# OpenAPI仕様書を新規作成する（BFF: TypeSpec / gRPC: OpenAPI YAML）

添付: 基本設計書（Web設計書・バックエンド設計書）と、あれば詳細設計書（バックエンド ×画面、フロントエンド）を添付すると、大分類・中分類・小分類・機能名・機能ID・API/gRPC一覧・パラメータ定義をすべて自動で読み取れます。アーキテクチャルールはこのファイルに内包済みのため、バックエンド教育資料の添付は不要です。

## 概要

このスキルは、マイクロサービス連携機能（画面・バッチ問わず）の**BFF⇔gRPC契約**を設計書から自動生成します。

> **重要な前提（`README.md` 参照）**: BFF側の4契約（`bffWeb`/`bffMobile`/`bffCommon`/`bffManual`）は **TypeSpec** で記述するように移行済みです。
>
> - **BFF側 = `src/tsp/bffWeb/**/*.tsp` を手書きする。** `src/openapi/bffWeb.yml` は `node scripts/generate-bff-openapi.mjs`（または Gradle の `compileBffTsp` タスク）が `.tsp` から自動生成する成果物であり、**gitignore対象・直接編集禁止**。
> - **gRPC側（`msGrpc.yml` とその配下）は移行対象外で、従来どおり手書きのOpenAPI YAML。** `openapi-rules.md` のルールはこちら側に引き続き完全に適用される。
> - つまり1機能を実装する際、**BFFは `.tsp` 1ファイル、gRPCは従来どおり `paths/grpc` + `components/grpc` の複数YAMLファイル**という非対称な構成になる。

**バックエンド教育資料の再添付は不要です。** このファイルにすべてのルールが内包されています。

### 入力ドキュメント（設計書）の種類と役割

| ドキュメント | 必須/任意 | このスキルが読み取る情報 |
|---|---|---|
| 基本設計書（Web設計書） | 必須 | 画面項目・バリデーション（パラメータの型/長さ/必須の補完材料） |
| 基本設計書（バックエンド設計書） | 必須 | 大分類/中分類/小分類/機能名/機能ID、API一覧（名称・概要のみ）、CRUD図、処理概要 |
| 詳細設計書（バックエンド、画面ごと） | **あれば優先採用** | 「API/gRPC一覧」表（エンドポイント(API)/サービス名(gRPC)/メソッド名(gRPC)/API・gRPC名称/説明）＋ 各APIの「パラメータ」入力/出力表（項目名/パラメータ名/型/長さ/必須/制約/デフォルト）、SQL定義 |
| 詳細設計書（フロントエンド） | 任意（補足） | 画面のAPI呼び出しタイミング・パラメータの受け渡し方の確認材料 |

詳細設計書（バックエンド）が添付されている場合、そこに書かれた具体的なエンドポイント/パラメータ定義を**そのまま採用**し、基本設計書からの再導出は行わない（基本設計書は大分類/中分類/小分類/機能名/機能IDの確認にのみ使う）。詳細設計書が無い場合のみ、基本設計書のAPI一覧・処理概要から本ファイルの命名規則に沿ってAPIパス/パラメータを導出する。

### 詳細設計書の「AI提案値」に関する注意

詳細設計書の「API/gRPC一覧」表に書かれたエンドポイント・サービス名・メソッド名は、多くの場合それ自体がAIによる提案値であり、脚注に「実装時の最終命名はBE devが確認」等の記載がある。これを採用する際は次を優先すること：

- **小分類の英語キーワードは本ファイルの§小分類マッピング表を正とする**（例: 「マスタ」→ `Master`。詳細設計書側に `mst` のような別表記があっても採用しない）
- gRPCサービス名は本ファイルの規則 `[中分類Pascal][小分類Pascal][機能名Pascal]Service` で確定する（詳細設計書の「サービス名(gRPC)」列がこれと異なる場合は本ファイルの規則を優先し、差異があればチャットで一言触れる）
- メソッド名・API名（PascalCase化する前のcamelCase名）は詳細設計書の値をそのまま使ってよい

### パラメータが「基本設計に記載なし」の場合の扱い

詳細設計書のパラメータ表に `（基本設計に記載なし）🔴【要詳細設計】` のようなプレースホルダーが残っている項目がある場合：

- 同一機能・類似カラムの慣例（コード系: `string` + `@maxLength(10~20)`、名称系: `string` + `@maxLength(40~80)`、フラグ系: `boolean`、日時系: `string`（ISO-8601）、金額・数量系: `decimal`）から妥当な値を仮定してよいが、**捏造した値は `@doc` の末尾に「（要確認）」を付記**し、生成完了後にチャットでその項目を一覧化してユーザー/BE devに確認を促す
- 出力パラメータの構造そのものが不明で類推もできない場合は、生成を止めてユーザーに確認する（既存の中止条件と同様、フィールドを憶測で作らない）

---

## ユーザーへの確認事項

**以下の項目を確認してください。** 設計書が添付されている場合、★印以外の項目は設計書から自動抽出します。

| 項目 | 確認タイミング | 例 |
|------|-------------|----|
| **★ 菅次郎チケット番号** | **常に最初に確認する（設計書から抽出不可）** | **123** |
| 大分類 | 設計書から自動抽出 | Web / API |
| 中分類 | 設計書から自動抽出 | コア / オプション |
| 小分類 | 設計書から自動抽出 | 出荷 / 入荷 / 在庫 など |
| 機能名（英語・PascalCase） | 設計書から自動抽出 | SoMainte |
| 機能ID（連番） | 設計書から自動抽出 | 003 |
| API/gRPC一覧（エンドポイント・サービス名・メソッド名・説明） | 詳細設計書があればそれを優先採用、無ければ基本設計書から導出 | getSo, saveSo, deleteSo |
| gRPCサービス名 | 詳細設計書の値より本ファイルの命名規則を優先 | CoreSoSoMainteService |
| 各APIのリクエスト/レスポンスパラメータ | 詳細設計書のパラメータ表を優先採用、無ければ基本設計書から導出 | — |

---

## ディレクトリ・ファイル構造

### 大分類マッピング

| 機能大分類 | コード | ディレクトリ名 | URL prefix | タグ prefix |
|-----------|--------|--------------|------------|------------|
| Web        | `w`    | `W_Web`      | `web`      | `Web /`（例: `Web / Core / So / SoMainte`）|
| モバイル   | `m`    | `M_Mobile`   | `mobile`   | なし |
| 帳票       | `r`    | `R_Report`   | `report`   | なし |
| EDI        | `e`    | `E_Edi`      | `edi`      | なし |
| 共通       | `c`    | `C_Common`   | `common`   | なし |
| バッチ     | `b`    | `B_Batch`    | `batch`    | なし |
| API        | `a`    | `A_API`      | `api`      | `Api /`（例: `Api / Core / So / SoMainte`）|

### 中分類マッピング

| 機能中分類     | コード    | ディレクトリ名 |
|----------------|-----------|---------------|
| コア機能       | `001`     | `001_core`    |
| オプション機能 | `002`     | `002_option`  |
| ローカル機能   | `100~999` | `[コード]_local` ※荷主専用 |

### 小分類マッピング

| 機能小分類   | コード | ディレクトリ名       | URL/タグ用キーワード |
|-------------|--------|---------------------|--------------------|
| FW          | `000`  | `000_fw`            | `Fw`               |
| 共通        | `010`  | `010_common`        | `Common`           |
| マスタ      | `020`  | `020_master`        | `Master`           |
| 入荷        | `030`  | `030_rcv`           | `Rcv`              |
| 出荷        | `040`  | `040_so`            | `So`               |
| オーダー管理 | `050` | `050_order`         | `Order`            |
| 在庫        | `060`  | `060_inv`           | `Inv`              |
| 請求        | `070`  | `070_billcalc`      | `Billcalc`         |
| 運賃        | `080`  | `080_carrycalc`     | `Carrycalc`        |
| 棚卸        | `090`  | `090_stks`          | `Stks`             |
| 配送        | `100`  | `100_tms`           | `Tms`              |
| 保税        | `110`  | `110_hozei`         | `Hozei`            |
| ABL         | `120`  | `120_abl`           | `Abl`              |
| BI          | `130`  | `130_bi`            | `Bi`               |
| ログ        | `140`  | `140_log`           | `Log`              |
| 受払        | `150`  | `150_inout`         | `Inout`            |
| 日々在庫    | `160`  | `160_dailyinv`      | `Dailyinv`         |
| 分析        | `170`  | `170_analyze`       | `Analyze`          |

### 作成ファイル一覧（機能ID=`[ID]`、機能名=`[Feature]`）

```
src/tsp/bffWeb/
├── main.tsp                                            ← import文を1行追加するだけ（②）
└── [大分類Dir]/[中分類Dir]/[小分類Dir]/
    └── [ID]_[featureCamel].tsp                          ← BFF: モデル＋オペレーションを1ファイルに全部書く（①）

src/openapi/
├── paths/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/
│   └── [ID]_[feature].yml                              ← gRPC pathファイル
└── components/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/
    ├── requests/[ID]_[feature]/
    │   ├── 01_[apiName].yml                             ← gRPC リクエスト
    │   └── 02_[apiName].yml  (APIが複数の場合)
    └── responses/[ID]_[feature]/
        ├── 01_[apiName].yml                             ← gRPC レスポンス
        └── 02_[apiName].yml
```

- **BFF側は `src/openapi/paths/bff/**`・`components/bff/**` を新規作成しない。** これらのYAMLは生成専用ディレクトリで、`.tsp` から自動生成される（gitignore対象）。1機能分のBFFモデル＋オペレーションは`[ID]_[featureCamel].tsp` 1ファイルにまとめるのが実例の慣例（`001_ediSetting.tsp` 参照。EDI設定機能はモデル定義＋7オペレーションを1ファイルに収めている）。
- gRPC側はレスポンスが「ヘッダ＋明細」等の複合構造の場合、参照ファイルを分割する（例: `01_getResponse.yml` が `02_getHeader.yml` と `03_getDetail.yml` を `$ref` で参照）。
- 列挙値が固定のドロップダウン（例: 業務区分、実行日タイプ）は、機能ファイル内またはドメイン共通の `_sharedEnums.tsp`（例: `src/tsp/bffWeb/W_Web/_sharedEnums.tsp`）に TypeSpec `enum` として定義する。

---

## 命名規則

### BFFオペレーション（TypeSpec、`[ID]_[featureCamel].tsp` 内）

実例（`001_ediSetting.tsp`）:

```tsp
@tag("Core / Master / EdiSetting")
@route("/v1/web/core/master/ediSearchById/select")
@post
@operationId("webCoreMasterEdiSearchById")
@summary("010_EDI設定_EDI詳細検索処理")
@doc("IDによるEDI設定の詳細取得")
op webCoreMasterEdiSearchById(@body body: CoreMasterEdiSearchByIdRequest):
  | CoreMasterEdiSearchByIdSuccessResponse
  | Resp400
  | Resp404;
```

| 項目 | ルール | 例 |
|------|--------|----|
| `@tag(...)` | `"[大分類Pascal] / [中分類Pascal] / [小分類Pascal] / [機能名Pascal]"` | `"Core / Master / EdiSetting"`（`Web /` は付けない。実例準拠） |
| `@route(...)` | `"/v1/[大分類lc]/[中分類lc]/[小分類lc]/[機能名lc]/[api名lc]"` | `"/v1/web/core/master/ediSearchById/select"` |
| `@post` | POSTのみ（設計思想は`openapi-rules.md`と同じ） | - |
| `@operationId(...)` | `"[大分類lc][中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]"` | `"webCoreMasterEdiSearchById"` |
| `@summary(...)` | `"[ID]_[機能名]_[API日本語名]"` | `"010_EDI設定_EDI詳細検索処理"` |
| `@doc(...)` | API日本語説明 | `"IDによるEDI設定の詳細取得"` |
| `op [operationIdと同名](...)` | リクエストありなら `@body body: [Request名]`、無しなら引数なし。戻り値は `| ` で区切ったunion（成功レスポンス + `Resp400`/`Resp404`/`Resp500`等の共通エラーモデル） | 上記参照 |

エラーレスポンスは `src/tsp/lib/errors.tsp` に `Resp400`/`Resp401`/`Resp403`/`Resp404`/`Resp409`/`Resp422`/`Resp500`/`Resp503` が定義済みなので、これらを再定義せずそのまま使う。

### BFFモデル（TypeSpec）

| 種類 | ルール | 例 |
|------|--------|----|
| Request | `[中分類Pascal][小分類Pascal][API名Pascal]Request`（大分類は含めない。実例準拠） | `CoreMasterEdiSearchByIdRequest` |
| Success Response（ラッパー） | `[中分類Pascal][小分類Pascal][API名Pascal]SuccessResponse`。単一データは`data:`、一覧は`option: X[]` + `metadata?: GrpcCommonPaginationMetadata`でラップ | `CoreMasterEdiSearchByIdSuccessResponse { data: CoreMasterEdiSearchByIdResponse }` |
| 実データ本体 / ネストモデル | `[API名Pascal]Response` やドメイン意味のある名前（`EdiSearchByIdBasic`, `EdiSearchByIdConditionItem` 等）。`$ref`は使わず、モデル名をそのまま型として参照する | `EdiSearchByIdConditionItem` |

### gRPC path YAML・メインYAML・コンポーネント

gRPC側はTypeSpec移行の対象外。以下は従来どおり。

| 項目 | ルール | 例 |
|------|--------|----|
| エンドポイント | `/[メソッド名PascalCase]` | `/EdiSearchById` |
| operationId | 実例では `[メソッド名PascalCase]`（エンドポイント名と同一。`openapi-rules.md`のシンプルな規則に合わせる） | `"EdiSearchById"` |
| tags | `"[大分類Pascal] / [中分類Pascal] / [小分類Pascal] / [機能名Pascal]"` | `"Web / Core / Master / EdiSetting"` |
| summary | `"[機能ID]: [API日本語名]"` または `"[ID]_[機能名]_[API日本語名]"`（既存機能に合わせて統一） | `"CA02-01-02: EDI詳細検索処理"` |

gRPC メインYAML（msGrpc.yml）のパスキー:

```
/v1.[大分類lc].[中分類lc].service.[中分類Pascal][小分類Pascal][機能名Pascal]Service/[メソッド名]:
```

例: `/v1.web.core.service.CoreMasterEdiSettingService/EdiSearchById`

gRPC コンポーネントスキーマ title（先頭は小文字 `grpc`、以降camelCase。実例準拠）:

| 種類 | ルール | 例 |
|------|--------|----|
| gRPC request | `grpc[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Request` | `grpcCoreMasterEdiSettingSearchByIdRequest` |
| gRPC response | `grpc[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]SuccessResponse` | `grpcCoreMasterEdiSettingSearchListSuccessResponse` |

---

## 型マッピング

### 設計書 → TypeSpec（BFF）

| 設計書の型 | TypeSpec型 | 備考 |
|-----------|-----------|------|
| String | `string` | `@maxLength(N)` を付与。任意項目は `field?: string;`、必須は `field: string;` |
| Long | `int64` | |
| Integer | `int32` | |
| BigDecimal（金額・数量） | `decimal` | 小数桁数の制約があれば `@extension("multipleOf", 0.001)` を付与（実例: `soInspection.tsp`） |
| Boolean / フラグ | `boolean` | |
| Array<X> | `X[]` | Xはモデル名（別途 `model X { ... }` を定義） |
| オブジェクト | モデル名を直接参照 | `$ref` は使わない。例: `basic?: EdiSearchByIdBasic \| null;` |
| null許容 | `(型 \| null)` | 例: `delimiter?: (string \| null);` |
| 固定値ドロップダウン | `enum` | `_sharedEnums.tsp` 参照 |
| 日付（YYYYMMDD） | `string` + `@maxLength(8)` | |
| 日時 | `string`（ISO-8601。実例では追加の `@maxLength` なし） | 例: `adddatetime?: string;` |
| example値 | `@extension("example", ...)` | 文字列/数値/真偽値そのまま。オブジェクトは `#{ key: "value" }` |
| Java Bean Validation個別注入 | `@extension("x-field-extra-annotation", "@Xxx")`（複数は `#["@Xxx", "@Yyy"]`） | `@maxLength`等から自動導出される分は付けない（README参照） |

必須項目は `?` を付けない（TypeSpecでは required がデフォルト）。

> **⚠️ 重要**: モデルのプロパティは**設計書に記載されているフィールドのみ**定義してください。設計書に存在しないフィールドを独自に追加することは禁止です。

### 設計書 → OpenAPI YAML（gRPC）

| 設計書の型 | OpenAPI type | format | 備考 |
|-----------|-------------|--------|------|
| String | `string` | - | `maxLength: [長さ]` を付与 |
| Long | `integer` | `int64` | |
| Integer | `integer` | `int32` | |
| BigDecimal | `number` | `double` | |
| Array<X> | `array` | - | `items: $ref: ./[Xのファイル].yml` |
| オブジェクト | `object` | - | `$ref: ./[サブファイル].yml` |
| 日付（YYYYMMDD）| `string` | - | `maxLength: 8`、description に `例: "20240101"` |
| 日時（YYYYMMDDHHmmss）| `string` | - | `maxLength: 14`、description に `例: "20240101120000"` |

必須項目（✅）は `required` 配列に追加します。

---

## テンプレート

### 1. BFF機能ファイル（TypeSpec、`src/tsp/bffWeb/[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[featureCamel].tsp`）

1機能分のモデル（Request/Response/ネストモデル）とオペレーションを、この1ファイルにまとめて書く。

```tsp
import "@typespec/http";
import "@typespec/openapi";
import "../../../../lib/common.tsp";

using Http;
using OpenAPI;

namespace ScmBff;

@doc("[API日本語名]リクエスト")
model [中分類Pascal][小分類Pascal][API名Pascal]Request {
  @doc("[項目説明]")
  @maxLength([長さ])
  @extension("example", "[例値]")
  [フィールド名]: string;

  @doc("[項目説明]")
  [フィールド名2]?: (int32 | null);
}

@doc("[API日本語名]レスポンス")
model [中分類Pascal][小分類Pascal][API名Pascal]SuccessResponse {
  @doc("[データ説明]")
  data: [API名Pascal]Response;
}

@doc("[データ説明]")
model [API名Pascal]Response {
  [フィールド名]?: string;
  // ネストが必要な場合は別モデルを定義して参照する
}

@tag("[中分類Pascal] / [小分類Pascal] / [機能名Pascal]")
@route("/v1/web/[中分類lc]/[小分類lc]/[機能名lc]/[api名lc]")
@post
@operationId("web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]")
@summary("[ID]_[機能名]_[API日本語名]")
@doc("[API日本語説明]")
op web[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal](@body body: [中分類Pascal][小分類Pascal][API名Pascal]Request):
  | [中分類Pascal][小分類Pascal][API名Pascal]SuccessResponse
  | Resp400
  | Resp404;
```

一覧取得系（ページング）は次のラッパーパターンを使う（実例: `CoreMasterPostEdiSearchListSuccessResponse`）:

```tsp
model [中分類Pascal][小分類Pascal][API名Pascal]SuccessResponse {
  option: [API名Pascal]Response[];
  metadata?: GrpcCommonPaginationMetadata;
}
```

パラメータ不要のGET相当API（`@body`なし）は `op xxx(): ...;` のように引数を空にする（実例: `webCoreMasterEdiSearchList`）。

### 2. `main.tsp` への import 追加

新規ファイルを作成したら `src/tsp/bffWeb/main.tsp` に1行importを足すだけでよい（既存の並び順・末尾に合わせる）:

```tsp
import "./[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[featureCamel].tsp";
```

`bffWeb.yml` の tags/paths は手動更新不要（下記「ファイル反映」参照）。

### 3. gRPC pathファイル

`src/openapi/paths/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[feature].yml`

```yaml
paths:
  /[メソッド名]:
    post:
      operationId: "[メソッド名]"
      summary: "[ID]_[機能名]_[API日本語名]"
      description: "[API説明]"
      tags:
        - "[大分類Pascal] / [中分類Pascal] / [小分類Pascal] / [機能名Pascal]"
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "../../../../../../components/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/requests/[ID]_[featurelc]/01_[apilc].yml"
      responses:
        "200":
          description: "[成功メッセージ]"
          content:
            application/json:
              schema:
                $ref: "../../../../../../components/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/responses/[ID]_[featurelc]/01_[apilc].yml"
        "400":
          $ref: "../../../../../../components/common/responses/error.yml#/BadRequestResponse"
```

### 4. gRPC リクエストコンポーネント

`src/openapi/components/grpc/v1/.../requests/[ID]_[feature]/01_[api].yml`

```yaml
type: "object"
title: grpc[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]Request
description: "[説明]"
required:
  - [必須フィールド名]
properties:
  [フィールド名]:
    type: [型]
    maxLength: [長さ]
    description: [日本語説明]
    example: "[例値]"
```

### 5. gRPC レスポンスコンポーネント

```yaml
type: object
title: grpc[中分類Pascal][小分類Pascal][機能名Pascal][API名Pascal]SuccessResponse
description: "[説明]"
properties:
  so:
    type: object
    $ref: ./02_[header].yml
    description: 出荷予定ヘッダ
  soDetail:
    type: array
    items:
      $ref: ./03_[detail].yml
    description: 出荷予定明細
```

---

## ファイル反映手順

### BFF側（`.tsp` → `bffWeb.yml` は自動生成）

`bffWeb.yml` のtags/pathsは**手動編集しない**。`.tsp` ファイル作成＋`main.tsp`へのimport追加後、以下のいずれかで生成を確認する：

```bash
node scripts/generate-bff-openapi.mjs   # src/openapi/bffWeb.yml を再生成
# または
./gradlew clean classes                  # ビルド時にcompileBffTspタスクが実行される
```

コンパイルエラーだけを素早く確認したい場合:

```bash
cd src/tsp && npx tsp compile bffWeb/main.tsp --no-emit
```

### msGrpc.yml の更新

**① tagsセクションに追加:**
```yaml
  - name: "[大分類Pascal] / [中分類Pascal] / [小分類Pascal] / [機能名Pascal]"
    description: [機能の日本語説明]
```

**② pathsセクションに追加:**
```yaml
  /v1.[大分類lc].[中分類lc].service.[中分類Pascal][小分類Pascal][機能名Pascal]Service/[メソッド名]:
    $ref: "./paths/grpc/v1/[大分類Dir]/[中分類Dir]/[小分類Dir]/[ID]_[feature].yml#/paths/~1[メソッド名]"
```

---

## $ref 相対パス早見表（gRPC側のみ。BFF側はTypeSpecのモデル名参照のため`$ref`不要）

| 参照元 → 参照先 | 相対パス |
|----------------|----------|
| paths/grpc/...（深さ6）→ components/ | `../../../../../../components/` |
| components/grpc/.../requests/[feature]/ → components/common/ | `../../../../../../../../components/common/` |
| 同一ディレクトリ内ファイル参照 | `./[ファイル名].yml` |

---

## 実行手順（チェックリスト）

生成時は以下の順番で進めてください：

1. [ ] **作業ブランチを作成する** ← `git checkout -b feature/<機能名>` でブランチを作成してから生成を開始する
2. [ ] BFF機能ファイル（`.tsp`）を作成する（モデル＋オペレーションを1ファイルに）
3. [ ] `main.tsp` にimportを1行追加する
4. [ ] `npx tsp compile bffWeb/main.tsp --no-emit`（`src/tsp`配下）でBFF側の構文エラーがないか確認する
5. [ ] gRPC pathファイルを作成する
6. [ ] gRPC リクエストコンポーネントを作成する（API数分）
7. [ ] gRPC レスポンスコンポーネントを作成する（API数分・複合構造は分割）
8. [ ] `msGrpc.yml` のtagsとpathsを更新する
9. [ ] `node scripts/generate-bff-openapi.mjs` を実行し `src/openapi/bffWeb.yml` が意図通り生成されることを確認する（生成物はコミット対象外）
10. [ ] **AI生成ソースをコミットする** ← `git commit -m "#<チケット番号> [ai] <機能名> 初期生成"` でコミットして初回生成の境界を記録する
11. [ ] ビルドして動作確認する（**初回生成後の手修正**が必要な場合は `[manual]` prefixで都度コミット）

> **⚠️ スコープ**: 手順1のブランチ作成・手順10の`[ai]`コミット・手順11の`[manual]`コミットは**このスキルによる初回生成フローでのみ実施する**。
> 初回生成後にClaudeを使って修正する場合は通常の開発フローに従い、ブランチ作成や特殊なコミットは不要。

---

## 注意事項

- **`src/openapi/{bffWeb,bffMobile,bffCommon,bffManual}.yml` を直接編集しない**: これらは`.tsp`からの生成物（gitignore対象）。修正が必要な場合は必ず対応する`.tsp`を編集して再生成する
- **既存ファイルへの上書き厳禁**: 同一機能名の`.tsp`ファイル・gRPC YAMLファイルが既に存在する場合、ユーザーに確認してから上書きする
- **設計書に存在しないフィールドの追加禁止**: モデル/コンポーネントには設計書の項目定義にあるフィールドのみを定義すること
- **`（基本設計に記載なし）`等のプレースホルダーが残る項目**: 憶測で断定せず、`@doc`に「（要確認）」を付記した上でチャットで確認を促す
- **【初回生成時のみ】作業ブランチを必ず作成してから生成を開始する**: `git checkout -b feature/<機能名>` でブランチを切ること。ブランチ名の例: `feature/so-mainte`
- **【初回生成時のみ】AI生成後は必ずコミットしてから手修正する**: AI生成ソースと手修正ソースを後から区別できるよう、以下のコミットprefixを使用すること（初回生成後にClaudeで修正する場合は通常の開発フローに従い不要）

  | prefix | 意味 | 例（チケット番号: 123） |
  |--------|------|------------------------|
  | `[ai]` | Claude が生成したソース | `#123 [ai] soMainte 初期生成` |
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

