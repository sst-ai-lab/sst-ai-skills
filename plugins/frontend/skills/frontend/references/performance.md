# Performance Frontend Conventions

Use these guidelines when implementing or reviewing code that affects rendering cost, bundle size, network usage, or perceived load time.

## Rendering

- Avoid creating new object, array, or function identities on every render when they feed memoized children, context values, or effect dependencies.
- Keep frequently changing values out of wide-reaching context providers.
- Virtualize long lists and large tables instead of rendering every row.
- Memoize only where profiling or clear cost justifies it; unnecessary memoization adds complexity without benefit.

## Network

- Avoid request waterfalls that could run in parallel, and avoid refetching data already available in cache.
- Debounce or throttle high-frequency triggers such as typing, scrolling, and resizing.
- Do not poll without a bound, backoff, or visibility check.

## Bundle and assets

- Code-split large routes and heavy, rarely used dependencies.
- Prefer targeted imports over importing entire libraries for a single helper.
- Size, compress, and lazy-load images; set explicit dimensions to avoid layout shift.

## Review checks

Pay special attention to render loops, effects that trigger themselves, context values recreated on every render, unvirtualized large lists, duplicate or waterfall requests, unbounded polling, heavy dependencies added to the main bundle, and layout shift from unsized media.
