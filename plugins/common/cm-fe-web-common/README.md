# cm-fe-web-common

Shared skills for the SCM Vue web applications. Enable it in `cm-fe-web` and `manual-fe-web`, together with `sst-common` and `sst-fe-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-fe-common@sst-ai-skills": true, "cm-fe-web-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose |
| --- | --- |
| `scaffold-screen` | Generate a search or maintenance screen from the Japanese design documents (基本設計書 / 詳細設計書) and Figma |

The frontend development standards and the `sst-fw-web` catalog live in `sst-fe-common`, which every Vue repository enables.

## Prerequisites

- `scaffold-screen` requires the Figma MCP server (`get_design_context`, `get_screenshot`).

## Values the skill reads from the repository

`scaffold-screen` derives the menu definition file, the 中分類 / 小分類 directory names under `src/views/`, and the `CommonLookup` / `DropDownApi` import paths from the repository itself. It asks only for what the repository cannot answer, such as the directory name of a 中分類 that does not exist yet.
