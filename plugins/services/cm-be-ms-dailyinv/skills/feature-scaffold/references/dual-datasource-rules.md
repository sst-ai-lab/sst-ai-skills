# Service-layer rules (dual-datasource)

Applies to: `**/service/**/*.java`

Service-specific parts of this repository's service-layer and PostgreSQL mapper rules. The generic rules (self-injection proxy, batch persistence) are in `backend-common:ms-scaffold` → `references/service-layer.md` and `references/mybatis-mapper.md`; the ClickHouse mapper rules are in `../../clickhouse-guide/references/mybatis-clickhouse.md`.

Services in `service/` orchestrate the daily-inventory build and fee-calc aggregation. A single service may read from **ClickHouse** and write to **PostgreSQL** in the same flow — inject the mappers it needs from **both** packages (`…mapper.postgres.*` and `…mapper.clickhouse.*`).

## Transactions span PostgreSQL only

- `@Transactional` (`org.springframework.transaction.annotation.Transactional`) is governed by the **PostgreSQL** (primary) transaction manager. **ClickHouse writes are NOT part of it** and won't roll back — make ClickHouse changes idempotent and order them so a failure leaves a recoverable state.

## Domain exception

- Throw **`DailyInventoryException`** (with an `ErrorCodeEnum`) for domain failures; log the detail line before throwing.

# MyBatis rules — PostgreSQL mappers

Applies to: `**/mybatis/postgres/**/*.xml`

These are the **PostgreSQL** statements (the primary, transactional ledger). Their mapper interfaces live in `…persistence.mapper.postgres.**` and are bound to the PostgreSQL `SqlSessionFactory` (primary — see the Dual-datasource MyBatis table in the repository `CLAUDE.md`). Keep XML for these mappers only under `mybatis/postgres/**`.

- `namespace` = the fully-qualified PostgreSQL mapper interface.
