# Event-ingest feature — initial creation

This scaffolds an **event-ingest feature**: consume a Kafka event and batch-upsert it into
PostgreSQL via `UNNEST`. This service has exactly one shape — **Kafka consumer → chunked
parallel UNNEST upsert** — there is **no gRPC and no MapStruct** here. Templates below are
skeletons; the per-line rules live in `../references/*.md`.

> **Out of scope:** gRPC services/clients; MapStruct; `@Transactional` (idempotent via
> `ON CONFLICT`); `com.fw.grpc.*` / `com.scm.core.*` / `cm-be-spec` classes (external jars —
> never stub); `target/`; **tests**. **Root package:** `{basePackage}`.

## Inputs to collect first

Ask; mark anything unknown as "needs confirmation / 要確認" (don't invent):

1. **Function ID & name (機能ID・機能名)**.
2. **Kafka topic** + the flat JSON payload shape (the consumer converts one message into one
   or more entity types).
3. **Target table(s)** + **primary key** (for `ON CONFLICT`) + the full column list.
4. **Entity field ↔ column** mapping (auto camel-case is OFF — names must line up).
5. Does one message feed **more than one table** (e.g. a ledger row + a history row)?

## Naming

Shared design-classification naming; this service's layers are flat:

| Layer | Pattern | Example |
|---|---|---|
| Entity | `[Name]Entity` | `{Domain}Entity` |
| Mapper interface | `[Name]Mapper` | `{Domain}Mapper` |
| Mapper SQL XML | `mybatis/mapper/[Name]Mapper.xml` (namespace = interface FQN) | `{Domain}Mapper.xml` |
| ResultMap XML (reads only) | `mybatis/mapping/[Name]Mapping.xml` | `{Domain}Mapping.xml` |
| Params builder | one `build[Name]Params(...)` per table in `UnnestParamsBuilder` | `build{Domain}Params` |
| Service | `Core[Feature]Service` + `…Impl` | `Core{Domain}MovementHistoryService` |
| Consumer | `[Feature]Consumer` | `CoreInvMovementHistoryConsumer` |

Domain package segment is `{domain}` (`…core.{domain}`).

## File / directory map (this repo only)

```
src/main/java/{basePackagePath}/
├─ infrastructure/message/consumer/[Feature]Consumer.java        ← ⑦ Kafka batch consumer
├─ service/core/{domain}/
│  ├─ Core[Feature]Service.java                                  ← ⑥ interface
│  └─ Core[Feature]ServiceImpl.java                              ← ⑥ impl (chunk + parallel, NO @Transactional)
├─ persistence/
│  ├─ mapper/core/{domain}/
│  │  ├─ [Name]Mapper.java                                       ← ② mapper interface
│  │  └─ UnnestParamsBuilder.java                                ← ④ extend with build[Name]Params
│  └─ model/core/{domain}/[Name]Entity.java                         ← ① entity (plain @Data, no BaseEntity)
├─ configuration/PostgresArrayTypeHandler.java                   ← (extend only if a new array element type appears)
└─ dto/                                                          ← (optional typed payload)

src/main/resources/mybatis/
├─ mapper/[Name]Mapper.xml                                       ← ③ UNNEST upsert SQL
└─ mapping/[Name]Mapping.xml                                     ← (resultMap — only if the feature also reads rows back)
```

## Data flow

```
Kafka topic → @KafkaListener batch consumer (manual ack)
  → normalize payload (String/byte[] → readTree; Map → pass through)
  → objectMapper.convertValue(normalized, [Name]Entity.class) → guard PK fields
  → service.batchUpsert(...)  → chunk + parallel per table (applicationTaskExecutor)
  → mapper.batchUpsert[Name]Unnest(params)
  → INSERT … SELECT … FROM unnest(<one array per column>) … ON CONFLICT (<pk>) DO NOTHING
```

## Generation order

1. ① Entity
2. ② Mapper interface
3. ③ Mapper XML (UNNEST upsert)
4. ④ `UnnestParamsBuilder` — add `build[Name]Params`
5. ⑤ `PostgresArrayTypeHandler` — only if a new array element type is introduced
6. ⑥ Service interface + `*Impl`
7. ⑦ Kafka consumer

---

## Templates

### ① Entity — `persistence/model/core/{domain}/[Name]Entity.java`

Plain Lombok POJO with **all** columns (audit `add*`/`upd*`, `exclusioncheck` inline — this
service does **not** use `BaseEntity`). `@JsonIgnoreProperties(ignoreUnknown = true)` so a
flat Kafka payload with extra fields converts cleanly. Field names map to DB columns (auto
camel-case is OFF — keep them aligned).

```java
package {basePackage}.persistence.model.core.{domain};

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class [Name]Entity {

    private String companycd;     // PK part
    private Long [pkColumn];         // PK part
    // ... every column from the design

    private LocalDateTime adddatetime;
    private String addusercd;
    private String addusername;
    private String addterminalcd;
    private LocalDateTime upddatetime;
    private String updusercd;
    private String updusername;
    private String updterminalcd;
    private LocalDateTime exclusioncheck;
}
```

### ② Mapper interface — `persistence/mapper/core/{domain}/[Name]Mapper.java`

```java
package {basePackage}.persistence.mapper.core.{domain};

@Mapper
public interface [Name]Mapper {

    /** UNNEST batch upsert; {@code params} holds one typed array per column. Returns rows inserted. */
    int batchUpsert[Name]Unnest(Map<String, Object> params);
}
```

### ③ Mapper XML — `mybatis/mapper/[Name]Mapper.xml`

Apply `../references/mybatis-mapper.md`. The core write path is a single
`INSERT … SELECT … FROM unnest(<arrays>) … ON CONFLICT (<pk>) DO NOTHING`:

- `namespace` = the mapper interface FQN.
- **One array per column, in the same order** in the `unnest(...)` list, the `AS v(...)`
  column list, and the INSERT column list — a misaligned array silently writes the wrong
  column.
- Bind each array via the project's `PostgresArrayTypeHandler` on the `#{…Arr}` parameter.
- Set `adddatetime` / `upddatetime` to `CURRENT_TIMESTAMP`; the final `exclusioncheck`
  column likewise.
- End with `ON CONFLICT (<pk>) DO NOTHING` — this is what makes re-consumed batches
  idempotent. Inline comments use `/* … */`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{basePackage}.persistence.mapper.core.{domain}.[Name]Mapper">

  <sql id="TableName">t_[name]</sql>

  <insert id="batchUpsert[Name]Unnest" parameterType="map">
    INSERT INTO <include refid="TableName"/> (
      companycd, [pkColumn], /* ...every column..., */ adddatetime, addusercd, /* ... */ exclusioncheck
    )
    SELECT
      v.companycd, v.[pkColumn], /* ...same order..., */ CURRENT_TIMESTAMP, v.addusercd, /* ... */ CURRENT_TIMESTAMP
    FROM unnest(
      #{companycdArr, typeHandler={basePackage}.configuration.PostgresArrayTypeHandler},
      #{[pkColumn]Arr, typeHandler={basePackage}.configuration.PostgresArrayTypeHandler}
      /* ...one #{<col>Arr, typeHandler=…} per column, same order... */
    ) AS v(
      companycd, [pkColumn] /* ...same column names, same order... */
    )
    ON CONFLICT (companycd, [pkColumn]) DO NOTHING
  </insert>

</mapper>
```

### ④ UNNEST params — extend `persistence/mapper/core/{domain}/UnnestParamsBuilder`

Add a `build[Name]Params(List<[Name]Entity> chunk)` returning a `Map<String,Object>` with
**one typed array per column** keyed `<column>Arr`, in the **exact INSERT column order**.
The builder is spec-driven — declare a `ColumnSpec` per column (`key`, getter, component
type); date columns use the SQL-date spec.

```java
private static final ColumnSpec[] [NAME]_SPECS = {
    column("companycdArr", "getCompanycd", String.class),
    column("[pkColumn]Arr",   "get[PkColumn]",   Long.class),
    // ... one spec per column, IN COLUMN ORDER
    sqlDateColumn("[dateColumn]Arr", "get[DateColumn]"),     // LocalDate → java.sql.Date
    column("qtyArr",       "getQty",       BigDecimal.class),
    column("addusercdArr", "getAddusercd", String.class),
    // ...
};

/** Build UNNEST parameter map for t_[name] batch insert. */
public static Map<String, Object> build[Name]Params(List<[Name]Entity> entities) {
    return buildParams(entities, [NAME]_SPECS);
}
```

> The array keys here must match the `#{…Arr}` names in ③ exactly, and the spec order must
> match the INSERT column order — these are the two most common UNNEST bugs.

### ⑤ PostgresArrayTypeHandler — only if a new element type appears

If a column's array element type isn't already handled, add the mapping in
`configuration/PostgresArrayTypeHandler` (PostgreSQL type per Java component type). Most
features reuse the existing types and skip this.

### ⑥ Service — `service/core/{domain}/Core[Feature]Service.java` + `…Impl.java`

Apply `../references/service-layer.md`. `@Service`; inject mappers and the
managed executor; **no `@Transactional`**. Chunk each entity list (tunable `CHUNK_SIZE`),
run independent tables in parallel via `CompletableFuture.runAsync(..., taskExecutor)` then
`allOf(...).join()`; skip an empty list. Keep payload mapping out of the service.

```java
public interface Core[Feature]Service {
    void batchUpsert(List<[Name]Entity> [name]Entities /*, List<OtherEntity> ... */);
}
```

```java
package {basePackage}.service.core.{domain};

@Slf4j
@Service
public class Core[Feature]ServiceImpl implements Core[Feature]Service {

    private static final int CHUNK_SIZE = 2000;   // UNNEST removes the bind-param limit → large chunks

    private final [Name]Mapper [name]Mapper;
    private final Executor taskExecutor;

    public Core[Feature]ServiceImpl(
            [Name]Mapper [name]Mapper,
            @Qualifier("applicationTaskExecutor") Executor taskExecutor) {
        this.[name]Mapper = [name]Mapper;
        this.taskExecutor = taskExecutor;
    }

    @Override
    public void batchUpsert(List<[Name]Entity> [name]Entities) {
        CompletableFuture<?> [name]Future = CompletableFuture.completedFuture(null);
        if (![name]Entities.isEmpty()) {
            [name]Future = CompletableFuture.runAsync(() -> batchUpsert[Name]Unnest([name]Entities), taskExecutor);
        }
        // one future per independent table...
        CompletableFuture.allOf([name]Future /*, ... */).join();
    }

    private void batchUpsert[Name]Unnest(List<[Name]Entity> entities) {
        for (int i = 0; i < entities.size(); i += CHUNK_SIZE) {
            List<[Name]Entity> chunk = entities.subList(i, Math.min(i + CHUNK_SIZE, entities.size()));
            Map<String, Object> params = UnnestParamsBuilder.build[Name]Params(chunk);
            int inserted = [name]Mapper.batchUpsert[Name]Unnest(params);
            log.debug("UNNEST upserted [name] chunk: size={}, inserted={}", chunk.size(), inserted);
        }
    }
}
```

### ⑦ Kafka consumer — `infrastructure/message/consumer/[Feature]Consumer.java`

Apply `../references/kafka-consumer.md`. `@Slf4j @Service
@RequiredArgsConstructor`; batch `@KafkaListener` + manual ack. Empty batch → `acknowledge()`
+ return. Per record: normalize (String/byte[] → `objectMapper.readTree`; Map → pass
through), `convertValue` into the entity type(s), **guard PK fields** (skip when null),
collect, delegate to the service, then `acknowledge()` **after** processing. Wrap per-record
deserialization in try/catch and **log-and-skip** a bad record (topic/partition/offset/key);
never ack before processing.

```java
package {basePackage}.infrastructure.message.consumer;

@Slf4j
@Service
@RequiredArgsConstructor
public class [Feature]Consumer {

    private final ObjectMapper objectMapper;
    private final Core[Feature]Service [feature]Service;

    @KafkaListener(topics = "[topic]", containerFactory = "kafkaListenerContainerFactory")
    public void onBatch(@Payload List<ConsumerRecord<String, Object>> records, Acknowledgment acknowledgment) {
        if (records.isEmpty()) {
            acknowledgment.acknowledge();
            return;
        }
        List<[Name]Entity> [name]Entities = new ArrayList<>(records.size());
        for (ConsumerRecord<String, Object> record : records) {
            try {
                Object normalized = normalizePayload(record.value());
                [Name]Entity entity = objectMapper.convertValue(normalized, [Name]Entity.class);
                if (entity.getCompanycd() != null && entity.get[PkColumn]() != null) {   // guard PK
                    [name]Entities.add(entity);
                }
            } catch (IllegalArgumentException e) {
                log.error("Failed to deserialize record: topic={}, partition={}, offset={}, key={}",
                    record.topic(), record.partition(), record.offset(), record.key(), e);
            }
        }
        if (![name]Entities.isEmpty()) {
            [feature]Service.batchUpsert([name]Entities);
        }
        acknowledgment.acknowledge();
    }

    private Object normalizePayload(Object value) {
        try {
            if (value instanceof String s)  return objectMapper.readTree(s);
            if (value instanceof byte[] b)  return objectMapper.readTree(b);
            return value;
        } catch (Exception e) {
            throw new IllegalArgumentException("Failed to parse Kafka payload", e);
        }
    }
}
```

---

## Type mapping (design → Java)

| 設計書の型 | Java | UNNEST array component |
|---|---|---|
| String | `String` | `String.class` |
| Long | `Long` | `Long.class` |
| Integer | `Integer` | `Integer.class` |
| BigDecimal | `java.math.BigDecimal` | `BigDecimal.class` |
| 日付 (date) | `LocalDate` | `java.sql.Date` (via `sqlDateColumn`) |
| 日時 (datetime) | `LocalDateTime` | set from `CURRENT_TIMESTAMP` in SQL |

## Completion checklist

1. Consumer: batch `@KafkaListener` + manual ack; empty → ack+return; payload normalized; PK-guarded; bad records logged-and-skipped; ack **after** processing.
2. Service: `@Service`, **no `@Transactional`**; chunked (`CHUNK_SIZE`); independent tables in parallel via `taskExecutor` + `allOf().join()`; empty lists skipped.
3. Mapper XML: `INSERT … SELECT … FROM unnest(<arrays>) AS v(...) ON CONFLICT (<pk>) DO NOTHING`; arrays bound via `PostgresArrayTypeHandler`; **arrays aligned to column order**; `CURRENT_TIMESTAMP` for audit/exclusioncheck; `/* */` comments.
4. `UnnestParamsBuilder`: `build[Name]Params` with one `ColumnSpec` per column in INSERT order; `<col>Arr` keys match the XML.
5. Entity: plain `@Data` + `@JsonIgnoreProperties(ignoreUnknown = true)` (no `BaseEntity`); fields aligned to columns (camel-case OFF).
6. (New array element type only) `PostgresArrayTypeHandler` extended.
7. No gRPC; no MapStruct; no `@Transactional`; no tests; no stubbed `com.fw.grpc.*` / `com.scm.core.*`; no edits to `target/`.
