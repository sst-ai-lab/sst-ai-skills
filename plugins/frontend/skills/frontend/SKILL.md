---
name: frontend
description: Apply SST frontend engineering conventions when implementing, refactoring, debugging, or explaining browser and client UI code, components, state management, routing, forms, rendering, and frontend API integration.
---

# Frontend

Use this skill for frontend development work.

Prefer predictable state flow, accessible interactions, explicit loading/error behavior, and patterns already established in the codebase.

Focus on:

- Correct rendering and state transitions.
- Async request lifecycle, cancellation, loading, and error states.
- Stable API integration and serialization assumptions.
- Form validation and submission behavior.
- Routing, navigation, and state persistence.
- Accessibility for keyboard, screen-reader, and form usage.
- Safe handling of external data, HTML, tokens, and client-visible state.
- Avoiding unnecessary rerenders, repeated requests, and other concrete performance regressions.
- Clear component boundaries and maintainable data flow.

When modifying an existing codebase, inspect nearby implementations and project-level `CLAUDE.md` instructions before introducing new patterns.

Do not perform unrelated redesigns or subjective styling changes unless requested.
