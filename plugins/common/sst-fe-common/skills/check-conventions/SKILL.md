---
name: check-conventions
description: フロントエンドのコードレビュー・修正を行うためのスキルです。公式フロントエンド開発規約（references/frontend-conventions.md）とプロジェクト固有チェックリストに基づき、既存の画面コード（.vue / composable / API層）を規約チェックし、違反箇所の指摘と（明示的に依頼された場合の）修正を支援します。開発者のセルフチェック・プルリクエストレビュー・規約チェックに使う。Use for a frontend convention review, 規約チェック, developer self-check or pull request review of a PR, local git diff or specific .vue / use*.ts / *Api.ts / *ApiType.ts files against the frontend development standard (naming, comments, script setup, props/emits, i18n, TypeScript type safety, import/export, API calls, logging, SstUtil) and the project checklist (PascalCase Sst* components, imports, hotkeys, tab order, memorize, lookup, grid columnDefs, pagination, API layer, SonarQube rules), or when explicitly asked to fix convention violations in a Vue 3 + @sst-cm/sst-fw-web screen.
---

# フロントエンド コードレビュー・修正スキル

## 適用タイミング

- 既存のフロントエンドコードをレビューしたいとき
- PR / ローカル変更をプロジェクト規約に照らして確認したいとき
- 既存画面のコードを規約に合わせて修正したいとき
- 「このコード問題ないか見て」と言われたとき

## 判定基準と優先順位

| 優先 | ファイル | 位置づけ |
| ---- | -------- | -------- |
| 1 | `references/frontend-conventions.md` | 公式フロントエンド開発規約。違反判定の第一の根拠 |
| 2 | `references/checklist.md` | プロジェクト固有のチェック項目（`規約§` 列で規約の対応節を示す） |

- checklist の項目（および参照する `../use-sst-framework/references/*` の記述）が規約と食い違う場合は規約を優先し、指摘の中でその旨（checklist ID またはファイルと、規約の節）を明記する。
- レビュー（ワークフロー 1〜4、6）はファイルを変更しない。修正は「5. 自動修正モード」をユーザーが明示的に依頼した場合のみ行う。

## ワークフロー

### 1. レビュー対象の特定

| ユーザーの依頼                     | 対象                                                             |
| ---------------------------------- | ---------------------------------------------------------------- |
| 「PR #123 をレビュー」             | リモート PR の diff                                              |
| 「変更をレビュー」「修正箇所見て」 | ローカル `git diff` + `git diff --staged`                        |
| 特定ファイルパスを指定             | 指定ファイルを Read で読む                                |
| 「この画面レビューして」           | `.vue` + 同ディレクトリの `use*.ts` + `*.types.ts` + 対応 API 層 |
| 「この composable だけ見て」       | 指定 `use*.ts` + 同ディレクトリの `.vue`（呼び出し側確認）       |

### 2. 準備（コンテキスト収集）

1. **対象コードを読む** — Read でレビュー対象ファイルを取得。`.vue` を読んだら同ディレクトリの composable (`use*.ts`) と types (`*.types.ts`) も読む。composable 単体の場合は対応 `.vue` も確認する。
2. **対応 API 層を確認** — `src/api/` 配下に該当 feature の API ファイルがあれば読む。
3. **`src/libs/client.ts` を確認** — 新規 API 追加が含まれる場合、client インスタンスが登録済みか確認する。
4. **規約とチェックリストを読む** — 必ず Read → `references/frontend-conventions.md` と `references/checklist.md` を読み込む（毎回必須、省略禁止）。
5. **instructions を参照** — レビュー対象に `.vue` ファイルがあれば Read → `../use-sst-framework/references/vue-conventions.md` を読む。API 層 (`src/api/**/*.ts`) があれば `../use-sst-framework/references/api-client.md` も読む。初回は必ず読むこと。

#### diff モードの場合の効率的な読み方

ローカル変更レビューの場合は以下の手順で対象を絞る:

1. `git diff --name-only` + `git diff --staged --name-only` で変更ファイル一覧を取得
2. `.vue` / `use*.ts` / `*Api.ts` / `*ApiType.ts` のみフィルタリング
3. 各ファイルの diff を `git diff <file>` で確認し、変更箇所を中心にレビュー。リネームされたファイルは新規ファイルではない。差分が追加・変更と示す行だけが対象で、持ち越された内容は対象外とする。

### 3. チェック観点

以下の観点でコードを分析する。**`references/frontend-conventions.md`**（公式規約・第一の根拠）と **`references/checklist.md`**（詳細チェック項目一覧）を用いる。

#### A. 規約準拠（Convention Compliance）

- PascalCase コンポーネント記法
- import ルール（明示的 import / 同一パッケージ統合 / import 元の正確性）
- Hotkey 定義（`useSstHotkeyScope` の正しい使い方）
- i18n（ハードコード文字列の有無、`t()` キーの存在確認）
- Tab order（`:tab` 属性の連番指定）
- Memorize 実装（`useFormDisplayConfig` の呼び出しタイミング）
- Lookup 実装（`:iconclick` + `SstDialog` + `CommonLookup`）、および `v-model:name` 付き `SstCodeName` の `@retrieve-data`
- Grid columnDefs（`maxLength`、必須 `rules`、操作列 `cellRenderer`）
- paginationSettings フィールド名（`page`/`size`/`total`/`pageSizes`/`enabled`）
- ApiType.ts の型定義（`@sst-cm/fe-web-client` alias 必須、手書き禁止）
- Vuetify ネイティブコンポーネント未使用（`<v-btn>`/`<v-text-field>` 等 → 対応する `Sst*` を使う）

#### B. アーキテクチャ適合（Architecture Fit）

- 画面は薄く composable に委譲しているか（`.vue` にロジック肥大化していないか）
- API 層が UI ロジックを含んでいないか
- Pinia store の適切な使い分け

#### C. 正確性（Correctness）

- リアクティブ変数の `.value` 忘れ / テンプレート内での不要な `.value`
- `async/await` の正しい使用
- イベントハンドラの引数型

#### D. パフォーマンス・保守性

- 不要な re-render を引き起こす `computed` / `watch` の過剰使用
- 巨大な関数の分割推奨
- 重複コードの指摘

#### E. セキュリティ

- `v-html` の使用（XSS リスク）
- ユーザー入力の未サニタイズ出力

#### F. SonarQube 品質ゲート（CI で自動検証）

CI（`buildspec-ci.yml`）で SonarQube 静的解析が実行され、Quality Gate に不合格だと PR がブロックされる。ローカルでは `eslint-plugin-sonarjs`（recommended ルール）が `yarn lint` で検出可能。レビュー時に以下を確認する:

- **Cognitive Complexity** — 1関数あたりの認知的複雑度が高すぎないか（目安: 15以下）。ネストが深い `if`/`switch`/`for` の連鎖を指摘
- **重複コード** — 同じロジックが複数箇所にコピーされていないか（3箇所以上は抽出推奨）
- **デッドコード** — 到達不能コード、使われていない変数・import・関数
- **バグパターン** — 常に true/false の条件、自己代入、同一条件の重複 `if` 分岐
- **セキュリティホットスポット** — `v-html`、`innerHTML`、ハードコードされた認証情報、未検証の外部入力
- **コードスメル** — 過度に長い関数（100行超）、パラメータ数過多（5個超）、過度なネスト（3階層超）

> **ヒント**: `yarn lint` を実行すると `eslint-plugin-sonarjs` の recommended ルールが適用され、CI の SonarQube で検出される問題の大半を事前にキャッチできる。レビューで sonarjs 系の警告が残っていれば指摘する。

### 4. フィードバック形式

レビュー結果は以下の構造で報告する:

```
## レビュー結果サマリー

対象: <ファイル一覧>
判定: ✅ 問題なし / ⚠️ 要改善 / ❌ 要修正

---

### ❌ Critical（必ず修正）

| # | ファイル | 行 | 問題 | 根拠ルール |
|---|---------|---|------|-----------|

### ⚠️ Improvements（改善推奨）

| # | ファイル | 行 | 提案 | 根拠 |
|---|---------|---|------|------|

### 💡 Nitpicks（軽微・任意）

| # | ファイル | 行 | 内容 |
|---|---------|---|------|

---

## 修正提案

(Critical/Improvements の具体的な修正コードを提示)
```

「根拠ルール」には `frontend-conventions.md` の節番号と該当ルールの原文をそのまま引用する（checklist 項目の場合はその ID も併記）。checklist と規約が相違する場合は規約を根拠とし、相違している旨を明記する。引用は読み込んだファイルからそのままコピーする。記憶で書き直す・省略する・翻訳することはしない。文書内に見つけられないルールはルールではないので、その指摘は取り下げる。

### 5. 自動修正モード

ユーザーが「修正して」「直して」「fix」と明示的に指示した場合のみ実行する（レビューだけを依頼された場合はファイルを変更しない）:

1. レビューを実施
2. Critical + Improvements を**自動で修正**（ファイル編集）
3. 修正後に以下を実行して問題がないか確認:
   - `yarn type-check` — 型エラー検出
   - `yarn lint` — ESLint + Prettier + **sonarjs** 違反検出（autofix あり。sonarjs ルールは CI の SonarQube Quality Gate と同等）
   - `yarn build` — 完全ビルド検証（大規模修正時のみ、小規模なら省略可）
4. 修正内容のサマリーを報告

> **注意**: CI では `scripts/ci-sonarqube.sh` により SonarQube 静的解析が実行され、Quality Gate 不合格で PR がブロックされる。`yarn lint` で検出される `sonarjs/*` 警告を事前に解消しておくこと。

### 6. 部分レビュー（ファイル単体）

ユーザーが「このファイルだけ見て」と特定した場合、そのファイルのみをチェックする。
ただし imports の整合性確認で関連ファイルを参照することは許可。

## 参照ファイル

| ファイル                                            | 内容                                                  |
| --------------------------------------------------- | ----------------------------------------------------- |
| `references/frontend-conventions.md`                | 公式フロントエンド開発規約（違反判定の第一の根拠）    |
| `references/checklist.md`                           | 全チェック項目一覧（24規約 + 追加観点）               |
| `../use-sst-framework/references/vue-conventions.md`        | `.vue` の規約（`.vue` をレビューするとき）            |
| `../use-sst-framework/references/api-client.md`             | API 層の規約（`src/api/**/*.ts` をレビューするとき）  |
| `../use-sst-framework/references/fw-components.md` | コンポーネント仕様（prop/event の正しい使い方確認用） |
| `../use-sst-framework/references/fw-catalog.md`               | ユーティリティ仕様                                    |

## レビュー時に使わない情報

- 設計書（新規生成時のみ必要、レビューでは参照しない — ただしユーザーが明示的に「設計書と突合して」と言った場合を除く）
- Figma デザイン（レビューではレイアウト検証しない）

## 重要度の判定ガイドライン

| レベル          | 基準                                         |
| --------------- | -------------------------------------------- |
| **Critical**    | 規約違反・バグ・セキュリティリスク。必ず修正 |
| **Improvement** | 品質向上・保守性改善。強く推奨               |
| **Nitpick**     | スタイル・好み。任意                         |

**降格できるケース:**

- プロジェクト内の既存コードが同じパターンで書かれている場合（過去の先例がある）→ Critical → Improvement に降格可
- 1ファイル内の軽微なスタイル不一致で動作に影響なし → Nitpick に降格可
- ただしセキュリティリスク (`v-html`, 未サニタイズ出力) は絶対に降格しない

## よくある違反パターン（Top 15）

> 以下は `references/checklist.md` の頻出違反を要約したリスト。詳細・正解例は checklist の各 ID を参照。

1. 同一パッケージ import が2行に分かれている → **S-02**
2. kebab-case コンポーネント → **T-01**
3. `pageNumber`/`pageSize` → **S-06**
4. 操作列で `cellEditor` → **G-03**
5. `ApiType.ts` 手書き型 → **A-01**
6. `registerHotkey('F3', ...)` → **S-04**
7. テンプレート日本語ハードコード → **T-02**
8. `SstCodeName` に `:code-type` 未指定 → **T-04**
9. Lookup 未実装 → **T-05, T-06**
10. `usePageChange` 宣言のみ → **S-09**
11. 読込に `apiCallWithLoading` → **A-06**
12. `paginationSettings` 不完全 → **G-09**
13. `validateAll()` 未呼出 → **S-14**
14. `reactive` に `.value` → **S-18**
15. `client.ts` 未登録 → **A-07**
16. `SstCodeName` に `@retrieve-data` 未紐付け → **T-10**
17. Vuetify ネイティブコンポーネントの直接使用（`<v-btn>` 等）→ **T-11**

## Quick Fix 対照表

よくある違反に対する自動修正テンプレート:

| 違反                                   | 修正方法                                                                                                     |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| kebab-case コンポーネント              | `<sst-text-field>` → `<SstTextField>`（テンプレート全体を PascalCase に置換）                                |
| import 分散                            | 同一パッケージの import を 1行に統合: `import { a, b, c } from '...'`                                        |
| pagination フィールド名                | `pageNumber→page`, `pageSize→size`, `totalCount→total` に置換                                                |
| `validateAll()` 欠如                   | 検索/保存関数の先頭に `if (!(await formRef.value?.validateAll())) return;` 追加                              |
| `apiCallWithLoading` 誤用              | 読み込み操作: `apiCallWithLoading` → `apiCall` に置換                                                        |
| `sstUtil.xxx()`                        | `sstUtil().xxx()` に修正（関数呼び出し括弧追加）                                                             |
| `reactive` に `.value`                 | `form.value.field` → `form.field` に修正                                                                     |
| `paginationSettings` 不完全            | 不足フィールド追加: `reactive({ enabled: true, page: 1, size: 10, total: 0, pageSizes: [10, 20, 50, 100] })` |
| `useMessage` の import 元誤り          | `from 'vuetify'` / `from 'vue'` → `from '@sst-cm/sst-fw-web'` に修正                                         |
| `usePageChange` import 漏れ            | `import { usePageChange } from '@sst-cm/sst-fw-web';` を追加                                                 |
| Vuetify ネイティブタグ                 | `<v-btn>`/`<v-text-field>`/`<v-card-text>` 等 → 対応する `Sst*` コンポーネントに置換                         |
| `SstCodeName` の `@retrieve-data` 欠如 | `v-model:name` があれば `@retrieve-data="handleFetchXxx"` を追加し、`CodeNameResponse` 型のハンドラーを実装  |

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

- `{repo}` — レビュー対象のフロントエンドリポジトリ名（`references/frontend-conventions.md` の 1.1 / 2.1 / 2.2.1）
- 参照先の `../use-sst-framework/SKILL.md` の入力（`{commonLookupImportPath}`）に従う。
