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

Load the relevant reference guidance only when it applies to the change being worked on:

- TypeScript types, contracts, and module boundaries: `references/typescript.md`
- React components, hooks, or React-based frameworks such as Next.js: `references/react.md`
- API integration, server-state caching, global state, or form submission: `references/data-fetching.md`
- Interactive UI, forms, dialogs, navigation, or dynamic content: `references/accessibility.md`
- Rendering cost, bundle size, network usage, or load time: `references/performance.md`

Multiple references may apply to the same change. For example, a React form that submits to an API may require `react.md`, `data-fetching.md`, and `accessibility.md`.

Do not load unrelated references just because they exist. Use progressive disclosure: start with this skill, then consult only the reference files needed to understand the current task or validate a finding.

For authentication, tokens, untrusted content rendering, redirects, or other security-sensitive browser behavior, also apply the `frontend-security` skill.

Do not perform unrelated redesigns or subjective styling changes unless requested.
