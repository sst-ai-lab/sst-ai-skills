# Frontend

Shared SST frontend engineering guidance and pull request review workflow for Claude Code.

Install from the `sst-ai-skills` marketplace:

```text
/plugin install frontend@sst-ai-skills
```

The plugin provides:
- `frontend` skill for implementation, refactoring, debugging, and design work.
- `frontend-review` skill for high-signal frontend review rules.
- `/frontend:review-pr` command for local and CI pull request review.

Example project settings:

```json
{
  "enabledPlugins": {
    "frontend@sst-ai-skills": true
  }
}
```

Run review locally:

```text
/frontend:review-pr --base develop
```

AWS CodeBuild can invoke the same command with `--format json`; GitHub publishing remains a separate CI adapter.
