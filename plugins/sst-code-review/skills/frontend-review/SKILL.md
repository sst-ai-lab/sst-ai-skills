---
name: frontend-review
description: Review frontend changes for correctness, state and data-flow bugs, API integration, accessibility, rendering behavior, and maintainability.
---

# Frontend Review

Apply this skill when the reviewed change affects browser or client UI code, components, state management, routing, forms, rendering, or frontend API integration.

Focus on high-signal issues introduced by the change:

- Incorrect rendering, stale state, broken state transitions, and lifecycle issues.
- Async race conditions, loading/error-state handling, and request cancellation.
- API contract mismatches, serialization assumptions, and unsafe fallback behavior.
- Form validation and submission bugs.
- Routing/navigation regressions and state loss.
- Accessibility regressions that materially block keyboard, screen-reader, or form usage.
- Security-sensitive client behavior such as unsafe HTML, token exposure, or trust in unvalidated external data.
- Performance regressions only when they are concrete and significant, such as accidental unbounded rerenders or repeated network requests.

Do not report subjective styling preferences, generic component-organization suggestions, or unrelated pre-existing issues. Validate findings against surrounding code when needed.
