# sst-be-common

Tiêu chuẩn phát triển backend và catalog framework, dùng chung cho mọi repository Java của SST: các service `cm-be-*`, các thư viện framework `sst-fw-be-*` và `cm-print-agent`. Bật cùng với `sst-common`, và cùng plugin theo vai trò của repository (`cm-be-bff-common`, `cm-be-ms-common` hoặc `sst-fw-be-common`).

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true } }
```

## Nội dung

| Skill | Mục đích |
| --- | --- |
| `check-conventions` | Tiêu chuẩn cho code Java và MyBatis mapper XML đã thay đổi (バックエンド開発規約), được `/sst-common:review-code` chạy |
| `use-sst-framework` | Catalog của framework nội bộ `sst-fw-be-*`, để dùng lại class đã có |

Phần sinh code nằm ở các plugin theo vai trò: `cm-be-bff-common:scaffold-bff-feature` cho phía BFF, `cm-be-ms-common:scaffold-ms-feature` cho microservice.

## Chưa viết

Phần quy ước chung xuyên stack trong cm-docs `19.開発規約整備/common/` — đặt tên DB và thuật ngữ nghiệp vụ, message ID và error code, feature ID, timezone, transaction, giới hạn kích thước file, APM — hiện chưa có trong `check-conventions`.
