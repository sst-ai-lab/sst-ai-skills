# API layer rules

Applies to: `**/src/api/**/*.ts`

`src/api/<中分類>/<小分類>/<feature>Api/` wraps the **generated** `@sst-cm/fe-web-client` so screens never touch the raw client. Two files per feature:

- `<feature>Api.ts` — exports a `<Feature>Api` object with one method per backend operation.
- `<feature>ApiType.ts` — the request/response types (alias/re-export the generated `@sst-cm/fe-web-client` model types; don't redefine shapes by hand).

## Wrapper pattern

```ts
import { apiCall, apiCallWithLoading } from '@/composables/sstApiRequest';
import { soMainteApiClient } from '@/libs/client';

export const SoMainteApi = {
  getSo: (payload: SoMainteGetRequest): Promise<SoMainteGetResponse> =>
    apiCall(() => soMainteApiClient.webCoreSoSoMainteGetSo({ webCoreSoSoMainteGetSoRequest: payload })),
  saveSo: (payload: SoMainteSaveRequest): Promise<SoMainteSaveResponse> =>
    apiCallWithLoading(() => soMainteApiClient.webCoreSoSoMainteSaveSo({ webCoreSoSoMainteSaveSoRequest: payload })),
};
```

- Wrap every call in **`apiCall(...)`** (reads) or **`apiCallWithLoading(...)`** (writes / long ops — shows the global loading) from `@/composables/sstApiRequest`. These centralize error handling/loading — don't add ad-hoc try/catch or loading flags here.
- The generated client method name is the OpenAPI **`operationId`** (e.g. `webCoreSoSoMainteGetSo`). Call it with whatever shape its TypeScript signature requires — with `useSingleRequestParameter`, body operations wrap the body under a named property (the request-body schema name, camelCased; e.g. `{ webCoreSoSoMainteGetSoRequest: payload }`), while query/header-only operations take a parameters object directly. Let the typed signature drive the call shape rather than guessing the key.
- **Get the client instance from `@/libs/client.ts`** — it instantiates one `new Client.Web.<Api>(configuration)` per API (and `Client.WebSSE.<Api>(sseConfiguration)` for streaming/SSE endpoints). Add a new client there; never `new` a client or write `fetch`/`axios` calls inline.

## Keep it UI-free

API modules return typed responses and contain no UI, i18n, or component logic. If a backend operation doesn't exist in `@sst-cm/fe-web-client`, it must first be added to the OpenAPI spec in `cm-be-spec` and regenerated — do not hand-write the HTTP call.
