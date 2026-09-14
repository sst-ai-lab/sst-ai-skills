# Data Fetching and State Conventions

Use these guidelines when implementing or reviewing API integration, server-state caching, global client state, and form submission flows.

## Request lifecycle

- Represent loading, empty, success, and error states explicitly and render each of them.
- Cancel or ignore superseded requests (search-as-you-type, fast navigation, changing filters) so stale responses cannot win.
- Surface actionable errors to the user; do not swallow failures or silently render empty data on error.
- Handle authentication expiry consistently (refresh or redirect) rather than per call site.

## Caching and server state

- Use the existing server-state library (for example TanStack Query, SWR, RTK Query, or framework loaders) when the codebase has one; do not duplicate server data into a separate global store.
- Build cache keys from every parameter that affects the response, including tenant, user, locale, and filters.
- Invalidate or update affected cache entries after mutations; verify optimistic updates roll back correctly on failure.
- Clear user-specific cached data on logout and account or tenant switch.

## Mutations and forms

- Prevent duplicate submission while a mutation is pending and keep the operation safe to retry.
- Keep client-side validation aligned with server validation, and still display server-side validation errors.
- Preserve user input on recoverable failures.

## Pagination and lists

- Keep pagination, sorting, and filter state consistent with the URL when the view is shareable or navigable.
- Avoid unbounded fetching of lists that grow with production data.

## Review checks

Pay special attention to race conditions from uncancelled requests, missing error or empty states, incomplete cache keys, missing invalidation after mutations, broken optimistic rollback, duplicate submissions, cross-user data surviving logout, and request waterfalls or repeated fetching.
