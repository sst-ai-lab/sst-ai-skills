# sst-fe-common

The frontend development standards and the `sst-fw-web` catalog, shared by every SST Vue repository: the web applications `cm-fe-web` and `manual-fe-web`, and the framework repositories `sst-fw-web` and `sst-fw-storybook`. Enable it together with `sst-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-fe-common@sst-ai-skills": true, "cm-fe-web-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose |
| --- | --- |
| `check-conventions` | Standards for changed `.vue`, composables and the API layer (フロントエンド開発規約) plus the project checklist; the standard wins on conflict |
| `use-sst-framework` | Vue and API client conventions, and the `@sst-cm/sst-fw-web` component and utility catalogs |

Screen generation lives in the role plugin `cm-fe-web-common:scaffold-screen`, which only the web applications enable.

## Not written yet

The cross-stack standards of cm-docs `19.開発規約整備/common/` — business terms in API types, message IDs for i18n keys, feature IDs, timezone, file size limits, APM — are not part of `check-conventions` yet.
