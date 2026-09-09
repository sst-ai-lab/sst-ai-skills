# Contributing

## Marketplace layout

The repository root is a Claude Code marketplace. Add installable plugins under `plugins/<plugin-name>/`.

Each plugin should follow the standard structure as needed:

```text
plugins/<plugin-name>/
├── .claude-plugin/
│   └── plugin.json
├── commands/      # optional
├── agents/        # optional
├── skills/        # optional
├── hooks/         # optional
├── .mcp.json      # optional
└── README.md
```

Do not place plugin commands or skills directly at the marketplace root.

## Plugin boundaries

Split plugins by capability and repository type, not by Claude Code implementation detail.

Current convention:

- `backend`: backend development guidance.
- `backend-review`: backend PR review workflow and review rules.
- `frontend`: frontend development guidance.
- `frontend-review`: frontend PR review workflow and review rules.

Keep development guidance independent from review workflows so repositories can enable only what they need.

## Add a plugin

1. Create `plugins/<plugin-name>/.claude-plugin/plugin.json`.
2. Add only the plugin components that are actually used.
3. Add the plugin entry to `.claude-plugin/marketplace.json` with a relative `source` such as `./plugins/<plugin-name>`.
4. Add a plugin README with usage examples.
5. Validate the marketplace with `claude plugin validate .`.
6. Install/test from the marketplace before opening a pull request.

## Add or update a skill

1. Create or edit `plugins/<plugin-name>/skills/<skill-name>/SKILL.md`.
2. Use lowercase kebab-case for the skill folder and frontmatter `name` when provided.
3. Give the skill a precise `description` so Claude can determine when it applies.
4. Keep supporting references or scripts inside that skill directory only when they are actually needed.
5. Avoid empty placeholder directories.

## Add or update a command

Create commands under `plugins/<plugin-name>/commands/`.

Commands should orchestrate workflows. Domain conventions and reusable review knowledge should live in skills rather than being duplicated inside commands.

For portable review workflows, keep provider-specific publishing logic outside the plugin. Review plugins emit findings; AWS CodeBuild or another CI adapter publishes them to GitHub.

## Versioning

Update the plugin version in both its `.claude-plugin/plugin.json` and marketplace entry when publishing a deliberate plugin release. Update the marketplace version when marketplace metadata changes.
