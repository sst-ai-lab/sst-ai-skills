# gRPC Backend Conventions

Use these guidelines when implementing or reviewing gRPC services, interceptors, observers, clients, and protobuf boundaries.

## Contracts and status

- Treat protobuf messages, field presence, service methods, metadata, and status codes as public contracts.
- Preserve unary semantics: exactly one response message for successful unary calls unless the framework abstraction explicitly handles otherwise.
- Do not infer success before the final gRPC `Status` is known when behavior depends on terminal status.
- Keep transport errors and business payloads distinct unless the protocol intentionally carries both.

## Interceptors and observers

- Verify interceptor ordering when behavior depends on observing final status, exceptions, or trailers.
- Observer/listener hooks should be fast and must not destabilize the primary request path.
- Isolate observer failures so one observer does not prevent others or break the call unless failure is intentionally fatal.
- Be explicit about the thread on which callbacks execute; avoid slow or blocking work on gRPC/Netty callback threads.

## Protobuf

- Preserve wire compatibility: avoid reusing field numbers or changing field meaning incompatibly.
- Be careful with default instances, field presence, oneof semantics, unknown fields, and generated-message type assumptions.
- When reflecting over protobuf messages, validate descriptors and message classes rather than assuming all marshallers are protobuf-based.

## Review checks

Pay special attention to duplicate response sends, lost error status, observer ordering, callback thread assumptions, payloads dropped on error paths, protobuf compatibility, metadata/trailer propagation, cancellation, deadlines, and resource cleanup.
