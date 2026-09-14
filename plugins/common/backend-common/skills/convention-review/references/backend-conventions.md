# 開発規約：バックエンド（Java / Spring Boot）

## 1. はじめに

### 1.1 本規約の目的・適用範囲

本規約はバックエンド（Java / Spring Boot）の開発者が守るべきルールと推奨事項を定める。  
適用対象は本プロジェクトのバックエンドリポジトリ（`.java` ファイル）全般とする。

### 1.2 参考規約

本規約は以下の公式スタイルガイドおよびプロジェクトの Checkstyle 設定を参考に策定している。  
本規約に記載のない事項については、下記を参照すること。

| 規約 | URL |
|------|-----|
| Google Java Style Guide | [https://google.github.io/styleguide/javaguide.html](https://google.github.io/styleguide/javaguide.html) |

### 1.3 ツールで自動適用・チェックされるルールについて

本プロジェクトでは、整形・静的解析・テストをツールで自動化している。各ツールの最終的な判定は、共通の Gradle 規約プラグイン（`com.sst.fw.build`？？？）および各リポジトリの設定に従う。  
本規約とツール設定に差異がある場合は、ツール設定を正とする。

| タイミング | ツール / コマンド | 内容 | 失敗時 |
|---|---|---|---|
| ファイル保存時 | Prettier（`editor.formatOnSave` が有効な場合） | エディタ上で自動整形 | 保存処理を確認する |
| `git commit` | lint-staged → Prettier | ステージ済みの `.java` / `.sql` を整形し、整形後の内容を再ステージ | コミット失敗 |
| `git commit` | commitlint | コミットメッセージを Conventional Commits 形式で検査 | コミット失敗 |
| `git push` 前 | `./gradlew clean check` | Prettier、Checkstyle、SpotBugs、JUnit を実行 | push 中止 |
| `git push` 後 | AWS CodeBuild（SonarQube / Amazon Inspector） | 品質ゲート判定、SBOM の脆弱性スキャン | CI の結果に応じて対応 |

`./gradlew clean check` に含まれる主なチェックは以下のとおりとする。

| ツール | 役割 | 扱い |
|---|---|---|
| Prettier | Java / SQL の整形差分検査 | 違反時はビルド失敗 |
| Checkstyle | Google Java Style Guide ベースのソース規約検査 | 違反時はビルド失敗 |
| SpotBugs | バグパターン・潜在的問題の静的解析 | 違反時はビルド失敗 |
| JUnit | 単体テストの実行 | テスト失敗時はビルド失敗 |
| JaCoCo | カバレッジレポートの生成 | 現状は閾値なし |
| ErrorProne / NullAway | コンパイル時の不具合・null 安全性検査 | 現状は警告のみ |

Checkstyle、SpotBugs などの共通設定は `sst-fw-be-starter-platform` で管理し、各リポジトリ側でチェック内容を上書きしない。  
なお、Prettier の対象外である import の並び順、Markdown・YAML・JSON の記述内容、業務上の命名や設計判断は、開発者が手動で確認する。

Checkstyle 設定ファイル: `sst-fw-be-starter-platform/fw-be-starter-build/src/main/resources/com/fw/build/checkstyle.xml`

---

## 2. プロジェクト構成

### 2.1 GitHub リポジトリ

**フレームワーク（sst-fw- プレフィックス）**

[sst-fw-be-starter-platform](https://github.com/suzuyo-cm/sst-fw-be-starter-platform)<br>
[sst-fw-be-core](https://github.com/suzuyo-cm/sst-fw-be-core)<br>
[sst-fw-be-http](https://github.com/suzuyo-cm/sst-fw-be-http)<br>
[sst-fw-be-grpc](https://github.com/suzuyo-cm/sst-fw-be-grpc)<br>
[sst-fw-be-security](https://github.com/suzuyo-cm/sst-fw-be-security)<br>

**アプリケーション（cm-be- プレフィックス）**

[cm-be-spec](https://github.com/suzuyo-cm/cm-be-spec)<br>
[{repo}](https://github.com/suzuyo-cm/{repo})<br>

### 2.2 パッケージ構成

各層（Controller / Service / gRPC クライアント / Mapping）の責務境界を以下のように定義する。  
`dto/` は HTTP リクエスト/レスポンス用、`model/` は gRPC メッセージ用として使い分ける。

業務機能のパッケージは、`{domain}/{subdomain}/{feature}` の階層で構成する。`{domain}` は中分類、`{subdomain}` は小分類を表し、機能フォルダは連番を含まない lowerCamelCase の機能名とする。各レイヤーで同じ分類・機能フォルダを使用し、機能名とクラス名の対応を保つ。

#### 2.2.1 BFF

```
...
src/main/java/{basePackage}/　　　　　　　　　　　　　　　　　　　　　    　　 **
├── {ApplicationClass}.java                                                 ** Spring Boot エントリーポイント
├── controller/                                                             ** controllerフォルダ
│   └── {domain}/                                                           ** 中分類（例: core）
│       └── {subdomain}/                                                    ** 小分類（例: so）
│           └── {feature}/                                                  ** lowerCamelCaseの機能名（例: soPlanSearch）
│               └── {Feature}Controller.java                                ** コントロールファイル
├── service/                                                                ** serviceフォルダ
│   ├── auth/                                                               ** 認証サービスフォルダ
│   └── {domain}/                                                           ** 中分類
│       └── {subdomain}/                                                    ** 小分類
│           └── {feature}/                                                  ** 機能名
│               ├── {Feature}Service.java                                   ** サービスファイル
│               └── {Feature}ServiceImpl.java                               **
├── infrastructure/                                                         **
│   ├── grpc/                                                               ** grpcフォルダ
│   │   └── {domain}/                                                       ** 中分類
│   │       └── {subdomain}/                                                ** 小分類
│   │           └── {feature}/                                              ** 機能名
│   │               ├── {Feature}Client.java                                ** クライアントファイル
│   │               └── {Feature}ClientImpl.java                            **
│   ├── mapping/                                                            ** mappingフォルダ
│   │   └── {domain}/                                                       ** 中分類
│   │       └── {subdomain}/                                                ** 小分類
│   │           └── {feature}/                                              ** 機能名
│   │               ├── {Feature}ServiceMapping.java                        ** サービスマッピングファイル
│   │               └── {Feature}ControllerMapping.java                     ** コントロールマッピングファイル
│   ├── message/                                                            ** Kafkaプロデューサーフォルダ（非同期メッセージ送信）
│   ├── repository/                                                         ** Redisセッション管理フォルダ
│   ├── azure/                                                              ** Azure Computer Vision（OCR）フォルダ
│   ├── bedrock/                                                            ** AWS Bedrock（AI）フォルダ
│   ├── logging/                                                            ** 操作ログフォルダ
│   └── zxing/                                                              ** バーコード処理フォルダ
├── dto/                                                                    ** BFF内部専用データクラスフォルダ
│   ├── app/                                                                ** アプリ状態（権限コンテキスト等）
│   ├── request/                                                            ** BFF内部リクエスト
│   └── response/                                                           ** BFF内部レスポンス
├── model/                                                                  ** OpenAPIモデル補完・拡張クラスフォルダ
├── security/                                                               ** JWT認証・認可フォルダ
├── configuration/                                                          ** configurationフォルダ
│   └── GrpcClientConfiguration.java                                        **
├── annotation/                                                             ** カスタムアノテーションフォルダ
├── aspect/                                                                 ** AOPフォルダ（操作ログ等の横断処理）
├── common/                                                                 ** 共通例外・JSON処理フォルダ
├── constant/                                                               ** 定数クラスフォルダ
└── util/                                                                   ** ユーティリティフォルダ
...
```

#### 2.2.2 マイクロサービス

```
...
src/main/java/{basePackage}/
├── {ApplicationClass}.java                                                 ** Spring Boot エントリーポイント
├── grpc/                                                                    ** gRPCフォルダ
│   └── {domain}/                                                           ** 中分類
│       └── {subdomain}/                                                    ** 小分類
│           └── {feature}/                                                  ** 機能名
│               └── {Feature}Grpc.java                                     ** gRPCサービスファイル
├── service/                                                                ** サービスフォルダ
│   └── {domain}/                                                           ** 中分類
│       └── {subdomain}/                                                    ** 小分類
│           └── {feature}/                                                  ** 機能名
│               ├── {Feature}Service.java                                  ** サービスファイル
│               └── {Feature}ServiceImpl.java                              **
├── infrastructure/                                                         **
│   └── mapping/                                                            ** マッピングフォルダ
│       └── {domain}/                                                       ** 中分類
│           └── {subdomain}/                                                ** 小分類
│               └── {feature}/                                              ** 機能名
│                   └── {Feature}ServiceMapping.java                       ** サービスマッピングファイル
├── persistence/                                                            **
│   ├── mapper/                                                             ** マッパーフォルダ
│   │   └── {domain}/                                                       ** 中分類
│   │       └── {subdomain}/                                                ** 小分類
│   │           └── {feature}/                                              ** 機能名
│   │               └── {feature}Mapper.java                                ** マッパーファイル
│   └── model/                                                              ** モデルフォルダ
│       └── {domain}/                                                       ** 中分類
│           └── {subdomain}/                                                ** 小分類
│               └── {feature}/                                              ** 機能名
│                   └── {Feature}Entity.java                                ** エンティティファイル
├── dto/                                                                    ** マイクロサービス内部用データクラスフォルダ
├── configuration/                                                          ** configurationフォルダ
├── helper/                                                                 ** ヘルパーフォルダ
├── util/                                                                   ** ユーティリティフォルダ
...
```

MyBatis の XML（`src/main/resources/mybatis/mapper/`）も、`{domain}/{subdomain}/{feature}/` の分類体系に従って配置する。

---

## 3. 命名規則

> ビジネス用語（取引先・倉庫・ドメイン名 等）の命名は [DB命名規則](../common/503847_feature_db_convention.md) の用語定義を参照すること。

| 対象 | 規則 | 例 |
|------|------|----|
| クラス名 | UpperCamelCase | `OrderService`、`StockController` |
| インターフェース名 | UpperCamelCase | `OrderService`、`StockRepository` |
| Enum / Record / アノテーション | UpperCamelCase | `OrderStatus`、`OrderDto` |
| メソッド名 | lowerCamelCase | `findOrderById()`、`updateStock()` |
| 変数名 | lowerCamelCase | `orderId`、`warehouseCode` |
| 定数 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`、`DEFAULT_PAGE_SIZE` |
| パッケージ名 | すべて小文字 | `{basePackage}` |
| 型パラメータ | 1文字または `XxxT` 形式 | `T`, `E`, `ResponseT` |

### 3.1 技術固有の命名（クラスサフィックス）

ファイル名から役割が判断できるよう、以下のサフィックスを統一する。

| 層 | サフィックス | 例 |
|------|----------|-----|
| Controller | `Controller` | `OrderController` |
| Serviceインターフェース | サフィックスなし | `OrderService` |
| Service実装 | `ServiceImpl` | `OrderServiceImpl` |
| gRPCサービス実装 | `Grpc` | `OrderGrpc` |
| gRPCクライアントインターフェース | `Client` | `OrderClient` |
| gRPCクライアント実装 | `ClientImpl` | `OrderClientImpl` |
| Serviceマッピング | `ServiceMapping` | `OrderServiceMapping` |
| Controllerマッピング | `ControllerMapping` | `OrderControllerMapping` |
| MyBatisマッパー | `Mapper` | `OrderMapper` |
| エンティティ | `Entity` | `OrderEntity` |

### 3.2 変数名

DBカラム名や業務仕様で定義された英語の用語を基準に命名する。DBカラム名が`snake_case`の場合は、Javaの命名規則に合わせて`camelCase`へ変換するが、単語自体を別の英語や日本語ローマ字へ置き換えない。

| DBカラム名 | Javaの変数名 | 備考 |
|---|---|---|
| `item_id` | `itemId` | DBの単語と意味を維持する |
| `rcv_qty` | `rcvQty` | 承認済み略語`rcv`を維持する |
| `is_active` | `isActive` | 真偽値の意味を維持する |
| `warehouse_cd` | `warehouseCd` | DB規約のコード接尾辞を維持する |

- フィールド、ローカル変数、メソッド引数はlower camel case（`camelCase`）で記述する
- 日本語ローマ字（`soshiki`、`kanri`、`kenpin`など）は使用しない
- 略語は共通命名規約またはDB命名規約で承認されたものだけを使用し、一覧にない語は原則として省略しない
- `data`、`info`、`value`、`temp`など、対象や意味が分からない名前は避ける
- 型名を変数名に埋め込まない（`orderString`、`countInt`などは使用しない）
- 意味のない1文字の変数名は使用しない。ただし、`i`、`j`などはループカウンターに限り許容する

```java
// ✅ DB・業務用語の単語を維持し、対象を明示する
String warehouseCode;
Integer rcvQty;
LocalDate shippingDate;

// ❌ 日本語ローマ字、曖昧な語、型名の埋め込み
String soukoCd;
Integer dataInt;
LocalDate dateValue;
```

#### 3.2.1 boolean 型

**基本原則：`if` 文の中で読んだときに意味が通り、何を判定しているか分かる名前にする。**

boolean変数は、肯定形を基本とし、単なるデータ型ではなく、状態・存在・能力などの意味を表す名前にする。

❌ **避ける命名**

- `xxxFlg`、`xxxFlag`、`xxxKbn`など、型や意味が分からない日本語由来の略語
- `isInvalid`、`isNotAvailable`など、条件判定時に二重否定になる否定形
- `exists`、`valid`、`value`など、対象や判定内容が分からない名前
- `shouldXxx`、`needsXxx`など、単純な状態ではなく業務判断と混同しやすい名前

`is`、`has`、`can`は必須の接頭辞ではない。判定の意味に応じて、次のような名前から最も自然なものを選択する。

| 命名 | 表す内容 | 例 |
|---|---|---|
| `is` / `are` | 状態・性質 | `isActive`、`isInitialized`、`areItemsValid` |
| `is...ed` | 特定の処理が完了している状態 | `isLoaded`、`isCalculated`、`isUpdated` |
| `has` | 所有・存在・包含 | `hasPermission`、`hasAttachment`、`hasChildren` |
| `can` | 能力・許可・可能性 | `canEdit`、`canRetry`、`canAllocate` |
| `is...able` | 可能・実行可能な状態 | `isEditable`、`isRetryable`、`isAllocatable` |
| 対象 + 述語 | `is`・`has`・`can`だけでは関係を表しにくい場合 | `userExists`、`orderContainsItem` |
| `is...Required` | 業務上の必要性 | `isApprovalRequired`、`isRetryRequired` |

`exists`、`contains`、`includes`、`supports`、`requires`、`allows`、`matches`などは、変数名として使用できる。変数へ判定結果を保持する場合は、対象と判定内容が分かる名前にする。能力や許可を表す場合は`canXxx`、実行可能な状態や性質を形容詞で表す場合は`isXxxable`を使用できる。`able`単独や、不自然な語順の`xxxAble`は使用せず、英語として自然な形容詞にする。

```java
boolean isActive = ...;                 // 有効な状態か
boolean hasPermission = ...;            // 権限を持っているか
boolean canEdit = ...;                  // 編集できるか
boolean orderContainsItem = ...;        // 注文に商品が含まれるか
boolean systemSupportsEncryption = ...; // 暗号化に対応しているか
boolean userExists = ...;               // 対象を明示した判定結果
boolean isApprovalRequired = ...;       // 承認が必要かという業務判断
```

なお、単純な所有・包含を表す場合は`hasItem`などの`has`形式を優先し、対象間の関係を明示する必要がある場合に`orderContainsItem`などの対象先行形式を使用する。

#### 3.2.2 boolean型とBoolean型

値が必ず`true`または`false`のいずれかで確定している場合は、プリミティブ型の`boolean`を使用する。`Boolean`型は原則として使用せず、`null`を「未指定」「不明」「DB上のNULL」として扱う必要がある場合に限り使用する。

`null`と`false`を区別する必要がない変数やDTOのフィールドには、`Boolean`を使用しない。使用する場合は、`null`が何を意味するかを設計上明確にする。

| 使用箇所 | 型 | ルール |
|---|---|---|
| ローカル変数・引数・戻り値 | `boolean` | 原則として`boolean`を使用する。`Boolean`は使用しない |
| ジェネリクスの型引数 | `Boolean` | `List<Boolean>`、`Optional<Boolean>`など、プリミティブ型を指定できない場合に限り使用する |
| DBのNULL許容カラムに対応するEntityフィールド | `Boolean` | DBのNULLを保持する必要がある場合に限り使用する |
| JSON部分更新（PATCH）DTO | `Boolean` | `null`（未指定）と`false`（明示指定）を区別する必要がある場合に限り使用する |

#### boolean型とBoolean型のgetter

LombokとOpenAPI Generatorで、boolean型のgetter自動生成規則が異なる。どちらで生成されたクラスかを意識したうえで、呼び出し側のgetter名を確認する。

**Lombok（DTO / Entity）**

プリミティブ型の`boolean`とラッパー型の`Boolean`で挙動が異なる。`boolean`はフィールド名の`is`接頭辞を重複させないが、`Boolean`は常に`get`接頭辞になる。

```java
// boolean型: getterはisActive()
private boolean active;

// Boolean型: getterはgetActive()
private Boolean active;

// boolean型でフィールド名にis接頭辞を付けた場合: 重複させずgetterはisActive()のまま
private boolean isActive;

// Boolean型でフィールド名にis接頭辞を付けた場合: getterはgetIsActive()になる
private Boolean isActive;
```

**OpenAPI Generator が生成するDTO**

生成モデルは常に`Boolean`ラッパー型として出力され、フィールド名の`is`接頭辞の有無に関わらず、getterは常に`get`接頭辞になる（Lombokのようにプリミティブ`boolean`とみなして`is`接頭辞を維持する処理は行われない）。

```java
// cm-be-spec/build/generated/.../AuthCommonEntraPostTokenRequest.java
private Boolean forceLogin = false;
public Boolean getForceLogin() { ... }

// isActiveのようにis接頭辞を付けたプロパティも、getterはgetIsActive()になる
```

#### 3.2.3 String 型

値の意味が明確な名詞を使用する。`xxxStr`、`xxxString` などの型名サフィックスは付けない。

```java
// ✅
String orderId;
String warehouseName;
String warehouseCode;

// ❌
String orderIdStr;
String nameString;
```

#### 3.2.4 数値型（int / long / double 等）

値の意味に応じたサフィックスを付ける。`xxxNum`、`xxxInt` のような型名サフィックスは付けない。

| 用途 | サフィックス例 | 例 |
|------|------------|-----|
| 件数・個数 | `Count`、`Size` | `itemCount`、`pageSize` |
| 数量 | `Quantity`、`Amount` | `stockQuantity`、`orderAmount` |
| 金額 | `Price`、`Amount`、`Fee` | `unitPrice`、`totalAmount` |
| 順番・順序 | `Order`、`Sequence` | `sortOrder`、`displaySequence` |
| 上限・下限 | `Max`、`Min`、`Limit` | `maxRetryCount`、`limitSize` |

---

## 4. コメントの書き方

### 4.1 基本理念

コメントは、コードだけでは読み取れない背景・意図・制約・妥協点を補足するために記載する。コメントを追加する前に、変数名・メソッド分割・クラス設計で説明できないかを検討する。

| 情報 | 表現方法 | 例 |
|---|---|---|
| What（何をするか） | 変数名・メソッド名・クラス名と実装で表現する | `confirmOrder`は注文を確定する処理である |
| How（どのようにするか） | コードで表現する | ステータスを`CONFIRMED`に変更し、確定日時を設定する |
| Why（なぜそうするか） | 必要な場合にコメントで表現する | 出荷ラベル発行後の変更を防ぐ業務ルールがある |
| Who / When（誰が・いつ変更したか） | Gitのコミット履歴や案件管理で管理する | 変更者・変更日・案件番号 |

コメントは、現在も有効な内容だけを記載し、実装を変更したときは関連するコメントが実装と一致しているか確認する。一致しないコメントは修正または削除する。

### 4.2 インラインコメント

実装コメント（`//`）は、そのクラス内で完結する実装の補足に限り、`private`メソッドまたは`private`フィールドに記載する。`//`の後ろには必ずスペースを入れる。

他のファイルから参照される`public`または`protected`のクラス、メソッド、フィールドには、インラインコメントではなくJavadocで仕様・制約を記載する。

次のいずれかに該当する場合は、インラインコメントを記載する。

- 業務ルールの理由を補足する必要がある
- 外部仕様との互換性を維持する必要がある
- 性能・セキュリティ・トランザクション上の制約がある
- 一見すると不自然な実装を採用している理由がある

#### コードから目的が分かりにくい場合の補足

外部ライブラリやフレームワークの呼び出し、複雑なSQL、複数の処理をまとめたブロックなど、コードだけでは処理の目的や対象が分からない場合は、Whatを補足するコメントを記載してよい。処理内容を逐語的に説明するのではなく、コードから読み取れない目的・対象・前提を簡潔に記載する。

コメントは現在も有効な内容だけを記載し、実装を変更したときは関連するコメントが実装と一致しているか確認する。一致しないコメントは修正または削除する。

```java
// ✅ コードだけでは目的が分かりにくいため、処理の目的を補足する
// 出荷確定後に在庫引当を行い、引当結果を後続の出荷処理で利用する。
allocateStock(order);

// ✅ 特殊な設定値の理由
int maxRetry = 3; // 外部APIのRate Limitが1秒間に3回までのため

// ✅ 特殊な業務ルールの背景
// 物流費高騰に伴う新ルールのため、離島以外でも大型商品には追加料金を適用する。
if (item.isLarge() && !address.isIsland()) {
    fee += 1000;
}

// ✅ 外部仕様との互換性を維持する理由
request.setHeader("X-Client-Version", clientVersion); // 旧クライアントがこのヘッダーを参照するため

// ✅ 性能上の制約
Pageable pageable = PageRequest.of(page, 100); // DBの最大取得件数を100件に制限するため

// ✅ セキュリティ上の制約
recordLoginResult(userId); // パスワードやトークンはログ照会・APMに出力しない

// ✅ トランザクション境界の理由
publisher.publish(event); // DBコミット後に送信し、ロールバック済みのデータを通知しないため

// ❌ メソッド名と処理を繰り返している
validateOrder(order); // 注文を検証する

// ❌ 値の意味や理由を説明していない
int timeout = 30; // タイムアウト

// ❌ コードをそのまま説明している
int itemCount = items.size(); // 商品数を取得する
```

### 4.3 禁止事項

#### 変更履歴をコメントで管理しない

修正箇所を示すStart/Endコメントや、作成者・作成日・修正日・修正内容・案件番号などの履歴情報を、コメントやJavadocで管理しない。変更のまとまりや作業履歴は、Gitで管理する。

```java
// ❌ Start/Endコメントや変更履歴をソースコードに残さない
// 2026-08-19 U2000-000 オーダーID処理改善 START
// 2026-08-21 山田 U2000-001 対応開始
confirmOrder(order);
```

#### 不要なコードをコメントアウトしない

修正によって不要になったコードは、コメントアウトしたまま残さず削除する。将来の参考や復元が必要な場合も、Gitのコミット履歴で追跡できるため、ソースコード内に保持しない。

```java
// ✅ 不要なコードは削除する
public void processOrder(String orderId) {
    validateOrder(orderId);
    updateOrder(orderId);
}

// ❌ 不要なコードをコメントアウトしたままにしない
public void processOrder(String orderId) {
    // validateOrder(orderId);
    // updateOrder(orderId);
    newProcessOrder(orderId);
}
```

### 4.4 Javadoc

Javadoc（`/** ... */`）は、そのクラスやメソッドを呼び出す側に向けて仕様を伝える説明書である。他のファイルから参照される`public`または`protected`の要素には、呼び出し側が知る必要のある仕様・制約をJavadocで記載する。クラス内で完結する`private`要素の複雑なロジックはインラインコメントに記載し、Javadocには記載しない。

#### 4.4.1 記述ルール

- 冒頭に、何をするものかを日本語1文で簡潔に記載し、概要文はピリオド（`.`）で終える。「このクラスは」「このメソッドは」などの冗長な定型句は使用しない
- `@param`、`@return`、`@throws`などで、引数・戻り値・例外の仕様と、null・空値・境界値・異常時の動作など呼び出し側が知る必要のある制約を記載する
- 原則として日本語で記述する。`@author`は初版作成者に限り記載してよい。初版以降の変更者・変更日・変更内容はGitの履歴で管理し、Javadocへ追記しない。`@since`、修正履歴、対応案件番号は記載しない
- `@Override`メソッドは、継承元のJavadocで契約が十分に説明されている場合は省略できる。実装固有の仕様や制約を補足する場合は`{@inheritDoc}`を使用する

```java
/**
 * 指定された注文を取得します.
 *
 * @param orderId 注文ID。nullまたは空文字は許可しません。
 * @return 注文情報
 * @throws NotFoundException 指定された注文が存在しない場合
 * @throws BadRequestException 注文IDがnullまたは空文字の場合
 */
public Order findById(String orderId) {
    // ...
}
```

```java
/**
 * 指定された条件に一致する注文を検索します.
 *
 * <p>該当する注文がない場合は空のリストを返します。</p>
 *
 * @param condition 検索条件。nullは指定できません。
 * @return 注文一覧。該当なしの場合は空のリスト
 * @throws BadRequestException 検索条件がnullまたは不正な場合
 */
public List<Order> search(OrderSearchCondition condition) {
    // ...
}
```

```java
/**
 * 注文を確定します.
 *
 * <p>同じ注文IDに対する呼び出しは冪等に処理されます。</p>
 *
 * @param orderId 確定する注文ID
 * @return 確定後の注文
 * @throws NotFoundException 注文が存在しない場合
 * @throws ConflictException すでに出荷済みの場合
 */
public Order confirm(String orderId) {
    // ...
}
```

```java
/**
 * {@inheritDoc}
 *
 * <p>検索結果は利用者の権限に応じて絞り込みます。</p>
 */
@Override
public Order findById(String orderId) {
    // ...
}
```

**必須箇所**

- `public` クラス、インターフェース、Enum、Record、アノテーション
- `public` または `protected` の内部クラス、内部インターフェース、内部 Enum、内部 Record、内部アノテーション
- `public` または `protected` メソッド（getter / setter、`@Test` が付いたメソッドは除外可）

---

## 5. フレームワーク固有ルール

### 5.1 レイヤー責務

| 層 | 責務 | 禁止事項 |
|----|------|----------|
| Controller | リクエスト受付・バリデーション・レスポンス返却 | 業務ロジックを書かない |
| Service | 業務ロジック・トランザクション管理 | DBアクセスを直接行わない |
| gRPC Client | 下流マイクロサービスへの通信 | 業務判断を行わない |
| Mapper / Mapping | オブジェクト変換のみ | ロジックを持たない |

### 5.2 MapStruct（DTOマッピング）

`@Mapper` 設定を各クラスに分散すると、`componentModel` 等の共通設定を変更する際に全ファイルを修正する必要が生じる。`BaseMapping` に集約することで変更が1ファイルに集中する。また `unmappedTargetPolicy = ERROR` にすることで、フィールド追加時のマッピング漏れをコンパイル時に検知でき、実行時にサイレントにデータが欠落する事故を防ぐ。

- `@Mapper` アノテーション設定は `BaseMapping` に集約し、個別 Mapping クラスは継承のみとする
- `unmappedTargetPolicy = ERROR` を原則とし、マッピング漏れをビルドエラーで検知する
- `dto/` は HTTP リクエスト/レスポンス用、`model/` は gRPC メッセージ用として使い分ける

**Mapperの責務**

- Mappingクラスは、MapStructによるオブジェクト変換のみを担う
- JSON文字列のパース、業務バリデーション、ファイルI/Oなど、副作用を伴う処理はMapperに実装しない。Service層で処理し、変換済みの単純な値のみをMapperへ渡す
- gRPC Clientクラスにマッピングまたはバリデーションロジックを直接書かない

**悪い例（gRPC Clientで業務判断・変換を行っている）**: JSON文字列のパースに失敗した場合に`BadRequestException`をthrowする処理や、リクエストのビルド前に行う入力バリデーションをClient内に実装すると、Client層が「下流マイクロサービスへの通信」を超えた責務を持ってしまう。このような処理はService層に置く。

```java
// ❌ gRPC Clientでバリデーション・例外throwを行わない
public CreateResponse create(String publicTargetsJson) {
    List<PublicTarget> targets = parsePublicTargets(publicTargetsJson); // JSONパース+例外throwをClientに実装している
    return stub.create(toRequest(targets));
}

// ✅ バリデーション・パースはServiceで行い、Clientには変換済みの値のみ渡す
// Service
public CreateResponse create(String publicTargetsJson) {
    List<PublicTarget> targets = validateAndParse(publicTargetsJson);
    return {feature}Client.create(targets);
}
```

**検討事項**
Mapstruct configを使って毎回同じプロパティを設定する必要がないようにしたい。
Mapstructで行うことが原則だが、例外があった場合の対応も必要。

### 5.3 MyBatis（データアクセス）

- クエリパラメータは必ず `#{}` を使用する（`${}` によるSQL組み立ては禁止）

```xml
<!-- ✅ プリペアドステートメント -->
WHERE order_id = #{orderId}

<!-- ❌ インジェクション危険 -->
WHERE order_id = ${orderId}
```

### 5.4 例外処理・エラーハンドリング

業務上エラーとなるケースは `sst-fw-be-core` で定義された独自例外クラスを使用する。  
例外のレスポンス変換は各モジュールのグローバルハンドラーに集約し、Controller 内での個別 `try-catch` によるレスポンス生成は禁止。

- Controllerでは、業務例外を捕捉するための`try-catch`を行わない
- Controllerでは、業務例外を自ら`throw`しない。業務上の妥当性判断はServiceで行い、Controllerはその結果（正常時のレスポンスまたは伝播してきた例外）をそのまま扱う
- ServiceやClientで発生した例外は、Controllerで握りつぶしたり別のレスポンスへ変換したりせず、グローバルハンドラーへ伝播させる
- Controllerは、リクエストの受付、入力値のバリデーション、Serviceの呼び出し、正常時のレスポンス返却に専念する
- 外部APIやDBなどの例外を別の独自例外へ変換する必要がある場合は、Controllerではなく、外部APIを呼び出すClientや業務判断を行うServiceで処理する

```java
// ✅ Controllerでは例外を捕捉せず、グローバルハンドラーへ伝播させる
@PostMapping
public OrderResponse create(@RequestBody CreateOrderRequest request) {
    return orderService.create(request);
}

// ❌ Controllerで業務例外を捕捉してレスポンスを個別生成しない
@PostMapping
public ResponseEntity<OrderResponse> create(@RequestBody CreateOrderRequest request) {
    try {
        return ResponseEntity.ok(orderService.create(request));
    } catch (ConflictException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(null);
    }
}

// ❌ Controllerで業務判断を行い、自ら例外をthrowしない
@PostMapping
public OrderResponse create(@RequestBody CreateOrderRequest request) {
    if (orderService.exists(request.getOrderId())) {
        throw new ConflictException(ErrorCodeEnum.ORDER_ALREADY_EXISTS);
    }
    return orderService.create(request);
}
```

### 5.5 DI（依存性の注入）

フィールドインジェクション（`@Autowired`）は以下の問題があるため禁止する。
（1）Spring コンテナなしでは注入できないため単体テストで `new XxxServiceImpl()` と書けずモックを渡せない。
（2）依存クラスが静默的に増えやすく、クラスの肥大化に気づきにくい。
（3）`final` を付けられずイミュータブルにできない。コンストラクタインジェクションであればこれらすべて解消できる。

コンストラクタインジェクションを使用する。Lombok の `@RequiredArgsConstructor` で簡略化する。フィールドインジェクション（`@Autowired`）は禁止。

```java
// ✅
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private final OrderMapper orderMapper;
}

// ❌ フィールドインジェクション禁止
@Autowired
private OrderMapper orderMapper;
```

### 5.6 バリデーション

バリデーションは、入力値の形式を確認する検証と、業務上の妥当性を確認する検証に分けて実施する。BFFとマイクロサービスの責務は次のとおりとする。

| 実施箇所 | 検証対象 | 実装方法 |
|---|---|---|
| BFF | 必須、文字数、形式、数値範囲、列挙値など、リクエスト単体で判定できる内容 | TypeSpec で記述し、自動生成されたBean Validationで検証する |
| マイクロサービス | マスタの存在、一意性、状態遷移、複数項目の整合性など、DBや業務ルールに基づく内容 | Service層で手動検証する |

#### BFFのバリデーション

BFFが公開するAPIの形式的な検証は、原則としてTypeSpecに記述する。Controllerや生成されたDTOに、Jakarta Bean Validationアノテーションを手動で追加・変更してはならない。

```typespec
// cm-be-spec/src/tsp/.../xxx.tsp
model CreateOrderRequest {
    @doc("注文ID")
    orderId: string;

    @doc("数量")
    @minValue(1)
    quantity: integer;
}
```

上記の定義により、生成されるDTOには次のような制約が付与される。

```java
public class CreateOrderRequest {
        @NotNull
        private String orderId;

        @NotNull
        @Min(value = 1)
        private Integer quantity;
}
```

TypeSpecでは、必須指定、`@minLength`/`@maxLength`、`@pattern`、`@minValue`/`@maxValue`、`@format("email")`、`enum`/`union`など、リクエスト単体で判定できる制約を記述する。

#### バリデーションメッセージ

Bean Validationアノテーションの `message()` には、日本語などの文言を直接記述せず、エラーコード（メッセージID、例：`EB-001-000-000-013`）を指定する。メッセージIDに対応する翻訳文言はプロパティファイル（英語・日本語）に登録し、Springが `Accept-Language` ヘッダーに応じて切り替える。この翻訳文言は、グローバルハンドラーがエラーレスポンスへ変換する際にクライアントへ返却される。

標準的な制約には既定のメッセージIDが割り当てられている。既定と異なるメッセージIDを指定する場合や、TypeSpecから自動生成されない制約を追加する場合は、TypeSpecの `@extension` を使用する。

```typespec
// 既に自動生成される @Size のメッセージIDだけを差し替える
@maxLength(20)
@extension("x-size-message", "EB-XXX-XXX-XXX-XXX")
warehouseCd: string;

// 自動生成されない @NotBlank を追加し、メッセージIDをアノテーション内に直接指定する
@extension("x-field-extra-annotation", "@NotBlank(message = \"EB-001-000-000-004\")\n")
alias: string;
```

#### マイクロサービス（gRPC）側のバリデーション

gRPC/Protobuf側では、TypeSpecの制約は自動的にバリデーションへ反映されない。`protobuf-schema` ジェネレータは型とフィールド番号を生成するが、`@minLength`/`@pattern`などの制約は生成しない。また、proto3では未設定のスカラー値がデフォルト値（空文字列、`0`、`false`など）になるため、BFFで検証済みの項目であっても、マイクロサービス側で改めて検証する。

Service層では、必要に応じて必須チェック、マスタ参照、一意性、状態遷移、複数項目の整合性などを実装する。エラーには `sst-fw-be-core` の例外クラスと `ErrorCodeEnum` を使用し、既存のもので表現できない場合は新規に追加してよい。ただし、メッセージは直接記述せず、`messages.properties`/`messages_ja.properties` にメッセージIDを登録し多言語対応を維持する（5.6「バリデーションメッセージ」参照）。

```java
// 手動実装の例（マイクロサービス）
private {Feature}Entity getHeaderOrThrow(String companyCd, String lookupKey)
    throws NotFoundException, BadRequestException {
    if (lookupKey == null || lookupKey.isBlank()) {
        throw new BadRequestException(ErrorCodeEnum.REQUEST_PARAMETER_INVALID);
    }
    ...
}
```

チェックすべき範囲・粒度はサービスの実装内容やDB構造に依存するため、本規約では一律に定めない。各マイクロサービスの実装者が、Service層で必要な検証（必須チェック、マスタ参照整合性、状態遷移の妥当性等）を判断のうえ実装すること。

### 5.7 ログの書き方

本プロジェクトでは、用途に応じて以下のログを使い分ける。

#### 5.7.1 操作ログ

操作ログは、ユーザー操作を後から追跡するためのログである。BFFの`@RestController`を付与したクラスのエンドポイントを対象とし、AOPにより自動記録する。

- 操作ログは、ユーザー情報、HTTPメソッド、APIパス、リクエスト・レスポンス、処理結果、処理時間および例外情報を記録する。
- 操作ログは、ログ専用マイクロサービスへ非同期で送信し、RDSの操作ログテーブルへ保存する。ログ送信の待ち時間は業務APIのレスポンスに影響させない。
- 操作ログの出力を不要とする場合に限り、クラスまたはメソッドへ `@SkipOperationLog` を付与できる。
- `@SkipOperationLog` の付与は例外とし、原則として操作ログを出力する。付与する場合は、アノテーションの直前に出力しない理由をコメントで記載する。

```java
// ヘルスチェックはユーザー操作ではないため、操作ログを記録しない。
@SkipOperationLog
@GetMapping("/health")
public HealthResponse health() {
    // ...
}
```

#### 5.7.2 ログ照会

**ログ照会規約の内容を反映させる**

#### 5.7.3 作業工数用ログ

**作業工数用ログ規約の内容を反映させる**

#### 5.7.4 APMログ

APMのトレース・ログ・メトリクスには、業務ロジック固有の属性やパラメーターを個別実装で付与しない。Controller・Serviceなどの業務ロジックへAPM用の属性設定や専用アノテーションを追加せず、共通基盤による自動付与・自動キャプチャを利用する。

```java
// ❌ 業務ロジックでOpenTelemetryのSpan APIを直接操作し、属性を個別に付与しない
@Service
public class OrderServiceImpl implements OrderService {
    public Order confirm(String orderId) {
        Span span = Span.current();
        span.setAttribute("order.id", orderId);
        span.setAttribute("order.status", "CONFIRMED");
        span.addEvent("order confirmed");
        // ...
    }
}

// ❌ APM計装用の専用アノテーションを業務メソッドへ追加しない
@WithSpan("OrderService.confirm")
public Order confirm(@SpanAttribute("order.id") String orderId) {
    // ...
}
```

#### 5.7.5 サーバーログ

業務上の事象はログ照会用DBへ記録し、技術的な障害はAPMで確認する。処理開始・終了、SQL実行、例外を追跡する目的で、業務アプリケーションから通常のサーバーログを出力しない。

開発中に一時的な調査が必要な場合に限り、`log.debug()`を使用してよい。本番環境では`DEBUG`レベルを有効にしない。調査完了後は、一時的に追加した`log.debug()`を削除する。

**今後修正する内容**
`@Slf4j`を付与した`BaseService`を作成して、各サービスに継承させる。実装方法が確定したら例を記載。

### 5.8 定数・Enum の管理場所

定数・Enumは、使用範囲に応じて`constant/`パッケージまたは利用するクラス内へ配置する。

| 使用範囲 | 配置場所 | 実装形式 |
|---|---|---|
| プロジェクト内の全機能で横断的に使う値（認証パス等） | `constant/` パッケージ直下 | `final` クラス / Enum |
| 同一業務の複数クラスで共通して使う値・状態 | `constant/{domain}/{subdomain}/` 配下 | `final` クラス / Enum |
| 単一クラス内でのみ使う値 | 利用するクラスの内部 | `private static final` |

- 状態を表す値は定数（`String`/`int`等）ではなく Enum で定義する
- 業務で共通して使う定数・Enumは、`constant/{domain}/{subdomain}/`配下へ配置する
- 単一クラスでしか使わない値は、定数クラスを新設せず、利用するクラスの`private static final`として定義する

**プロジェクト全体で共有する例**: `SecurityPathConstant`（認証をバイパスするパス）、`JwtClaimConstant`（JWTクレームキー）は、`WebSecurityConfiguration` など複数のdomainから参照されるため `{basePackage}.constant` 直下に配置する。

**業務共通の例**: 出荷予定業務で複数の機能から使う `soPlanStatusEnum` は、`{basePackage}.constant.core.so` 配下に配置する。出荷予定ステータスが予定かを判定するために`100`のような数値を直接記述せず、`ShippingPlanStatusEnum.PLANNED`を使用する。

```java
@RequiredArgsConstructor
public enum ShippingPlanStatusEnum {
    PLANNED(100),
    SHIPPED(700),
    CANCELED(999);

    private final int code;
}
```

```java
// ✅ Enumを使用して状態を判定する
if (shippingPlanStatus == ShippingPlanStatusEnum.PLANNED) {
    // ...
}

// ❌ DBコードを業務コードへ直接記述しない
if (shippingPlanStatusCode == 100) {
    // ...
}
```

```
{basePackage}/
├── constant/                                ** プロジェクト内の全機能で共有
│   ├── SecurityPathConstant.java
│   ├── JwtClaimConstant.java
│   └── core/                                ** {domain}
│       └── so/                              ** {subdomain}
│           └── SoOrderStatusEnum.java       ** 出荷業務で共通して使う区分値
└── service/core/so/soPlanSearch/
    └── SoPlanSearchServiceImpl.java         ** このクラスだけの定数はクラス内に定義
```

**アンチパターン**: 単一クラスでしか使わない値を`constant/`配下へ置くと、利用箇所と定義場所が離れて追跡しにくくなる。また、DBコードや状態値など定数・Enumで管理できる値を直接記述して判定してはならない。値の意味や変更箇所が分散し、コード値の変更時に修正漏れが発生するためである。

### 5.9 トランザクション管理

具体的な実装方法については、CDCツール + Outboxテーブルの運用方法が決まり次第、記入。


- 参照系メソッドは `@Transactional(readOnly = true)` をクラスレベルに付与する
- 更新系メソッドのみ `@Transactional` をメソッドレベルで上書きする
- `private` メソッドに `@Transactional` を付与しない（AOPプロキシが効かないため）

```java
@Service
@Transactional(readOnly = true)
public class OrderServiceImpl implements OrderService {
    public Order findById(String orderId) { ... }

    @Transactional
    public void updateOrder(OrderDto dto) { ... }
}
```

---

### 5.10 Java 言語仕様

> ※ 以下は Spring Boot 固有ではなく Java 言語レベルの推奨事項

- 可能な限りイミュータブルにする（`final` を積極的に付与する）
- `null` を返すメソッドは作成しない。戻り値が存在しない場合は `Optional<T>` を使用する
- `instanceof` のキャストは Pattern Matching で記述する

> **推奨**: Java 25 の Record・Sealed Classes・Pattern Matching を積極的に活用する

```java
// Record：DTOやValue Objectに使用する
public record DecodedBarcodeResult(String format, String value) {}

// Pattern Matching
// ❌ 従来の書き方：型チェックとキャストが別々の行に分かれる
if (authentication instanceof JwtAuthenticationToken) {
    JwtAuthenticationToken jwtAuth = (JwtAuthenticationToken) authentication;
    return jwtAuth.getToken();
}

// ✅ Pattern Matching：型チェックと同時に変数へバインドされる
if (authentication instanceof JwtAuthenticationToken jwtAuth) {
    return jwtAuth.getToken();
}
```

**Recordを使う理由**: 通常のクラスでDTOやValue Objectを作ると、`equals()`/`hashCode()`/`toString()`/getterを手動実装する必要があり、フィールド追加時にこれらの更新を忘れるとバグの温床になる。Recordはこれらをコンストラクタの引数リストから自動生成するため、記述量を減らしつつ更新漏れを防げる。また全フィールドが自動的に`final`になるため、イミュータブルなValue Objectを強制できる。

**Pattern Matchingを使う理由**: 従来の`instanceof`は、型チェックとキャストが2行に分かれるため、キャストの書き忘れや、型チェックした変数と実際にキャストする変数を取り違えるミスが起こり得る。Pattern Matchingは型チェックと同時に変数へバインドするため、キャストが不要になり、キャスト漏れや`ClassCastException`のリスクを減らせる。

**Sealed Classes を使う場面**: Enumは全バリアントが同じ構造（名前のみ）しか持てないが、Sealed Classesは`permits`で許可するサブタイプを限定しつつ、バリアントごとに異なるフィールドを持たせられる。以下のようなケースで有効。

- 状態ごとに付随データの構造が異なる状態表現（例：注文ステータスを表す際、確定済みなら`confirmedAt`、キャンセル済みなら`canceledReason`のように状態ごとに異なる項目を持たせたい場合）
- 外部レスポンスや処理結果を「成功時の型」「失敗時の型」のように型で分岐させたい場合
- `switch`式とPattern Matchingを組み合わせ、将来サブタイプが追加された際に既存の`switch`の分岐漏れをコンパイルエラーで検知したい場合

```java
public sealed interface OrderStatus permits OrderConfirmed, OrderCanceled {}
public record OrderConfirmed(Instant confirmedAt) implements OrderStatus {}
public record OrderCanceled(String canceledReason) implements OrderStatus {}
```

### 5.11 日付・時刻

#### timestamp 型の時刻振り出しは DB で行う

登録日時・更新日時（`created_at`/`updated_at` 等）の現在時刻は、アプリケーションサーバーでは生成せず、PostgreSQL の `clock_timestamp()` で生成する。Serviceから `Instant.now()` 等で生成した時刻を INSERT/UPDATE に渡してはならない。

**禁止: `now()`および`CURRENT_TIMESTAMP`は使用しない。**
これらはトランザクション開始時刻に固定される。現在時刻の取得には、**常に`clock_timestamp()`を使用する。**

```sql
-- INSERT時はcreated_at/updated_atにclock_timestamp()を指定する
INSERT INTO order_header (order_id, created_at, updated_at)
VALUES (#{orderId}, clock_timestamp(), clock_timestamp());

-- UPDATE時はSET句でclock_timestamp()を指定する
UPDATE order_header
SET status = #{status},
    updated_at = clock_timestamp()
WHERE order_id = #{orderId};
```

アプリ側で生成した時刻をタイムスタンプ列にそのまま渡してはならない。

#### アプリ内では timestamp 型のデータを UTC で管理する

DB保存値とAPI通信のtimestampはUTCに統一し、Java側では `Instant`（またはUTCの `OffsetDateTime`）で扱う。Service層でJSTなどの特定タイムゾーンへ変換した値を保持しない。

- API（HTTP）の日時型は ISO 8601 の `Z` サフィックス付き（UTC）で送受信する。`Z` なし・オフセットなしの文字列は TZ が不定になるため使用しない
- API（HTTP）の日付型（`DATE`。納期・有効期限等）は TZ 変換不要のため `YYYY-MM-DD` 形式等でそのまま送受信する
- gRPC は `google.protobuf.Timestamp` 型を使用する。Unix エポック秒で表現されるため型として UTC が保証される
- TIMESTAMPTZ 列への INSERT・検索条件指定時、TZ オフセットなしの文字列を渡すとセッションの `TimeZone` 設定でそのまま解釈され、意図しない時刻ズレが発生する。必ず UTC に変換するか、オフセット付き文字列を使用する

```java
// ✅ UTCのInstantとして扱う
Instant createdAt = entity.getCreatedAt(); // TIMESTAMPTZ列はUTCのInstantとして受け取る

// ❌ JSTに変換した値をアプリ内やDBに保持しない
OffsetDateTime createdAtJst = createdAt.atOffset(ZoneOffset.ofHours(9));
entity.setCreatedAt(createdAtJst.toInstant()); // 変換後の値を再登録しない
```

#### 必要な箇所でのみタイムゾーン変換を行う

フロントエンドへの表示や実績送信ファイル（CSV等）への出力など、UTC以外の表現が必要な場合に限り、レスポンス生成・ファイル出力の直前で変換する。変換後の値をDBや内部状態へ保持しない。

```java
// ✅ レスポンス生成・ファイル出力の直前でのみTZ変換する
ZonedDateTime displayTime = createdAt.atZone(ZoneId.of("Asia/Tokyo"));
```

業務日付の「今日」判定（納期・有効期限等）は、アプリケーションサーバーの時刻やDBの `CURRENT_DATE` を直接使用しない。DBで `clock_timestamp()` により取得した現在時刻を、フロントエンドから渡された端末タイムゾーンへ変換して算出する。

```sql
-- DBの現在時刻をclock_timestamp()で取得する
SELECT clock_timestamp();
```

```java
// ✅ DBで振り出した現在時刻を端末TZに変換して「今日」を算出する
Instant now = timeMapper.selectCurrentTimestamp(); // clock_timestamp()で取得したDBの現在時刻
LocalDate today = now.atZone(ZoneId.of(clientTimeZone)).toLocalDate();
```

#### 型の使い分け

`java.util.Date` / `Calendar` は使用せず、日付・時刻の型には `java.time` パッケージを使用する。

| 型 | 用途 |
|---|---|
| `LocalDate` | 納期・有効期限など、タイムゾーンを持たない業務日付 |
| `Instant` | DB・API通信・JWT・セッションなど、UTCで一意に扱うtimestamp |
| `OffsetDateTime` | 固定オフセット（例：`+09:00`）を明示するtimestamp |
| `ZonedDateTime` | `Asia/Tokyo`など、地域のタイムゾーン規則に基づく変換結果 |
| `Duration` | タイムアウト・有効期限などの経過時間 |

`OffsetDateTime`は固定オフセットを保持し、`ZonedDateTime`は`ZoneId`を保持する。サマータイムなど地域の暦ルールに基づく変換が必要な場合は`ZonedDateTime`を使用する。

### 5.12 非同期処理

マイクロサービスにおける非同期処理には、単一サービス内で完結する処理と、サービス間で連携する処理の2パターンがある。どちらの場合も`@Async`は使用せず、Kafkaを経由して非同期処理を実行する。

具体的な実装方法については、CDCツール + Outboxテーブルの運用方法が決まり次第、記入。

### 5.13 アノテーションの使用方針

使用してよいアノテーションを、層（レイヤー）ごとに整理する。
層をまたいで共通的に使うもの（Lombok、バリデーション等）は別途まとめる。
ここに記載のないアノテーションを追加する場合は、まず既存のアノテーションで代替できないかを検討する。

#### Controller層

| アノテーション | 用途 |
|---|---|
| `@RestController` | コンポーネント定義 |
| `@SkipOperationLog` | 操作ログの出力除外（例外的使用。5.7.1参照） |
| `@RequiredArgsConstructor` | DI（Lombok） |

#### Service層

| アノテーション | 用途 |
|---|---|
| `@Service`、`@RequiredArgsConstructor` | コンポーネント定義・DI |
| `@Transactional` | トランザクション境界（5.9参照） |

#### gRPC Client / Mapper層

| アノテーション | 用途 |
|---|---|
| `@RequiredArgsConstructor` | DI（Lombok） |
| `@Mapper`（`org.mapstruct.Mapper`）、`@Mapping`、`@CollectionMappingStrategy` | DTO/gRPCメッセージ変換（MapStruct。5.2参照） |
| `@Mapper`（`org.apache.ibatis.annotations.Mapper`） | MyBatisマッパーインターフェース |
| `@CircuitBreaker` | 下流サービス呼び出しの回路遮断（Resilience4j） |

#### DTO・Entity（モデル）

| アノテーション | 用途 |
|---|---|
| `@Getter`、`@Builder`、`@AllArgsConstructor`、`@NoArgsConstructor`、`@EqualsAndHashCode`、`@Data` | Lombokによるボイラープレート生成 |
| `@NotBlank`、`@Min`/`@Max`、`@Future`/`@FutureOrPresent`/`@Past`/`@PastOrPresent`、`@ChronologicalDates`、`@MaxDate` | 入力値検証 |
| `@JsonProperty`、`@JsonAlias`、`@JsonIgnoreProperties` | JSONプロパティ名・別名・未知プロパティ許容の制御 |
| `@Nullable`、`@NonNull`（`org.jspecify.annotations`） | null許容・非許容の明示 |

BFFが公開するリクエスト/レスポンスDTO（`cm-be-spec`生成物）は上記アノテーションを手動で追加・変更しない（5.6参照）。上記は手書きの内部DTO・Entityに適用する。

#### Configuration層

| アノテーション | 用途 |
|---|---|
| `@Configuration`、`@Bean` | Bean定義 |
| `@ConfigurationProperties`、`@EnableConfigurationProperties`、`@Validated` | 設定値のバインド・検証 |
| `@ConditionalOnProperty`、`@ConditionalOnBean`、`@ConditionalOnClass`、`@ConditionalOnMissingBean` | 条件付きBean登録 |
| `@Primary`、`@Qualifier`、`@Lazy` | 複数実装の優先順位付け・遅延初期化 |

---

## 6. 関連ドキュメント

| ドキュメント |
|-------------|
| 単体テスト規約 |
| 開発手順 |
| GitHub 運用ルール | 
| AI用 instructions |
| 共通開発規約 |

---