# Quy tắc tầng service

Áp dụng cho: `**/service/**/*.java`

Các microservice khác nhau về hình dạng service, transaction và xử lý lỗi. Những quy tắc đúng ở mọi nơi được đặt trước; sau đó mỗi cách làm được giữ lại dưới dạng một biến thể có tên. Hãy theo biến thể mà các class `*ServiceImpl` hiện có của repository này đang dùng; khi chưa có class nào, hãy hỏi người dùng.

## Quy tắc chung

- Tách **interface + `*Impl`**. Phần impl là `@Service` + `@RequiredArgsConstructor` (inject mapper/publisher dưới dạng field `private final`). Các service chỉ làm nhiệm vụ nạp dữ liệu có thể là class `@Service` cụ thể không có interface — xem các biến thể.
- Một method được tầng gRPC gọi; nó có thể nhận/trả về trực tiếp các kiểu message gRPC, hoặc làm việc với entity và dùng một MapStruct mapper cho response — hãy theo mẫu của các service lân cận trong cùng miền.
- Báo lỗi bằng cách throw một exception có kiểu từ `com.fw.core.exception.*` (kèm một `ErrorCodeEnum`) — ví dụ `ForbiddenException` / `BadRequestException` / `NotFoundException` — thay vì trả về null hoặc cờ trạng thái. Đừng bắt lỗi gRPC hạ nguồn chỉ để nuốt nó; hãy để nó nổi lên tới phần mapping `Status` gRPC trung tâm. Một repository có khai báo exception miền riêng của nó thì dùng exception đó — hãy theo những gì các service hiện có của nó throw.
- Tính kết quả trong bộ nhớ trước (ví dụ trong một map có khóa), rồi **lưu theo chunk** (kích thước là một hằng số có thể điều chỉnh) qua batch upsert của mapper — tránh gọi DB từng dòng trong vòng lặp.

## Transaction & proxy self-inject

- Đặt `@Transactional` lên **đơn vị công việc**, không nhất thiết ở điểm vào cấp cao nhất. Giữ transaction ngắn — làm phần tính toán trong bộ nhớ trước, rồi ghi theo lô.
- Một method `@Transactional` được gọi từ một method khác **của cùng bean** sẽ đi vòng qua proxy của Spring và không mở transaction. Hãy cho lời gọi đi qua một proxy self-inject:

```java
private XxxService self;
@Lazy @Autowired void setSelf(XxxService self) { this.self = self; }
// ...
self.transactionalMethod(...);   // đi qua proxy → @Transactional có hiệu lực
```

---

## Biến thể `crud-transactional`

Các service trong `service/core/<domain>` chứa logic nghiệp vụ. Một gRPC impl uỷ quyền cho một service; service điều phối các MyBatis mapper (dữ liệu) và MapStruct mapper (entity ↔ gRPC), rồi trả về kết quả.

### Hình dạng

- Tách **interface + `*Impl`**. Phần impl là `@Service` + `@RequiredArgsConstructor` (inject mapper/publisher dưới dạng field `private final`).
- Một method được tầng gRPC gọi; nó có thể nhận/trả về trực tiếp các kiểu message gRPC, hoặc làm việc với entity và dùng một MapStruct mapper cho response — hãy theo mẫu của các service lân cận trong cùng miền.

### Transaction

- Đánh dấu mọi method có ghi (insert/update/delete, thay đổi trạng thái nhiều bước) bằng `@Transactional` (`org.springframework.transaction.annotation.Transactional`). Truy vấn chỉ đọc thì không cần.
- Phát các sự kiện miền Kafka (ví dụ qua `{eventPublisher}`) **sau khi** lưu thành công, bên trong cùng method có transaction, để sự kiện phản ánh trạng thái đã commit.

### Xử lý lỗi — throw exception miền có kiểu

Throw các exception từ `com.fw.core.exception.*` kèm một `ErrorCodeEnum`; tuyệt đối không trả về null/cờ lỗi, và không bắt-rồi-nuốt (một advice trung tâm map chúng sang `Status` gRPC):

- **`ForbiddenException(ErrorCodeEnum.REQUEST_NOT_PERMITTED)`** — người gọi không có quyền / không có phạm vi quyền.
- **`NotFoundException(ErrorCodeEnum.RESOURCE_NOT_FOUND)`** — không tìm thấy dòng đích.
- **`BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors)`** — dữ liệu vào không hợp lệ. Hãy dựng các `InvalidRequestExceptionRecord` ở mức field (tên field + giá trị + thông điệp) để client nhận được chi tiết theo từng field; xem helper `invalidBody(...)` trong `{referenceServiceImpl}`.
- **`ConflictException(ErrorCodeEnum.SQL_UNIQUE_VIOLATION)`** — lỗi optimistic-lock / vi phạm unique (xem bên dưới).

### Optimistic locking & audit

- Các dòng nghiệp vụ mang một timestamp `exclusioncheck`. Khi update, truyền `exclusioncheck` kỳ vọng và **so sánh số dòng bị ảnh hưởng do mapper trả về với số dòng bạn dự định update**; nếu khác nhau, throw `ConflictException(SQL_UNIQUE_VIOLATION)` — một tiến trình ghi khác đã thay đổi dòng đó.
- Đặt các cột audit (`updusercd` / `updusername` / `updterminalcd`, và `add*` khi insert) từ chủ thể đã phân giải. Phân giải ngữ cảnh người dùng/audit hiện tại qua `RequestContextHolder.getContext()` (`com.fw.grpc.core.dto`), dự phòng bằng `userId` của request / `"SYSTEM"`.
- Dựng/vá entity bằng Lombok builder; khi vá, hãy giữ lại các field mà request không thay đổi thay vì ghi đè chúng bằng null.

---

## Biến thể `ingest-no-transaction`

Các service ở tầng `service/` lưu theo lô các danh sách entity đã được deserialize vào
database bằng `UNNEST` của PostgreSQL. Chúng được người gọi (ví dụ một Kafka consumer) gọi
với các entity đã được trích xuất sẵn — service chỉ điều phối việc lưu trữ.

### Mẫu lưu trữ

- **Chia chunk** dữ liệu vào lớn (kích thước chunk là một hằng số có thể điều chỉnh) và gọi
  `batchUpsert…Unnest(params)` của mapper một lần cho mỗi chunk, trong đó `params` chứa một mảng có kiểu cho mỗi
  cột (được dựng bởi một params builder).
- Ghi vào các **bảng độc lập song song** qua `CompletableFuture.runAsync(..., executor)`
  dùng một `Executor` được quản lý và inject vào (ví dụ `applicationTaskExecutor` của Spring), rồi
  `CompletableFuture.allOf(...).join()`.
- Bỏ qua một bảng khi danh sách entity của nó rỗng.

### Không dùng transaction theo thiết kế

- **Không thêm `@Transactional`.** Mỗi chunk tự auto-commit độc lập; tính đúng đắn đến từ
  **upsert idempotent ở tầng lưu trữ**, không phải từ một transaction bao ngoài — nhờ vậy
  xử lý lại cùng dữ liệu vào là an toàn.
- Vì không có transaction, đừng đưa vào đây các bất biến liên bảng đòi hỏi
  tính nguyên tử — hãy giữ upsert của mỗi bảng độc lập.

### Chung

- Đánh dấu bằng `@Service`; inject các mapper và executor làm dependency của constructor.
- Giữ việc trích xuất/mapping payload ra ngoài service (làm ở phía người gọi hoặc trong params
  builder); service chỉ điều phối việc chia chunk, song song hoá, và gọi mapper.
- Log số lượng theo từng chunk (kích thước chunk, số dòng đã insert) ở mức debug để theo dõi thông lượng.

---

## Biến thể `gateway-no-db`

`service/` chứa các **service điều phối**. **Service này không có database** — một service điều phối với tới `{targetMicroservice}` qua (các) gRPC client và định hình kết quả; nó không bao giờ chạy SQL, transaction, hay optimistic locking.

### Hình dạng

- Một service điều phối là một cặp **interface + `*Impl`**; phần impl là `@Service` + `@RequiredArgsConstructor` với các dependency `private final` — (các) gRPC client `{targetMicroservice}` của nó, và một mapper chỉ khi nó tự định hình response.
- Một method của service thường: kiểm tra dữ liệu vào → gọi (các) client hạ nguồn → map/tổng hợp kết quả → trả về message của service này. Chuyển tiếp mỏng (thin pass-through) là bình thường và ổn.
- **Không `@Transactional`** (không có datasource). Đừng đưa JDBC/MyBatis vào đây — mọi dữ liệu, đọc và ghi, đều đi qua gRPC client.

### Lỗi

- Báo lỗi bằng cách throw một exception có kiểu từ `com.fw.core.exception.*` (kèm một `ErrorCodeEnum`) — ví dụ `ForbiddenException` / `BadRequestException` / `NotFoundException` — thay vì trả về null hoặc cờ trạng thái. Đừng bắt lỗi gRPC hạ nguồn chỉ để nuốt nó; hãy để nó nổi lên tới phần mapping `Status` gRPC trung tâm.

---

## Biến thể `search-ingest`

> Ở nơi một repository còn truy vấn thêm một nơi lưu dữ liệu phân tích bên ngoài, phần điều phối và kiểm tra identifier mà việc đó đòi hỏi không thuộc phạm vi tài liệu này.

Các service trong `service/core/<domain>` chứa logic nghiệp vụ. Một gRPC impl hoặc Kafka consumer uỷ quyền vào đây; service điều phối các MyBatis mapper (PostgreSQL) và MapStruct mapping (row/entity ↔ gRPC), rồi trả về kết quả.

### Hình dạng

- **Các search service** tách **interface + `*Impl`**; phần impl là `@Service` + `@RequiredArgsConstructor` (dependency dạng `private final`).
- **Các ingest service** có thể là class `@Service` cụ thể (không có interface). Hãy theo phong cách lân cận trong miền thay vì cố ép phải có interface.
- Một method có thể nhận/trả về trực tiếp các kiểu message gRPC, hoặc làm việc với entity + một MapStruct mapping cho response — hãy theo mẫu của các service gần đó.

### Transaction

- Đánh dấu mọi method **ghi vào PostgreSQL** (insert/update) bằng `@Transactional` (`org.springframework.transaction.annotation.Transactional`). Truy vấn chỉ đọc thì không cần.
- Service này **không có optimistic-locking bằng `exclusioncheck`**; đừng thêm vào trừ khi thiết kế yêu cầu.

### Kiểm tra dữ liệu vào & an toàn

- Chuẩn hoá phân trang với giá trị mặc định hợp lý khi thiếu (`page = 1`, `size = 10`).
- Cắt/làm sạch các field chuỗi đầu vào về đúng độ dài cột trước khi lưu.

### Audit & ngữ cảnh request

- Phân giải chủ thể/công ty từ `RequestContextHolder.getContext()` (`com.fw.grpc.core.dto`) khi có, dự phòng bằng một giá trị mặc định hợp lý (ví dụ công ty `"01"` cho tìm kiếm, người dùng `"SYSTEM"` cho ingest). Đặt các field audit `add*` từ chủ thể đã phân giải.

### Xử lý lỗi

- Hãy throw các exception có kiểu `com.fw.core.exception.*` (`BadRequestException` / `ForbiddenException` / `NotFoundException`): advice toàn cục map mỗi exception sang `Status` gRPC tương ứng và mang mã lỗi cùng các record ở mức field tới phía gọi (xem [grpc-server.md](grpc-server.md)). Code hiện có đôi khi throw `IllegalArgumentException` cho một vấn đề kiểm tra dữ liệu và để gRPC impl tự chuyển đổi — đừng mở rộng mẫu đó trong code mới, vì advice báo một exception chưa được map là `INTERNAL`.
