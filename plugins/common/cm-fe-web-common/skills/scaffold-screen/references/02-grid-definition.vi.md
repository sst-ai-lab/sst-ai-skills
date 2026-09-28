# Định nghĩa Grid

Cách sử dụng SstGrid, cách viết columnDefs, phân trang.

## Grid chỉ đọc (màn hình tìm kiếm)

Grid của màn hình tìm kiếm sử dụng **phân trang phía server**.
**Phải chỉ định rõ ràng `pagination-mode="server"`** (không được bỏ qua).

```html
<SstGrid
  id="grid"
  ref="gridRef"
  v-model="gridData"
  :column-defs="columnDefs"
  filter
  :loading="gridLoading"
  :page-setting-item="paginationSettings"
  pagination-mode="server"
  show-checkbox-column
  sortable
  :toolbar-config="{ showColVis: true, showExport: true }"
  width="100%"
  @page-changed="pageChanged"
  @page-size-changed="pageChanged"
  @selection-changed="onSelectionChanged"
/>
```

Các event bắt buộc:

- `@page-changed` + `@page-size-changed` → lấy lại dữ liệu khi đổi trang
- `@selection-changed` → điều khiển bật/tắt button dựa trên dòng được chọn (xem mẫu bên dưới)
- `:loading="gridLoading"` → hiển thị loading trong lúc gọi API

### Mẫu triển khai onSelectionChanged

Callback của `@selection-changed` nhận mảng các dòng được chọn qua `event.selectRows`.
Khi cần điều khiển `disabled` của button thì dùng mẫu sau:

```ts
const selectedRows = ref<ResponseType[]>([]);
const confirmDisabled = ref(true);
const deleteDisabled = ref(true);

function onSelectionChanged(event: { selectRows: ResponseType[] }) {
  selectedRows.value = event.selectRows;
  confirmDisabled.value =
    selectedRows.value.length === 0 ||
    !selectedRows.value.every((row) => row.status != undefined && row.status < '200');
  deleteDisabled.value =
    selectedRows.value.length === 0 ||
    !selectedRows.value.every((row) => row.status != undefined && row.status === '100');
}
```

> ⚠️ Dùng **`event.selectRows`**. Cấm gọi trực tiếp AG Grid API như `event.api.getSelectedRows()`.

## Grid có thể chỉnh sửa (màn hình bảo trì)

Grid có thể chỉnh sửa dùng **phân trang phía client**.
Chỉ định rõ ràng `pagination-mode="client"`.

**⚠️ Grid có thể chỉnh sửa phải chỉ định `:tab`.** Giống như các component nhập liệu của form, grid cũng phải được gán thứ tự tab để có thể focus vào grid bằng phím Tab. Số của `:tab` dùng số kế tiếp của trường nhập liệu form ngay trước đó.

```html
<SstGrid
  ref="gridRef"
  v-model="gridData"
  :column-defs="columnDefs"
  filter
  :page-setting-item="paginationSettings"
  pagination-mode="client"
  sortable
  :tab="10"
  :toolbar-config="{ showColVis: true, add: true, delete: true }"
  width="100%"
/>
```

## Bảng đối chiếu cellEditor của columnDefs

| Component trong tài liệu thiết kế | CellEditorType            |
| --------------------------------- | ------------------------- |
| SstInputColumn                    | `CellEditorType.Input`    |
| SstNumberInputColumn              | `CellEditorType.Number`   |
| SstSelectColumn                   | `CellEditorType.Select`   |
| SstDateColumn                     | `CellEditorType.Date`     |
| SstDateTimeColumn                 | `CellEditorType.DateTime` |
| SstTimeColumn                     | `CellEditorType.Time`     |
| SstButtonColumn                   | `CellEditorType.Button`   |
| SstCheckboxColumn                 | `CellEditorType.Checkbox` |
| SstActionColumn                   | `CellEditorType.Action`   |
| SstCodeNameColumn                 | `CellEditorType.CodeName` |
| SstProcessColumn                  | `CellEditorType.Process`  |

## Ví dụ triển khai columnDefs

```ts
import { CellEditorType } from '@sst-cm/sst-fw-web';

// ⚠️ columnDefs bắt buộc phải bọc trong computed (vì dùng t() nên cần hỗ trợ chuyển đổi ngôn ngữ)
const columnDefs = computed<ColumnDef[]>(() => [
  // Cột thao tác (Action): cellRenderer + cellRendererParams.actions
  {
    headerName: t('label.action'),
    field: 'action',
    width: 80,
    cellRenderer: CellEditorType.Action,
    cellRendererParams: {
      actions: [
        {
          icon: 'mdi-playlist-edit',
          onClick: (params: any) => {
            router.push({ name: 'soMainte', query: { soNo: params.data.soNo } });
          },
        },
      ],
    },
  },
  // Cột nhập liệu thông thường: maxLength + rules
  {
    headerName: t('label.itemCode'),
    field: 'itemCd',
    width: 150,
    editable: true,
    cellEditor: CellEditorType.Input,
    cellEditorParams: {
      maxLength: 20,
      rules: [{ required: true, message: t('validation.itemCodeRequired') }],
    },
  },
  // Cột CodeName
  {
    headerName: t('label.ownerItemCode'),
    field: 'ownerItemCd',
    width: 200,
    editable: true,
    cellEditor: CellEditorType.CodeName,
    cellEditorParams: {
      codeType: CodeNameType.ITEM,
      maxLength: 30,
      iconclick: (rowIndex: number) => {
        currentLookupRowIndex.value = rowIndex;
        currentLookupType.value = 'item';
        showLookupDialog.value = true;
      },
      retrieveParams: () => ({
        referenceKey1: itemAdminCd.value,
      }),
      retrieveData: (data: CodeNameResponse, rowIndex: number, rowData: SoDetail) => {
        rowData.itemName = data.name || '';
      },
    },
  },
  // Cột Select
  {
    headerName: t('label.soType'),
    field: 'soType',
    width: 120,
    editable: true,
    cellEditor: CellEditorType.Select,
    cellEditorParams: {
      items: soTypeItems.value,
      rules: [{ required: true, message: t('validation.soTypeRequired') }],
    },
  },
  // Cột chỉ đọc: trường hợp editable: false
  // - Chỉ cột Date/DateTime mới chỉ định cellEditor (dùng để định dạng hiển thị)
  // - Các cột không phải Date như Select/Input/Number thì không chỉ định cellEditor / cellEditorParams
  { headerName: t('label.soNo'), field: 'soNo', width: 205, editable: false },
  {
    headerName: t('label.shipSchDate'),
    field: 'shipSchDate',
    width: 205,
    editable: false,
    cellEditor: CellEditorType.Date,
  },
  { headerName: t('label.status'), field: 'status', width: 205, editable: false },
  // Cột ghi chú có giới hạn số ký tự
  {
    headerName: t('label.remarks'),
    field: 'remarks',
    width: 200,
    editable: true,
    cellEditor: CellEditorType.Input,
    cellEditorParams: { maxLength: 50 },
  },
]);
```

> **⚠️ Checklist columnDefs:**
>
> - [ ] "Số ký tự" trong tài liệu thiết kế → `cellEditorParams.maxLength` (chỉ với cột editable: true)
> - [ ] "Bắt buộc" trong tài liệu thiết kế → `cellEditorParams.rules: [{ required: true, message: t('...') }]`
> - [ ] Cột thao tác → `cellRenderer: CellEditorType.Action` + `cellRendererParams.actions` (không phải `cellEditor`)
> - [ ] Cột CodeName → chỉ định đầy đủ `codeType`, `iconclick`, `retrieveParams`, `retrieveData`
> - [ ] Cột Select → truyền `.value` của ref vào `items` (**cấm mảng rỗng `[]`**)
> - [ ] Cột Number nếu cũng có giới hạn số ký tự thì chỉ định `maxLength`
> - [ ] **🚫 Cấm cellEditor ở cột không chỉnh sửa (`editable: false`)**: **chỉ** cột Date/DateTime mới chỉ định `cellEditor` (dùng để định dạng hiển thị). **Cột Select/Input/Number tuyệt đối không chỉ định cả `cellEditor` lẫn `cellEditorParams`**. Vi phạm sẽ gây render DOM không cần thiết
> - [ ] headerName dùng `t('label.xxx')`. Cấm `t('grid.xxx')`

## paginationSettings

```ts
import { GLOBAL_CONSTANTS } from '@/constants/globalConstants';

const paginationSettings = reactive({
  enabled: true,
  page: 1,
  size: GLOBAL_CONSTANTS.PAGINATION_SIZE,
  pageSizes: GLOBAL_CONSTANTS.PAGINATION_SIZES,
  total: 0,
});
```

> ⚠️ **Tên field là cố định:**
>
> - `page` (không phải `pageNumber`)
> - `size` (không phải `pageSize`)
> - `total` (không phải `totalCount`)
> - `pageSizes` — mảng các lựa chọn kích thước trang
> - `enabled` — cờ bật phân trang

## pageChanged

Trong callback của `@page-changed` / `@page-size-changed`, ghi ngược lại `page` và `size`.

```ts
function pageChanged(params: { page: number; size: number }) {
  paginationSettings.page = params.page;
  paginationSettings.size = params.size;
  getData();
}
```

## getData()

Với phân trang phía server thì **bắt buộc phải truyền `page` và `size` cho API**.
**Thống nhất dùng `async/await`** (không trộn lẫn với chuỗi `.then()`).

```ts
async function getData(): Promise<void> {
  gridLoading.value = true;
  try {
    const res = await SoPlanSearchApi.search({
      ownerCd: form.ownerCd,
      warehouseCd: form.warehouseCd,
      // ... các điều kiện tìm kiếm khác
      page: paginationSettings.page,
      size: paginationSettings.size,
    });
    gridData.value = res.data || [];
    paginationSettings.total = res.metadata?.total || 0;
  } finally {
    gridLoading.value = false;
  }
}
```

> ⚠️ **Checklist getData():**
>
> - [ ] Đã truyền `page: paginationSettings.page` và `size: paginationSettings.size` chưa
> - [ ] `gridLoading.value = true` → gọi API → `gridLoading.value = false` trong `finally`
> - [ ] Đã gán total của response vào `paginationSettings.total` chưa
> - [ ] Đã viết bằng `async/await` chưa (chuỗi `.then()` không được khuyến nghị)
> - [ ] Khi tìm kiếm lần đầu, có reset `paginationSettings.page = 1` trước khi gọi không

## Hiển thị chi tiết con bằng cách mở rộng dòng (detail-grid)

Mẫu click vào dòng để mở rộng, lấy dữ liệu dòng chi tiết con (dòng detail) bất đồng bộ rồi hiển thị.
Truyền một object có `getDetailRowData` vào thuộc tính `:detail-grid`.

> **🚫 Điều cấm:** Nếu tài liệu thiết kế có mở rộng chi tiết thì bắt buộc dùng `:detail-grid` + slot `#detail`.
> **Cấm** cách triển khai tự quản lý ref `expandedRows` thủ công rồi hiển thị bảng HTML.
> Nếu dùng chức năng mở rộng gốc của SstGrid thì việc quản lý trạng thái mở rộng, loading và xử lý lỗi sẽ được thực hiện tự động.

### Template

```html
<SstGrid
  ref="gridRef"
  v-model="gridData"
  :column-defs="columnDefs"
  :detail-grid="detailGridConfig"
  filter
  :page-setting-item="paginationSettings"
  :show-index-column="false"
  sortable
  :toolbar-config="{ showColVis: true }"
  width="100%"
  @page-changed="pageChanged"
>
  <!-- slot detail: render tùy biến vùng mở rộng -->
  <template #detail="{ rows, loading, error }">
    <div v-if="loading">{{ t('information.codes.loading') }}</div>
    <div v-else-if="error">{{ error }}</div>
    <div v-else-if="!Array.isArray(rows) || rows.length === 0">{{ t('information.codes.noData') }}</div>
    <table v-else class="detail-table">
      <tbody>
        <tr v-for="(r, idx) in rows" :key="idx">
          <td>{{ r.message }}</td>
        </tr>
      </tbody>
    </table>
  </template>
</SstGrid>
```

### Định nghĩa detailGridConfig

`getDetailRowData` là hàm bất đồng bộ nhận dữ liệu dòng `data` và trả về `Promise<any[]>`.
Nó được gọi khi mở rộng, và kết quả được truyền vào `rows` của slot `#detail`.

```ts
const detailGridConfig = {
  getDetailRowData: ({ data }: { data: any }) => {
    const logId = data?.logId;
    const serviceKbn = data?.serviceKbn;
    if (!logId || !serviceKbn) return Promise.resolve([]);
    return LogSearchApi.coreLogPostLogSearchDetail({ logId, serviceKbn })
      .then((res) => res.data || [])
      .catch(() => {
        useMessage().error(t('errors.codes.efw-001-140-000-001'));
        return [];
      });
  },
};
```

### Interface DetailGridConfig

```ts
interface DetailGridConfig {
  /** Chiều cao vùng mở rộng (nếu không chỉ định thì tự động theo nội dung) */
  height?: number | string;
  /** Hàm bất đồng bộ nhận dữ liệu dòng và trả về dữ liệu chi tiết con */
  getDetailRowData: (params: { data: any }) => any[] | Promise<any[]>;
}
```

### Scope của slot #detail

| Thuộc tính | Kiểu      | Mô tả                                             |
| ---------- | --------- | ------------------------------------------------- |
| rows       | `any[]`   | Dữ liệu chi tiết con do `getDetailRowData` trả về |
| loading    | `boolean` | Cờ đang lấy dữ liệu                               |
| error      | `string`  | Thông báo lỗi (khi lấy dữ liệu thất bại)          |

> **⚠️ Checklist detail-grid:**
>
> - [ ] Truyền vào `:detail-grid` một object có `getDetailRowData`
> - [ ] `getDetailRowData` trả về `Promise` (mảng đồng bộ cũng được)
> - [ ] Trong slot `#detail` xử lý đầy đủ các trường hợp `loading` / `error` / mảng rỗng
> - [ ] Lấy các key cần thiết từ `data` của dòng mở rộng và truyền cho API
> - [ ] Khi có lỗi thì thông báo cho người dùng bằng `useMessage().error()`
> - [ ] **Cấm triển khai thủ công bằng expandedRows + v-if + bảng HTML** (bắt buộc dùng `:detail-grid`)

## Cột ẩn ban đầu (hiddenColumns)

Các cột được chỉ định "ẩn ban đầu" trong tài liệu thiết kế thì quản lý bằng ref `hiddenColumns` và truyền cho SstGrid.
Nhờ đó, người dùng có thể hiển thị chúng sau này từ menu chuyển đổi hiển thị cột (`showColVis: true`).

```ts
// Định nghĩa dưới dạng mảng các tên field của cột "ẩn ban đầu" trong tài liệu thiết kế
const hiddenColumns = ref<string[]>([
  'otherRefNo1',
  'otherRefNo2',
  'otherRefNo3',
  'address1',
  'address2',
  'address3',
  'postNo',
  'tel',
  'fax',
  'addUserCd',
  'addUserName',
  'updDateTime',
  'updUserCd',
  'updUserName',
]);
```

```html
<SstGrid
  ref="gridRef"
  v-model="gridData"
  :column-defs="columnDefs"
  filter
  :hidden-columns="hiddenColumns"
  :loading="gridLoading"
  :page-setting-item="paginationSettings"
  pagination-mode="server"
  sortable
  :toolbar-config="{ showColVis: true, showExport: true }"
  width="100%"
  @page-changed="pageChanged"
  @page-size-changed="pageChanged"
/>
```

> **⚠️ Checklist hiddenColumns:**
>
> - [ ] Đưa tất cả các cột được chỉ định "ẩn ban đầu" trong tài liệu thiết kế vào `hiddenColumns`
> - [ ] Field nằm trong `hiddenColumns` cũng phải được định nghĩa trong `columnDefs` (không có định nghĩa thì không thể ẩn)
> - [ ] Chỉ định `showColVis: true` trong `:toolbar-config` để bật menu chuyển đổi hiển thị cột
