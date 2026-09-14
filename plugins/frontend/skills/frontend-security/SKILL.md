---
name: frontend-security
description: Apply SST frontend security guidance when implementing or reviewing authentication flows, token and session handling, rendering of untrusted content, redirects, third-party scripts, client-side storage, and other security-sensitive browser behavior.
---

# Frontend Security

Use this skill when frontend work touches login, logout, tokens, sessions, permissions-driven UI, untrusted or user-generated content, URLs and redirects, file uploads, third-party scripts or embeds, cross-window messaging, or client-side storage of sensitive data.

Prioritize prevention of XSS, token theft, open redirects, sensitive data exposure, and false assumptions that the client enforces security.

Focus on:

- Treat the browser as untrusted. Client-side route guards and hidden UI are usability features, not access control; the backend must enforce authorization.
- Render untrusted content as text by default. Avoid `dangerouslySetInnerHTML`, `v-html`, `innerHTML`, `insertAdjacentHTML`, and `document.write`; when HTML rendering is required, sanitize with an established sanitizer and a restrictive allowlist.
- Never build executable code from untrusted input: no `eval`, `new Function`, string-based `setTimeout`/`setInterval`, or dynamic script injection.
- Validate URLs before using them in `href`, `src`, `window.location`, or redirects. Block `javascript:` and `data:` schemes and restrict post-login and return-URL redirects to same-origin or an explicit allowlist.
- Prefer `HttpOnly`, `Secure`, `SameSite` cookies for session tokens. Do not store long-lived access or refresh tokens in `localStorage` or `sessionStorage` unless the architecture explicitly accepts that risk.
- Keep tokens, session identifiers, and personal data out of URLs, query strings, logs, analytics events, error-tracking payloads, and client-side persisted state.
- Clear tokens, cached user data, and in-memory state on logout, session expiry, and account or tenant switch.
- Protect state-changing requests against CSRF when cookie-based authentication is used, following the backend's chosen mechanism.
- Never embed secrets, private API keys, or internal endpoints in client bundles or public environment variables; anything shipped to the browser is public.
- Validate `event.origin` and message shape for `postMessage` listeners, and specify an explicit target origin when sending.
- Use `rel="noopener noreferrer"` for links opened with `target="_blank"` to untrusted destinations.
- Load third-party scripts only from approved sources, pin versions, and use Subresource Integrity where supported; do not weaken Content Security Policy to make a change work.
- Validate file type and size before upload for user feedback, while relying on the server for enforcement; never render uploaded content as HTML from the application origin.
- Do not expose stack traces, internal identifiers, or backend error details to end users.
- Add or update tests for security-relevant UI paths such as unauthorized access redirects, logout cleanup, and sanitization of user-generated content.

When reviewing a security-sensitive change, trace untrusted data from its source (API response, URL, storage, message, user input) to every sink where it is rendered, navigated to, executed, or persisted, and verify the backend enforces any access decision the UI reflects.

Do not recommend weakening sanitization, Content Security Policy, cookie flags, redirect validation, or token handling merely to simplify implementation.
