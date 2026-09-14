# React Frontend Conventions

Use these guidelines when implementing or reviewing React components, hooks, and React-based frameworks such as Next.js.

## Rendering and state

- Keep render pure: no side effects, subscriptions, or mutations during render.
- Derive values from props and state instead of mirroring them into extra state that can drift out of sync.
- Keep state as local as possible and lift it only when multiple consumers need it.
- Use stable, unique `key` values for lists; never use array index as key when items can be reordered, inserted, or removed.
- Do not mutate state objects or arrays in place.

## Effects and lifecycle

- Use effects only to synchronize with external systems; do not use them to compute derived data or respond to user events that handlers can process directly.
- Declare complete dependency arrays; do not suppress `react-hooks/exhaustive-deps` to hide stale closures.
- Clean up subscriptions, timers, listeners, observers, and in-flight requests on unmount and on dependency change.
- Guard async effects against races so a slower, older response cannot overwrite a newer one.
- Follow the rules of hooks: no conditional hook calls.

## Server rendering and frameworks

- Keep server-only code, secrets, and environment variables out of client components; only expose explicitly public configuration.
- Avoid hydration mismatches caused by reading `window`, time, randomness, or locale during the initial render.
- Respect the framework's data-fetching, caching, and revalidation model instead of layering ad-hoc fetching on top.

## Review checks

Pay special attention to stale closures, missing effect cleanup, race conditions in async effects, unstable or index-based keys, state mirroring props, in-place mutation, conditional hooks, hydration mismatches, and server-only data leaking into client bundles.
