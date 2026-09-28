# Quy tắc MapStruct mapping

Áp dụng cho: `**/infrastructure/mapping/**/*.java`

Các mapper chuyển đổi giữa **entity lưu trữ / đối tượng miền** và **message gRPC (protobuf)** (trong `infrastructure/mapping/core/<domain>`), hoặc giữa **các message gRPC của service này** và **các message gRPC của `{targetMicroservice}` hạ nguồn** (trong `infrastructure/mapping`). Chúng là nơi duy nhất chứa logic chuyển đổi — các service và gRPC impl nên gọi một mapper, không tự map bằng tay. Một response đơn giản vẫn có thể được lắp trực tiếp bằng message builder.

Hãy theo header `@Mapper` mà các class mapping hiện có của repository này đang dùng.

## Khai báo mapper

Các mapper là **interface** thành phần của Spring. Header chuẩn là:

```java
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [Domain]GrpcMapping { ... }
```

- `componentModel = "spring"` (luôn luôn) — các mapper được inject dưới dạng Spring bean.
- Ba thuộc tính đầu luôn có mặt. Chỉ thêm `collectionMappingStrategy = ADDER_PREFERRED` **khi mapper xử lý các field `repeated`/collection của gRPC**; một mapper không có field kiểu collection cũng có thể bỏ luôn `nullValueCheckStrategy`.
- Các mapper là **interface phẳng**. Ở nơi một repository có một interface mapping dùng chung mà mapper tái sử dụng các phép chuyển đổi từ đó, hãy kế thừa nó thay vì cài lại các phép chuyển đổi ấy; nếu không có thì đừng tạo ra.
- Đặt tên method theo chiều: `to{TargetPascal}Request(...)` cho chiều service này→`{targetMicroservice}`, `to{ServicePascal}Response(Grpc{TargetPascal}…SuccessResponse)` cho chiều `{targetMicroservice}`→service này. Chỉ map những chiều mà use case cần (một luồng ghi có thể chỉ map request và lắp response ở chỗ khác). Một method có thể nhận thêm các tham số vô hướng, ví dụ `to{TargetPascal}Request(item, companyCd)`.

## Mapping field

- Dùng `@Mapping(target = "...", source = "...")` cho mọi field bị đổi tên. Những tên khác nhau giữa entity và proto (ví dụ `unit1` ↔ `unit1Qty`) phải được map tường minh; trông chờ vào việc tên trùng nhau tình cờ là một lỗi thường gặp.
- **Field `repeated` của gRPC**: protobuf phơi ra một `repeated foo` thành `getFooList()` / `addFoo(...)`. Với `collectionMappingStrategy = ADDER_PREFERRED`, hãy map collection nguồn thẳng vào tên logic — `@Mapping(target = "details", source = "soDetails")` — và MapStruct sẽ dùng adder được sinh ra. Đừng tự nhắm vào `...List`.
- Các phép chuyển đổi message/item lồng nhau có method mapper riêng của chúng (ví dụ `toAdvancedItem(SoEntity)`, `toAdvancedItemDetail(SoDetailEntity)`); MapStruct tự động nối các list tới chúng.

## Chuyển đổi tuỳ biến & mặc định

- Với các phép biến đổi giá trị (định dạng timestamp, enum, v.v.) hãy thêm một method `default` được đánh dấu `@Named("...")` và tham chiếu tới nó bằng `@Mapping(..., qualifiedByName = "...")`. Ví dụ: `localDateTimeToExclusionCheckString` định dạng `exclusioncheck` thành `yyyyMMddHHmmssSSS`.
- Các phép chuyển đổi cấu trúc thuần không có protobuf builder (ví dụ metadata → `GrpcCommonPaginationMetadata`) có thể là các method `default` dựng message trực tiếp.

## Nhắc nhở

- Đừng đặt logic nghiệp vụ trong mapper — chỉ định hình/chuyển đổi dữ liệu.
- Các kiểu message `com.cm.grpc.*` đến từ jar `cm-be-spec`; tuyệt đối không stub chúng. Các mapper impl được sinh ra nằm ở `build/generated/` — tuyệt đối không sửa tay.
