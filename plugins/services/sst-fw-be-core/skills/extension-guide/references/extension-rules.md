# Extension utility rules

Applies to: `**/extension/**/*.java`

`com.scm.core.extension.*` groups reusable helpers that enrich JDK types (`string`, `number`, `date`, `time`, …) without service-specific logic. Each type family is one utility class (e.g. `StringExtension`, `LocalDateExtension`).

Full conventions are in the repository `CLAUDE.md` — "Extension Utilities" section. Key reminders when editing files under this path:

- **Non-instantiable**: `final` class + private constructor; **static methods only**, no state.
- **Null-safe by default**: handle `null` gracefully (return `0` / `false` / empty rather than throwing — e.g. `within` returns `false` if any operand is `null`).
- **Temporal helpers**: handle cross-midnight by computing shortest distance (see `withinSeconds`).
- Mirror each helper with `@ExtensionMethod` usage in `extension/example/*` for both call styles.

Keep helpers generic — service-specific logic belongs in the consuming service.
