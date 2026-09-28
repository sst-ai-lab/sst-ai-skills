# Đóng góp

Hướng dẫn này dành cho bất kỳ ai thay đổi skill: sửa một quy tắc, thêm một skill hay thêm một plugin.

**Trong trang này**

- [1. Trước khi bắt đầu](#1-trước-khi-bắt-đầu)
- [2. Các việc thường làm](#2-các-việc-thường-làm)
  - [2.1 Sửa hoặc cải thiện một skill](#21-sửa-hoặc-cải-thiện-một-skill)
  - [2.2 Thêm một skill](#22-thêm-một-skill)
  - [2.3 Đổi tên hoặc xóa một skill](#23-đổi-tên-hoặc-xóa-một-skill)
  - [2.4 Thêm một plugin](#24-thêm-một-plugin)
  - [2.5 Đổi tên hoặc xóa một plugin](#25-đổi-tên-hoặc-xóa-một-plugin)
- [3. Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi)
- [4. Tra cứu](#4-tra-cứu)
  - [4.1 Tăng version nào](#41-tăng-version-nào)
  - [4.2 Nội dung đặt ở đâu](#42-nội-dung-đặt-ở-đâu)
  - [4.3 Plugin common dùng được cho mọi repository](#43-plugin-common-dùng-được-cho-mọi-repository)
  - [4.4 Đặt tên](#44-đặt-tên)
  - [4.5 Viết một skill](#45-viết-một-skill)
  - [4.6 Viết một command](#46-viết-một-command)
  - [4.7 Tiêu chuẩn review](#47-tiêu-chuẩn-review)

## 1. Trước khi bắt đầu

**Thay đổi tới các repository như thế nào.** Một repository cài plugin từ nhánh `develop` của repository này, và chỉ cập nhật một plugin khi `version` của nó thay đổi. Vì vậy mỗi thay đổi cần hai việc:

1. một `version` mới trong `.claude-plugin/plugin.json` của plugin;
2. merge vào `develop`.

Sau đó các repository sẽ nhận thay đổi vào lần tiếp theo có người mở Claude Code trong đó.

**Mọi thứ nằm ở đâu.**

```text
sst-ai-skills/
├── .claude-plugin/
│   └── marketplace.json          # the list of plugins
└── plugins/
    ├── common/<plugin>/          # shared by every repository of a stack
    └── services/<plugin>/        # used by one repository, named after it
        ├── .claude-plugin/
        │   └── plugin.json       # name and version of the plugin
        ├── skills/
        │   └── <skill>/
        │       ├── SKILL.md      # what Claude reads
        │       └── references/   # documents SKILL.md points to
        ├── commands/             # slash commands, if any
        └── README.md             # what the plugin's skills do
```

(Chú thích trong sơ đồ: `marketplace.json` là danh sách plugin; `common/` dùng chung cho mọi repository của một stack; `services/` cho một repository, đặt theo tên nó; `plugin.json` chứa tên và version của plugin; `SKILL.md` là thứ Claude đọc; `references/` là các tài liệu mà `SKILL.md` trỏ tới; `commands/` là các slash command nếu có; `README.md` giải thích các skill của plugin làm gì.)

## 2. Các việc thường làm

### 2.1 Sửa hoặc cải thiện một skill

1. Sửa `SKILL.md` của skill hoặc thư mục `references/` của nó.
2. Trong `.claude-plugin/plugin.json` của plugin, tăng phần PATCH của `version`: `0.3.0` → `0.3.1`.
3. [Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi).
4. Mở pull request vào `develop`.

### 2.2 Thêm một skill

1. Quyết định đặt skill ở đâu: trong plugin common của stack nếu nhiều repository cần nó, ngược lại thì trong plugin service của repository. Xem [Nội dung đặt ở đâu](#42-nội-dung-đặt-ở-đâu).
2. Tạo `plugins/<common|services>/<plugin>/skills/<skill-name>/SKILL.md`. Đặt tên theo [Đặt tên](#44-đặt-tên), và làm theo [Viết một skill](#45-viết-một-skill).
3. Tăng phần MINOR của `version` plugin: `0.3.0` → `0.4.0`.
4. Thêm skill vào `README.md` của plugin và vào mục [Có những gì](README.vi.md#2-có-những-gì) trong README.
5. [Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi), rồi mở pull request vào `develop`.

Các repository không cần thay đổi gì: chúng nhận skill mới cùng version mới.

### 2.3 Đổi tên hoặc xóa một skill

1. Đổi tên hoặc xóa thư mục của skill.
2. Tìm tên cũ trong các skill và command khác, và cập nhật chúng.
3. Tăng phần MAJOR của `version` plugin: `0.3.0` → `1.0.0`.
4. Cập nhật `README.md` của plugin và mục [Có những gì](README.vi.md#2-có-những-gì) trong README.
5. [Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi), rồi mở pull request vào `develop`.
6. Thông báo tên mới cho các team.

### 2.4 Thêm một plugin

1. Tạo `plugins/<common|services>/<plugin>/` gồm:
   - `.claude-plugin/plugin.json`, với `version` là `0.1.0`;
   - ít nhất một skill;
   - một `README.md` liệt kê các skill và các repository bật plugin này.
2. Thêm plugin vào `.claude-plugin/marketplace.json`, với `source` là thư mục của nó (ví dụ `./plugins/services/<plugin>`), và tăng phần MINOR của `version` marketplace.
3. Trong README, thêm plugin vào mục [Có những gì](README.vi.md#2-có-những-gì) và vào các repository dùng nó trong [Tình trạng triển khai](README.vi.md#31-tình-trạng-triển-khai).
4. [Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi), rồi mở pull request vào `develop`.
5. Sau khi merge, thêm `"<plugin>@sst-ai-skills": true` vào `enabledPlugins` trong `.claude/settings.json` của mỗi repository dùng plugin đó.

### 2.5 Đổi tên hoặc xóa một plugin

1. Đổi tên hoặc xóa thư mục của plugin, cập nhật `.claude-plugin/marketplace.json`, và tăng phần MAJOR của `version` marketplace.
2. Cập nhật mục [Có những gì](README.vi.md#2-có-những-gì) và [Tình trạng triển khai](README.vi.md#31-tình-trạng-triển-khai) trong README.
3. [Kiểm tra thay đổi](#3-kiểm-tra-thay-đổi), rồi mở pull request vào `develop`.
4. Sau khi merge, đổi tên hoặc xóa plugin trong `enabledPlugins` của mỗi repository đang bật nó. Cho tới lúc đó, Claude Code sẽ báo thiếu plugin mỗi lần khởi động ở các repository này.

## 3. Kiểm tra thay đổi

1. Kiểm tra marketplace hợp lệ:

   ```bash
   claude plugin validate .
   ```

   Kết quả phải kết thúc bằng `Validation passed`.

2. Thử plugin vừa thay đổi trong một repository có dùng nó. Chạy từ repository đó:

   ```bash
   claude --plugin-dir <path-to-sst-ai-skills>/plugins/<common|services>/<plugin>
   ```

   Claude Code load bản plugin trên máy bạn, chỉ cho phiên này. Hãy yêu cầu đúng việc mà skill đảm nhận, và kiểm tra kết quả.

## 4. Tra cứu

### 4.1 Tăng version nào

| Thay đổi | `version` của plugin (`plugin.json`) | `version` của marketplace (`marketplace.json`) | Việc cần làm ở mỗi repository |
|---|---|---|---|
| Sửa lỗi hoặc sửa câu chữ của skill | PATCH (0.3.0 → 0.3.1) | — | Không cần |
| Thêm skill | MINOR (0.3.0 → 0.4.0) | — | Không cần |
| Đổi tên hoặc xóa skill | MAJOR (0.3.0 → 1.0.0) | — | Không cần |
| Chuyển skill sang plugin khác | MINOR cho plugin nhận skill, MAJOR cho plugin mất skill | — | Bật plugin nhận skill, nếu chưa bật |
| Thêm plugin | Bắt đầu từ 0.1.0 | MINOR (1.4.0 → 1.5.0) | Bật plugin ở nơi dùng nó |
| Đổi tên hoặc xóa plugin | — | MAJOR (1.4.0 → 2.0.0) | Đổi tên hoặc xóa plugin ở nơi đang bật nó |

`version` của plugin chỉ nằm trong `plugin.json` của nó; không lặp lại trong `marketplace.json`.

### 4.2 Nội dung đặt ở đâu

Plugin được phân lớp theo phạm vi áp dụng của nội dung:

| Nội dung | Đặt ở | Ví dụ |
|---|---|---|
| Thông tin về một repository: mục đích, port, topic, các policy nó đã chọn | `CLAUDE.md` của repository đó, không bao giờ đặt trong plugin | — |
| Command mà mọi repository đều dùng, bất kể stack | `plugins/common/sst-common` | `/review-code` |
| Tiêu chuẩn phát triển hoặc catalog framework cho cả một stack | `plugins/common/sst-<stack>-common` | `sst-be-common`, `sst-fe-common`, `sst-mobile-common` |
| Sinh code, hoặc quy tắc, cho một loại repository | `plugins/common/cm-<nhóm>-common` hoặc `plugins/common/sst-fw-<stack>-common` | `cm-be-ms-common`, `sst-fw-be-common` |
| Skill hoặc command chỉ một repository dùng | `plugins/services/<tên repository>` | `cm-be-ms-log` |

- Đặt skill ở lớp hẹp nhất còn phù hợp. Khi repository thứ hai cần nó, chuyển lên một lớp.
- Chỉ tạo plugin service khi repository có ít nhất một skill của riêng nó.
- Chỉ tạo plugin khi đã có nội dung. Plugin rỗng nằm trong bảng sẽ làm người bật nó hiểu sai.
- Mỗi repository bật một plugin ở mỗi lớp áp dụng cho nó, nên phần lớn repository bật ba plugin.

### 4.3 Plugin common dùng được cho mọi repository

Một skill trong `plugins/common` phải dùng được, không cần sửa, trong một repository mới cùng loại.

- Không ghi tên repository, port, topic, tên bảng, class exception của service, tên gRPC channel hay base package của service. Thay vào đó dùng placeholder, ví dụ `{basePackage}`, `{grpcChannel}`, `{serviceException}`.
- Được phép ghi vai trò kiến trúc (BFF, microservice, gRPC server hoặc client, Kafka consumer) và tên các framework dùng chung (`sst-fw-be-*`, `sst-fw-web`).
- Khi các service khác nhau một cách hợp lý, giữ mỗi cách làm thành một biến thể có tên, và để `CLAUDE.md` của repository lựa chọn.
- Liệt kê các placeholder mà skill cần trong mục `## Inputs from CLAUDE.md` của nó. Giá trị lấy từ các mục `## Service profile` và `## Policies` trong `CLAUDE.md` của repository. Khi thiếu một giá trị, skill hỏi developer thay vì đoán.

### 4.4 Đặt tên

- **Plugin:** tên cho biết plugin áp dụng ở đâu. `sst-common` cho mọi repository; `sst-<stack>-common` cho cả một stack, gồm cả sản phẩm lẫn framework (`sst-be-common`, `sst-fe-common`, `sst-mobile-common`); `cm-<nhóm>-common` cho một nhóm sản phẩm (`cm-be-bff-common`, `cm-be-ms-common`, `cm-fe-web-common`); `sst-fw-<stack>-common` cho các repository framework (`sst-fw-be-common`); và đúng tên repository cho plugin service (`cm-be-ms-log`).
- **Skill:** một động từ và một đối tượng, `<verb>-<object>`, nói rõ skill làm gì. Developer gõ nó như một lệnh (`/cm-be-ms-common:scaffold-ms-feature`), nên nó phải đọc được như một lệnh. Dùng một trong bốn động từ:

  | Động từ | Skill | Ví dụ |
  |---|---|---|
  | `scaffold-` | sinh code mới | `scaffold-screen` |
  | `check-` | so code với các tiêu chuẩn đã được viết thành văn bản | `check-conventions`, `check-security` |
  | `use-` | cho biết những gì đã có, để được dùng lại | `use-sst-framework` |
  | `write-` | chứa quy tắc để tự viết tay một loại code | `write-athena-clients` |

  Đặt đối tượng cụ thể (`scaffold-log-feature`, không phải `scaffold-feature`), và không lặp lại tên plugin. Trong plugin common, được phép thêm tiền tố `bff-` hoặc `ms-` cho skill chỉ áp dụng cho một vai trò.
- **Command:** cũng theo dạng động từ - đối tượng (`review-code`, `create-comment`).

### 4.5 Viết một skill

- Tên thư mục và `name` trong frontmatter viết thường theo kebab-case.
- Viết `description` thật chính xác. Claude đọc nó để quyết định khi nào dùng skill.
- Chỉ giữ các tài liệu tham chiếu và script mà skill dùng, trong thư mục của chính nó.
- Không tạo thư mục rỗng để giữ chỗ.

### 4.6 Viết một command

- Đặt command trong `plugins/<common|services>/<plugin>/commands/`.
- Một command chạy các bước của một quy trình. Giữ các quy tắc và kiến thức nó cần trong skill, không đặt trong command.

### 4.7 Tiêu chuẩn review

`/sst-common:review-code` không có tiêu chuẩn riêng. Nó load mọi skill có tên bắt đầu bằng `check-` trong các plugin mà repository bật, và áp dụng từng skill cho những file mà description của skill đó bao quát. Để thêm tiêu chuẩn (cho một stack mới, cho quy tắc mà chỉ một repository tuân theo, hoặc cho một lĩnh vực mới như bảo mật), hãy thêm một skill như vậy; `sst-common` không cần thay đổi.

- Đặt tên skill theo dạng `check-<lĩnh vực>`: `check-conventions` cho tiêu chuẩn phát triển, `check-security` cho quy tắc bảo mật, v.v. Skill có tên khác sẽ không được load.
- Dựa trên các quy tắc đã được viết thành văn bản và có mã định danh, như số mục hoặc ID trong checklist. Command chỉ báo cáo những gì tài liệu quy định, và trích dẫn quy tắc đó. Một skill đi tìm bug mà không dựa trên quy tắc thành văn thì không phải là skill `check-`.
- Ghi trong description những file mà skill bao quát, ví dụ "changed Java code" hoặc ".vue / use*.ts".
- Giữ các tài liệu mà skill trỏ tới trong cùng plugin. Nếu một tài liệu được ưu tiên hơn tài liệu khác (tiêu chuẩn hơn checklist), hãy ghi rõ trong `SKILL.md`.
- Trong plugin service, chỉ viết những gì khác với skill cùng tên của stack: cả hai đều được áp dụng.

Command chỉ báo cáo các vi phạm tìm được. Việc đăng chúng lên pull request do CI của từng repository làm (ví dụ các script `pr-review` của `cm-be-bff-api`), không phải plugin.
