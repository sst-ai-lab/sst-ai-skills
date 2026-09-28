# コードレビュー チェックリスト

レビュー時にすべての項目を確認する。違反があれば指摘すること。

`規約§` 列は `frontend-conventions.md`（公式フロントエンド開発規約）の対応節を示す。`—` は対応節なし（プロジェクト固有チェック）、`（相違）` は規約と内容が食い違う項目で、規約を優先する。

---

## 1. テンプレート規約

| #    | チェック項目                                                   | 重要度      | 違反例                                        | 正解                                                                                | 規約§ |
| ---- | -------------------------------------------------------------- | ----------- | --------------------------------------------- | ----------------------------------------------------------------------------------- | --- |
| T-01 | Sst コンポーネントは PascalCase                                | Critical    | `<sst-text-field>`                            | `<SstTextField>`                                                                    | 5.6 |
| T-02 | テンプレート内の日本語ハードコード禁止                         | Critical    | `"読み込み中..."`                             | `t('information.codes.loading')`                                                    | 5.8, 5.19 #3（3.1 相違） |
| T-03 | フォーム入力に `:tab` 属性あり（連番）                         | Improvement | `:tab` 省略                                   | `:tab="1"`, `:tab="2"` ...                                                          | 5.6 |
| T-04 | `SstCodeName` に `:code-type` 指定あり                         | Critical    | `:code-type` 省略                             | `:code-type="CodeNameType.OWNER"`                                                   | — |
| T-05 | ルックアップ付き `SstCodeName` に `:iconclick` あり            | Critical    | `:iconclick` 省略                             | `:iconclick="openLookup"`                                                           | — |
| T-06 | `:iconclick` 指定時に `SstDialog` + `CommonLookup` あり        | Critical    | Dialog 未実装                                 | 完全なダイアログ実装                                                                | — |
| T-10 | `v-model:name` 付き `SstCodeName` に `@retrieve-data` あり     | Critical    | ハンドラ未紐付け                              | `@retrieve-data="handleFetchXxx"`                                                   | —（3.1 相違） |
| T-07 | `v-html` 未使用（XSS リスク）                                  | Critical    | `v-html="userInput"`                          | `{{ sanitized }}` or `t()`                                                          | 5.19 #9（相違） |
| T-08 | `SstGrid` に `pagination-mode="server"` 明示（検索画面）       | Improvement | 省略                                          | `pagination-mode="server"`                                                          | — |
| T-09 | `SstSelect`/`SstRadio` の冗長な `item-title`/`item-value` 不要 | Nitpick     | `item-title="label" item-value="value"`       | 省略（デフォルト）                                                                  | — |
| T-11 | Vuetify ネイティブコンポーネントを直接使用しない               | Critical    | `<v-btn>`/`<v-text-field>`/`<v-card-text>` 等 | 対応する `Sst*` コンポーネント（`SstButton`/`SstTextField`/`SstCardText` 等）に置換 | — |

---

## 2. スクリプト規約（Composable / .vue `<script setup>`）

| #    | チェック項目                                                                   | 重要度      | 違反例                                       | 正解                                                                                    | 規約§ |
| ---- | ------------------------------------------------------------------------------ | ----------- | -------------------------------------------- | --------------------------------------------------------------------------------------- | --- |
| S-01 | 使用シンボルの明示的 import                                                    | Critical    | import 漏れ（auto-import 依存）              | `import { useI18n } from '@sst-cm/sst-fw-web'`                                          | 5.18（相違） |
| S-02 | 同一パッケージ import は1行に統合                                              | Critical    | 2行の `import ... from '@sst-cm/sst-fw-web'` | 1行にまとめる                                                                           | 5.10（相違） |
| S-03 | import 元が正しい                                                              | Critical    | `import { useI18n } from 'vue-i18n'`         | `from '@sst-cm/sst-fw-web'`                                                             | — |
| S-04 | Hotkey: `useSstHotkeyScope` + `useSstHotkey`                                   | Critical    | `registerHotkey('F3', ...)`                  | `const { useSstHotkey } = useSstHotkeyScope({ scope: ID }); useSstHotkey('f3', search)` | — |
| S-05 | Hotkey キー名は小文字                                                          | Improvement | `'F3'`                                       | `'f3'`                                                                                  | — |
| S-06 | `paginationSettings` フィールド名                                              | Critical    | `pageNumber` / `pageSize` / `totalCount`     | `page` / `size` / `total`                                                               | — |
| S-07 | `pageChanged` で `page`/`size` に書き戻し                                      | Critical    | `pageNumber = e.page`                        | `page.value = e.page; size.value = e.size`                                              | — |
| S-08 | `getData()` で `page`/`size` を API に渡す                                     | Critical    | ページネーション値の渡し漏れ                 | `api.search({ ...form, page, size })`                                                   | — |
| S-09 | `usePageChange` 使用時に `markClean()`/`confirmValueChanged()` 呼び出し        | Critical    | 宣言のみ                                     | 保存後 `markClean()`、画面離脱前 `confirmValueChanged()`                                | — |
| S-10 | `currentLookupKey` は `computed` + 大文字マッピング                            | Critical    | `ref('')` で直接代入                         | `computed(() => switch...)` で大文字化                                                  | — |
| S-11 | `.vue` にロジック肥大化していない                                              | Improvement | 50行超のビジネスロジック in `.vue`           | composable に切り出し                                                                   | 5.1 |
| S-12 | Memorize: `getMemorizeConfig`(onMounted) + `saveMemorizeConfig`(検索後)        | Improvement | 呼び出しタイミング不正                       | パターン通り                                                                            | — |
| S-13 | `localeCd` 注入は API 層のみ                                                   | Improvement | composable で `getLocaleCd()` 直接注入       | `{機能名}Api.ts` 内で注入                                                               | — |
| S-14 | 検索/保存前に `SstForm` の `validateAll()` 呼び出し                            | Critical    | バリデーション未実行                         | `if (!(await formRef.value?.validateAll())) return;`                                    | 5.16 |
| S-15 | `useMessage`/`useDialog`/`useNotification` は `@sst-cm/sst-fw-web` から import | Critical    | `vuetify` や別パッケージから import          | `import { useMessage } from '@sst-cm/sst-fw-web'`                                       | 5.16 |
| S-16 | `sstUtil()` は関数呼び出し（括弧あり）                                         | Critical    | `sstUtil.toString(...)`                      | `sstUtil().toString(...)`                                                               | 5.18 |
| S-17 | `reactive` は form オブジェクト、`ref` はリスト/単一値                         | Improvement | form に `ref({})` 使用                       | `reactive({})` で form、`ref([])` でリスト                                              | —（5.7, 5.16 相違） |
| S-18 | `reactive` オブジェクトに `.value` アクセスしない                              | Critical    | `form.value.field`                           | `form.field`（reactive は `.value` 不要）                                               | — |
| S-19 | `usePageChange` は `@sst-cm/sst-fw-web` から import                            | Critical    | 未 import / 別ソース                         | `import { usePageChange } from '@sst-cm/sst-fw-web'`                                    | — |

---

## 3. Grid (columnDefs) 規約

| #    | チェック項目                                          | 重要度      | 違反例                               | 正解                                                      | 規約§ |
| ---- | ----------------------------------------------------- | ----------- | ------------------------------------ | --------------------------------------------------------- | --- |
| G-01 | 入力列に `maxLength` 指定（Number列含む）             | Critical    | `cellEditorParams: {}`               | `cellEditorParams: { maxLength: 10 }`                     | — |
| G-02 | 必須入力列に `rules` 指定                             | Critical    | rules 漏れ                           | `rules: [{ required: true, message: t('...') }]`          | — |
| G-03 | 操作列は `cellRenderer`（`cellEditor` ではない）      | Critical    | `cellEditor: CellEditorType.Action`  | `cellRenderer: CellEditorType.Action`                     | — |
| G-04 | Grid headerName は `t('label.xxx')`                   | Improvement | `t('grid.xxx')` 独自名前空間         | `t('label.columnName')`                                   | 3.1 |
| G-05 | Select列の `items` に空配列 `[]` を使わない           | Critical    | `items: []`                          | `items: dropdownOptions.value` (init で取得)              | — |
| G-06 | `@selection-changed` は `event.selectRows` で取得     | Critical    | AG Grid API 直接呼出し               | `(event) => { selectedRows.value = event.selectRows }`    | — |
| G-07 | `SstTreeview` のフィルタは `filterable` prop          | Improvement | 自前 TextField + computed            | `<SstTreeview :filterable="true" />`                      | — |
| G-08 | `@page-changed` / `@page-size-changed` でデータ再取得 | Critical    | イベント受けてもAPI未呼出し          | `pageChanged(e) { page=e.page; size=e.size; getData(); }` | — |
| G-09 | `paginationSettings` に5フィールド完備                | Critical    | `pageSizes` や `enabled` 漏れ        | `{ enabled, page, size, total, pageSizes }` すべて必須    | — |
| G-10 | 編集列の `cellEditor` タイプが正しい                  | Improvement | 操作列以外で `CellEditorType.Action` | 入力列は `.Text` / `.Select` 等を適切に使用               | — |

---

## 4. API 層規約

| #    | チェック項目                                              | 重要度      | 違反例                              | 正解                                                                                   | 規約§ |
| ---- | --------------------------------------------------------- | ----------- | ----------------------------------- | -------------------------------------------------------------------------------------- | --- |
| A-01 | `ApiType.ts` は `@sst-cm/fe-web-client` の型 alias        | Critical    | `interface MyReq { ... }` 手書き    | `export type MyReq = Web.XxxRequest`                                                   | 2.2.2 |
| A-02 | API wrapper は `apiCall` / `apiCallWithLoading` 使用      | Critical    | `try/catch` 直書き                  | `apiCall(() => client.method(...))`                                                    | 5.16 |
| A-03 | Client は `@/libs/client.ts` から取得                     | Critical    | `new Client.Web.XxxApi(...)` inline | `import { xxxApiClient } from '@/libs/client'`                                         | 5.16, 5.19 #8 |
| A-04 | API 層に UI ロジック / i18n なし                          | Improvement | `t('error')` in API                 | API は型付きデータ返却のみ                                                             | 5.1 |
| A-05 | `localeCd` は API 層で注入                                | Improvement | composable で注入                   | `Api.ts` 内で `getLocaleCd()`                                                          | — |
| A-06 | `apiCall` は読込、`apiCallWithLoading` は書込/長時間処理  | Critical    | 読込に `apiCallWithLoading` 使用    | 読込: `apiCall`、保存/削除: `apiCallWithLoading`                                       | 5.16 |
| A-07 | 新規 API 追加時に `src/libs/client.ts` に client 登録済み | Critical    | client 未登録で参照エラー           | `client.ts` に `export const xxxApiClient = new Client.Web.XxxApi(configuration)` 追加 | 5.16 |

---

## 5. その他

| #    | チェック項目                                             | 重要度      | 違反例                      | 正解                         | 規約§ |
| ---- | -------------------------------------------------------- | ----------- | --------------------------- | ---------------------------- | --- |
| O-01 | `<script setup lang="ts">` 必須                          | Critical    | Options API / plain JS      | Composition API + TypeScript | 5.1, 5.19 #1 |
| O-02 | 生成ファイル未編集（`auto-imports.d.ts` 等）             | Critical    | 手動編集あり                | 触らない                     | 1.1, 5.19 #6 |
| O-03 | i18n キーが `src/locales/ja.ts` に存在する               | Critical    | 未登録キー使用              | 4言語ファイルすべてに追加    | 5.8 |
| O-04 | `.value` 忘れ（script 内 ref アクセス）                  | Critical    | `myRef` (without `.value`)  | `myRef.value`                | — |
| O-05 | テンプレート内の不要な `.value`                          | Nitpick     | `{{ myRef.value }}`         | `{{ myRef }}`                | — |
| O-06 | `<style scoped>` 使用（グローバルスタイル汚染防止）      | Improvement | `<style>` (scoped なし)     | `<style scoped>`             | 5.5, 5.19 #10 |
| O-07 | 生成ファイル `src/libs/client.ts` に新規 client 追記済み | Critical    | client 未登録で実行時エラー | 新 API 追加時は必ず登録      | 5.16（1.1 相違） |

---

## 6. SonarQube / sonarjs 規約

CI の SonarQube Quality Gate で検出される項目。ローカルでは `yarn lint`（`eslint-plugin-sonarjs` recommended）で事前検出可能。

| #     | チェック項目                                    | 重要度      | 違反例                                    | 正解                                        | 規約§ |
| ----- | ----------------------------------------------- | ----------- | ----------------------------------------- | ------------------------------------------- | --- |
| SQ-01 | Cognitive Complexity ≤ 15（1関数あたり）        | Critical    | ネスト 4階層 + 分岐 10個の巨大関数        | 関数分割・早期 return・ガード節で複雑度低減 | 1.3 |
| SQ-02 | 重複コードなし（3箇所以上の同一ロジック）       | Improvement | 同じ API 呼び出し + 加工を3画面にコピペ   | 共通 composable / util に抽出               | 1.3 |
| SQ-03 | デッドコード除去（未使用 import / 変数 / 関数） | Critical    | `import { unused } from '...'`            | 不要な import・変数を削除                   | 1.3 |
| SQ-04 | 到達不能コードなし                              | Critical    | `return` 後のコード                       | 到達不能箇所を削除                          | 1.3 |
| SQ-05 | 同一条件の重複 if 分岐なし                      | Critical    | `if (a) {...} else if (a) {...}`          | 条件を整理・統合                            | 1.3 |
| SQ-06 | 常に true/false の条件なし                      | Critical    | `if (x && !x)`                            | 条件式を修正                                | 1.3 |
| SQ-07 | 関数パラメータ数 ≤ 5                            | Improvement | `function f(a,b,c,d,e,f,g)`               | オブジェクト引数にまとめる                  | 1.3 |
| SQ-08 | 関数行数 ≤ 100行                                | Improvement | 200行超の巨大関数                         | 責務ごとに分割                              | 1.3 |
| SQ-09 | ネスト深度 ≤ 3階層                              | Improvement | `if { if { if { if {`                     | 早期 return / ガード節で平坦化              | 1.3 |
| SQ-10 | セキュリティホットスポットなし                  | Critical    | ハードコード URL / トークン / `innerHTML` | 環境変数・定数化・`v-html` 回避             | 1.3, 5.19 #9 |

---

## 重要度の定義

| レベル          | 意味                               | 対応     |
| --------------- | ---------------------------------- | -------- |
| **Critical**    | 規約違反・バグ・セキュリティリスク | 必ず修正 |
| **Improvement** | 品質向上・保守性改善               | 強く推奨 |
| **Nitpick**     | スタイル・好み                     | 任意     |
