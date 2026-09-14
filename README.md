# SST AI Skills Marketplace

Private Claude Code plugin marketplace for shared SST engineering guidance and pull request review workflows.

## Structure

```text
sst-ai-skills/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── backend/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/review-pr.md
│   │   └── skills/
│   │       ├── backend/
│   │       │   ├── SKILL.md
│   │       │   └── references/
│   │       ├── backend-review/SKILL.md
│   │       └── backend-security/SKILL.md
│   └── frontend/
│       ├── .claude-plugin/plugin.json
│       ├── commands/review-pr.md
│       └── skills/
│           ├── frontend/
│           │   ├── SKILL.md
│           │   └── references/
│           ├── frontend-review/SKILL.md
│           └── frontend-security/SKILL.md
├── README.md
└── CONTRIBUTING.md
```

Each repository type uses one plugin. The plugin contains both normal development guidance and its PR review workflow.

## Add the marketplace

The repository is private, so normal Git access to `sst-ai-lab/sst-ai-skills` must work first.

Add the marketplace once per developer machine:

```text
/plugin marketplace add sst-ai-lab/sst-ai-skills
```

## Backend repositories

Install one plugin:

```text
/plugin install backend@sst-ai-skills
```

The backend plugin provides the `backend`, `backend-review`, and `backend-security` skills plus the review command:

```text
/backend:review-pr --base develop
```

A backend repository can commit `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "backend@sst-ai-skills": true
  }
}
```

## Frontend repositories

Install one plugin:

```text
/plugin install frontend@sst-ai-skills
```

The frontend plugin provides the `frontend`, `frontend-review`, and `frontend-security` skills plus the review command:

```text
/frontend:review-pr --base develop
```

Example project settings:

```json
{
  "enabledPlugins": {
    "frontend@sst-ai-skills": true
  }
}
```

## Local vs CI

Local Claude Code and AWS CodeBuild use the same plugin and the same `review-pr` command. The command always applies the plugin's review skill and may use its development skill for surrounding implementation context.

For CI, invoke the command with `--format json`. Publishing findings to GitHub Pull Request Review APIs remains a separate CodeBuild adapter.

## Update

Refresh marketplace metadata after changes are published:

```text
/plugin marketplace update sst-ai-skills
```

## Validate

```bash
claude plugin validate .
```
