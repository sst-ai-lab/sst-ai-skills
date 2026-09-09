---
description: Review the changes introduced by the current branch or CI pull request using SST review skills.
allowed-tools: Bash(git status:*), Bash(git branch:*), Bash(git rev-parse:*), Bash(git merge-base:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git fetch:*)
---

Review the change set represented by the current branch or CI pull request.

Arguments: `$ARGUMENTS`

Supported arguments:
- `--base <ref>`: base branch or ref to compare against.
- `--head <ref>`: head ref to review. Defaults to `HEAD`.
- `--format markdown|json`: output format. Defaults to `markdown`.

## Resolve the review range

1. Determine the head ref:
   - Use `--head` when provided.
   - Otherwise use `HEAD`.

2. Determine the base ref in this order:
   - `--base` when provided.
   - `CODEBUILD_WEBHOOK_BASE_REF` when present; strip the `refs/heads/` prefix.
   - `develop` as the local-development default.

3. Resolve the base locally. Prefer `origin/<base>` when it exists, otherwise use `<base>`.
   If the base ref is unavailable and an `origin` remote exists, fetch only the required base branch and retry.
   If the base still cannot be resolved, stop and explain which ref is missing. Never review against an arbitrary fallback branch.

4. Use merge-base semantics so the review represents changes introduced by the head branch rather than unrelated changes on the base branch.
   Inspect at minimum:
   - changed file names
   - the unified diff
   - commits in the review range

## Review scope

The diff defines WHAT is under review. The repository defines the context available to validate the change.

- Report only issues introduced by the reviewed change set.
- You may inspect surrounding source, callers, callees, interfaces, tests, configuration, and related code when necessary to validate a finding.
- Read applicable `CLAUDE.md` files when present.
- Apply the relevant SST plugin skills based on the changed code, including backend-review, frontend-review, and security-review when applicable.
- Do not report unrelated pre-existing problems.
- Do not report formatting/style nitpicks that should be handled by a formatter or linter.
- Prefer high-signal, actionable findings. If an issue cannot be validated with reasonable confidence, omit it.
- Pay special attention to correctness, regressions, error handling, data integrity, API/contract compatibility, concurrency, security boundaries, and behavior changes.

## Finding format

Each finding must include:
- severity: `critical`, `high`, `medium`, or `low`
- file path
- line or changed hunk when identifiable
- concise title
- explanation of the concrete failure/risk
- evidence from the changed code and relevant context
- a practical remediation direction

Do not fabricate a line number. If the issue spans multiple locations, identify the smallest useful changed hunk and mention the related locations in the explanation.

## Output

For `markdown` output:

```text
## Review summary
<short summary>

## Findings
### [severity] <title>
- File: <path>:<line-or-hunk>
- Issue: <concrete explanation>
- Evidence: <why this is a real issue>
- Recommendation: <remediation direction>
```

If there are no findings, output exactly this finding section:

```text
## Findings
No issues found.
```

For `json` output, return only valid JSON with this shape and no surrounding markdown fences:

```json
{
  "summary": "...",
  "base": "...",
  "head": "...",
  "findings": [
    {
      "severity": "high",
      "path": "src/...",
      "line": 42,
      "title": "...",
      "issue": "...",
      "evidence": "...",
      "recommendation": "..."
    }
  ]
}
```

Use `null` for `line` when no single line is appropriate.

This command only performs review and emits findings. It must not modify files, create commits, push branches, or post GitHub comments. CI systems such as AWS CodeBuild should publish the resulting findings through a separate adapter.
