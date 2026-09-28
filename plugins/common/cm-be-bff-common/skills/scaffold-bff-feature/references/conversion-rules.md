# バックエンドを新規作成する — 設計書からの自動変換ルール・実装パターン早見表

## 設計書からの自動変換ルール

### DB物理列名 → Java フィールド名

| 変換ルール                            | 例                              |
| ------------------------------------- | ------------------------------- |
| 大文字スネークケース → lowerCamelCase | `COMPANYCD` → `companyCd`       |
| `_` を除去して次の文字を大文字化      | `SHIP_SCH_DATE` → `shipSchDate` |
| プレフィックス `N_` は `n` として扱う | `N_KANRINO` → `nKanriNo`        |

### 型マッピング（設計書 → Java）

| 設計書の型             | Java型                 | 備考                   |
| ---------------------- | ---------------------- | ---------------------- |
| String                 | `String`               |                        |
| Long                   | `Long`                 |                        |
| Integer                | `Integer`              |                        |
| BigDecimal             | `java.math.BigDecimal` |                        |
| 日付（YYYYMMDD）       | `String`               | フォーマット変換は不要 |
| 日時（YYYYMMDDHHmmss） | `String`               | フォーマット変換は不要 |
| Array<X>               | `List<X>`              |                        |

### リクエスト/レスポンスの必須フィールド

- 設計書「入力パラメータ」の「必須 ✅」項目 → `@NotNull` / `@NotBlank` アノテーションを付与

---

## 実装パターン早見表

| API種別 | BFF Service 戻り値             | gRPC レスポンス（Client が受け取る型） |
| ------- | ------------------------------ | -------------------------------------- |
| 検索    | `ListResponse<DetailResponse>` | gRPCレスポンス型                       |
| 登録    | `void`                         | `Empty`                                |
| 更新    | `void`                         | `Empty`                                |
| 削除    | `void`                         | `Empty`                                |

マイクロサービス側の戻り値・トランザクション方針は、そのリポジトリのマイクロサービス規約に従う。
update