# Tạo mới backend — quy tắc tự động chuyển đổi từ tài liệu thiết kế, bảng tra nhanh mẫu triển khai

## Quy tắc tự động chuyển đổi từ tài liệu thiết kế

### Tên cột vật lý trong DB → tên field Java

| Quy tắc chuyển đổi                            | Ví dụ                              |
| ------------------------------------- | ------------------------------- |
| Snake case chữ in hoa → lowerCamelCase | `COMPANYCD` → `companyCd`       |
| Bỏ `_` và viết hoa ký tự tiếp theo      | `SHIP_SCH_DATE` → `shipSchDate` |
| Tiền tố `N_` được xử lý thành `n` | `N_KANRINO` → `nKanriNo`        |

### Mapping kiểu dữ liệu (tài liệu thiết kế → Java)

| Kiểu trong tài liệu thiết kế             | Kiểu Java                 | Ghi chú                   |
| ---------------------- | ---------------------- | ---------------------- |
| String                 | `String`               |                        |
| Long                   | `Long`                 |                        |
| Integer                | `Integer`              |                        |
| BigDecimal             | `java.math.BigDecimal` |                        |
| Ngày (YYYYMMDD)       | `String`               | Không cần chuyển đổi định dạng |
| Ngày giờ (YYYYMMDDHHmmss) | `String`               | Không cần chuyển đổi định dạng |
| Array<X>               | `List<X>`              |                        |

### Field bắt buộc của request/response

- Các mục "bắt buộc ✅" trong "tham số đầu vào" của tài liệu thiết kế → gắn annotation `@NotNull` / `@NotBlank`

---

## Bảng tra nhanh mẫu triển khai

| Loại API | Giá trị trả về của BFF Service             | Response gRPC (kiểu mà Client nhận được) |
| ------- | ------------------------------ | -------------------------------------- |
| Tìm kiếm    | `ListResponse<DetailResponse>` | Kiểu response gRPC                       |
| Đăng ký    | `void`                         | `Empty`                                |
| Cập nhật    | `void`                         | `Empty`                                |
| Xóa    | `void`                         | `Empty`                                |

Giá trị trả về và chính sách transaction ở phía microservice tuân theo quy ước microservice của repository đó.
