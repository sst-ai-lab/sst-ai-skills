# SST Code Review

Claude Code plugin that provides a portable code review workflow and shared SST review skills.

## Contents

```text
sst-code-review/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   └── review-pr.md
└── skills/
    ├── backend-review/
    │   └── SKILL.md
    ├── frontend-review/
    │   └── SKILL.md
    └── security-review/
        └── SKILL.md
```

## Usage

Run the review command from a target repository:

```text
/sst-code-review:review-pr
```

Choose an explicit base when needed:

```text
/sst-code-review:review-pr --base develop
```

For CI consumers such as AWS CodeBuild, request structured output:

```text
/sst-code-review:review-pr --format json
```

The plugin only performs review and returns findings. Publishing findings to GitHub is intentionally handled by a separate CI adapter so the same review workflow can be used locally and in CI.
