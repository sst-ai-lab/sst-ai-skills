# gRPC client rules (downstream call to {targetMicroservice})

Applies to: `**/infrastructure/grpc/**/*.java`

`infrastructure/grpc/{targetLc}`, or `infrastructure/grpc/{targetLc}/<domain>` when the calls are split per domain, holds the gRPC client used to call **`{targetMicroservice}`**. Follow the layout this repository already uses.

Repositories differ in what a client method returns. Each way is kept as a named variant below. Follow the variant the existing `*ClientImpl` classes of this repository use; when there is none, ask the user.

## Wiring — declared in config, injected as a bean

> **Key rule:** `@GrpcClient` is declared **only in `GrpcClientConfiguration`** (re-exposed as a `@Bean`) — **never** on a field inside a `*ClientImpl`. Follow the pattern below.

- Declare the downstream stub in **`configuration/GrpcClientConfiguration`** with `@GrpcClient("<channelName>")` on a private field, and re-expose it as a Spring `@Bean`:

  ```java
  @GrpcClient("{grpcChannel}")
  private Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;

  @Bean
  Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStubBean() {
    return web{TargetPascal}[Tag]ServiceBlockingStub;
  }
  ```

- Channel name is **`"{grpcChannel}"`** → resolved from `grpc.client.{grpcChannel}.address` (default `localhost:{port}`). Don't invent new channel names for `{targetMicroservice}` calls.

## Client interface + impl

- Each downstream call gets a `*Client` interface and a `*ClientImpl` (`@Component` + `@RequiredArgsConstructor`).
- The impl injects the **stub bean and the MapStruct mapper as `private final` constructor deps** (no `@GrpcClient` on impl fields).

### Variant `map-to-entities`

- A client method maps the domain request → gRPC request (mapper), calls the blocking stub, and maps the gRPC response rows back to entities:
  ```java
  var resp = stub.[rpc](mapping.toGrpcRequest(request));

  return resp.getRowsList().stream().map(mapping::toEntity).toList();
  ```
- `com.cm.grpc.*` stubs and message types come from the `cm-be-spec` jar — never stub them locally.

### Variant `raw-response`

- A client method maps this service's request to the `{targetMicroservice}` request (via the mapper), calls the blocking stub, and **returns the raw `{targetMicroservice}` response**. The response mapping back to this service's message happens in the **caller** (the gRPC service impl, or the orchestration service on write paths) — not inside the client:
  ```java
  public Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request) {
    return web{TargetPascal}[Tag]ServiceBlockingStub.[rpc]([domain]GrpcMapping.to{TargetPascal}Request(request));
  }
  ```
- Stubs and message types (`com.cm.grpc.*`) come from the `cm-be-spec` jar — never stub them locally.
