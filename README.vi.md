# SST AI Skills

Repository này là marketplace plugin Claude Code của SST: nơi quản lý và phát hành các plugin chứa skill cho các repository SST, gồm skill chung cho cả một stack và skill riêng của từng repository. Các skill này cung cấp cho Claude tiêu chuẩn phát triển (開発規約) và các framework nội bộ `sst-fw-*`.

**Trong trang này**

- [1. Bắt đầu nhanh](#1-bắt-đầu-nhanh)
  - [1.1 Dùng một skill](#11-dùng-một-skill)
- [2. Có những gì](#2-có-những-gì)
  - [2.1 Chưa viết](#21-chưa-viết)
- [3. Thêm skill vào một repository](#3-thêm-skill-vào-một-repository)
  - [3.1 Tình trạng triển khai](#31-tình-trạng-triển-khai)
- [4. Xử lý sự cố](#4-xử-lý-sự-cố)
- [5. Cách hoạt động](#5-cách-hoạt-động)

Để sửa hoặc thêm skill, xem [CONTRIBUTING.vi.md](CONTRIBUTING.vi.md).

## 1. Bắt đầu nhanh

Làm theo các bước này trong một repository đã cài đặt plugin từ marketplace này, ví dụ [`cm-be-bff-api`](https://github.com/suzuyo-cm/cm-be-bff-api/tree/feature/SCM-535088) (xem [Tình trạng triển khai](#31-tình-trạng-triển-khai)).

**Trước khi bắt đầu**

- Đã cài Claude Code, trên terminal hoặc trong VS Code.
- Đã cài Node.js 22 trở lên. Kiểm tra bằng `node --version`. Việc đồng bộ plugin chạy bằng Node.js.
- Bạn có quyền đọc repository private `suzuyo-cm/sst-ai-skills`. Nếu lệnh `git ls-remote git@github.com:suzuyo-cm/sst-ai-skills.git` bị lỗi, hãy kiểm tra lại quyền truy cập vào repository.

**Các bước**

1. Mở Claude Code trong repository và gửi một tin nhắn bất kỳ.

   Các skill được cài ở chế độ nền. Lần đầu tiên, bạn sẽ thấy:

   ```text
   Claude plugins synced:
     • sst-common@sst-ai-skills: installed 0.1.0
     • sst-be-common@sst-ai-skills: installed 0.3.0
   Run /reload-plugins to load the changes in this session.
   ```

2. Chạy `/reload-plugins`.

3. Review thay đổi của bạn:

   ```text
   /sst-common:review-code
   ```

   Claude hỏi cần review những thay đổi nào, rồi liệt kê từng chỗ vi phạm tiêu chuẩn, kèm quy tắc và cách sửa. Claude không sửa file nào.

Cài đặt hoàn tất. Các skill được cập nhật tự động mỗi khi Claude Code khởi động.

### 1.1 Dùng một skill

Không cần ghi nhớ tên skill. Hãy mô tả công việc, Claude sẽ chọn skill phù hợp:

```text
Create the BFF endpoint for the owner shipment search, from the attached design document.
```

Để tự chọn skill, gõ `/` trong Claude Code rồi chọn trong danh sách, ví dụ `/cm-be-bff-common:scaffold-bff-feature`.

## 2. Có những gì

Plugin được chia làm bốn lớp. Mỗi repository bật một plugin ở mỗi lớp áp dụng cho nó, nên chỉ nhận đúng những skill cần dùng.

| Lớp | Chứa gì | Plugin |
|---|---|---|
| Mọi repository | command review | `sst-common` |
| Stack | tiêu chuẩn phát triển (開発規約) và catalog framework | `sst-be-common`, `sst-fe-common`, `sst-mobile-common` |
| Vai trò | sinh code cho loại repository đó | `cm-be-bff-common`, `cm-be-ms-common`, `cm-fe-web-common`, `sst-fw-be-common` |
| Một repository | thứ chỉ repository đó cần | `cm-be-bff-web`, `cm-be-spec`, `cm-be-ms-log`, `cm-be-ms-dailyinv`, `sst-fw-be-core` |

**Mọi repository** — `sst-common`

| Command | Dùng để |
|---|---|
| `/sst-common:review-code` | Review thay đổi của bạn theo mọi tiêu chuẩn mà các plugin repository đang bật cung cấp. |

**Java: `cm-be-*`, `sst-fw-be-*`, `cm-print-agent`** — [`sst-be-common`](plugins/common/sst-be-common/README.md)

| Skill | Dùng để |
|---|---|
| `check-conventions` | Kiểm tra code Java và MyBatis XML theo バックエンド開発規約. `/sst-common:review-code` dùng skill này. |
| `use-sst-framework` | Tìm những gì framework `sst-fw-be-*` đã có, trước khi tự viết. |

**BFF: `cm-be-bff-*`** — [`cm-be-bff-common`](plugins/common/cm-be-bff-common/README.md)

| Skill | Dùng để |
|---|---|
| `scaffold-bff-feature` | Sinh phía BFF của một feature từ tài liệu thiết kế: Controller, Service, gRPC client. |

**Microservice: `cm-be-ms-*`** — [`cm-be-ms-common`](plugins/common/cm-be-ms-common/README.md)

| Skill | Dùng để |
|---|---|
| `scaffold-ms-feature` | Sinh một feature của microservice: gRPC service, Service, MyBatis mapper, MapStruct mapping, hoặc Kafka consumer. |

**Vue: `cm-fe-web`, `cm-fe-manual-web`, `sst-fw-web`, `sst-fw-storybook`** — [`sst-fe-common`](plugins/common/sst-fe-common/README.md)

| Skill | Dùng để |
|---|---|
| `check-conventions` | Kiểm tra `.vue`, composable và tầng API theo フロントエンド開発規約. `/sst-common:review-code` dùng skill này. |
| `use-sst-framework` | Theo đúng quy ước Vue và API client, và tìm các component, utility của `sst-fw-web` để dùng lại. |

**Ứng dụng web Vue: `cm-fe-web`, `cm-fe-manual-web`** — [`cm-fe-web-common`](plugins/common/cm-fe-web-common/README.md)

| Skill | Dùng để |
|---|---|
| `scaffold-screen` | Sinh màn hình tìm kiếm hoặc màn hình bảo trì từ 基本設計書 / 詳細設計書 và Figma. |

**Flutter: `cm-fe-mobile`, `sst-fw-mobile`, `sst-fw-widgetbook`** — [`sst-mobile-common`](plugins/common/sst-mobile-common/README.md)

| Command | Dùng để |
|---|---|
| `/sst-mobile-common:create-comment <file>` | Thêm comment Dart tiếng Nhật vào một file, không thay đổi code. |

**Chỉ một repository** — plugin service, đặt theo tên repository

| Repository | Skill | Dùng để |
|---|---|---|
| [`cm-be-bff-web`](plugins/services/cm-be-bff-web/README.md) | `scaffold-report` | Sinh feature báo cáo JasperReports (帳票). |
| | `scaffold-integration` | Sinh tích hợp bên ngoài, bọc SDK của nhà cung cấp (Azure, Bedrock). |
| [`cm-be-spec`](plugins/services/cm-be-spec/README.md) | `scaffold-contract` | Sinh contract BFF (TypeSpec) và contract gRPC (OpenAPI) từ tài liệu thiết kế. |
| | `scaffold-integration-contract` | Sinh contract TypeSpec chỉ ở phía BFF cho tích hợp bên ngoài. |
| [`cm-be-ms-log`](plugins/services/cm-be-ms-log/README.md) | `scaffold-log-feature` | Sinh endpoint tìm kiếm log (PostgreSQL hoặc Athena) hoặc luồng nạp log từ Kafka. |
| | `write-athena-clients` | Theo đúng quy tắc cho các class AWS Athena client. |
| [`cm-be-ms-dailyinv`](plugins/services/cm-be-ms-dailyinv/README.md) | `scaffold-inventory-feature` | Sinh feature dùng cả PostgreSQL và ClickHouse. |
| | `write-clickhouse-mappers` | Theo đúng quy tắc cho MyBatis mapper của ClickHouse. |
| [`sst-fw-be-core`](plugins/services/sst-fw-be-core/README.md) | `scaffold-constraint` | Sinh constraint Bean Validation tùy chỉnh. |
| | `write-extensions` | Theo đúng quy tắc cho các class extension utility. |

### 2.1 Chưa viết

| Plugin | Còn thiếu | Viết từ |
|---|---|---|
| `sst-mobile-common` | `check-conventions` | cm-docs モバイル開発規約 (537 dòng) |
| `sst-fw-be-common` | toàn bộ skill | quy tắc mà 6 repository `sst-fw-be-*` đang giữ (683 dòng) |
| `cm-be-spec` | `check-conventions` cho `.tsp` và OpenAPI | quy tắc OpenAPI và TypeSpec mà repository đang giữ (524 dòng) |
| `cm-devops-common` | cả plugin, cho `cm-devops-*` | quy tắc Terraform mà `cm-devops-terraform` đang giữ (124 dòng) |
| `sst-be-common`, `sst-fe-common` | phần quy ước chung xuyên stack | 11 tài liệu trong cm-docs `19.開発規約整備/common/` |

## 3. Thêm skill vào một repository

Dành cho người phụ trách một repository chưa được cài đặt. Việc cài đặt gồm hai file và một pull request.

1. Copy hai file này từ `cm-be-bff-api` (nhánh `feature/SCM-535088`) vào cùng đường dẫn trong repository của bạn:
   - [`.claude/settings.json`](https://github.com/suzuyo-cm/cm-be-bff-api/blob/feature/SCM-535088/.claude/settings.json)
   - [`.claude/hooks/sync-plugins.mjs`](https://github.com/suzuyo-cm/cm-be-bff-api/blob/feature/SCM-535088/.claude/hooks/sync-plugins.mjs)

2. Trong `.claude/settings.json`, liệt kê các plugin của repository bạn trong `enabledPlugins`. Tra các plugin này trong bảng [Tình trạng triển khai](#31-tình-trạng-triển-khai). Với `cm-be-bff-api`:

   ```json
   "enabledPlugins": {
     "sst-common@sst-ai-skills": true,
     "sst-be-common@sst-ai-skills": true
   }
   ```

   Repository có plugin service thì thêm cả plugin đó, ví dụ `"cm-be-bff-web@sst-ai-skills": true`.

   Giữ nguyên phần còn lại của file.

3. Commit cả hai file và merge vào nhánh mặc định.

4. Kiểm tra: mở Claude Code trong repository. Bạn sẽ thấy `Claude plugins synced` với các plugin ở bước 2.

5. Chuyển repository sang **Đã triển khai** trong bảng [Tình trạng triển khai](#31-tình-trạng-triển-khai), bằng một pull request vào repository này.

<details>
<summary>File <code>.claude/settings.json</code> đầy đủ của <code>cm-be-bff-api</code></summary>

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/sync-plugins.mjs\"",
            "timeout": 300
          }
        ]
      }
    ]
  },
  "enabledPlugins": {
    "sst-common@sst-ai-skills": true,
    "sst-be-common@sst-ai-skills": true
  },
  "extraKnownMarketplaces": {
    "sst-ai-skills": {
      "source": {
        "source": "git",
        "url": "git@github.com:suzuyo-cm/sst-ai-skills.git"
      },
      "autoUpdate": false
    }
  }
}
```

</details>

### 3.1 Tình trạng triển khai

Tính đến 2026-09-28.

| Repository | Nhóm | Plugin cần bật | Tình trạng |
|---|---|---|---|
| `cm-be-bff-api` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common` | Đang làm ([PR #6](https://github.com/suzuyo-cm/cm-be-bff-api/pull/6)) |
| `cm-be-bff-manual` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common` | Chưa |
| `cm-be-bff-web` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common`, `cm-be-bff-web` | Chưa |
| `cm-be-ms-bill` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Chưa |
| `cm-be-ms-core` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Chưa |
| `cm-be-ms-inout` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Chưa |
| `cm-be-ms-manual` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Chưa |
| `cm-be-ms-owner` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Chưa |
| `cm-be-ms-log` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common`, `cm-be-ms-log` | Chưa |
| `cm-be-ms-dailyinv` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common`, `cm-be-ms-dailyinv` | Chưa |
| `cm-be-spec` | API contract | `sst-common`, `cm-be-spec` | Chưa |
| `cm-fe-web` | Vue web | `sst-common`, `sst-fe-common`, `cm-fe-web-common` | Chưa |
| `cm-fe-manual-web` | Vue web | `sst-common`, `sst-fe-common`, `cm-fe-web-common` | Chưa |
| `cm-fe-mobile` | Flutter | `sst-common`, `sst-mobile-common` | Chưa |
| `sst-fw-mobile` | Flutter | `sst-common`, `sst-mobile-common` | Chưa |
| `sst-fw-widgetbook` | Flutter | `sst-common`, `sst-mobile-common` | Chưa |
| `sst-fw-be-core` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common`, `sst-fw-be-core` | Chưa |
| `sst-fw-be-aws` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Chưa |
| `sst-fw-be-grpc` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Chưa |
| `sst-fw-be-http` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Chưa |
| `sst-fw-be-security` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Chưa |
| `sst-fw-be-starter-platform` | Framework backend | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Chưa |
| `sst-fw-web` | Framework frontend | `sst-common`, `sst-fe-common` | Chưa |
| `sst-fw-storybook` | Framework frontend | `sst-common`, `sst-fe-common` | Chưa |
| `cm-print-agent` | Tool (Java) | `sst-common`, `sst-be-common` | Chưa |
| `cm-devops-terraform` | Terraform | `sst-common`, `cm-devops-common` | Chờ `cm-devops-common` |
| `cm-devops-cicd` | Terraform | `sst-common`, `cm-devops-common` | Chờ `cm-devops-common` |

`cm-tool-db-copy` (Python) nằm ngoài phạm vi cho tới khi có quy ước Python để đối chiếu.

## 4. Xử lý sự cố

| Bạn thấy | Cần làm |
|---|---|
| Không có thông báo `Claude plugins synced`, và không thấy skill | Repository chưa được cài đặt. Xem bảng [Tình trạng triển khai](#31-tình-trạng-triển-khai). |
| `Failed ... plugin operation(s)`, kèm lỗi Git hoặc `sst-ai-skills` | Tài khoản của bạn không đọc được `suzuyo-cm/sst-ai-skills`. Chạy `git ls-remote git@github.com:suzuyo-cm/sst-ai-skills.git`; nếu bị lỗi, hãy kiểm tra lại quyền truy cập vào repository. |
| `node` is not recognized, hoặc `node: command not found`, khi Claude Code khởi động | Chưa cài Node.js hoặc Node.js không có trong `PATH`. Cài Node.js 22 trở lên, rồi khởi động lại Claude Code. |
| `Plugin sync skipped: Claude Code CLI not found` | Cài Claude Code CLI, hoặc đặt biến môi trường `CLAUDE_CLI_PATH` trỏ tới file chạy `claude`. |
| Vẫn không thấy skill sau khi chạy `/reload-plugins` (VS Code) | Chạy **Developer: Reload Window** từ command palette. |
| Cả terminal và VS Code đều hiện `Claude plugins synced` cho cùng một repository | Đây là hành vi bình thường. Trên Windows, terminal và VS Code mỗi bên duy trì một bản cài đặt riêng. |

## 5. Cách hoạt động

- Một **skill** là một bộ hướng dẫn và tài liệu tham chiếu. Claude load nó khi việc bạn yêu cầu khớp với nó, hoặc khi bạn gọi nó bằng `/`.
- Một **plugin** là một gói gồm nhiều skill. Mỗi plugin có một version.
- Repository này là một **marketplace**: nơi phát hành các plugin.
- Một repository liệt kê các plugin nó cần trong `.claude/settings.json`. Mỗi lần Claude Code khởi động ở đó, hook `sync-plugins.mjs` cài các plugin còn thiếu và cập nhật các plugin khác lên version mới nhất trên `develop`.

Tên plugin cho biết nó áp dụng ở đâu, còn lớp của nó cho biết nó chứa gì:

| Tên | Áp dụng cho | Chứa gì |
|---|---|---|
| `sst-common` | mọi repository | command review |
| `sst-<stack>-common` | mọi repository của một stack, cả sản phẩm lẫn framework | tiêu chuẩn phát triển và catalog framework |
| `cm-<nhóm>-common` | các repository của một nhóm sản phẩm | sinh code cho loại repository đó |
| `<tên repository>` | một repository | thứ chỉ repository đó cần |
