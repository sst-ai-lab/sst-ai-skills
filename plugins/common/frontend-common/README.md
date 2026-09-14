# frontend-common

Shared skills for SCM Vue web frontends built on `@sst-cm/sst-fw-web`. Enable it in `cm-fe-web` and `manual-fe-web`.

```json
{ "enabledPlugins": { "frontend-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose | Migrated from (Copilot, `cm-fe-web/.github/`) |
|---|---|---|
| `vue-guide` | Vue / API-client conventions and the sst-fw-web component and utility catalogs | `instructions/vue.instructions.md`, `instructions/api-client.instructions.md`, `skills/frontend/references/00.FW*.md` |
| `screen-scaffold` | Generate a screen from 基本設計書 / 詳細設計書 and Figma | `skills/frontend/` (SKILL.md, `init.md`, `01`–`05`) |
| `convention-review` | Review (and, on request, fix) code against フロントエンド開発規約 plus the project checklist; the standard wins on conflict | cm-docs `frontend_web/フロントエンド開発規約_ver1.md` (486ca98) + `skills/code-review/` |
| `commands/review-code` | `/frontend-common:review-code [scope]` — read-only scoped review using `convention-review` | backend-common `review-code` flow (SCM-117) |

`cm-fe-web` was used as the canonical source; `manual-fe-web` holds an older, partly conflicting copy.

## Prerequisites

- `screen-scaffold` requires the Figma MCP server (`get_design_context`, `get_screenshot`).

## Inputs from CLAUDE.md

Read from the repository `CLAUDE.md` (`## Service profile`): `{repo}`, `{menuFile}`, `{middleCategoryDirs}`, `{subCategoryDirs}`, `{commonLookupImportPath}`, `{dropDownApiDir}`.
