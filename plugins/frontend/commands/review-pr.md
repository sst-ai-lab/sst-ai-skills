---
description: Review frontend changes introduced by the current branch or CI pull request.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git merge-base:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git fetch:*)
---

Review the frontend change set represented by the current branch or CI pull request.

Arguments: `$ARGUMENTS`

Supported arguments:
- `--base <ref>`: base branch/ref.
- `--head <ref>`: head ref, default `HEAD`.
- `--format markdown|json`: output format, default `markdown`.

Resolve base in this order: explicit `--base`, `CODEBUILD_WEBHOOK_BASE_REF` with `refs/heads/` removed, then `develop`. Prefer `origin/<base>` when available. If missing and `origin` exists, fetch only that base branch. Never silently fall back to another branch.

Use merge-base semantics and inspect changed files, unified diff, commits, and surrounding repository context needed to validate findings. Read applicable `CLAUDE.md` files. Always apply the `frontend-review` skill from this plugin; use the `frontend` skill for surrounding implementation context when useful. Report only issues introduced by the reviewed changes; ignore unrelated pre-existing issues, style nitpicks, and speculative concerns.

Prioritize rendering correctness, state/data flow, async lifecycle, API integration, forms, navigation, accessibility, concrete performance regressions, and client-side security risks.

Each finding must contain severity (`critical|high|medium|low`), path, changed line/hunk when identifiable, concise title, concrete issue, evidence, and recommendation. Never invent a line number.

For markdown, output `## Review summary` and `## Findings`; if none, output `## Findings\nNo issues found.`

For JSON, output only valid JSON:

```json
{"summary":"...","base":"...","head":"...","findings":[{"severity":"high","path":"src/...","line":42,"title":"...","issue":"...","evidence":"...","recommendation":"..."}]}
```

Use `null` for `line` when needed. Do not modify files, commit, push, or post GitHub comments. CI publishing is a separate adapter.
