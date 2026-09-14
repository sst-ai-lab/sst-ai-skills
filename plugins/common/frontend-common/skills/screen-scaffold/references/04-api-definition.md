# API定義

API型定義・ラッパー・ client.ts・DropDown・CodeName・CodeNameType。

## 入力パラメータマッピング表 → リクエスト実装（詳細設計書・必読）

詳細設計書の各APIコールステップに付く「入力パラメータマッピング」表（`パラメータ名`/`項目名`/`取得元`）は、
リクエストオブジェクトの各フィールドの値をどこから取ってくるかをそのまま指定している。
`取得元` 列の記載は次の対応でコードに落とし込む（表にない独自の取得先を作らない）。

| `取得元` の記載                                                 | コードでの取得パターン                                                                          |
| --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------- |
| 画面項目 / 入力.xxx                                             | `form.xxx`（フォームの該当フィールド）                                                          |
| グリッド行 / タブ                                               | `gridData.value` の該当行、またはタブ配列（`tabItems.value[i].xxx`）                            |
| ログイン情報 / システム共通情報（会社コード・ログインユーザ等） | 認証・ユーザーストア（例: `useAuthStore()`/`useUserStore()`）から取得。自前でハードコードしない |
| 取得APIレスポンス値（他ステップで取得済みの値）                 | 直前に呼んだAPIの結果を保持した `ref`/`computed` を参照する                                     |
| システム日時・自動採番等                                        | サーバー側で設定される値のため、原則リクエストに含めない（表に明記されている場合のみ含める）    |
| `（基本設計に記載なし）🔴【要詳細設計】` 等のマーカー           | 推測でフィールドを埋めない。`init.md` ルール#49 に従い実装を止めてユーザーに質問する            |

## {機能名}.types.ts（View層型定義）

```ts
import type { CellEditorType } from '@sst-cm/sst-fw-web';

export type Form = {
  // 設計書の項目定義から生成
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

> **🚨 型の手書き禁止（最重要ルール）**
> ApiType.ts では **必ず `@sst-cm/fe-web-client` が公開する `Web.*` 型を alias して使う**。
> 自前で `Record<string, unknown>` やオブジェクトリテラル型を定義してはならない。
> 正しい型名が分からない場合は `node_modules/@sst-cm/fe-web-client/dist/index.d.ts` を検索すること。

```ts
import type { Web } from '@sst-cm/fe-web-client';

// ⚠️ APIには2種類の型がある:
// - ラッパー型（WebCoreSoSoMainteGetSoRequest）: APIメソッドの引数型 { soMainteGetSoRequest: ... }
// - 内部型（SoMainteGetSoRequest）: リクエストボディ型
// → ApiType.ts には「内部型」を定義

type {リクエスト型名} = Web.{内部リクエスト型名};
type {レスポンス型名} = Web.{内部レスポンス型名};

export type { {リクエスト型名}, {レスポンス型名} };
```

```ts
// ❌ 禁止: 手書き型
type SoPlanCreateGetSoResponse = {
  soHeader?: Record<string, unknown>;
  soDetail?: Record<string, unknown>[];
};

// ✅ 正しい: fe-web-client の型を alias
type SoPlanCreateGetSoResponse = Web.CoreSoPostSearchResponse;
```

## {機能名}Api.ts

> **⚠️ `apiCall` vs `apiCallWithLoading` の使い分け:**
>
> - **`apiCall`** — 読み取り系（検索・取得・ドロップダウン）。ローディング表示なし
> - **`apiCallWithLoading`** — 書き込み系・バッチ操作（保存・削除・確定・引当・実績登録等）。グローバルローディング表示
>
> 原則: ユーザーが「完了を待つ」操作 → `apiCallWithLoading`。「裏で取得」→ `apiCall`。

```ts
import type { {リクエスト型名}, {レスポンス型名} } from './{機能名}ApiType';
import { apiCall, apiCallWithLoading } from '@/composables/sstApiRequest';
import { {APIクライアント変数名} } from '@/libs/client';

export const {機能名Pascal}Api = {
  {メソッド名}: async (payload: {リクエスト型名}): Promise<{レスポンス型名}> => {
    const response = await {APIクライアント変数名}.{OpenAPI生成メソッド名}({
      // ⚠️ キー名はラッパー型のプロパティ名（lowerCamelCase）
      // 確認: node_modules/@sst-cm/fe-web-client/dist/index.d.ts で検索
      {リクエストパラメータ名}: payload,
    });
    return response;
  },
};
```

## localeCd（言語コード）の注入ルール

> **設計書の SQL で「言語コード」列を使用している API は `localeCd` を注入する。**
> 設計書のSQL定義・検索条件に `言語コード`（locale_cd 等）が含まれる場合、
> リクエストに `localeCd` を追加してからAPIを呼び出す。

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
        // ⚠️ localeCd を先頭に注入
        webCoreSoSoPlanCreateSearchSoInfoRequest: { localeCd: getLocaleCd(), ...payload },
      }),
    );
  },
};
```

> 判断基準:
>
> - 設計書SQL内に `言語コード` / `locale_cd` / `LOCALE_CD` がある → **`localeCd` 必要**
> - ない → 不要（余計に付けない）

## libs/client.ts への追加

```ts
// ⚠️ Web名前空間内でもWebプレフィックスが必要
// 誤: new Web.CoreSoSoMainteApi(configuration)
// 正: new Web.WebCoreSoSoMainteApi(configuration)

const {機能名Camel}ApiClient = new Web.{フルクラス名}(configuration);
export { {機能名Camel}ApiClient };
```

## DropDownAPI

ドロップダウンリストは `DropDownApi.coreCommonPostDropDown` で取得する。

> **⚠️ Grid の Select 列用ドロップダウンも忘れずに取得すること。**

```ts
import { DropDownApi } from '{dropDownApiDir}/dropDownApi';
import type { DropdownResponse } from '{dropDownApiDir}/dropDownApiType';

// ⚠️ メソッド名: coreCommonPostDropDown（getDropDown ではない）
// ⚠️ プロパティ名: codeCategoryKey（category ではない）

// 設計書に code1/code2/code3 の指定がある場合
function getDropdownItems(key: string, code1: string, code2: string, code3: string) {
  return DropDownApi.coreCommonPostDropDown({
    codeCategoryKey: key,
    code1,
    code2,
    code3,
  });
}

// init() で一括取得
const [soTypeRes, statusRes, actFlgRes] = await Promise.all([
  getDropdownItems('SOTYPE', '', '*', '*'),
  getDropdownItems('SOSTATUS', '', '*', '*'),
  getDropdownItems('ACTFLG', '', '*', '*'),
]);
soTypeItems.value = soTypeRes?.data ?? [];
statusItems.value = statusRes?.data ?? [];
actFlgItems.value = actFlgRes?.data ?? [];

// 設計書に code1/code2/code3 の指定がない場合は codeCategoryKey のみ
const billTypeRes = await DropDownApi.coreCommonPostDropDown({ codeCategoryKey: 'BILLTYPE' });
```

> ⚠️ レスポンスのフィールド名は `value` と `label`。
> `SstSelect` に渡す際は `item-title` / `item-value` 指定不要。
> `item-title="name"` にすると `[object Object]` が表示される。

## CodeNameResponse の型とキャスト

> **⚠️ `@retrieve-data` ハンドラの実装は省略禁止**（`v-model:name` を使う `SstCodeName` すべてに必要。init.md 規則 #54）。`String()` ではなく `sstUtil().toString()` を使う（init.md 注意事項「sstUtil を優先使用」）。

```ts
// data.name は object 型 → sstUtil().toString() でキャストする
const handleFetchOwnerCd = (data?: CodeNameResponse): void => {
  form.ownerName = data?.data?.name != null ? sstUtil().toString(data.data.name) : '';
};
```

## CodeNameType 定数

`SstCodeName` の `:code-type` に渡す値。**`src/constants/codeNameType.ts`** に `as const` オブジェクト + union literal type で定義する（アプリ全体で横断的に使う値のため `src/constants/` 配下。ネイティブ `enum` は使わない）。`src/composables/sstCodeNameApi.ts` には置かない（compose 層は API 呼び出しの責務のみ）。

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
// 利用側（constants は auto-import 対象外 → 明示 import が必須）
import { CodeNameType } from '@/constants/codeNameType';
```

```vue
<SstCodeName v-model:name="form.ownerName" v-model:code="form.ownerCd" :code-type="CodeNameType.OWNER" />
```

> ⚠️ 定義されていない値がある場合は、`src/constants/codeNameType.ts` の `CodeNameType` に追加してから使う。文字列リテラルで直接渡すのは禁止（init.md 規則 #29）。
>
> ```ts
> // src/constants/codeNameType.ts に追加
> export const CodeNameType = {
>   OWNER: 'OWNER',
>   WAREHOUSE: 'WAREHOUSE',
>   ITEM: 'ITEM',
>   EDICONVERT: 'EDICONVERT',
>   SHIPPER: 'SHIPPER', // ← 追加
>   DELIVERY: 'DELIVERY', // ← 追加
> } as const;
> export type CodeNameType = (typeof CodeNameType)[keyof typeof CodeNameType];
> ```
>
> 📌 `CodeNameType` 以外で新規にこの種の固定値集合（状態値・区分値）を追加する場合も同じパターン（`as const` オブジェクト + union literal type、`src/constants/` 配下）に従うこと。
>
> ```ts
> // src/constants/xxxType.ts（新規に固定値集合を追加する場合の模範パターン）
> export const XxxType = {
>   FOO: 'FOO',
>   BAR: 'BAR',
> } as const;
> export type XxxType = (typeof XxxType)[keyof typeof XxxType];
> ```

## 型マッピング（設計書属性 → TypeScript型）

| 設計書属性 | TypeScript型     |
| ---------- | ---------------- |
| 文字       | `string`         |
| 数値       | `number \| null` |
| 日付       | `string`         |
| 日時       | `string`         |
| ツリー     | 別途定義         |
