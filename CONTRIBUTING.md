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

Split plugins by repository/domain capability, not by whether content is a command or skill.

Current convention:

- `backend`: backend development guidance plus backend PR review workflow/rules.
- `frontend`: frontend development guidance plus frontend PR review workflow/rules.

A backend repository should only need the `backend` plugin; a frontend repository should only need the `frontend` plugin. Keep related development and review guidance together when they are expected to be installed and versioned together.

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

For portable review workflows, keep provider-specific publishing logic outside the plugin. The `review-pr` command emits findings; AWS CodeBuild or another CI adapter publishes them to GitHub.

## Versioning

Each plugin uses SemVer in its own `.claude-plugin/plugin.json`. Treat that manifest as the single source of truth for the plugin version; do not duplicate the plugin version in the marketplace entry.

Bump the plugin version whenever a change to that plugin should be distributed to installed users. This includes changes to skills, commands, agents, hooks, plugin-local configuration, or other plugin content.

Use the usual SemVer intent:

- PATCH for backward-compatible fixes, wording/convention updates, and other non-breaking plugin changes.
- MINOR for backward-compatible new capabilities or workflows.
- MAJOR for breaking changes to plugin behavior, commands, or expected usage.

Update the top-level marketplace version only when marketplace metadata itself changes.
