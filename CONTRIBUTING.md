# Contributing

## Marketplace layout

The repository root is a Claude Code marketplace. Add installable plugins under `plugins/common/<plugin-name>/` or `plugins/services/<plugin-name>/`.

Each plugin should follow the standard structure as needed:

```text
plugins/<common|services>/<plugin-name>/
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

Split plugins by who uses the content, not by whether content is a command or skill.

| Content | Location |
|---|---|
| Facts about one repository (purpose, ports, topics, chosen policies) | That repository's `CLAUDE.md` — never a plugin |
| Skill or command used by two or more repositories of the same stack | `plugins/common/<stack>-common` |
| Skill or command used by exactly one repository | `plugins/services/<repository-name>` |

Current plugins:

- Common: `backend-common` (all `cm-be-*`), `frontend-common` (Vue web frontends), `mobile-common` (Flutter), `fw-be-common` (`sst-fw-be-*`).
- Services: `cm-be-bff-web`, `cm-be-spec`, `cm-be-ms-log`, `cm-be-ms-dailyinv`, `sst-fw-be-core`.

A repository enables its stack's common plugin plus, only when it exists, its own service plugin. Create a service plugin only when the repository has at least one specific skill. When a second repository starts using a service skill, move it to the common plugin and bump both plugins.

### Common plugins are service-neutral

Content in `plugins/common` must work unchanged for a brand-new repository of the same kind:

- Do not write repository names, ports, topics, table names, service exception classes, gRPC channel names or service base packages. Use placeholders such as `{basePackage}`, `{grpcChannel}`, `{serviceException}`.
- Architectural roles (BFF, microservice, gRPC server/client, Kafka consumer) and shared framework names (`sst-fw-be-*`, `sst-fw-web`) are allowed.
- When services legitimately differ, keep each rule as a named variant and let the repository `CLAUDE.md` select it.
- Each common skill lists its `## Inputs from CLAUDE.md`. Placeholder values come from the repository `CLAUDE.md` sections `## Service profile` and `## Policies`; when a value is missing the skill asks instead of guessing.

### Naming

- Plugins: `<stack>-common` or the exact repository name.
- Skills: `<subject>-<kind>`, where kind is `guide` (conventions/knowledge), `scaffold` (generate code) or `review` (check against conventions). Do not repeat the plugin name; skills are already namespaced (`/backend-common:ms-scaffold`). A `bff-` / `ms-` prefix is allowed in common plugins when a skill applies to one architectural role only.
- Commands: a verb phrase (`review-code`, `create-comment`).

## Add a plugin

1. Create `plugins/<common|services>/<plugin-name>/.claude-plugin/plugin.json`.
2. Add only the plugin components that are actually used.
3. Add the plugin entry to `.claude-plugin/marketplace.json` with a relative `source` such as `./plugins/services/<plugin-name>`.
4. Add a plugin README with usage examples.
5. Validate the marketplace with `claude plugin validate .`.
6. Install/test from the marketplace before opening a pull request.

## Add or update a skill

1. Create or edit `plugins/<common|services>/<plugin-name>/skills/<skill-name>/SKILL.md`.
2. Use lowercase kebab-case for the skill folder and frontmatter `name` when provided.
3. Give the skill a precise `description` so Claude can determine when it applies.
4. Keep supporting references or scripts inside that skill directory only when they are actually needed.
5. Avoid empty placeholder directories.

## Add or update a command

Create commands under `plugins/<common|services>/<plugin-name>/commands/`.

Commands should orchestrate workflows. Domain conventions and reusable review knowledge should live in skills rather than being duplicated inside commands.

For portable review workflows, keep provider-specific publishing logic outside the plugin. The `review-code` commands emit findings only; publishing them to GitHub (for example from AWS CodeBuild) belongs to a separate CI adapter.

## Versioning

Each plugin uses SemVer in its own `.claude-plugin/plugin.json`. Treat that manifest as the single source of truth for the plugin version; do not duplicate the plugin version in the marketplace entry.

Bump the plugin version whenever a change to that plugin should be distributed to installed users. This includes changes to skills, commands, agents, hooks, plugin-local configuration, or other plugin content.

Use the usual SemVer intent:

- PATCH for backward-compatible fixes, wording/convention updates, and other non-breaking plugin changes.
- MINOR for backward-compatible new capabilities or workflows.
- MAJOR for breaking changes to plugin behavior, commands, or expected usage.

Update the top-level marketplace version only when marketplace metadata itself changes.
