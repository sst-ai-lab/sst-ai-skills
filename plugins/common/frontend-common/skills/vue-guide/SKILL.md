---
name: vue-guide
description: Vue 画面（.vue）・API 層（src/api/**）のコーディング規約と、@sst-cm/sst-fw-web の Sst* コンポーネント一覧・sstUtil 等ロジック一覧。Use when writing or editing .vue files, co-located composables (use*.ts / *.types.ts), the src/api layer (*Api.ts / *ApiType.ts wrapping @sst-cm/fe-web-client, src/libs/client.ts), or when using Sst* components, sstUtil, useSstHotkeyScope, useFormDisplayConfig in a Vue 3 + Vuetify SPA.
---

# Vue / API 規約ガイド

## When to use

- `.vue` 画面を作成・編集するとき（Applies to: `**/*.vue`）
- API 層 `src/api/**/*.ts` を作成・編集するとき（Applies to: `**/src/api/**/*.ts`）
- `Sst*` コンポーネントのプロパティ・スロット・イベント・使用例、`sstUtil` 等のユーティリティを確認するとき

## References

| ファイル                           | いつ読むか                                                            |
| ---------------------------------- | --------------------------------------------------------------------- |
| `references/vue-conventions.md`    | `.vue` を編集するとき（Vue screen rules）                             |
| `references/api-client.md`         | `src/api/**/*.ts` を編集するとき（API layer rules）                   |
| `references/fw-components.md`      | FWコンポーネント一覧 — 全コンポーネントのプロパティ・スロット・イベント・使用例 |
| `references/fw-catalog.md`         | FW一覧 — sstUtil 等のユーティリティメソッド一覧                       |

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

- `{commonLookupImportPath}` — `CommonLookup` コンポーネント（`.vue`）の import パス（`references/vue-conventions.md` の Lookup dialog 節）
