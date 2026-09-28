# Quy tắc Kafka consumer

Áp dụng cho: `**/consumer/**/*.java` hoặc `**/infrastructure/message/**/*.java` — hãy dùng package mà repository này đang đặt các consumer của nó.

Consumer là một điểm vào (không phải gRPC) kích hoạt xử lý ở tầng service. Hình dạng của listener giống nhau ở mọi nơi, nhưng các repository khác nhau ở chỗ **khi nào ack và có rethrow hay không**. Mỗi chính sách ack được giữ lại dưới dạng một biến thể có tên bên dưới. Hãy theo biến thể mà các consumer hiện có của repository này đang dùng; khi chưa có, hãy hỏi người dùng.

## Quy tắc chung

- `@Component` + `@RequiredArgsConstructor`; `@KafkaListener(topics = <Topic constant>, groupId = "${spring.kafka.consumer.group-id}")`.
- **Chế độ batch** (`List<String> messages`) với **manual ack** (`Acknowledgment`). Một số repository lại nhận `List<ConsumerRecord<String, Object>>` — xem các biến thể.
- Phân tích từng message một cách phòng vệ: xử lý **JSON bị encode hai lần** (thử `readValue(json, String.class)` trước, dự phòng bằng chuỗi thô), rồi deserialize sang kiểu message. Hãy log-và-bỏ qua một message không phân tích được thay vì làm hỏng cả lô.
- Chuyển message sang DTO của service và uỷ quyền công việc thực sự cho service; consumer **không chứa logic nghiệp vụ và không có SQL**.

## Biến thể `ack-always`

- **Chế độ batch** (`List<String> messages`) + **manual ack** (`Acknowledgment`).
- **Ack bất kể thành công hay thất bại** — kết quả được ghi vào process log, không thông qua việc Kafka gửi lại. (Khác với các consumer rethrow để buộc gửi lại; ở đây process log là nguồn sự thật.) Bắt exception quanh cả lô, log + commit-failed, rồi `ack.acknowledge()`.
- Phân tích phòng vệ: xử lý **JSON bị encode hai lần** (`readValue(json, String.class)` trước, dự phòng bằng chuỗi thô), rồi deserialize sang kiểu message. Log-và-bỏ qua một message không phân tích được; tiếp tục cả lô.

## Biến thể `rethrow`

- **Chế độ batch** (`List<String> messages`) với **manual ack** (`Acknowledgment`): xử lý mọi message, rồi `ack.acknowledge()` một lần ở cuối. Khi có exception, hoàn tất việc ghi log lỗi và **rethrow** để Kafka gửi lại — đừng nuốt lỗi.

## Biến thể `rethrow-batch-fatal`

> Việc điều phối một lô theo field `messageType` (`INIT` / `DETAIL` / `COMMIT`) là đặc thù cho việc nạp process-log và không thuộc phạm vi các quy tắc này.

### Hình dạng listener

- `@Component` + `@RequiredArgsConstructor` + `@Slf4j`; inject `*Service` đích và một `ObjectMapper` dưới dạng `private final`.
- `@KafkaListener(topics = {topicConstantClass}.<TOPIC>, groupId = "${spring.kafka.consumer.group-id}", concurrency = "...")` — các hằng topic đến từ `{topicConstantClass}`. Đặt `concurrency` khớp với số partition của topic.
- **Chế độ batch** (`List<String> messages`) + **manual ack** (`org.springframework.kafka.support.Acknowledgment`). Container bị buộc sang batch + manual-ack trong `KafkaConfiguration` — đừng cấu hình lại chế độ ack trên listener.

### Hợp đồng xử lý

- Phân tích từng message một cách **phòng vệ**: payload là **JSON bị encode hai lần** — `objectMapper.readValue(json, String.class)` trước để bóc lớp, rồi deserialize sang kiểu message (`com.fw.core.message.*`). Log-và-bỏ qua một message không phân tích được (trả về `null`, lọc nó ra); tuyệt đối không để một message lỗi làm hỏng cả lô.
- Khi thứ tự quan trọng, hãy sắp xếp lô đã phân tích trước khi xử lý.
- **Không có logic nghiệp vụ / không truy cập DB trong consumer** — hãy dựng `*Message` có kiểu (Lombok builder) và chuyển cho service.
- **Ack sau khi lô đã được xử lý.** Các lỗi xử lý ở mức từng message được bắt, log, và bỏ qua (lô vẫn tiếp tục); một lỗi chí tử ở mức lô được rethrow **trước** `ack.acknowledge()` để lô được gửi lại. Hãy giữ `ack.acknowledge()` là bước thành công cuối cùng.

## Biến thể `ack-after-success`

Các Kafka consumer dưới `infrastructure/message/consumer` là điểm vào nạp dữ liệu:
chúng nhận sự kiện và chuyển cho tầng service để lưu theo lô.
Hãy giữ chúng mỏng — không SQL và không quy tắc nghiệp vụ ở đây.

### Hình dạng listener

- Dùng một listener **batch** với **manual ack**: `@KafkaListener` nhận
  `@Payload List<ConsumerRecord<String, Object>> records` và một tham số
  `Acknowledgment`, gắn với batch container factory.
- Với một lô rỗng, gọi `acknowledge()` và return sớm.
- **Chỉ acknowledge sau khi** lô đã được xử lý và chuyển cho service
  thành công — tuyệt đối không ack trước khi xử lý. Nếu việc lưu thất bại, **đừng** ack;
  hãy để lô được gửi lại.

### Xử lý payload

- Giá trị của một record có thể đến dưới dạng `String`, `byte[]`, hoặc một map đã được phân tích sẵn tùy
  cấu hình deserializer — hãy **chuẩn hoá** nó trước (phân tích `String`/`byte[]` qua
  `ObjectMapper.readTree`; cho các giá trị đã phân tích đi qua).
- Một message có thể ứng với **một hoặc nhiều** kiểu entity qua
  `objectMapper.convertValue(normalized, XxxEntity.class)`. Hãy cấu hình entity bỏ qua
  các property không biết để chấp nhận được các field thừa.
- Sau khi chuyển đổi, **canh các khóa bắt buộc** (ví dụ chỉ giữ một entity khi các field
  khóa chính của nó khác null) để bỏ qua các payload thiếu hoặc không liên quan.

### Độ bền vững

- Bọc việc deserialize từng record trong try/catch và **log-và-bỏ qua** một record sai định dạng
  (log topic/partition/offset/key) — một message lỗi không được làm hỏng cả lô.
- Đừng dựa vào thứ tự hay việc giao đúng một lần. Hãy giả định **ít nhất một lần**: việc lưu
  phải idempotent, để việc giao trùng là an toàn. (Bản thân cơ chế idempotent
  thuộc về tầng lưu trữ, không phải ở đây.)
- Giữ consumer chỉ gồm: chuẩn hoá → chuyển đổi → canh khóa → uỷ quyền cho tầng service.
