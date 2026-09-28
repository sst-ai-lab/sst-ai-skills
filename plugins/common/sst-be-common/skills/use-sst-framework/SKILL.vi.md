---
name: use-sst-framework
description: Danh sách framework tự phát triển (SST framework sst-fw-be-*). Use when writing or reviewing Java code in any SST repository (BFF, microservice, framework library or Java tool) and you need to know what the shared SST framework (sst-fw-be-*) already provides so you reuse it instead of reinventing — validation annotations (@DateFormat, @ChronologicalDates, @Password…), file utils (FileCsvUtil, FilePdfUtil, FileImageUtil, FileTabularUtil, FileZipUtil), extensions (StringExtension, BigDecimalExtension, LocalDateExtension…), security helpers, event streaming, exceptions (BadRequestException, NotFoundException…), error codes (ErrorCodeEnum), InvalidRequestExceptionRecord, DTOs like ListResponse / ListResponseMetadata, RequestContext / RequestContextHolder, SecurityUserDto.
---

# Hướng dẫn framework

## Cách sử dụng

Về cách sử dụng chi tiết, vui lòng tham khảo các file .md dưới đây.

| Mẫu         | Tên file md                          | Mô tả                                                                                                                               |
| ---------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| Đặc tả logic     | `references/fw-catalog.md`            | Danh sách framework tự phát triển                                                                                                   |
| Reuse reference  | `references/fw-reuse-microservice.md` | The shared `com.fw.core.*` types this service reuses (exceptions, `ErrorCodeEnum`, `ListResponse`, `RequestContext`) — don't reinvent |

## Placeholder

Các placeholder trong `references/fw-reuse-microservice.md` được đọc từ chính repository đang review hoặc đang code. Không cần hỏi người dùng.

- `{repo}` — tên thư mục gốc của repository
- `{Feature}` — tên chức năng đang xử lý (tên dùng trong tên entity `{Feature}Entity`)
- `{processLogHelper}` — tên class helper ghi log xử lý, nằm trong `helper/` của repository đó
- `{eventPublisher}` — tên class phát event, nằm trong `infrastructure/message/` của repository đó
