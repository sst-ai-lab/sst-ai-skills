# sst-be-common

The backend development standards and the framework catalog, shared by every SST Java repository: the `cm-be-*` services, the `sst-fw-be-*` framework libraries and `cm-print-agent`. Enable it together with `sst-common`, and with the role plugin of the repository (`cm-be-bff-common`, `cm-be-ms-common` or `sst-fw-be-common`).

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose |
| --- | --- |
| `check-conventions` | Standards for changed Java code and MyBatis mapper XML (バックエンド開発規約), run by `/sst-common:review-code` |
| `use-sst-framework` | Catalog of the internal `sst-fw-be-*` framework, so existing classes get reused |

Code generation lives in the role plugins: `cm-be-bff-common:scaffold-bff-feature` for the BFF side, `cm-be-ms-common:scaffold-ms-feature` for a microservice.

## Not written yet

The cross-stack standards of cm-docs `19.開発規約整備/common/` — DB naming and business terms, message IDs and error codes, feature IDs, timezone, transactions, file size limits, APM — are not part of `check-conventions` yet.
