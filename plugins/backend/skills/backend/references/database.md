# Database Backend Conventions

Use these guidelines when implementing or reviewing persistence and database changes.

## Transactions and consistency

- Make transaction boundaries explicit and keep related writes atomic when partial success would corrupt business state.
- Verify behavior when downstream calls fail before or after commit.
- Preserve idempotency for retryable operations.
- Do not assume application-level checks are sufficient when correctness requires database constraints.

## Queries and data integrity

- Check pagination, ordering, filtering, null semantics, and uniqueness assumptions.
- Avoid unbounded queries on paths that can grow with production data.
- Verify indexes support newly introduced access patterns when performance depends on them.
- Treat migrations as compatibility-sensitive: consider deployment order, backfills, defaults, locks, and rollback/forward-fix behavior.

## Concurrency

- Check lost updates, race conditions, read-modify-write sequences, and locking/isolation assumptions.
- Use optimistic/pessimistic locking only when it matches the domain and existing architecture.
- Be careful with uniqueness races: prefer database-enforced constraints over pre-check-only logic.

## Review checks

Pay special attention to missing constraints, N+1 queries, unstable pagination, transaction leaks, partial writes, retry duplication, lock contention, unsafe migrations, schema/application version skew, and data corruption on concurrent requests.
