---
name: scaffold-bff-feature
description: BFF 側のバックエンドを自動生成するためのスキルです。Use in a BFF repository (cm-be-bff-*) when scaffolding a new BFF feature from a backend design document (設計書) — generates the BFF Controller, ControllerMapping, gRPC Client/ClientImpl, ServiceMapping and Service/ServiceImpl using cm-be-spec generated stubs and models. Generates the BFF side only; the microservice side is generated in the microservice repository.
---

# バックエンドスキル（BFF 側）

## 適用タイミング

- BFF のバックエンドを自動生成する必要があるとき

## スコープ

- **生成する:** BFF の ①〜⑦（Controller、ControllerMapping、gRPC Client / ClientImpl、ServiceMapping、Service / ServiceImpl）
- **生成しない:** マイクロサービス側（gRPC サービス、ServiceMapping、MyBatis Mapper / XML、永続化モデル、Service / ServiceImpl）。
  `{targetMicroservice}` リポジトリ側で生成する。
  BFF 側の生成後、`references/preflight-and-checklist.md` の「マイクロサービス側への引き継ぎ」をユーザーに提示すること。

## 使い方

詳細な利用方法は、下記.mdを参照してください。

| パターン     | mdファイル名                                        | 説明                   |
| ------------ | --------------------------------------------------- | ---------------------- |
| 初期作成     | `references/inputs-and-naming.md`                   | バックエンドの初期作成（概要・前提条件・ユーザーへの確認事項・命名規則） |
| 初期作成     | `references/file-structure.md`                      | ファイル/ディレクトリ構造・データフロー |
| 初期作成     | `templates/bff-templates.md`                        | Javaファイルテンプレート（BFF ①〜⑦） |
| 初期作成     | `references/conversion-rules.md`                    | 設計書からの自動変換ルール・実装パターン早見表 |
| 初期作成     | `references/preflight-and-checklist.md`             | 事前ファイル確認（必須）・実行チェックリスト・マイクロサービス側への引き継ぎ・注意事項 |

## 生成前に決める値

リポジトリから読み取れる値は読み取る。読み取れない値だけユーザーに確認する。

| プレースホルダー        | 決め方                                                                      |
| ----------------------- | --------------------------------------------------------------------------- |
| `{repo}`                | リポジトリのルートディレクトリ名                                            |
| `{basePackage}`         | 既存の Java ファイルの `package` 宣言（`{basePackagePath}` はそのディレクトリ形式） |
| `{grpcChannel}`         | 既存の gRPC クライアント設定に書かれているチャネル名                        |
| `{targetMicroservice}`  | 呼び出し先マイクロサービスのリポジトリ名 — ユーザーに確認する                |
| 大分類                  | `references/inputs-and-naming.md` の大分類マッピング表から選ぶ — ユーザーに確認する |

## フレームワークの再利用

ユーティリティ・例外・バリデーション・DTO を新しく書く前に、共有フレームワーク（`sst-fw-be-*`）に同じものが既にないか確認する。既にあるものは作らず、それを使う。
