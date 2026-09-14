# Shared framework — what this service reuses ({repo})

The shared types below come from the **`com.scm.core.*` jar (scm-be-core)** and the gRPC
audit jar — **import and reuse them; never write your own equivalent**. This lists only what
**this service** uses (not the whole framework). It records _what exists to reuse_ — if a
signature looks off, confirm it against the dependency **jar on your classpath** (IDE
go-to-definition), not a frozen spec. This file is self-contained: it does not point to any
other repository.

## Domain exceptions — `com.scm.core.exception.*`

Throw these (never return null / error flags); a central advice maps them to gRPC `Status`,
so **don't catch-and-swallow**. All take a `BaseErrorCodeEnum` (use `ErrorCodeEnum`).

| Exception             | Use when                             | Constructors                                                                                                                                                                                  |
| --------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ForbiddenException`  | caller lacks permission / no scope   | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `NotFoundException`   | target row not found                 | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `ConflictException`   | optimistic-lock / unique violation   | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `BadRequestException` | invalid input (optionally per-field) | `(errorCode)`, `(errorCode, String... args)`, `(errorCode, Throwable)`, `(errorCode, List<BaseInvalidRequestExceptionRecord> errors)`, `(errorCode, BaseInvalidRequestExceptionRecord error)` |
| `ServiceUnavailableException` | downstream/dependency unavailable | `(errorCode)`, `(errorCode, Throwable, int retryAfterSeconds)`, `(errorCode, Object... args)` |

```java
throw new NotFoundException(ErrorCodeEnum.RESOURCE_NOT_FOUND);

throw new ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION); // affected-row mismatch on update
```

## Error codes — `com.scm.core.constant.ErrorCodeEnum`

The platform error-code enum (`EB-…` codes). Pass a constant to an exception / record;
**don't invent string codes**. Constants this service commonly uses: `RESOURCE_NOT_FOUND`,
`REQUEST_NOT_PERMITTED`, `REQUEST_BODY_INVALID`, `SQL_UNIQUE_VIOLATION`, `FIELD_INVALID`,
`INTERNAL_SERVER_ERROR`. (See `ErrorCodeEnum` for the full set — pick an existing one.)

## Per-field error record — `com.scm.core.shape.InvalidRequestExceptionRecord`

For field-level `BadRequestException` detail (client gets which field failed). Implements
`BaseInvalidRequestExceptionRecord`.

| Constructor                                                                                  | Fields                                               |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `(errorCode, errorMessage, errorField, errorFieldValue, Map<String,String> errorParameters)` | full                                                 |
| `(errorCode, errorMessage, errorField, errorFieldValue)`                                     | no params                                            |
| `(errorField, errorMessage, errorFieldValue)`                                                | defaults `errorCode` = `ErrorCodeEnum.FIELD_INVALID` |

```java
var errors = List.<BaseInvalidRequestExceptionRecord>of(
  new InvalidRequestExceptionRecord(ErrorCodeEnum.REQUEST_BODY_INVALID, msg, field, value, Map.of("fieldName", field))
);

throw new BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors);
```

## List response — `com.scm.core.dto.ListResponse<T>` + `ListResponseMetadata`

The standard paged-list wrapper returned to the gRPC/MapStruct layer. **Don't define your own
list-result class.**

- `ListResponse<T>`: fields `data` (`List<T>`), `metadata` (`ListResponseMetadata`).
  Factories: `ListResponse.of(List<T> data, int total)` · `ListResponse.of(List<T> data, ListResponseMetadata metadata)`.
- `ListResponseMetadata`: fields `total` (long), `page` (int), `size` (int). Factories:
  `ListResponseMetadata.of(int total)` · `of(int total, int page, int size)`.

```java
ListResponse<{Feature}Entity> response = ListResponse.of(results, results.size());
// paged: new ListResponse<>(rows, ListResponseMetadata.of((int) totalCount, page, size));
```

## Caller / audit context — `com.scm.core.dto.RequestContext` + `RequestContextHolder`

Resolve the current actor for audit / permission. **`RequestContextHolder` is in the gRPC
audit jar `com.scm.grpc.core.dto`** (not `com.scm.core`); it returns a
`com.scm.core.dto.RequestContext`.

- `RequestContextHolder.getContext()` → `RequestContext` (may be `null`).
- `RequestContext.getUser()` → `SecurityUserDto` (may be `null`); `getAttribute(name)`.
- `SecurityUserDto`: `getUsercd()`, `getUsername()`, `getCompanyCode()` (first of `companycd`), `getEmail()`, `getAuthorities()`.

```java
RequestContext ctx = RequestContextHolder.getContext();

String userCd = ctx != null && ctx.getUser() != null ? ctx.getUser().getUsercd() : null;
// fall back to the request's userId / "SYSTEM" when absent (see the service-layer template)
```

## Event / process-log constants — `com.scm.core.constant.*` + `com.scm.core.message.*`

When a feature emits events or writes a process log, reuse the shared constants
(`LogLevel`, `LogProcessKbn`, `ServiceKbn`, `ProcessResult`, `CoreEventTopic`, …) and the
message types (`com.scm.core.message.*`) — drive them through the **in-repo** helpers
(`helper/{processLogHelper}`, `infrastructure/message/{eventPublisher}`), don't hand-roll
new topics/constants.

---

**Rule of thumb:** before writing a new exception, error code, list wrapper, or audit/user
type — check here first; the shared one almost always exists. External jars
(`com.scm.core.*`, `com.fw.grpc.*`) are never stubbed.
