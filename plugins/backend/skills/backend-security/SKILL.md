---
name: backend-security
description: Apply SST backend security guidance when implementing or reviewing authentication, authorization, secrets, input handling, data access, service-to-service communication, and security-sensitive backend behavior.
---

# Backend Security

Use this skill when backend work touches authentication, authorization, identity, permissions, untrusted input, sensitive data, secrets, cryptography, network boundaries, service-to-service calls, or other security-sensitive behavior.

Prioritize prevention of authorization bypasses, data exposure, confused-deputy behavior, unsafe defaults, and insecure error handling.

Focus on:

- Enforce authentication and authorization at trusted server-side boundaries; never rely on client-side checks for access control.
- Validate audience, issuer, signature, expiry, not-before, scopes, roles, tenant/workspace context, and subject claims when processing tokens.
- Apply least privilege to users, service accounts, credentials, database permissions, cloud IAM, and downstream service access.
- Prevent IDOR/BOLA-style access issues by checking object ownership or policy against the authenticated principal and tenant context for every protected resource.
- Treat all external input as untrusted. Validate structure, length, ranges, allowed values, identifiers, filenames, URLs, and content types before use.
- Use parameterized queries and safe framework APIs. Never build SQL, shell commands, templates, paths, or expressions by concatenating untrusted input.
- Protect against SSRF by constraining outbound destinations and validating URLs before server-side fetches.
- Keep secrets out of source code, logs, exceptions, URLs, telemetry, test fixtures, and API responses. Load them from approved secret/configuration mechanisms.
- Avoid logging credentials, tokens, session identifiers, private keys, raw authorization headers, or unnecessarily sensitive payloads.
- Use established cryptographic libraries and protocols. Do not invent encryption, signing, password hashing, or token schemes.
- Fail closed for authorization and security checks. Do not silently fall back to broader access when identity or policy information is missing or invalid.
- Return useful but non-sensitive errors. Do not expose stack traces, internal topology, SQL, credentials, filesystem paths, or security configuration to callers.
- Protect state-changing operations against replay and duplicate execution when relevant through idempotency, nonce, timestamp, or transaction controls.
- Review upload and download flows for path traversal, unsafe filenames, size limits, decompression bombs, content-type confusion, and unintended public exposure.
- Preserve tenant isolation across database queries, caches, queues, object storage, vector stores, logs, and downstream calls.
- Verify service-to-service calls authenticate the intended workload and authorize the requested action; do not trust network location alone.
- Prefer secure defaults for CORS, cookies, TLS, redirects, headers, debug modes, and administrative endpoints.
- Add or update tests for both allowed and denied paths, including cross-tenant access, missing scopes/roles, malformed tokens, and boundary inputs.

When reviewing a security-sensitive change, trace the complete trust boundary from entry point to protected resource. Verify where identity is established, where policy is enforced, what context is propagated downstream, and whether any alternate path bypasses those controls.

Do not recommend weakening authentication, authorization, validation, tenant isolation, secret handling, or auditability merely to simplify implementation.
