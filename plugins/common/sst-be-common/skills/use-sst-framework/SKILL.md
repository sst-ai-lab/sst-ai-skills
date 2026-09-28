---
name: use-sst-framework
description: 自作フレームワーク一覧（SST framework sst-fw-be-*）。Use when writing or reviewing Java code in any SST repository (BFF, microservice, framework library or Java tool) and you need to know what the shared SST framework (sst-fw-be-*) already provides so you reuse it instead of reinventing — validation annotations (@DateFormat, @ChronologicalDates, @Password…), file utils (FileCsvUtil, FilePdfUtil, FileImageUtil, FileTabularUtil, FileZipUtil), extensions (StringExtension, BigDecimalExtension, LocalDateExtension…), security helpers, event streaming, exceptions (BadRequestException, NotFoundException…), error codes (ErrorCodeEnum), InvalidRequestExceptionRecord, DTOs like ListResponse / ListResponseMetadata, RequestContext / RequestContextHolder, SecurityUserDto.
---

# フレームワークガイド

## 使い方

詳細な利用方法は、下記.mdを参照してください。

| パターン         | mdファイル名                          | 説明                                                                                                                                   |
| ---------------- | ------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ロジック仕様     | `references/fw-catalog.md`            | 自作フレームワーク一覧                                                                                                                 |
| Reuse reference  | `references/fw-reuse-microservice.md` | The shared `com.fw.core.*` types this service reuses (exceptions, `ErrorCodeEnum`, `ListResponse`, `RequestContext`) — don't reinvent |

## プレースホルダー

`references/fw-reuse-microservice.md` のプレースホルダーは、レビュー・実装対象のリポジトリから読み取る。ユーザーに質問する必要はない。

- `{repo}` — リポジトリのルートディレクトリ名
- `{Feature}` — 対象機能名（エンティティ名 `{Feature}Entity` に使われているもの）
- `{processLogHelper}` — そのリポジトリの `helper/` にある処理ログ用ヘルパークラス名
- `{eventPublisher}` — そのリポジトリの `infrastructure/message/` にあるイベント発行クラス名
