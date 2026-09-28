# Framework dùng chung — những gì service này tái sử dụng ({repo})

Các type dùng chung dưới đây đến từ **jar `com.fw.core.*` (sst-fw-be-core)** và jar audit
gRPC — **hãy import và tái sử dụng chúng; đừng bao giờ tự viết bản tương đương**. Đây chỉ liệt kê những gì
**service này** dùng (không phải toàn bộ framework). Nó ghi lại _những gì đang tồn tại để tái sử dụng_ — nếu một
signature trông có vẻ sai, hãy đối chiếu với **jar dependency trên classpath** của bạn (IDE
go-to-definition), chứ không phải một bản spec đã đóng băng. File này tự chứa: nó không trỏ tới bất kỳ
repository nào khác.

## Exception domain — `com.fw.core.exception.*`

Hãy throw những cái này (đừng bao giờ trả về null / cờ lỗi); một advice trung tâm map chúng sang gRPC `Status`,
nên **đừng catch rồi bỏ qua**. Tất cả đều nhận một `BaseErrorCodeEnum` (dùng `ErrorCodeEnum`).

| Exception             | Dùng khi                             | Constructor                                                                                                                                                                                  |
| --------------------- | ------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `ForbiddenException`  | caller không có quyền / không có scope   | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `NotFoundException`   | không tìm thấy dòng đích                 | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `ConflictException`   | vi phạm optimistic-lock / unique   | `(errorCode)`, `(errorCode, Throwable)`, `(errorCode, Object... args)`                                                                                                                        |
| `BadRequestException` | input không hợp lệ (có thể theo từng field) | `(errorCode)`, `(errorCode, String... args)`, `(errorCode, Throwable)`, `(errorCode, List<BaseInvalidRequestExceptionRecord> errors)`, `(errorCode, BaseInvalidRequestExceptionRecord error)` |
| `ServiceUnavailableException` | downstream/dependency không khả dụng | `(errorCode)`, `(errorCode, Throwable, int retryAfterSeconds)`, `(errorCode, Object... args)` |

```java
throw new NotFoundException(ErrorCodeEnum.RESOURCE_NOT_FOUND);

throw new ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION); // affected-row mismatch on update
```

## Mã lỗi — `com.fw.core.constant.ErrorCodeEnum`

Enum mã lỗi của nền tảng (các mã `EB-…`). Hãy truyền một constant cho exception / record;
**đừng tự nghĩ ra mã dạng chuỗi**. Các constant mà service này thường dùng: `RESOURCE_NOT_FOUND`,
`REQUEST_NOT_PERMITTED`, `REQUEST_BODY_INVALID`, `SQL_UNIQUE_VIOLATION`, `FIELD_INVALID`,
`INTERNAL_SERVER_ERROR`. (Xem `ErrorCodeEnum` để biết toàn bộ tập hợp — hãy chọn một cái đã có.)

## Record lỗi theo từng field — `com.fw.core.shape.InvalidRequestExceptionRecord`

Dùng cho chi tiết `BadRequestException` ở mức field (client biết được field nào không hợp lệ). Implement
`BaseInvalidRequestExceptionRecord`.

| Constructor                                                                                  | Field                                               |
| -------------------------------------------------------------------------------------------- | ---------------------------------------------------- |
| `(errorCode, errorMessage, errorField, errorFieldValue, Map<String,String> errorParameters)` | đầy đủ                                                 |
| `(errorCode, errorMessage, errorField, errorFieldValue)`                                     | không có params                                            |
| `(errorField, errorMessage, errorFieldValue)`                                                | mặc định `errorCode` = `ErrorCodeEnum.FIELD_INVALID` |

```java
var errors = List.<BaseInvalidRequestExceptionRecord>of(
  new InvalidRequestExceptionRecord(ErrorCodeEnum.REQUEST_BODY_INVALID, msg, field, value, Map.of("fieldName", field))
);

throw new BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors);
```

## Response dạng danh sách — `com.fw.core.dto.ListResponse<T>` + `ListResponseMetadata`

Wrapper chuẩn cho danh sách phân trang được trả về cho tầng gRPC/MapStruct. **Đừng tự định nghĩa
class kết quả danh sách của riêng bạn.**

- `ListResponse<T>`: các field `data` (`List<T>`), `metadata` (`ListResponseMetadata`).
  Factory: `ListResponse.of(List<T> data, int total)` · `ListResponse.of(List<T> data, ListResponseMetadata metadata)`.
- `ListResponseMetadata`: các field `total` (long), `page` (int), `size` (int). Factory:
  `ListResponseMetadata.of(int total)` · `of(int total, int page, int size)`.

```java
ListResponse<{Feature}Entity> response = ListResponse.of(results, results.size());
// paged: new ListResponse<>(rows, ListResponseMetadata.of((int) totalCount, page, size));
```

## Context của caller / audit — `com.fw.core.dto.RequestContext` + `RequestContextHolder`

Xác định actor hiện tại để audit / phân quyền. **`RequestContextHolder` nằm trong jar audit gRPC
`com.fw.grpc.core.dto`** (không phải `com.fw.core`); nó trả về một
`com.fw.core.dto.RequestContext`.

- `RequestContextHolder.getContext()` → `RequestContext` (có thể là `null`).
- `RequestContext.getUser()` → `SecurityUserDto` (có thể là `null`); `getAttribute(name)`.
- `SecurityUserDto`: `getUsercd()`, `getUsername()`, `getCompanyCode()` (phần tử đầu của `companycd`), `getEmail()`, `getAuthorities()`.

```java
RequestContext ctx = RequestContextHolder.getContext();

String userCd = ctx != null && ctx.getUser() != null ? ctx.getUser().getUsercd() : null;
// fall back to the request's userId / "SYSTEM" when absent (see the service-layer template)
```

## Constant cho event / process-log — `com.fw.core.constant.*` + `com.fw.core.message.*`

Khi một feature phát ra event hoặc ghi process log, hãy tái sử dụng các constant dùng chung
(`LogLevel`, `LogProcessKbn`, `ServiceKbn`, `ProcessResult`, `CoreEventTopic`, …) và các
message type (`com.fw.core.message.*`) — điều khiển chúng thông qua các helper **nằm trong repo**
(`helper/{processLogHelper}`, `infrastructure/message/{eventPublisher}`), đừng tự tạo
topic/constant mới bằng tay.

---

**Nguyên tắc chung:** trước khi viết một exception, mã lỗi, wrapper danh sách, hoặc type audit/user
mới — hãy kiểm tra ở đây trước; cái dùng chung hầu như luôn đã tồn tại. Các jar bên ngoài
(`com.fw.core.*`, `com.fw.grpc.core.*`) và jar gRPC được sinh ra (`com.cm.grpc.*`) không bao giờ được stub.
