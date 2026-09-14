# フロントエンド新規作成手順

設計書を元にフロントエンドのファイルを新規作成する手順を説明します。
詳細は各参照ファイルを Read で読み込むこと。

> **🚨 見落としやすいルール（生成前に必ず確認）:**
>
> 1. **Grid columnDefs**: 設計書に桁数がある入力列 → `cellEditorParams: { maxLength: N }` を必ず指定（**Number列も含む**）
> 2. **Grid columnDefs**: 設計書に必須マークがある入力列 → `cellEditorParams: { rules: [{ required: true, message: t('...') }] }` を必ず指定
> 3. **Grid 操作列**: `cellRenderer: CellEditorType.Action`（`cellEditor` ではない）+ `cellRendererParams: { actions: [...] }`
> 4. **PascalCase**: すべての Sst コンポーネントは `<SstTextField>` のように PascalCase で書く（`<sst-text-field>` は禁止）
> 5. **SstTreeview フィルタ**: `filterable` prop を使う。自前で TextField + computed フィルタを書かない
> 6. **pageChanged**: `page`/`size` を変数に書き戻してから再検索する（`pageNumber`/`pageSize` ではない）
> 7. **getData()**: サーバーサイドページネーション時、API に `page` / `size` を必ず渡す
> 8. **Grid Select列**: `cellEditorParams.items` に空配列 `[]` を指定しない。init() で DropDownApi から取得した ref の `.value` を渡す
> 9. **usePageChange（登録画面）**: 宣言だけでなく `markClean()` / `confirmValueChanged()` を適切なタイミングで呼ぶ
> 10. **Grid headerName の i18n キー**: `t('label.xxx')` を使う。`t('grid.xxx')` のような独自名前空間は禁止
> 11. **SstSelect/SstRadio の items**: デフォルトが `label`/`value` なので `item-title="label" item-value="value"` を書かない（冗長）
> 12. **SstCodeName**: `:code-type` は必須 prop。省略禁止（`CodeNameType.OWNER` 等を必ず指定する）
> 13. **paginationSettings**: フィールド名は `page`/`size`/`total`/`pageSizes`/`enabled`。`pageNumber`/`pageSize`/`totalCount` は禁止
> 14. **pagination-mode="server"**: 検索画面の SstGrid に明示的に書く（省略しない）
> 15. **すべての使用箇所で明示的 import**: `useI18n`, `useMessage`, `useDialog`, `useNotification`, `sstUtil`, `useSstHotkeyScope`, `usePageChange`, `CellEditorType`, `useFormDisplayConfig` 等は**必ず明示的に `import` 文を書く**。import 元は SKILL.md の対応表を参照
> 16. **同一パッケージからの重複 import 禁止**: 同じパッケージから複数回 `import` する場合は **1行にまとめる**。例: `import { CellEditorType, useI18n, useSstHotkeyScope } from '@sst-cm/sst-fw-web'`（2行に分けない）
> 17. **@selection-changed ハンドラ**: `event.selectRows` で選択行配列を取得する。AG Grid API の直接呼出し禁止。実装パターンは `references/02-grid-definition.md` と `references/03-event-implementation.md` を参照
> 18. **ApiType.ts の型は手書き禁止**: `@sst-cm/fe-web-client` の `Web.*` 型を必ず alias する。`Record<string, unknown>` やオブジェクトリテラル型で自前定義しない
> 19. **localeCd 注入**: 設計書SQLに「言語コード」（locale_cd）がある API のみ `localeCd: getLocaleCd()` をリクエストに注入する。ない場合は付けない。実装は `references/04-api-definition.md` の `getLocaleCd()` パターンに従い **API層**（`{機能名}Api.ts`）に書くこと。composable 側で直接注入しない
> 20. **Lookup の TODO/空実装 禁止**: `:iconclick` を指定した `SstCodeName` がある場合、`iconclick` 関数は必ず `showLookupDialog.value = true` で Lookup ダイアログを開く完全な実装にすること。`// TODO` や空関数は禁止。テンプレート側にも必ず `<SstDialog>` + `<CommonLookup>` を配置し、`<script setup>` で `CommonLookup` を import する。実装パターンは `references/01-template-structure.md` のcomposable骨格を参照
> 21. **Hotkey の書き方厳守**: `useSstHotkeyScope` の返り値は **`useSstHotkey`**（`registerHotkey` ではない）。scope 引数も必須。キー名は**小文字**（`'f3'`）。コールバックは関数参照（`search`）で渡す。正しいパターン: `const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID }); useSstHotkey('f3', search)`。❌ `registerHotkey('F3', () => search())` は禁止
> 22. **SstCodeName の `:iconclick` は設計書に従う**: 設計書の項目定義に `ルックアップ: ✔` がある `SstCodeName` には必ず `:iconclick` prop を指定すること。`:iconclick` を省略して Lookup 実装を回避するのは禁止。結果として規則 #20 が必ず発動し、Lookup ダイアログの完全実装が求められる。設計書に `ルックアップ: ✔` が**ない** SstCodeName は `:iconclick` 不要。**実装前に**、設計書の項目定義表から `SstCodeName` に該当する行をすべて抽出し、`ルックアップ` 列の値（✔ の有無）を一覧化してから実装に着手すること（実装後に気づくのは手戻りが大きく見落としの原因になる）。生成後は規則 #51 のセルフチェックで、この一覧の ✔ 件数と `.vue` 内の `:iconclick` 出現数が**完全に一致する**ことを突き合わせて確認する
> 23. **Lookup key は大文字＋computed 必須**: `currentLookupKey` は必ず `computed` で定義し、`currentLookupType` の値を `switch` で**大文字**にマッピングする（例: `case 'owner': return 'OWNER'`）。`ref('')` で直接代入する方式は禁止。`LookupType` は小文字識別子（`'owner'`/`'warehouse'`）、`:lookup-key` に渡す最終値は大文字（`'OWNER'`/`'WAREHOUSE'`）
> 24. **テンプレート内の日本語ハードコード禁止**: `<template>` 内に表示する文字列は必ず `t('xxx')` で i18n キーを使う。`"読み込み中..."` や `"データなし"` のような直接日本語文字列の埋め込みは禁止。`#detail` スロット等のローディング/エラー/空表示も `t('information.codes.xxx')` を使うこと
> 25. **コールバック引数名の衝突禁止**: `findIndex`/`filter`/`map` 等のコールバック引数に `t` を使わない（i18n の `t = useI18n()` と shadow する）。代わりに `el`, `item`, `entry`, `c` 等を使う。例: `conditionItems.value.findIndex((el) => el.value === item)` ✅ / `...findIndex((t) => t.value === item)` ❌
> 26. **doInit() は onMounted 内で呼ぶ**: composable のトップレベルで `doInit()` を即時呼出しするのは禁止。`onMounted(async () => { await doInit(); ... })` で呼ぶこと。トップレベルだと初期化エラーが握りつぶされ、テンプレートの ref 未解決の問題が起きる
> 27. **MEMORIZE_CONFIG の正しいシェイプ**: `{ screenId, gridRefs, formRefs, trackedFieldIds }` の4フィールドを必ず指定する。`{ screenId, items }` 形式は旧パターンであり禁止。**注意点**: (a) `useFormDisplayConfig()` は**引数なし**で呼ぶ — `useFormDisplayConfig(MEMORIZE_CONFIG)` は誤り。(b) 戻り値は `{ getMemorizeConfig, saveMemorizeConfig }` — `loadMemorizeConfig` は存在しない。(c) `gridRefs` / `formRefs` は **Record 形式** `{ grid: gridRef }` / `{ form: formRef }` — 配列 `[gridRef]` は誤り
> 28. **async/await で統一**: composable 内のすべての非同期関数は `async/await` で書く。`.then()` チェーンと混在させない。`getData()` も `async function getData()` で書くこと
> 29. **:code-type は CodeNameType 定数で指定**: `SstCodeName` の `:code-type` は必ず `CodeNameType.OWNER` / `CodeNameType.WAREHOUSE` 等の定数を使う。`"SHIPTO"` 等の文字列リテラルは禁止。`CodeNameType` に該当する値がない場合は `src/constants/codeNameType.ts` に追加定義してから使う（`import { CodeNameType } from '@/constants/codeNameType'`）
> 30. **onLookupSelected に any 禁止**: Lookup 選択ハンドラの引数は `any` を使わず、`LookupRow` 型（`{ code?: string; name?: string; [key: string]: unknown }`）を定義して使う
> 31. **日付初期値は `today` 変数で一元化**: `sstUtil().getCurrentDate('YYYYMMDD')` は **composable 冒頭で `const today = ...` として一度だけ呼び出し**、各フォームフィールドでは `today` を参照する。`shipSchDateStart: sstUtil().getCurrentDate(), shipSchDateEnd: sstUtil().getCurrentDate()` のようにフィールドごとにインラインで呼ぶのは禁止（冗長かつ呼出しタイミングのずれが起きる）
> 32. **SstDateInput の `:dateFormat`**: 日付項目のモデル値は常に `YYYYMMDD`（区切りなし）。**表示フォーマット**は `:dateFormat` prop で指定する。デフォルトは `YYYY/MM/DD` なので、設計書の「フォーマット」列が `YYYY/MM/DD` または未記載なら `:dateFormat` は省略してよい。設計書に `YYYY-MM-DD` や `YYYY年MM月DD日` 等デフォルト以外が書かれている場合は `:dateFormat="'YYYY-MM-DD'"` のように明示すること
> 33. **:code-type はフィールドの業務意味に合致させる**: `SstCodeName` の `:code-type` は**そのフィールドが表す業務エンティティ**に対応する値を指定する。他フィールドからのコピペで異なる CodeNameType を流用するのは禁止。例: `transportCd`（運送会社）に `CodeNameType.OWNER`（荷主）は**間違い**。`CodeNameType` に該当値がなければ `src/constants/codeNameType.ts` に追加してから使う
> 34. **save() のレスポンス処理（登録画面）**: 新規作成モード（`pcsMod='0'`）の `save()` では、API レスポンスから返却された**主キー（soNo 等）をフォームに反映**し、ツリーに追加する処理を必ず実装する。レスポンスを無視してはならない。パターン: `const res = await Api.save({...}); if (pcsMod.value === '0') { form.soNo = res.soNo ?? ''; addTreeItem(form.soNo); pcsMod.value = '1'; } pageDirty.markClean()`
> 35. **import は使用箇所のファイルにのみ書く**: `CodeNameType` を `.vue` のテンプレートでのみ使うなら `.vue` の `<script setup>` で import し、composable (`use*.ts`) には import しない。composable 内で実際に使用するシンボルだけを import する。**未使用 import（デッドコード）は SonarQube で Critical 違反になる**
> 36. **loadData の長大な代入は mapping helper で圧縮する**: API レスポンスを form に代入するフィールドが **20個を超える**場合、1行ずつ `form.xxx = String(header.xxx ?? '')` と書くのは禁止（Cognitive Complexity 超過 + 100行超）。代わりに**フィールドマッピング配列 + ループ**で圧縮する: `const fields = ['ownerCd', 'warehouseCd', ...] as const; fields.forEach((f) => { form[f] = sstUtil().toString(header[f]) })`。型変換が異なるフィールド（数値・日付）のみ個別に書く
> 37. **`.vue` で destructure するのはテンプレートで使う値のみ**: composable の return オブジェクトから `.vue` の `<script setup>` で展開する変数は、**テンプレート内で実際に参照する値だけ**に限定する。テンプレートで使わない値（columnDefs 内部でのみ参照する `statusItems` 等）は展開しない。未使用の展開変数は SonarQube デッドコード違反になる
> 38. **非編集列の cellEditor 指定ルール**: `editable: false` の列では以下を守る: (1) **Date/DateTime 列**のみ `cellEditor: CellEditorType.Date` を指定してよい（表示フォーマット用）。(2) **Select/Input/Number 等の非 Date 列**は `cellEditor` / `cellEditorParams` を**指定しない**（表示には不要、紛らわしい）。(3) `cellEditorParams`（`items` 等）は `editable: true` の列にのみ指定する
> 39. **`:tab` は全入力コンポーネントに漏れなく付与**: 設計書のフィールド数に関わらず、`SstTextField`/`SstNumberInput`/`SstDateInput`/`SstSelect`/`SstCodeName`/`SstRadio`/`SstTimePicker` 等の**全入力コンポーネント**に `:tab="N"` を付ける。補足情報パネル内のフィールド（soSupplementInfo01〜20 等）も省略禁止。Tab キーのフォーカス順序が途切れる
> 40. **`as unknown as` キャストの制限**: `{ ...form } as unknown as Record<string, unknown>` のような**型安全性を完全にバイパスするトリプルキャスト**は禁止。save() では form から API 型へのマッピングを明示的に行う。パターン: (1) form のフィールド名が API 型と一致する場合 → `{ ...form } as Web.XxxRequest`（直接キャスト可）。(2) フィールド名が異なる場合 → 明示的にオブジェクトを組み立てる。`as unknown as` は**配列の要素型変換**（`gridData.value as unknown as Web.XxxDetail[]`）のみ許容する
> 41. **関数パラメータの未使用引数を持たない**: 関数定義で使わない引数は宣言しない。既存テンプレートの `hiddenPanelClick(key: string, _name: string)` のようなパターンは禁止。使用する引数のみ定義する: `hiddenPanelClick(key: string)`
> 42. **`Ref<T>` 型注釈の省略**: `const formRef: Ref<{ resetAll: () => void; validateAll: () => Promise<boolean> } | undefined> = ref()` のような冗長な型注釈は書かない。代わりに `ref` のジェネリクスで推論させる: `const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()`
> 43. **`useDialog` の引数はオブジェクト（文字列禁止）**: `dialog.confirm()` / `dialog.info()` 等は `DialogOptions` 型のオブジェクトを受け取る。✅ `dialog.confirm({ content: t('message.xxx') })` / ❌ `dialog.confirm(t('message.xxx'))`（文字列を直接渡すのは**間違い**）。`DialogOptions` の主要フィールド: `{ title?: string, content?: string, persistent?: boolean, positiveText?: string, negativeText?: string }`
> 44. **`useMessage` のメソッド名**: `info` / `success` / `warning` / `error` + `WithTitle` 版（`infoWithTitle(title, content)` 等）+ `closeAll()`。**`showInfo` / `showSuccess` / `showError` / `showWarning` は存在しない**。正しいパターン: `message.info(t('information.codes.I00001'))` / `message.successWithTitle('完了', '保存しました')`
> 45. **`useI18n()` は .vue と composable の両方で呼ぶ（設計上正しい）**: `.vue` の `<script setup>` と composable (`use*.ts`) の**両方**で `const t = useI18n()` を呼ぶのは正常。`useI18n()` はシングルトンステートパターンであり、複数箇所で呼んでも同じ翻訳状態を参照する。`.vue` 側の `t` はテンプレート内で使用し、composable 側の `t` は composable 内部（`columnDefs`, `tabItems`, `statusTypeItems` 等の `computed` 内）で使用する。**composable から `t` を return して `.vue` で使うパターンは禁止**（責務が混在する）
> 46. **バッチ操作の重複コード禁止（DRY）**: 検索画面で確定・引当・実績追加・削除など、同じパターン（dialog確認→リスト作成→API呼出→メッセージ→再検索）の関数が**3つ以上**ある場合は、共通の `batchAction` ヘルパー関数を定義し、各操作はそれを呼ぶだけにする。コピペで4つの関数を書くのは SonarQube 重複コード違反。パターンは `references/03-event-implementation.md` の「バッチ操作」セクションを参照
> 47. **`getData()` のエラーハンドリング方針**: API呼出を `apiCall` / `apiCallWithLoading` で行う場合はフレームワーク側で中央エラーハンドリングされるため `try/catch` は不要。直接 API を呼ぶ場合で `try/finally`（loading 制御のみ）を使うなら、`catch` ブロックを書かない設計にする（エラーは自動的に上位で処理される）。`try/finally` + **個別 `catch`** を書くのは、ユーザーに追加フィードバックを出す場合のみ
> 48. **詳細設計書は必須入力**: 基本設計書のみが提供され、対応する詳細設計書（`docs/02.詳細設計/**/*.md`）が見つからない/提供されない場合は実装を開始せず、詳細設計書の提供をユーザーに依頼する。基本設計書の地の文だけからイベントロジックやAPIパラメータを推測して実装するのは禁止
> 49. **詳細設計書のマーカー（🔴🟠）は推測禁止**: `（基本設計に記載なし）🔴【要詳細設計】` / `🟠【要基本設計書修正】` が付いた箇所（イベント処理・パラメータマッピング・初期値/ボタン制御等）は、内容を推測してコード化してはならない。該当箇所の実装を止め、ユーザーに質問すること。マーカーが付いていない箇所は通常どおり実装を続ける
> 50. **画面構造は `references/01-template-structure.md` のテンプレートよりFigmaを優先する**: 検索画面の `SstTabs`（条件タブ/結果タブ）構成はFigmaでタブ分割されている場合の標準例にすぎない。Figmaで検索条件と検索結果が同一ページ内に並んでいる（タブ切替が存在しない）場合は `SstTabs`/`#condition`/`#result` を使わず、条件ブロックと結果ブロックをページ内に直接、上から順に配置する。ボタン配置・`SstCard`グルーピング等のスタイル規約はタブ有無に関わらず適用する
> 51. **生成完了前のセルフチェック（レイアウト構造・Lookup・ボタン位置・システム情報）**: `.vue` 生成後、コミット前に (a) タブ分割/単一ページの構造がFigmaと一致しているか、(b) 設計書の項目定義表で `ルックアップ: ✔` になっている `SstCodeName` の**件数**と、生成した `.vue` 内の `:iconclick` の**出現数**を実際に数えて一致するか（1件でも不一致があれば規則 #22 違反として直ちに修正する。「たぶん付けた」という記憶に頼らず必ず数える）、(c) ボタンの画面上の位置（上部/下部等）がFigmaと一致しているか（規則 #52）、(d) `add*`/`upd*` 監査列があるのに画面モックアップに `panel.systemInfo` パネルが見当たらない場合、ユーザーに追加要否を確認済みか（規則 #53。無断で追加も無断で省略もしない）、(e) `v-model:name` を使う `SstCodeName` すべてに `@retrieve-data` が付いているか（規則 #54）、(f) `<template>` 内に `<v-xxx>` のような Vuetify ネイティブタグが混入していないか（規則 #55）を再確認する。取得した Figma スクリーンショットと生成した `.vue` を見比べて確認すること
> 52. **登録・メンテナンス画面のボタン位置は画面下部固定ではない**: `references/01-template-structure.md` の登録画面テンプレート例は `position-fixed` ユーティリティクラス + インライン `style="top:...;right:..."` でページ上部付近にボタンを浮かせるのが標準例であり、`position: fixed; bottom: 0` のような画面最下部固定バーをデフォルトとして作成してはならない。必ずFigmaの実際のボタン位置（位置・寄せ方向）を確認し、`top`/`right`/`left`/`bottom` の値をそれに合わせて調整する
> 53. **システム情報パネル（`panel.systemInfo`）の有無は自己判断せずユーザーに確認する**: 設計書の項目定義に `add*`/`upd*` 監査列（登録日時・登録者・登録端末・更新日時・更新者・更新端末・有効フラグ等）がある登録・メンテナンス画面で、**基本設計書の画面モックアップ（Figma/レイアウト画像）に `panel.systemInfo` に相当するパネルが描かれていない**場合、追加するかどうかを自己判断（無断で追加・無断で省略のどちらも禁止）せず、実装着手前に「項目定義に監査列がありますが画面モックアップにシステム情報パネルが見当たりません。追加しますか？」とユーザーに確認すること。ユーザーが追加を了承した場合のみ `references/01-template-structure.md` の「システム情報パネルの標準構成」に従い実装する。画面モックアップに既にシステム情報パネルが描かれている場合は確認不要でそのまま実装する
> 54. **`SstCodeName` の `@retrieve-data` は `v-model:name` を使う場合省略禁止**: `:iconclick`（規則 #22）は設計書に `ルックアップ: ✔` がある場合のみ必須だが、`@retrieve-data` はそれとは無関係に **`v-model:name` で名称フィールドを紐付けている `SstCodeName` すべてで必須**（コード入力時の自動名称取得のため、Lookupダイアログの有無とは無関係）。ハンドラーの実装パターンは `references/01-template-structure.md` の「SstCodeName」節を参照（`CodeNameResponse` 型を使い、`sstUtil().toString()` で値を変換する）
> 55. **Vuetify コンポーネントの直接使用禁止**: `<v-card-text>`/`<v-btn>`/`<v-text-field>`/`<v-select>`/`<v-dialog>` 等、Vuetify のネイティブコンポーネントを `<template>` に直接書くことは禁止。**必ず `../../vue-guide/references/fw-components.md` に定義されている `Sst*` ラッパーコンポーネント（`SstCard`/`SstCardText`/`SstCardTitle`/`SstButton`/`SstTextField`/`SstSelect`/`SstDialog` 等）を使うこと**。目的のUIに対応する `Sst*` コンポーネントが `../../vue-guide/references/fw-components.md` に見当たらない場合は、自己判断で `v-*` に fallback せず、ユーザーに確認する

## 参照ファイル一覧

実装時は以下のファイルを必要に応じて Read で読み込む:

| ファイル                                | 内容                                                                  |
| --------------------------------------- | --------------------------------------------------------------------- |
| `references/01-template-structure.md`     | 検索画面/登録画面テンプレート + composable骨格 + コンポーネント対応表 |
| `references/02-grid-definition.md`         | SstGrid + columnDefs + pagination + pageChanged + getData             |
| `references/03-event-implementation.md`         | 追加条件/選択制御/検索/保存/削除パターン                              |
| `references/04-api-definition.md`              | types.ts/ApiType.ts/Api.ts/client.ts/DropDown/CodeName                |
| `references/05-i18n-layout.md`   | i18n規則 + Figma MCP + SstRow/SstCol レイアウト                       |
| `../../vue-guide/references/fw-components.md` | 全コンポーネントのプロパティ・スロット・イベント・使用例              |
| `../../vue-guide/references/fw-catalog.md`               | sstUtil 等のユーティリティメソッド一覧                                |

## 事前準備: 設計書を読む（必須・最初に行う）

ユーザーが設計書を添付した場合、**チャットコンテキストに内容が渡されないことがある**。
添付の `filePath` が存在する場合は必ず Read でファイルを読み込むこと。

特に以下の2ファイルを必ず読む:

1. **基本設計書**（基本設計ディレクトリ内の `.md`）→ レイアウト（Figmaリンク）・項目定義・画面遷移
2. **詳細設計書**（詳細設計ディレクトリ内の `.md`）→ イベント定義・処理概要・APIパラメータマッピング・モード別初期値/ボタン制御

### 詳細設計書は必須入力（ブロッカー・基本設計書のみでの生成は禁止）

> **詳細設計書（`docs/02.詳細設計/**/\*.md`、`detail-design-fe` エージェント生成物）が存在しない機能は実装を開始しない。\*\*
> 基本設計書だけが渡された場合は、詳細設計書の作成・提供をユーザーに依頼して終了すること
> （「詳細設計書がないので基本設計書から直接推測して実装する」は禁止 — 事件ロジック・APIパラメータの出所が
> 構造化されておらず、AIの推測に頼ると仕様齟齬が起きるため）。

### 基本設計書 と 詳細設計書 の役割分担

| 設計書     | 担当する情報                                                                                                                                                     |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 基本設計書 | レイアウト（Figmaリンク）・項目定義（型/桁数/必須/ドロップダウン等の属性）・画面遷移                                                                             |
| 詳細設計書 | イベント定義一覧・各イベントの処理概要（実装順序）・処理フロー・入力パラメータマッピング表・モード分岐（新規/編集）・処理モード概要（初期値設定/画面ボタン制御） |

### 詳細設計書の構造 → 実装への反映ルール

詳細設計書（`detail-design-fe` 生成フォーマット）の各要素は、以下の対応で実装に落とし込む。
自己流の解釈をせず、この対応表に従うこと。

| 詳細設計書の要素                                                                    | 実装への反映                                                                                                                                                                        |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `### {イベント定義名}` の見出し                                                     | composable 内の対応する関数（`search`/`save`/`clear`/`onXxxClick` 等）1つに対応させる                                                                                               |
| `#### 処理概要` の番号付きステップ                                                  | ステップの順序どおりに処理を実装する（勝手に順序を入れ替えない・省略しない）                                                                                                        |
| `共通処理（FW）の場合はイベント定義の記載不要` という記載                           | フレームワーク標準動作のため独自実装は不要（該当イベントは既存FW挙動に任せる）                                                                                                      |
| `入力パラメータマッピング` 表（`パラメータ名`/`項目名`/`取得元`）                   | API リクエストオブジェクトの各フィールドの値の出所を決める。`取得元`列の分類とコード対応は `references/04-api-definition.md` の「入力パラメータマッピング → リクエスト実装」を参照         |
| `**新規モード場合**` / `**編集モード場合**` の太字分岐                              | `pcsMod` 等のモード変数による `if`/`switch` 分岐として実装する（詳細は `references/03-event-implementation.md`）                                                                            |
| `##### 処理モード概要` の「初期値設定」表（`項目名`/`初期値`/`入力可/不可`/`備考`） | モード切替時の初期値セット・フィールド `disabled`/`readonly` 制御に反映する。「未記載項目は基本設計の項目定義に従う」の注記がある場合、記載外フィールドは基本設計書の項目定義を使う |
| `画面ボタン制御` 表（`項目名`/`利用可否`/`備考`）                                   | 対応ボタンの `:disabled`（または `v-show`）制御に反映する                                                                                                                           |
| メッセージ文（`エラーメッセージ「…」を表示する`）                                   | 基本設計/詳細設計の文言をそのまま i18n キーの値として使う（独自に言い換えない）                                                                                                     |

### 詳細設計書マーカー（🔴🟠）の確認（必須・ブロッカー）

> 詳細設計書には情報不足箇所を示すマーカーが付く:
>
> - `（基本設計に記載なし）🔴【要詳細設計】` … 詳細設計側の補完待ち（API入力マッピング・パラメータ定義等）
> - `（基本設計に記載なし）🟠【要基本設計書修正】` … 基本設計書側の不備（機能ID未採番等）
> - 同ディレクトリに `<機能名>.markers.md`（マーカー一覧のsidecarファイル）がある場合は、まずそれを読んで全件を把握する。

**これから実装しようとしている箇所（イベント処理・APIパラメータ・初期値/ボタン制御など）に
🔴 または 🟠 のマーカーが付いている場合、その部分を推測で実装してはならない。**
実装を止め、該当箇所を明示してユーザーに質問すること（TODOコメントで仮実装して先に進むことも禁止）。
マーカーが付いていない箇所は通常どおり実装を続けてよい（機能全体を止める必要はない）。

### Figmaデザインの取得（必須・ブロッカー）

> **フロントエンド画面には必ずFigmaリンクが存在する。**
> 見つからない場合は実装を開始せず、ユーザーに伝えて終了すること。

基本設計書の `## レイアウト` セクションに Figma URL がある場合、
**`get_design_context` + `get_screenshot` を並列で呼び出してからコード生成を行う**。
詳細は `references/05-i18n-layout.md` の Figma MCP セクションを参照。

> **画面構造（タブ分割 or 単一ページ、カラム比率等）は `references/01-template-structure.md` の
> テンプレート例より常に実際のFigmaレイアウトを優先する。** テンプレートの `SstTabs` 構成は
> あくまでデフォルト例であり、Figmaにタブ切替が存在しない場合は単一ページ構成で実装する。

## ユーザーへの確認事項

| 項目                     | 確認タイミング                               | 例       |
| ------------------------ | -------------------------------------------- | -------- |
| **★ 菅次郎チケット番号** | **常に最初に確認する（設計書から抽出不可）** | **123**  |
| 大分類                   | 設計書から自動抽出                           | Web      |
| 中分類                   | 設計書から自動抽出                           | コア     |
| 小分類                   | 設計書から自動抽出                           | 出荷     |
| 機能名                   | 設計書から自動抽出                           | soMainte |
| 機能ID                   | 設計書から自動抽出                           | 003      |

## 設計書から読み取る情報

| 設計書項目 | 用途                                                             |
| ---------- | ---------------------------------------------------------------- |
| 大分類     | 機能IDの組み立て（例: Web → `w`）。ディレクトリには現れない      |
| 中分類     | 中分類ディレクトリ特定（例: コア → `core`、ニーモニックのみ）    |
| 小分類     | 小分類ディレクトリ特定（例: 出荷 → `so`、ニーモニックのみ）      |
| 機能名     | ファイル名・機能フォルダ名のベース（lowerCamelCase、連番なし）   |
| 機能ID     | ディレクトリ名には使用しない（APPKEY・メッセージコード等で使用） |

## ディレクトリ・ファイル構成

```
{repo}/
├── {menuFile}                                ← APPKEYとvueファイルの紐づけを追加
└── src/
    ├── api/
    │   └── {中分類ディレクトリ}/
    │       └── {小分類ディレクトリ}/
    │           └── {機能名}Api/
    │               ├── {機能名}Api.ts        ← APIラッパー
    │               └── {機能名}ApiType.ts    ← API型定義
    └── views/
        └── {中分類ディレクトリ}/
            └── {小分類ディレクトリ}/
                └── {機能名}/
                    ├── {機能名}.vue         ← テンプレート
                    ├── use{機能名Pascal}.ts ← composable
                    └── {機能名}.types.ts    ← View層型定義
```

> **ディレクトリ命名は数値コードを使わず、ニーモニックコードのみで統一する（連番も付けない）。**
> 例: `040_so` ❌ → `so` ✅、`003_soMainte` ❌ → `soMainte` ✅

### 中分類ディレクトリ一覧

中分類ディレクトリ（設計書 → ディレクトリ名）の一覧は repository `CLAUDE.md` の `{middleCategoryDirs}` を参照する。

> ローカル機能は `core`/`option` と混在させない（別ディレクトリに分ける）。

### 小分類ディレクトリ一覧

小分類ディレクトリ（設計書 → ディレクトリ名）の一覧は repository `CLAUDE.md` の `{subCategoryDirs}` を参照する。

## {menuFile} 追加

```ts
{APPKEY}: {
  name: '{画面表示名}',
  path: '{機能名}',
  url: 'views/{中分類ディレクトリ}/{小分類ディレクトリ}/{機能名}/{機能名}.vue',
},
```

## 実装順序

1. [ ] **作業ブランチを作成する** ← `git checkout -b feature/<機能名>`
2. [ ] 設計書から機能名・機能ID・大分類・中分類・小分類を読み取る
3. [ ] **詳細設計書のマーカー（🔴🟠）を確認する** — 実装に必要な箇所（イベント処理・パラメータマッピング・初期値/ボタン制御）に未解決マーカーがあれば、ここでユーザーに質問し確認を得てから先に進む
4. [ ] Figma URL を取得し `get_design_context` + `get_screenshot` を並列呼出 — タブ分割/単一ページどちらの構造か確認する。あわせて (a) 項目定義表の `SstCodeName` 行をすべて抽出し `ルックアップ: ✔` の件数を控える（規則 #22/#51）、(b) `add*`/`upd*` 監査列があるのに画面モックアップに `panel.systemInfo` が見当たらない場合はここでユーザーに追加要否を確認する（規則 #53）
5. [ ] ディレクトリ・ファイルを作成する（5ファイル）
6. [ ] `{機能名}.types.ts` → 型定義
7. [ ] `{機能名}ApiType.ts` → API型定義
8. [ ] `{機能名}Api.ts` → APIラッパー
9. [ ] `use{機能名Pascal}.ts` → ロジック
10. [ ] `{機能名}.vue` → テンプレート
11. [ ] `{menuFile}` にAPPKEY追加
12. [ ] `libs/client.ts` にAPIクライアント追加（必要時）
13. [ ] **多言語キーを確認・追加する（必須・省略禁止）** — 4言語すべて
14. [ ] **セルフチェック（規則 #50/#51）** — 生成した `.vue` のレイアウト構造（タブ分割/単一ページ）がFigmaと一致しているか、ステップ4で控えた `ルックアップ: ✔` の件数と `.vue` 内の `:iconclick` 出現数を実際に数えて一致するか、`v-model:name` を使う `SstCodeName` すべてに `@retrieve-data`（規則 #54）が付いているか、Vuetify ネイティブタグ（`<v-xxx>`）が混入していないか（規則 #55）を確認する
15. [ ] **AI生成ソースをコミット** ← `git commit -m "#<チケット番号> [ai] <機能名> 初期生成"`
16. [ ] ビルド・動作確認（手修正は `[manual]` prefix）

## 注意事項

- **既存ファイルへの上書き厳禁**: 存在する場合はユーザーに確認してから上書き
- **OpenAPI生成クラスは編集不可**: `node_modules/@sst-cm/fe-web-client` 配下は変更しない
- **設計書にないフィールドの追加禁止**: 型定義は設計書の項目定義のみ
- **sstUtil を優先使用**: `getCurrentDate`, `toString` 等は `sstUtil()` を使い自前ロジックで代替しない
- **ボタンスタイル規約**: 検索 = `color="primary"` + `variant="elevated"`、クリア = `variant="outlined"`、操作 = `#AFF4C6`（緑）、取消/削除 = `#FCB3AD`（赤）
- **コンポーネント選定は設計書の属性列に従う**: 「数値」→ `SstNumberInput`、「文字」→ `SstTextField`
- **【初回生成時のみ】ブランチ作成 + `[ai]` コミット**: 初回生成後の Claude 修正では通常フローに従う
