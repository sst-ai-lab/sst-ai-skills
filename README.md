# SST AI Skills Marketplace

Private Claude Code plugin marketplace for shared SST engineering guidance and pull request review workflows.

## Structure

```text
sst-ai-skills/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   ├── common/                     # skills shared by 2+ repositories of a stack
│   │   ├── backend-common/         # all cm-be-*: convention-review, framework-guide, bff-scaffold, ms-scaffold, /review-code
│   │   ├── frontend-common/        # Vue web: vue-guide, screen-scaffold, convention-review
│   │   ├── mobile-common/          # Flutter: /create-comment
│   │   └── fw-be-common/           # sst-fw-be-* (no skills yet)
│   ├── services/                   # skills used by exactly one repository
│   │   ├── cm-be-bff-web/          # report-scaffold, integration-scaffold
│   │   ├── cm-be-spec/             # openapi-scaffold, openapi-integration-scaffold
│   │   ├── cm-be-ms-log/           # feature-scaffold, athena-guide
│   │   ├── cm-be-ms-dailyinv/      # feature-scaffold, clickhouse-guide
│   │   └── sst-fw-be-core/         # validation-scaffold, extension-guide
├── README.md
└── CONTRIBUTING.md
```

Each repository enables its stack's common plugin and, when one exists, its own service plugin. Repository-specific facts stay in the repository's `CLAUDE.md`. See `CONTRIBUTING.md` for placement and naming rules.

| Repository | `enabledPlugins` |
|---|---|
| `cm-be-bff-web`, `cm-be-spec`, `cm-be-ms-log`, `cm-be-ms-dailyinv` | `backend-common` + the plugin named after the repository |
| other `cm-be-*` | `backend-common` |
| `cm-fe-web`, `manual-fe-web` | `frontend-common` |
| `sst-fw-be-core` | `fw-be-common` + `sst-fw-be-core` |
| other `sst-fw-be-*` | `fw-be-common` |
| `cm-fe-mobile`, `sst-fw-mobile`, `sst-fw-widgetbook` | `mobile-common` |

Example (`cm-be-bff-web/.claude/settings.json`):

```json
{
  "enabledPlugins": {
    "backend-common@sst-ai-skills": true,
    "cm-be-bff-web@sst-ai-skills": true
  }
}
```

## Add the marketplace

The repository is private, so normal Git access to `sst-ai-lab/sst-ai-skills` must work first.

Add the marketplace once per developer machine:

```text
/plugin marketplace add sst-ai-lab/sst-ai-skills
```

## Install

Plugins listed in a repository's `.claude/settings.json` `enabledPlugins` are installed and updated automatically at session start by that repository's `sync-plugins.mjs` hook. To install manually:

```text
/plugin install backend-common@sst-ai-skills
/plugin install cm-be-bff-web@sst-ai-skills
```

## Convention review

Each stack has one `convention-review` skill (based on the cm-docs 開発規約) and a read-only `/review-code` command. The same skill serves the developer self-check and pull request review.

```text
/backend-common:review-code staged
/frontend-common:review-code src/views/core/so/soMainte
```

## Update

Refresh marketplace metadata after changes are published:

```text
/plugin marketplace update sst-ai-skills
```

## Validate

```bash
claude plugin validate .
```
