# cm-be-ms-log

Các skill riêng của `cm-be-ms-log`. Bật cùng với `sst-common`, `sst-be-common` và `cm-be-ms-common`; các quy tắc chung của microservice lấy từ `cm-be-ms-common:scaffold-ms-feature`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true, "cm-be-ms-log@sst-ai-skills": true } }
```

| Skill | Mục đích |
| --- | --- |
| `scaffold-log-feature` | Endpoint tìm kiếm gRPC (PostgreSQL / Athena) hoặc feature nạp log từ Kafka |
| `write-athena-clients` | Quy tắc cho AWS Athena client |
