# Tính năng Kafka batch — tạo mới ban đầu

Hướng dẫn này dựng khung một tính năng batch kích hoạt bởi Kafka (`{domain}`). Quy tắc theo từng tầng nằm ở `../references/*.md`.

> **Ngoài phạm vi:** gRPC server (service này do Kafka điều khiển, không có gRPC server); các class `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` (jar bên ngoài — tuyệt đối không stub); `build/`; **test**.
> **Package:** khai báo các kiểu mới dưới `{basePackage}`, đọc từ khai báo `package` của các class đã có.

## Đầu vào cần thu thập trước

Hãy hỏi; đánh dấu những gì chưa rõ là "cần xác nhận / 要確認":

1. **ID & tên chức năng (機能ID・機能名)**.
2. **Topic / sự kiện Kafka** + các field của message (yếu tố kích hoạt).
3. **Dữ liệu hạ nguồn**: method gRPC nào của `{targetMicroservice}` cung cấp dữ liệu tổng hợp.
4. **(Các) bảng đích** + khóa upsert (cho `ON CONFLICT`) + danh sách cột.
5. Các tra cứu dữ liệu master cần cho phần tính toán.

## Luồng dữ liệu

```
Kafka ({topic}) → consumer (batch, ack-always)
  → service: gRPC client → {targetMicroservice} (aggregates)
            → compute (in memory)
            → UNNEST batch upsert → PostgreSQL ({database})
```

## Các file cần sinh

### 1. Kafka consumer — `consumer/<Name>Consumer.java`

Theo `../references/kafka-consumer.md` (Biến thể `ack-always`). Nhắc nhở then chốt: **ack bất kể thế nào** — kết quả đi vào process log, không thông qua việc Kafka gửi lại.

### 2. gRPC client tới {targetMicroservice} — `infrastructure/grpc/{targetLc}/<Tag>Client.java` + `Impl` (+ mapping)

Theo `../references/grpc-client.md`. Nhắc nhở then chốt: `@GrpcClient` nằm trong `GrpcClientConfiguration` (phơi lại dưới dạng `@Bean`), **tuyệt đối không** trên một field của `*ClientImpl`.

### 3. Service — `service/core/{domain}/<Tag>Service.java` + `Impl`

Theo `../references/service-layer.md`. Throw một exception typed `com.fw.core.exception.*` (kèm một `ErrorCodeEnum`) cho các lỗi miền, hoặc exception miền riêng của repository ở nơi repository đó có khai báo.

### 4. MyBatis mapper — `persistence/mapper/core/{domain}/<Name>Mapper.java` + `mybatis/mapper/{domain}/<Name>Mapper.xml`

Theo `../references/mybatis-mapper.md`. Map mọi cột một cách tường minh (camel-case đang TẮT).

### 5. Entity / model — `persistence/model/core/{domain}/<Name>Entity.java`

Các entity Lombok khớp với cột; thêm các model request/row/master theo nhu cầu của phần tính toán.

## Danh sách kiểm tra hoàn thành

1. Đã tạo consumer — ack-always.
2. Đã nối gRPC client — `@GrpcClient` chỉ ở trong `GrpcClientConfiguration` (không ở impl).
3. Đã tạo service — `@Transactional` cho PostgreSQL; throw một typed domain exception khi có lỗi miền.
4. MyBatis: UNNEST + `ON CONFLICT`; các cột được map tường minh (camel-case TẮT).
5. Các entity được map tường minh.
6. Không có gRPC server; không có test; không stub class bên ngoài; không sửa `build/`.
