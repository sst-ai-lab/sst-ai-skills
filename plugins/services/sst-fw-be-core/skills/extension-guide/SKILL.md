---
name: extension-guide
description: Extension utility rules for `com.scm.core.extension.*` — reusable helpers that enrich JDK types (`string`, `number`, `date`, `time`, …) without service-specific logic. Use when creating or editing extension utility classes under `**/extension/**` (`**/extension/**/*.java`, e.g. `StringExtension`, `LocalDateExtension`, `extension/example/*`) in sst-fw-be-core.
---

# Extension utility rules

## When to use

- Creating or editing files under `**/extension/**/*.java` — `com.scm.core.extension.*` groups reusable helpers that enrich JDK types (`string`, `number`, `date`, `time`, …) without service-specific logic.

| File | When to read |
|---|---|
| `references/extension-rules.md` | Key reminders when editing files under this path |

Full conventions are in the repository `CLAUDE.md` — "Extension Utilities" section.
