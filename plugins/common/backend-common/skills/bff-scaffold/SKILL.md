---
name: bff-scaffold
description: バックエンドを自動生成するためのスキルです。Use when scaffolding a new BFF feature from a backend design document (設計書) in a BFF repository — generates BFF Controller, ControllerMapping, gRPC Client/ClientImpl, ServiceMapping, Service/ServiceImpl, plus the microservice-side gRPC service, ServiceMapping, MyBatis Mapper/XML, persistence models and Service/Impl, using cm-be-spec generated stubs and models.
---

# バックエンドスキル

## 適用タイミング

- バックエンドを自動生成する必要があるとき

## 使い方

詳細な利用方法は、下記.mdを参照してください。

| パターン     | mdファイル名                                        | 説明                   |
| ------------ | --------------------------------------------------- | ---------------------- |
| 初期作成     | `references/inputs-and-naming.md`                   | バックエンドの初期作成（概要・前提条件・ユーザーへの確認事項・命名規則） |
| 初期作成     | `references/file-structure.md`                      | ファイル/ディレクトリ構造・データフロー |
| 初期作成     | `templates/bff-templates.md`                        | Javaファイルテンプレート（BFF ①〜⑦） |
| 初期作成     | `templates/ms-templates.md`                         | Javaファイルテンプレート（マイクロサービス ⑧〜⑭） |
| 初期作成     | `references/conversion-rules.md`                    | 設計書からの自動変換ルール・実装パターン早見表 |
| 初期作成     | `references/preflight-and-checklist.md`             | 事前ファイル確認（必須）・実行チェックリスト・注意事項 |
| ロジック仕様 | `../framework-guide/references/fw-catalog.md`       | 自作フレームワーク一覧 |

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

| Placeholder             | Meaning                                                        |
| ----------------------- | -------------------------------------------------------------- |
| `{repo}`                | この BFF リポジトリ名                                           |
| `{basePackage}`         | BFF のベースパッケージ（`{basePackagePath}` はそのディレクトリ形式） |
| `{grpcChannel}`         | ClientImpl の `@GrpcClient` に指定する gRPC チャネル名          |
| `{targetMicroservice}`  | 呼び出し先マイクロサービスのリポジトリ名                         |
| `{msBasePackage}`       | 呼び出し先マイクロサービスのベースパッケージ（`{msBasePackagePath}` はそのディレクトリ形式） |
| 大分類                  | この BFF が扱う大分類（`references/inputs-and-naming.md` の大分類マッピング表の値） |
