# gRPC server-layer rules

Applies to: `**/grpc/**/*.java`

Classes in `grpc/core/<domain>` are the service's inbound entry from the BFF. Each is a thin adapter that delegates to a `*Service`.

## Shape

- `@GrpcService` (`net.devh.boot.grpc.server.service.GrpcService`) + `@RequiredArgsConstructor`; inject the `*Service` as a `private final` field.
- `extends` the **generated `*ServiceImplBase`** from `com.fw.grpc.*` and `@Override` the RPC method. Never create/stub the base class or the request/response message types — they come from the `cm-be-spec` jar.
- **Delegate only — no business logic.** Call the service, then `responseObserver.onNext(response)` followed by `responseObserver.onCompleted()`.

## Error handling

The sources disagree on where exceptions become gRPC `Status`. Each rule is kept as a named variant, selected by the repository `CLAUDE.md` `## Policies` → `grpc-error-mapping`. If it is not set, ask the user.

### Variant `local-status-mapping` (source: cm-be-ms-log)

This service does **not** have a central gRPC exception advice wired in, so each gRPC impl translates failures locally:

- For input/validation failures (the service throws `IllegalArgumentException`): catch it and respond `Status.INVALID_ARGUMENT.withDescription(e.getMessage()).asRuntimeException()`.
- For write/save RPCs: catch the broad failure and forward it via `responseObserver.onError(ex)`.
- Do not swallow exceptions silently; always complete the observer via `onCompleted()` or `onError(...)`.
- The typed `com.scm.core.exception.*` (`BadRequestException`, `ForbiddenException`, `NotFoundException`) are available; if a central advice is later introduced, route them there.

### Variant `central-advice` (sources: cm-be-ms-core, cm-be-ms-owner)

- **Delegate only — no business logic.** End with `onNext(...)` then `onCompleted()`. Don't catch domain exceptions (a central advice maps them to gRPC `Status`). (source: cm-be-ms-core `init.md`, see `../templates/crud-grpc-server.md` ⑥)
- No business logic; don't catch domain exceptions (central `Status` mapping). (source: cm-be-ms-owner `init.md`, see `../templates/grpc-gateway.md` ⑤)
