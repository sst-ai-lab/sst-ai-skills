---
name: backend-review
description: Review backend changes for correctness, API and contract compatibility, data integrity, reliability, concurrency, transactions, observability, and security-sensitive regressions.
---

# Backend Review

Apply this skill when reviewing backend services, APIs, domain logic, persistence, messaging, RPC, jobs, or service integrations.

Focus on high-signal issues introduced by the reviewed change:

- Business logic correctness and edge cases.
- API, schema, serialization, protocol, and backward-compatibility risks.
- Error propagation, retries, timeouts, cancellation, and failure handling.
- Transaction boundaries, consistency, idempotency, and partial-failure behavior.
- Database queries, locking, pagination, ordering, and data integrity.
- Concurrency, shared state, race conditions, and lifecycle ordering.
- Messaging/event semantics including duplicate delivery and ordering assumptions.
- Resource lifecycle, cleanup, and leaks.
- Authentication, authorization, tenant isolation, injection, secret exposure, unsafe deserialization, and trust-boundary mistakes when relevant to the change.
- Configuration changes that can alter runtime behavior unexpectedly.

Do not report generic style preferences, speculative improvements, linter findings, or unrelated pre-existing issues. Validate findings against surrounding code when needed.
