---
name: write-clickhouse-mappers
description: MyBatis rules for ClickHouse mappers in cm-be-ms-dailyinv — the analytical store (movement-history aggregates, daily-inv logs) bound to the ClickHouse SqlSessionFactory. Use when creating or editing `**/mybatis/clickhouse/**/*.xml` or `…persistence.mapper.clickhouse.**` mapper interfaces (no unnest / ::type[] / ON CONFLICT, no UPSERT → delete-then-insert, set-based analytical reads, SQL safe without rollback) in the cm-be-ms-dailyinv repository.
---

# MyBatis rules — ClickHouse mappers — cm-be-ms-dailyinv

## When to use

- Writing the **ClickHouse** statements (the analytical store — movement-history aggregates, daily-inv logs). Their mapper interfaces live in `…persistence.mapper.clickhouse.**`; XML only under `mybatis/clickhouse/**`.

## How to use

| Pattern | File | Description |
|---|---|---|
| ClickHouse mapper rules | `references/mybatis-clickhouse.md` | Namespace/column mapping, no PostgreSQL-only syntax, delete-then-insert, analytical reads, SQL safe without rollback |

## Related

- Datasource package/folder rule and scaffolding: `../scaffold-inventory-feature/SKILL.md`.
- `@Transactional` scope (PostgreSQL only): `../scaffold-inventory-feature/references/dual-datasource-rules.md`.
