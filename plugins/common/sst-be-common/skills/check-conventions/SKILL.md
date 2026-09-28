---
name: check-conventions
description: 変更された Java コードと MyBatis マッパー XMLをバックエンド開発規約に照らしてレビューするためのスキルです。Use when reviewing changed Java code or MyBatis mapper XML (pull request or local diff) in any SST Java repository — a BFF, a microservice, a framework library (sst-fw-be-*) or a standalone Java tool — against the backend development conventions (開発規約) — package structure, layer responsibilities, class suffixes, naming, comments/Javadoc, MapStruct, MyBatis, exceptions, DI, validation, logging, constants/Enum, transactions, date/time, annotation usage. Also the rule source for the /sst-common:review-code command.
---

# コードレビュースキル

## 適用タイミング

- プルリクエストまたはローカルの差分で、変更された Java コードと MyBatis マッパー XMLをレビューする必要があるとき

## 使い方

判定基準は下記.mdだけを根拠とする。そこに書かれていない事項は規約違反ではない。

| パターン | mdファイル名 | 説明 |
| -------- | ------------ | ---- |
| 判定 | `references/backend-conventions.md` | 開発規約の全文 |

## レビュー手順

1. `references/backend-conventions.md` を読む
2. ファイル全体ではなく差分を見る。変更されていない箇所の既存違反は対象外。リネームされたファイルは新規ファイルではない。差分が追加・変更と示す行だけが対象で、持ち越された内容は対象外とする。
3. パッケージから各ファイルの層を判断し、レイヤー責務とパッケージ構成のルールを適用する
4. クラスサフィックス表と変数名の規則に照らして名前を確認する
5. 迷う場合は規約の文言を確認する。そう書かれていなければ、そう主張しない

## 報告の仕方

- 適用した規約の文言をそのまま引用したうえで、具体的な修正内容を書く
- 引用は読み込んだファイルからそのままコピーする。記憶で書き直す・省略する・翻訳することはしない。文書内に見つけられないルールはルールではないので、その指摘は取り下げる。
- 指摘は場所ごとに1件とする。同じ原因が別のファイル・行にも現れる場合はそこでも報告する
- 規約に書かれていない事項（バグ・セキュリティ・性能）も報告してよいが、規約違反ではないと明記する

## 審査から除外する項目

規約側が未確定の項目は、違反として報告しない。

| 規約の項目 | 状況 |
| --- | --- |
| 5.2 `unmappedTargetPolicy = ERROR` | 全リポジトリのコードは `IGNORE`。規約側に検討事項が残っている |
| 5.2 `@Mapper` 設定を `BaseMapping` に集約 | 一部のリポジトリのみ導入済み |

## 規約内のプレースホルダー

`references/backend-conventions.md` の 2.1・2.2・3・5.8 には、リポジトリごとに変わる値がプレースホルダーで書かれている。レビュー対象のリポジトリから読み取って解釈する。ユーザーに質問する必要はない。

| プレースホルダー     | 読み取り方                                                                 |
| -------------------- | -------------------------------------------------------------------------- |
| `{repo}`             | リポジトリのルートディレクトリ名                                           |
| `{basePackage}`      | レビュー対象ファイルの `package` 宣言。`src/main/java/` 直下の構成と一致する |
| `{ApplicationClass}` | `@SpringBootApplication` が付いたクラス名。無い場合は 2.2 の判定を行わない   |

ライブラリ（`sst-fw-be-*`）のようにアプリケーションクラスを持たないリポジトリでは、2.2 のパッケージ構成は BFF・マイクロサービス向けの規約なので適用しない。3・4・5 章は適用する。
