# SST AI Skills

This repository is the Claude Code plugin marketplace of SST: it manages and publishes the plugins that provide skills to the SST repositories, both skills common to a whole stack and skills specific to one repository. These skills provide Claude with the development standards (開発規約) and the internal `sst-fw-*` frameworks.

**On this page**

- [1. Quick start](#1-quick-start)
  - [1.1 Use a skill](#11-use-a-skill)
- [2. What's included](#2-whats-included)
  - [2.1 Not written yet](#21-not-written-yet)
- [3. Add the skills to a repository](#3-add-the-skills-to-a-repository)
  - [3.1 Rollout status](#31-rollout-status)
- [4. Troubleshooting](#4-troubleshooting)
- [5. How it works](#5-how-it-works)

To change a skill or add one, see [CONTRIBUTING.md](CONTRIBUTING.md).

## 1. Quick start

Follow these steps in a repository that has installed the plugins from this marketplace, for example [`cm-be-bff-api`](https://github.com/suzuyo-cm/cm-be-bff-api/tree/feature/SCM-535088) (see [Rollout status](#31-rollout-status)).

**Before you start**

- Claude Code is installed, in the terminal or in VS Code.
- Node.js 22 or later is installed. Check with `node --version`. The plugin sync runs on Node.js.
- You have read access to the private repository `suzuyo-cm/sst-ai-skills`. If `git ls-remote git@github.com:suzuyo-cm/sst-ai-skills.git` fails, check your access to the repository.

**Steps**

1. Open Claude Code in the repository and send any message.

   The skills install in the background. The first time, you see:

   ```text
   Claude plugins synced:
     • sst-common@sst-ai-skills: installed 0.1.0
     • sst-be-common@sst-ai-skills: installed 0.3.0
   Run /reload-plugins to load the changes in this session.
   ```

2. Run `/reload-plugins`.

3. Review your changes:

   ```text
   /sst-common:review-code
   ```

   Claude asks which changes to review, then lists each place that breaks the standards, with the rule and how to fix it. It does not edit any file.

Setup is complete. The skills are updated automatically each time Claude Code starts.

### 1.1 Use a skill

Skill names do not need to be memorized. Describe the task, and Claude selects the matching skill:

```text
Create the BFF endpoint for the owner shipment search, from the attached design document.
```

To pick a skill yourself, type `/` in Claude Code and choose from the list, for example `/cm-be-bff-common:scaffold-bff-feature`.

## 2. What's included

Plugins come in four layers. A repository enables one plugin per layer that applies to it, so it gets exactly the skills it needs.

| Layer | Holds | Plugins |
|---|---|---|
| Every repository | the review command | `sst-common` |
| Stack | the development standards (開発規約) and the framework catalog | `sst-be-common`, `sst-fe-common`, `sst-mobile-common` |
| Role | code generation for that kind of repository | `cm-be-bff-common`, `cm-be-ms-common`, `cm-fe-web-common`, `sst-fw-be-common` |
| One repository | what only that repository needs | `cm-be-bff-web`, `cm-be-spec`, `cm-be-ms-log`, `cm-be-ms-dailyinv`, `sst-fw-be-core` |

**Every repository** — `sst-common`

| Command | Use it to |
|---|---|
| `/sst-common:review-code` | Review your changes against the standards of every plugin the repository enables. |

**Java: `cm-be-*`, `sst-fw-be-*`, `cm-print-agent`** — [`sst-be-common`](plugins/common/sst-be-common/README.md)

| Skill | Use it to |
|---|---|
| `check-conventions` | Check Java code and MyBatis XML against バックエンド開発規約. `/sst-common:review-code` uses it. |
| `use-sst-framework` | Find what the `sst-fw-be-*` framework already provides, before writing it yourself. |

**BFF: `cm-be-bff-*`** — [`cm-be-bff-common`](plugins/common/cm-be-bff-common/README.md)

| Skill | Use it to |
|---|---|
| `scaffold-bff-feature` | Generate the BFF side of a feature from a design document: Controller, Service, gRPC client. |

**Microservices: `cm-be-ms-*`** — [`cm-be-ms-common`](plugins/common/cm-be-ms-common/README.md)

| Skill | Use it to |
|---|---|
| `scaffold-ms-feature` | Generate a microservice feature: gRPC service, Service, MyBatis mapper, MapStruct mapping, or a Kafka consumer. |

**Vue: `cm-fe-web`, `manual-fe-web`, `sst-fw-web`, `sst-fw-storybook`** — [`sst-fe-common`](plugins/common/sst-fe-common/README.md)

| Skill | Use it to |
|---|---|
| `check-conventions` | Check `.vue`, composables and the API layer against フロントエンド開発規約. `/sst-common:review-code` uses it. |
| `use-sst-framework` | Follow the Vue and API client conventions, and find the `sst-fw-web` components and utilities to reuse. |

**Vue web applications: `cm-fe-web`, `manual-fe-web`** — [`cm-fe-web-common`](plugins/common/cm-fe-web-common/README.md)

| Skill | Use it to |
|---|---|
| `scaffold-screen` | Generate a search or maintenance screen from 基本設計書 / 詳細設計書 and Figma. |

**Flutter: `cm-fe-mobile`, `sst-fw-mobile`, `sst-fw-widgetbook`** — [`sst-mobile-common`](plugins/common/sst-mobile-common/README.md)

| Command | Use it to |
|---|---|
| `/sst-mobile-common:create-comment <file>` | Add Japanese Dart comments to a file, without changing the code. |

**One repository only** — service plugins, named after their repository

| Repository | Skill | Use it to |
|---|---|---|
| [`cm-be-bff-web`](plugins/services/cm-be-bff-web/README.md) | `scaffold-report` | Generate a JasperReports report feature (帳票). |
| | `scaffold-integration` | Generate an external integration that wraps a vendor SDK (Azure, Bedrock). |
| [`cm-be-spec`](plugins/services/cm-be-spec/README.md) | `scaffold-contract` | Generate the BFF contract (TypeSpec) and the gRPC contract (OpenAPI) from design documents. |
| | `scaffold-integration-contract` | Generate the BFF-only TypeSpec contract of an external integration. |
| [`cm-be-ms-log`](plugins/services/cm-be-ms-log/README.md) | `scaffold-log-feature` | Generate a log search endpoint (PostgreSQL or Athena) or a Kafka log ingestion. |
| | `write-athena-clients` | Follow the rules for AWS Athena client classes. |
| [`cm-be-ms-dailyinv`](plugins/services/cm-be-ms-dailyinv/README.md) | `scaffold-inventory-feature` | Generate a feature that uses both PostgreSQL and ClickHouse. |
| | `write-clickhouse-mappers` | Follow the rules for ClickHouse MyBatis mappers. |
| [`sst-fw-be-core`](plugins/services/sst-fw-be-core/README.md) | `scaffold-constraint` | Generate a custom Bean Validation constraint. |
| | `write-extensions` | Follow the rules for extension utility classes. |

### 2.1 Not written yet

| Plugin | Missing | Written from |
|---|---|---|
| `sst-mobile-common` | `check-conventions` | cm-docs モバイル開発規約 (537 lines) |
| `sst-fw-be-common` | every skill | the rules the six `sst-fw-be-*` repositories keep today (683 lines) |
| `cm-be-spec` | `check-conventions` for `.tsp` and OpenAPI | the OpenAPI and TypeSpec rules the repository keeps today (524 lines) |
| `cm-devops-common` | the whole plugin, for `cm-devops-*` | the Terraform rules `cm-devops-terraform` keeps today (124 lines) |
| `sst-be-common`, `sst-fe-common` | the cross-stack standards | the 11 documents of cm-docs `19.開発規約整備/common/` |

## 3. Add the skills to a repository

For the person responsible for a repository that is not set up yet. The setup consists of two files and one pull request.

1. Copy these two files from `cm-be-bff-api` (branch `feature/SCM-535088`) to the same paths in your repository:
   - [`.claude/settings.json`](https://github.com/suzuyo-cm/cm-be-bff-api/blob/feature/SCM-535088/.claude/settings.json)
   - [`.claude/hooks/sync-plugins.mjs`](https://github.com/suzuyo-cm/cm-be-bff-api/blob/feature/SCM-535088/.claude/hooks/sync-plugins.mjs)

2. In `.claude/settings.json`, list your repository's plugins under `enabledPlugins`. Find them in the [Rollout status](#31-rollout-status) table. For `cm-be-bff-api`:

   ```json
   "enabledPlugins": {
     "sst-common@sst-ai-skills": true,
     "sst-be-common@sst-ai-skills": true
   }
   ```

   A repository with a service plugin adds it as well, for example `"cm-be-bff-web@sst-ai-skills": true`.

   Leave the rest of the file as it is.

3. Commit both files and merge them into the default branch.

4. Check: open Claude Code in the repository. You should see `Claude plugins synced` with the plugins from step 2.

5. Mark the repository as **Deployed** in the [Rollout status](#31-rollout-status) table, with a pull request to this repository.

<details>
<summary>The complete <code>.claude/settings.json</code> of <code>cm-be-bff-api</code></summary>

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "node \"$CLAUDE_PROJECT_DIR/.claude/hooks/sync-plugins.mjs\"",
            "timeout": 300
          }
        ]
      }
    ]
  },
  "enabledPlugins": {
    "sst-common@sst-ai-skills": true,
    "sst-be-common@sst-ai-skills": true
  },
  "extraKnownMarketplaces": {
    "sst-ai-skills": {
      "source": {
        "source": "git",
        "url": "git@github.com:suzuyo-cm/sst-ai-skills.git"
      },
      "autoUpdate": false
    }
  }
}
```

</details>

### 3.1 Rollout status

As of 2026-09-28.

| Repository | Group | Plugins to enable | Status |
|---|---|---|---|
| `cm-be-bff-api` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common` | In progress ([PR #6](https://github.com/suzuyo-cm/cm-be-bff-api/pull/6)) |
| `cm-be-bff-manual` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common` | Not yet |
| `cm-be-bff-web` | BFF | `sst-common`, `sst-be-common`, `cm-be-bff-common`, `cm-be-bff-web` | Not yet |
| `cm-be-ms-bill` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Not yet |
| `cm-be-ms-core` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Not yet |
| `cm-be-ms-inout` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Not yet |
| `cm-be-ms-manual` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Not yet |
| `cm-be-ms-owner` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common` | Not yet |
| `cm-be-ms-log` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common`, `cm-be-ms-log` | Not yet |
| `cm-be-ms-dailyinv` | Microservice | `sst-common`, `sst-be-common`, `cm-be-ms-common`, `cm-be-ms-dailyinv` | Not yet |
| `cm-be-spec` | API contracts | `sst-common`, `cm-be-spec` | Not yet |
| `cm-fe-web` | Vue web | `sst-common`, `sst-fe-common`, `cm-fe-web-common` | Not yet |
| `manual-fe-web` | Vue web | `sst-common`, `sst-fe-common`, `cm-fe-web-common` | Not yet |
| `cm-fe-mobile` | Flutter | `sst-common`, `sst-mobile-common` | Not yet |
| `sst-fw-mobile` | Flutter | `sst-common`, `sst-mobile-common` | Not yet |
| `sst-fw-widgetbook` | Flutter | `sst-common`, `sst-mobile-common` | Not yet |
| `sst-fw-be-core` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common`, `sst-fw-be-core` | Not yet |
| `sst-fw-be-aws` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Not yet |
| `sst-fw-be-grpc` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Not yet |
| `sst-fw-be-http` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Not yet |
| `sst-fw-be-security` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Not yet |
| `sst-fw-be-starter-platform` | Backend framework | `sst-common`, `sst-be-common`, `sst-fw-be-common` | Not yet |
| `sst-fw-web` | Frontend framework | `sst-common`, `sst-fe-common` | Not yet |
| `sst-fw-storybook` | Frontend framework | `sst-common`, `sst-fe-common` | Not yet |
| `cm-print-agent` | Tool (Java) | `sst-common`, `sst-be-common` | Not yet |
| `cm-devops-terraform` | Terraform | `sst-common`, `cm-devops-common` | Waiting for `cm-devops-common` |
| `cm-devops-cicd` | Terraform | `sst-common`, `cm-devops-common` | Waiting for `cm-devops-common` |

`cm-tool-db-copy` (Python) is out of scope until there are Python standards to review against.

## 4. Troubleshooting

| What you see | What to do |
|---|---|
| No `Claude plugins synced` message, and the skills are missing | The repository is not set up yet. Check the [Rollout status](#31-rollout-status) table. |
| `Failed ... plugin operation(s)`, with a Git or `sst-ai-skills` error | Your account cannot read `suzuyo-cm/sst-ai-skills`. Run `git ls-remote git@github.com:suzuyo-cm/sst-ai-skills.git`; if it fails, check your access to the repository. |
| `node` is not recognized, or `node: command not found`, when Claude Code starts | Node.js is not installed or not on `PATH`. Install Node.js 22 or later, then restart Claude Code. |
| `Plugin sync skipped: Claude Code CLI not found` | Install the Claude Code CLI, or set the `CLAUDE_CLI_PATH` environment variable to the `claude` executable. |
| The skills are still missing after `/reload-plugins` (VS Code) | Run **Developer: Reload Window** from the command palette. |
| The terminal and VS Code both show `Claude plugins synced` for the same repository | This is expected. On Windows, the terminal and VS Code each maintain a separate installation. |

## 5. How it works

- A **skill** is a set of instructions and reference documents. Claude loads it when your task matches it, or when you call it with `/`.
- A **plugin** is a package of skills. Each plugin has a version.
- This repository is a **marketplace**: it publishes the plugins.
- A repository lists the plugins it needs in `.claude/settings.json`. Every time Claude Code starts there, the `sync-plugins.mjs` hook installs the missing plugins and updates the others to their latest version on `develop`.

A plugin's name says where it applies, and its layer says what it holds:

| Name | Applies to | Holds |
|---|---|---|
| `sst-common` | every repository | the review command |
| `sst-<stack>-common` | every repository of a stack, products and frameworks alike | the development standards and the framework catalog |
| `cm-<family>-common` | the repositories of one product family | code generation for that kind of repository |
| `<repository name>` | one repository | what only that repository needs |
