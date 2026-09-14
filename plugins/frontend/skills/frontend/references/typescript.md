# TypeScript Frontend Conventions

Use these guidelines when implementing or reviewing TypeScript frontend code.

## Types and contracts

- Treat API response types, shared DTOs, route params, and component props as contracts; keep them aligned with the backend or generated client instead of hand-copying shapes.
- Validate untrusted runtime data (API responses, `localStorage`, URL params, `postMessage` payloads) at the boundary; a TypeScript type is not a runtime guarantee.
- Prefer discriminated unions for loading/success/error and other multi-state values over loosely related booleans and optional fields.
- Model optionality honestly. Do not use non-null assertions (`!`) or `as` casts to silence errors that reflect real `null`/`undefined` paths.

## Safety

- Avoid `any` at module boundaries; prefer `unknown` plus narrowing when the shape is genuinely unknown.
- Keep `strict` compiler guarantees intact; do not weaken `tsconfig` or add blanket `@ts-ignore` to make a change compile.
- Be careful with numeric and date handling across serialization: IDs that exceed safe integer range, timezone-naive date strings, and locale-dependent parsing.
- Handle exhaustiveness explicitly for unions and enums so newly added variants fail at compile time rather than falling through silently.

## Modules

- Keep side effects out of module top level where they run on import, especially in code shared with SSR or tests.
- Do not import server-only modules, secrets, or large Node dependencies into client bundles.

## Review checks

Pay special attention to unsafe casts, non-null assertions hiding real nulls, unvalidated external data typed as trusted, `any` leaking across boundaries, non-exhaustive union handling, contract drift from the backend, and date/number serialization mistakes.
