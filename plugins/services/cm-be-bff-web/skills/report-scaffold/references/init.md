# Report feature — initial creation (JasperReports)

Generate a **report (帳票) feature** — the report-specific layer only. For the standard BFF scaffolding, follow the **`backend-common:bff-scaffold` skill**; for `.jrxml` rules, see **`jrxml.md`**.

## Inputs to collect first

Ask for these before generating (mark anything unknown as `要確認` (to-be-confirmed); do not invent):

1. **機能ID + 機能名 (feature ID + name)** (e.g. `bw-001-030-xxx` / "出荷作業用帳票出力") → drives class names via the naming convention in the repository `CLAUDE.md`.
2. **データ取得元 (data source)**: target microservice + gRPC method that returns the report rows.
3. **フィールド一覧 (field list)**: each report field + its Java type (String / `BigDecimal` for money / `byte[]` for images).
4. **出力形式 (output format)**: PDF download, Base64 `jrprint` (for the external print services), data-only JSON — or a combination.
5. **単票 or 複数票 (single or multi-document)**: single template, or grouped multi-document with a **group key** (page break per document)?
6. **サブレポート (subreports)**: standalone report, or a main report composing subreports?
7. **多言語 (localization)**: which locales must the service handle (it passes `REPORT_LOCALE`)? Label text and `messages*.properties` are out of scope.

## Data flow

```
Controller (PDF / Base64 / data)         ← this skill
  → Service impl  (toXxxRow → JRMapCollectionDataSource → JasperFillManager → export)   ← this skill
      → gRPC client → microservice (report data)        ← backend-common:bff-scaffold skill pattern
  uses: .jrxml template (compiled & cached @PostConstruct)   ← do NOT generate (jrxml.md)
```

## Files involved

### 1. Controller (`controller/core/<domain>/...Controller.java`)

Implement the generated `*Api` — **no logic**, one method per output format:

- **PDF download** — `ResponseEntity<Resource>`:

  ```java
  byte[] pdf = service.printXxx(request);

  return ResponseEntity.ok()
    .contentType(MediaType.APPLICATION_PDF)
    .header(HttpHeaders.CONTENT_DISPOSITION, ContentDisposition.attachment().filename("xxx.pdf").build().toString())
    .body(new ByteArrayResource(pdf));
  ```

- **Base64 `jrprint`** (local/external print service) — `ResponseEntity<byte[]>`, wrap the Base64 string in JSON quotes and return as `APPLICATION_JSON` (the generated client parses JSON):

  ```java
  String base64 = service.printXxxBinary(request);

  return ResponseEntity.ok()
    .contentType(MediaType.APPLICATION_JSON)
    .body(("\"" + base64 + "\"").getBytes(StandardCharsets.UTF_8));
  ```

- **Data only** — return the response DTO via `ResponseEntity.ok(service.getXxxData(request))`.

### 2. Service interface + impl (`service/core/<domain>/...Service[Impl].java`)

In the `*Impl`:

- **Inject the template path** with `@Value("${report.template.xxx:/reports/core/<domain>/XXX.jrxml}")` — add a second `@Value` for the subreport base path if needed.
- **Compile once and cache:** in `@PostConstruct init()`, compile the template into a `JasperReport` field; throw `IllegalStateException` if the resource is missing; never compile per request.
  ```java
  try (InputStream is = getClass().getResourceAsStream(templatePath)) {
    if (is == null) throw new IllegalStateException("template not found: " + templatePath);
    this.cachedReport = JasperCompileManager.compileReport(is);
  }
  ```
- **Subreports**: in `init()`, copy each subreport `.jrxml` to a temp dir, `JasperCompileManager.compileReportToFile(...)` to `.jasper`, and remember the temp dir as `SUBREPORT_DIR`.
- **Row mapping `toXxxRow(dto) → Map<String,Object>`**: keys must be **byte-identical** to the `.jrxml` `<field name>` (see `jrxml.md`; follow the report family's key style). Money → `BigDecimal`, images → `byte[]`.
- **Fill & export**:
  - Build `new JRMapCollectionDataSource(rows)`.
  - Params: `REPORT_LOCALE` (map the request locale enum via a `toLocale()` helper, default `Locale.JAPANESE`).
  - PDF: `JasperExportManager.exportReportToPdf(JasperFillManager.fillReport(report, params, ds))`.
  - `jrprint`: `JRSaver.saveObject(jasperPrint, baos)` → `Base64.getEncoder().encodeToString(...)`.
- **Multi-document (group + page break)**: group rows by the group key (`LinkedHashMap` to keep order), fill one `JasperPrint` per group, merge into one PDF:

  ```java
  JRPdfExporter exporter = new JRPdfExporter();

  exporter.setExporterInput(SimpleExporterInput.getInstance(prints));

  exporter.setExporterOutput(new SimpleOutputStreamExporterOutput(baos));

  exporter.exportReport();
  ```

- Override `companyCd` from `HttpRequestContextHolder.getContext().getUser()` before calling gRPC.

### 3. gRPC client + ServiceMapping

Follow the **`backend-common:bff-scaffold` skill** for the gRPC client (`*Client`/`*ClientImpl`) and `*ServiceMapping`. Nothing report-specific here.

### 4. Config (if a new template property is introduced)

Add `report.template.xxx` defaults under the relevant `application-*.yml` only if you didn't inline the default in the `@Value`.

## Completion checklist

1. Controller endpoint(s) per chosen output format (PDF / Base64 / data), correct content-type & filename.
2. Service impl: `@Value` template path, `@PostConstruct` compile+cache, `toXxxRow` keys match `.jrxml` fields, fill+export, locale + companyCd handling.
3. (Subreports) compiled to temp dir, `SUBREPORT_DIR` + a `JRDataSource` per subreport supplied.
4. (Multi-doc) grouped fill + `JRPdfExporter` merge.
5. gRPC client + ServiceMapping per `backend-common:bff-scaffold` skill.
