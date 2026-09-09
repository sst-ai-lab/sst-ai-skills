# SST AI Skills

Central Claude Code plugin for shared SST AI engineering and code review skills.

## Plugin structure

```text
sst-ai-skills/
├── .claude-plugin/
│   └── plugin.json
└── skills/
    ├── backend-skill/
    │   └── SKILL.md
    ├── frontend-skill/
    │   └── SKILL.md
    └── security-skill/
        └── SKILL.md
```

Claude Code discovers skills from `skills/<skill-name>/SKILL.md` and namespaces them under the plugin name.

## Test locally

From the parent directory of this repository:

```bash
claude --plugin-dir ./sst-ai-skills
```

Then verify the plugin is loaded with `/help` or run a skill explicitly, for example:

```text
/sst-ai-skills:backend-skill
```

For CI environments such as AWS CodeBuild, load this repository as a Claude Code plugin before invoking Claude for review.
