# gRPC client rules (downstream call to {targetMicroservice})

Applies to: `**/infrastructure/grpc/**/*.java`

`infrastructure/grpc/{targetLc}` (source: cm-be-ms-bill) / `infrastructure/grpc/{targetLc}/<domain>` (source: cm-be-ms-owner) holds the gRPC client used to call **`{targetMicroservice}`**.

The two sources share the same template; they differ in what a client method returns. That choice is kept as a named variant, selected by the repository `CLAUDE.md` `## Policies` → `grpc-client-return`. If it is not set, ask the user.

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

- Channel name is **`"{grpcChannel}"`** → resolved from `grpc.client.{grpcChannel}.address` (default `localhost:{port}`). Don't invent new channel names for `{targetMicroservice}` calls. (source: cm-be-ms-owner)

## Client interface + impl

- Each downstream call gets a `*Client` interface and a `*ClientImpl` (`@Component` + `@RequiredArgsConstructor`).
- The impl injects the **stub bean and the MapStruct mapper as `private final` constructor deps** (no `@GrpcClient` on impl fields).

### Variant `map-to-entities` (source: cm-be-ms-bill)

- A client method maps the domain request → gRPC request (mapper), calls the blocking stub, and maps the gRPC response rows back to entities:
  ```java
  var resp = stub.[rpc](mapping.toGrpcRequest(request));

  return resp.getRowsList().stream().map(mapping::toEntity).toList();
  ```
- `com.fw.grpc.*` stubs/messages come from `cm-be-spec` — never stub them locally.

### Variant `raw-response` (source: cm-be-ms-owner)

- A client method maps this service's request to the `{targetMicroservice}` request (via the mapper), calls the blocking stub, and **returns the raw `{targetMicroservice}` response**. The response mapping back to this service's message happens in the **caller** (the gRPC service impl, or the orchestration service on write paths) — not inside the client:
  ```java
  public Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request) {
    return web{TargetPascal}[Tag]ServiceBlockingStub.[rpc]([domain]GrpcMapping.to{TargetPascal}Request(request));
  }
  ```
- Stubs/messages (`com.scm.grpc.*`) come from `scm-be-grpc-core` — never stub them locally.
