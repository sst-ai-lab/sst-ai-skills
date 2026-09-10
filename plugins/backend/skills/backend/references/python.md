# Python Backend Conventions

Use these guidelines when implementing or reviewing Python backend code.

## Types and contracts

- Preserve API and data-model contracts across FastAPI, Pydantic, generated clients, serialization, and persistence boundaries.
- Prefer explicit typing for public functions, service boundaries, and shared models.
- Distinguish expected domain failures from programmer errors; do not hide unexpected exceptions behind generic fallbacks.
- Validate external input at trust boundaries instead of scattering defensive checks deep in business logic.

## Async and lifecycle

- Do not call blocking I/O from async request paths unless it is intentionally offloaded.
- Propagate cancellation and timeouts through async layers where supported.
- Ensure async generators, clients, sessions, files, and other resources are closed on success and failure paths.
- Avoid shared mutable module/global state unless synchronization and lifecycle are explicit.

## FastAPI and Pydantic

- Keep transport DTOs separate from domain behavior when the surrounding architecture does so.
- Preserve status-code and exception-handler contracts.
- Be careful when changing Pydantic defaults, aliases, optionality, validators, or serialization behavior because these are API-contract changes.
- Prefer dependency injection over hidden global access for request-scoped dependencies.

## Review checks

Pay special attention to unguarded `None` access, mutable default/state mistakes, exception swallowing, sync work in async handlers, leaked clients/sessions, cancellation bugs, Pydantic compatibility changes, unsafe deserialization, and accidental behavior changes caused by fallback defaults.
