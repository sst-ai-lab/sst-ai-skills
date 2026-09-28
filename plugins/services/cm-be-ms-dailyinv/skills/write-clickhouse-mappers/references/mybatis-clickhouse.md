# MyBatis rules — ClickHouse mappers

Applies to: `**/mybatis/clickhouse/**/*.xml`

These are the **ClickHouse** statements (the analytical store — movement-history aggregates, daily-inv logs). Their mapper interfaces live in `…persistence.mapper.clickhouse.**` and are bound to the ClickHouse `SqlSessionFactory` (separate from PostgreSQL — see the Dual-datasource MyBatis table in the repository `CLAUDE.md`). Keep XML for these mappers only under `mybatis/clickhouse/**`.

- `namespace` = the fully-qualified ClickHouse mapper interface. Auto camel-case is OFF — map columns explicitly (or `resultType` with matching column names) and use `<foreach>` for `IN (...)` lists.
- **ClickHouse is not PostgreSQL — do not use PostgreSQL-only syntax here:**
  - No `unnest(...)`, no `::type[]` array casts, no `ON CONFLICT`. Those belong to the `mybatis/postgres/**` mappers.
  - ClickHouse has **no UPSERT**. To replace a row, use **delete-then-insert** (a `delete<Name>` followed by an `insert<Name>`), or a `ReplacingMergeTree`-style insert — follow the neighbouring mappers.
- Favour **set-based analytical reads** (aggregations, `GROUP BY`, JOINs across ClickHouse tables); these queries feed in-memory computation in the service.
- Keep SQL faithful to the design; uppercase keywords; `--` comments only as the last token on a line (prefer `/* … */`).
- Write ClickHouse SQL that's safe without rollback (idempotent, order-tolerant) — these statements are outside the service's `@Transactional` scope (see [dual-datasource-rules.md](../../scaffold-inventory-feature/references/dual-datasource-rules.md)).
