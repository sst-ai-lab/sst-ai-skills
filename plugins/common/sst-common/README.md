# sst-common

Shared by every SST repository, whatever its stack. Enable it next to the repository's stack plugin.

```json
{
  "enabledPlugins": {
    "sst-common@sst-ai-skills": true,
    "sst-be-common@sst-ai-skills": true
  }
}
```

## Contents

| Component | Purpose |
|---|---|
| `commands/review-code` | `/sst-common:review-code [scope]` — read-only review of the changes in scope against every standard the enabled plugins provide |

## Where the standards come from

This plugin has no standards of its own. The command loads every skill whose name starts with `check-` in the other enabled plugins and applies each to the files its description covers:

| Plugin | Skill | Covers |
|---|---|---|
| `sst-be-common` | `check-conventions` | Java, MyBatis mapper XML (バックエンド開発規約) |
| `sst-fe-common` | `check-conventions` | `.vue`, `use*.ts`, `*Api.ts`, `*ApiType.ts` (フロントエンド開発規約 + checklist) |
| `sst-mobile-common` | `check-conventions` | Dart (モバイル開発規約) — not written yet |
| `cm-be-spec` | `check-conventions` | `.tsp`, OpenAPI YAML — not written yet |
| `cm-devops-common` | `check-conventions` | `.tf`, `.hcl` — plugin not created yet |

A repository with `sst-common` enabled and no stack plugin has no standards, and the command says so instead of reviewing.

To add standards, see [Review standards](../../../CONTRIBUTING.md#47-review-standards) in `CONTRIBUTING.md`.
