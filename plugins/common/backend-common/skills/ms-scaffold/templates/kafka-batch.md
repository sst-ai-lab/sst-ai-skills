# Kafka batch feature — initial creation

This guide scaffolds a Kafka-triggered batch feature (`{domain}`). Per-layer rules live in `../references/*.md`.

> **Out of scope:** gRPC server (this service is Kafka-driven, none exists); `com.fw.grpc.*` / `com.scm.core.*` / `cm-be-spec` classes (external jars — never stub); `target/`; **tests**.
> **Package:** declare new types under `{basePackage}` (see the repository `CLAUDE.md`).

## Inputs to collect first

Ask; mark unknowns as "needs confirmation / 要確認":

1. **Function ID & name (機能ID・機能名)**.
2. **Kafka topic / event** + message fields (the trigger).
3. **Downstream data**: which `{targetMicroservice}` gRPC method supplies the aggregates.
4. **Target table(s)** + upsert key (for `ON CONFLICT`) + column list.
5. Master lookups needed for the calculation.

## Data flow

```
Kafka ({topic}) → consumer (batch, ack-always, ProcessLog init/commit)
  → service: gRPC client → {targetMicroservice} (aggregates)
            → compute (in memory)
            → UNNEST batch upsert → PostgreSQL ({database})
```

## Files to generate

### 1. Kafka consumer — `consumer/<Name>Consumer.java`

Per `../references/kafka-consumer.md` (Variant `ack-always`, source: cm-be-ms-bill). Key reminder: **ack regardless** — outcomes go to the process log, not Kafka redelivery.

### 2. gRPC client to {targetMicroservice} — `infrastructure/grpc/{targetLc}/<Tag>Client.java` + `Impl` (+ mapping)

Per `../references/grpc-client.md`. Key reminder: `@GrpcClient` lives in `GrpcClientConfiguration` (re-exposed as `@Bean`), **never** on a `*ClientImpl` field.

### 3. Service — `service/core/{domain}/<Tag>Service.java` + `Impl`

Per `../references/service-layer.md`. Throw `{serviceException}` (with an `ErrorCodeEnum`) for domain failures.

### 4. MyBatis mapper — `persistence/mapper/core/{domain}/<Name>Mapper.java` + `mybatis/mapper/{domain}/<Name>Mapper.xml`

Per `../references/mybatis-mapper.md`. Map every column explicitly (camel-case is OFF).

### 5. Entities / models — `persistence/model/core/{domain}/<Name>Entity.java`

Lombok entities matching columns; add request/row/master models as the calculation needs.

## Completion checklist

1. Consumer created — ack-always; ProcessLog lifecycle owned here.
2. gRPC client wired — `@GrpcClient` only in `GrpcClientConfiguration` (not on impl).
3. Service created — `@Transactional` for PostgreSQL; throws `{serviceException}` on domain failures.
4. MyBatis: UNNEST + `ON CONFLICT`; columns mapped explicitly (camel-case OFF).
5. Entities mapped explicitly.
6. No gRPC server; no tests; no stubbed external classes; no edits to `target/`.
