# cm-be-bff-web

Skills specific to `cm-be-bff-web`. Enable together with `backend-common`.

```json
{ "enabledPlugins": { "backend-common@sst-ai-skills": true, "cm-be-bff-web@sst-ai-skills": true } }
```

| Skill | Purpose | Migrated from (`cm-be-bff-web/.github/`) |
|---|---|---|
| `report-scaffold` | JasperReports report feature (BFF glue, row map, `.jrxml` rules) | `skills/report/`, `instructions/jrxml.instructions.md` |
| `integration-scaffold` | External integration feature wrapping a vendor SDK (Azure / Bedrock) | `skills/integration/` |
