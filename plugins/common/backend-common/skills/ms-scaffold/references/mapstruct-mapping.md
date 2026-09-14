# MapStruct mapping rules

Applies to: `**/infrastructure/mapping/**/*.java`

Mappers convert between **persistence entities / domain objects** and **gRPC (protobuf) messages** (source: cm-be-ms-core, in `infrastructure/mapping/core/<domain>`), or between **this service's gRPC messages** and **the downstream `{targetMicroservice}` gRPC messages** (source: cm-be-ms-owner, in `infrastructure/mapping`). They are the only place that conversion logic lives — services and gRPC impls should call a mapper, not map by hand. (source: cm-be-ms-core; cm-be-ms-owner adds: a simple response may still be assembled with the message builder directly)

The sources disagree on `BaseMapping` and on when the optional header attributes are present. Each rule is kept as a named variant, selected by the repository `CLAUDE.md` `## Policies` → `mapstruct-base`. If it is not set, ask the user.

## Mapper declaration

Mappers are Spring-component **interfaces**. The standard header is:

```java
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface CoreXxxServiceMapping extends BaseMapping { ... }
```

- `componentModel = "spring"` (always) — mappers are injected as Spring beans.

### Variant `base-mapping` (source: cm-be-ms-core)

- `collectionMappingStrategy = ADDER_PREFERRED` is for mapping gRPC `repeated` fields; a mapper with no collection fields may drop it (and `nullValueCheckStrategy`) — some do.
- **Extend `BaseMapping`** (`infrastructure/mapping/core/fw/BaseMapping`) only when you reuse a conversion it defines (about a third of mappers do); the rest are plain `@Mapper` interfaces. Don't re-implement a conversion `BaseMapping` already provides.

### Variant `flat` (source: cm-be-ms-owner)

Standard `@Mapper` header — the first three attributes are always present; add `collectionMappingStrategy = ADDER_PREFERRED` **only when the mapper handles gRPC `repeated`/collection fields**:

```java
@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED // add only with repeated/collection fields
)
public interface [Domain]GrpcMapping { ... }
```

- These mappers are **flat interfaces** (this service has no `BaseMapping`; don't add an `extends BaseMapping`).
- Name methods by direction: `to{TargetPascal}Request(...)` for this service→`{targetMicroservice}`, `to{ServicePascal}Response(Grpc{TargetPascal}…SuccessResponse)` for `{targetMicroservice}`→this service. Map only the directions a use case needs (a write path may map just the request and assemble its response elsewhere). A method may take extra scalar args, e.g. `to{TargetPascal}Request(item, companyCd)`.

## Field mapping

- Use `@Mapping(target = "...", source = "...")` for every renamed field. Names that differ between entity and proto (e.g. `unit1` ↔ `unit1Qty`) must be mapped explicitly; relying on accidental name matches is a common bug.
- **gRPC `repeated` fields**: protobuf exposes a `repeated foo` as `getFooList()` / `addFoo(...)`. With `collectionMappingStrategy = ADDER_PREFERRED`, map the source collection straight to the logical name — `@Mapping(target = "details", source = "soDetails")` — and MapStruct uses the generated adder. Don't target `...List` yourself.
- Nested message/item conversions get their own mapper method (e.g. `toAdvancedItem(SoEntity)`, `toAdvancedItemDetail(SoDetailEntity)`); MapStruct wires lists to them automatically.

## Custom & default conversions (source: cm-be-ms-core)

- For value transforms (formatting timestamps, enums, etc.) add a `default` method annotated `@Named("...")` and reference it with `@Mapping(..., qualifiedByName = "...")`. Example: `localDateTimeToExclusionCheckString` formats `exclusioncheck` as `yyyyMMddHHmmssSSS`.
- Plain structural conversions with no protobuf builder (e.g. metadata → `GrpcCommonPaginationMetadata`) can be `default` methods that build the message directly.

## Reminders

- Don't put business logic in mappers — only shape/convert data.
- `com.fw.grpc.*` message types come from internal jars; never stub them. Generated mapper impls land in `target/generated-sources` — never hand-edit them.
