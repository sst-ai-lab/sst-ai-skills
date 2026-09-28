# バックエンドを新規作成する — 事前ファイル確認・実行チェックリスト・注意事項

## 事前ファイル確認（必須）

**ファイル生成を開始する前に、必ず以下の確認を行うこと。確認できなかった場合は作業を中断してユーザーに報告すること。**

### 確認手順

設計書から `[タグ結合]` を導出し（例: `WebCoreSoSoMainte`）、下記2つのjarに対象クラスが含まれているかを確認する。

#### 1. BFF HTTP APIインターフェースの確認

```bash
# Windowsの場合
jar -tf %USERPROFILE%\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar | findstr "[タグ結合]"

# PowerShellの場合
jar -tf "$env:USERPROFILE\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar" | Select-String "[タグ結合]"
```

期待される出力の例:

```
com/cm/http/api/WebCoreSoSoMainteApi.class
com/cm/http/model/WebCoreSoSoMainteGetSoRequest.class
com/cm/http/model/WebCoreSoSoMainteGetSoSuccessResponse.class
...
```

#### 2. gRPC スタブの確認

```bash
# Windowsの場合
jar -tf %USERPROFILE%\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar | findstr "[タグ結合]"

# PowerShellの場合
jar -tf "$env:USERPROFILE\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar" | Select-String "[タグ結合]"
```

期待される出力の例:

```
com/cm/grpc/WebCoreSoSoMainteServiceGrpc.class
com/cm/grpc/GrpcWebCoreSoSoMainteGetSoRequestOuterClass.class
...
```

### 判定基準

| 確認結果                       | 対応                                                      |
| ------------------------------ | --------------------------------------------------------- |
| ✅ 両方のクラスが確認できた    | → ファイル生成を開始する                                  |
| ❌ クラスが1つでも見つからない | → **作業を中断** し、以下のメッセージをユーザーに報告する |

#### 中断時のメッセージ（そのままユーザーに伝える）

```
⚠️ ビルドが未完了のため作業を中断しました。

以下のクラスが見つかりませんでした:
- [見つからなかったクラス名]

`cm-be-spec` の生成・パブリッシュが完了しているか、
JFrog Artifactory から `com.cm:cm-be-spec` が解決できているかを確認してから、再度お試しください。

確認コマンド（当リポジトリ）:

  ./gradlew classes
```

---

## 実行チェックリスト

生成時は以下の順番で進めてください（**OpenAPIスキルでのOpenAPI生成・ビルドは事前完了前提**）:

1. [ ] **作業ブランチを作成する** ← `git checkout -b feature/<機能名>` でブランチを作成してから生成を開始する
2. [ ] 事前ファイル確認を実行する（上記「事前ファイル確認（必須）」参照）← **クラスが見つからない場合は中断**
3. [ ] ⑤ BFF ServiceMapping を作成する
4. [ ] ② BFF gRPCクライアント インターフェースを作成する
5. [ ] ③ BFF gRPCクライアント 実装クラスを作成する
6. [ ] ④ BFF ControllerMapping を作成する（検索系のみ）
7. [ ] ⑥ BFF Service インターフェースを作成する
8. [ ] ⑦ BFF Service 実装クラスを作成する
9. [ ] ① BFF コントローラーを作成する
10. [ ] **AI生成ソースをコミットする** ← `git commit -m "#<チケット番号> [ai] <機能名> 初期生成"` でコミットして初回生成の境界を記録する
11. [ ] ビルドして動作確認する（**初回生成後の手修正**が必要な場合は `[manual]` prefixで都度コミット）
12. [ ] **マイクロサービス側への引き継ぎを提示する** ← 下記「マイクロサービス側への引き継ぎ」をユーザーに伝える

> **⚠️ スコープ**: 手順1のブランチ作成・手順10の`[ai]`コミット・手順11の`[manual]`コミットは**このスキルによる初回生成フローでのみ実施する**。
> 初回生成後にClaudeを使って修正する場合は通常の開発フローに従い、ブランチ作成や特殊なコミットは不要。

---

## マイクロサービス側への引き継ぎ

このスキルはマイクロサービス側のファイルを生成しない。BFF 側の生成が終わったら、以下をユーザーに提示し、
`{targetMicroservice}` リポジトリ側で対応する生成作業を行うよう案内する。

| 引き継ぎ項目                         | 内容                                                                 |
| ------------------------------------ | -------------------------------------------------------------------- |
| 対象リポジトリ                       | `{targetMicroservice}`                                               |
| 設計書                               | BFF 側の生成に使った設計書（SQL定義を含む）                           |
| 機能ID・機能名・大分類/中分類/小分類 | 設計書から抽出した値                                                 |
| `[タグ結合]`                         | 例: `WebCoreSoSoMainte`（`[タグ結合]ServiceImplBase` を実装する）      |
| API一覧                              | `[operationId]` ごとの gRPC リクエスト/レスポンス型と API種別（検索/登録/更新/削除） |

設計書にない項目（権限スコープ、Kafka イベント発行の有無など）は `scaffold-ms-feature` 側でユーザーに確認する。

---

## 注意事項

- **既存ファイルへの上書き厳禁**: 同一機能名のファイルが既に存在する場合、ユーザーに確認してから上書きする
- **OpenAPIで生成されたクラスは直接編集しない**: `com.cm.http.model.*` / `com.cm.http.api.*` / `com.cm.grpc.*` は
  `cm-be-spec` の依存 jar 内に存在する外部APIであり、当リポジトリに実体は無い。作成・スタブ化も禁止
- **アノテーションプロセッサ出力は直接編集しない**: MapStruct / Lombok の生成物は
  `build/generated/sources/annotationProcessor/java/main` 配下に出力される
- **MapStruct の配列フィールド名に注意**: gRPC の配列プロパティは自動的に `[フィールド名]List` となる（例: `soDetail` → `soDetailList`）ため、`@Mapping` で明示的にマッピングすること
- **【初回生成時のみ】作業ブランチを必ず作成してから生成を開始する**: `git checkout -b feature/<機能名>` でブランチを切ること。ブランチ名の例: `feature/so-mainte`
- **【初回生成時のみ】AI生成後は必ずコミットしてから手修正する**: AI生成ソースと手修正ソースを後から区別できるよう、以下のコミットprefixを使用すること（初回生成後にClaudeで修正する場合は通常の開発フローに従い不要）

  | prefix     | 意味                                  | 例（チケット番号: 123）         |
  | ---------- | ------------------------------------- | ------------------------------- |
  | `[ai]`     | Claude が生成したソース              | `#123 [ai] soMainte 初期生成`   |
  | `[manual]` | 人が手修正したソース（動作確認後1回） | `#123 [manual] soMainte 手修正` |

  ```bash
  # AI生成直後（手修正前）に必ず実行
  git add .
  git commit -m "#<チケット番号> [ai] <機能名> 初期生成"

  # 動作確認が取れたタイミングで1回まとめて実行
  git add .
  git commit -m "#<チケット番号> [manual] <機能名> 手修正"
  ```

  ステップ数の集計は以下で行う:

  ```bash
  # AI生成分
  git log --pretty=format:"%H" --grep="\[ai\]" | xargs -I{} git show --stat {}

  # 手修正分（[ai]コミット時点との差分）
  git diff <aiコミットハッシュ> HEAD --stat
  ```
