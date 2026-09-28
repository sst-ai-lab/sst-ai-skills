# OpenAPI Creation Claude Instructions（OpenAPI作成 Claude指示書）

This document defines the rules that AI Agents/Claude MUST follow when creating OpenAPI specifications.

Applies to: `**/src/openapi/**/*`

## 1. Strict Rule Enforcement

### 1.1 Cancellation Conditions

**If ANY of the following are detected, implementation MUST be stopped and corrections MUST be requested:**

- [ ] Major Feature Class（機能大分類）is not in the predefined list
- [ ] Mid-level Feature Class（機能中分類）code is not `001`, `002`, or `100~999`
- [ ] Minor Feature Class（機能小分類）code is not in the [Predefined Code List](#6-predefined-code-list)
- [ ] Parameters are hardcoded instead of using `$ref`
- [ ] HTTP method is not POST
- [ ] Query parameters are used
- [ ] operationId is not globally unique (potential duplication)
- [ ] Attempting to proceed without schema files existing
- [ ] Contains `api/` in path or filename

**→ When these are detected, explicitly state "Correction Required" and STOP**

---

## 2. Hierarchical Structure Validation

### 2.1 Function ID（機能ID）Structure (Required)

```
[Environment（環境）] + [Major Class（機能大分類）] + [Mid Class（機能中分類）] + [Minor Class（機能小分類）] + [Sequential Number（機能連番）]

Example: b  w  - 001 - 030 - 001
         ↓  ↓    ↓      ↓     ↓
    Backend Web  Core Receiving 1st feature

→ Combined: bw-001-030-001
```

**Validation Rules:**

- **Environment（環境）**: `b` (Backend) or `f` (Frontend)
- **Major Class（機能大分類）**: `w` (Web), `m` (Mobile), `r` (Report), `e` (EDI), `c` (Common), `b` (Batch), `a` (API)
- **Mid-level Class（機能中分類）**: `001` (Core) or `002` (Optional) or `100~999` (Local)
- **Minor Class（機能小分類）**: [Select from predefined codes below](#6-predefined-code-list)
- **Sequential Number（機能連番）**: 3-digit sequence (`001`, `002`, `003`, ...)

**Checklist:**

- [ ] All 5 elements of Function ID（機能ID）are present
- [ ] Hyphen-separated format: `[環境][機能大分類]-[機能中分類]-[機能小分類]-[機能連番]` (example: `bw-001-030-001`)
- [ ] Correct digit count for each element (環境:1, 機能大分類:1, 機能中分類:3, 機能小分類:3, 機能連番:3)

### 2.2 Environment and Major Feature Classification

**Environment Code（環境コード）:**

| Code | Name     | Description |
| ---- | -------- | ----------- |
| f    | Frontend | frontend    |
| b    | Backend  | backend     |

**Major Feature Classification（機能大分類）:**

| Code | Name   | Description         |
| ---- | ------ | ------------------- |
| w    | Web    | Web application     |
| m    | Mobile | Mobile app          |
| r    | Report | Report              |
| e    | EDI    | Data exchange       |
| c    | Common | Common/Shared       |
| b    | Batch  | Batch jobs          |
| a    | API    | External public API |

**Combined Function ID prefix = Environment + Major Class** (e.g., `fw` = Frontend + Web, `bw` = Backend + Web)

**Checklist:**

- [ ] Environment code exists in the above list
- [ ] Major Feature Class（機能大分類）exists in the above list
- [ ] Both BFF and gRPC implementations follow the same structural rules
- [ ] External API（a）routes through BFF first, then to gRPC backend

---

## 3. File Structure "MUST" Rules

### 3.1 BFF API File Structure

```
cm-be-spec/src/openapi/
├── paths/bff/v1/
│   └── [Major Class（機能大分類）]/         ← W_Web, M_モバイル etc.
│       └── [Mid Class（機能中分類）]/       ← 001_core, 002_option etc.
│           └── [Minor Class（機能小分類）]/ ← 030_rcv, 040_so etc.
│               └── [Seq（機能連番）]_[Feature Name].yml  ← 001_rcvPlanSearch.yml
│
├── components/bff/v1/
│   └── [Major Class（機能大分類）]/
│       ├── requests/
│       │   └── [Mid Class（機能中分類）]/
│       │       └── [Minor Class（機能小分類）]/
│       │           └── [Seq（機能連番）]_[Feature Name]/
│       │               ├── 01_[Parameter Name].yml
│       │               └── 02_[Parameter Name].yml
│       └── responses/
│           └── [Mid Class（機能中分類）]/
│               └── [Minor Class（機能小分類）]/
│                   └── [Seq（機能連番）]_[Feature Name]/
│                       ├── 01_[Parameter Name].yml
│                       └── 02_[Parameter Name].yml
└── bffWeb.yml                            ← Integrated BFF API definition
```

**Mandatory Checklist:**

- [ ] Folder names follow format: `code_name`
- [ ] Minor Class（機能小分類）folder exists
- [ ] API filename includes Sequential Number（機能連番）
- [ ] requests/responses folders are separated
- [ ] Parameter files are numbered (01_header, 02_detail, etc.)

### 3.2 gRPC API File Structure

```
cm-be-spec/src/openapi/
├── paths/grpc/v1/
│   └── [Major Class（機能大分類）]/
│       └── [Mid Class（機能中分類）]/
│           └── [Minor Class（機能小分類）]/
│               └── [Seq（機能連番）]_[Feature Name].yml
│
├── components/grpc/v1/
│   └── [Major Class（機能大分類）]/
│       ├── requests/
│       │   └── [Mid Class（機能中分類）]/...
│       └── responses/
│           └── [Mid Class（機能中分類）]/...
└── msGrpc.yml                            ← Integrated gRPC API definition
```

**Mandatory Checklist:**

- [ ] Same hierarchical structure as BFF
- [ ] Under grpc/v1 directory
- [ ] Both bff and components are defined

---

## 4. API Definition "MUST" Rules

### 4.1 BFF Endpoint Definition

| Item            | Rule                                                                                                                                            | Example                                                                       |
| --------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| **Path Format** | `/v1/[Major（機能大分類）]/[Mid（機能中分類）]/[Minor（機能小分類）]/[Feature Name]/[API Name]`                                                 | `/v1/web/core/rcv/rcvPlanSearch/searchHeader`                                 |
| **Uppercase**   | **Forbidden - all lowercase**                                                                                                                   | ❌ `/v1/Web/Core` → ✓ `/v1/web/core`                                          |
| **Method**      | **POST only**                                                                                                                                   | `post:`                                                                       |
| **operationId** | `[Major（機能大分類）][Mid（機能中分類）][Minor（機能小分類）][Feature Name][API]` + **camelCase** + **globally unique**                        | `webCoreRcvRcvPlanSearchSearchHeader`                                         |
| **Request**     | **MUST use `$ref`** - No hardcoding                                                                                                             | ✓ `$ref: ".../requests/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"`  |
| **Response**    | **MUST use `$ref`** - No hardcoding                                                                                                             | ✓ `$ref: ".../responses/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"` |
| **Tags**        | Format: `[Major（機能大分類）] / [Mid（機能中分類）] / [Minor（機能小分類）] / [Feature Name（機能名）]` + **Add tag definition to bffWeb.yml** | `Web / Core / Rcv / RcvSearch`                                                |
| **Summary**     | `[Function ID（機能ID）]_[Feature Name]_[API Name]`                                                                                             | `001_入荷予定検索_入荷予定ヘッダ検索`                                         |

**Mandatory Checklist:**

```yaml
paths:
  "/v1/web/core/rcv/rcvPlanSearch/searchHeader":
    post:
      summary: "001_入荷予定検索_入荷予定ヘッダ検索"
      description: "入荷予定ヘッダの検索を行います。"
      operationId: "webCoreRcvRcvPlanSearchSearchHeader" # ← Verify globally unique
      tags:
        - "Web / Core / Rcv / RcvSearch"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "../../../../../../components/bff/v1/W_Web/requests/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"
      responses:
        "200":
          description: "Success"
          content:
            application/json:
              schema:
                $ref: "../../../../../../components/bff/v1/W_Web/responses/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"
```

**Validation Items:**

- [ ] No uppercase in path
- [ ] operationId is unique camelCase
- [ ] `$ref` path exists (relative path accuracy)
- [ ] Tag format is "Major / Mid / Minor / FeatureName" (e.g., `Web / Core / Rcv / RcvSearch`)
- [ ] Request/Response uses `$ref`, not hardcoded

### 4.2 gRPC Method Definition

| Item                 | Rule                                                                                                                                            | Example                                  |
| -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------- |
| **Path Format**      | `/[Method Name]` (method name only)                                                                                                             | `/SearchHeader`                          |
| **Uppercase**        | PascalCase (first letter uppercase)                                                                                                             | ✓ `/SearchHeader` ❌ `/searchheader`     |
| **Method**           | **POST only**                                                                                                                                   | `post:`                                  |
| **operationId**      | **File-unique** + **Same as path name**                                                                                                         | `SearchHeader`                           |
| **Request/Response** | **MUST use `$ref`** - No hardcoding                                                                                                             | `$ref: ".../requests/.../01_header.yml"` |
| **Tags**             | Format: `[Major（機能大分類）] / [Mid（機能中分類）] / [Minor（機能小分類）] / [Feature Name（機能名）]` + **Add tag definition to msGrpc.yml** | `Web / Core / Rcv / RcvSearch`           |

**Mandatory Checklist:**

```yaml
paths:
  "/SearchHeader":
    post:
      summary: "001_入荷予定検索_入荷予定ヘッダ検索"
      description: "入荷予定ヘッダの検索を行います。"
      operationId: "SearchHeader" # ← パス名と同じになっているか
      tags:
        - "Web / Core / Rcv / RcvSearch"
      requestBody:
        content:
          application/json:
            schema:
              $ref: "../../../../../../components/grpc/v1/W_Web/requests/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"
      responses:
        "200":
          description: "Success"
          content:
            application/json:
              schema:
                $ref: "../../../../../../components/grpc/v1/W_Web/responses/001_core/030_rcv/001_rcvPlanSearch/01_rcvHeader.yml"
```

**Validation Items:**

- [ ] operationId is file-unique
- [ ] operationId is same as path name
- [ ] Path name is PascalCase
- [ ] `$ref` path points to grpc directory

---

## 5. Schema Definition "MUST" Rules

### 5.1 Single Structure Schema

```yaml
title: "webCoreRcvRcvPlanSearchRcvHeaderRequests" # ← camelCase
description: "入荷予定検索条件パラメータ"
type: "object"
required:
  - "ownerCd"
  - "warehouseCd"
properties:
  ownerCd:
    type: "string"
    maxLength: 10
    description: "取引先コード"
    example: "123456789"
  warehouseCd:
    type: "string"
    maxLength: 10
    description: "倉庫コード"
    example: "H999"
  rcvSchDateFrom:
    type: "string"
    maxLength: 8
    description: "入荷予定日"
    example: "20260202"
```

**Mandatory Checklist:**

- [ ] `title` follows `[Major（機能大分類）][Mid（機能中分類）][Minor（機能小分類）][Feature Name](Requests|Responses)` format
- [ ] `type: object` is defined
- [ ] Required items are defined in `required` array
- [ ] Each property has `description`
- [ ] Each property has `example`
- [ ] Each string property has `maxLength`

### 5.2 Composite Structure Schema（Example: Header/Detail）

When a feature requires nested structures (e.g., header + detail), use multiple schema files:

```yaml
title: "webCoreRcvRcvPlanSearchRcvHeaderResponses"
description: "入荷予定ヘッダ結果レスポンス"
type: "object"
properties:
  ownerCd:
    type: "string"
    maxLength: 10
    description: "取引先コード"
    example: "123456789"
  detail:
    $ref: "./02_rcvDetail.yml" # ← Relative path $ref
```

**Mandatory Checklist:**

- [ ] Parent and child schemas are in separate files
- [ ] Parent schema references child via appropriate field
- [ ] `$ref` uses relative path
- [ ] All fields have `description`
- [ ] All string properties have `maxLength`

### 5.3 Data Type "MUST" Rules

| Data Type                 | OpenAPI type | format    | Example                                                          |
| ------------------------- | ------------ | --------- | ---------------------------------------------------------------- |
| String                    | `string`     | -         | `type: "string"` + `maxLength: 10`                               |
| Date (YYYYMMDD)           | `string`     | -         | `type: "string"` + `maxLength: 8` + `example: "20260202"`        |
| DateTime (YYYYMMDDHHMMSS) | `string`     | -         | `type: "string"` + `maxLength: 14` + `example: "20260202103000"` |
| Time (HHMMSS)             | `string`     | -         | `type: "string"` + `maxLength: 6` + `example: "103000"`          |
| Integer                   | `integer`    | `int32`   | `type: "integer", format: "int32"`                               |
| Long Integer              | `integer`    | `int64`   | `type: "integer", format: "int64"`                               |
| Decimal                   | `number`     | `decimal` | `type: "number", format: "decimal"` + `multipleOf: 0.01`         |
| Boolean                   | `boolean`    | -         | `type: "boolean"`                                                |
| Array                     | `array`      | -         | Define with `$ref` (no hardcoding)                               |

**Mandatory Checklist:**

- [ ] format is specified (for integer, number)
- [ ] Date/DateTime format is `YYYYMMDD` or `YYYYMMDDHHMMSS`
- [ ] integer example is **numeric not string** (`100` ≠ `"100"`)
- [ ] All properties have `example`
- [ ] All string properties have `maxLength`
- [ ] Decimal properties use `format: decimal` and `multipleOf` for precision

---

## 6. Predefined Code List

### 6.1 Major Feature Classification（機能大分類）

| Code | Name   |
| ---- | ------ |
| w    | Web    |
| m    | Mobile |
| r    | Report |
| e    | EDI    |
| c    | Common |
| b    | Batch  |
| a    | API    |

### 6.2 Mid-level Feature Classification（機能中分類）

| Code    | Name     | Description                   |
| ------- | -------- | ----------------------------- |
| 001     | Core     | Standard features             |
| 002     | Optional | Additional features           |
| 100-999 | Local    | Client-specific customization |

### 6.3 Minor Feature Classification（機能小分類）Required

| Code | Name         | Abbreviation | Description                  |
| ---- | ------------ | ------------ | ---------------------------- |
| 000  | FW           | fw           | Framework utilities          |
| 010  | Common       | common       | Common/General operations    |
| 020  | Master       | master       | Master data management       |
| 030  | Receiving    | rcv          | Receiving/Inbound            |
| 040  | Shipping     | so           | Shipping Order               |
| 050  | Order Mgmt   | order        | Order Management             |
| 060  | Inventory    | inv          | Inventory Management         |
| 070  | Billing      | billcalc     | Billing/Invoicing            |
| 080  | Freight      | carrycalc    | Freight/Shipping costs       |
| 090  | Stock Taking | stks         | Stock Taking/Inventory count |
| 100  | Delivery     | tms          | Delivery/Distribution        |
| 110  | Bonded       | hozei        | Bonded warehouse             |
| 120  | ABL          | abl          | Asset-Based Lending          |
| 130  | BI           | bi           | Business Intelligence        |

**Check Rules:**

- [ ] Minor Class（機能小分類）code being used exists in this list
- [ ] When adding new Minor Class（機能小分類）, consult non-functional team

---

## 7. $ref Path "MUST" Rules

### 7.1 BFF $ref Path

**Request Schema:**

```
$ref: "../../../../../../components/bff/v1/[Major（機能大分類）]/requests/[Mid（機能中分類）]/[Minor（機能小分類）]/[Seq（機能連番）]_[Feature Name]/[Seq]_[Parameter Name].yml"
```

**Response Schema:**

```
$ref: "../../../../../../components/bff/v1/[Major（機能大分類）]/responses/[Mid（機能中分類）]/[Minor（機能小分類）]/[Seq（機能連番）]_[Feature Name]/[Seq]_[Parameter Name].yml"
```

### 7.2 gRPC $ref Path

**Request Schema:**

```
$ref: "../../../../../../components/grpc/v1/[Major（機能大分類）]/requests/[Mid（機能中分類）]/[Minor（機能小分類）]/[Seq（機能連番）]_[Feature Name]/[Seq]_[Parameter Name].yml"
```

**Response Schema:**

```
$ref: "../../../../../../components/grpc/v1/[Major（機能大分類）]/responses/[Mid（機能中分類）]/[Minor（機能小分類）]/[Seq（機能連番）]_[Feature Name]/[Seq]_[Parameter Name].yml"
```

**Validation Checklist:**

- [ ] Correct number of `../` (6 levels = `../` ×6)
- [ ] Correct whether `bff` or `grpc`
- [ ] Correct `requests` or `responses` directory
- [ ] File path actually exists
- [ ] File extension is `.yml` (not `.yaml`)

---

## 8. Integration Definition File "MUST" Rules

### 8.1 bffWeb.yml

```yaml
paths:
  /v1/web/core/rcv/rcvPlanSearch/searchHeader:
    $ref: "./paths/bff/v1/W_Web/001_core/030_rcv/001_rcvPlanSearch.yml#/paths/~1v1~1web~1core~1rcv~1rcvPlanSearch~1searchHeader"
  /v1/web/core/rcv/rcvPlanSearch/searchDetail:
    $ref: "./paths/bff/v1/W_Web/001_core/030_rcv/001_rcvPlanSearch.yml#/paths/~1v1~1web~1core~1rcv~1rcvPlanSearch~1searchDetail"
```

**Mandatory Checklist:**

- [ ] All endpoint paths are lowercase (not uppercase)
- [ ] References YAML internal paths with `#/paths/`
- [ ] `/` symbols converted to `~1`
- [ ] File references use `./paths/bff/v1/...` consistently

### 8.2 msGrpc.yml

```yaml
paths:
  /v1.web.core.service.RcvPlanSearchService/SearchHeader:
    $ref: "./paths/grpc/v1/W_Web/001_core/030_rcv/001_rcvPlanSearch.yml#/paths/~1SearchHeader"
  /v1.web.core.service.RcvPlanSearchService/SearchDetail:
    $ref: "./paths/grpc/v1/W_Web/001_core/030_rcv/001_rcvPlanSearch.yml#/paths/~1SearchDetail"
```

**Mandatory Checklist:**

- [ ] gRPC service path format is correct (`/[version].[Major].[Mid].service.[ServiceName]/[MethodName]`)
- [ ] Method name is PascalCase
- [ ] References with `#/paths/`
- [ ] File references use `./paths/grpc/v1/...`

---

## 9. Implementation Flow "MUST" Sequence

**AI agents MUST strictly follow this sequence when implementing:**

1. **Function ID（機能ID）Validation**
   - [ ] Function ID（機能ID）format is correct (bw-001-030-001)
   - [ ] Minor Class（機能小分類）exists in predefined list

2. **Directory Structure Confirmation**
   - [ ] Major Class（機能大分類）folder exists (W_Web, M_Mobile etc.)
   - [ ] Mid Class（機能中分類）folder exists (001_core etc.)
   - [ ] Minor Class（機能小分類）folder exists (030_rcv etc.)

3. **API File Creation**
   - [ ] Place API definition file in paths directory
   - [ ] Filename is correct (001_rcvPlanSearch.yml)
   - [ ] Confirm BFF or gRPC

4. **Schema File Creation**
   - [ ] Place request schema in components/requests directory
   - [ ] Place response schema in components/responses directory
   - [ ] File count matches (header+detail etc.)

5. **API Definition Content Validation**
   - [ ] operationId is unique
   - [ ] `$ref` paths are correct
   - [ ] Tag format is correct
   - [ ] Method is POST

6. **Integration File Update**
   - [ ] Registered in bffWeb.yml or msGrpc.yml
   - [ ] Path conversion (`/` → `~1`) is correct

7. **Final Verification**
   - [ ] All `$ref` paths point to actual files
   - [ ] All YAML has valid syntax
   - [ ] No duplicates or contradictions

---

## 10. Error Detection and Reporting Rules

### 10.1 Error Report Format / 発見したエラーの報告形式

```
[Error Level] [Error Type]
───────────────────────────
Detection: [Detailed description]
Location: [File path]:[Line number]
Issue: [What rule violation]
Fix: [How to fix]
```

### 10.2 Error Levels

| Level    | Meaning                           | Action                     |
| -------- | --------------------------------- | -------------------------- |
| CRITICAL | Rule violation - cannot implement | Do not proceed until fixed |
| ERROR    | Rule violation                    | Fix required               |
| WARNING  | Recommendation not followed       | Issue warning              |
| INFO     | Information/Confirmation          | Log only                   |

---

**This document contains mandatory rules. No exceptions are allowed without approval from the non-functional team.**
