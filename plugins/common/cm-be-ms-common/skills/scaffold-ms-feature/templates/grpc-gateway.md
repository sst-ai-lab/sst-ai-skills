# Gateway feature — initial creation

This scaffolds an **{serviceLc} M2M gateway feature**: an {serviceLc}-facing gRPC endpoint served by
calling `{targetMicroservice}` over gRPC and reshaping the result. This service has one shape —
**gRPC impl → {targetLc} gRPC client → MapStruct remap** (with an orchestration service only for
write/multi-step flows) — and **owns no database**. Templates below are skeletons; the
per-line rules live in `../references/*.md`.

**Prerequisite:** the OpenAPI/proto spec is built, so both the {serviceLc} stubs (`Web{ServicePascal}…`,
this service's API) and the downstream {targetLc} stubs (`Web{TargetPascal}…`) exist as internal jars.

> **Out of scope:** database / MyBatis / `@Transactional` (no datasource — fetch from
> `{targetMicroservice}`); Kafka / Redis / M2M-token plumbing (not part of feature scaffolding);
> `com.cm.grpc.*` / `com.fw.core.*` (external internal jars — never stub); `build/`;
> **tests**. **Root package:** `{basePackage}`.

**Reuse the shared framework — don't reinvent:** before writing an exception or error code,
check the shared framework first — reuse `com.fw.core.exception.*` (`ForbiddenException`,
`NotFoundException`, `BadRequestException`) + `ErrorCodeEnum`.

## Inputs to collect first

Ask; mark anything unknown as "needs confirmation / 要確認" (don't invent):

1. **Function ID & name (機能ID・機能名)** → class names.
2. **{ServicePascal} gRPC service + RPC**: the generated `Web{ServicePascal}…ServiceImplBase` and the RPC to
   implement, with its `Grpc{ServicePascal}…` request/response messages.
3. **Downstream {targetLc} call**: which `{targetMicroservice}` gRPC service/method (the `Web{TargetPascal}…` stub) and
   its `Grpc{TargetPascal}…` request/response messages provide the data.
4. **Read or write/multi-step?** A simple read can call the client straight from the gRPC
   impl; a write or multi-step flow goes through an orchestration service.

## Naming

Shared design-classification naming. The {serviceLc} feature chain (impl classes drop the `Web`
prefix; the generated stubs keep it):

| Layer                                    | Pattern                                                                                           | Example                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| gRPC impl                                | `[{ServicePascal}Tag]GrpcService` extends generated `Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase` | `{ServicePascal}SoSoSearchGrpcService` / `Web{ServicePascal}SoSoSearchServiceImplBase` |
| {TargetPascal} client                              | `{TargetPascal}[Tag]Client` + `{TargetPascal}[Tag]ClientImpl`                                                         | `{TargetPascal}{ServicePascal}SoSearchClient(Impl)`                                    |
| MapStruct                                | `[Domain]GrpcMapping`                                                                             | `SoSearchGrpcMapping`                                              |
| Orchestration service (write/multi-step) | `[Tag]Service` + `[Tag]ServiceImpl`                                                               | `{ServicePascal}SoUpdateService(Impl)`                                       |

{ServicePascal} messages = `Grpc{ServicePascal}…`; downstream {targetLc} messages/stubs = `Grpc{TargetPascal}…` /
`Web{TargetPascal}…ServiceBlockingStub` — all external (`com.cm.grpc.*`), never stub.

## File / directory map (this repo only)

```
src/main/java/{basePackagePath}/
├─ grpc/{serviceLc}/<domain>/[{ServicePascal}Tag]GrpcService.java               ← ⑤ gRPC impl (delegate only)
├─ infrastructure/
│  ├─ grpc/{targetLc}/<domain>/
│  │  ├─ {TargetPascal}[Tag]Client.java                                   ← ② client interface
│  │  └─ {TargetPascal}[Tag]ClientImpl.java                               ← ② client impl (@Component)
│  └─ mapping/[Domain]GrpcMapping.java                          ← ③ MapStruct ({serviceLc} ↔ {targetLc})
├─ service/                                                     ← ④ orchestration (write/multi-step only)
│  ├─ [Tag]Service.java
│  └─ [Tag]ServiceImpl.java
└─ configuration/GrpcClientConfiguration.java                  ← ① add the downstream stub + @Bean
```

## Data flow

```
@GrpcService impl  (delegate-only)
  → (read) {targetLc} client directly, or (write/multi-step) orchestration service
      → {TargetPascal}[Tag]ClientImpl: mapper.to{TargetPascal}Request({serviceLc}) → blocking stub on channel "{grpcChannel}" → raw {targetLc} response
      → {targetMicroservice} (:{port})
  → caller maps {targetLc}→{serviceLc} (mapper.to{ServicePascal}Response) → onNext + onCompleted
```

The client returns the **raw** {targetLc} response; the {targetLc}→{serviceLc} mapping happens in the caller
(the gRPC impl, or the orchestration service on writes) — not inside the client.

## Generation order

1. ③ MapStruct mapping (`to{TargetPascal}Request` + `to{ServicePascal}Response`)
2. ② {TargetPascal} client interface + impl
3. ① Register the downstream stub in `GrpcClientConfiguration` (+ `@Bean`)
4. ④ Orchestration service — only for write/multi-step
5. ⑤ gRPC impl

---

## Templates

### ① GrpcClientConfiguration — register the downstream stub

Apply `../references/grpc-client.md`. Declare the {targetLc} blocking stub with
`@GrpcClient("{grpcChannel}")` on a private field **here** and re-expose it as a `@Bean` — **never**
put `@GrpcClient` on a `*ClientImpl` field. Channel is always `"{grpcChannel}"`.

```java
package {basePackage}.configuration;

@Configuration
@ConditionalOnClass(ManagedChannel.class)
public class GrpcClientConfiguration {

    @GrpcClient("{grpcChannel}")
    private Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;

    /** Exposes the {targetLc} [Tag] blocking stub as a Spring bean. */
    @Bean
    Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStubBean() {
        return web{TargetPascal}[Tag]ServiceBlockingStub;
    }
}
```

### ② {TargetPascal} client — `infrastructure/grpc/{targetLc}/<domain>/{TargetPascal}[Tag]Client.java` + `…Impl.java`

`@Component` + `@RequiredArgsConstructor`; inject the **stub bean** (the `@Bean` from ①) and
the mapper as `private final`. Map {serviceLc}→{targetLc} via the mapper, call the stub, **return the
raw {targetLc} response**.

```java
public interface {TargetPascal}[Tag]Client {
    Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request);
}
```

```java
package {basePackage}.infrastructure.grpc.{targetLc}.[domain];

@Component
@RequiredArgsConstructor
public class {TargetPascal}[Tag]ClientImpl implements {TargetPascal}[Tag]Client {

    private final Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;
    private final [Domain]GrpcMapping [domain]GrpcMapping;

    @Override
    public Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request) {
        return web{TargetPascal}[Tag]ServiceBlockingStub.[{targetLc}Rpc]([domain]GrpcMapping.to{TargetPascal}Request(request));
    }
}
```

### ③ MapStruct mapping — `infrastructure/mapping/[Domain]GrpcMapping.java`

Apply `../references/mapstruct-mapping.md`. Standard header; **flat interface —
no `BaseMapping`**; add `collectionMappingStrategy = ADDER_PREFERRED` only when mapping
`repeated`/collection fields. Map only the directions the use case needs; give nested
items/details their own methods.

```java
package {basePackage}.infrastructure.mapping;

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED   // only with repeated/collection fields
)
public interface [Domain]GrpcMapping {

    Grpc{TargetPascal}[...]Request to{TargetPascal}Request(Grpc{ServicePascal}[...]Request request);          // {serviceLc} → {targetLc}
    Grpc{ServicePascal}[...]Response to{ServicePascal}Response(Grpc{TargetPascal}[...]SuccessResponse source); // {targetLc} → {serviceLc}

    Grpc{ServicePascal}[...]Item to{ServicePascal}Item(Grpc{TargetPascal}[...]Item source);                   // nested (lists wired automatically)
    Grpc{ServicePascal}[...]Detail to{ServicePascal}Detail(Grpc{TargetPascal}[...]Detail source);
}
```

Rename mismatched fields with `@Mapping(target = …, source = …)`; for `repeated` fields map
to the logical name (not `…List`).

### ④ Orchestration service — `service/[Tag]Service.java` + `…ServiceImpl.java` (write/multi-step only)

A simple read skips this and calls the client from the gRPC impl. Apply
`../references/service-layer.md`: interface + `@Service` impl
(`@RequiredArgsConstructor`, `private final` deps = {targetLc} client(s) + mapper if it shapes the
response). **No `@Transactional`, no DB.** Validate input → call {targetLc} client(s) → map/
aggregate → return the {serviceLc} message. Throw typed `com.fw.core.exception.*`
(`ForbiddenException` / `BadRequestException` / `NotFoundException`) on failure; don't
swallow downstream gRPC errors.

```java
public interface [Tag]Service {
    Grpc{ServicePascal}[...]Response [method](Grpc{ServicePascal}[...]Request request);
}
```

```java
package {basePackage}.service;

@Service
@RequiredArgsConstructor
public class [Tag]ServiceImpl implements [Tag]Service {

    private final {TargetPascal}[Tag]Client {targetLc}[Tag]Client;
    private final [Domain]GrpcMapping [domain]GrpcMapping;

    @Override
    public Grpc{ServicePascal}[...]Response [method](Grpc{ServicePascal}[...]Request request) {
        // validate input (e.g. throw ForbiddenException when scope/permission is missing)
        Grpc{TargetPascal}[...]SuccessResponse {targetLc}Response = {targetLc}[Tag]Client.[method](request);
        return [domain]GrpcMapping.to{ServicePascal}Response({targetLc}Response);
    }
}
```

### ⑤ gRPC impl — `grpc/{serviceLc}/<domain>/[{ServicePascal}Tag]GrpcService.java`

`@Slf4j @GrpcService @RequiredArgsConstructor`, `extends Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase`.
**Delegate only:** inject the {targetLc} client + mapper (simple read) or the orchestration
service (write/multi-step); call it, map {targetLc}→{serviceLc} if the impl owns that step, then
`onNext` + `onCompleted`. No business logic; don't catch domain exceptions (central `Status`
mapping).

```java
package {basePackage}.grpc.{serviceLc}.[domain];

@Slf4j
@GrpcService
@RequiredArgsConstructor
public class [{ServicePascal}Tag]GrpcService extends Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase {

    private final {TargetPascal}[Tag]Client {targetLc}[Tag]Client;       // simple read
    private final [Domain]GrpcMapping [domain]GrpcMapping;
    // private final [Tag]Service [tag]Service;           // write/multi-step instead

    @Override
    public void [rpc](
            Grpc{ServicePascal}[...]Request request,
            StreamObserver<Grpc{ServicePascal}[...]Response> responseObserver) {
        Grpc{TargetPascal}[...]SuccessResponse {targetLc}Response = {targetLc}[Tag]Client.[method](request);   // read
        responseObserver.onNext([domain]GrpcMapping.to{ServicePascal}Response({targetLc}Response));
        responseObserver.onCompleted();
    }
}
```

## Completion checklist

1. gRPC impl: `@GrpcService`, extends `Web[{ServicePascal}Tag]ServiceImplBase`, delegates only, `onNext` + `onCompleted`, no exception catching.
2. {TargetPascal} client: stub declared `@GrpcClient("{grpcChannel}")` + `@Bean` in `GrpcClientConfiguration`; `*ClientImpl` injects the stub bean + mapper as `private final` (no `@GrpcClient` on the impl); returns the raw {targetLc} response.
3. MapStruct: standard header (flat, no `BaseMapping`; `ADDER_PREFERRED` only with collections); `to{TargetPascal}Request` / `to{ServicePascal}Response` (+ nested) as the use case needs.
4. Orchestration service (only if write/multi-step): `@Service`, no `@Transactional`/DB; typed exceptions; calls {targetLc} client(s).
5. No DB/MyBatis; no Kafka/Redis/M2M added; no tests; no stubbed `com.cm.grpc.*` / `com.fw.core.*`; no edits to `build/`.
