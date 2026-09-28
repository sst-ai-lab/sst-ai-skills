---
name: scaffold-screen
description: "Skill dùng để tự động sinh frontend. Dùng khi scaffold một màn hình Vue mới (màn hình tìm kiếm / màn hình đăng ký - bảo trì) từ tài liệu thiết kế cơ bản/chi tiết tiếng Nhật (基本設計書・詳細設計書) và Figma: sinh ra <feature>.vue, composable use<Feature>.ts, <feature>.types.ts, src/api <feature>Api.ts / <feature>ApiType.ts, đăng ký menu, entry trong libs/client.ts và các key i18n, sử dụng các component Sst* của @sst-cm/sst-fw-web. Yêu cầu Figma MCP server (get_design_context / get_screenshot)."
---

# Skill frontend

## Thời điểm áp dụng

- Khi cần tự động sinh frontend

## 🚨 Quan trọng: mỗi lần đều phải đọc lại các file tham chiếu

> **Mỗi lần skill này được gọi, hãy thực hiện các bước sau lại từ đầu.**
> Ngay cả khi đây là lần gọi thứ hai trở đi trong cùng một đoạn chat, không được bị ảnh hưởng bởi kết quả sinh lần trước,
> **bắt buộc phải Read lại `references/init.md`** và tuân theo các bước được ghi ở đó.
>
> **Không được "ghi nhớ" và tái sử dụng pattern của code đã sinh lần trước.**
> Mỗi lần sinh là độc lập, và file tham chiếu là đáp án đúng duy nhất.

### Các bước đọc bắt buộc (không được lược bỏ)

1. **Read** → `references/init.md` (luồng các bước・14 quy tắc ở đầu file・cấu trúc thư mục)
2. **Read** → `references/01-template-structure.md` (template + bộ khung composable)
3. **Read** → `references/02-grid-definition.md` (Grid + pagination)
4. **Read** → `references/03-event-implementation.md` (pattern xử lý sự kiện)
5. **Read** → `references/04-api-definition.md` (kiểu API + wrapper)
6. **Read** → `references/05-i18n-layout.md` (i18n + Figma + layout)
7. Khi cần đặc tả chi tiết (property・slot・event・ví dụ sử dụng) của component・utility sẽ dùng, hãy xem danh sách của framework frontend dùng chung `@sst-cm/sst-fw-web`

**Các mục 1〜6 ở trên bắt buộc đọc mỗi lần. Cấm "lược bỏ vì lần trước đã đọc rồi".**

## Định nghĩa phím tắt cho button (Hotkey) —— quy tắc chung của hệ thống

Tương ứng giữa phím và button: `f3`=tìm kiếm, `f4`=nhân bản, `f6`=tạo mới, `f7`=lưu, `f8`=xóa trắng, `f9`=thực thi.
Hãy đăng ký toàn bộ các phím tương ứng với những button có trên màn hình đó.

## Quy tắc chọn component (tuân thủ nghiêm ngặt)

> **Cấm dùng trực tiếp các component native của Vuetify (`<v-card-text>`/`<v-btn>`/`<v-text-field>`/`<v-select>`/`<v-dialog>`, v.v.) trong `<template>`.**
> Mọi phần tử UI trên màn hình đều phải dùng component wrapper `Sst*` do `@sst-cm/sst-fw-web` cung cấp.
> Nếu không tìm thấy component `Sst*` tương ứng, không được tự ý fallback sang `v-*`, hãy xác nhận với người dùng (chi tiết xem quy tắc #55 trong `references/init.md`).

## Danh sách file tham chiếu

| Pattern            | Tên file md                             | Mô tả                                                                 |
| ------------------ | --------------------------------------- | --------------------------------------------------------------------- |
| Tạo mới ban đầu    | `references/init.md`                    | Luồng các bước・quy tắc đầu file・cấu trúc thư mục・trình tự triển khai |
| Template           | `references/01-template-structure.md`     | Template màn hình tìm kiếm/đăng ký + khung composable + bảng component |
| Grid               | `references/02-grid-definition.md`         | SstGrid + columnDefs + pagination + pageChanged + getData             |
| Sự kiện            | `references/03-event-implementation.md`         | Pattern thêm điều kiện/điều khiển chọn/tìm kiếm/lưu/xóa               |
| API                | `references/04-api-definition.md`              | types.ts/ApiType.ts/Api.ts/client.ts/DropDown/CodeName                |
| Đa ngữ・layout     | `references/05-i18n-layout.md`   | Quy tắc i18n + Figma MCP + SstRow/SstCol                              |

## Quy tắc import (tuân thủ nghiêm ngặt)

### Viết import tường minh tại mọi nơi sử dụng

**Mọi symbol được sử dụng đều phải có câu lệnh `import` tường minh** (auto-import không được thiết lập).
Nhờ đó quan hệ phụ thuộc của code trở nên rõ ràng và dễ đọc hơn.

```ts
// ✅ Đúng: viết import tại nơi sử dụng
import { useI18n, useMessage, useDialog, sstUtil, useSstHotkeyScope, CellEditorType } from '@sst-cm/sst-fw-web';
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig';
```

### Bảng tương ứng nguồn import

| Symbol                                                                                                                                  | Nguồn import                      |
| --------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `useI18n`, `useMessage`, `useDialog`, `useNotification`, `sstUtil`, `useSstHotkeyScope`, `usePageChange`, `CellEditorType`, `setLocale` | `@sst-cm/sst-fw-web`              |
| `useFormDisplayConfig`                                                                                                                  | `@/composables/sstMemorizeConfig` |
| `sstCodeNameApi`                                                                                                                        | `@/composables/sstCodeNameApi`    |
| `CodeNameType`                                                                                                                          | `@/constants/codeNameType`        |

### Quy tắc nơi import `CodeNameType` (quan trọng)

`CodeNameType` **khi dùng trực tiếp trong template** thì import trong `<script setup>` của `.vue`,
**chỉ khi dùng bên trong composable** thì import trong `use*.ts`.
Nếu dùng ở cả hai nơi thì có thể viết ở cả hai, nhưng **cấm để lại import trong file không dùng đến** (vi phạm dead code của SonarQube).

```ts
// Khi dùng trong template .vue dưới dạng :code-type="CodeNameType.OWNER" → viết trong .vue
// Khi dùng trong columnDefs của composable dưới dạng codeType: CodeNameType.ITEM → viết trong use*.ts
```

### Gộp import cùng package (cấm trùng lặp)

Khi import nhiều symbol từ cùng một package thì **bắt buộc gộp vào một dòng**:

```ts
// ✅ Đúng
import { CellEditorType, useI18n, useMessage, useSstHotkeyScope, usePageChange } from '@sst-cm/sst-fw-web';

// ❌ Cấm (import từ cùng một package trên 2 dòng trở lên)
import { CellEditorType } from '@sst-cm/sst-fw-web';
import { useSstHotkeyScope } from '@sst-cm/sst-fw-web';
```

## Các giá trị cần quyết định trước khi sinh code

Giá trị nào đọc được từ repository thì đọc. Chỉ xác nhận với người dùng những giá trị không đọc được.

| Placeholder                | Cách quyết định                                                                             |
| -------------------------- | ------------------------------------------------------------------------------------------- |
| `{repo}`                   | Tên thư mục gốc của repository                                                              |
| `{menuFile}`               | File định nghĩa menu hiện có đang liên kết APPKEY với file vue (`src/constants/menu.ts`, v.v.) |
| `{middleCategoryDirs}`     | Tên các thư mục 中分類 (phân loại trung) hiện có dưới `src/views/`                           |
| `{subCategoryDirs}`        | Tên các thư mục 小分類 (phân loại nhỏ) hiện có dưới thư mục 中分類                           |
| `{commonLookupImportPath}` | Đường dẫn của `commonLookup.vue` trong repository. Với repository không có thì không dùng Lookup |
| `{dropDownApiDir}`         | Thư mục chứa `dropDownApi.ts` / `dropDownApiType.ts` trong repository. Với repository không có thì không dùng DropDown |

Chỉ khi cần tạo 中分類・小分類 mới thì mới xác nhận tên thư mục với người dùng.
