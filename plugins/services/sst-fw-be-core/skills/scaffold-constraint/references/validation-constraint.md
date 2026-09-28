# Validation constraint authoring rules

Applies to: `**/validation/**/*.java`

`sst-fw-be-core` ships custom Bean Validation constraints used platform-wide. A constraint is a **pair**: the annotation in `com.fw.core.validation.constraint` + its validator in `com.fw.core.validation.validator` (suffix `Validator`).

Full template + conventions are in the repository `CLAUDE.md` — "Custom Validation Annotations / Extending Standard Constraints / Validator Implementation Pattern / Class-Level Validation" sections. Key reminders when editing files under this path:

- `message()` **must reference an `ErrorCodeEnum` key** (e.g. `"EB-001-XXX-XXX-XXX"`), never literal text. Add the key to **both** `messages.properties` and `messages-ja-jp.properties` (parameterized form, e.g. `... {1}`).
- Validator returns **true for null / blank** inputs (combine with `@NotNull`/`@NotBlank` when presence is required); use `StringUtils.hasText(...)`.
- **Extending a standard constraint:** same simple name as the JDK/Spring one + meta-annotate with the original; `@Constraint(validatedBy = {})`.
- **Class-level (multi-field) constraints** target the type and name the compared fields.
- Javadoc bilingual summary (English + `<p>バリデーション > …`), `@since`, `@author SCM Development Team`.

