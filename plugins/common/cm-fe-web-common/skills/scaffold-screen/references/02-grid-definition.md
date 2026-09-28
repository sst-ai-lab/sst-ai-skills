# グリッド定義

SstGrid の使い方、columnDefs の書き方、ページネーション。

## 読み取り専用グリッド（検索画面）

検索画面のグリッドは**サーバーサイドページネーション**を使用する。
**`pagination-mode="server"` を明示的に指定すること**（省略しない）。

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

必須イベント:

- `@page-changed` + `@page-size-changed` → ページ変更時にデータを再取得
- `@selection-changed` → 選択行に基づいてボタンの有効/無効を制御（下記パターン参照）
- `:loading="gridLoading"` → API呼び出し中にローディング表示

### onSelectionChanged の実装パターン

`@selection-changed` のコールバックは `event.selectRows` で選択行配列を受け取る。
ボタンの `disabled` を制御する場合は以下のパターンを使う:

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

> ⚠️ **`event.selectRows`** を使う。`event.api.getSelectedRows()` 等の AG Grid API 直接呼出しは禁止。

## 編集可能グリッド（メンテナンス画面）

編集可能なグリッドは**クライアントサイドページネーション**。
`pagination-mode="client"` を明示的に指定する。

**⚠️ 編集可能グリッドには `:tab` を指定すること。** フォーム入力コンポーネントと同様に、グリッドにもタブオーダーを割り当て、Tab キーでグリッドにフォーカスできるようにする。`:tab` の番号は、直前のフォーム入力フィールドの次の番号を使う。

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

## columnDefs の cellEditor 対応表

| 設計書コンポーネント | CellEditorType            |
| -------------------- | ------------------------- |
| SstInputColumn       | `CellEditorType.Input`    |
| SstNumberInputColumn | `CellEditorType.Number`   |
| SstSelectColumn      | `CellEditorType.Select`   |
| SstDateColumn        | `CellEditorType.Date`     |
| SstDateTimeColumn    | `CellEditorType.DateTime` |
| SstTimeColumn        | `CellEditorType.Time`     |
| SstButtonColumn      | `CellEditorType.Button`   |
| SstCheckboxColumn    | `CellEditorType.Checkbox` |
| SstActionColumn      | `CellEditorType.Action`   |
| SstCodeNameColumn    | `CellEditorType.CodeName` |
| SstProcessColumn     | `CellEditorType.Process`  |

## columnDefs 実装例

```ts
import { CellEditorType } from '@sst-cm/sst-fw-web';

// ⚠️ columnDefs は必ず computed で囲む（t() を使うため言語切替に対応）
const columnDefs = computed<ColumnDef[]>(() => [
  // 操作列（Action）: cellRenderer + cellRendererParams.actions
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
  // 通常入力列: maxLength + rules
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
  // CodeName列
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
  // Select列
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
  // 読み取り専用列: editable: false の場合
  // - Date/DateTime 列のみ cellEditor を指定する（表示フォーマット用）
  // - Select/Input/Number 等の非 Date 列は cellEditor / cellEditorParams を指定しない
  { headerName: t('label.soNo'), field: 'soNo', width: 205, editable: false },
  {
    headerName: t('label.shipSchDate'),
    field: 'shipSchDate',
    width: 205,
    editable: false,
    cellEditor: CellEditorType.Date,
  },
  { headerName: t('label.status'), field: 'status', width: 205, editable: false },
  // 桁数ありの備考列
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

> **⚠️ columnDefs チェックリスト:**
>
> - [ ] 設計書の「桁数」→ `cellEditorParams.maxLength`（editable: true の列のみ）
> - [ ] 設計書の「必須」→ `cellEditorParams.rules: [{ required: true, message: t('...') }]`
> - [ ] 操作列 → `cellRenderer: CellEditorType.Action` + `cellRendererParams.actions`（`cellEditor` ではない）
> - [ ] CodeName列 → `codeType`, `iconclick`, `retrieveParams`, `retrieveData` すべて指定
> - [ ] Select列 → `items` に ref の `.value` を渡す（**空配列 `[]` 禁止**）
> - [ ] Number列にも桁数があれば `maxLength` を指定
> - [ ] **🚫 非編集列（`editable: false`）の cellEditor 禁止**: Date/DateTime 列**のみ** `cellEditor` を指定（表示フォーマット用）。**Select/Input/Number 列は `cellEditor` も `cellEditorParams` も絶対に指定しない**。違反すると不要な DOM レンダリングが発生する
> - [ ] headerName は `t('label.xxx')` を使う。`t('grid.xxx')` 禁止

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

> ⚠️ **フィールド名は固定:**
>
> - `page`（`pageNumber` ではない）
> - `size`（`pageSize` ではない）
> - `total`（`totalCount` ではない）
> - `pageSizes` — ページサイズ選択肢配列
> - `enabled` — ページネーション有効フラグ

## pageChanged

`@page-changed` / `@page-size-changed` のコールバックで `page` と `size` を書き戻す。

```ts
function pageChanged(params: { page: number; size: number }) {
  paginationSettings.page = params.page;
  paginationSettings.size = params.size;
  getData();
}
```

## getData()

サーバーサイドページネーションでは **`page` と `size` を必ず API に渡す**。
**`async/await` で統一する**（`.then()` チェーンと混在させない）。

```ts
async function getData(): Promise<void> {
  gridLoading.value = true;
  try {
    const res = await SoPlanSearchApi.search({
      ownerCd: form.ownerCd,
      warehouseCd: form.warehouseCd,
      // ... 他の検索条件
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

> ⚠️ **getData() チェックリスト:**
>
> - [ ] `page: paginationSettings.page` と `size: paginationSettings.size` を渡しているか
> - [ ] `gridLoading.value = true` → API呼出し → `finally` で `gridLoading.value = false`
> - [ ] `paginationSettings.total` にレスポンスの total を代入しているか
> - [ ] `async/await` で書いているか（`.then()` チェーンは非推奨）
> - [ ] 初回検索時は `paginationSettings.page = 1` にリセットしてから呼ぶか

## 行展開による子明細表示（detail-grid）

行をクリックして展開し、子明細行（ディテール行）を非同期取得して表示するパターン。
`:detail-grid` プロパティに `getDetailRowData` を持つオブジェクトを渡す。

> **🚫 禁止事項:** 設計書に明細展開がある場合、必ず `:detail-grid` + `#detail` スロットを使用すること。
> 手動で `expandedRows` ref を管理して HTML テーブルを表示する実装は**禁止**。
> SstGrid のネイティブ展開機能を使えば、展開状態管理・ローディング・エラーハンドリングが自動的に行われる。

### テンプレート

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
  <!-- detail スロット: 展開領域のカスタムレンダリング -->
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

### detailGridConfig 定義

`getDetailRowData` は行データ `data` を受け取り、`Promise<any[]>` を返す非同期関数。
展開時に呼び出され、結果が `#detail` スロットの `rows` に渡される。

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

### DetailGridConfig インターフェース

```ts
interface DetailGridConfig {
  /** 展開領域の高さ（指定しない場合は内容に応じて自動） */
  height?: number | string;
  /** 行データを受け取り、子明細データを返す非同期関数 */
  getDetailRowData: (params: { data: any }) => any[] | Promise<any[]>;
}
```

### #detail スロットのスコープ

| プロパティ | 型        | 説明                                    |
| ---------- | --------- | --------------------------------------- |
| rows       | `any[]`   | `getDetailRowData` が返した子明細データ |
| loading    | `boolean` | データ取得中フラグ                      |
| error      | `string`  | エラーメッセージ（取得失敗時）          |

> **⚠️ detail-grid チェックリスト:**
>
> - [ ] `:detail-grid` に `getDetailRowData` を持つオブジェクトを渡す
> - [ ] `getDetailRowData` は `Promise` を返す（同期配列も可）
> - [ ] `#detail` スロットで `loading` / `error` / 空配列のケースを全てハンドリングする
> - [ ] 展開行から必要なキーを `data` から取り出して API に渡す
> - [ ] エラー時は `useMessage().error()` でユーザーに通知する
> - [ ] **手動の expandedRows + v-if + HTML テーブルによる実装は禁止**（必ず `:detail-grid` を使う）

## 初期非表示列（hiddenColumns）

設計書で「初期非表示」と指定されている列は、`hiddenColumns` ref で管理し SstGrid に渡す。
これにより、ユーザーは列表示切替メニュー（`showColVis: true`）から後から表示できる。

```ts
// 設計書の「初期非表示」列の field 名を配列で定義
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

> **⚠️ hiddenColumns チェックリスト:**
>
> - [ ] 設計書に「初期非表示」指定がある列をすべて `hiddenColumns` に含める
> - [ ] `hiddenColumns` に含まれる field は `columnDefs` にも定義されていること（定義がなければ非表示にできない）
> - [ ] `:toolbar-config` に `showColVis: true` を指定して列表示切替メニューを有効にする
