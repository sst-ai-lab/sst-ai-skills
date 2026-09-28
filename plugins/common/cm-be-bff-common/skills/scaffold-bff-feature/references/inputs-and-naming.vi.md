# Tạo mới backend (triển khai Java)

Khi đính kèm tài liệu thiết kế (backend), có thể tự động đọc được toàn bộ phân loại lớn, phân loại trung, phân loại nhỏ, tên chức năng, ID chức năng, danh sách API và tổng quan xử lý. Tiền đề là việc sinh tài liệu đặc tả OpenAPI và build đã hoàn tất.

## Tổng quan

Skill này tự động sinh các file triển khai Java phía BFF (① đến ⑦) dựa trên tài liệu thiết kế backend của SCM và các stub, model đã được sinh bằng `cm-be-spec`.
Phía microservice được sinh ở phía repository `{targetMicroservice}`.

**Điều kiện tiên quyết:**

- Việc sinh và publish stub, model từ tài liệu đặc tả OpenAPI trong repository `cm-be-spec` đã hoàn tất
- Artifact đã sinh `com.cm:cm-be-spec` có thể phân giải được từ JFrog Artifactory
  (`{repo}` đưa nó vào **dưới dạng jar phụ thuộc**. Không bao giờ sinh stub ở local)

> **Việc sinh stub, model không được thực hiện tại repository này.**
> `{repo}` là project Gradle (build bằng `./gradlew`, package manager của Node là pnpm), và
> sử dụng nguyên jar `com.cm:cm-be-spec` đã phân giải phụ thuộc.
> Về quy trình sinh và publish stub, model, hãy tham khảo README của `cm-be-spec`.

---

## Các điểm cần xác nhận với người dùng

**Hãy xác nhận các mục dưới đây.** Nếu tài liệu thiết kế được đính kèm, các mục ngoài mục có dấu ★ sẽ được trích xuất tự động từ tài liệu thiết kế.

| Mục                                          | Thời điểm xác nhận                               | Ví dụ                                 |
| --------------------------------------------- | -------------------------------------------- | ---------------------------------- |
| **★ Số ticket 菅次郎**                      | **Luôn xác nhận đầu tiên (không thể trích xuất từ tài liệu thiết kế)** | **123**                            |
| Phân loại lớn                                        | Trích xuất tự động từ tài liệu thiết kế                           | Web                                |
| Phân loại trung                                        | Trích xuất tự động từ tài liệu thiết kế                           | Core                               |
| Phân loại nhỏ                                        | Trích xuất tự động từ tài liệu thiết kế                           | Xuất hàng                               |
| Tên chức năng (tiếng Anh, PascalCase)                    | Trích xuất tự động từ tài liệu thiết kế                           | SoMainte                           |
| ID chức năng                                        | Trích xuất tự động từ tài liệu thiết kế                           | 003                                |
| Danh sách API (tên method, tổng quan xử lý)               | Trích xuất tự động từ tài liệu thiết kế                           | getSo / saveSo / deleteSo          |
| Microservice đích                          | Trích xuất tự động từ tài liệu thiết kế                           | {targetMicroservice} |

---

## Quy tắc đặt tên

### Quy tắc cơ bản

Từng thành phần code được dẫn xuất như sau.

| Tên biến           | Quy tắc dẫn xuất                                                                                 | Ví dụ (SoMainte)                                                                     |
| ---------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `[大分類Pascal]` | "Phân loại lớn" trong tài liệu thiết kế viết theo PascalCase                                                              | `Web`                                                                              |
| `[中分類Pascal]` | "Phân loại trung" tiếng Anh trong tài liệu thiết kế viết theo PascalCase                                                          | `Core`                                                                             |
| `[小分類Pascal]` | "Phân loại nhỏ" tiếng Anh trong tài liệu thiết kế viết theo PascalCase                                                          | `So`                                                                               |
| `[機能名Pascal]` | "Tên chức năng" trong tài liệu thiết kế viết theo PascalCase                                                              | `SoMainte`                                                                         |
| `[中分類lc]`     | Phân loại trung viết chữ thường                                                                             | `core`                                                                             |
| `[小分類lc]`     | Phân loại nhỏ viết chữ thường                                                                             | `so`                                                                               |
| `[機能名lc]`     | Tên chức năng viết theo lowerCamelCase                                                                    | `soMainte`                                                                         |
| `[タグ結合]`     | Nối trực tiếp `[大分類][中分類][小分類][機能名Pascal]`                                    | `WebCoreSoSoMainte`                                                                |
| `[API名Pascal]`  | Từng tên API viết theo PascalCase                                                                       | `GetSo` / `SaveSo` / `DeleteSo`                                                    |
| `[API名lc]`      | Từng tên API viết theo lowerCamelCase                                                                   | `getSo` / `saveSo` / `deleteSo`                                                    |
| `[operationId]`  | Nối `[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]` theo lowerCamelCase | `webCoreSoSoMainteGetSo` / `webCoreSoSoMainteSaveSo` / `webCoreSoSoMainteDeleteSo` |

### Mapping phân loại lớn

| Phân loại lớn trong tài liệu thiết kế | Mã | [大分類Pascal] | [大分類lc] |
| ------------ | ------ | -------------- | ---------- |
| Web          | `w`    | `Web`          | `web`      |
| Mobile     | `m`    | `Mobile`       | `mobile`   |
| Biểu mẫu/báo cáo         | `r`    | `Report`       | `report`   |
| EDI          | `e`    | `Edi`          | `edi`      |
| Dùng chung         | `c`    | `Common`       | `common`   |
| Batch       | `b`    | `Batch`        | `batch`    |
| API          | `a`    | `Api`          | `api`      |

### Mapping phân loại trung

| Phân loại trung trong tài liệu thiết kế   | Mã    | [中分類Pascal] | [中分類lc] |
| -------------- | --------- | -------------- | ---------- |
| Chức năng cốt lõi       | `001`     | `Core`         | `core`     |
| Chức năng tùy chọn | `002`     | `Option`       | `option`   |
| Chức năng cục bộ   | `100~999` | `Local`        | `local`    |

### Mapping phân loại nhỏ

| Phân loại nhỏ trong tài liệu thiết kế | Mã | [小分類Pascal] | [小分類lc]  |
| ------------ | ------ | -------------- | ----------- |
| FW           | `000`  | `Fw`           | `fw`        |
| Dùng chung         | `010`  | `Common`       | `common`    |
| Master       | `020`  | `Master`       | `master`    |
| Nhập hàng         | `030`  | `Rcv`          | `rcv`       |
| Xuất hàng         | `040`  | `So`           | `so`        |
| Quản lý đơn hàng | `050`  | `Order`        | `order`     |
| Tồn kho         | `060`  | `Inv`          | `inv`       |
| Thanh toán/hóa đơn         | `070`  | `Billcalc`     | `billcalc`  |
| Phí vận chuyển         | `080`  | `Carrycalc`    | `carrycalc` |
| Kiểm kê         | `090`  | `Stks`         | `stks`      |
| Giao hàng         | `100`  | `Tms`          | `tms`       |
| Kho ngoại quan         | `110`  | `Hozei`        | `hozei`     |
| ABL          | `120`  | `Abl`          | `abl`       |
| BI           | `130`  | `Bi`           | `bi`        |
| Log         | `140`  | `Log`          | `log`       |
| Xuất nhập (thu chi)         | `150`  | `Inout`        | `inout`     |
| Tồn kho hằng ngày     | `160`  | `Dailyinv`     | `dailyinv`  |
| Phân tích         | `170`  | `Analyze`      | `analyze`   |

### Quy tắc đặt tên cho các class tự động sinh bởi OpenAPI

Từ tags của tài liệu đặc tả OpenAPI, các class dưới đây được sinh tự động (`tags: Web / Core / So / SoMainte` → `[タグ結合] = WebCoreSoSoMainte`).

| Loại class                              | Quy tắc đặt tên                                                                | Ví dụ (SoMainte)                                                                                   |
| --------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| Interface API của BFF                 | `[タグ結合]Api`                                                         | `WebCoreSoSoMainteApi`                                                                           |
| Model request của BFF                    | `[title]` (title của component trong OpenAPI)                                   | `WebCoreSoSoMainteGetSoRequest`                                                                  |
| Model response của BFF                    | `[title]`                                                               | `WebCoreSoSoMainteGetSoSuccessResponse`                                                          |
| gRPC BlockingStub                       | `[タグ結合]ServiceBlockingStub` (inner class)                          | `WebCoreSoSoMainteServiceBlockingStub`                                                           |
| gRPC ServiceImplBase                    | `[タグ結合]ServiceImplBase` (inner class)                              | `WebCoreSoSoMainteServiceImplBase`                                                               |
| Message request của gRPC               | `Grpc[title]` (class nội bộ của OuterClass)                                 | `GrpcWebCoreSoSoMainteGetSoRequest`                                                              |
| Message response của gRPC               | `Grpc[title]` (class nội bộ của OuterClass)                                 | `GrpcWebCoreSoSoMainteGetSoSuccessResponse`                                                      |
| Message lồng của gRPC (header của nhóm đăng ký, v.v.) | `Grpc[タグ結合][API名Pascal][フィールド名Pascal]` (OuterClass độc lập) | `GrpcWebCoreSoSoMainteSaveSoHeader` (OuterClass: `GrpcWebCoreSoSoMainteSaveSoHeaderOuterClass`) |

> **⚠️ Lưu ý về message lồng của gRPC**: Với request thuộc nhóm đăng ký (ví dụ: `GrpcWebCoreSoSoMainteSaveSoRequest`), **các kiểu message lồng như field `so` không phải là class nội bộ**. Tham chiếu kiểu `[リクエストクラス].So` sẽ gây **lỗi biên dịch**. Hãy luôn kiểm tra kiểu thực tế bằng `javap` và import từ OuterClass tương ứng.
>
> ```java
> // ❌ 誤り（内部クラスは存在しない）
> GrpcWebCoreSoSoMainteSaveSoRequest.So grpcHeader = request.getSo();
>
> // ✅ 正しい（独立したOuterClassからインポート）
> import com.cm.grpc.GrpcWebCoreSoSoMainteSaveSoHeaderOuterClass.GrpcWebCoreSoSoMainteSaveSoHeader;
>
> GrpcWebCoreSoSoMainteSaveSoHeader grpcHeader = request.getSo();
> ```
