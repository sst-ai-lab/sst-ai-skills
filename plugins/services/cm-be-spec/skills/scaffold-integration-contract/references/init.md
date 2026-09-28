
# Create a BFF-only TypeSpec contract (no gRPC)

For a feature whose work is done **inside the BFF by an external SDK/cloud API** (OCR, AI, vision,
file processing, an external device) and that therefore has **no microservice / no gRPC method**.
Generate **only a `.tsp` file** under `src/tsp/bffWeb/**`; do **not** create anything under
`src/openapi/paths/grpc/`, `src/openapi/components/grpc/`, and do **not** touch `msGrpc.yml`.

> **BFF contracts are TypeSpec.** `src/openapi/bffWeb.yml` is generated from `src/tsp/bffWeb/**/*.tsp`
> (`node scripts/generate-bff-openapi.mjs` / Gradle `compileBffTsp`) — never hand-edit it.

This shape also typically **uploads a file** (`@multipartBody` + `HttpPart<bytes>`) and may be
**asynchronous**: a `post...` operation starts the job and returns a job id, and a separate
`get...{jobId}`-style operation (path parameter, polled or streamed by the frontend) returns
progress/results — patterns the standard CRUD flow does not use. This is the real pattern used by
the existing OCR feature (`src/tsp/bffWeb/W_Web/002_option/010_common/002_ocr.tsp`) — follow it,
not a generic REST `202 Accepted` convention.

> If the feature has a gRPC counterpart (it calls a microservice), it is **not** BFF-only — use the
> `scaffold-contract` skill instead.

## Inputs to collect first

Mark unknowns as "needs confirmation / 要確認":

| Item | Notes |
|---|---|
| **★ Suzuyo ticket number** | always confirm first (cannot be derived) |
| 大分類 / 中分類 / 小分類 | classification (see tables below) — e.g. Web / Option / Common |
| 機能名 (English, PascalCase) | the feature name |
| 機能ID (sequence) | e.g. `003` |
| API list (endpoint, method name, description) | one operation per API, all in the same `.tsp` file |
| **Input shape** | JSON body, or **file upload** (`@multipartBody`)? |
| **Response shape** | plain JSON, or **async start (job id) + poll/stream** (see `002_ocr.tsp`)? |

## Classification (compact)

**大分類** `w`=Web (`W_Web`, url `web`, tag `Web /`) · `m`=Mobile · `r`=Report · `e`=EDI · `c`=Common · `b`=Batch · `a`=API.
**中分類** `001`=Core (`001_core`) · `002`=Option (`002_option`) · `100~999`=Local (`[code]_local`).
**小分類** `000_fw`/`Fw` · `010_common`/`Common` · `020_master`/`Master` · `030_rcv`/`Rcv` · `040_so`/`So` ·
`050_order`/`Order` · `060_inv`/`Inv` · `070_billcalc`/`Billcalc` · `080_carrycalc`/`Carrycalc` ·
`090_stks`/`Stks` · `100_tms`/`Tms` · `110_hozei`/`Hozei` · `120_abl`/`Abl` · `130_bi`/`Bi` ·
`140_log`/`Log` · `150_inout`/`Inout` · `160_dailyinv`/`Dailyinv` · `170_analyze`/`Analyze`.

## File map (BFF-only —機能ID=`[ID]`, 機能名=`[Feature]`)

```
src/tsp/bffWeb/
├── main.tsp                                             ← add one import line
└── [大分類Dir]/[中分類Dir]/[小分類Dir]/
    └── [ID]_[featureCamel].tsp                          ← all models + operations for this feature
```

> **No `src/openapi/paths/grpc/…`, no `components/grpc/…`, no `msGrpc.yml` change, no manual edits
> to `src/openapi/bffWeb.yml`.** Those exist only for microservice-backed features / are generated.

## Naming

Real example (`002_ocr.tsp`, `003_barcode.tsp`):

```tsp
@tag("Option / Common / Ocr")
@route("/v1/web/option/common/ocr/postInvoice")
@post
@operationId("webOptionCommonOcrPostInvoice")
@summary("002_OCR Invoice_Start OCR job")
@doc("Uploads an invoice document")
op webOptionCommonOcrPostInvoice(
    @multipartBody body: {
      @doc("Invoice document file (PDF or image).")
      file: HttpPart<bytes>,
      @doc("The code of the AI model to use.")
      modelCode?: HttpPart<string>,
    }
):
  | OptionCommonOcrPostInvoiceSuccessResponse
  | Resp400
  | Resp401
  | Resp403;
```

| Item | Rule | Example |
|---|---|---|
| `@tag(...)` | `"[中分類Pascal] / [小分類Pascal] / [機能名Pascal]"` (no `Web /` prefix — matches real examples) | `"Option / Common / Ocr"` |
| `@route(...)` | `"/v1/[大分類lc]/[中分類lc]/[小分類lc]/[機能名lc]/[api名lc]"`; path params use `{paramName}` | `"/v1/web/option/common/ocr/getInvoice/{ocrJobId}"` |
| `@post` | POST only | - |
| `@operationId(...)` | `"[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]"` | `"webOptionCommonOcrPostInvoice"` |
| `@summary(...)` | `"[ID]_[機能名]_[API日本語名]"` | `"002_OCR Invoice_Start OCR job"` |
| model names | `[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Request` / `...SuccessResponse` (大分類は含めない) | `OptionCommonOcrPostInvoiceSuccessResponse` |

Errors: reference the shared `Resp400`/`Resp401`/`Resp403`/`Resp404`/`Resp500` models from
`src/tsp/lib/errors.tsp` — do not redefine them.

---

## Templates

### 1. Feature file — plain JSON body

`src/tsp/bffWeb/[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[featureCamel].tsp`

```tsp
import "@typespec/http";
import "@typespec/openapi";
import "../../../../lib/common.tsp";

using Http;
using OpenAPI;

namespace ScmBff;

@doc("[API日本語名]リクエスト")
model [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Request {
  @doc("[項目説明]")
  [フィールド名]: string;
}

@doc("[API日本語名]レスポンス")
model [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]SuccessResponse {
  data: [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Response;
}

@doc("[データ説明]")
model [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Response {
  [フィールド名]?: string;
}

@tag("[中分類Pascal] / [小分類Pascal] / [機能名Pascal]")
@route("/v1/web/[中分類lc]/[小分類lc]/[機能名lc]/[api名lc]")
@post
@operationId("web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]")
@summary("[ID]_[機能名]_[API日本語名]")
@doc("[API日本語説明]")
op web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal](@body body: [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Request):
  | [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]SuccessResponse
  | Resp400
  | Resp401
  | Resp403;
```

### 2. File upload operation (`@multipartBody`)

```tsp
@tag("[中分類Pascal] / [小分類Pascal] / [機能名Pascal]")
@route("/v1/web/[中分類lc]/[小分類lc]/[機能名lc]/[api名lc]")
@post
@operationId("web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]")
@summary("[ID]_[機能名]_[API日本語名]")
@doc("[アップロード内容の説明]")
op web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal](
    @multipartBody body: {
      @doc("[ファイルの説明]")
      file: HttpPart<bytes>,
      @doc("[任意パラメータの説明]")
      [optionalParam]?: HttpPart<string>,
    }
):
  | [中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]SuccessResponse
  | Resp400
  | Resp401
  | Resp403
  | Resp500;
```

### 3. Async job pattern — start + poll/stream (実例: `002_ocr.tsp`)

Start operation returns a job id (still `200`, wrapped in `data:`):

```tsp
@doc("Job acceptance response wrapper.")
model [Feature][StartApi]SuccessResponse {
  data: [Feature][StartApi]Response;
}

@doc("Job creation response payload.")
model [Feature][StartApi]Response {
  @doc("Unique identifier for the asynchronous job.")
  @extension("example", "job-12345")
  jobId: string;
}
```

Poll/stream operation takes the job id as a `@path` parameter:

```tsp
@doc("Job progress / result response.")
model [Feature][PollApi]Response {
  event: [Feature]StreamEvent;

  @doc("Unique identifier of the job.")
  jobId: string;

  @doc("Event specific payload.")
  data?: {};

  @doc("Timestamp when the event was emitted.")
  timestamp: utcDateTime;
}

@tag("[中分類Pascal] / [小分類Pascal] / [機能名Pascal]")
@route("/v1/web/[中分類lc]/[小分類lc]/[機能名lc]/[pollApiLc]/{jobId}")
@post
@operationId("web[中分類Pascal][小分類Pascal][機能名Pascal][PollApiPascal]")
@summary("[ID]_[機能名]_[API日本語名]")
@doc("[ジョブ進捗取得の説明]")
op web[中分類Pascal][小分類Pascal][機能名Pascal][PollApiPascal](
    @doc("The unique identifier of the job.")
    @path jobId: string
):
  | [Feature][PollApi]Response
  | Resp400
  | Resp401
  | Resp403;
```

Define the fixed `event` values as a TypeSpec `enum` (e.g. `[Feature]StreamEvent`) in the same file
or in a shared `_sharedEnums.tsp`.

---

## Generation / verification steps

`src/openapi/bffWeb.yml` **is never hand-edited** — after creating/editing the `.tsp` file:

```bash
cd src/tsp && npx tsp compile bffWeb/main.tsp --no-emit   # syntax check
node scripts/generate-bff-openapi.mjs                      # regenerate src/openapi/bffWeb.yml
```

## Checklist

1. [ ] Create the feature `.tsp` file (models + all operations for the feature, one file).
2. [ ] Add one `import "./..."` line to `src/tsp/bffWeb/main.tsp`.
3. [ ] For file-upload operations, use `@multipartBody` + `HttpPart<bytes>` (template 2).
4. [ ] For async features, add the start (job id) + poll/stream operations (template 3).
5. [ ] `npx tsp compile bffWeb/main.tsp --no-emit` — fix any errors.
6. [ ] `node scripts/generate-bff-openapi.mjs` — confirm `src/openapi/bffWeb.yml` picks up the new paths.
7. [ ] **Do NOT** create anything under `src/openapi/paths/grpc/`, `components/grpc/`, or touch `msGrpc.yml`.
8. [ ] Only define fields present in the design document — do not invent fields.

## Notes

- **No overwrite without confirmation** if a `.tsp` file for the same feature already exists.
- **Only define fields present in the design document** — do not invent fields.
- This skill targets BFF-only features; the moment a gRPC method is involved, switch to the
  `scaffold-contract` skill.

