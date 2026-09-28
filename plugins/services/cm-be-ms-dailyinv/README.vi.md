# cm-be-ms-dailyinv

Các skill riêng của `cm-be-ms-dailyinv`. Bật cùng với `sst-common`, `sst-be-common` và `cm-be-ms-common`; các quy tắc chung của microservice lấy từ `cm-be-ms-common:scaffold-ms-feature`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true, "cm-be-ms-dailyinv@sst-ai-skills": true } }
```

| Skill | Mục đích |
| --- | --- |
| `scaffold-inventory-feature` | Feature dùng hai datasource (PostgreSQL + ClickHouse), đầu vào là Kafka hoặc gRPC |
| `write-clickhouse-mappers` | Quy tắc MyBatis mapper cho ClickHouse |
