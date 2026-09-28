# cm-be-ms-log layer rules (service-specific)

Service-specific parts of this repository's layer rules. The generic rules are in `cm-be-ms-common:scaffold-ms-feature` → `references/service-layer.md`, `references/grpc-server.md`, `references/mybatis-mapper.md`.

# Service-layer rules

Applies to: `**/service/**/*.java`

Services in `service/core/<domain>` hold the business logic. A gRPC impl or the Kafka consumer delegates here; the service orchestrates MyBatis mappers (PostgreSQL), the Athena client (S3-backed log data), and MapStruct mappings (row/entity ↔ gRPC), and returns the result.

## Shape

- **Search services** split **interface + `*Impl`**; the impl is `@Service` + `@RequiredArgsConstructor` (deps as `private final`).
- **Ingest services** may be concrete `@Service` classes (no interface). Match the neighbouring style in the domain rather than forcing an interface.

## Transactions

- Annotate every method that **writes to PostgreSQL** (insert/update) with `@Transactional` (`org.springframework.transaction.annotation.Transactional`). Read-only queries and Athena reads don't need it.
- There is **no `exclusioncheck` optimistic-locking** in this service; don't add it unless the design calls for it.

## Input validation & safety

- **Validate identifiers before querying.** Table names interpolated into Athena SQL must pass a strict allow-pattern (e.g. `[a-zA-Z0-9_]+`); throw `IllegalArgumentException` on a bad name **before** issuing the Athena query — the Athena client interpolates identifiers as strings (see [athena-client.md](../../write-athena-clients/references/athena-client.md)).
- Normalize paging with sensible defaults when missing (`page = 1`, `size = 10`).

## Audit & request context

- Resolve the actor/company from `RequestContextHolder.getContext()` (`com.fw.grpc.core.dto`) when present, falling back to a sensible default (e.g. company `"01"` for search, `"SYSTEM"` user for ingest). Set `add*` audit fields from the resolved actor.

## Error handling

- For request/validation problems prefer `IllegalArgumentException` (the gRPC layer maps it to `INVALID_ARGUMENT`). The typed `com.fw.core.exception.*` (`BadRequestException` / `ForbiddenException` / `NotFoundException`) are also available and declared on some search methods — use them where the design specifies, but be aware there is no confirmed central advice (see the gRPC-server rules below).

# gRPC server-layer rules

Applies to: `**/grpc/**/*.java`

## Error handling

The gRPC server starter auto-registers the framework's global advice (`GrpcGlobalExceptionHandler`), which maps the typed `com.fw.core.exception.*` family to a gRPC `Status` and attaches the error-code and field-record trailers. Anything outside that family reaches the caller as `INTERNAL`.

- **Throw the typed exceptions** — `BadRequestException`, `ForbiddenException`, `NotFoundException` — and let the advice map them. Don't convert them by hand in the gRPC impl.
- Some existing impls here catch `IllegalArgumentException` and respond `Status.INVALID_ARGUMENT.withDescription(e.getMessage()).asRuntimeException()`, because the advice would otherwise report it as `INTERNAL`. Keep that catch when you touch such a method, but for new validation failures throw `BadRequestException` instead.
- Do not swallow exceptions silently; always complete the observer via `onCompleted()` or `onError(...)`.

# MyBatis mapper XML rules

Applies to: `**/mybatis/**/*.xml`

MyBatis mapper XML lives in `src/main/resources/mybatis/mapper/core/<domain>/<Name>Mapper.xml` and is paired with a `@Mapper` interface at `com.cm.ms.log.persistence.mapper.core.<domain>.<Name>Mapper`. Loaded via `mybatis.mapper-locations=classpath*:mybatis/**/*.xml`. These queries hit **PostgreSQL** (DB `Log`, schema `CM`) — the Athena path is separate.

- Writes that touch log tables set the audit columns (`addusercd` / `addusername` / `addterminalcd`, and `adddatetime` via `CURRENT_TIMESTAMP`).
