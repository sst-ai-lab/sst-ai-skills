# Contributing

This guide is for anyone who changes the skills: fixes a rule, adds a skill or adds a plugin.

**On this page**

- [1. Before you start](#1-before-you-start)
- [2. Common tasks](#2-common-tasks)
  - [2.1 Fix or improve a skill](#21-fix-or-improve-a-skill)
  - [2.2 Add a skill](#22-add-a-skill)
  - [2.3 Rename or remove a skill](#23-rename-or-remove-a-skill)
  - [2.4 Add a plugin](#24-add-a-plugin)
  - [2.5 Rename or remove a plugin](#25-rename-or-remove-a-plugin)
- [3. Test your change](#3-test-your-change)
- [4. Reference](#4-reference)
  - [4.1 Which version to raise](#41-which-version-to-raise)
  - [4.2 Where content belongs](#42-where-content-belongs)
  - [4.3 Common plugins work for any repository](#43-common-plugins-work-for-any-repository)
  - [4.4 Naming](#44-naming)
  - [4.5 Writing a skill](#45-writing-a-skill)
  - [4.6 Writing a command](#46-writing-a-command)
  - [4.7 Review standards](#47-review-standards)

## 1. Before you start

**How a change reaches the repositories.** A repository installs the plugins from the `develop` branch of this repository, and only updates a plugin when its `version` has changed. So every change needs two things:

1. a new `version` in the plugin's `.claude-plugin/plugin.json`;
2. a merge into `develop`.

Repositories then pick it up the next time someone opens Claude Code in them.

**The version hook.** On every commit, a Git hook compares each changed plugin's `version` with `origin/develop`. If you have not raised it, the hook raises the PATCH part for you (`0.3.0` → `0.3.1`) and adds `plugin.json` to the commit. A version you raised yourself (MINOR or MAJOR) is kept, and a branch with several commits is raised only once. To skip it for one commit: `SKIP_VERSION_BUMP=1 git commit ...`.

The hook turns itself on the first time you open Claude Code in this repository and trust it. If you commit without ever opening Claude Code here, turn it on once per clone:

```bash
git config core.hooksPath .githooks
```

If `plugin.json` has changes you have not staged, the hook stops the commit: stage or stash them, or raise the version yourself.

**Where things are.**

```text
sst-ai-skills/
├── .claude-plugin/
│   └── marketplace.json          # the list of plugins
└── plugins/
    ├── common/<plugin>/          # shared by every repository of a stack
    └── services/<plugin>/        # used by one repository, named after it
        ├── .claude-plugin/
        │   └── plugin.json       # name and version of the plugin
        ├── skills/
        │   └── <skill>/
        │       ├── SKILL.md      # what Claude reads
        │       └── references/   # documents SKILL.md points to
        ├── commands/             # slash commands, if any
        └── README.md             # what the plugin's skills do
```

## 2. Common tasks

### 2.1 Fix or improve a skill

1. Edit the skill's `SKILL.md` or its `references/`.
2. In the plugin's `.claude-plugin/plugin.json`, raise the PATCH part of `version`: `0.3.0` → `0.3.1`.
3. [Test your change](#3-test-your-change).
4. Open a pull request to `develop`.

### 2.2 Add a skill

1. Decide where it goes: in the common plugin of the stack if several repositories need it, in the repository's service plugin otherwise. See [Where content belongs](#42-where-content-belongs).
2. Create `plugins/<common|services>/<plugin>/skills/<skill-name>/SKILL.md`. Name it as described in [Naming](#44-naming), and follow [Writing a skill](#45-writing-a-skill).
3. Raise the MINOR part of the plugin `version`: `0.3.0` → `0.4.0`.
4. Add the skill to the plugin's `README.md` and to [What's included](README.md#2-whats-included) in the README.
5. [Test your change](#3-test-your-change), then open a pull request to `develop`.

The repositories need no change: they get the new skill with the new version.

### 2.3 Rename or remove a skill

1. Rename or delete the skill's folder.
2. Search the other skills and commands for the old name, and update them.
3. Raise the MAJOR part of the plugin `version`: `0.3.0` → `1.0.0`.
4. Update the plugin's `README.md` and [What's included](README.md#2-whats-included) in the README.
5. [Test your change](#3-test-your-change), then open a pull request to `develop`.
6. Notify the teams of the new name.

### 2.4 Add a plugin

1. Create `plugins/<common|services>/<plugin>/` with:
   - `.claude-plugin/plugin.json`, with `version` `0.1.0`;
   - at least one skill;
   - a `README.md` that lists the skills and the repositories that enable the plugin.
2. Add the plugin to `.claude-plugin/marketplace.json`, with `source` set to its folder (for example `./plugins/services/<plugin>`), and raise the MINOR part of the marketplace `version`.
3. In the README, add the plugin to [What's included](README.md#2-whats-included) and to the repositories that use it in [Rollout status](README.md#31-rollout-status).
4. [Test your change](#3-test-your-change), then open a pull request to `develop`.
5. After the merge, add `"<plugin>@sst-ai-skills": true` to `enabledPlugins` in `.claude/settings.json` of each repository that uses it.

### 2.5 Rename or remove a plugin

1. Rename or delete the plugin's folder, update `.claude-plugin/marketplace.json`, and raise the MAJOR part of the marketplace `version`.
2. Update [What's included](README.md#2-whats-included) and [Rollout status](README.md#31-rollout-status) in the README.
3. [Test your change](#3-test-your-change), then open a pull request to `develop`.
4. After the merge, rename or remove the plugin in `enabledPlugins` of each repository that enables it. Until then, Claude Code reports it as missing every time it starts there.

## 3. Test your change

1. Check that the marketplace is valid:

   ```bash
   claude plugin validate .
   ```

   It should end with `Validation passed`.

2. Try the changed plugin in a repository that uses it. From that repository:

   ```bash
   claude --plugin-dir <path-to-sst-ai-skills>/plugins/<common|services>/<plugin>
   ```

   Claude Code loads your local copy of the plugin for this session only. Ask for the task the skill covers, and check the result.

## 4. Reference

### 4.1 Which version to raise

| Change | Plugin `version` (`plugin.json`) | Marketplace `version` (`marketplace.json`) | Change in each repository |
|---|---|---|---|
| Fix or reword a skill | PATCH (0.3.0 → 0.3.1) | — | None |
| Add a skill | MINOR (0.3.0 → 0.4.0) | — | None |
| Rename or remove a skill | MAJOR (0.3.0 → 1.0.0) | — | None |
| Move a skill to another plugin | MINOR for the plugin that gets it, MAJOR for the one that loses it | — | Enable the plugin that gets it, if not enabled yet |
| Add a plugin | Starts at 0.1.0 | MINOR (1.4.0 → 1.5.0) | Enable it where it is used |
| Rename or remove a plugin | — | MAJOR (1.4.0 → 2.0.0) | Rename or remove it where it is enabled |

The plugin `version` lives only in its `plugin.json`; do not repeat it in `marketplace.json`.

### 4.2 Where content belongs

Plugins are layered by how widely their content applies:

| Content | Goes in | Example |
|---|---|---|
| Facts about one repository: purpose, ports, topics, the policies it chose | that repository's `CLAUDE.md`, never a plugin | — |
| A command every repository uses, whatever its stack | `plugins/common/sst-common` | `/review-code` |
| Development standards or a framework catalog for a whole stack | `plugins/common/sst-<stack>-common` | `sst-be-common`, `sst-fe-common`, `sst-mobile-common` |
| Code generation, or rules, for one kind of repository | `plugins/common/cm-<family>-common` or `plugins/common/sst-fw-<stack>-common` | `cm-be-ms-common`, `sst-fw-be-common` |
| A skill or command only one repository uses | `plugins/services/<repository-name>` | `cm-be-ms-log` |

- Put a skill in the narrowest layer that fits. When a second repository needs it, move it up one layer.
- Create a service plugin only when the repository has at least one skill of its own.
- Create a plugin only once it has content. An empty plugin in the tables misleads whoever enables it.
- A repository enables one plugin per layer that applies to it, so most repositories enable three.

### 4.3 Common plugins work for any repository

A skill in `plugins/common` must work, unchanged, in a new repository of the same kind.

- Do not write repository names, ports, topics, table names, service exception classes, gRPC channel names or service base packages. Use placeholders instead, such as `{basePackage}`, `{grpcChannel}`, `{serviceException}`.
- Architectural roles (BFF, microservice, gRPC server or client, Kafka consumer) and shared framework names (`sst-fw-be-*`, `sst-fw-web`) are fine.
- When services legitimately differ, keep each approach as a named variant, and let the repository's `CLAUDE.md` select it.
- List the placeholders a skill needs in its `## Inputs from CLAUDE.md` section. Their values come from the `## Service profile` and `## Policies` sections of the repository's `CLAUDE.md`. When one is missing, the skill asks the developer instead of guessing.

### 4.4 Naming

- **Plugins:** the name says where the plugin applies. `sst-common` for every repository; `sst-<stack>-common` for a whole stack, products and frameworks alike (`sst-be-common`, `sst-fe-common`, `sst-mobile-common`); `cm-<family>-common` for one product family (`cm-be-bff-common`, `cm-be-ms-common`, `cm-fe-web-common`); `sst-fw-<stack>-common` for the framework repositories (`sst-fw-be-common`); and the exact repository name for a service plugin (`cm-be-ms-log`).
- **Skills:** a verb and an object, `<verb>-<object>`, that says what the skill does. Developers type it as a command (`/cm-be-ms-common:scaffold-ms-feature`), so it should read as one. Use one of four verbs:

  | Verb | The skill | Example |
  |---|---|---|
  | `scaffold-` | generates new code | `scaffold-screen` |
  | `check-` | compares code with written standards | `check-conventions`, `check-security` |
  | `use-` | shows what already exists, so it gets reused | `use-sst-framework` |
  | `write-` | holds the rules for writing one kind of code by hand | `write-athena-clients` |

  Make the object specific (`scaffold-log-feature`, not `scaffold-feature`), and do not repeat the plugin name. In a common plugin, a `bff-` or `ms-` prefix is fine for a skill that only applies to one role.
- **Commands:** the same verb-object form (`review-code`, `create-comment`).

### 4.5 Writing a skill

- Name the folder and the frontmatter `name` in lowercase kebab-case.
- Write a precise `description`. Claude reads it to decide when to use the skill.
- Keep only the references and scripts the skill uses, inside its own folder.
- Do not create empty placeholder folders.

### 4.6 Writing a command

- Put commands in `plugins/<common|services>/<plugin>/commands/`.
- A command runs the steps of a workflow. Keep the rules and knowledge it needs in skills, not in the command.

### 4.7 Review standards

`/sst-common:review-code` has no standards of its own. It loads every skill whose name starts with `check-` in the plugins the repository enables, and applies each to the files its description covers. To add standards (for a new stack, for rules only one repository follows, or for a new area such as security), add such a skill; `sst-common` does not change.

- Name the skill `check-<area>`: `check-conventions` for the development standards, `check-security` for security rules, and so on. Skills with other names are not loaded.
- Base it on written rules that have an identifier, such as a section number or a checklist ID. The command reports only what a document states, and quotes the rule. A skill that looks for bugs without written rules is not a `check-` skill.
- Say in its description which files it covers, for example "changed Java code" or ".vue / use*.ts".
- Keep the documents it points to in the same plugin. If one document wins over another (the standard over a checklist), say so in `SKILL.md`.
- In a service plugin, write only what differs from the stack's skill of the same name: both apply.

The command only reports findings. Posting them on a pull request is done by each repository's CI (for example the `pr-review` scripts of `cm-be-bff-api`), not by the plugin.
