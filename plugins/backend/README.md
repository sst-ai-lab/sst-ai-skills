# Backend

Shared SST backend engineering guidance and pull request review workflow for Claude Code.

Install from the `sst-ai-skills` marketplace:

```text
/plugin install backend@sst-ai-skills
```

The plugin provides:
- `backend` skill for implementation, refactoring, debugging, and design work.
- `backend-review` skill for high-signal backend review rules.
- `/backend:review-pr` command for local and CI pull request review.

Example project settings:

```json
{
  "enabledPlugins": {
    "backend@sst-ai-skills": true
  }
}
```

Run review locally:

```text
/backend:review-pr --base develop
```

AWS CodeBuild can invoke the same command with `--format json`; GitHub publishing remains a separate CI adapter.
