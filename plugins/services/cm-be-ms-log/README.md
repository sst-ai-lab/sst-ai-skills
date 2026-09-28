# cm-be-ms-log

Skills specific to `cm-be-ms-log`. Enable together with `sst-common`, `sst-be-common` and `cm-be-ms-common`; the generic microservice rules come from `cm-be-ms-common:scaffold-ms-feature`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true, "cm-be-ms-log@sst-ai-skills": true } }
```

| Skill | Purpose |
| --- | --- |
| `scaffold-log-feature` | gRPC search endpoint (PostgreSQL / Athena) or Kafka log-ingestion feature |
| `write-athena-clients` | AWS Athena client rules |
