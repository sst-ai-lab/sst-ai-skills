---
name: scaffold-inventory-feature
description: Scaffolds a daily-inventory feature in cm-be-ms-dailyinv — a Kafka-consumer or gRPC entry, a dual-datasource service (PostgreSQL + ClickHouse), MyBatis mappers in the correct datasource package/folder, and entities. No tests. Use when adding a Kafka-triggered batch (build/aggregate inventory) or a gRPC aggregation endpoint, or when editing service classes that combine PostgreSQL and ClickHouse (@Transactional scope, DailyInventoryException), in the cm-be-ms-dailyinv repository.
---

# Backend skill (daily-inventory, dual-datasource) — cm-be-ms-dailyinv

## When to use

- Adding a feature in this microservice: a Kafka-triggered batch (build/aggregate inventory) **or** a gRPC aggregation endpoint, backed by PostgreSQL and/or ClickHouse.

## Scope

- **Generates:** the entry (`consumer/` Kafka listener **or** `grpc/` `@GrpcService` impl), a `service/` orchestration (dual-datasource; `@Transactional` for PostgreSQL; `ProcessLogHelper`), MyBatis mapper interface(s) + XML **in the matching datasource package/folder**, entities, and (for fee-calc) the MapStruct mapping.
- **Does NOT generate:** `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` classes (external generated jars — never stub), or tests.

## The one rule you must get right

A mapper is bound to a datasource **by package**, and its XML must match:

| Datasource              | Mapper interface package            | XML folder              |
| ----------------------- | ----------------------------------- | ----------------------- |
| PostgreSQL (primary)    | `…persistence.mapper.postgres.**`   | `mybatis/postgres/**`   |
| ClickHouse (analytical) | `…persistence.mapper.clickhouse.**` | `mybatis/clickhouse/**` |

Never mix the two. PostgreSQL = UNNEST / `ON CONFLICT`; ClickHouse = analytical reads + delete-then-insert.

## How to use

| Pattern          | File                                  | Description                                 |
| ---------------- | ------------------------------------- | ------------------------------------------- |
| Initial creation | `references/init.md`                  | Steps to scaffold a daily-inventory feature |
| Layer rules (service-specific) | `references/dual-datasource-rules.md` | Dual-datasource service rules: `@Transactional` spans PostgreSQL only, datasource ↔ `SqlSessionFactory` binding, `DailyInventoryException` |

## Related

- Layer rules — Read before you edit the matching files: `cm-be-ms-common:scaffold-ms-feature` → `references/kafka-consumer.md`, `references/service-layer.md` (+ `references/dual-datasource-rules.md`), `references/mybatis-mapper.md` (PostgreSQL); `../write-clickhouse-mappers/references/mybatis-clickhouse.md` (ClickHouse).
- Repo conventions & build constraints: the repository `CLAUDE.md`.
