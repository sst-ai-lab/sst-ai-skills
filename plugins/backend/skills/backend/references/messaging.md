# Messaging Backend Conventions

Use these guidelines when implementing or reviewing Kafka, queue, event, and asynchronous messaging code.

## Delivery semantics

- Assume duplicate delivery is possible unless the infrastructure contract proves otherwise.
- Make consumer side effects idempotent when messages can be retried or redelivered.
- Do not assume global ordering; reason about partition/key ordering explicitly.
- Distinguish at-most-once, at-least-once, and effectively-once behavior and preserve the intended contract.

## Producer behavior

- Define what happens when publish succeeds but surrounding business work fails, and vice versa.
- Avoid dual-write inconsistencies between database state and message publication; use the existing outbox/transaction pattern when present.
- Preserve message keys, headers, schema/version fields, and routing semantics when they are part of downstream behavior.

## Consumer behavior

- Handle retries, poison messages, dead-letter behavior, and partial failures explicitly.
- Commit/ack only at the point consistent with the required delivery semantics.
- Keep handlers safe under concurrent processing and re-delivery.
- Make external side effects resilient to duplicate processing.

## Contracts and compatibility

- Treat event schemas as contracts shared with independent deployables.
- Prefer additive schema evolution and tolerate older/newer producers where the system requires rolling deployments.
- Be careful with serialization naming, defaults, enum evolution, and optional fields.

## Review checks

Pay special attention to duplicate side effects, lost messages, premature acknowledgement, retry storms, ordering assumptions, incompatible schema changes, producer/consumer serialization mismatch, missing idempotency, and database/message consistency gaps.
