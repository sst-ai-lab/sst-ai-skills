# cm-be-ms-common

Các skill dùng chung cho các microservice của SCM. Bật plugin này trong mọi repository `cm-be-ms-*`, cùng với `sst-common` và `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true } }
```

## Nội dung

| Skill | Mục đích |
| --- | --- |
| `scaffold-ms-feature` | Sinh một feature của microservice: gRPC service, Service, MyBatis mapper và XML, entity, MapStruct mapping; gRPC client gọi microservice khác; hoặc Kafka consumer |

Tiêu chuẩn phát triển backend và catalog framework nằm ở `sst-be-common`, plugin mà mọi repository Java đều bật.

## Đầu vào từ CLAUDE.md

Các lựa chọn riêng của từng service được giữ thành biến thể có tên, và chọn qua mục `## Policies` trong `CLAUDE.md` của repository: `service-pattern`, `kafka-ack`, `grpc-error-mapping`, `grpc-client-return`, `mapstruct-base`, `mybatis-xml-layout`, `unnest-on-conflict`.
