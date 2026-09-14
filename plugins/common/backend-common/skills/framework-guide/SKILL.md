---
name: framework-guide
description: 自作フレームワーク一覧（SST framework sst-fw-be-*）。Use when writing or reviewing backend code (BFF or microservice) and you need to know what the shared SST framework (sst-fw-be-*) already provides so you reuse it instead of reinventing — validation annotations (@DateFormat, @ChronologicalDates, @Password…), file utils (FileCsvUtil, FilePdfUtil, FileImageUtil, FileTabularUtil, FileZipUtil), extensions (StringExtension, BigDecimalExtension, LocalDateExtension…), security helpers, event streaming, exceptions (BadRequestException, NotFoundException…), error codes (ErrorCodeEnum), InvalidRequestExceptionRecord, DTOs like ListResponse / ListResponseMetadata, RequestContext / RequestContextHolder, SecurityUserDto.
---

# フレームワークガイド

## 使い方

詳細な利用方法は、下記.mdを参照してください。

| パターン         | mdファイル名                          | 説明                                                                                                                                   |
| ---------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ロジック仕様     | `references/fw-catalog.md`            | 自作フレームワーク一覧                                                                                                                 |
| Reuse reference  | `references/fw-reuse-microservice.md` | The shared `com.scm.core.*` types this service reuses (exceptions, `ErrorCodeEnum`, `ListResponse`, `RequestContext`) — don't reinvent |

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

- `{repo}` — repository name (title of `references/fw-reuse-microservice.md`)
- `{Feature}` — feature name used in entity class names (`{Feature}Entity`)
- `{processLogHelper}` — in-repo process-log helper class under `helper/`
- `{eventPublisher}` — in-repo event publisher class under `infrastructure/message/`
