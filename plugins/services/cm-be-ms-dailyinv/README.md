# cm-be-ms-dailyinv

Skills specific to `cm-be-ms-dailyinv`. Enable together with `backend-common`; generic microservice rules come from `backend-common:ms-scaffold`.

```json
{ "enabledPlugins": { "backend-common@sst-ai-skills": true, "cm-be-ms-dailyinv@sst-ai-skills": true } }
```

| Skill | Purpose | Migrated from (`cm-be-ms-dailyinv/.github/`) |
|---|---|---|
| `feature-scaffold` | Dual-datasource (PostgreSQL + ClickHouse) feature with Kafka or gRPC entry | `skills/backend/`, service-only parts of `instructions/{service-layer,mybatis-postgres}.instructions.md` |
| `clickhouse-guide` | MyBatis mapper rules for ClickHouse | `instructions/mybatis-clickhouse.instructions.md` |
