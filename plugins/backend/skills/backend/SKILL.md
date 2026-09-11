---
name: backend
description: Apply SST backend engineering conventions when implementing, refactoring, debugging, explaining, or reviewing backend services, APIs, domain logic, persistence, messaging, RPC, jobs, and service integrations.
---

# Backend

Use this skill for backend development and surrounding implementation context during backend reviews.

Prefer solutions that are explicit, testable, maintainable, and consistent with the surrounding codebase. Preserve existing architecture and contracts unless the task explicitly requires a change.

Focus on:

- Correct business logic and clear domain boundaries.
- Stable API, schema, serialization, and protocol contracts.
- Explicit error handling and meaningful failure propagation.
- Correct transaction, consistency, idempotency, retry, timeout, and cancellation behavior.
- Safe database access, pagination, ordering, locking, and data integrity.
- Concurrency and lifecycle correctness.
- Messaging and event semantics, including duplicate delivery and ordering assumptions.
- Resource cleanup and connection lifecycle.
- Useful logging and observability without exposing sensitive data.
- Configuration that is explicit and safe across environments.

When modifying or reviewing an existing codebase, inspect nearby implementations and applicable project-level `CLAUDE.md` instructions before introducing or recommending new patterns.

Load the relevant reference guidance only when it applies to the change being worked on:

- Java backend code: `references/java.md`
- Python backend code: `references/python.md`
- gRPC/protobuf/interceptor/observer code: `references/grpc.md`
- Database, persistence, transaction, or migration code: `references/database.md`
- Kafka, queue, event, or asynchronous messaging code: `references/messaging.md`

Multiple references may apply to the same change. For example, a Java gRPC service that writes to a database may require `java.md`, `grpc.md`, and `database.md`.

Do not load unrelated references just because they exist. Use progressive disclosure: start with this skill, then consult only the reference files needed to understand the current task or validate a finding.

For testable plugin releases, keep behavior changes small and easy to verify before adding broader conventions.

Do not perform unrelated refactors or introduce abstractions without a concrete need.
