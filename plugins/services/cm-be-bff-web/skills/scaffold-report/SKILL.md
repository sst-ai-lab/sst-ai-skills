---
name: scaffold-report
description: Generates the BFF Java glue for a JasperReports report feature (Controller / Service / ServiceMapping / gRPC client) plus the row map and template wiring. Also holds the `.jrxml` authoring rules. Use when creating a new JasperReports report feature (帳票, PDF / jrprint output) in cm-be-bff-web, or when creating/editing a `.jrxml` / JasperReports template (field names, fonts, i18n, subreports, page breaks).
---

# Report skill (JasperReports)

## When to use

- Creating a new JasperReports report feature (帳票) with PDF / `jrprint` output.
- Creating or editing a `.jrxml` JasperReports template (`**/*.jrxml`).

## Scope

- **Generates:** the BFF Java glue (Controller, Service interface/impl, ServiceMapping, gRPC client/impl), the `toXxxRow` row map, and template registration (`@Value` + `@PostConstruct` compile/cache).

## How to use

See the reference below for the detailed steps.

| Pattern                    | File                  | Description                                              |
| -------------------------- | --------------------- | -------------------------------------------------------- |
| Initial creation           | `references/init.md`  | Steps to create a report feature from scratch            |
| `.jrxml` authoring rules   | `references/jrxml.md` | `.jrxml` field-name / font / i18n rules (`**/*.jrxml`)   |

## Related

- For the standard Controller→Service→gRPC client→Mapping scaffolding, see the **`cm-be-bff-common:scaffold-bff-feature` skill**.
- For `.jrxml` field-name / font / i18n rules, see **`references/jrxml.md`**.
- For repo-wide conventions and build constraints, see the repository **`CLAUDE.md`**.
