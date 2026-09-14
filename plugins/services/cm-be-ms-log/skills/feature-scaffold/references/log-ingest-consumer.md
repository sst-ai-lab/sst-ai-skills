# Kafka consumer rules (cm-be-ms-log log ingestion)

Applies to: `**/consumer/**/*.java`

Service-specific parts of this repository's Kafka consumer rules. The generic rules (batch + manual ack, double-encoded JSON parsing, ack-policy variants) are in `backend-common:ms-scaffold` → `references/kafka-consumer.md`.

The consumer in `consumer/` is the **log-ingestion** entry point: it receives process-log events and persists them through the service layer.

## Listener shape

- `@Component` + `@RequiredArgsConstructor` + `@Slf4j`; inject the target `*Service` and an `ObjectMapper` as `private final`.
- `@KafkaListener(topics = LogEventTopic.<TOPIC>, groupId = "${spring.kafka.consumer.group-id}", concurrency = "...")` — topic constants come from `com.scm.core.constant.LogEventTopic`. Set `concurrency` to match the topic partition count.
- **Batch mode** (`List<String> messages`) + **manual ack** (`org.springframework.kafka.support.Acknowledgment`). The container is forced to batch + manual-ack in `KafkaConfiguration` — don't re-configure ack mode on the listener.

## Processing contract

- When ordering matters, sort the parsed batch (the process-log consumer sorts by `sendTimestampNanos`, nulls last) before processing.
- Dispatch by the message's `messageType` (`com.scm.core.constant.LogMessageType` — `INIT` / `DETAIL` / `COMMIT`) and delegate each to the corresponding service method. **No business logic / no DB access in the consumer** — build the typed `*Message` (Lombok builder) and hand it to the service.
