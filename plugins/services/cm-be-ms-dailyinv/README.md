# cm-be-ms-dailyinv

Skills specific to `cm-be-ms-dailyinv`. Enable together with `sst-common`, `sst-be-common` and `cm-be-ms-common`; the generic microservice rules come from `cm-be-ms-common:scaffold-ms-feature`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true, "cm-be-ms-dailyinv@sst-ai-skills": true } }
```

| Skill | Purpose |
| --- | --- |
| `scaffold-inventory-feature` | Dual-datasource (PostgreSQL + ClickHouse) feature with Kafka or gRPC entry |
| `write-clickhouse-mappers` | MyBatis mapper rules for ClickHouse |
