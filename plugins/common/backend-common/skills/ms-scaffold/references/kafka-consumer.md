# Kafka consumer rules

Applies to: `**/consumer/**/*.java` (sources: cm-be-ms-bill, cm-be-ms-dailyinv, cm-be-ms-log) or `**/infrastructure/message/**/*.java` (source: cm-be-ms-inout)

The consumer is a (non-gRPC) entry point that triggers processing on the service layer. The sources agree on the listener shape but disagree on **when to ack and whether to rethrow**. Each ack policy is kept as a named variant, selected by the repository `CLAUDE.md` `## Policies` → `kafka-ack`. If it is not set, ask the user.

## Common (rules repeated in several sources)

- `@Component` + `@RequiredArgsConstructor`; `@KafkaListener(topics = <Topic constant>, groupId = "${spring.kafka.consumer.group-id}")`. (source: cm-be-ms-dailyinv; same in cm-be-ms-bill, cm-be-ms-log)
- **Batch mode** (`List<String> messages`) with **manual ack** (`Acknowledgment`). (source: cm-be-ms-dailyinv; same in cm-be-ms-bill, cm-be-ms-log; cm-be-ms-inout uses `List<ConsumerRecord<String, Object>>` — see its variant)
- Parse each message defensively: handle **double-encoded JSON** (try `readValue(json, String.class)` first, fall back to the raw string), then deserialize to the message type. Log-and-skip a single un-parseable message rather than failing the whole batch. (source: cm-be-ms-dailyinv; same in cm-be-ms-bill, cm-be-ms-log)
- Convert the message to the service DTO and delegate the actual work to the service, passing the `logId`; the consumer holds **no business logic**. (source: cm-be-ms-dailyinv; same in cm-be-ms-bill; cm-be-ms-log and cm-be-ms-inout: no business logic / no SQL in the consumer)

## Process-log lifecycle (owned by the consumer) (sources: cm-be-ms-bill, cm-be-ms-dailyinv)

- Initialize once via `processLog.initLog(companyCd, LogProcessKbn.…, "…")` (lazily, on the first message that yields a company code) and reuse the returned `logId` for the batch. (source: cm-be-ms-dailyinv)
  - cm-be-ms-bill signature: `processLog.initLog(companyCd, LogProcessKbn.…, "…", user, user, terminal)`.
- On success call `processLog.commitSuccess(companyCd, logId, …)`; on failure `processLog.addLogDetail(…, LogLevel.ERROR, …)` + `processLog.commitFailed(companyCd, logId, …)`. (source: cm-be-ms-dailyinv)
  - cm-be-ms-bill: On success: `processLog.addLogDetail(...)` + `processLog.commitSuccess(companyCd, logId, …)`. On failure: `addLogDetail(..., LogLevel.ERROR, …)` + `processLog.commitFailed(companyCd, logId, …)`.

---

## Variant `ack-always` (source: cm-be-ms-bill)

- **Batch mode** (`List<String> messages`) + **manual ack** (`Acknowledgment`).
- **Ack regardless of success or failure** — the outcome is recorded in the process log, not via Kafka redelivery. (Differs from consumers that rethrow to force redelivery; here the process log is the source of truth.) Catch exceptions around the batch, log + commit-failed, then `ack.acknowledge()`.
- Parse defensively: handle **double-encoded JSON** (`readValue(json, String.class)` first, fall back to the raw string), then deserialize to the message type. Log-and-skip a single un-parseable message; continue the batch.

## Variant `rethrow` (source: cm-be-ms-dailyinv)

- **Batch mode** (`List<String> messages`) with **manual ack** (`Acknowledgment`): process every message, then `ack.acknowledge()` once at the end. On exception, finish the failure logging and **rethrow** so Kafka redelivers — don't swallow.

## Variant `rethrow-batch-fatal` (source: cm-be-ms-log)

> The dispatch by `messageType` (`INIT` / `DETAIL` / `COMMIT`) of this source is specific to process-log ingestion — see the `cm-be-ms-log` service plugin.

### Listener shape

- `@Component` + `@RequiredArgsConstructor` + `@Slf4j`; inject the target `*Service` and an `ObjectMapper` as `private final`.
- `@KafkaListener(topics = {topicConstantClass}.<TOPIC>, groupId = "${spring.kafka.consumer.group-id}", concurrency = "...")` — topic constants come from `{topicConstantClass}`. Set `concurrency` to match the topic partition count.
- **Batch mode** (`List<String> messages`) + **manual ack** (`org.springframework.kafka.support.Acknowledgment`). The container is forced to batch + manual-ack in `KafkaConfiguration` — don't re-configure ack mode on the listener.

### Processing contract

- Parse each message **defensively**: the payload is **double-encoded JSON** — `objectMapper.readValue(json, String.class)` first to unwrap, then deserialize to the message type (`com.scm.core.message.*`). Log-and-skip a single un-parseable message (return `null`, filter it out); never let one bad message abort the batch.
- When ordering matters, sort the parsed batch before processing.
- **No business logic / no DB access in the consumer** — build the typed `*Message` (Lombok builder) and hand it to the service.
- **Ack after the batch is processed.** Per-message processing failures are caught, logged, and skipped (the batch continues); a fatal batch-level error is rethrown **before** `ack.acknowledge()` so the batch is redelivered. Keep `ack.acknowledge()` as the last successful step.

## Variant `ack-after-success` (source: cm-be-ms-inout)

Kafka consumers under `infrastructure/message/consumer` are ingestion entry points:
they receive events and hand them to the service layer for batch persistence.
Keep them thin — no SQL and no business rules here.

### Listener shape

- Use a **batch** listener with **manual ack**: `@KafkaListener` taking
  `@Payload List<ConsumerRecord<String, Object>> records` and an `Acknowledgment`
  parameter, bound to the batch container factory.
- On an empty batch, `acknowledge()` and return early.
- **Acknowledge only after** the batch has been processed and handed to the service
  successfully — never ack before processing. If persistence fails, do **not** ack;
  let the batch be redelivered.

### Payload handling

- A record value may arrive as a `String`, `byte[]`, or an already-parsed map depending
  on deserializer config — **normalize** it first (parse `String`/`byte[]` via
  `ObjectMapper.readTree`; pass parsed values through).
- A single message may map to **one or more** entity types via
  `objectMapper.convertValue(normalized, XxxEntity.class)`. Configure entities to ignore
  unknown properties so extra fields are tolerated.
- After converting, **guard required keys** (e.g. only keep an entity when its
  primary-key fields are non-null) so partial or irrelevant payloads are skipped.

### Robustness

- Wrap per-record deserialization in try/catch and **log-and-skip** a malformed record
  (log topic/partition/offset/key) — one bad message must not fail the whole batch.
- Don't rely on ordering or exactly-once delivery. Assume **at-least-once**: persistence
  must be idempotent, so duplicate deliveries are safe. (The idempotency mechanism itself
  belongs in the persistence layer, not here.)
- Keep the consumer to: normalize → convert → guard → delegate to the service layer.
