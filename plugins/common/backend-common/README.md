# backend-common

Shared skills for all SCM backend services (BFF and microservices). Enable it in every `cm-be-*` repository.

```json
{ "enabledPlugins": { "backend-common@sst-ai-skills": true } }
```

## Contents

| Component | Purpose | Migrated from (Copilot) |
|---|---|---|
| `skills/convention-review` | Review changed Java code against バックエンド開発規約 | Procedure: `.github/skills/backend-convention-review/` (identical in all 9 backend repos). Standard: cm-docs `backend/バックエンド開発規約_ver1.md` (486ca98) |
| `commands/review-code` | `/backend-common:review-code [scope]` — scoped review using `convention-review` | `.github/prompts/review-code.prompt.md` (identical in all 9 backend repos) |
| `skills/framework-guide` | Catalog of the internal sst-fw-be-* framework | `cm-be-bff-*/.github/skills/backend/references/00.FW一覧.md`, `cm-be-ms-core` + `cm-be-ms-owner` `references/FW.md` |
| `skills/bff-scaffold` | Generate a BFF feature (Controller → Service → gRPC client) and the matching microservice side | `cm-be-bff-web/.github/skills/backend/` (`init.md` split by section) |
| `skills/ms-scaffold` | Generate a microservice feature (gRPC server/client, Kafka consumer, MyBatis, MapStruct) | `cm-be-ms-{core,owner,inout,bill,dailyinv,log}` `skills/backend/` and `instructions/*.instructions.md` |

## Inputs from CLAUDE.md

Common skills never hard-code a service. They read these sections from the repository `CLAUDE.md` and ask the user when a value is missing:

- `## Service profile` — e.g. `{repo}`, `{basePackage}`, `{grpcChannel}`, `{targetMicroservice}`, `{serviceException}`, `{topic}`, `{port}`.
- `## Policies` — per-service choices kept as variants in `ms-scaffold`: `service-pattern`, `kafka-ack`, `grpc-error-mapping`, `grpc-client-return`, `mapstruct-base`, `mybatis-xml-layout`, `unnest-on-conflict`.

See each `SKILL.md` for the exact list.
