# バックエンドを新規作成する（Java実装）

設計書（バックエンド）を添付すると、大分類・中分類・小分類・機能名・機能ID・API一覧・処理概要をすべて自動で読み取れます。OpenAPI仕様書の生成とビルドが完了していることを前提とします。

## 概要

このスキルは、SCM バックエンドの設計書と、`cm-be-spec` で生成済みのスタブ・モデルを基に、BFF 側の Java 実装ファイル（①〜⑦）を自動生成します。
マイクロサービス側は `{targetMicroservice}` リポジトリ側で生成します。

**前提条件:**

- `cm-be-spec` リポジトリで OpenAPI 仕様書からスタブ・モデルの生成とパブリッシュが完了していること
- 生成済みアーティファクト `com.cm:cm-be-spec` が JFrog Artifactory から解決できること
  （`{repo}` はこれを **依存 jar として** 取り込む。ローカルでスタブを生成することはない）

> **スタブ・モデルの生成は当リポジトリでは行わない。**
> `{repo}` は Gradle プロジェクト（ビルドは `./gradlew`、Node のパッケージマネージャは pnpm）であり、
> 依存解決した `com.cm:cm-be-spec` の jar をそのまま利用する。
> スタブ・モデルの生成・パブリッシュ手順は `cm-be-spec` の README を参照すること。

---

## ユーザーへの確認事項

**以下の項目を確認してください。** 設計書が添付されている場合、★印以外の項目は設計書から自動抽出します。

| 項目                                          | 確認タイミング                               | 例                                 |
| --------------------------------------------- | -------------------------------------------- | ---------------------------------- |
| **★ 菅次郎チケット番号**                      | **常に最初に確認する（設計書から抽出不可）** | **123**                            |
| 大分類                                        | 設計書から自動抽出                           | Web                                |
| 中分類                                        | 設計書から自動抽出                           | コア                               |
| 小分類                                        | 設計書から自動抽出                           | 出荷                               |
| 機能名（英語・PascalCase）                    | 設計書から自動抽出                           | SoMainte                           |
| 機能ID                                        | 設計書から自動抽出                           | 003                                |
| API一覧（メソッド名・処理概要）               | 設計書から自動抽出                           | getSo / saveSo / deleteSo          |
| 対象マイクロサービス                          | 設計書から自動抽出                           | {targetMicroservice} |

---

## 命名規則

### 基礎ルール

各コードパーツを以下のように導出します。

| 変数名           | 導出ルール                                                                                 | 例（SoMainte）                                                                     |
| ---------------- | ------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------- |
| `[大分類Pascal]` | 設計書「大分類」を PascalCase                                                              | `Web`                                                                              |
| `[中分類Pascal]` | 設計書「中分類」英語を PascalCase                                                          | `Core`                                                                             |
| `[小分類Pascal]` | 設計書「小分類」英語を PascalCase                                                          | `So`                                                                               |
| `[機能名Pascal]` | 設計書「機能名」を PascalCase                                                              | `SoMainte`                                                                         |
| `[中分類lc]`     | 中分類を小文字                                                                             | `core`                                                                             |
| `[小分類lc]`     | 小分類を小文字                                                                             | `so`                                                                               |
| `[機能名lc]`     | 機能名を lowerCamelCase                                                                    | `soMainte`                                                                         |
| `[タグ結合]`     | `[大分類][中分類][小分類][機能名Pascal]` をそのまま連結                                    | `WebCoreSoSoMainte`                                                                |
| `[API名Pascal]`  | 各API名を PascalCase                                                                       | `GetSo` / `SaveSo` / `DeleteSo`                                                    |
| `[API名lc]`      | 各API名を lowerCamelCase                                                                   | `getSo` / `saveSo` / `deleteSo`                                                    |
| `[operationId]`  | `[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]` をlowerCamelCaseで連結 | `webCoreSoSoMainteGetSo` / `webCoreSoSoMainteSaveSo` / `webCoreSoSoMainteDeleteSo` |

### 大分類マッピング

| 設計書大分類 | コード | [大分類Pascal] | [大分類lc] |
| ------------ | ------ | -------------- | ---------- |
| Web          | `w`    | `Web`          | `web`      |
| モバイル     | `m`    | `Mobile`       | `mobile`   |
| 帳票         | `r`    | `Report`       | `report`   |
| EDI          | `e`    | `Edi`          | `edi`      |
| 共通         | `c`    | `Common`       | `common`   |
| バッチ       | `b`    | `Batch`        | `batch`    |
| API          | `a`    | `Api`          | `api`      |

### 中分類マッピング

| 設計書中分類   | コード    | [中分類Pascal] | [中分類lc] |
| -------------- | --------- | -------------- | ---------- |
| コア機能       | `001`     | `Core`         | `core`     |
| オプション機能 | `002`     | `Option`       | `option`   |
| ローカル機能   | `100~999` | `Local`        | `local`    |

### 小分類マッピング

| 設計書小分類 | コード | [小分類Pascal] | [小分類lc]  |
| ------------ | ------ | -------------- | ----------- |
| FW           | `000`  | `Fw`           | `fw`        |
| 共通         | `010`  | `Common`       | `common`    |
| マスタ       | `020`  | `Master`       | `master`    |
| 入荷         | `030`  | `Rcv`          | `rcv`       |
| 出荷         | `040`  | `So`           | `so`        |
| オーダー管理 | `050`  | `Order`        | `order`     |
| 在庫         | `060`  | `Inv`          | `inv`       |
| 請求         | `070`  | `Billcalc`     | `billcalc`  |
| 運賃         | `080`  | `Carrycalc`    | `carrycalc` |
| 棚卸         | `090`  | `Stks`         | `stks`      |
| 配送         | `100`  | `Tms`          | `tms`       |
| 保税         | `110`  | `Hozei`        | `hozei`     |
| ABL          | `120`  | `Abl`          | `abl`       |
| BI           | `130`  | `Bi`           | `bi`        |
| ログ         | `140`  | `Log`          | `log`       |
| 受払         | `150`  | `Inout`        | `inout`     |
| 日々在庫     | `160`  | `Dailyinv`     | `dailyinv`  |
| 分析         | `170`  | `Analyze`      | `analyze`   |

### OpenAPI自動生成クラスの命名規則

OpenAPI仕様書のtagsから下記クラスが自動生成されます（`tags: Web / Core / So / SoMainte` → `[タグ結合] = WebCoreSoSoMainte`）。

| クラス種別                              | 命名規則                                                                | 例（SoMainte）                                                                                   |
| --------------------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| BFF APIインターフェース                 | `[タグ結合]Api`                                                         | `WebCoreSoSoMainteApi`                                                                           |
| BFF リクエストモデル                    | `[title]`（OpenAPI componentのtitle）                                   | `WebCoreSoSoMainteGetSoRequest`                                                                  |
| BFF レスポンスモデル                    | `[title]`                                                               | `WebCoreSoSoMainteGetSoSuccessResponse`                                                          |
| gRPC BlockingStub                       | `[タグ結合]ServiceBlockingStub`（inner class）                          | `WebCoreSoSoMainteServiceBlockingStub`                                                           |
| gRPC ServiceImplBase                    | `[タグ結合]ServiceImplBase`（inner class）                              | `WebCoreSoSoMainteServiceImplBase`                                                               |
| gRPC リクエストメッセージ               | `Grpc[title]`（OuterClassの内部クラス）                                 | `GrpcWebCoreSoSoMainteGetSoRequest`                                                              |
| gRPC レスポンスメッセージ               | `Grpc[title]`（OuterClassの内部クラス）                                 | `GrpcWebCoreSoSoMainteGetSoSuccessResponse`                                                      |
| gRPC ネストメッセージ（登録系ヘッダ等） | `Grpc[タグ結合][API名Pascal][フィールド名Pascal]`（独立したOuterClass） | `GrpcWebCoreSoSoMainteSaveSoHeader`（OuterClass: `GrpcWebCoreSoSoMainteSaveSoHeaderOuterClass`） |

> **⚠️ gRPC ネストメッセージの注意**: 登録系リクエスト（例: `GrpcWebCoreSoSoMainteSaveSoRequest`）の `so` フィールドのような **ネストされたメッセージ型は内部クラスではありません**。`[リクエストクラス].So` のような参照は**コンパイルエラー**になります。必ず `javap` で実際の型を確認し、対応するOuterClassからインポートしてください。
>
> ```java
> // ❌ 誤り（内部クラスは存在しない）
> GrpcWebCoreSoSoMainteSaveSoRequest.So grpcHeader = request.getSo();
>
> // ✅ 正しい（独立したOuterClassからインポート）
> import com.cm.grpc.GrpcWebCoreSoSoMainteSaveSoHeaderOuterClass.GrpcWebCoreSoSoMainteSaveSoHeader;
>
> GrpcWebCoreSoSoMainteSaveSoHeader grpcHeader = request.getSo();
> ```
