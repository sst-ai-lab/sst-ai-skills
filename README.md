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
│   │   └── skills/backend/SKILL.md
│   ├── backend-review/
│   │   ├── .claude-plugin/plugin.json
│   │   ├── commands/review-pr.md
│   │   └── skills/backend-review/SKILL.md
│   ├── frontend/
│   │   ├── .claude-plugin/plugin.json
│   │   └── skills/frontend/SKILL.md
│   └── frontend-review/
│       ├── .claude-plugin/plugin.json
│       ├── commands/review-pr.md
│       └── skills/frontend-review/SKILL.md
├── README.md
└── CONTRIBUTING.md
```

Each directory under `plugins/` is independently installable.

## Add the marketplace

The repository is private, so normal Git access to `sst-ai-lab/sst-ai-skills` must work first.

Add the marketplace once per developer machine:

```text
/plugin marketplace add sst-ai-lab/sst-ai-skills
```

## Backend repositories

Install the development guidance plugin:

```text
/plugin install backend@sst-ai-skills
```

Install the review workflow when PR review is needed:

```text
/plugin install backend-review@sst-ai-skills
```

Run review:

```text
/backend-review:review-pr --base develop
```

A backend repository can share these choices through `.claude/settings.json`:

```json
{
  "enabledPlugins": {
    "backend@sst-ai-skills": true,
    "backend-review@sst-ai-skills": true
  }
}
```

## Frontend repositories

```text
/plugin install frontend@sst-ai-skills
/plugin install frontend-review@sst-ai-skills
```

Run review:

```text
/frontend-review:review-pr --base develop
```

Example project settings:

```json
{
  "enabledPlugins": {
    "frontend@sst-ai-skills": true,
    "frontend-review@sst-ai-skills": true
  }
}
```

## Local vs CI

Development plugins (`backend`, `frontend`) provide reusable engineering guidance during normal Claude Code work.

Review plugins (`backend-review`, `frontend-review`) provide explicit `review-pr` workflows. The same command can run locally or in AWS CodeBuild. CI can use `--format json` and publish findings through a separate GitHub Review API adapter.

## Update

Refresh marketplace metadata after changes are published:

```text
/plugin marketplace update sst-ai-skills
```

## Validate

```bash
claude plugin validate .
```
