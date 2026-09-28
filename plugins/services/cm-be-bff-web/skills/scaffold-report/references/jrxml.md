# JasperReports (`.jrxml`) authoring rules

Applies to: `**/*.jrxml`

`.jrxml` are JasperReports templates under `src/main/resources/reports/` (with their `messages*.properties` bundles alongside; Japanese fonts under `src/main/resources/fonts/`), **compiled in-process at startup** (`@PostConstruct`) — no Maven step, no `.jasper` in git. Edit only `.jrxml`; never hand-edit a compiled `.jasper`.

A report is always paired with a service that fills it; the template and that service must stay in sync.

## Field binding — keys must match the service row-map exactly

`$F{...}` fields are populated from a `Map<String,Object>` built by the service's `toXxxRow()` method and fed via `JRMapCollectionDataSource`. **The `<field name>` must be byte-identical to the map key** or the cell renders blank.

- Key naming is **not consistent across reports — never assume a convention; open the target `.jrxml` and copy its exact `<field>` names** (styles seen range from hyphenated to underscored to concatenated to camelCase).
- When adding a field you must change **both** sides: add `<field name="…">` here **and** the matching `row.put("…", …)` in the service. Adding only one side is the most common bug.
- The `class` attribute must match the map value's Java type: `java.lang.String` (default), `java.math.BigDecimal` for monetary/decimal values, `java.lang.Integer`/`Double` for whole or computed numbers, `byte[]` for image bytes.

## Localization — never hardcode label text

- **Always use `$R{key}` for label text** — declare the `resourceBundle` on the root element, reference labels with `$R{key}`.
- When you do use `$R{}`, every key must exist in **all** locale variants of the bundle (`messages*.properties`) — add a new key to each.
- The service passes the active locale via the `REPORT_LOCALE` parameter — do not add your own locale switch in the template.
- Use `$F{}` for data, `$R{}` for labels, `$P{}` for parameters. Don't mix these up.

## Japanese fonts

Japanese (CJK) text needs an **embedded CJK font** or the PDF renders blank/garbled. Use the fonts registered through the JasperReports font extension (`src/main/resources/fonts/fonts.xml` + `jasperreports_extension.properties`) and reference them **by family name** (e.g. `fontName="MS Gothic"` / `"MS Mincho"`) — those already map to the bundled TTFs. Don't hardcode an absolute font-file path, and don't use a font that isn't registered there.

## Subreports

When a report composes subreports:

- Reference the **compiled** artifact, never the source: `subreportExpression = $P{SUBREPORT_DIR} + "<name>.jasper"` (note `.jasper`). Building the name dynamically from a parameter is allowed.
- Feed data with `dataSourceExpression = $P{…}` — a `net.sf.jasperreports.engine.JRDataSource` parameter the service supplies; don't query inside the subreport.
- The service compiles the subreports to a temp dir and supplies `SUBREPORT_DIR` + the data-source parameters at fill time. **Ignore the Jaspersoft Studio default path** baked into `SUBREPORT_DIR`'s `defaultValueExpression` — it's a local authoring convenience, always overridden at runtime; never commit a machine-specific path as anything but that default.

## Page breaks

To break each logical document (slip/order) onto a new page, add `<group … startNewPage="true">` keyed on the grouping field, and keep that key consistent with the order the service feeds rows. Note: some reports are paginated by the service instead (it fills and merges one print per group) — check how the report is driven before relying on a group for page breaks.

## Parameters

- Locale comes from the service as a `java.util.Locale` (`REPORT_LOCALE`); don't switch locale in the template.
- A report with subreports receives `SUBREPORT_DIR` (`String`) plus one `JRDataSource` parameter per subreport.
- Any other parameter is report-specific — declare each `<parameter>` you reference (correct `class`) and let the service supply its value.

## Checklist when adding / changing a report

1. Declare `<parameter>` / `<field>` (correct `class`); set `resourceBundle` if the report has its own labels.
2. Add every new `$R{}` key to all `messages*.properties` locale variants.
3. Apply a CJK-capable font (per **Japanese fonts** above) to any element that may hold Japanese.
4. For subreports: reference the `.jasper` via `SUBREPORT_DIR`, and feed each via a `JRDataSource` parameter.
5. Mirror every field in the service's row-map, and make sure the service loads and compiles the template.
