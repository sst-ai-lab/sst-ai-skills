# sst-mobile-common

Tiêu chuẩn phát triển mobile và các command dùng chung của mọi repository Flutter của SST: `cm-fe-mobile`, `sst-fw-mobile` và `sst-fw-widgetbook`. Bật cùng với `sst-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-mobile-common@sst-ai-skills": true } }
```

## Nội dung

| Skill / command | Mục đích |
| --- | --- |
| `/sst-mobile-common:create-comment <file>` | Thêm comment Dart tiếng Nhật vào một file, không thay đổi code |

## Chưa viết

`check-conventions` cho Dart. Nguồn đã có: cm-docs `frontend_mobile/モバイル開発規約_ver1.md` (537 dòng), cùng phần quy ước chung xuyên stack trong `19.開発規約整備/common/`. Cho tới khi có skill này, `/sst-common:review-code` chạy trong repository Flutter sẽ không tìm thấy tiêu chuẩn nào.
