# MS feature — initial creation

This scaffolds a **microservice-side feature**: a gRPC endpoint backed by business
logic, MyBatis/PostgreSQL persistence, and MapStruct mapping. Templates below are the
skeletons; the per-line rules live in `../references/*.md` — this guide tells you **which files to create and in
what order**, the references tell you **how each line must look**.

**Prerequisite:** the OpenAPI spec is generated and built, so the gRPC stubs/messages
(`com.fw.grpc.*`) and shared DTOs/exceptions (`com.scm.core.*`) already exist as
internal jars. If a `*ServiceImplBase` or message type for this feature is missing, the
spec hasn't been built — stop and report it; never stub these classes.

> **Out of scope:** tests; `com.fw.grpc.*` / `com.scm.core.*` classes (external internal
> jars — never stub); `target/` (generated). **Root package:** `{basePackage}`.

**Reuse the shared framework — don't reinvent:** before writing an exception, error code,
list wrapper, or audit/user type, check **`../../framework-guide/references/fw-reuse-microservice.md`** — the `com.scm.core.*` type
almost always exists (e.g. `NotFoundException` + `ErrorCodeEnum`, `ListResponse`,
`RequestContextHolder`). Import and reuse it.

## Inputs to collect first

Ask; mark anything unknown as "needs confirmation / 要確認" (don't invent):

1. **Function ID & name (機能ID・機能名)** + classification (大分類 / 中分類 / 小分類) → drives class names and package (see _Naming_ below).
2. **gRPC service + method**: the generated `*ServiceImplBase` and the RPC(s) to implement, plus the request/response message types.
3. **Read or write**: a query, a write path (insert/update/delete, optimistic lock, audit, event), or both.
4. **Data & SQL**: target PostgreSQL table(s) and the query/statement **from the design** (kept faithful — see `../references/mybatis-mapper.md`).
5. **Permission scope**: which owner/warehouse/company filter the caller is restricted to (if any).
6. **Events**: does the design emit a Kafka domain event after a write?

## Naming — derive everything from the classification

The design document classifies a feature by 大分類 / 中分類 / 小分類 / 機能名. Map each
to its code, then assemble the tags. **This service is `{middleCategory}` (中分類) under the `Web`
or `Mobile` 大分類**; the generated stubs carry the full tag, the impl classes drop the
大分類 prefix.

### 大分類 (drives the generated stub prefix only)

| 設計書 大分類     | Pascal   | lc       |
| ----------------- | -------- | -------- |
| Web               | `Web`    | `web`    |
| モバイル / Mobile | `Mobile` | `mobile` |
| API               | `Api`    | `api`    |

### 中分類

| 設計書 中分類  | コード    | Pascal   | lc       |
| -------------- | --------- | -------- | -------- |
| コア機能       | `001`     | `Core`   | `core`   |
| オプション機能 | `002`     | `Option` | `option` |
| ローカル機能   | `100~999` | `Local`  | `local`  |

### 小分類 (→ `<domain>` package segment)

| 設計書 小分類 | コード | Pascal   | lc (`<domain>`) |
| ------------- | ------ | -------- | --------------- |
| 共通          | `010`  | `Common` | `common`        |
| マスタ        | `020`  | `Master` | `master`        |
| 入荷          | `030`  | `Rcv`    | `rcv`           |
| 出荷          | `040`  | `So`     | `so`            |
| オーダー管理  | `050`  | `Order`  | `order`         |
| 在庫          | `060`  | `Inv`    | `inv`           |
| 棚卸          | `090`  | `Stks`   | `stks`          |

> Only the 小分類 that exist as domains in this repo are listed; for a new domain, use
> the design's English sub-category in lowerCamel as `<domain>` and PascalCase in tags.

### Assembled names

| Variable         | Rule                                                                                 | Example (中=Core, 小=So, 機能=SoMainte) |
| ---------------- | ------------------------------------------------------------------------------------ | --------------------------------------- |
| `<domain>`       | 小分類 lc                                                                            | `so`                                    |
| `[TagMs]`        | `[中分類Pascal][小分類Pascal][機能名Pascal]` — **impl-side classes**                 | `CoreSoSoMainte`                        |
| `[TagFull]`      | `[大分類Pascal][TagMs]` — **generated stub/base only** (external)                    | `WebCoreSoSoMainte`                     |
| `[operationId]`  | `[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]` — the RPC method | `webCoreSoSoMainteGetSo`                |
| `[機能名Pascal]` | 機能名 PascalCase — mapper / entity base                                             | `SoMainte`                              |

Resulting class names: `[TagMs]Grpc` (extends generated `[TagFull]ServiceImplBase`),
`[TagMs]Service` / `…ServiceImpl`, `[TagMs]ServiceMapping`, `[機能名Pascal]Mapper`
(+ `.xml`), `[Name]Entity`.

## File / directory map (this repo only)

```
src/main/java/{basePackagePath}/
├─ grpc/core/<domain>/[TagMs]Grpc.java                         ← ⑥ gRPC impl
├─ service/core/<domain>/
│  ├─ [TagMs]Service.java                                      ← ⑤ interface
│  └─ [TagMs]ServiceImpl.java                                  ← ⑤ impl
├─ infrastructure/mapping/core/<domain>/[TagMs]ServiceMapping.java   ← ④ MapStruct
├─ persistence/
│  ├─ mapper/core/<domain>/[機能名Pascal]Mapper.java           ← ② MyBatis interface
│  └─ model/core/<domain>/
│     ├─ [Name]Entity.java                                     ← ① entity (extends BaseEntity)
│     └─ [機能名Pascal][API名]Request.java / …Result.java       ← ① query/result models
└─ infrastructure/message/                                     ← ⑦ Kafka event (only if the design emits one)

src/main/resources/
└─ mybatis/mapper/core/<domain>/[機能名Pascal]Mapper.xml        ← ③ MyBatis SQL
```

## Data flow

```
gRPC impl (@GrpcService, delegate-only)
  → Service (@Transactional on writes; typed com.scm.core.exception.*; optimistic lock; audit)
      → MyBatis @Mapper + Mapper.xml      (PostgreSQL — explicit column mapping)
      → MapStruct [TagMs]ServiceMapping    (entity ↔ gRPC message)
      → Kafka publish (after commit, only if the design emits events)
```

## Generation order

Build inside-out so each layer compiles against the one below:

1. ① Entity + request/result models
2. ② MyBatis mapper interface
3. ③ MyBatis mapper XML (SQL from the design — kept faithful)
4. ④ MapStruct `[TagMs]ServiceMapping`
5. ⑤ Service interface + `*Impl`
6. ⑥ gRPC impl
7. ⑦ Kafka event publisher/record (only if the design emits events)

---

## Templates

### ① Entity + models — `persistence/model/core/<domain>/`

Business-table entities extend `BaseEntity` (inherits audit `adddatetime/addusercd/
addusername/addterminalcd` + `upd*`). Declare `exclusioncheck` on the entity itself for
optimistically-locked business rows. Use plain Lombok POJOs for non-entity query/result
shapes.

```java
package {basePackage}.persistence.model.core.[domain];

@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class [Name]Entity extends BaseEntity {

    // Columns from the design (only fields defined in the design — don't invent).
    private String companyCd;
    private Long soNo;
    // ...

    /** Optimistic-lock timestamp (business rows only). */
    private LocalDateTime exclusioncheck;
}
```

```java
// Query params / result rows that are NOT entities (no audit, no BaseEntity):
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class [機能名Pascal][API名]Request {
    private String companyCd;
    private Long soNo;
    // ... design input parameters
}
```

### ② MyBatis mapper interface — `persistence/mapper/core/<domain>/[機能名Pascal]Mapper.java`

```java
package {basePackage}.persistence.mapper.core.[domain];

@Mapper
public interface [機能名Pascal]Mapper {

    // Reads return entities / result models:
    List<[Name]Entity> select[機能名Pascal]([機能名Pascal]Request request);

    // Writes return the affected-row count (the service checks it for optimistic lock):
    int insert[機能名Pascal]([Name]Entity entity);
    int update[機能名Pascal]([Name]Entity entity);
    int delete[機能名Pascal]([機能名Pascal]Request request);
}
```

### ③ MyBatis mapper XML — `mybatis/mapper/core/<domain>/[機能名Pascal]Mapper.xml`

Apply `../references/mybatis-mapper.md`. Key rules: `namespace` = the mapper
interface FQN (exact); **auto camel-case is OFF** → map every column explicitly via
`<resultMap>` or column aliases; keep the design's SQL faithful (JOINs / subqueries /
`COALESCE` / PostgreSQL casts — don't simplify); inline comments use `/* … */`; writes
set audit columns and respect `exclusioncheck`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{basePackage}.persistence.mapper.core.[domain].[機能名Pascal]Mapper">

  <resultMap id="[機能名Pascal]Result"
             type="{basePackage}.persistence.model.core.[domain].[Name]Entity">
    <result property="companyCd"     column="companycd"/>   <!-- camel-case is OFF: map each column -->
    <result property="soNo"          column="sono"/>
    <result property="exclusioncheck" column="exclusioncheck"/>
    <!-- ... one <result> per property -->
  </resultMap>

  <select id="select[機能名Pascal]"
          parameterType="{basePackage}.persistence.model.core.[domain].[機能名Pascal]Request"
          resultMap="[機能名Pascal]Result">
    /* Reproduce the design's SELECT as-is — keep JOINs/COALESCE/casts. */
    SELECT ...
    FROM   ...
    WHERE  companycd = #{companyCd}
  </select>

  <update id="update[機能名Pascal]"
          parameterType="{basePackage}.persistence.model.core.[domain].[Name]Entity">
    UPDATE {table} SET
      ...,
      updusercd     = #{updusercd},
      updusername   = #{updusername},
      updterminalcd = #{updterminalcd},
      upddatetime   = CURRENT_TIMESTAMP
    WHERE companycd      = #{companyCd}
      AND sono           = #{soNo}
      AND exclusioncheck = #{exclusioncheck}   /* optimistic lock: 0 rows ⇒ conflict */
  </update>

</mapper>
```

### ④ MapStruct mapping — `infrastructure/mapping/core/<domain>/[TagMs]ServiceMapping.java`

Apply `../references/mapstruct-mapping.md`. Standard header; extend
`BaseMapping` **only** if you reuse one of its conversions; `@Mapping` for renamed fields;
map `repeated` to the logical name (not `…List`); `@Named` + `qualifiedByName` for value
transforms (e.g. formatting `exclusioncheck`).

```java
package {basePackage}.infrastructure.mapping.core.[domain];

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [TagMs]ServiceMapping {

    @Mapping(target = "details", source = "soDetails")   // repeated → logical name
    Grpc[TagFull][API名]Response to[API名]Response(List<[Name]Entity> entities);
}
```

### ⑤ Service — `service/core/<domain>/[TagMs]Service.java` + `…ServiceImpl.java`

Apply `../references/service-layer.md`. Interface + `@Service` impl
(`@RequiredArgsConstructor`, deps `private final`). Throw typed
`com.scm.core.exception.*` with `ErrorCodeEnum` — never null/flags. **Writes:**
`@Transactional`; resolve audit via `RequestContextHolder.getContext()`; on update compare
the affected-row count and throw `ConflictException(SQL_UNIQUE_VIOLATION)` on mismatch;
publish Kafka events **after** persistence succeeds. Enforce the caller's permission scope.

Service methods take/return the gRPC message types directly. Typed exceptions and the
audit context come from the external `com.scm.core.*` / `com.scm.grpc.core.dto` jars
(never stub):

```java
import com.scm.core.constant.ErrorCodeEnum;
import com.scm.core.dto.RequestContext;
import com.scm.core.exception.BadRequestException; // + ConflictException / ForbiddenException / NotFoundException
import com.scm.core.shape.BaseInvalidRequestExceptionRecord;
import com.scm.core.shape.InvalidRequestExceptionRecord;
import com.scm.grpc.core.dto.RequestContextHolder;
```

```java
public interface [TagMs]Service {
    Grpc[TagFull][API名]Response [API名lc](Grpc[TagFull][API名]Request request);          // read
    com.google.protobuf.Empty [writeApiLc](Grpc[TagFull][WriteApi]Request request);       // write (Empty when the RPC returns no payload)
}
```

```java
package {basePackage}.service.core.[domain];

@Service
@RequiredArgsConstructor
public class [TagMs]ServiceImpl implements [TagMs]Service {

    private final [機能名Pascal]Mapper [機能名lc]Mapper;
    private final [TagMs]ServiceMapping [tagMsLc]ServiceMapping;
    private final {permissionMapper} userPermissionMapper;
    // private final {eventPublisher} [tagMsLc]EventPublisher;  // only if the design emits events

    // ---- read ----
    @Override
    public Grpc[TagFull][API名]Response [API名lc](Grpc[TagFull][API名]Request request) {
        String userId = request.getUserid();
        List<{permissionScope}> scopes = resolvePermissionScopes(userId);   // no scope → ForbiddenException
        List<[Name]Entity> rows = [機能名lc]Mapper.select[機能名Pascal](/* query built from request + scopes */);
        return [tagMsLc]ServiceMapping.to[API名]Response(rows);
    }

    // ---- write ----
    @Override
    @Transactional
    public com.google.protobuf.Empty [writeApiLc](Grpc[TagFull][WriteApi]Request request) {
        String userId = request.getUserid();
        if (!StringUtils.hasText(userId)) {
            throw new ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED);
        }
        AuditInfo audit = resolveAuditInfo(userId);

        [Name]Entity entity = [Name]Entity.builder()
            // ... design fields
            .exclusioncheck(/* parsed expected lock value from request */)
            .updusercd(audit.userCd())
            .updusername(audit.userName())
            .updterminalcd(audit.terminalCd())
            .build();

        int affected = [機能名lc]Mapper.update[機能名Pascal](entity);
        if (affected != 1) {                                  // optimistic-lock check
            throw new ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION);
        }
        // [tagMsLc]EventPublisher.publishUpsert(entity.getXxx());   // after persistence, inside the tx

        return com.google.protobuf.Empty.getDefaultInstance();   // write RPC returns Empty
    }

    // Resolve audit actor: prefer the request userId, enrich from RequestContext, fall back to "SYSTEM".
    private AuditInfo resolveAuditInfo(String requestedUserId) {
        RequestContext context = RequestContextHolder.getContext();
        String userCd = StringUtils.hasText(requestedUserId) ? requestedUserId : "SYSTEM";
        String userName = userCd;
        if (context != null && context.getUser() != null) {
            if (!StringUtils.hasText(requestedUserId) && StringUtils.hasText(context.getUser().getUsercd())) {
                userCd = context.getUser().getUsercd();
            }
            String raw = StringUtils.hasText(requestedUserId) ? requestedUserId : context.getUser().getUsername();
            if (StringUtils.hasText(raw)) {
                userName = raw.length() > 30 ? raw.substring(0, 30) : raw;   // column length guard
            }
        }
        return new AuditInfo(userCd, userName, "");
    }

    private List<{permissionScope}> resolvePermissionScopes(String userId) {
        if (!StringUtils.hasText(userId)) {
            throw new ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED);
        }
        List<{permissionScope}> scopes = userPermissionMapper.findByUserId(userId);
        if (scopes == null || scopes.isEmpty()) {
            throw new ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED);
        }
        return scopes;
    }

    // Per-field invalid-input error (gives the client field-level detail):
    private BadRequestException invalidBody(String message, String fieldName, Object fieldValue) {
        List<BaseInvalidRequestExceptionRecord> errors = List.of(new InvalidRequestExceptionRecord(
            ErrorCodeEnum.REQUEST_BODY_INVALID, message, fieldName, fieldValue,
            StringUtils.hasText(fieldName) ? Map.of("fieldName", fieldName) : Map.of()));
        return new BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors);
    }

    private record AuditInfo(String userCd, String userName, String terminalCd) {}
}
```

Typed exceptions to use (from `com.scm.core.exception.*` + `ErrorCodeEnum`):
`ForbiddenException(REQUEST_NOT_PERMITTED)`, `NotFoundException(RESOURCE_NOT_FOUND)`,
`BadRequestException(REQUEST_BODY_INVALID, errors)` (via `invalidBody`),
`ConflictException(SQL_UNIQUE_VIOLATION)`.

### ⑥ gRPC impl — `grpc/core/<domain>/[TagMs]Grpc.java`

`@GrpcService` + `@RequiredArgsConstructor`, `extends [TagFull]ServiceImplBase`. **Delegate
only — no business logic.** End with `onNext(...)` then `onCompleted()`. Don't catch
domain exceptions (a central advice maps them to gRPC `Status`).

```java
package {basePackage}.grpc.core.[domain];

@GrpcService
@RequiredArgsConstructor
public class [TagMs]Grpc extends [TagFull]ServiceImplBase {

    private final [TagMs]Service [tagMsLc]Service;

    @Override
    public void [operationId](
            Grpc[TagFull][API名]Request request,
            StreamObserver<Grpc[TagFull][API名]Response> responseObserver) {
        responseObserver.onNext([tagMsLc]Service.[API名lc](request));
        responseObserver.onCompleted();
    }

    // write RPC returning Empty:
    @Override
    public void [operationId](
            Grpc[TagFull][API名]Request request,
            StreamObserver<com.google.protobuf.Empty> responseObserver) {
        [tagMsLc]Service.[API名lc](request);
        responseObserver.onNext(com.google.protobuf.Empty.getDefaultInstance());
        responseObserver.onCompleted();
    }
}
```

### ⑦ Kafka event (only if the design emits one)

Add/extend a publisher under `infrastructure/message` (pattern: `{eventPublisher}`)
plus an event record under `infrastructure/message/event`; publish from the service
**after** the write succeeds, inside the transactional method.

---

## Type mapping (design → Java)

| 設計書の型                              | Java                   | Note                 |
| --------------------------------------- | ---------------------- | -------------------- |
| String                                  | `String`               |                      |
| Long                                    | `Long`                 |                      |
| Integer                                 | `Integer`              |                      |
| BigDecimal                              | `java.math.BigDecimal` |                      |
| 日付 (YYYYMMDD) / 日時 (YYYYMMDDHHmmss) | `String`               | no format conversion |
| Array<X>                                | `List<X>`              |                      |

Column → property: DB columns are lowercase (e.g. `companycd`, `sono`); auto camel-case is
OFF, so map each one explicitly in the `<resultMap>` (or alias in SQL).

## Completion checklist

1. gRPC impl: `@GrpcService`, extends `[TagFull]ServiceImplBase`, delegates only, `onNext` + `onCompleted`, no exception catching.
2. Service: typed `com.scm.core.exception.*` + `ErrorCodeEnum`; `@Transactional` on writes; optimistic-lock (affected-row check → `ConflictException`); audit from `RequestContextHolder`; permission scope enforced; events published after persistence.
3. MyBatis: `namespace` = interface FQN; explicit column mapping (camel-case OFF); faithful PostgreSQL SQL; `/* */` comments; writes set audit + respect `exclusioncheck`.
4. Entity extends `BaseEntity` (+ `exclusioncheck` for locked rows); query/result models are plain Lombok.
5. MapStruct: standard header (+ `BaseMapping` only if its conversions are reused); renamed fields + `repeated` + custom conversions mapped.
6. (Events) published after the write, inside the transaction.
7. No tests; no stubbed `com.fw.grpc.*` / `com.scm.core.*`; no edits to `target/`.
