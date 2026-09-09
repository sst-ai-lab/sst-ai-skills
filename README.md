# SST AI Skills Marketplace

Private Claude Code plugin marketplace for shared SST AI engineering workflows and review conventions.

## Structure

```text
sst-ai-skills/
├── .claude-plugin/
│   └── marketplace.json
├── plugins/
│   └── sst-code-review/
│       ├── .claude-plugin/
│       │   └── plugin.json
│       ├── commands/
│       │   └── review-pr.md
│       ├── skills/
│       │   ├── backend-review/
│       │   │   └── SKILL.md
│       │   ├── frontend-review/
│       │   │   └── SKILL.md
│       │   └── security-review/
│       │       └── SKILL.md
│       └── README.md
├── README.md
└── CONTRIBUTING.md
```

The repository root is a Claude Code marketplace. Each directory under `plugins/` is an independently installable Claude Code plugin.

## Install locally

The repository is private, so make sure normal Git access works first, for example through `gh auth login`, SSH, or your configured Git credential helper.

Inside Claude Code, add the marketplace once:

```text
/plugin marketplace add sst-ai-lab/sst-ai-skills
```

Then install the review plugin:

```text
/plugin install sst-code-review@sst-ai-skills
```

The default install scope is user scope, so the plugin is available across local repositories for that developer.

Then from any repository:

```text
/sst-code-review:review-pr
```

Or specify the base explicitly:

```text
/sst-code-review:review-pr --base develop
```

## Non-interactive / CI setup

Claude Code also exposes plugin management commands suitable for automation:

```bash
claude plugin marketplace add sst-ai-lab/sst-ai-skills
claude plugin install sst-code-review@sst-ai-skills
```

AWS CodeBuild can install the same marketplace/plugin and invoke the same review command with JSON output. GitHub comment publishing should remain a separate CI adapter.

## Update

After marketplace changes are published, refresh the local marketplace:

```text
/plugin marketplace update sst-ai-skills
```

Plugin installation and update behavior is managed by Claude Code's plugin cache; consuming projects do not copy `SKILL.md` files into their repositories.

## Validate

Validate the marketplace before publishing changes:

```bash
claude plugin validate .
```
