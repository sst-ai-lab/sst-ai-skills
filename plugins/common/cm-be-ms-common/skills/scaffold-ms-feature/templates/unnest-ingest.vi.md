# Tính năng nạp sự kiện — tạo mới ban đầu

Tài liệu này dựng khung một **tính năng nạp sự kiện (event-ingest)**: tiêu thụ một sự kiện Kafka và batch-upsert nó vào
PostgreSQL qua `UNNEST`. Service này có đúng một hình dạng — **Kafka consumer → UNNEST upsert
song song theo chunk** — ở đây **không có gRPC và không có MapStruct**. Các template bên dưới là
bộ khung; các quy tắc chi tiết từng dòng nằm ở `../references/*.md`.

> **Ngoài phạm vi:** các gRPC service/client; MapStruct; `@Transactional` (idempotent nhờ
> `ON CONFLICT`); các class `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` (jar bên ngoài —
> tuyệt đối không stub); `build/`; **test**. **Package gốc:** `{basePackage}`.

## Đầu vào cần thu thập trước

Hãy hỏi; đánh dấu bất cứ điều gì chưa rõ là "cần xác nhận / 要確認" (đừng tự nghĩ ra):

1. **ID & tên chức năng (機能ID・機能名)**.
2. **Topic Kafka** + hình dạng payload JSON phẳng (consumer chuyển một message thành một
   hoặc nhiều kiểu entity).
3. **(Các) bảng đích** + **khóa chính** (cho `ON CONFLICT`) + danh sách cột đầy đủ.
4. Mapping **field entity ↔ cột** (camel-case tự động đang TẮT — tên phải khớp nhau).
5. Một message có nạp vào **nhiều hơn một bảng** không (ví dụ một dòng sổ + một dòng lịch sử)?

## Cách đặt tên

Cách đặt tên theo phân loại thiết kế dùng chung; các tầng của service này là phẳng:

| Tầng | Mẫu | Ví dụ |
|---|---|---|
| Entity | `[Name]Entity` | `{Domain}Entity` |
| Mapper interface | `[Name]Mapper` | `{Domain}Mapper` |
| XML SQL của mapper | `mybatis/mapper/[Name]Mapper.xml` (namespace = tên đầy đủ của interface) | `{Domain}Mapper.xml` |
| XML ResultMap (chỉ khi đọc) | `mybatis/mapping/[Name]Mapping.xml` | `{Domain}Mapping.xml` |
| Params builder | một `build[Name]Params(...)` cho mỗi bảng trong `UnnestParamsBuilder` | `build{Domain}Params` |
| Service | `Core[Feature]Service` + `…Impl` | `Core{Domain}MovementHistoryService` |
| Consumer | `[Feature]Consumer` | `CoreInvMovementHistoryConsumer` |

Đoạn package của miền là `{domain}` (`…core.{domain}`).

## Bản đồ file / thư mục (chỉ trong repo này)

```
src/main/java/{basePackagePath}/
├─ infrastructure/message/consumer/[Feature]Consumer.java        ← ⑦ Kafka batch consumer
├─ service/core/{domain}/
│  ├─ Core[Feature]Service.java                                  ← ⑥ interface
│  └─ Core[Feature]ServiceImpl.java                              ← ⑥ impl (chunk + song song, KHÔNG @Transactional)
├─ persistence/
│  ├─ mapper/core/{domain}/
│  │  ├─ [Name]Mapper.java                                       ← ② interface mapper
│  │  └─ UnnestParamsBuilder.java                                ← ④ mở rộng thêm build[Name]Params
│  └─ model/core/{domain}/[Name]Entity.java                         ← ① entity (@Data thuần, không BaseEntity)
├─ configuration/PostgresArrayTypeHandler.java                   ← (chỉ mở rộng nếu xuất hiện kiểu phần tử mảng mới)
└─ dto/                                                          ← (payload có kiểu, tuỳ chọn)

src/main/resources/mybatis/
├─ mapper/[Name]Mapper.xml                                       ← ③ SQL UNNEST upsert
└─ mapping/[Name]Mapping.xml                                     ← (resultMap — chỉ khi tính năng cũng đọc dòng về)
```

## Luồng dữ liệu

```
Kafka topic → @KafkaListener batch consumer (manual ack)
  → normalize payload (String/byte[] → readTree; Map → pass through)
  → objectMapper.convertValue(normalized, [Name]Entity.class) → guard PK fields
  → service.batchUpsert(...)  → chunk + parallel per table (applicationTaskExecutor)
  → mapper.batchUpsert[Name]Unnest(params)
  → INSERT … SELECT … FROM unnest(<one array per column>) … ON CONFLICT (<pk>) DO NOTHING
```

## Thứ tự sinh code

1. ① Entity
2. ② Interface mapper
3. ③ XML mapper (UNNEST upsert)
4. ④ `UnnestParamsBuilder` — thêm `build[Name]Params`
5. ⑤ `PostgresArrayTypeHandler` — chỉ khi đưa vào một kiểu phần tử mảng mới
6. ⑥ Interface service + `*Impl`
7. ⑦ Kafka consumer

---

## Các template

### ① Entity — `persistence/model/core/{domain}/[Name]Entity.java`

POJO Lombok thuần với **tất cả** các cột (audit `add*`/`upd*`, `exclusioncheck` khai báo trực tiếp — service
này **không** dùng `BaseEntity`). `@JsonIgnoreProperties(ignoreUnknown = true)` để một
payload Kafka phẳng có field thừa vẫn chuyển đổi gọn gàng. Tên field map tới cột DB (camel-case
tự động đang TẮT — hãy giữ chúng khớp nhau).

```java
package {basePackage}.persistence.model.core.{domain};

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class [Name]Entity {

    private String companycd;     // một phần của PK
    private Long [pkColumn];         // một phần của PK
    // ... mọi cột từ thiết kế

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

### ② Interface mapper — `persistence/mapper/core/{domain}/[Name]Mapper.java`

```java
package {basePackage}.persistence.mapper.core.{domain};

@Mapper
public interface [Name]Mapper {

    /** UNNEST batch upsert; {@code params} chứa một mảng có kiểu cho mỗi cột. Trả về số dòng đã insert. */
    int batchUpsert[Name]Unnest(Map<String, Object> params);
}
```

### ③ XML mapper — `mybatis/mapper/[Name]Mapper.xml`

Áp dụng `../references/mybatis-mapper.md`. Luồng ghi cốt lõi là một câu lệnh
`INSERT … SELECT … FROM unnest(<arrays>) … ON CONFLICT (<pk>) DO NOTHING` duy nhất:

- `namespace` = tên đầy đủ của interface mapper.
- **Một mảng cho mỗi cột, theo cùng thứ tự** trong danh sách `unnest(...)`, danh sách cột
  `AS v(...)`, và danh sách cột của INSERT — một mảng lệch vị trí sẽ lặng lẽ ghi sai
  cột.
- Bind mỗi mảng qua `PostgresArrayTypeHandler` của dự án trên tham số `#{…Arr}`.
- Đặt `adddatetime` / `upddatetime` thành `CURRENT_TIMESTAMP`; cột `exclusioncheck`
  cuối cùng cũng vậy.
- Kết thúc bằng `ON CONFLICT (<pk>) DO NOTHING` — đây chính là thứ làm cho các lô được tiêu thụ lại
  trở nên idempotent. Chú thích inline dùng `/* … */`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{basePackage}.persistence.mapper.core.{domain}.[Name]Mapper">

  <sql id="TableName">t_[name]</sql>

  <insert id="batchUpsert[Name]Unnest" parameterType="map">
    INSERT INTO <include refid="TableName"/> (
      companycd, [pkColumn], /* ...mọi cột..., */ adddatetime, addusercd, /* ... */ exclusioncheck
    )
    SELECT
      v.companycd, v.[pkColumn], /* ...cùng thứ tự..., */ CURRENT_TIMESTAMP, v.addusercd, /* ... */ CURRENT_TIMESTAMP
    FROM unnest(
      #{companycdArr, typeHandler={basePackage}.configuration.PostgresArrayTypeHandler},
      #{[pkColumn]Arr, typeHandler={basePackage}.configuration.PostgresArrayTypeHandler}
      /* ...một #{<col>Arr, typeHandler=…} cho mỗi cột, cùng thứ tự... */
    ) AS v(
      companycd, [pkColumn] /* ...cùng tên cột, cùng thứ tự... */
    )
    ON CONFLICT (companycd, [pkColumn]) DO NOTHING
  </insert>

</mapper>
```

### ④ Tham số UNNEST — mở rộng `persistence/mapper/core/{domain}/UnnestParamsBuilder`

Thêm một `build[Name]Params(List<[Name]Entity> chunk)` trả về một `Map<String,Object>` với
**một mảng có kiểu cho mỗi cột** đặt khóa `<column>Arr`, theo **đúng thứ tự cột của INSERT**.
Builder này được điều khiển bởi spec — khai báo một `ColumnSpec` cho mỗi cột (`key`, getter, kiểu
thành phần); các cột ngày dùng spec sql-date.

```java
private static final ColumnSpec[] [NAME]_SPECS = {
    column("companycdArr", "getCompanycd", String.class),
    column("[pkColumn]Arr",   "get[PkColumn]",   Long.class),
    // ... một spec cho mỗi cột, THEO THỨ TỰ CỘT
    sqlDateColumn("[dateColumn]Arr", "get[DateColumn]"),     // LocalDate → java.sql.Date
    column("qtyArr",       "getQty",       BigDecimal.class),
    column("addusercdArr", "getAddusercd", String.class),
    // ...
};

/** Dựng map tham số UNNEST cho lần insert theo lô vào t_[name]. */
public static Map<String, Object> build[Name]Params(List<[Name]Entity> entities) {
    return buildParams(entities, [NAME]_SPECS);
}
```

> Các khóa mảng ở đây phải khớp chính xác với các tên `#{…Arr}` ở ③, và thứ tự spec phải
> khớp thứ tự cột của INSERT — đây là hai lỗi UNNEST thường gặp nhất.

### ⑤ PostgresArrayTypeHandler — chỉ khi xuất hiện một kiểu phần tử mới

Nếu kiểu phần tử mảng của một cột chưa được xử lý, hãy thêm mapping trong
`configuration/PostgresArrayTypeHandler` (kiểu PostgreSQL tương ứng mỗi kiểu thành phần Java). Phần lớn
tính năng tái sử dụng các kiểu đã có và bỏ qua bước này.

### ⑥ Service — `service/core/{domain}/Core[Feature]Service.java` + `…Impl.java`

Áp dụng `../references/service-layer.md`. `@Service`; inject các mapper và
executor được quản lý; **không `@Transactional`**. Chia chunk mỗi danh sách entity (`CHUNK_SIZE` có thể điều chỉnh),
chạy các bảng độc lập song song qua `CompletableFuture.runAsync(..., taskExecutor)` rồi
`allOf(...).join()`; bỏ qua danh sách rỗng. Giữ việc map payload ra ngoài service.

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

    private static final int CHUNK_SIZE = 2000;   // UNNEST loại bỏ giới hạn tham số bind → chunk lớn

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
        // một future cho mỗi bảng độc lập...
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

Áp dụng `../references/kafka-consumer.md`. `@Slf4j @Service
@RequiredArgsConstructor`; `@KafkaListener` dạng batch + manual ack. Lô rỗng → `acknowledge()`
+ return. Với mỗi record: chuẩn hoá (String/byte[] → `objectMapper.readTree`; Map → cho đi
qua), `convertValue` sang (các) kiểu entity, **canh các field PK** (bỏ qua khi null),
thu gom, uỷ quyền cho service, rồi `acknowledge()` **sau khi** xử lý. Bọc việc deserialize từng record
trong try/catch và **log-và-bỏ qua** một record lỗi (topic/partition/offset/key);
tuyệt đối không ack trước khi xử lý.

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
                if (entity.getCompanycd() != null && entity.get[PkColumn]() != null) {   // canh PK
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

## Mapping kiểu (thiết kế → Java)

| 設計書の型 | Java | Thành phần mảng UNNEST |
|---|---|---|
| String | `String` | `String.class` |
| Long | `Long` | `Long.class` |
| Integer | `Integer` | `Integer.class` |
| BigDecimal | `java.math.BigDecimal` | `BigDecimal.class` |
| 日付 (ngày) | `LocalDate` | `java.sql.Date` (qua `sqlDateColumn`) |
| 日時 (ngày giờ) | `LocalDateTime` | đặt từ `CURRENT_TIMESTAMP` trong SQL |

## Danh sách kiểm tra hoàn thành

1. Consumer: `@KafkaListener` dạng batch + manual ack; rỗng → ack+return; payload đã chuẩn hoá; đã canh PK; record lỗi được log-và-bỏ qua; ack **sau khi** xử lý.
2. Service: `@Service`, **không `@Transactional`**; chia chunk (`CHUNK_SIZE`); các bảng độc lập chạy song song qua `taskExecutor` + `allOf().join()`; bỏ qua danh sách rỗng.
3. XML mapper: `INSERT … SELECT … FROM unnest(<arrays>) AS v(...) ON CONFLICT (<pk>) DO NOTHING`; các mảng được bind qua `PostgresArrayTypeHandler`; **mảng khớp thứ tự cột**; `CURRENT_TIMESTAMP` cho audit/exclusioncheck; chú thích `/* */`.
4. `UnnestParamsBuilder`: `build[Name]Params` với một `ColumnSpec` cho mỗi cột theo thứ tự INSERT; các khóa `<col>Arr` khớp với XML.
5. Entity: `@Data` thuần + `@JsonIgnoreProperties(ignoreUnknown = true)` (không `BaseEntity`); các field khớp với cột (camel-case TẮT).
6. (Chỉ khi có kiểu phần tử mảng mới) `PostgresArrayTypeHandler` đã được mở rộng.
7. Không gRPC; không MapStruct; không `@Transactional`; không test; không stub `com.cm.grpc.*` / `com.fw.core.*`; không sửa `build/`.
