---
name: security-review
description: Review changes for authentication, authorization, trust-boundary, injection, secret-handling, sensitive-data, deserialization, and security-configuration vulnerabilities.
---

# Security Review

Apply this skill when the reviewed change touches authentication, authorization, external input, secrets, cryptography, sensitive data, network boundaries, file/process execution, serialization, or security configuration.

Focus on concrete vulnerabilities introduced by the change:

- Missing or incorrect authentication and authorization checks.
- Privilege escalation and tenant/user isolation failures.
- Injection risks in SQL, shell commands, templates, expressions, URLs, or other interpreters.
- Unsafe deserialization or execution of untrusted input.
- Path traversal, SSRF, insecure redirects, and unsafe external resource access.
- Sensitive-data or secret exposure in logs, responses, source, configuration, or client-visible state.
- Incorrect cryptographic assumptions or weakened transport/security settings.
- Trust-boundary mistakes where client-controlled or external data is treated as trusted.
- Security regressions caused by dependency or configuration changes.

Report only actionable findings tied to the reviewed change. Do not report generic security hardening suggestions without a concrete failure path.
