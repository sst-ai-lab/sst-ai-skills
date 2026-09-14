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
3. [ ] ⑪ 永続化モデル Request/Response を作成する（API数分）
4. [ ] ⑩ MyBatis Mapper インターフェースを作成する
5. [ ] ⑭ MyBatis Mapper XML を作成する（設計書のSQL定義に従う）
6. [ ] ⑨ MS ServiceMapping を作成する
7. [ ] ⑫ MS Service インターフェースを作成する
8. [ ] ⑬ MS Service 実装クラスを作成する
9. [ ] ⑧ MS gRPCサービスを作成する
10. [ ] ⑤ BFF ServiceMapping を作成する
11. [ ] ② BFF gRPCクライアント インターフェースを作成する
12. [ ] ③ BFF gRPCクライアント 実装クラスを作成する
13. [ ] ④ BFF ControllerMapping を作成する（検索系のみ）
14. [ ] ⑥ BFF Service インターフェースを作成する
15. [ ] ⑦ BFF Service 実装クラスを作成する
16. [ ] ① BFF コントローラーを作成する
17. [ ] **AI生成ソースをコミットする** ← `git commit -m "#<チケット番号> [ai] <機能名> 初期生成"` でコミットして初回生成の境界を記録する
18. [ ] ビルドして動作確認する（**初回生成後の手修正**が必要な場合は `[manual]` prefixで都度コミット）

> **⚠️ スコープ**: 手順1のブランチ作成・手順17の`[ai]`コミット・手順18の`[manual]`コミットは**このスキルによる初回生成フローでのみ実施する**。
> 初回生成後にClaudeを使って修正する場合は通常の開発フローに従い、ブランチ作成や特殊なコミットは不要。

---

## 注意事項

- **既存ファイルへの上書き厳禁**: 同一機能名のファイルが既に存在する場合、ユーザーに確認してから上書きする
- **OpenAPIで生成されたクラスは直接編集しない**: `com.cm.http.model.*` / `com.cm.http.api.*` / `com.cm.grpc.*` は
  `cm-be-spec` の依存 jar 内に存在する外部APIであり、当リポジトリに実体は無い。作成・スタブ化も禁止
- **アノテーションプロセッサ出力は直接編集しない**: MapStruct / Lombok の生成物は
  `build/generated/sources/annotationProcessor/java/main` 配下に出力される
- **設計書に存在しないフィールドの追加禁止**: 永続化モデルには設計書の項目定義にあるフィールドのみを定義すること
- **MyBatis XML 内の SQL コメントは `/* */` を使用する**: `--` による行コメントは MyBatis が SQL をログ処理等で1行に圧縮した場合に以降の SQL が全てコメントアウトされる恐れがある。`<select>` / `<insert>` / `<update>` / `<delete>` 内のコメントには必ず `/* コメント */` ブロックコメントを使用すること。XML レベルのコメント（`<!-- -->`) は `<resultMap>` 等のタグ外で使用する。
- **SQL は設計書定義に忠実に**: 設計書のSQL定義をそのまま MyBatis XML に転記する。以下を厳守すること:
  - テーブル名・カラム名・集計関数（`MIN`/`MAX` 等）を変更しない
  - JOINの結合条件（`LOCALECD`・`CODE2` 等を含む）を省略しない
  - サブクエリ内の `WHERE` 条件を省略しない
  - PostgreSQL 固有の型キャスト（`::TEXT` 等）を省略しない
  - 独自のロジックを追加しない
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
