---
name: backend
description: Apply SST backend engineering conventions when implementing, refactoring, debugging, or explaining backend services, APIs, domain logic, persistence, messaging, RPC, jobs, and service integrations.
---

# Backend

Use this skill for backend development work.

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

When modifying an existing codebase, inspect nearby implementations and project-level `CLAUDE.md` instructions before introducing new patterns.

Do not perform unrelated refactors or introduce abstractions without a concrete need.
