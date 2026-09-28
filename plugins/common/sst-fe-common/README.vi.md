# sst-fe-common

Tiêu chuẩn phát triển frontend và catalog `sst-fw-web`, dùng chung cho mọi repository Vue của SST: hai ứng dụng web `cm-fe-web`, `cm-fe-manual-web`, và hai repository framework `sst-fw-web`, `sst-fw-storybook`. Bật cùng với `sst-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-fe-common@sst-ai-skills": true, "cm-fe-web-common@sst-ai-skills": true } }
```

## Nội dung

| Skill | Mục đích |
| --- | --- |
| `check-conventions` | Tiêu chuẩn cho `.vue`, composable và tầng API đã thay đổi (フロントエンド開発規約) cùng checklist của dự án; khi mâu thuẫn thì tiêu chuẩn được ưu tiên |
| `use-sst-framework` | Quy ước Vue và API client, cùng catalog component và utility của `@sst-cm/sst-fw-web` |

Phần sinh màn hình nằm ở plugin theo vai trò `cm-fe-web-common:scaffold-screen`, chỉ hai ứng dụng web bật plugin này.

## Chưa viết

Phần quy ước chung xuyên stack trong cm-docs `19.開発規約整備/common/` — thuật ngữ nghiệp vụ trong API type, message ID cho i18n key, feature ID, timezone, giới hạn kích thước file, APM — hiện chưa có trong `check-conventions`.
