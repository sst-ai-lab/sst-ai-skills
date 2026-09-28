# gRPC server-layer rules

Applies to: `**/grpc/**/*.java`

Classes in `grpc/core/<domain>` are the service's inbound entry from the BFF. Each is a thin adapter that delegates to a `*Service`.

## Shape

- `@GrpcService` (`net.devh.boot.grpc.server.service.GrpcService`) + `@RequiredArgsConstructor`; inject the `*Service` as a `private final` field.
- `extends` the **generated `*ServiceImplBase`** from `com.cm.grpc.*` and `@Override` the RPC method. Never create/stub the base class or the request/response message types — they come from the `cm-be-spec` jar.
- **Delegate only — no business logic.** Call the service, then `responseObserver.onNext(response)` followed by `responseObserver.onCompleted()`.

## Error handling

A global exception advice is already wired in. `GrpcGlobalExceptionHandler` (`@GrpcAdvice`, in `com.fw.grpc.core.exception.handler`) is auto-registered by the gRPC server starter in every service that depends on it, unless the service declares a handler bean of its own. **The gRPC impl therefore does not translate domain failures itself.**

What the advice already maps:

| Thrown by the service layer                                | gRPC `Status`         |
| ---------------------------------------------------------- | --------------------- |
| `BadRequestException`, `InvalidRequestPayloadException`     | `INVALID_ARGUMENT`    |
| `NotFoundException`                                        | `NOT_FOUND`           |
| `ConflictException`                                        | `ALREADY_EXISTS`      |
| `UnauthorizedException`                                    | `UNAUTHENTICATED`     |
| `ForbiddenException`                                       | `PERMISSION_DENIED`   |
| `UnprocessableEntityException`                             | `FAILED_PRECONDITION` |
| `ServiceUnavailableException`                              | `UNAVAILABLE`         |
| `TooManyRequestsException`                                 | `RESOURCE_EXHAUSTED`  |
| `StatusRuntimeException` from an upstream gRPC call         | passed through unchanged, keeping its original status and trailers |
| `DataAccessException`, or any other exception               | `INTERNAL`            |

- **Throw a typed exception from `com.fw.core.exception.*`** (they all extend `ServerErrorException`) and let the advice map it. Don't catch it in the gRPC impl to convert it by hand.
- The advice also attaches the `x-error-code` and `x-errors` trailers, so a `BadRequestException` carrying `InvalidRequestExceptionRecord`s reaches the caller with per-field detail. Catching the exception locally throws that detail away.
- Catch locally **only** for an exception outside that family that needs a specific status — `IllegalArgumentException`, for instance, would otherwise reach the caller as `INTERNAL`:

  ```java
  } catch (IllegalArgumentException e) {
      responseObserver.onError(
          Status.INVALID_ARGUMENT.withDescription(e.getMessage()).asRuntimeException());
  }
  ```

  Prefer throwing `BadRequestException` from the service so the advice handles it, rather than adding such a catch.
- Never swallow an exception: always complete the observer, via `onCompleted()` or `onError(...)`.
