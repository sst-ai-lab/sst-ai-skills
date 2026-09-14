# cm-be-ms-log

Skills specific to `cm-be-ms-log`. Enable together with `backend-common`; generic microservice rules come from `backend-common:ms-scaffold`.

```json
{ "enabledPlugins": { "backend-common@sst-ai-skills": true, "cm-be-ms-log@sst-ai-skills": true } }
```

| Skill | Purpose | Migrated from (`cm-be-ms-log/.github/`) |
|---|---|---|
| `feature-scaffold` | gRPC search endpoint (PostgreSQL / Athena) or Kafka log-ingestion feature | `skills/backend/`, service-only parts of `instructions/{service-layer,grpc-server,mybatis-mapper,kafka-consumer}.instructions.md` |
| `athena-guide` | AWS Athena client rules | `instructions/athena-client.instructions.md` |
