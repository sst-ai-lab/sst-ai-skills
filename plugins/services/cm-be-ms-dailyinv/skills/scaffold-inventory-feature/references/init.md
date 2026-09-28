# Daily-inventory feature — initial creation (cm-be-ms-dailyinv)

This guide scaffolds a feature in the dual-datasource daily-inventory service. Per-layer rules live in the `cm-be-ms-common:scaffold-ms-feature` references and in this plugin's references (see the Related list in `SKILL.md`); Read them when you edit the matching files.

> **Out of scope:** `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` classes (external jars — never stub); `build/`; **tests**.

## Inputs to collect first

Ask; mark unknowns as "needs confirmation / 要確認":

1. **Function ID & name (機能ID・機能名)**.
2. **Entry type**: Kafka-triggered batch (`consumer/`) **or** gRPC endpoint (`grpc/`)?
3. **Datasources involved**: reads/writes on PostgreSQL, ClickHouse, or both? Which tables?
4. For writes: PostgreSQL upsert key (for `ON CONFLICT`) and column list; or ClickHouse delete-then-insert keys.
5. Process-log needed (batch flows use `ProcessLogHelper`)?

## Data flow (typical batch feature)

```
Kafka → consumer/ (batch, manual ack, ProcessLog init/commit)
  → service/ (read ClickHouse aggregates → compute in memory → batch upsert PostgreSQL)
  → mapper.clickhouse.* (analytical read)  +  mapper.postgres.* (UNNEST / ON CONFLICT upsert)
```

## Files to generate

### 1. Entry

- **Kafka:** `consumer/<Name>Consumer.java` — per `cm-be-ms-common:scaffold-ms-feature` `references/kafka-consumer.md`.
- **gRPC:** `grpc/core/<domain>/<Tag>Grpc.java` — `@GrpcService` extends the generated `*ServiceImplBase`, delegate to the service; convert exceptions to `responseObserver.onError(e)`.

### 2. Service — `service/<area>/<Tag>Service.java` + `Impl`

Per `cm-be-ms-common:scaffold-ms-feature` `references/service-layer.md` and `references/dual-datasource-rules.md`. Key reminder: use the **self-injection proxy** when one service method calls another `@Transactional` method of the same class.

### 3. MyBatis mappers — in the correct datasource package + folder

- PostgreSQL: `persistence/mapper/postgres/**/<Name>Mapper.java` + `mybatis/postgres/**/<Name>Mapper.xml` — per `cm-be-ms-common:scaffold-ms-feature` `references/mybatis-mapper.md` and `references/dual-datasource-rules.md`.
- ClickHouse: `persistence/mapper/clickhouse/**/<Name>Mapper.java` + `mybatis/clickhouse/**/<Name>Mapper.xml` — per `../../write-clickhouse-mappers/references/mybatis-clickhouse.md`.
- **Never put a mapper in the wrong package or its XML in the wrong `mybatis/<db>/` folder** — it won't resolve against the right `SqlSessionFactory`.

### 4. Entities / models

PostgreSQL entities under `persistence/model/core/**`; ClickHouse records/aggregates under `persistence/model/clickhouse/**`. Lombok builders; columns mapped explicitly (camel-case OFF).

### 5. MapStruct (fee-calc only)

`infrastructure/mapping/core/billcalc/<Tag>ServiceMapping.java` — entity ↔ gRPC; use the `@Mapper` configuration from the repository `CLAUDE.md` (Code conventions section).

## Completion checklist

1. Entry (consumer batch+ack+ProcessLog, or gRPC delegate+onError) created.
2. Service created; service-layer rule applied (self-proxy where calling inner `@Transactional`).
3. Mappers in the **correct datasource package** + XML in **matching `mybatis/<db>/` folder**.
4. Entities mapped explicitly (camel-case OFF).
5. No tests; no stubbed `com.fw.*`; no edits to `build/`.
