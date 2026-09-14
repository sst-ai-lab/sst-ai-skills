# External-integration feature — initial scaffold (cm-be-bff-web)

This scaffolds the **repeating skeleton** shared by every option/common external-integration
feature (OCR / AI / vision / device). The skeleton is always the same; only the
**vendor-specific core inside the gateway** is bespoke. This skill generates the skeleton and
marks the core with `// 要確認` — it never fabricates SDK logic.

> **Marker convention:** the repo's house style forbids leaving `TODO`/placeholder comments in
> committed code (see the repository `CLAUDE.md`). The `// 要確認` markers below denote the
> bespoke parts you must implement **and remove before committing** — they are scaffolding gaps,
> not final code.

> **Out of scope (hand-written):** the vendor decode/analyze/prompt logic, result parsing
> (bounding-box ordering, JSON field extraction, format resolution), prompt templates, SSE streaming
> protocol. **Prerequisite:** the endpoint must exist in the spec; the `com.cm.http.api.*Api`
> interface and `com.cm.http.model.*` models are generated from it (a classpath jar). This skill
> implements that `*Api`; it does not write the OpenAPI.

## Inputs to collect first

Ask; mark unknowns as "needs confirmation / 要確認":

1. **Feature name** `<Feature>` and the module path (`option/common`).
2. **The generated spec `*Api`** this implements, its operation(s) `<ApiName>`, and the
   request/response models (`com.cm.http.model.*`). File upload? → request is `MultipartFile`.
   Returns JSON? streaming (SSE)?
3. **Vendor(s)** the gateway wraps: Azure Vision (`ImageAnalysisClient`), AWS Bedrock
   (`BedrockClient`), or other — and whether there is a **fallback** (a primary gateway → a
   secondary one).
4. **Config keys** the feature needs (binds under `app.<feature>`).

## Naming & layout

```
controller/option/common/OptionCommon<Feature>Controller.java                   ← ① implements spec *Api, delegates
service/option/common/OptionCommon<Feature>Service.java                         ← ② service interface
service/option/common/OptionCommon<Feature>ServiceImpl.java                     ← ③ validate + orchestrate gateways + map
infrastructure/<primary>/<feature>/OptionCommon<Primary><Feature>Gateway.java   ← ④a primary gateway  — step 1 (core = 要確認)
infrastructure/<fallback>/<feature>/OptionCommon<Fallback><Feature>Gateway.java ← ④b fallback gateway — step 2, only if the feature has a fallback (core = 要確認)
configuration/App<Feature>Configuration.java                                    ← ⑤ @EnableConfigurationProperties
autoconfigure/<Feature>Properties.java                                          ← ⑥ @ConfigurationProperties("app.<feature>")
```

- **One gateway per vendor**, each in its own `infrastructure/<vendor>/<feature>` package — the
  `<vendor>` segment is the SDK/provider (e.g. `azure`, `bedrock`, or a local-decode library). A
  feature with a **primary + fallback** has **two** gateways (e.g. a fast local decode as step 1,
  then a cloud vision/OCR call as step 2 when step 1 finds nothing); a single-vendor feature has
  one. The **service** injects and orchestrates them in order (see ③).
- Reuse shared types from `com.fw.core.*` (a classpath jar) — **don't redefine**:
  `ErrorCodeEnum`, and exceptions `BadRequestException` / `ServiceUnavailableException` /
  `UnreachableCodeException`. Verify their signatures against that dependency jar in the IDE.

### Naming — worked example

Every name derives from the **spec `operationId`**. A POST operation that uploads & processes is
conventionally named `post<Noun>` (e.g. `postScan`). For an operation `postScan` on feature `<Feature>`:

| Element                               | Value                                                                                          |
| ------------------------------------- | ---------------------------------------------------------------------------------------------- |
| spec endpoint                         | `/v1/web/option/common/<featurelc>/postScan`                                                   |
| operationId = controller method       | `webOptionCommon<Feature>PostScan`                                                             |
| service method                        | `postScan`                                                                                     |
| request arg                           | `MultipartFile file` (file upload) — or `OptionCommon<Feature>PostScanRequest` for a JSON body |
| response payload model                | `OptionCommon<Feature>PostScanResponse`                                                        |
| response wrapper (controller returns) | `OptionCommon<Feature>PostScanSuccessResponse`                                                 |

These are the _pattern_ — use the actual generated names from the `*Api` on the classpath. In the
templates below, `<ApiName>` = the operation in PascalCase (`PostScan`), `<apiName>` = camelCase (`postScan`).

---

## Templates

### ① Controller — `controller/option/common/OptionCommon<Feature>Controller.java`

Implements the generated `*Api`, injects the service, delegates, wraps the result in the generated
`*SuccessResponse`. No business logic, no try/catch (the service owns error mapping).

```java
@RestController
@Slf4j
@RequiredArgsConstructor
public class OptionCommon<Feature>Controller implements OptionCommon<Feature>Api {

    private final OptionCommon<Feature>Service <feature>Service;

    @Override
    public ResponseEntity<OptionCommon<Feature><ApiName>SuccessResponse> webOptionCommon<Feature><ApiName>(
        MultipartFile file
    ) {
        OptionCommon<Feature><ApiName>Response response = <feature>Service.<apiName>(file);
        log.info("Processed <feature> request for file: {}", file != null ? file.getOriginalFilename() : null);
        return ResponseEntity.ok(new OptionCommon<Feature><ApiName>SuccessResponse(response));
    }
}
```

### ② Service interface — `service/option/common/OptionCommon<Feature>Service.java`

```java
public interface OptionCommon<Feature>Service {
    /** Processes one <feature> request and returns the spec response model. */
    OptionCommon<Feature><ApiName>Response <apiName>(MultipartFile file);
}
```

### ③ Service impl — `service/option/common/OptionCommon<Feature>ServiceImpl.java`

Validate the input, orchestrate the gateway(s) (primary → optional fallback), build the generated
response model, map failures to a typed `com.fw.core.exception.*`. Keep the **business
normalization a `// 要確認`** — that part is bespoke.

```java
@Slf4j
@Service
@RequiredArgsConstructor
public class OptionCommon<Feature>ServiceImpl implements OptionCommon<Feature>Service {

    private static final String INVALID_FILE_MESSAGE = "File must not be empty";
    private static final String UNSUPPORTED_TYPE_MESSAGE = "Only image files are supported";
    private static final String IMAGE_CONTENT_TYPE_PREFIX = "image/";

    private final OptionCommon<Primary><Feature>Gateway primaryGateway;     // step 1
    private final OptionCommon<Fallback><Feature>Gateway fallbackGateway;   // step 2 — drop this field if there is no fallback

    @Override
    public OptionCommon<Feature><ApiName>Response <apiName>(MultipartFile file) {
        validateInput(file);
        try {
            byte[] bytes = file.getBytes();

            // Step 1: primary gateway. Step 2: fall back only when step 1 finds nothing (returns null).
            <Feature>GatewayResult result = primaryGateway.process(bytes);
            if (result == null) {
                result = fallbackGateway.process(bytes);   // remove this block for a single-vendor feature
            }

            // 要確認: map `result` into the generated response model + any business normalization
            //        (field extraction, format resolution). Set the real generated model fields:
            OptionCommon<Feature><ApiName>Response response = new OptionCommon<Feature><ApiName>Response();
            // e.g. response.value(result.value()); response.format(result.format());
            return response;
        } catch (IOException e) {
            log.error("Error reading <feature> file bytes", e);
            throw new BadRequestException(ErrorCodeEnum.INTERNAL_SERVER_ERROR, "Error processing <feature> file");
        }
    }

    private void validateInput(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BadRequestException(ErrorCodeEnum.REQUEST_PARAMETER_INVALID, INVALID_FILE_MESSAGE);
        }
        String contentType = file.getContentType();
        if (contentType == null || !contentType.toLowerCase(Locale.ROOT).startsWith(IMAGE_CONTENT_TYPE_PREFIX)) {
            throw new BadRequestException(ErrorCodeEnum.REQUEST_PARAMETER_INVALID, UNSUPPORTED_TYPE_MESSAGE);
        }
    }
}
```

> For prompt/schema-driven features (OCR/AI), add a `@PostConstruct init()` that loads templates
> from `<Feature>Properties` via `ResourceLoader`, and inject the vendor client + `ObjectMapper`.

### ④ Gateway — `infrastructure/<vendor>/<feature>/OptionCommon<Vendor><Feature>Gateway.java`

A `@Component` that wraps **one** vendor SDK — **one gateway file per vendor**. With a fallback you
generate two from this same template: the **primary** (step 1) and the **fallback** (step 2); each
lives in its own `infrastructure/<vendor>/<feature>` package. This is the boundary between the app
and the vendor. The **actual SDK call is the 要確認** — the skill only sets up the shape, error
handling, and return type. Return a small `record`/primitive; **return `null` for "nothing detected"**
— that is exactly what lets the service move from step 1 to step 2; throw `UnreachableCodeException`
on unexpected failure.

```java
@Slf4j
@Component
@RequiredArgsConstructor   // omit if the gateway has no injected dependencies
public class OptionCommon<Vendor><Feature>Gateway {

    // e.g. private final ObjectProvider<ImageAnalysisClient> clientProvider;  // when the client may be absent
    // e.g. private final BedrockClient bedrockClient;

    public <Feature>GatewayResult process(byte[] imageBytes) {
        try {
            // 要確認: call the vendor SDK here, e.g.
            //   Azure:   imageAnalysisClient.analyze(BinaryData.fromBytes(bytes), List.of(VisualFeatures.READ), null)
            //   Bedrock: bedrockClient / ConverseStream ...
            // Map the vendor result into <Feature>GatewayResult; return null when nothing is detected.
            return null;
        } catch (Exception e) {
            log.error("Failed to process <feature> with <Vendor>", e);
            throw new UnreachableCodeException(
                ErrorCodeEnum.INTERNAL_SERVER_ERROR, "Failed to process <feature> with <Vendor>", e);
        }
    }

    /** Minimal payload returned by the gateway — fields depend on the vendor output. */
    public record <Feature>GatewayResult(String format, String value) {}
}
```

> When the vendor client may be unconfigured, inject it as `ObjectProvider<Client>` and
> `getIfAvailable()` → return `null` if absent, so the feature degrades gracefully instead of
> failing startup.

> **Shared result type:** when a primary + fallback feed the same service, declare
> `<Feature>GatewayResult` **once** (a standalone record in the feature package, or in the primary
> gateway) and have both gateways return it — do **not** declare the record twice.

### ⑤ Configuration — `configuration/App<Feature>Configuration.java`

```java
@Configuration
@EnableConfigurationProperties(<Feature>Properties.class)
public class App<Feature>Configuration {
    // Add @Bean methods here only if a vendor client must be constructed from properties.
}
```

### ⑥ Properties — `autoconfigure/<Feature>Properties.java`

```java
@ConfigurationProperties(prefix = "app.<feature>")
@Data
public class <Feature>Properties {
    // bind app.<feature>.* keys (endpoint, timeoutSeconds, systemPrompt, ...)
}
```

## Streaming (SSE) variant — advanced, optional

OCR/AI also expose **streaming** endpoints (`OptionCommon<Feature>StreamingController`) where the
gateway streams partial results back via a callback
(`BiConsumer<String, Map<String, Object>> onFieldCompleted`) and the controller emits SSE. The
skeleton (controller → service → gateway) is the same; the **streaming protocol and callback wiring
are bespoke** — scaffold the classes, leave the streaming body as `// 要確認`.

## Completion checklist

1. Controller `implements` the generated `*Api`, delegates only, no try/catch.
2. Service validates input, orchestrates gateway(s) (+ fallback if any), maps to the generated
   response model, maps failures to a typed `com.fw.core.exception.*` with `ErrorCodeEnum`.
3. Each vendor has its own `infrastructure/<vendor>/<feature>` `@Component` gateway; the SDK call is
   a clearly-marked `// 要確認`; `null` = nothing detected; `UnreachableCodeException` on failure.
4. `App<Feature>Configuration` + `<Feature>Properties` bind `app.<feature>.*`.
5. The endpoint exists in the spec and the `*Api`/models are on the classpath. **No tests generated.**
6. Shared `com.fw.core.*` types reused, not redefined.
