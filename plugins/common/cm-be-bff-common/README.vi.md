# cm-be-bff-common

Các skill dùng chung cho các service BFF của SCM. Bật plugin này trong mọi repository `cm-be-bff-*`, cùng với `sst-common` và `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-bff-common@sst-ai-skills": true } }
```

## Nội dung

| Skill | Mục đích |
| --- | --- |
| `scaffold-bff-feature` | Sinh phía BFF của một feature (Controller -> Service -> gRPC client) từ tài liệu thiết kế; phía microservice được sinh bằng `cm-be-ms-common:scaffold-ms-feature` trong repository của microservice |

Tiêu chuẩn phát triển backend và catalog framework nằm ở `sst-be-common`, plugin mà mọi repository Java đều bật.

## Đầu vào từ CLAUDE.md

`scaffold-bff-feature` đọc `## Service profile` và `## Policies` trong `CLAUDE.md` của repository, và hỏi người dùng khi thiếu giá trị. Xem `SKILL.md` của skill để có danh sách chính xác.
