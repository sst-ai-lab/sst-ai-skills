# sst-fw-be-common

The rules for writing the SST backend framework libraries (`sst-fw-be-*`), shared by all six of them. Enable it together with `sst-common` and `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "sst-fw-be-common@sst-ai-skills": true } }
```

## Contents

No skills yet. The backend standards and the framework catalog come from `sst-be-common`; skills specific to one framework repository live in its service plugin (see `plugins/services/sst-fw-be-core`).

## Not written yet

The rules for writing a framework module. Each of the six repositories still keeps its own rules, 683 lines in total; what they share becomes a skill here, and what belongs to one repository goes to its service plugin.
