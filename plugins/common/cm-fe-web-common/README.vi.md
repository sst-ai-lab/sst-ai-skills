# cm-fe-web-common

Các skill dùng chung cho các ứng dụng web Vue của SCM. Bật plugin này trong `cm-fe-web` và `manual-fe-web`, cùng với `sst-common` và `sst-fe-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-fe-common@sst-ai-skills": true, "cm-fe-web-common@sst-ai-skills": true } }
```

## Nội dung

| Skill | Mục đích |
| --- | --- |
| `scaffold-screen` | Sinh màn hình tìm kiếm hoặc màn hình bảo trì từ tài liệu thiết kế tiếng Nhật (基本設計書 (tài liệu thiết kế cơ bản) / 詳細設計書 (tài liệu thiết kế chi tiết)) và Figma |

Tiêu chuẩn phát triển frontend và catalog `sst-fw-web` nằm ở `sst-fe-common`, plugin mà mọi repository Vue đều bật.

## Điều kiện cần

- `scaffold-screen` cần Figma MCP server (`get_design_context`, `get_screenshot`).

## Các giá trị mà skill đọc từ repository

`scaffold-screen` tự suy ra file định nghĩa menu, tên các thư mục 中分類 (phân loại trung) / 小分類 (phân loại nhỏ) nằm dưới `src/views/`, và các đường dẫn import `CommonLookup` / `DropDownApi` từ chính repository. Nó chỉ hỏi những gì mà repository không thể trả lời, chẳng hạn tên thư mục của một 中分類 chưa tồn tại.
