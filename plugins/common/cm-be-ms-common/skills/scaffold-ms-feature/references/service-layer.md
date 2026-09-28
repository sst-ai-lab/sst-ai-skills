# Service-layer rules

Applies to: `**/service/**/*.java`

Microservices differ on service shape, transactions and error handling. The rules that hold everywhere come first; then each way is kept as a named variant. Follow the variant the existing `*ServiceImpl` classes of this repository use; when there is none, ask the user.

## Common rules

- Split **interface + `*Impl`**. The impl is `@Service` + `@RequiredArgsConstructor` (inject mappers/publishers as `private final` fields). Ingest-only services may be concrete `@Service` classes without an interface — see the variants.
- A method is invoked by the gRPC layer; it may take/return gRPC message types directly, or work with entities and use a MapStruct mapper for the response — follow the pattern of neighbouring services in the domain.
- Signal failures by throwing a typed exception from `com.fw.core.exception.*` (with an `ErrorCodeEnum`) — e.g. `ForbiddenException` / `BadRequestException` / `NotFoundException` — rather than returning null or status flags. Don't catch a downstream gRPC error just to swallow it; let it surface to the central gRPC `Status` mapping. A repository that declares its own domain exception uses that one instead — follow what its existing services throw.
- Compute results in memory first (e.g. in a keyed map), then **persist in chunks** (size is a tunable constant) via the mapper's batch upsert — avoid per-row DB calls in loops.

## Transactions & the self-injection proxy

- Put `@Transactional` on the **unit of work**, not necessarily the top-level entry. Keep transactions short — do the in-memory computation first, then a batched write.
- A `@Transactional` method called from another method **of the same bean** bypasses the Spring proxy and won't start a transaction. Route the call through a self-injected proxy:

```java
private XxxService self;
@Lazy @Autowired void setSelf(XxxService self) { this.self = self; }
// ...
self.transactionalMethod(...);   // goes through the proxy → @Transactional applies
```

---

## Variant `crud-transactional`

Services in `service/core/<domain>` hold the business logic. A gRPC impl delegates to a service; the service orchestrates MyBatis mappers (data) and MapStruct mappers (entity ↔ gRPC), and returns the result.

### Shape

- Split **interface + `*Impl`**. The impl is `@Service` + `@RequiredArgsConstructor` (inject mappers/publishers as `private final` fields).
- A method is invoked by the gRPC layer; it may take/return gRPC message types directly, or work with entities and use a MapStruct mapper for the response — follow the pattern of neighbouring services in the domain.

### Transactions

- Annotate every method that writes (insert/update/delete, multi-step state changes) with `@Transactional` (`org.springframework.transaction.annotation.Transactional`). Read-only queries don't need it.
- Publish Kafka domain events (e.g. via `{eventPublisher}`) **after** the persistence succeeds within the same transactional method, so events reflect committed state.

### Error handling — throw typed domain exceptions

Throw exceptions from `com.fw.core.exception.*` with an `ErrorCodeEnum`; never return null/error flags, and don't catch-and-swallow (a central advice maps these to gRPC `Status`):

- **`ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED)`** — caller lacks permission / no permission scope.
- **`NotFoundException(ErrorCodeEnum.RESOURCE_NOT_FOUND)`** — target row not found.
- **`BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors)`** — invalid input. Build field-level `InvalidRequestExceptionRecord`s (field name + value + message) so the client gets per-field detail; see the `invalidBody(...)` helper in `{referenceServiceImpl}`.
- **`ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION)`** — optimistic-lock failure / unique violation (see below).

### Optimistic locking & audit

- Business rows carry an `exclusioncheck` timestamp. On update, pass the expected `exclusioncheck` and **compare the mapper's affected-row count to the number you intended to update**; if they differ, throw `ConflictException(SQL_UNIQUE_VIOLATION)` — another writer changed the row.
- Set audit columns (`updusercd` / `updusername` / `updterminalcd`, and `add*` on insert) from the resolved actor. Resolve the current user/audit context via `RequestContextHolder.getContext()` (`com.fw.grpc.core.dto`), falling back to the request's `userId` / `"SYSTEM"`.
- Build/patch entities with the Lombok builder; when patching, preserve fields the request didn't change rather than overwriting them with null.

---

## Variant `ingest-no-transaction`

Services in the `service/` layer batch-persist already-deserialized entity lists into the
database using PostgreSQL `UNNEST`. They are invoked by callers (e.g. a Kafka consumer)
with entities already extracted — the service only orchestrates persistence.

### Persistence pattern

- **Chunk** large input (chunk size is a tunable constant) and call the mapper's
  `batchUpsert…Unnest(params)` once per chunk, where `params` holds one typed array per
  column (built by a params builder).
- Write to **independent tables in parallel** via `CompletableFuture.runAsync(..., executor)`
  using an injected managed `Executor` (e.g. Spring's `applicationTaskExecutor`), then
  `CompletableFuture.allOf(...).join()`.
- Skip a table when its entity list is empty.

### No transaction by design

- **Do not add `@Transactional`.** Each chunk auto-commits independently; correctness comes
  from **idempotent upserts in the persistence layer**, not from a wrapping transaction — so
  re-processing the same input is safe.
- Because there is no transaction, don't introduce cross-table invariants that would require
  atomicity here — keep each table's upsert independent.

### General

- Annotate with `@Service`; inject mappers and the executor as constructor dependencies.
- Keep payload extraction/mapping out of the service (do it in the caller or the params
  builder); the service only orchestrates chunking, parallelism, and mapper calls.
- Log per-chunk counts (chunk size, rows inserted) at debug level for throughput visibility.

---

## Variant `gateway-no-db`

`service/` holds the **orchestration services**. **This service has no database** — an orchestration service reaches `{targetMicroservice}` through gRPC client(s) and shapes the result; it never runs SQL, transactions, or optimistic locking.

### Shape

- An orchestration service is an **interface + `*Impl`** pair; the impl is `@Service` + `@RequiredArgsConstructor` with `private final` dependencies — its `{targetMicroservice}` gRPC client(s), and a mapper only if it shapes the response itself.
- A service method typically: validates input → calls the downstream client(s) → maps/aggregates the result → returns this service's message. Thin pass-through is normal and fine.
- **No `@Transactional`** (no datasource). Don't introduce JDBC/MyBatis here — all data, reads and writes, goes through the gRPC client.

### Errors

- Signal failures by throwing a typed exception from `com.fw.core.exception.*` (with an `ErrorCodeEnum`) — e.g. `ForbiddenException` / `BadRequestException` / `NotFoundException` — rather than returning null or status flags. Don't catch a downstream gRPC error just to swallow it; let it surface to the central gRPC `Status` mapping.

---

## Variant `search-ingest`

> Where a repository also queries an external analytics store, the orchestration and identifier validation that this requires are not part of these rules.

Services in `service/core/<domain>` hold the business logic. A gRPC impl or the Kafka consumer delegates here; the service orchestrates MyBatis mappers (PostgreSQL) and MapStruct mappings (row/entity ↔ gRPC), and returns the result.

### Shape

- **Search services** split **interface + `*Impl`**; the impl is `@Service` + `@RequiredArgsConstructor` (deps as `private final`).
- **Ingest services** may be concrete `@Service` classes (no interface). Match the neighbouring style in the domain rather than forcing an interface.
- A method may take/return gRPC message types directly, or work with entities + a MapStruct mapping for the response — follow the pattern of nearby services.

### Transactions

- Annotate every method that **writes to PostgreSQL** (insert/update) with `@Transactional` (`org.springframework.transaction.annotation.Transactional`). Read-only queries don't need it.
- There is **no `exclusioncheck` optimistic-locking** in this service; don't add it unless the design calls for it.

### Input validation & safety

- Normalize paging with sensible defaults when missing (`page = 1`, `size = 10`).
- Truncate/clean inbound string fields to their column lengths before persisting.

### Audit & request context

- Resolve the actor/company from `RequestContextHolder.getContext()` (`com.fw.grpc.core.dto`) when present, falling back to a sensible default (e.g. company `"01"` for search, `"SYSTEM"` user for ingest). Set `add*` audit fields from the resolved actor.

### Error handling

- Throw the typed `com.fw.core.exception.*` exceptions (`BadRequestException` / `ForbiddenException` / `NotFoundException`): the global advice maps each to its gRPC `Status` and carries the error code and field-level records to the caller (see [grpc-server.md](grpc-server.md)). Existing code sometimes throws `IllegalArgumentException` for a validation problem and lets the gRPC impl convert it — don't extend that pattern in new code, because the advice reports an unmapped exception as `INTERNAL`.
