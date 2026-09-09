---
name: backend-review
description: Review backend changes for correctness, API and contract compatibility, data integrity, reliability, concurrency, transactions, observability, and maintainability.
---

# Backend Review

Apply this skill when the reviewed change affects backend services, APIs, domain logic, persistence, messaging, RPC, jobs, or service integration.

Focus on high-signal issues introduced by the change:

- Business logic correctness and edge cases.
- API, schema, serialization, protocol, and backward-compatibility risks.
- Error propagation, retries, timeouts, cancellation, and failure handling.
- Transaction boundaries, consistency, idempotency, and partial-failure behavior.
- Database queries, locking, pagination, ordering, and data integrity.
- Concurrency, shared state, race conditions, and lifecycle ordering.
- Messaging/event semantics including duplicate delivery and ordering assumptions.
- Resource lifecycle, connection handling, cleanup, and leaks.
- Logging and observability when missing context would make production failures materially harder to diagnose.
- Configuration changes that can alter runtime behavior unexpectedly.

Do not report generic style preferences, speculative improvements, or unrelated pre-existing issues. Validate findings against surrounding code when needed.
