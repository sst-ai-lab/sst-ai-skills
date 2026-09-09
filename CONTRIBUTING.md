# Contributing

## Add or update a review skill

1. Create or edit `skills/<skill-name>/SKILL.md`.
2. Use lowercase kebab-case for the skill folder and frontmatter `name`.
3. Give the skill a precise `description` so Claude can determine when it applies.
4. Keep the skill focused on reusable domain knowledge and review guidance. Do not put CI-specific publishing logic in a skill.
5. Add `references/` or `scripts/` under a skill only when they are actually required.
6. Test the plugin locally before opening a pull request.

## Update the review workflow

Edit `commands/review-pr.md` when changing how reviews are scoped, how base/head refs are resolved, or how findings are formatted.

The command must remain portable between local development and CI:

- It may inspect Git state and source code.
- It may emit markdown or structured JSON findings.
- It must not modify project files, commit, push, or publish comments to GitHub.
- Environment-specific publishing belongs in the CI adapter, not in the plugin command.

## Test locally

From the parent directory of this repository:

```bash
claude --plugin-dir ./sst-ai-skills
```

From a target repository, run for example:

```text
/sst-ai-skills:review-pr --base develop
```

For CI-oriented validation:

```text
/sst-ai-skills:review-pr --base develop --format json
```

## Plugin metadata

Update `.claude-plugin/plugin.json` when plugin metadata or version changes.
