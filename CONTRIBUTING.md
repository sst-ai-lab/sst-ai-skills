# Contributing

## Add a skill

1. Create `skills/<skill-name>/SKILL.md`.
2. Use lowercase kebab-case for the skill folder and frontmatter `name` when provided.
3. Give the skill a clear `description` so Claude can determine when to invoke it.
4. Keep supporting references or scripts inside that skill directory only when they are actually used.
5. Test the plugin locally with `claude --plugin-dir ./sst-ai-skills`.
6. Open a pull request.

## Update a skill

Edit the canonical skill under `skills/` and test the plugin locally before opening a pull request.

## Plugin metadata

Update `.claude-plugin/plugin.json` when the plugin metadata or version changes.
