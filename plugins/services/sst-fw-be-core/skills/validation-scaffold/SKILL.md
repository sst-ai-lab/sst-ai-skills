---
name: validation-scaffold
description: Scaffolds a custom Bean Validation constraint in scm-be-core — the annotation + its validator + an example DTO + the error-code message keys. No tests. Also holds the validation constraint authoring rules. Use when adding a custom Bean Validation constraint (annotation + validator, extend-standard or class-level multi-field) in sst-fw-be-core, or when creating/editing Java files under `**/validation/**` (annotation/validator pattern, error-code `message`, null/blank handling).
---

# Validation skill — scm-be-core

## When to use

- Adding a new custom Bean Validation **constraint** (annotation + validator) to the core library, or a class-level multi-field constraint.
- Editing files under `**/validation/**/*.java` (read `references/validation-constraint.md`).

## Scope

- **Generates:** the annotation (`validation/constraint/<Name>.java`), its validator (`validation/validator/<Name>Validator.java`), an example DTO under `validation/example/`, and the `message()` error-code keys in `messages.properties` / `messages-ja-jp.properties`.
- **Does NOT generate:** tests; business-/service-specific rules (those belong in the consuming service, not `scm-be-core`).

## How to use

| Pattern | File | Description |
|---|---|---|
| Initial creation | `references/init.md` | Code templates to add a constraint (annotation + validator + example + messages), incl. the extend-standard and class-level variants |
| Authoring rules | `references/validation-constraint.md` | Annotation/validator pattern, error-code `message`, null/blank handling (`**/validation/**/*.java`) |

## Related

- Authoring rules: `references/validation-constraint.md` (annotation/validator pattern, error-code `message`, null/blank handling) and `../extension-guide/references/extension-rules.md` (for extension utilities).
- Repo conventions: the repository `CLAUDE.md` (the existing base — do not modify; it also documents the validation framework).
