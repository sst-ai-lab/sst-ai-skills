# cm-be-spec

Skills specific to `cm-be-spec`. Enable together with `backend-common`.

```json
{ "enabledPlugins": { "backend-common@sst-ai-skills": true, "cm-be-spec@sst-ai-skills": true } }
```

| Skill | Purpose | Migrated from (`cm-be-spec/.github/`) |
|---|---|---|
| `openapi-scaffold` | BFF contract (TypeSpec) and gRPC contract (OpenAPI YAML) from design documents | `skills/openapi/`, `instructions/openapi.instructions.md` |
| `openapi-integration-scaffold` | BFF-only TypeSpec contract for external integrations | `skills/openapi-integration/` |
