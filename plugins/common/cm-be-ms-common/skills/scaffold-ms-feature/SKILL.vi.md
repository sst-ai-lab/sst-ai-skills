---
name: scaffold-ms-feature
description: Dựng khung một tính năng phía microservice (MS) — gRPC service impl, Service, MyBatis mapper + XML, entity, và MapStruct mapping; hoặc một gRPC client gọi sang microservice khác; hoặc một Kafka batch consumer với UNNEST upsert theo chunk. Không sinh test. Dùng khi thêm hoặc mở rộng một tính năng bên trong repository microservice Spring Boot (cm-be-ms-*), và khi sửa tầng service của nó (`**/service/**/*.java`), MyBatis mapper XML (`**/mybatis/**/*.xml`), Kafka consumer (`**/consumer/**/*.java`, `**/infrastructure/message/**/*.java`), gRPC client (`**/infrastructure/grpc/**/*.java`), gRPC server impl (`**/grpc/**/*.java`) hoặc MapStruct mapping (`**/infrastructure/mapping/**/*.java`).
---

# Skill backend (phía microservice)

## Khi nào dùng

- Thêm hoặc mở rộng một tính năng **bên trong microservice này**: một gRPC endpoint mới, một truy vấn, hoặc một luồng ghi.
- Thêm hoặc mở rộng một tính năng **nạp sự kiện (event-ingest)**: tiêu thụ một sự kiện Kafka và batch-upsert nó vào PostgreSQL.
- Thêm một batch được kích hoạt bởi Kafka, lấy dữ liệu từ một microservice khác qua gRPC, tính toán trong bộ nhớ, và lưu vào PostgreSQL.
- Thêm một tính năng gRPC được phục vụ bằng cách gọi một microservice khác (`{targetMicroservice}`) rồi biến đổi lại kết quả.

## Phạm vi

- **Sinh ra:** gRPC service impl (`@GrpcService`), Service interface + `*Impl`, MyBatis mapper interface + `*Mapper.xml`, entity/model tầng lưu trữ, và MapStruct mapping (entity ↔ gRPC). Phát sự kiện Kafka khi thiết kế yêu cầu. Tùy theo loại điểm vào: một Kafka **batch** consumer (manual ack), gRPC **client** gọi sang microservice khác (`*Client` + `*ClientImpl`) cùng với `@Bean` stub của nó trong `GrpcClientConfiguration`, phần dựng mảng của `UnnestParamsBuilder`.
- **KHÔNG sinh ra:** test; proto/gRPC stub hay DTO dùng chung (chúng đến từ các jar nội bộ `sst-fw-be-grpc` / `cm-be-spec` — coi như bên ngoài); các class `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` (jar sinh tự động bên ngoài — tuyệt đối không stub).

## Cách dùng

Chọn template theo loại điểm vào của tính năng, rồi đọc quy tắc tầng cho từng file bạn sinh ra.

| Mẫu | File | Mô tả |
| --- | --- | --- |
| Tạo mới ban đầu — gRPC server + CRUD | `templates/crud-grpc-server.md` | Suy ra cách đặt tên (大分類 / 中分類 / 小分類), bản đồ file, và các template code để dựng khung một tính năng MS từ thiết kế (gRPC impl, Service, MyBatis mapper + XML, entity, MapStruct, sự kiện Kafka tùy chọn) |
| Tạo mới ban đầu — gRPC gateway (server + client gọi sang MS khác, không có DB) | `templates/grpc-gateway.md` | Cách đặt tên, bản đồ file, và các template code để dựng khung một tính năng gateway (gRPC impl, client tới hạ nguồn + `@Bean` stub, MapStruct, service điều phối) |
| Tạo mới ban đầu — Kafka ingest (UNNEST upsert) | `templates/unnest-ingest.md` | Cách đặt tên, bản đồ file, và các template code để dựng khung một tính năng ingest (consumer, service, UNNEST mapper + XML, params builder, entity) |
| Tạo mới ban đầu — Kafka batch (gRPC fetch → tính toán → UNNEST) | `templates/kafka-batch.md` | Các bước dựng khung một tính năng batch kích hoạt bởi Kafka |
| Quy tắc tầng — Service | `references/service-layer.md` | Sửa `**/service/**/*.java` |
| Quy tắc tầng — MyBatis | `references/mybatis-mapper.md` | Sửa `**/mybatis/**/*.xml` |
| Quy tắc tầng — Kafka consumer | `references/kafka-consumer.md` | Sửa `**/consumer/**/*.java` hoặc `**/infrastructure/message/**/*.java` |
| Quy tắc tầng — gRPC client | `references/grpc-client.md` | Sửa `**/infrastructure/grpc/**/*.java` |
| Quy tắc tầng — gRPC server | `references/grpc-server.md` | Sửa `**/grpc/**/*.java` |
| Quy tắc tầng — MapStruct | `references/mapstruct-mapping.md` | Sửa `**/infrastructure/mapping/**/*.java` |

## Các giá trị cần chốt trước khi sinh code

Đọc mọi giá trị từ chính repository đang làm việc: các khai báo `package`, các class đã có, `application*.yml`. Chỉ hỏi người dùng khi đó là một lựa chọn mà repository không thể trả lời, ví dụ microservice hạ nguồn của một tính năng gateway mới.

Với mỗi chính sách, hãy theo đúng những gì repository đang làm — xem một service impl, consumer, mapper XML hoặc class mapping cùng loại đã có. Chỉ hỏi người dùng khi repository chưa có file nào như vậy.

| Placeholder / chính sách | Ý nghĩa |
| --- | --- |
| `{basePackage}` | Package gốc của microservice này (`{basePackagePath}` là dạng thư mục của nó) |
| `{middleCategory}` | 中分類 của service này (Pascal) |
| `{ServicePascal}` / `{serviceLc}` | Tiền tố message/stub của service này (mẫu gateway) |
| `{targetMicroservice}` | Microservice hạ nguồn được gọi qua gRPC (`{TargetPascal}` / `{targetLc}` = tiền tố message/stub và đoạn package của nó) |
| `{grpcChannel}` / `{port}` | Tên gRPC channel của microservice hạ nguồn và cổng mặc định của nó |
| `{topic}` / `{topicConstantClass}` / `{database}` | Topic Kafka kích hoạt batch; class chứa các hằng topic; tên database PostgreSQL |
| `{domain}` | Đoạn package của miền |
| `{eventPublisher}`, `{referenceServiceImpl}`, `{referenceMapperXml}` | Các class/file đã có trong repository này được dùng làm mẫu |
| Chính sách `service-pattern` | Biến thể tầng service trong `references/service-layer.md` |
| Chính sách `kafka-ack` | Biến thể ack trong `references/kafka-consumer.md` |
| Chính sách `mybatis-xml-layout`, `unnest-on-conflict` | Các biến thể trong `references/mybatis-mapper.md` |
| Chính sách `grpc-client-return` | Biến thể trong `references/grpc-client.md` |
| Chính sách `grpc-error-mapping` | Biến thể trong `references/grpc-server.md` |
| Chính sách `mapstruct-base` | Biến thể trong `references/mapstruct-mapping.md` |

## Liên quan

- Trước khi tự viết một utility, exception, validation hay DTO của riêng bạn, hãy kiểm tra xem framework dùng chung (`sst-fw-be-*`) đã cung cấp nó chưa, và tái sử dụng.
