# Accessibility Frontend Conventions

Use these guidelines when implementing or reviewing interactive UI, forms, navigation, dialogs, and dynamic content.

## Semantics

- Prefer native elements (`button`, `a`, `input`, `select`, `dialog`) over `div`/`span` with click handlers.
- Use links for navigation and buttons for actions.
- Keep heading levels and landmarks meaningful so the page structure is navigable.
- Use ARIA only to fill gaps native semantics cannot cover; incorrect ARIA is worse than none.

## Keyboard and focus

- Every interactive element must be reachable and operable by keyboard with a visible focus indicator.
- Trap focus inside modal dialogs, restore focus to the trigger on close, and support `Escape` to dismiss.
- Move or announce focus deliberately after route changes and after content is inserted or removed.
- Do not use positive `tabindex` values.

## Forms

- Associate every input with a visible label; placeholders are not labels.
- Link validation errors to their fields (for example with `aria-describedby`) and announce them.
- Do not rely on color alone to convey state, errors, or required fields.

## Dynamic content and media

- Announce asynchronous status changes (toasts, loading completion, errors) through live regions when they are not otherwise visible to assistive technology.
- Provide text alternatives for meaningful images and icon-only buttons; mark decorative images as decorative.
- Respect `prefers-reduced-motion` for non-essential animation.

## Review checks

Pay special attention to clickable non-interactive elements, missing labels or accessible names, keyboard traps or unreachable controls, lost focus after dialogs and navigation, unannounced errors, color-only state, and invalid ARIA usage.
