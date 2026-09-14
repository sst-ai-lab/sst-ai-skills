# MyBatis mapper XML rules

Applies to: `**/mybatis/**/*.xml`

The common rules below are taken from the most thorough source (cm-be-ms-core); the same rules appear in shorter form in cm-be-ms-inout, cm-be-ms-bill, cm-be-ms-log and cm-be-ms-dailyinv (PostgreSQL mappers). Where the sources differ (XML layout, `ON CONFLICT` behaviour), each source rule is kept as a named variant selected by the repository `CLAUDE.md` `## Policies` → `mybatis-xml-layout` / `unnest-on-conflict`. If it is not set, ask the user. ClickHouse mapper rules are service-specific — see the `cm-be-ms-dailyinv` service plugin.

## Structure

- Start with the MyBatis 3.0 DOCTYPE and set `namespace` to the **fully-qualified mapper interface** — it must match exactly, or statements won't bind.
- One `<select>/<insert>/<update>/<delete>` `id` per interface method, with matching `parameterType` / `resultMap` (or `resultType`).

## Column ↔ property mapping is explicit (no auto camel-case)

`mybatis.configuration.map-underscore-to-camel-case` is **`false`** in this service. MyBatis will **not** convert `ship_sch_date` → `shipSchDate`. So you must make columns line up with entity properties by **either**:

- declaring a `<resultMap>` that maps each `property` to its `column` (the dominant pattern — see `{referenceMapperXml}`), **or**
- aliasing each selected column to the exact property name (`select so.ownersono as ownerSoNo`).

When you add a field to an entity, add the corresponding `<result>` (or column alias) here too — an unmapped column is silently dropped.

- Keep shared column lists in reusable `<sql>` fragments (`<include refid="..."/>`). (source: cm-be-ms-inout; same in cm-be-ms-bill, cm-be-ms-dailyinv)
- `... AS "headerName"` — note the double-quotes to preserve camel-case in PostgreSQL. (source: cm-be-ms-log)

## SQL must stay faithful to the design

Generated/edited SQL must reproduce the design document's query **as-is** — this is a hard rule:

- **Do not drop or "simplify"** JOINs, subqueries, `COALESCE(...)`, `GROUP BY`, window functions, or filter conditions.
- **Preserve PostgreSQL-specific syntax**: type casts (`::TEXT`, `::numeric`, `::date`), `COALESCE`, `DISTINCT ON`, etc. This is a PostgreSQL database — don't rewrite to ANSI-only equivalents.
- Keep SQL keywords uppercase (Prettier-SQL / Checkstyle expectation).

Additional items from other sources:

- **Do not drop or "simplify"** … date arithmetic. **Preserve PostgreSQL-specific syntax**: `TO_CHAR(...)` / `TO_DATE(...)` date formatting, `interval '1 day'`, `::regclass` casts, `information_schema` lookups, `LOWER(...)`, etc. (source: cm-be-ms-log)
- Escape comparison operators that break XML: wrap `>=` / `<` in `<![CDATA[ ... ]]>` (see `{referenceMapperXml}`). (source: cm-be-ms-log)
- Keep SQL faithful to the design — don't drop columns from the array/column list, and preserve the `unnest(...) … ON CONFLICT` structure. (source: cm-be-ms-inout)

## Comments — the `--` hazard

Existing mappers annotate columns with end-of-line `--` comments (e.g. `so.sono as sono, --出荷予定番号`). This works **only** because each `--` is the last thing on its physical line. A `--` comment silently comments out **everything after it on the same line**, so it is dangerous if SQL is reformatted, minified, or a fragment is moved onto a commented line — especially inside dynamic `<if>`/`<foreach>` blocks.

- **Prefer `/* … */` block comments** for inline annotations (the `ms-scaffold` skill mandates this).
- If you keep a `--` comment, it must be the **last token on its line**, with a newline before any further SQL. Never place SQL after `--` on the same line, and never let an editor/formatter join a `--` line into the following SQL.

## Dynamic SQL & writes

- Use `<if>`, `<choose>`, `<foreach>` for conditional/bulk SQL; guard against an empty `<foreach>` producing invalid SQL (e.g. `IN ()`).
- Bulk `update`/`insert` statements return the affected-row count; the service compares it against the expected count for optimistic-lock / integrity checks (see [service-layer.md](service-layer.md)) — keep the statement counting rows accurately. (source: cm-be-ms-core)
- Writes that touch business tables must set the audit columns (`upd*` / `add*`) and respect the `exclusioncheck` optimistic-lock column. (source: cm-be-ms-core)
- Writes that touch log tables set the audit columns (`addusercd` / `addusername` / `addterminalcd`, and `adddatetime` via `CURRENT_TIMESTAMP`). (source: cm-be-ms-log)

---

## XML layout — policy `mybatis-xml-layout`

### Variant `mapper-per-domain` (sources: cm-be-ms-core, cm-be-ms-log)

MyBatis mapper XML lives in `src/main/resources/mybatis/mapper/core/<domain>/<Name>Mapper.xml` and is paired with a `@Mapper` interface at `{basePackage}.persistence.mapper.core.<domain>.<Name>Mapper`. Loaded via `mybatis.mapper-locations=classpath*:mybatis/**/*.xml`.

### Variant `mapper-plus-mapping` (source: cm-be-ms-inout)

MyBatis XML lives under `src/main/resources/mybatis/` and is split into two kinds (both
loaded by `mapper-locations: classpath*:mybatis/**/*.xml`):

- **`mybatis/mapper/<Name>Mapper.xml`** — SQL statements; `namespace` = the fully-qualified
  mapper interface.
- **`mybatis/mapping/<Name>Mapping.xml`** — `<resultMap>` definitions under a separate logical
  namespace, referenced by the statements.

Map every column explicitly in a `<resultMap>` (in the `mapping/` file), or alias the column to the exact property name.

### Variant `mapper-tree` (source: cm-be-ms-bill)

MyBatis XML lives under `src/main/resources/mybatis/mapper/**` (loaded via `mapper-locations: classpath*:mybatis/**/*.xml`). The mapper interfaces are under `…persistence.mapper.core.**`. The datastore is **PostgreSQL** (DB `{database}`).

> cm-be-ms-dailyinv keeps PostgreSQL mapper XML only under `mybatis/postgres/**` (interfaces in `…persistence.mapper.postgres.**`) because it has two datasources — service-specific, see the `cm-be-ms-dailyinv` service plugin.

---

## UNNEST batch upsert — policy `unnest-on-conflict`

### Variant `do-nothing` (source: cm-be-ms-inout)

High-throughput writes use a single PostgreSQL
`INSERT … SELECT … FROM unnest(<arrays>) … ON CONFLICT DO NOTHING` statement instead of
per-row inserts:

- Bind one **array per column**, in the **same order** as the column list — a misaligned array
  silently writes the wrong column.
- Resolve array element types via the project's array `typeHandler` on each `#{...}` parameter
  (it sets the correct PostgreSQL type). Match each array to its column type; don't add
  redundant `::type[]` casts unless a parameter genuinely needs one.
- End with **`ON CONFLICT (<pk>) DO NOTHING`** — this is what makes re-consumed batches
  idempotent. Don't replace it with a plain `INSERT` (which errors on duplicates) unless the
  design explicitly wants upsert-update semantics.
- Comments: a `--` line comment swallows the rest of its line, which is risky inside
  array/statement blocks. Prefer `/* … */`; if you use `--`, keep it the last token on the line.

### Variant `do-update-or-nothing` (source: cm-be-ms-bill; near-identical in cm-be-ms-dailyinv)

- **Bulk upsert** uses PostgreSQL `INSERT … SELECT … FROM unnest(#{…Arr, typeHandler=…}, …) … ON CONFLICT (<pk>) DO UPDATE/NOTHING`:
  - Arrays come from a params builder, each bound via the project's array `typeHandler` — **array element order must match the column order exactly**; the typeHandler sets the PostgreSQL array element type, so no `::type[]` casts are needed.
  - Choose `DO UPDATE` vs `DO NOTHING` to match the statement's intent; keep the statement set-based, not row-by-row — the service handles chunking (see [service-layer.md](service-layer.md)).

cm-be-ms-dailyinv wording of the same rule:

- **Bulk upsert** is the main write path:
  - For large inserts use PostgreSQL `INSERT … SELECT … FROM unnest(#{…Arr, typeHandler=…}, …)` with arrays from a params builder, each bound via the project's array `typeHandler` — **array element order must match the column order exactly**; the typeHandler sets the PostgreSQL array element type, so no `::type[]` casts are needed.
  - End with **`ON CONFLICT (<pk>) DO UPDATE …`** for read-modify-write upserts (e.g. balances) or `DO NOTHING` for idempotent inserts — match the existing statement's intent.
  - Keep the statement set-based, not row-by-row — the service handles chunking (see [service-layer.md](service-layer.md)).
