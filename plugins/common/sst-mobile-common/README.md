# sst-mobile-common

The mobile development standards and the shared commands of every SST Flutter repository: `cm-fe-mobile`, `sst-fw-mobile` and `sst-fw-widgetbook`. Enable it together with `sst-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-mobile-common@sst-ai-skills": true } }
```

## Contents

| Skill / command | Purpose |
| --- | --- |
| `/sst-mobile-common:create-comment <file>` | Add Japanese Dart comments to a file, without changing the code |

## Not written yet

`check-conventions` for Dart. The source is ready: cm-docs `frontend_mobile/モバイル開発規約_ver1.md` (537 lines), plus the cross-stack standards of `19.開発規約整備/common/`. Until it exists, `/sst-common:review-code` finds no standards in a Flutter repository.
