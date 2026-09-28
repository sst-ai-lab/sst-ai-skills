# cm-be-bff-common

Shared skills for the SCM BFF services. Enable it in every `cm-be-bff-*` repository, together with `sst-common` and `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "cm-be-bff-common@sst-ai-skills": true } }
```

## Contents

| Skill | Purpose |
| --- | --- |
| `scaffold-bff-feature` | Generate the BFF side of a feature (Controller -> Service -> gRPC client) from a design document; the microservice side is generated with `cm-be-ms-common:scaffold-ms-feature` in the microservice repository |

The backend development standards and the framework catalog live in `sst-be-common`, which every Java repository enables.

## Inputs from CLAUDE.md

`scaffold-bff-feature` reads `## Service profile` and `## Policies` from the repository `CLAUDE.md`, and asks the user when a value is missing. See its `SKILL.md` for the exact list.
