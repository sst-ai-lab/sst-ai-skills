---
name: scaffold-integration-contract
description: Generates the TypeSpec (BFF-only) contract for an external-integration feature — one that does NOT call a microservice (an external SDK/API integration handled inside the BFF, e.g. OCR, AI, vision, file upload). No gRPC side — only a `.tsp` file under `src/tsp/bffWeb/**` (models + operations) plus a `main.tsp` import. Supports multipart/form-data file uploads and the async job-id (start + poll/stream) variant. Use when adding the contract for a BFF-only feature (no microservice / no gRPC method) in cm-be-spec.
---

# OpenAPI integration skill (BFF-only, TypeSpec) — cm-be-spec

For a feature whose work is done **inside the BFF by an external SDK/cloud API** (OCR, AI, vision,
document/file processing, an external device) rather than by a downstream microservice. Such a
feature has **no gRPC counterpart**, so its contract is **BFF-only**.

> **BFF contracts are authored in TypeSpec** (`src/tsp/bffWeb/**/*.tsp`) — `src/openapi/bffWeb.yml`
> is generated from it (`node scripts/generate-bff-openapi.mjs` / Gradle `compileBffTsp`) and must
> never be hand-edited.

It also commonly **uploads a file** (`@multipartBody` + `HttpPart<bytes>`) and may be **asynchronous**
(a `post...` start operation returns a job id, and a separate `get...{jobId}`-style operation is
polled/streamed for progress) — both of which the standard CRUD flow does not use.

> **Distinct from the `scaffold-contract` skill.** Use **`scaffold-contract`** for a standard feature backed by a
> microservice — it generates **both** the BFF (TypeSpec) and gRPC (YAML) sides. Use **this** skill
> when the feature does **not** call a microservice, so only the BFF `.tsp` side exists.

## When to use

- Adding the contract for a BFF-only feature (no microservice / no gRPC method): OCR, AI, vision,
  file-upload or other external-SDK integration.

## Scope

- **Generates (BFF side only, TypeSpec):**
  - `src/tsp/bffWeb/[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[featureCamel].tsp` — models + operations for the feature.
  - An added `import "./..."` line in `src/tsp/bffWeb/main.tsp`.
- **Does NOT generate:** anything under `src/openapi/paths/grpc/`, `src/openapi/components/grpc/`,
  and **no `msGrpc.yml` entry** — this feature has no gRPC method. (If yours does, it is not
  BFF-only; use the `scaffold-contract` skill instead.) Also never hand-edits `src/openapi/bffWeb.yml` (generated).

## How to use

| Pattern | File | Description |
|---|---|---|
| Initial creation | `references/init.md` | Classification, TypeSpec templates (incl. multipart upload + async job-id polling), and the `main.tsp` / generation steps |

## Related

- Repo conventions: the repository `CLAUDE.md`; spec rules: `../scaffold-contract/references/openapi-rules.md` (gRPC-only scope now).
- For a microservice-backed feature (BFF **and** gRPC), use the `scaffold-contract` skill instead.

