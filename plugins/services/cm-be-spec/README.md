# cm-be-spec

Skills specific to `cm-be-spec`. Enable together with `sst-common`. The repository holds TypeSpec and OpenAPI contracts, not hand-written Java, so it does not enable `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "cm-be-spec@sst-ai-skills": true } }
```

| Skill | Purpose |
| --- | --- |
| `scaffold-contract` | BFF contract (TypeSpec) and gRPC contract (OpenAPI YAML) from design documents |
| `scaffold-integration-contract` | BFF-only TypeSpec contract for external integrations |
