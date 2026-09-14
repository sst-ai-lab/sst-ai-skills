---
name: screen-scaffold
description: フロントエンドを自動生成するためのスキルです。Use when scaffolding a new Vue screen (search screen / registration-maintenance screen) from Japanese basic/detail design documents (基本設計書・詳細設計書) and Figma: generates <feature>.vue, use<Feature>.ts composable, <feature>.types.ts, src/api <feature>Api.ts / <feature>ApiType.ts, menu registration, libs/client.ts entry and i18n keys using @sst-cm/sst-fw-web Sst* components. Requires the Figma MCP server (get_design_context / get_screenshot).
---

# フロントエンドスキル

## 適用タイミング

- フロントエンドを自動生成する必要があるとき

## 🚨 重要: 毎回必ず参照ファイルを読み直すこと

> **このスキルが呼び出されるたびに、以下の手順を最初から実行すること。**
> 同じチャット内で2回目以降の呼び出しであっても、前回の生成結果に引きずられず、
> **必ず `references/init.md` を Read で読み直し**、そこに書かれた手順に従うこと。
>
> **前回生成したコードのパターンを "記憶" して再利用してはならない。**
> 毎回の生成は独立しており、参照ファイルが唯一の正解である。

### 必須読込手順（省略禁止）

1. **Read** → `references/init.md`（手順フロー・冒頭14ルール・ディレクトリ構成）
2. **Read** → `references/01-template-structure.md`（テンプレート + composable骨格）
3. **Read** → `references/02-grid-definition.md`（Grid + pagination）
4. **Read** → `references/03-event-implementation.md`（イベントパターン）
5. **Read** → `references/04-api-definition.md`（API型 + ラッパー）
6. **Read** → `references/05-i18n-layout.md`（i18n + Figma + レイアウト）
7. 必要に応じて → `../vue-guide/references/fw-components.md`、`../vue-guide/references/fw-catalog.md`

**上記1〜6は毎回必ず読む。「前回読んだから省略」は禁止。**

## ボタン快捷キー定義（Hotkey）——システム共通ルール

> 詳細な実装パターンは `../vue-guide/references/vue-conventions.md` の「Hotkeys」セクションを参照。

キーとボタンの対応: `f3`=検索, `f4`=複製, `f6`=新規, `f7`=保存, `f8`=クリア, `f9`=実行。
その画面に存在するボタンに対応するキーをすべて登録する。

## コンポーネント選定ルール（厳守）

> **Vuetify のネイティブコンポーネント（`<v-card-text>`/`<v-btn>`/`<v-text-field>`/`<v-select>`/`<v-dialog>` 等）を `<template>` に直接使うことは禁止。**
> 画面上のあらゆるUI要素は必ず `../vue-guide/references/fw-components.md` に定義されている `Sst*` ラッパーコンポーネントを使う。
> 対応する `Sst*` コンポーネントが見当たらない場合は、`v-*` へ自己判断でフォールバックせず、ユーザーに確認すること（詳細は `references/init.md` 規則 #55）。

## 参照ファイル一覧

| パターン           | mdファイル名                            | 説明                                                                  |
| ------------------ | --------------------------------------- | --------------------------------------------------------------------- |
| 初期作成           | `references/init.md`                    | 手順フロー・冒頭ルール・ディレクトリ構成・実装順序                    |
| テンプレート       | `references/01-template-structure.md`     | 検索画面/登録画面テンプレート + composable骨格 + コンポーネント対応表 |
| グリッド           | `references/02-grid-definition.md`         | SstGrid + columnDefs + pagination + pageChanged + getData             |
| イベント           | `references/03-event-implementation.md`         | 追加条件/選択制御/検索/保存/削除パターン                              |
| API                | `references/04-api-definition.md`              | types.ts/ApiType.ts/Api.ts/client.ts/DropDown/CodeName                |
| 多言語・レイアウト | `references/05-i18n-layout.md`   | i18n規則 + Figma MCP + SstRow/SstCol                                  |
| コンポーネント仕様 | `../vue-guide/references/fw-components.md` | 全コンポーネントのプロパティ・スロット・イベント・使用例              |
| ロジック仕様       | `../vue-guide/references/fw-catalog.md`               | SstUtil等のユーティリティメソッド一覧                                 |

## import ルール（厳守）

### すべての使用箇所で明示的に import を書く

**使用するシンボルは必ず明示的に `import` 文を書くこと**（auto-import は設定されていない）。
これによりコードの依存関係が明確になり、可読性が向上する。

```ts
// ✅ 正しい: 使う場所で必ず import を書く
import { useI18n, useMessage, useDialog, sstUtil, useSstHotkeyScope, CellEditorType } from '@sst-cm/sst-fw-web';
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig';
```

### import 元の対応表

| シンボル                                                                                                                                | import 元                         |
| --------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------- |
| `useI18n`, `useMessage`, `useDialog`, `useNotification`, `sstUtil`, `useSstHotkeyScope`, `usePageChange`, `CellEditorType`, `setLocale` | `@sst-cm/sst-fw-web`              |
| `useFormDisplayConfig`                                                                                                                  | `@/composables/sstMemorizeConfig` |
| `sstCodeNameApi`                                                                                                                        | `@/composables/sstCodeNameApi`    |
| `CodeNameType`                                                                                                                          | `@/constants/codeNameType`        |

### CodeNameType の import 先ルール（重要）

`CodeNameType` は**テンプレートで直接使う場合** `.vue` の `<script setup>` で import し、
**composable 内で使う場合のみ** `use*.ts` で import する。
両方で使う場合は両方に書いてよいが、**使わないファイルに import を残すのは禁止**（SonarQube デッドコード違反）。

```ts
// .vue テンプレートで :code-type="CodeNameType.OWNER" として使う場合 → .vue に書く
// composable の columnDefs 内で codeType: CodeNameType.ITEM として使う場合 → use*.ts に書く
```

### 同一パッケージ import の統合（重複禁止）

同じパッケージから複数シンボルを import する場合は **必ず1行にまとめる**:

```ts
// ✅ 正しい
import { CellEditorType, useI18n, useMessage, useSstHotkeyScope, usePageChange } from '@sst-cm/sst-fw-web';

// ❌ 禁止（同じパッケージから2行以上の import）
import { CellEditorType } from '@sst-cm/sst-fw-web';
import { useSstHotkeyScope } from '@sst-cm/sst-fw-web';
```

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

- `{repo}` — リポジトリ名（`references/init.md` のディレクトリ・ファイル構成のルート）
- `{menuFile}` — APPKEY と vue ファイルの紐づけを追加するメニュー定義ファイルのパス（`references/init.md`）
- `{middleCategoryDirs}` — 中分類ディレクトリ一覧（設計書の中分類 → ディレクトリ名）（`references/init.md`）
- `{subCategoryDirs}` — 小分類ディレクトリ一覧（設計書の小分類 → ディレクトリ名）（`references/init.md`）
- `{commonLookupImportPath}` — `CommonLookup` コンポーネントの import パス（`references/01-template-structure.md`）
- `{dropDownApiDir}` — `DropDownApi`（`dropDownApi.ts` / `dropDownApiType.ts`）の import ディレクトリ（`references/01-template-structure.md`、`references/04-api-definition.md`）
