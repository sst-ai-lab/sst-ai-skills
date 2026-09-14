# Athena client rules

Applies to: `**/infrastructure/athena/**/*.java`

Classes in `infrastructure/athena/core/<domain>` query **AWS Athena** (which reads log data stored in S3) using the **AWS SDK v2** synchronous client. This is the service's second data store, separate from PostgreSQL/MyBatis.

## Client & configuration

- Inject the shared `software.amazon.awssdk.services.athena.AthenaClient` bean (declared in `configuration/AthenaConfiguration`, built with `DefaultCredentialsProvider`) as a `private final` constructor dep (`@Component` + `@RequiredArgsConstructor`). Do **not** build a new client per call.
- Read Athena settings from `@Value("${app.athena.*}")`: `database`, `workgroup` (default `primary`), `output-location` (S3 result URI), `poll-interval-ms`, `max-wait-attempts`.
- **Validate config before querying:** fail fast (`IllegalStateException`) if `database` or `output-location` is blank — Athena cannot run without them.

## Query lifecycle — start, poll, fetch

Athena is asynchronous; the SDK v2 calls are wrapped in a three-step blocking flow:

1. **Start** — `startQueryExecution` with `QueryExecutionContext.database(database)`, `ResultConfiguration.outputLocation(outputLocation)`, and `workGroup` when set; keep the returned `queryExecutionId`.
2. **Poll** — loop `getQueryExecution` up to `max-wait-attempts`, sleeping `poll-interval-ms` between attempts. On `SUCCEEDED` return; on `FAILED`/`CANCELLED` throw `IllegalStateException` with the `stateChangeReason`; on timeout throw. Re-set the interrupt flag if `Thread.sleep` is interrupted.
3. **Fetch** — page through `getQueryResults` following `nextToken`; on the **first** page skip row 0 (it is the column header), map each `Row`'s `Datum.varCharValue()` to a `LinkedHashMap<String,Object>` keyed by `ColumnInfo.name()` (null → empty string).

## SQL & identifier safety

- Athena SQL here is **string-built, not parameterized** — there is no bind-parameter API in this flow. Any identifier (table name) **must already be validated by the caller** (the service enforces `[a-zA-Z0-9_]+`); the client only double-quotes identifiers via `quoteIdentifier(...)`. Never interpolate un-validated user input.
- Use Athena/Presto/Trino SQL dialect (e.g. `OFFSET ... LIMIT ...` paging, `COUNT(*)`), not PostgreSQL-specific syntax — this path does not touch PostgreSQL.

## Boundary

- Keep the client **data-access only**: run the query and return rows/counts as `List<Map<String,Object>>` / `int`. Pagination math, validation, and gRPC assembly belong in the service / mapping layers.
