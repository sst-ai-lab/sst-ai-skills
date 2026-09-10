# Java Backend Conventions

Use these guidelines when implementing or reviewing Java backend code.

## Correctness and APIs

- Prefer explicit contracts and preserve existing public API behavior unless a change is intentional.
- Treat nullability, exception behavior, and serialization boundaries as part of the contract.
- Avoid catching `Throwable` or overly broad exceptions unless a framework boundary explicitly requires it; preserve interruption and cancellation semantics.
- Keep domain logic out of transport/framework glue when the surrounding architecture already separates those concerns.

## Concurrency and lifecycle

- Treat shared mutable state, static state, thread-local state, callbacks, interceptors, and asynchronous listeners as concurrency-sensitive.
- Verify ordering assumptions around callbacks, completion, cleanup, and error propagation.
- Ensure thread-local or request-scoped state is cleared on all terminal paths.
- Do not block event-loop, Netty, reactive, or framework callback threads with slow I/O.

## Collections and streams

- Avoid unnecessary stream pipelines when imperative code is clearer around side effects or error handling.
- Be careful with mutable collections exposed across layers and with iteration over collections that can be modified concurrently.

## Spring and dependency injection

- Prefer constructor injection for required dependencies.
- Keep component scope explicit when state is stored on Spring-managed objects.
- Do not assume singleton components are request-scoped.
- Preserve transaction and proxy boundaries when refactoring annotated methods.

## Review checks

Pay special attention to null dereferences, Optional misuse, exception swallowing, thread safety, request-state leakage, transaction proxy behavior, resource cleanup, equality/hashCode mistakes, serialization compatibility, and framework lifecycle ordering.
