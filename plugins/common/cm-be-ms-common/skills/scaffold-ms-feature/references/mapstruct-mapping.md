# MapStruct mapping rules

Applies to: `**/infrastructure/mapping/**/*.java`

Mappers convert between **persistence entities / domain objects** and **gRPC (protobuf) messages** (in `infrastructure/mapping/core/<domain>`), or between **this service's gRPC messages** and **the downstream `{targetMicroservice}` gRPC messages** (in `infrastructure/mapping`). They are the only place that conversion logic lives — services and gRPC impls should call a mapper, not map by hand. A simple response may still be assembled with the message builder directly.

Follow the `@Mapper` header the existing mapping classes of this repository use.

## Mapper declaration

Mappers are Spring-component **interfaces**. The standard header is:

```java
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [Domain]GrpcMapping { ... }
```

- `componentModel = "spring"` (always) — mappers are injected as Spring beans.
- The first three attributes are always present. Add `collectionMappingStrategy = ADDER_PREFERRED` **only when the mapper handles gRPC `repeated`/collection fields**; a mapper with no collection fields may also drop `nullValueCheckStrategy`.
- Mappers are **flat interfaces**. Where a repository has a shared mapping interface that a mapper reuses conversions from, extend it rather than re-implementing those conversions; otherwise don't introduce one.
- Name methods by direction: `to{TargetPascal}Request(...)` for this service→`{targetMicroservice}`, `to{ServicePascal}Response(Grpc{TargetPascal}…SuccessResponse)` for `{targetMicroservice}`→this service. Map only the directions a use case needs (a write path may map just the request and assemble its response elsewhere). A method may take extra scalar args, e.g. `to{TargetPascal}Request(item, companyCd)`.

## Field mapping

- Use `@Mapping(target = "...", source = "...")` for every renamed field. Names that differ between entity and proto (e.g. `unit1` ↔ `unit1Qty`) must be mapped explicitly; relying on accidental name matches is a common bug.
- **gRPC `repeated` fields**: protobuf exposes a `repeated foo` as `getFooList()` / `addFoo(...)`. With `collectionMappingStrategy = ADDER_PREFERRED`, map the source collection straight to the logical name — `@Mapping(target = "details", source = "soDetails")` — and MapStruct uses the generated adder. Don't target `...List` yourself.
- Nested message/item conversions get their own mapper method (e.g. `toAdvancedItem(SoEntity)`, `toAdvancedItemDetail(SoDetailEntity)`); MapStruct wires lists to them automatically.

## Custom & default conversions

- For value transforms (formatting timestamps, enums, etc.) add a `default` method annotated `@Named("...")` and reference it with `@Mapping(..., qualifiedByName = "...")`. Example: `localDateTimeToExclusionCheckString` formats `exclusioncheck` as `yyyyMMddHHmmssSSS`.
- Plain structural conversions with no protobuf builder (e.g. metadata → `GrpcCommonPaginationMetadata`) can be `default` methods that build the message directly.

## Reminders

- Don't put business logic in mappers — only shape/convert data.
- `com.cm.grpc.*` message types come from the `cm-be-spec` jar; never stub them. Generated mapper impls land under `build/generated/` — never hand-edit them.
