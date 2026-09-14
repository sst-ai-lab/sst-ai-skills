---
name: convention-review
description: 変更された Java コードをバックエンド開発規約に照らしてレビューするためのスキルです。Use when reviewing changed Java code (pull request or local diff) in a backend repository (BFF or microservice) against the backend development conventions (開発規約) — package structure, layer responsibilities, class suffixes, naming, comments/Javadoc, MapStruct, MyBatis, exceptions, DI, validation, logging, constants/Enum, transactions, date/time, annotation usage. Also the rule source for the /review-code command.
---

# コードレビュースキル

## 適用タイミング

- プルリクエストまたはローカルの差分で、変更された Java コードをレビューする必要があるとき

## 使い方

判定基準は下記.mdだけを根拠とする。そこに書かれていない事項は規約違反ではない。

| パターン | mdファイル名 | 説明 |
| -------- | ------------ | ---- |
| 判定 | `references/backend-conventions.md` | 開発規約の全文 |

## レビュー手順

1. `references/backend-conventions.md` を読む
2. ファイル全体ではなく差分を見る。変更されていない箇所の既存違反は対象外
3. パッケージから各ファイルの層を判断し、レイヤー責務とパッケージ構成のルールを適用する
4. クラスサフィックス表と変数名の規則に照らして名前を確認する
5. 迷う場合は規約の文言を確認する。そう書かれていなければ、そう主張しない

## 報告の仕方

- 適用した規約の文言をそのまま引用したうえで、具体的な修正内容を書く
- 指摘は場所ごとに1件とする。同じ原因が別のファイル・行にも現れる場合はそこでも報告する
- 規約に書かれていない事項（バグ・セキュリティ・性能）も報告してよいが、規約違反ではないと明記する

## Inputs from CLAUDE.md

Read `## Service profile` and `## Policies` in the repository `CLAUDE.md`. If a value is missing, ask the user instead of guessing.

- `{repo}` — the repository under review, shown in the repository list (2.1 GitHub リポジトリ)
- `{basePackage}` — service base package (as a directory path under `src/main/java/` in 2.2, and as a package name in 3 and 5.8)
- `{ApplicationClass}` — Spring Boot entry-point class name
