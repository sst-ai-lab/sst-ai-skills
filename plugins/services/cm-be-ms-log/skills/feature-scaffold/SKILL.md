---
name: feature-scaffold
description: Scaffolds a log-microservice feature in cm-be-ms-log — a gRPC search endpoint (PostgreSQL/MyBatis and/or AWS Athena) or a Kafka log-ingestion path. Generates gRPC impl, Service, MyBatis mapper + XML, Athena client, MapStruct mapping, and entities. No tests. Use when adding or extending a log-head/detail search, history-data search, or process/operation-log ingestion feature in the cm-be-ms-log repository, or when editing its service or consumer classes.
---

# Backend skill (logging / log-search MS) — cm-be-ms-log

## When to use

- Adding or extending a feature **inside this microservice**:
  - a **gRPC search endpoint** served to the BFF — log-head/detail search over **PostgreSQL/MyBatis**, or history-data search over **AWS Athena** (S3-backed log data), or a hybrid (column defs from PostgreSQL + rows from Athena);
  - a **Kafka log-ingestion** path — consume a process/operation-log event and persist it to PostgreSQL.

## Scope

- **Generates:** gRPC service impl (`@GrpcService`, delegate-only), Service interface + `*Impl` (search) or concrete `@Service` (ingest), MyBatis mapper interface + `*Mapper.xml` (PostgreSQL), Athena client `*AthenaClient` + `*Impl` (when the data is in Athena/S3), MapStruct `*ServiceMapping`, plain Lombok entities/request models, and a `@KafkaListener` consumer when the feature is ingestion.
- **Does NOT generate:** tests; proto/gRPC stubs or shared DTOs/messages/constants/exceptions (they come from the `cm-be-spec` / `scm-be-grpc-core` internal jars as `com.fw.grpc.*` / `com.scm.core.*` — treat as external, never stub).

## How to use

| Pattern | File | Description |
|---|---|---|
| Initial creation | `references/init.md` | Steps to scaffold a search or ingestion feature for this repo's layers |
| Layer rules (service-specific) | `references/log-service-rules.md` | cm-be-ms-log-only service-layer, gRPC error-handling and MyBatis rules |
| Layer rules (service-specific) | `references/log-ingest-consumer.md` | cm-be-ms-log-only Kafka consumer rules (INIT/DETAIL/COMMIT dispatch, ordering) |

## Related

- Layer rules — Read before you edit the matching files:
  - gRPC server: `backend-common:ms-scaffold` → `references/grpc-server.md` + `references/log-service-rules.md`
  - Kafka consumer: `backend-common:ms-scaffold` → `references/kafka-consumer.md` + `references/log-ingest-consumer.md`
  - Service layer: `backend-common:ms-scaffold` → `references/service-layer.md` + `references/log-service-rules.md`
  - Athena client: `../athena-guide/references/athena-client.md`
  - MyBatis mapper: `backend-common:ms-scaffold` → `references/mybatis-mapper.md` + `references/log-service-rules.md`
- Repo conventions & build constraints: the repository `CLAUDE.md`.
