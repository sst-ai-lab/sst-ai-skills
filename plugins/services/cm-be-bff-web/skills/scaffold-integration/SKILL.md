---
name: scaffold-integration
description: Scaffolds an option/common external-integration feature in cm-be-bff-web — Controller, Service (+Impl), an infrastructure Gateway that wraps a vendor SDK (Azure / Bedrock / other), and the App<Feature>Configuration + Properties. Base scaffold only — the vendor-specific core is left as a marked 要確認. Use when adding a BFF feature that calls an external SDK / cloud API (OCR, AI, vision, device) instead of a microservice.
---

# Integration skill (external-integration features) — cm-be-bff-web

A _base_ generator for the BFF features that **do not delegate to a microservice** but instead
call an external library / cloud API directly — OCR (Azure Vision / AWS Bedrock),
AI (Bedrock), and any future vision/AI/device integration. These all share **one repeating
skeleton**: `Controller → Service → infrastructure Gateway(s) → Config/Properties`. This skill
scaffolds that skeleton so the developer only hand-writes the **vendor-specific core**.

This is **distinct from the `cm-be-bff-common:scaffold-bff-feature` skill**, which generates the standard CRUD-over-gRPC chain
(Controller → Service → `@GrpcClient`). Use `cm-be-bff-common:scaffold-bff-feature` when the feature calls a microservice; use
**this** skill when the feature wraps an external SDK/API via an `infrastructure/<vendor>/` gateway.

## When to use

- Adding an `option/common` (or similar) feature whose work is done by an **external SDK / cloud
  API** (OCR, AI, document/vision processing, an external device), not by a
  downstream microservice.

## Scope

- **Generates (the wrapper / boilerplate):**
  - `controller/option/common/OptionCommon<Feature>Controller` — implements the spec-generated
    `*Api`, delegates to the Service, wraps the response.
  - `service/option/common/OptionCommon<Feature>Service` + `*ServiceImpl` — input validation,
    gateway orchestration (incl. primary→fallback), response-model mapping, error mapping.
  - `infrastructure/<vendor>/<feature>/OptionCommon<Vendor><Feature>Gateway` — a `@Component` that
    wraps the vendor SDK, with the **actual SDK call left as a `// 要確認`**.
  - `configuration/App<Feature>Configuration` + `autoconfigure/<Feature>Properties` — `app.<feature>`
    configuration binding.
- **Does NOT generate (hand-written — bespoke core):** the vendor decode/analyze/prompt logic,
  result parsing (e.g. bounding-box ordering, JSON field extraction), prompt templates, and
  the SSE streaming protocol. The skill marks each with `// 要確認` so nothing is silently faked.
- **Prerequisite, not generated here:** the API contract. Define the endpoint in the spec project
  first; the `com.cm.http.api.*Api` interface and `com.cm.http.model.*` request/response models
  are generated from it and arrive on the classpath as a jar. This skill **implements** that
  generated `*Api`; it does not author the OpenAPI.

## How to use

| Pattern          | File                 | Description                                                                                 |
| ---------------- | -------------------- | ------------------------------------------------------------------------------------------- |
| Initial creation | `references/init.md` | Naming, file map, and templates to scaffold the integration skeleton (vendor core = 要確認) |

## Related

- Repo conventions & build constraints: the repository `CLAUDE.md`.
- For a feature backed by a **microservice** (gRPC), use the `cm-be-bff-common:scaffold-bff-feature` skill instead.
