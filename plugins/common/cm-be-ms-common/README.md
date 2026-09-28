# cm-be-ms-common

Shared skills for the SCM microservices. Enable it in every `cm-be-ms-*` repository, together with `sst-common` and `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-ms-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose |
| --- | --- |
| `scaffold-ms-feature` | Generate a microservice feature: gRPC service, Service, MyBatis mapper and XML, entity, MapStruct mapping; a gRPC client to another microservice; or a Kafka consumer |

The backend development standards and the framework catalog live in `sst-be-common`, which every Java repository enables.

## Inputs from CLAUDE.md

Per-service choices are kept as named variants and selected from the repository `CLAUDE.md` `## Policies`: `service-pattern`, `kafka-ack`, `grpc-error-mapping`, `grpc-client-return`, `mapstruct-base`, `mybatis-xml-layout`, `unnest-on-conflict`.
