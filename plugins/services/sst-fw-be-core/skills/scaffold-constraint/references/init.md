# Validation constraint — initial creation (sst-fw-be-core)

This scaffolds a custom Bean Validation constraint. A constraint is always the **same
four-part skeleton** — annotation + validator + example + message keys — only the check
logic and members are bespoke. The rules in
`validation-constraint.md` (applies to `**/validation/**/*.java`)
apply throughout.

> **Out of scope:** tests; service-specific logic (keep `sst-fw-be-core` generic). **Packages:**
> annotation → `com.fw.core.validation.constraint`, validator →
> `com.fw.core.validation.validator`, example → `com.fw.core.validation.example`.

## Inputs to collect first

Ask; mark unknowns as "needs confirmation / 要確認" (don't invent):

1. **Constraint name** `<Name>` and what it validates.
2. **Target type(s)**: `String`, a temporal type (`LocalDate`/`LocalDateTime`/…), or class-level (multi-field).
3. **Members**: e.g. `formats()`, `min`/`max`, or the compared field names for a class-level constraint.
4. **Error code** (an `ErrorCodeEnum` key, `EB-…`) for `message()` + the parameterized message text.
5. Is it a **new** constraint or an **extension of a standard** (JDK/Spring) constraint (same-name pass-through)?

## Files

```
src/main/java/com/scm/core/validation/
├─ constraint/<Name>.java            ← ① annotation
├─ validator/<Name>Validator.java    ← ② validator
└─ example/<Name>Example.java        ← ③ reference DTO (or add to a shared *ValidationExample)
src/main/resources/
├─ messages.properties               ← ④ add the error-code key (parameterized)
└─ messages-ja-jp.properties         ← ④ ja translation of the same key
```

---

## Templates

### ① Annotation — `constraint/<Name>.java`

`@Documented`, `@Constraint(validatedBy = <Name>Validator.class)`, the standard targets +
`RUNTIME` retention. `message()` defaults to an **`ErrorCodeEnum` key**, never literal text.
Add any constraint-specific members. Bilingual Javadoc (English + `<p>バリデーション > …`)
with `@return` per member, `@since`, `@author SCM Development Team`.

```java
package com.fw.core.validation.constraint;

/**
 * Custom validation annotation for <what it validates>.
 *
 * <p>バリデーション > <カテゴリ> > <説明>
 */
@Documented
@Constraint(validatedBy = <Name>Validator.class)
@Target({ ElementType.FIELD, ElementType.METHOD, ElementType.PARAMETER, ElementType.ANNOTATION_TYPE })
@Retention(RetentionPolicy.RUNTIME)
public @interface <Name> {

    /** Default error message. @return error message */
    String message() default "EB-001-XXX-XXX-XXX";   // an ErrorCodeEnum key

    /** Validation groups. @return groups */
    Class<?>[] groups() default {};

    /** Payload for additional metadata. @return payload */
    Class<? extends Payload>[] payload() default {};

    // constraint-specific members, e.g.:
    // /** Allowed formats. @return patterns */
    // String[] formats() default { "yyyyMMdd", "yyyy/MM/dd" };
}
```

**Extending a standard constraint** instead (same simple name + meta-annotate with the
original, `validatedBy = {}`):

```java
@Documented
@Constraint(validatedBy = {})
@Target({ ElementType.METHOD, ElementType.FIELD, ElementType.ANNOTATION_TYPE,
          ElementType.CONSTRUCTOR, ElementType.PARAMETER, ElementType.TYPE_USE })
@Retention(RetentionPolicy.RUNTIME)
@jakarta.validation.constraints.NotBlank
public @interface NotBlank {}
```

**Class-level (multi-field)**: target the type and name the compared fields, e.g.
`@ChronologicalDates(startField = "…", endField = "…")`.

### ② Validator — `validator/<Name>Validator.java`

`implements ConstraintValidator<<Name>, T>` (use `Object` if it must accept several types).
Read members in `initialize(...)`; **return `true` for null / blank** (combine with
`@NotNull`/`@NotBlank` when presence is required) using `StringUtils.hasText(...)`; implement
the check null-safely. The bespoke validation logic goes in `isValid` — keep it generic
(no service-specific rules).

```java
package com.fw.core.validation.validator;

public class <Name>Validator implements ConstraintValidator<<Name>, String> {

    private /* members */ ;

    @Override
    public void initialize(<Name> constraintAnnotation) {
        // this.xxx = constraintAnnotation.xxx();
    }

    @Override
    public boolean isValid(String value, ConstraintValidatorContext context) {
        if (!StringUtils.hasText(value)) {
            return true;   // null/blank handled by @NotNull/@NotBlank
        }
        // bespoke check → return true/false
        return /* ... */;
    }
}
```

### ③ Example — `example/<Name>Example.java`

A reference DTO showing the constraint applied (composed with `@NotNull`/`@NotBlank` when
presence is required), or add a field to the matching `*ValidationExample` (date / string /
number / time).

```java
package com.fw.core.validation.example;

@Data
public class <Name>Example {
    @<Name>
    private String field;
}
```

### ④ Messages — `messages.properties` (+ `messages-ja-jp.properties`)

Add the `message()` error-code key to **both** files, in parameterized form (e.g. `{1}`):

```properties
# messages.properties
EB-001-XXX-XXX-XXX=Value not satisfying <rule> {1}
# messages-ja-jp.properties
EB-001-XXX-XXX-XXX=<日本語メッセージ> {1}
```

## Completion checklist

1. Annotation: `@Constraint(validatedBy = <Name>Validator.class)`, correct targets/retention, `message()` references an `ErrorCodeEnum` key, members documented.
2. Validator: `ConstraintValidator`, **true for null/blank**, null-safe, members read in `initialize`; bespoke check generic (no service logic).
3. Example DTO demonstrates usage (+ composition with `@NotNull`/`@NotBlank`).
4. Message key added in **both** `.properties` files (parameterized).
5. Javadoc bilingual (`@since`, `@author SCM Development Team`); **no tests generated**.
