# Định nghĩa API

Định nghĩa kiểu API, wrapper, client.ts, DropDown, CodeName, CodeNameType.

## Bảng mapping tham số đầu vào → triển khai request (詳細設計書 (tài liệu thiết kế chi tiết), bắt buộc đọc)

Bảng "入力パラメータマッピング" (`パラメータ名`/`項目名`/`取得元`) gắn với từng bước gọi API trong 詳細設計書
chỉ định nguyên văn việc lấy giá trị của từng field trong object request từ đâu.
Nội dung ở cột `取得元` được chuyển thành code theo các đối chiếu sau (không tự tạo nguồn lấy dữ liệu riêng không có trong bảng).

| Nội dung ghi ở `取得元`                                                     | Mẫu lấy giá trị trong code                                                                                    |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| Mục trên màn hình / 入力.xxx                                                | `form.xxx` (field tương ứng của form)                                                                         |
| Dòng grid / tab                                                             | Dòng tương ứng của `gridData.value`, hoặc mảng tab (`tabItems.value[i].xxx`)                                   |
| Thông tin đăng nhập / thông tin chung hệ thống (mã công ty, user đăng nhập…) | Lấy từ store xác thực, store user (ví dụ: `useAuthStore()`/`useUserStore()`). Không tự hardcode                |
| Giá trị response của API lấy dữ liệu (giá trị đã lấy ở bước khác)           | Tham chiếu `ref`/`computed` đang giữ kết quả của API vừa gọi trước đó                                          |
| Ngày giờ hệ thống, tự động sinh số…                                         | Là giá trị được set ở phía server nên về nguyên tắc không đưa vào request (chỉ đưa vào khi bảng ghi rõ)        |
| Marker như `（基本設計に記載なし）🔴【要詳細設計】`                          | Không điền field theo suy đoán. Theo quy tắc #49 của `init.md`, dừng triển khai và hỏi người dùng              |

## {機能名}.types.ts (định nghĩa kiểu tầng View)

```ts
import type { CellEditorType } from '@sst-cm/sst-fw-web';

export type Form = {
  // Sinh từ 項目定義 (định nghĩa mục) của tài liệu thiết kế
};

export type ColumnDef = {
  headerName: string;
  field: string;
  width: number;
  editable: boolean;
  cellEditor: CellEditorType;
};

export type PaginationSettings = {
  enabled: boolean;
  page: number;
  size: number;
  pageSizes: number[];
  total: number;
};
```

## {機能名}ApiType.ts

> **🚨 Cấm viết kiểu bằng tay (quy tắc quan trọng nhất)**
> Trong ApiType.ts **bắt buộc phải alias và dùng các kiểu `Web.*` mà `@sst-cm/fe-web-client` công bố**.
> Không được tự định nghĩa `Record<string, unknown>` hay kiểu object literal.
> Nếu không biết tên kiểu đúng thì hãy tìm trong `node_modules/@sst-cm/fe-web-client/dist/index.d.ts`.

```ts
import type { Web } from '@sst-cm/fe-web-client';

// ⚠️ API có 2 loại kiểu:
// - Kiểu wrapper (WebCoreSoSoMainteGetSoRequest): kiểu tham số của method API { soMainteGetSoRequest: ... }
// - Kiểu nội bộ (SoMainteGetSoRequest): kiểu body của request
// → Trong ApiType.ts định nghĩa "kiểu nội bộ"

type {リクエスト型名} = Web.{内部リクエスト型名};
type {レスポンス型名} = Web.{内部レスポンス型名};

export type { {リクエスト型名}, {レスポンス型名} };
```

```ts
// ❌ Cấm: kiểu viết tay
type SoPlanCreateGetSoResponse = {
  soHeader?: Record<string, unknown>;
  soDetail?: Record<string, unknown>[];
};

// ✅ Đúng: alias kiểu của fe-web-client
type SoPlanCreateGetSoResponse = Web.CoreSoPostSearchResponse;
```

## {機能名}Api.ts

> **⚠️ Phân biệt sử dụng `apiCall` và `apiCallWithLoading`:**
>
> - **`apiCall`** — loại đọc (tìm kiếm, lấy dữ liệu, dropdown). Không hiển thị loading
> - **`apiCallWithLoading`** — loại ghi, thao tác theo lô (lưu, xóa, xác định, phân bổ, đăng ký thực tế v.v.). Hiển thị loading toàn cục
>
> Nguyên tắc: thao tác mà người dùng "chờ hoàn tất" → `apiCallWithLoading`. "Lấy dữ liệu ở hậu trường" → `apiCall`.

```ts
import type { {リクエスト型名}, {レスポンス型名} } from './{機能名}ApiType';
import { apiCall, apiCallWithLoading } from '@/composables/sstApiRequest';
import { {APIクライアント変数名} } from '@/libs/client';

export const {機能名Pascal}Api = {
  {メソッド名}: async (payload: {リクエスト型名}): Promise<{レスポンス型名}> => {
    const response = await {APIクライアント変数名}.{OpenAPI生成メソッド名}({
      // ⚠️ Tên key là tên thuộc tính của kiểu wrapper (lowerCamelCase)
      // Kiểm tra: tìm trong node_modules/@sst-cm/fe-web-client/dist/index.d.ts
      {リクエストパラメータ名}: payload,
    });
    return response;
  },
};
```

## Quy tắc chèn localeCd (mã ngôn ngữ)

> **API mà SQL trong tài liệu thiết kế có dùng cột "mã ngôn ngữ" thì phải chèn `localeCd`.**
> Nếu định nghĩa SQL hoặc điều kiện tìm kiếm trong tài liệu thiết kế có chứa `言語コード` (locale_cd v.v.),
> thì thêm `localeCd` vào request rồi mới gọi API.

```ts
import { GLOBAL_CONSTANTS } from '@/constants/globalConstants';
import { useUserThemeStore } from '@/stores/userTheme';

function getLocaleCd(): string {
  const userThemeStore = useUserThemeStore();
  return userThemeStore.language ? GLOBAL_CONSTANTS.MAPPED_LOCALES[userThemeStore.language] : '1';
}

export const SoPlanCreateApi = {
  getSoInfo: async (payload: SoPlanCreateGetSoRequest): Promise<SoPlanCreateGetSoResponse> => {
    return await apiCall(() =>
      soPlanCreateApiClient.webCoreSoSoPlanCreateSearchSoInfo({
        // ⚠️ Chèn localeCd lên đầu
        webCoreSoSoPlanCreateSearchSoInfoRequest: { localeCd: getLocaleCd(), ...payload },
      }),
    );
  },
};
```

> Tiêu chí phán đoán:
>
> - Trong SQL của tài liệu thiết kế có `言語コード` / `locale_cd` / `LOCALE_CD` → **cần `localeCd`**
> - Không có → không cần (không thêm dư thừa)

## Thêm vào libs/client.ts

```ts
// ⚠️ Ngay cả trong namespace Web vẫn cần prefix Web
// Sai: new Web.CoreSoSoMainteApi(configuration)
// Đúng: new Web.WebCoreSoSoMainteApi(configuration)

const {機能名Camel}ApiClient = new Web.{フルクラス名}(configuration);
export { {機能名Camel}ApiClient };
```

## DropDownAPI

Danh sách dropdown được lấy bằng `DropDownApi.coreCommonPostDropDown`.

> **⚠️ Đừng quên lấy cả dropdown cho cột Select của Grid.**

```ts
import { DropDownApi } from '{dropDownApiDir}/dropDownApi';
import type { DropdownResponse } from '{dropDownApiDir}/dropDownApiType';

// ⚠️ Tên method: coreCommonPostDropDown (không phải getDropDown)
// ⚠️ Tên thuộc tính: codeCategoryKey (không phải category)

// Trường hợp tài liệu thiết kế có chỉ định code1/code2/code3
function getDropdownItems(key: string, code1: string, code2: string, code3: string) {
  return DropDownApi.coreCommonPostDropDown({
    codeCategoryKey: key,
    code1,
    code2,
    code3,
  });
}

// Lấy đồng loạt trong init()
const [soTypeRes, statusRes, actFlgRes] = await Promise.all([
  getDropdownItems('SOTYPE', '', '*', '*'),
  getDropdownItems('SOSTATUS', '', '*', '*'),
  getDropdownItems('ACTFLG', '', '*', '*'),
]);
soTypeItems.value = soTypeRes?.data ?? [];
statusItems.value = statusRes?.data ?? [];
actFlgItems.value = actFlgRes?.data ?? [];

// Nếu tài liệu thiết kế không chỉ định code1/code2/code3 thì chỉ truyền codeCategoryKey
const billTypeRes = await DropDownApi.coreCommonPostDropDown({ codeCategoryKey: 'BILLTYPE' });
```

> ⚠️ Tên field của response là `value` và `label`.
> Khi truyền cho `SstSelect` thì không cần chỉ định `item-title` / `item-value`.
> Nếu đặt `item-title="name"` thì sẽ hiển thị `[object Object]`.

## Kiểu và cast của CodeNameResponse

> **⚠️ Cấm bỏ qua việc triển khai handler `@retrieve-data`** (cần cho mọi `SstCodeName` dùng `v-model:name`. Quy tắc #54 của init.md). Dùng `sstUtil().toString()` thay vì `String()` (mục lưu ý của init.md "Ưu tiên dùng sstUtil").

```ts
// data.name có kiểu object → cast bằng sstUtil().toString()
const handleFetchOwnerCd = (data?: CodeNameResponse): void => {
  form.ownerName = data?.data?.name != null ? sstUtil().toString(data.data.name) : '';
};
```

## Hằng số CodeNameType

Giá trị truyền vào `:code-type` của `SstCodeName`. Định nghĩa trong **`src/constants/codeNameType.ts`** dưới dạng object `as const` + union literal type (vì là giá trị dùng xuyên suốt toàn ứng dụng nên đặt dưới `src/constants/`. Không dùng `enum` native). Không đặt trong `src/composables/sstCodeNameApi.ts` (tầng compose chỉ chịu trách nhiệm gọi API).

```ts
// src/constants/codeNameType.ts
export const CodeNameType = {
  OWNER: 'OWNER',
  WAREHOUSE: 'WAREHOUSE',
  ITEM: 'ITEM',
  EDICONVERT: 'EDICONVERT',
} as const;
export type CodeNameType = (typeof CodeNameType)[keyof typeof CodeNameType];
```

```ts
// Phía sử dụng (constants không thuộc đối tượng auto-import → bắt buộc import tường minh)
import { CodeNameType } from '@/constants/codeNameType';
```

```vue
<SstCodeName v-model:name="form.ownerName" v-model:code="form.ownerCd" :code-type="CodeNameType.OWNER" />
```

> ⚠️ Nếu có giá trị chưa được định nghĩa thì phải thêm vào `CodeNameType` trong `src/constants/codeNameType.ts` rồi mới dùng. Cấm truyền trực tiếp bằng string literal (quy tắc #29 của init.md).
>
> ```ts
> // Thêm vào src/constants/codeNameType.ts
> export const CodeNameType = {
>   OWNER: 'OWNER',
>   WAREHOUSE: 'WAREHOUSE',
>   ITEM: 'ITEM',
>   EDICONVERT: 'EDICONVERT',
>   SHIPPER: 'SHIPPER', // ← thêm
>   DELIVERY: 'DELIVERY', // ← thêm
> } as const;
> export type CodeNameType = (typeof CodeNameType)[keyof typeof CodeNameType];
> ```
>
> 📌 Khi thêm mới tập giá trị cố định loại này (giá trị trạng thái, giá trị phân loại) ngoài `CodeNameType` thì cũng tuân theo cùng mẫu (object `as const` + union literal type, đặt dưới `src/constants/`).
>
> ```ts
> // src/constants/xxxType.ts (mẫu chuẩn khi thêm mới tập giá trị cố định)
> export const XxxType = {
>   FOO: 'FOO',
>   BAR: 'BAR',
> } as const;
> export type XxxType = (typeof XxxType)[keyof typeof XxxType];
> ```

## Mapping kiểu (thuộc tính trong tài liệu thiết kế → kiểu TypeScript)

| Thuộc tính thiết kế | Kiểu TypeScript  |
| ------------------- | ---------------- |
| Chuỗi               | `string`         |
| Số                  | `number \| null` |
| Ngày                | `string`         |
| Ngày giờ            | `string`         |
| Cây (tree)          | Định nghĩa riêng |
