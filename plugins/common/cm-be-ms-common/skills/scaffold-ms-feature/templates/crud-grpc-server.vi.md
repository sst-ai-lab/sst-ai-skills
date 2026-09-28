# Tính năng MS — tạo mới ban đầu

Tài liệu này dựng khung một **tính năng phía microservice**: một gRPC endpoint được hậu thuẫn bởi logic
nghiệp vụ, lưu trữ MyBatis/PostgreSQL, và MapStruct mapping. Các template bên dưới là
bộ khung; các quy tắc chi tiết từng dòng nằm ở `../references/*.md` — hướng dẫn này cho bạn biết **cần tạo file nào và theo
thứ tự nào**, còn các tài liệu tham chiếu cho biết **mỗi dòng phải trông như thế nào**.

**Điều kiện tiên quyết:** spec OpenAPI đã được sinh và build, nên các stub/message gRPC
(`com.cm.grpc.*`) và các DTO/exception dùng chung (`com.fw.core.*`) đã tồn tại dưới dạng
jar nội bộ. Nếu thiếu một `*ServiceImplBase` hay kiểu message cho tính năng này, tức là
spec chưa được build — hãy dừng lại và báo cáo; tuyệt đối không stub các class này.

> **Ngoài phạm vi:** test; các class `com.cm.grpc.*` / `com.fw.core.*` (jar nội bộ
> bên ngoài — tuyệt đối không stub); `build/` (được sinh ra). **Package gốc:** `{basePackage}`.

**Tái sử dụng framework dùng chung — đừng phát minh lại:** trước khi viết một exception, mã lỗi,
list wrapper, hay kiểu audit/user, hãy kiểm tra framework dùng chung trước — kiểu `com.fw.core.*`
gần như luôn đã tồn tại (ví dụ `NotFoundException` + `ErrorCodeEnum`, `ListResponse`,
`RequestContextHolder`). Hãy import và tái sử dụng nó.

## Đầu vào cần thu thập trước

Hãy hỏi; đánh dấu bất cứ điều gì chưa rõ là "cần xác nhận / 要確認" (đừng tự nghĩ ra):

1. **ID & tên chức năng (機能ID・機能名)** + phân loại (大分類 / 中分類 / 小分類) → quyết định tên class và package (xem _Cách đặt tên_ bên dưới).
2. **gRPC service + method**: `*ServiceImplBase` được sinh ra và (các) RPC cần cài đặt, cùng các kiểu message request/response.
3. **Đọc hay ghi**: một truy vấn, một luồng ghi (insert/update/delete, optimistic lock, audit, sự kiện), hoặc cả hai.
4. **Dữ liệu & SQL**: (các) bảng PostgreSQL đích và câu truy vấn/câu lệnh **lấy từ thiết kế** (giữ trung thực — xem `../references/mybatis-mapper.md`).
5. **Phạm vi quyền**: người gọi bị giới hạn theo bộ lọc owner/kho/công ty nào (nếu có).
6. **Sự kiện**: thiết kế có phát một sự kiện miền Kafka sau khi ghi không?

## Cách đặt tên — suy ra mọi thứ từ phân loại

Tài liệu thiết kế phân loại một tính năng theo 大分類 / 中分類 / 小分類 / 機能名. Hãy map từng phần
sang mã của nó, rồi lắp thành các tag. **Service này là `{middleCategory}` (中分類) thuộc 大分類 `Web`
hoặc `Mobile`**; các stub được sinh ra mang tag đầy đủ, các class impl bỏ
tiền tố 大分類.

### 大分類 (chỉ quyết định tiền tố của stub được sinh ra)

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

### 小分類 (→ đoạn package `<domain>`)

| 設計書 小分類 | コード | Pascal      | lc (`<domain>`) |
| ------------- | ------ | ----------- | --------------- |
| FW            | `000`  | `Fw`        | `fw`            |
| 共通          | `010`  | `Common`    | `common`        |
| マスタ        | `020`  | `Master`    | `master`        |
| 入荷          | `030`  | `Rcv`       | `rcv`           |
| 出荷          | `040`  | `So`        | `so`            |
| オーダー管理  | `050`  | `Order`     | `order`         |
| 在庫          | `060`  | `Inv`       | `inv`           |
| 請求          | `070`  | `Billcalc`  | `billcalc`      |
| 運賃          | `080`  | `Carrycalc` | `carrycalc`     |
| 棚卸          | `090`  | `Stks`      | `stks`          |
| 配送          | `100`  | `Tms`       | `tms`           |
| 保税          | `110`  | `Hozei`     | `hozei`         |
| ABL           | `120`  | `Abl`       | `abl`           |
| BI            | `130`  | `Bi`        | `bi`            |
| ログ          | `140`  | `Log`       | `log`           |
| 受払          | `150`  | `Inout`     | `inout`         |
| 日々在庫      | `160`  | `Dailyinv`  | `dailyinv`      |
| 分析          | `170`  | `Analyze`   | `analyze`       |

> Một repository chỉ triển khai một phần trong số này thành các package `<domain>`. Với một 小分類
> không có trong bảng, hãy dùng tiểu mục tiếng Anh của thiết kế viết lowerCamel làm `<domain>` và PascalCase trong các tag.

### Các tên đã lắp ghép

| Biến         | Quy tắc                                                                                 | Ví dụ (中=Core, 小=So, 機能=SoMainte) |
| ---------------- | ------------------------------------------------------------------------------------ | --------------------------------------- |
| `<domain>`       | 小分類 lc                                                                            | `so`                                    |
| `[TagMs]`        | `[中分類Pascal][小分類Pascal][機能名Pascal]` — **các class phía impl**                 | `CoreSoSoMainte`                        |
| `[TagFull]`      | `[大分類Pascal][TagMs]` — **chỉ dùng cho stub/base được sinh ra** (bên ngoài)                    | `WebCoreSoSoMainte`                     |
| `[operationId]`  | `[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]` — method RPC | `webCoreSoSoMainteGetSo`                |
| `[機能名Pascal]` | 機能名 viết PascalCase — nền tảng cho mapper / entity                                           | `SoMainte`                              |

Các tên class thu được: `[TagMs]Grpc` (kế thừa `[TagFull]ServiceImplBase` được sinh ra),
`[TagMs]Service` / `…ServiceImpl`, `[TagMs]ServiceMapping`, `[機能名Pascal]Mapper`
(+ `.xml`), `[Name]Entity`.

## Bản đồ file / thư mục (chỉ trong repo này)

```
src/main/java/{basePackagePath}/
├─ grpc/core/<domain>/[TagMs]Grpc.java                         ← ⑥ gRPC impl
├─ service/core/<domain>/
│  ├─ [TagMs]Service.java                                      ← ⑤ interface
│  └─ [TagMs]ServiceImpl.java                                  ← ⑤ impl
├─ infrastructure/mapping/core/<domain>/[TagMs]ServiceMapping.java   ← ④ MapStruct
├─ persistence/
│  ├─ mapper/core/<domain>/[機能名Pascal]Mapper.java           ← ② interface MyBatis
│  └─ model/core/<domain>/
│     ├─ [Name]Entity.java                                     ← ① entity (kế thừa BaseEntity)
│     └─ [機能名Pascal][API名]Request.java / …Result.java       ← ① model truy vấn/kết quả
└─ infrastructure/message/                                     ← ⑦ sự kiện Kafka (chỉ khi thiết kế phát sự kiện)

src/main/resources/
└─ mybatis/mapper/core/<domain>/[機能名Pascal]Mapper.xml        ← ③ SQL của MyBatis
```

## Luồng dữ liệu

```
gRPC impl (@GrpcService, delegate-only)
  → Service (@Transactional on writes; typed com.fw.core.exception.*; optimistic lock; audit)
      → MyBatis @Mapper + Mapper.xml      (PostgreSQL — explicit column mapping)
      → MapStruct [TagMs]ServiceMapping    (entity ↔ gRPC message)
      → Kafka publish (after commit, only if the design emits events)
```

## Thứ tự sinh code

Hãy xây từ trong ra ngoài để mỗi tầng biên dịch được dựa trên tầng bên dưới:

1. ① Entity + các model request/result
2. ② Interface MyBatis mapper
3. ③ XML MyBatis mapper (SQL từ thiết kế — giữ trung thực)
4. ④ MapStruct `[TagMs]ServiceMapping`
5. ⑤ Interface service + `*Impl`
6. ⑥ gRPC impl
7. ⑦ Publisher/record sự kiện Kafka (chỉ khi thiết kế phát sự kiện)

---

## Các template

### ① Entity + model — `persistence/model/core/<domain>/`

Các entity của bảng nghiệp vụ kế thừa `BaseEntity` (thừa hưởng các cột audit `adddatetime/addusercd/
addusername/addterminalcd` + `upd*`). Hãy khai báo `exclusioncheck` trên chính entity cho
các dòng nghiệp vụ có optimistic lock. Dùng POJO Lombok thuần cho các hình dạng truy vấn/kết quả
không phải entity.

```java
package {basePackage}.persistence.model.core.[domain];

@Data
@SuperBuilder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(callSuper = true)
public class [Name]Entity extends BaseEntity {

    // Các cột từ thiết kế (chỉ những field được định nghĩa trong thiết kế — đừng tự nghĩ ra).
    private String companyCd;
    private Long soNo;
    // ...

    /** Timestamp optimistic-lock (chỉ cho các dòng nghiệp vụ). */
    private LocalDateTime exclusioncheck;
}
```

```java
// Tham số truy vấn / dòng kết quả KHÔNG phải entity (không audit, không BaseEntity):
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class [機能名Pascal][API名]Request {
    private String companyCd;
    private Long soNo;
    // ... các tham số đầu vào theo thiết kế
}
```

### ② Interface MyBatis mapper — `persistence/mapper/core/<domain>/[機能名Pascal]Mapper.java`

```java
package {basePackage}.persistence.mapper.core.[domain];

@Mapper
public interface [機能名Pascal]Mapper {

    // Các lệnh đọc trả về entity / model kết quả:
    List<[Name]Entity> select[機能名Pascal]([機能名Pascal]Request request);

    // Các lệnh ghi trả về số dòng bị ảnh hưởng (service kiểm tra nó cho optimistic lock):
    int insert[機能名Pascal]([Name]Entity entity);
    int update[機能名Pascal]([Name]Entity entity);
    int delete[機能名Pascal]([機能名Pascal]Request request);
}
```

### ③ XML MyBatis mapper — `mybatis/mapper/core/<domain>/[機能名Pascal]Mapper.xml`

Áp dụng `../references/mybatis-mapper.md`. Các quy tắc then chốt: `namespace` = tên đầy đủ (FQN) của
mapper interface (chính xác); **camel-case tự động đang TẮT** → map mọi cột tường minh qua
`<resultMap>` hoặc alias cột; giữ SQL của thiết kế trung thực (JOIN / subquery /
`COALESCE` / các cast PostgreSQL — đừng đơn giản hoá); chú thích inline dùng `/* … */`; các lệnh ghi
đặt các cột audit và tôn trọng `exclusioncheck`.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{basePackage}.persistence.mapper.core.[domain].[機能名Pascal]Mapper">

  <resultMap id="[機能名Pascal]Result"
             type="{basePackage}.persistence.model.core.[domain].[Name]Entity">
    <result property="companyCd"     column="companycd"/>   <!-- camel-case đang TẮT: map từng cột -->
    <result property="soNo"          column="sono"/>
    <result property="exclusioncheck" column="exclusioncheck"/>
    <!-- ... một <result> cho mỗi property -->
  </resultMap>

  <select id="select[機能名Pascal]"
          parameterType="{basePackage}.persistence.model.core.[domain].[機能名Pascal]Request"
          resultMap="[機能名Pascal]Result">
    /* Tái tạo câu SELECT của thiết kế nguyên trạng — giữ các JOIN/COALESCE/cast. */
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
      AND exclusioncheck = #{exclusioncheck}   /* optimistic lock: 0 dòng ⇒ xung đột */
  </update>

</mapper>
```

### ④ MapStruct mapping — `infrastructure/mapping/core/<domain>/[TagMs]ServiceMapping.java`

Áp dụng `../references/mapstruct-mapping.md`. Header chuẩn; kế thừa
`BaseMapping` **chỉ khi** bạn tái sử dụng một trong các phép chuyển đổi của nó; dùng `@Mapping` cho các field bị đổi tên;
map `repeated` tới tên logic (không phải `…List`); `@Named` + `qualifiedByName` cho các phép biến đổi
giá trị (ví dụ định dạng `exclusioncheck`).

```java
package {basePackage}.infrastructure.mapping.core.[domain];

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [TagMs]ServiceMapping {

    @Mapping(target = "details", source = "soDetails")   // repeated → tên logic
    Grpc[TagFull][API名]Response to[API名]Response(List<[Name]Entity> entities);
}
```

### ⑤ Service — `service/core/<domain>/[TagMs]Service.java` + `…ServiceImpl.java`

Áp dụng `../references/service-layer.md`. Interface + impl `@Service`
(`@RequiredArgsConstructor`, các dependency `private final`). Throw các
`com.fw.core.exception.*` có kiểu kèm `ErrorCodeEnum` — tuyệt đối không null/cờ. **Các luồng ghi:**
`@Transactional`; phân giải audit qua `RequestContextHolder.getContext()`; khi update hãy so sánh
số dòng bị ảnh hưởng và throw `ConflictException(SQL_UNIQUE_VIOLATION)` nếu lệch;
phát sự kiện Kafka **sau khi** lưu thành công. Áp dụng phạm vi quyền của người gọi.

Các method của service nhận/trả về trực tiếp các kiểu message gRPC. Các exception có kiểu và
ngữ cảnh audit đến từ các jar bên ngoài `com.fw.core.*` / `com.fw.grpc.core.dto`
(tuyệt đối không stub):

```java
import com.fw.core.constant.ErrorCodeEnum;
import com.fw.core.dto.RequestContext;
import com.fw.core.exception.BadRequestException; // + ConflictException / ForbiddenException / NotFoundException
import com.fw.core.shape.BaseInvalidRequestExceptionRecord;
import com.fw.core.shape.InvalidRequestExceptionRecord;
import com.fw.grpc.core.dto.RequestContextHolder;
```

```java
public interface [TagMs]Service {
    Grpc[TagFull][API名]Response [API名lc](Grpc[TagFull][API名]Request request);          // đọc
    com.google.protobuf.Empty [writeApiLc](Grpc[TagFull][WriteApi]Request request);       // ghi (Empty khi RPC không trả payload)
}
```

```java
package {basePackage}.service.core.[domain];

@Service
@RequiredArgsConstructor
public class [TagMs]ServiceImpl implements [TagMs]Service {

    private final [機能名Pascal]Mapper [機能名lc]Mapper;
    private final [TagMs]ServiceMapping [tagMsLc]ServiceMapping;
    // private final {eventPublisher} [tagMsLc]EventPublisher;  // chỉ khi thiết kế phát sự kiện

    // ---- đọc ----
    @Override
    public Grpc[TagFull][API名]Response [API名lc](Grpc[TagFull][API名]Request request) {
        List<[Name]Entity> rows = [機能名lc]Mapper.select[機能名Pascal](/* truy vấn dựng từ request */);
        return [tagMsLc]ServiceMapping.to[API名]Response(rows);
    }

    // ---- ghi ----
    @Override
    @Transactional
    public com.google.protobuf.Empty [writeApiLc](Grpc[TagFull][WriteApi]Request request) {
        String userId = request.getUserid();
        if (!StringUtils.hasText(userId)) {
            throw new ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED);
        }
        AuditInfo audit = resolveAuditInfo(userId);

        [Name]Entity entity = [Name]Entity.builder()
            // ... các field theo thiết kế
            .exclusioncheck(/* giá trị lock kỳ vọng được phân tích từ request */)
            .updusercd(audit.userCd())
            .updusername(audit.userName())
            .updterminalcd(audit.terminalCd())
            .build();

        int affected = [機能名lc]Mapper.update[機能名Pascal](entity);
        if (affected != 1) {                                  // kiểm tra optimistic-lock
            throw new ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION);
        }
        // [tagMsLc]EventPublisher.publishUpsert(entity.getXxx());   // sau khi lưu, bên trong transaction

        return com.google.protobuf.Empty.getDefaultInstance();   // RPC ghi trả về Empty
    }

    // Phân giải chủ thể audit: ưu tiên userId của request, làm giàu từ RequestContext, dự phòng "SYSTEM".
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
                userName = raw.length() > 30 ? raw.substring(0, 30) : raw;   // canh độ dài cột
            }
        }
        return new AuditInfo(userCd, userName, "");
    }

    // Lỗi dữ liệu vào không hợp lệ theo từng field (cho client chi tiết ở mức field):
    private BadRequestException invalidBody(String message, String fieldName, Object fieldValue) {
        List<BaseInvalidRequestExceptionRecord> errors = List.of(new InvalidRequestExceptionRecord(
            ErrorCodeEnum.REQUEST_BODY_INVALID, message, fieldName, fieldValue,
            StringUtils.hasText(fieldName) ? Map.of("fieldName", fieldName) : Map.of()));
        return new BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors);
    }

    private record AuditInfo(String userCd, String userName, String terminalCd) {}
}
```

Các exception có kiểu nên dùng (từ `com.fw.core.exception.*` + `ErrorCodeEnum`):
`ForbiddenException(REQUEST_NOT_PERMITTED)`, `NotFoundException(RESOURCE_NOT_FOUND)`,
`BadRequestException(REQUEST_BODY_INVALID, errors)` (qua `invalidBody`),
`ConflictException(SQL_UNIQUE_VIOLATION)`.

### ⑥ gRPC impl — `grpc/core/<domain>/[TagMs]Grpc.java`

`@GrpcService` + `@RequiredArgsConstructor`, `extends [TagFull]ServiceImplBase`. **Chỉ uỷ
quyền — không có logic nghiệp vụ.** Kết thúc bằng `onNext(...)` rồi `onCompleted()`. Đừng bắt các
exception miền (một advice trung tâm map chúng sang `Status` gRPC).

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

    // RPC ghi trả về Empty:
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

### ⑦ Sự kiện Kafka (chỉ khi thiết kế phát sự kiện)

Thêm/mở rộng một publisher dưới `infrastructure/message` (mẫu: `{eventPublisher}`)
cùng một event record dưới `infrastructure/message/event`; phát từ service
**sau khi** lệnh ghi thành công, bên trong method có transaction.

---

## Mapping kiểu (thiết kế → Java)

| 設計書の型                              | Java                   | Ghi chú                 |
| --------------------------------------- | ---------------------- | -------------------- |
| String                                  | `String`               |                      |
| Long                                    | `Long`                 |                      |
| Integer                                 | `Integer`              |                      |
| BigDecimal                              | `java.math.BigDecimal` |                      |
| 日付 (YYYYMMDD) / 日時 (YYYYMMDDHHmmss) | `String`               | không chuyển đổi định dạng |
| Array<X>                                | `List<X>`              |                      |

Cột → property: các cột DB viết thường (ví dụ `companycd`, `sono`); camel-case tự động đang
TẮT, nên hãy map từng cột tường minh trong `<resultMap>` (hoặc đặt alias trong SQL).

## Danh sách kiểm tra hoàn thành

1. gRPC impl: `@GrpcService`, kế thừa `[TagFull]ServiceImplBase`, chỉ uỷ quyền, `onNext` + `onCompleted`, không bắt exception.
2. Service: các `com.fw.core.exception.*` có kiểu + `ErrorCodeEnum`; `@Transactional` cho các luồng ghi; optimistic-lock (kiểm tra số dòng bị ảnh hưởng → `ConflictException`); audit từ `RequestContextHolder`; phạm vi quyền được áp dụng; sự kiện được phát sau khi lưu.
3. MyBatis: `namespace` = FQN của interface; map cột tường minh (camel-case TẮT); SQL PostgreSQL trung thực; chú thích `/* */`; các lệnh ghi đặt audit + tôn trọng `exclusioncheck`.
4. Entity kế thừa `BaseEntity` (+ `exclusioncheck` cho các dòng có lock); các model truy vấn/kết quả là Lombok thuần.
5. MapStruct: header chuẩn (+ `BaseMapping` chỉ khi tái sử dụng các phép chuyển đổi của nó); các field đổi tên + `repeated` + các phép chuyển đổi tuỳ biến đều được map.
6. (Sự kiện) được phát sau lệnh ghi, bên trong transaction.
7. Không test; không stub `com.cm.grpc.*` / `com.fw.core.*`; không sửa `build/`.
