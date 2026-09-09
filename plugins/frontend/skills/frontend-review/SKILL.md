---
name: frontend-review
description: Review frontend changes for correctness, state and data-flow bugs, API integration, accessibility, rendering behavior, performance regressions, and security-sensitive client issues.
---

# Frontend Review

Apply this skill when reviewing browser or client UI code, components, state management, routing, forms, rendering, or frontend API integration.

Focus on high-signal issues introduced by the reviewed change:

- Incorrect rendering, stale state, broken state transitions, and lifecycle issues.
- Async race conditions, loading/error-state handling, and request cancellation.
- API contract mismatches, serialization assumptions, and unsafe fallback behavior.
- Form validation and submission bugs.
- Routing/navigation regressions and state loss.
- Accessibility regressions that materially block keyboard, screen-reader, or form usage.
- Unsafe HTML, token exposure, trust in unvalidated external data, and other concrete client-side security risks.
- Significant performance regressions such as unbounded rerenders or repeated network requests.

Do not report subjective styling preferences, generic component-organization suggestions, linter findings, or unrelated pre-existing issues. Validate findings against surrounding code when needed.
