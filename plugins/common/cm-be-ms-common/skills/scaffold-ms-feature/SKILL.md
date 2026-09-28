---
name: scaffold-ms-feature
description: Scaffolds a microservice-side (MS) feature — gRPC service impl, Service, MyBatis mapper + XML, entity, and MapStruct mapping; or a gRPC client to another microservice; or a Kafka batch consumer with chunked UNNEST upsert. No tests. Use when adding or extending a feature inside a Spring Boot microservice repository (cm-be-ms-*), and when editing its service layer (`**/service/**/*.java`), MyBatis mapper XML (`**/mybatis/**/*.xml`), Kafka consumers (`**/consumer/**/*.java`, `**/infrastructure/message/**/*.java`), gRPC clients (`**/infrastructure/grpc/**/*.java`), gRPC server impls (`**/grpc/**/*.java`) or MapStruct mappings (`**/infrastructure/mapping/**/*.java`).
---

# Backend skill (microservice side)

## When to use

- Adding or extending a feature **inside this microservice**: a new gRPC endpoint, query, or write path.
- Adding or extending an **event-ingest feature**: consume a Kafka event and batch-upsert it into PostgreSQL.
- Adding a Kafka-triggered batch that fetches data from another microservice over gRPC, computes in memory, and persists to PostgreSQL.
- Adding a gRPC feature that is served by calling another microservice (`{targetMicroservice}`) and reshaping the result.

## Scope

- **Generates:** gRPC service impl (`@GrpcService`), Service interface + `*Impl`, MyBatis mapper interface + `*Mapper.xml`, persistence entity/models, and MapStruct mapping (entity ↔ gRPC). Kafka event publishing when the design calls for it. Depending on the entry type: a Kafka **batch** consumer (manual ack), the gRPC **client** to another microservice (`*Client` + `*ClientImpl`) plus its stub `@Bean` in `GrpcClientConfiguration`, the `UnnestParamsBuilder` array assembly.
- **Does NOT generate:** tests; proto/gRPC stubs or shared DTOs (they come from the `sst-fw-be-grpc` / `cm-be-spec` internal jars — treat as external); `com.cm.grpc.*` / `com.fw.core.*` / `cm-be-spec` classes (external generated jars — never stub).

## How to use

Pick the template by the feature's entry type, then read the layer rules for each file you generate.

| Pattern | File | Description |
| --- | --- | --- |
| Initial creation — gRPC server + CRUD | `templates/crud-grpc-server.md` | Naming derivation (大分類 / 中分類 / 小分類), file map, and code templates to scaffold an MS feature from a design (gRPC impl, Service, MyBatis mapper + XML, entity, MapStruct, optional Kafka event) |
| Initial creation — gRPC gateway (server + client to another MS, no DB) | `templates/grpc-gateway.md` | Naming, file map, and code templates to scaffold a gateway feature (gRPC impl, downstream client + stub `@Bean`, MapStruct, orchestration service) |
| Initial creation — Kafka ingest (UNNEST upsert) | `templates/unnest-ingest.md` | Naming, file map, and code templates to scaffold an ingest feature (consumer, service, UNNEST mapper + XML, params builder, entity) |
| Initial creation — Kafka batch (gRPC fetch → calc → UNNEST) | `templates/kafka-batch.md` | Steps to scaffold a Kafka-triggered batch feature |
| Layer rules — Service | `references/service-layer.md` | Editing `**/service/**/*.java` |
| Layer rules — MyBatis | `references/mybatis-mapper.md` | Editing `**/mybatis/**/*.xml` |
| Layer rules — Kafka consumer | `references/kafka-consumer.md` | Editing `**/consumer/**/*.java` or `**/infrastructure/message/**/*.java` |
| Layer rules — gRPC client | `references/grpc-client.md` | Editing `**/infrastructure/grpc/**/*.java` |
| Layer rules — gRPC server | `references/grpc-server.md` | Editing `**/grpc/**/*.java` |
| Layer rules — MapStruct | `references/mapstruct-mapping.md` | Editing `**/infrastructure/mapping/**/*.java` |

## Values to settle before generating

Read every value from the repository being worked on: the `package` declarations, the existing classes, `application*.yml`. Ask the user only for a choice the repository cannot answer, such as the downstream microservice of a new gateway feature.

For each policy, follow what the repository already does — look at an existing service impl, consumer, mapper XML or mapping class of the same kind. Ask the user only when the repository has no such file yet.

| Placeholder / policy | Meaning |
| --- | --- |
| `{basePackage}` | Root package of this microservice (`{basePackagePath}` is its directory form) |
| `{middleCategory}` | This service's 中分類 (Pascal) |
| `{ServicePascal}` / `{serviceLc}` | This service's message/stub prefix (gateway pattern) |
| `{targetMicroservice}` | The downstream microservice called over gRPC (`{TargetPascal}` / `{targetLc}` = its message/stub prefix and package segment) |
| `{grpcChannel}` / `{port}` | gRPC channel name of the downstream microservice and its default port |
| `{topic}` / `{topicConstantClass}` / `{database}` | Kafka topic that triggers the batch; class holding topic constants; PostgreSQL database name |
| `{domain}` | Domain package segment |
| `{eventPublisher}`, `{referenceServiceImpl}`, `{referenceMapperXml}` | Existing classes/files in this repository used as patterns |
| Policy `service-pattern` | Service-layer variant in `references/service-layer.md` |
| Policy `kafka-ack` | Ack variant in `references/kafka-consumer.md` |
| Policy `mybatis-xml-layout`, `unnest-on-conflict` | Variants in `references/mybatis-mapper.md` |
| Policy `grpc-client-return` | Variant in `references/grpc-client.md` |
| Policy `grpc-error-mapping` | Variant in `references/grpc-server.md` |
| Policy `mapstruct-base` | Variant in `references/mapstruct-mapping.md` |

## Related

- Before writing a utility, exception, validation or DTO of your own, check whether the shared framework (`sst-fw-be-*`) already provides it, and reuse it.
