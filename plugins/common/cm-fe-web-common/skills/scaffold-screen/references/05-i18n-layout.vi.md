# Đa ngôn ngữ và layout

Quy tắc i18n và sinh layout bằng Figma MCP.

## Định dạng key i18n

> Với các từ vựng dùng chung nhiều màn hình (label, button, panel, tab, thông báo validation v.v.) thì dùng **key phẳng**, không thêm prefix tên màn hình. Chỉ riêng các mục cấp cao đặc thù của màn hình (ví dụ: tiêu đề toàn màn hình) mới được lồng theo tên chức năng (mã mnemonic).

```ts
// ✅ Đúng (từ vựng dùng chung nhiều màn hình → phẳng)
t('label.ownerCode');
t('button.search');
t('panel.searchCondition');

// ✅ Đúng (tiêu đề cấp cao đặc thù của màn hình → lồng theo tên chức năng. Ví dụ thực tế: login.title, aiChat.title, ocr.title)
t('soMainte.title');

// ❌ Sai (chèn tên màn hình vào dưới category từ vựng chung `label`)
t('soPlanSearch.label.ownerCode');
```

Từ vựng dùng chung được đặt trong các key theo category như `label.xxx`, `button.xxx`, `panel.xxx`, `tab.xxx`, `validation.xxx`. Khi tạo mới key cấp cao đặc thù của màn hình (`<機能名>.title` v.v.) thì cũng không được lồng các văn bản khác của màn hình đó (label v.v.) xuống dưới tên chức năng — đối tượng chỉ là những mục cấp cao đặc thù của màn hình không thể đặt vào category chung.

## Ưu tiên tái sử dụng key có sẵn (quan trọng nhất)

> **Trước khi tạo key mới phải đọc `src/locales/ja.ts` để kiểm tra các key đã có.**

Các lỗi đặt tên thường gặp:
| Thứ muốn dùng | Sai (tạo mới) | Đúng (key có sẵn) |
|-------------|-----------|--------------|
| Loại phiếu | `label.soType` | `label.slipType` |
| Mã đối tác | `label.ownerCd` | `label.ownerCode` |
| Mã kho | `label.warehouseCd` | `label.warehouseCode` |
| Mã nơi xuất hàng | `label.shipperCd` | `label.shipperCode` |
| Phân loại xuất hàng của đối tác | `label.ownerSoKbn` | `label.shipDiv` |
| Khóa lô phân bổ | `label.allocBatchKey` | `label.pickBatchKey` |
| Button nhân bản | `button.duplicate` | `button.copy` |

## Quy tắc thêm đa ngôn ngữ

- Thêm key sử dụng vào **cả 4 ngôn ngữ** (`ja.ts`/`en.ts`/`zh.ts`/`es.ts`)
- Sau khi sinh code, phải kiểm tra `src/locales/ja.ts` xem key đang dùng có tồn tại hay không

```ts
// Ví dụ thêm vào ja.ts
panel: {
  soBaseInfo: '出荷メイン情報',
},
label: {
  soSlipNo: '出荷伝票番号',
  regDateTime: '登録日時',
},
```

---

## Lấy design từ Figma MCP

### Quy tắc chuyển đổi URL

URL embed trong tài liệu thiết kế → URL dùng cho MCP:

```
# Định dạng embed
https://embed.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}&embed-host=share

# Định dạng truyền cho MCP
https://www.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
```

### Phân biệt sử dụng tool

| Tool                 | Mục đích                                                  |
| -------------------- | --------------------------------------------------------- |
| `get_design_context` | Loại component, thuộc tính, nội dung text                 |
| `get_screenshot`     | **Bắt buộc để tính `SstCol :cols`** (xác nhận tỉ lệ cột bằng mắt) |

> **Bắt buộc gọi cả hai tool song song.**

### Quy trình vận dụng

1. Lấy Figma URL từ mục "Layout" của tài liệu thiết kế
2. Gọi đồng thời `get_design_context` + `get_screenshot`
3. Đọc tỉ lệ cols từ ảnh chụp màn hình
4. Chọn component Sst từ code được sinh ra
5. Kết hợp lại để sinh template

### Chuyển đổi Figma → component Sst

| Phần tử UI Figma | Component Sst                    |
| ---------------- | -------------------------------- |
| Nhập text        | `<SstTextField>`                 |
| Nhập số          | `<SstNumberInput>`               |
| Nhập ngày        | `<SstDateInput>`                 |
| Dropdown         | `<SstSelect>`                    |
| Radio button     | `<SstRadio>`                     |
| Checkbox         | `<SstCheckbox>`                  |
| Mã + tên         | `<SstCodeName>`                  |
| Button           | `<SstButton>`                    |
| Accordion        | `<SstPanel variant="accordion">` |
| Tab              | `<SstTabs>`                      |
| Grid             | `<SstGrid>`                      |
| Cây (tree)       | `<SstTreeview>`                  |

---

## Layout SstRow / SstCol (grid 24 cột)

Chỉ định chiều rộng chiếm dụng bằng `:cols` của `SstCol` (tổng = 24).

### Các mẫu chia thường dùng

| Layout               | cols       | Trường hợp sử dụng   |
| -------------------- | ---------- | -------------------- |
| Toàn chiều rộng      | `24`       | Hàng button, grid    |
| Chia 2 đều           | `12` × 2   | 2 mục nằm ngang      |
| Chia 3 đều           | `8` × 3    | 3 mục nằm ngang      |
| Chia 4 đều           | `6` × 4    | 4 mục nằm ngang      |
| Cây + form (1:5)     | `4` + `20` | Cây bên trái + form bên phải |
| Cây + form (1:3)     | `6` + `18` | Cây bên trái + form bên phải |

### Quy trình tính cols

1. Lấy ảnh chụp màn hình bằng `get_screenshot`
2. Đọc bằng mắt số lượng item và tỉ lệ chiều rộng của từng hàng
3. Quy đổi tỉ lệ ra 24
4. Xác nhận tổng trong cùng một `SstRow` là **24**

### Checklist

- [ ] Tổng `:cols` trong cùng một `SstRow` là **24**
- [ ] Tỉ lệ cây đã được xác nhận bằng mắt qua `get_screenshot`
- [ ] Hàng button dùng `justify="space-between"` hoặc `justify="end"`
- [ ] Các mục trong panel mặc định bố trí 2 cột với `:cols="12"`
