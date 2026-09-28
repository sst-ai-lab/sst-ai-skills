# sst-common

Dùng chung cho mọi repository của SST, bất kể stack. Bật plugin này bên cạnh plugin stack của repository.

```json
{
  "enabledPlugins": {
    "sst-common@sst-ai-skills": true,
    "sst-be-common@sst-ai-skills": true
  }
}
```

## Nội dung

| Thành phần | Mục đích |
|---|---|
| `commands/review-code` | `/sst-common:review-code [scope]` — review chỉ đọc các thay đổi trong phạm vi, theo mọi tiêu chuẩn mà các plugin đang bật cung cấp |

## Tiêu chuẩn lấy từ đâu

Plugin này không có tiêu chuẩn riêng. Command load mọi skill có tên bắt đầu bằng `check-` trong các plugin khác đang bật và áp dụng từng skill cho những file mà description của nó bao quát:

| Plugin | Skill | Bao quát |
|---|---|---|
| `sst-be-common` | `check-conventions` | Java, MyBatis mapper XML (バックエンド開発規約) |
| `sst-fe-common` | `check-conventions` | `.vue`, `use*.ts`, `*Api.ts`, `*ApiType.ts` (フロントエンド開発規約 + checklist) |
| `sst-mobile-common` | `check-conventions` | Dart (モバイル開発規約) — chưa viết |
| `cm-be-spec` | `check-conventions` | `.tsp`, OpenAPI YAML — chưa viết |
| `cm-devops-common` | `check-conventions` | `.tf`, `.hcl` — chưa tạo plugin |

Một repository bật `sst-common` mà không có plugin stack nào thì không có tiêu chuẩn nào, và command sẽ báo như vậy thay vì review.

Để thêm tiêu chuẩn, xem [Tiêu chuẩn review](../../../CONTRIBUTING.vi.md#47-tiêu-chuẩn-review) trong `CONTRIBUTING.vi.md`.
