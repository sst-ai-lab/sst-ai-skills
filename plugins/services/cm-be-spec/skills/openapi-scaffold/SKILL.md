---
name: openapi-scaffold
description: マイクロサービス連携機能のBFF契約(TypeSpec)とgRPC契約(OpenAPI YAML)を、基本設計書/詳細設計書から自動生成するためのスキルです。OpenAPI作成ルール（`**/src/openapi/**/*`）も含む。Use when creating or changing a microservice-backed BFF⇔gRPC contract in cm-be-spec (TypeSpec `.tsp` + `msGrpc.yml` / gRPC OpenAPI YAML), or when creating/editing files under `src/openapi/` (paths, components, $ref, operationId, function ID rules).
---

# OpenAPIスキル

BFF側の契約は **TypeSpec**（`src/tsp/bffWeb/**/*.tsp`）で作成し、`src/openapi/bffWeb.yml` はそこから自動生成される成果物（直接編集禁止）。gRPC側（`msGrpc.yml` とその配下）は引き続き手書きのOpenAPI YAML。詳細は `references/init.md` を参照。

## 適用タイミング

- マイクロサービスを呼び出す機能（画面・バッチ問わず）のBFF⇔gRPC契約を新規作成/変更する必要があるとき
- `src/openapi/**/*` 配下のファイルを作成/編集するとき（`references/openapi-rules.md`）
- 外部SDK/API連携（gRPCを呼ばない機能）は対象外 → `openapi-integration-scaffold` スキルを使う

## 使い方

詳細な利用方法は、下記.mdを参照してください。

| パターン | mdファイル名 | 説明 |
|---------|----------|------|
| 初期作成 | `references/init.md` | 基本設計書・詳細設計書からBFF(TypeSpec)+gRPC(YAML)を新規作成 |
| OpenAPI作成ルール | `references/openapi-rules.md` | `**/src/openapi/**/*` に適用されるOpenAPI作成ルール |
