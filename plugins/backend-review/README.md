# Backend Review

SST backend pull request review workflow for Claude Code.

Install:

```text
/plugin install backend-review@sst-ai-skills
```

Run locally:

```text
/backend-review:review-pr --base develop
```

CI can invoke the same command with `--format json` and publish findings separately.
