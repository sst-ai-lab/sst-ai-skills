# Log-MS feature — initial creation (cm-be-ms-log)

This guide scaffolds a feature for the logging microservice. It has two flavours — pick the one the design needs (or both):

- **Search** — a gRPC endpoint the BFF calls, reading from **PostgreSQL/MyBatis** and/or **AWS Athena**.
- **Ingestion** — a Kafka consumer that persists log events to PostgreSQL.

Per-layer rules are in the `backend-common:ms-scaffold` references and in this skill's `references/` (see the Related list in `SKILL.md`); Read them when you edit the matching files.

> **Out of scope:** tests; `com.fw.grpc.*` / `com.scm.core.*` / `cm-be-spec` classes (external jars — never stub); `target/` (generated).
> **Package:** declare new types under `com.cm.ms.log` (this repo's `com.cm` groupId — see overview).

## Inputs to collect first

Ask; mark unknowns as "needs confirmation / 要確認" (don't invent):

1. **Function ID & name (機能ID・機能名)** → class names (see the naming table in the repository `CLAUDE.md`).
2. **Flavour:** search (gRPC) or ingestion (Kafka)?
3. **gRPC service + method** (search): the generated `com.fw.grpc.*ServiceImplBase` + RPC, with request/response message types.
4. **Kafka topic / event** (ingestion): the `LogEventTopic` constant + the `com.scm.core.message.*` message type and its `messageType` variants.
5. **Data store:** PostgreSQL table(s) (DB `Log`, schema `CM`) via MyBatis, and/or an **Athena** database/table (S3-backed). For history-data search, note that column metadata comes from PostgreSQL `information_schema` while rows come from Athena.
6. **Read or write**, and any identifiers that get interpolated into SQL (these must be validated).

## Files to generate

### Search flavour

1. **gRPC impl — `grpc/core/<domain>/<Tag>Grpc.java`**
   Per `backend-common:ms-scaffold` `references/grpc-server.md` and `references/log-service-rules.md`. Key reminder: errors are mapped/forwarded **locally** in this impl (no central advice) — `IllegalArgumentException` → `Status.INVALID_ARGUMENT`, others → `onError`.

2. **Service — `service/core/<domain>/<Tag>Service.java` + `<Tag>ServiceImpl.java`**
   Per `backend-common:ms-scaffold` `references/service-layer.md` and `references/log-service-rules.md`. Key reminder: **validate any SQL-interpolated identifier** before querying — Athena SQL is string-built (not parameterized).

3. **Athena client (only if rows come from Athena) — `infrastructure/athena/core/<domain>/<Tag>AthenaClient.java` + `Impl.java`**
   Per `../../athena-guide/references/athena-client.md`. Key reminder: the client only quotes identifiers — **the caller must validate them** before passing in.

4. **MyBatis mapper (PostgreSQL parts) — `persistence/mapper/core/<domain>/<Name>Mapper.java` + `mybatis/mapper/core/<domain>/<Name>Mapper.xml`**
   Per `backend-common:ms-scaffold` `references/mybatis-mapper.md` and `references/log-service-rules.md`. Key reminder: **map every column explicitly** (auto camel-case is OFF).

5. **MapStruct mapping — `infrastructure/mapping/core/<domain>/<Tag>ServiceMapping.java`**
   `@Mapper` header per the repository `CLAUDE.md` (Code conventions). Mappings here are typically `default` methods that build the gRPC response from `Map`/entity rows and pagination metadata.

6. **Entities / request models — `persistence/model/core/<domain>/<Name>Entity.java` / `<Name>Request.java`**
   Plain Lombok (`@Data @Builder @NoArgsConstructor @AllArgsConstructor`) with explicit `add*` audit fields — **no `BaseEntity`, no `exclusioncheck`**. Request models may extend `com.scm.core.dto.ListRequestMetadata` for paging.

### Ingestion flavour

1. **Kafka consumer — `consumer/<Name>Consumer.java`**
   Per `backend-common:ms-scaffold` `references/kafka-consumer.md` and `references/log-ingest-consumer.md`. Key reminder: dispatch by `messageType` (INIT/DETAIL/COMMIT) and delegate to the service — no business logic in the consumer.

2. **Service — `service/core/<domain>/<Name>Service.java`** (concrete `@Service`)
   Per `backend-common:ms-scaffold` `references/service-layer.md` and `references/log-service-rules.md`. `@Transactional` on PostgreSQL writes; truncate inbound strings to column lengths before persisting.

3. **MyBatis mapper + XML** — as above (PostgreSQL insert/update).

## Completion checklist

1. gRPC impl delegates only; errors mapped/forwarded locally (no central advice).
2. Service validates SQL-interpolated identifiers; `@Transactional` on PostgreSQL writes; paging + audit resolved.
3. Athena client (if used): caller-validated identifiers, header row skipped.
4. MyBatis: explicit column mapping (camel-case OFF); faithful PostgreSQL SQL.
5. MapStruct mapper header per overview.
6. Entities are plain Lombok with explicit audit fields (no `BaseEntity`).
7. Consumer (ingestion): batch + manual ack; dispatch by `messageType`.
8. No tests; no stubbed `com.fw.grpc.*` / `com.scm.core.*` / `cm-be-spec` classes; no edits to `target/`.
