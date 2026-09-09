# SST AI Skills

Central Claude Code plugin for reusable SST engineering review skills and a portable PR/branch review workflow.

## Plugin structure

```text
sst-ai-skills/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── review-pr.md
├── skills/
│   ├── backend-review/
│   │   └── SKILL.md
│   ├── frontend-review/
│   │   └── SKILL.md
│   └── security-review/
│       └── SKILL.md
├── README.md
└── CONTRIBUTING.md
```

The plugin separates review orchestration from review knowledge:

- `commands/review-pr.md` defines the review workflow, diff scope, output contract, and local/CI behavior.
- `skills/*/SKILL.md` contains reusable domain-specific review guidance.

## Test locally

From the parent directory of this repository:

```bash
claude --plugin-dir ./sst-ai-skills
```

Then run the review command from the target project repository.

Default local review against `develop`:

```text
/sst-ai-skills:review-pr
```

Explicit base branch:

```text
/sst-ai-skills:review-pr --base main
```

Structured output for automation:

```text
/sst-ai-skills:review-pr --base develop --format json
```

The command reviews only the change set introduced by the current branch while allowing Claude to inspect related code for validation. It does not modify files, create commits, push code, or post GitHub comments.

## AWS CodeBuild usage

The same plugin and `review-pr` command can run in CodeBuild. When `CODEBUILD_WEBHOOK_BASE_REF` is available, the command uses it as the PR base unless `--base` is supplied explicitly.

A CI adapter should handle environment-specific responsibilities separately:

```text
GitHub PR
   ↓
AWS CodeBuild
   ↓
Claude Code CLI + this plugin
   ↓
/sst-ai-skills:review-pr --format json
   ↓
review findings
   ↓
GitHub Review API adapter
```

Keeping GitHub publishing outside the plugin means developers can run exactly the same review workflow locally before pushing code.
