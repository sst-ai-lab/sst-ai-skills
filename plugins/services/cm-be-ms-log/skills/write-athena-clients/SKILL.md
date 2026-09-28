---
name: write-athena-clients
description: Athena client rules for cm-be-ms-log — classes in infrastructure/athena/core/<domain> that query AWS Athena (log data stored in S3) with the AWS SDK v2 synchronous client. Use when creating or editing `**/infrastructure/athena/**/*.java` (AthenaClient bean injection, app.athena.* config, start/poll/fetch query lifecycle, string-built SQL and identifier safety, Athena/Presto/Trino dialect) in the cm-be-ms-log repository.
---

# Athena client rules — cm-be-ms-log

## When to use

- Classes in `infrastructure/athena/core/<domain>` query **AWS Athena** (which reads log data stored in S3) using the **AWS SDK v2** synchronous client. This is the service's second data store, separate from PostgreSQL/MyBatis.

## How to use

| Pattern | File | Description |
|---|---|---|
| Athena client rules | `references/athena-client.md` | Client & configuration, query lifecycle (start, poll, fetch), SQL & identifier safety, boundary |

## Related

- Scaffolding a search feature that uses Athena: `../scaffold-log-feature/SKILL.md`.
