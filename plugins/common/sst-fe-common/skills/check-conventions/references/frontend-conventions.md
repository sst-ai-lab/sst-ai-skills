# 開発規約：フロントエンド（Vue.js / TypeScript）

## 1. はじめに

### 1.1 本規約の目的・適用範囲

本規約はフロントエンド（Vue.js / TypeScript）の開発者が守るべきルールと推奨事項を定める。  
適用対象は `{repo}` リポジトリの `src/` 配下のすべてのソースコード（`.vue` / `.ts` / `.scss` 等）とする。  
自動生成ファイル（`auto-imports.d.ts`、`components.d.ts`、`typed-router.d.ts`）は対象外とする。

### 1.2 参考規約

本規約は以下の公式スタイルガイドを参考に策定している。  
本規約に記載のない事項については、下記を参照すること。

| 規約 | URL |
|------|-----|
| Vue.js 公式 Style Guide（Priority A–D） | https://ja.vuejs.org/style-guide/ |
| Google TypeScript Style Guide | https://google.github.io/styleguide/tsguide.html |

### 1.3 ツールで自動適用されるルールについて

本プロジェクトでは、整形・静的解析・型チェックをツールで自動化している。各ツールの最終的な判定は、共通の ESLint / Prettier 設定（`eslint.config.js` 等）に従う。  
本規約とツール設定に差異がある場合は、ツール設定を正とする。

| タイミング | ツール / コマンド | 内容 | 失敗時 |
|---|---|---|---|
| ファイル保存時 | Prettier（`editor.formatOnSave` が有効な場合） | エディタ上で自動整形 | 保存内容を確認する |
| `git commit` | lint-staged → ESLint / Prettier | ステージ済みの `*.{ts,tsx}` を ESLint、`*.{json,md,yml}` 等を Prettier で整形・検査し、整形後の内容を再ステージ | コミット失敗 |
| `git commit` | commitlint | コミットメッセージを Conventional Commits 形式で検査 | コミット失敗 |
| `git push` 後 | AWS CodeBuild（`buildspec-ci.yml`） | install の後、型チェック・Lint・ビルドを実行 | CI の結果に応じて対応 |

CI（`buildspec-ci.yml`）で実行される主なチェックは以下のとおりとする。

| ツール / コマンド | 役割 | 扱い |
|---|---|---|
| `yarn type-check`（vue-tsc） | TypeScript 型チェック（`.vue` ファイルを含む） | 違反時はビルド失敗 |
| `yarn lint`（ESLint：`eslint-config-vuetify` + `eslint-plugin-sonarjs`） | Vue / TypeScript コードスタイル・品質チェック | 違反時はビルド失敗 |
| `yarn build`（Vite） | ビルド可否の確認 | 違反時はビルド失敗 |

**Prettier 設定値**

| 項目 | 値 |
|------|----|
| インデント | 2スペース（タブ禁止） |
| 行幅 | 120文字 |
| セミコロン | あり |
| クォート | シングルクォート |
| 改行コード | LF |

コミットメッセージの書き方（Conventional Commits 形式、許可されるタイプ、チケット番号の記載方法等）は Git 運用ガイドライン（`99.git/guideline.md`）を参照する。本規約側では重複記載せず、Git 運用ガイドラインを正とする。

---

## 2. プロジェクト構成

### 2.1 GitHub リポジトリ

[{repo}](https://github.com/SST-CM/{repo})

### 2.2 ディレクトリ構成

#### 2.2.1 リポジトリ全体のレイアウト

```text
{repo}/
└─ src/
   ├─ views/          ** 画面（ファイルベースルーティング）
   ├─ api/            ** API ラッパー層
   ├─ composables/    ** 共通 composable
   ├─ stores/         ** Pinia ストア（グローバル状態）
   ├─ components/     ** 共通 UI コンポーネント
   ├─ layouts/        ** レイアウトコンポーネント（MainLayout 等）
   ├─ errorPages/     ** エラーページ（404 等）
   ├─ router/         ** ルーティング関連設定
   ├─ plugins/        ** Vue プラグイン初期化（Vuetify、i18n 等）
   ├─ constants/      ** 定数定義
   ├─ utils/          ** ユーティリティ関数
   ├─ libs/           ** 外部ライブラリ設定（API クライアント等）
   ├─ locales/        ** i18n 翻訳ファイル（ja / en / es / zh）
   ├─ assets/         ** 画像等の静的アセット
   ├─ styles/         ** グローバル SCSS
   └─ types/          ** 共通型定義
```

#### 2.2.2 業務機能のディレクトリ構成

業務画面は `503968_ディレクトリ構造` で定義したニーモニックコード方式に従って管理する。  
画面と設計書の対応を明確にし、担当者間での認識ズレを防ぐため、`views/` と `api/` は同じ分類体系を使う。

```text
views/
  core/              ** 中分類（ニーモニックコード）
    so/              ** 小分類（ニーモニックコード）
      soPlanSearch/  ** 機能名（lowerCamelCase、連番なし）
      soMainte/
api/
  core/
    so/
      soMainteApi/   ** views/ と同じ体系を使う
```

新機能は `503968_ディレクトリ構造` のニーモニックコード一覧に従い、中分類・小分類フォルダを選択して機能名フォルダを追加する。連番はフォルダ名に含めない。

**画面機能ごとのファイル構成（1機能 = 3ファイル）**

画面・ロジック・型を役割ごとに分離することで、変更の影響範囲を限定し、レビューをしやすくする。

```text
<feature>/
  ├─ <feature>.vue          ** テンプレートと composable の接続のみ
  ├─ use<Feature>.ts        ** 画面ロジック（検索・保存・バリデーション等）
  └─ <feature>.types.ts     ** この画面固有の型定義
```

**API の構成（1機能 = 2ファイル）**

```text
<feature>Api/
  ├─ <feature>Api.ts        ** API 呼び出しメソッドの定義
  └─ <feature>ApiType.ts    ** 生成型を再 export し、画面側から使いやすい名前に整理
```

`@sst-cm/fe-web-client` の型名は長くなりやすい。`ApiType.ts` で短い別名をつけることで、画面側の記述量を減らせる。

---

## 3. 命名規則

> ビジネス用語（取引先・倉庫・ドメイン名 等）の命名は共通開発規約の用語定義を参照すること。

| 対象 | 規則 | 例 |
|------|------|----|
| 画面 Vue ファイル | lowerCamelCase.vue | `soMainte.vue` |
| 共通コンポーネント | PascalCase.vue | `AppHeader.vue` |
| Composable | `use` + PascalCase.ts | `useSoMainte.ts` |
| Pinia ストア | lowerCamelCase.ts | `auth.ts` |
| API ラッパー | `featureApi.ts` | `soMainteApi.ts` |
| API 型定義 | `featureApiType.ts` | `soMainteApiType.ts` |
| 画面固有の型定義 | `feature.types.ts` | `soMainte.types.ts` |
| 変数・関数名 | lowerCamelCase | `ownerCd`、`findItems()` |
| 型・インターフェース名 | PascalCase | `SearchCondition`、`SoDetailRow` |
| 定数 | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`、`DEFAULT_PAGE_SIZE` |

### 3.1 技術固有の命名

**イベントハンドラ名**

ファイル名・関数名から役割が判断できるよう、イベントハンドラの命名パターンを以下に統一する。

| パターン | 用途 | 例 |
|---|---|---|
| `handle` + 動詞 | ユーザーアクション・コールバック | `handleSave`、`handleFindOwnerCd` |
| `on` + 動詞 | イベントリスナー | `onTreeItemSelect` |
| 動詞のみ | composable 内の CRUD 操作 | `findItems`、`save`、`clear`、`deleteItem` |

パターンを統一することで、コードを読んだときに「これはユーザー操作由来か」「これは内部ロジックか」が名前から判断できる。

```ts
// ✅
const handleFindOwnerCd = (data?: CodeNameResponse): void => { /* コールバック処理 */ };
const onTreeItemSelect = (event: { id: unknown }): void => { /* ツリー選択処理 */ };
const save = async (): Promise<void> => { /* 保存 CRUD 操作 */ };

// ❌ 意味不明な名前
const doStuff = () => { /* ... */ };
const click1 = () => { /* ... */ };
```

**共通フック・composable の推奨 const 名**

以下の共通フックを利用する際は、指定の const 名で宣言する。
名前を統一することで、どのファイルでも同じ見た目になり、レビューや読解のコストを下げる。

| 機能 | composable | 推奨 const 名 | 根拠 |
|---|---|---|---|
| 多言語 | `useI18n()` | `t` | vue-i18n 公式ドキュメントおよびエコシステム全体での標準慣例（※後述） |
| ルーティング | `useRouter()` | `router` | Vue Router 公式ドキュメントでの標準慣例 |
| 認証ストア | `useAuthStore()` | `authStore` | ストアの種類（auth）を名前に含めることで、複数ストア使用時に区別しやすい |
| メッセージ | `useMessage()` | `message` | composable 名から `use` を除いたそのまま |
| ダイアログ | `useDialog()` | `dialog` | composable 名から `use` を除いたそのまま |
| 通知 | `useNotification()` | `notification` | composable 名から `use` を除いたそのまま |

```ts
// ✅
const t = useI18n();
const router = useRouter();
const authStore = useAuthStore();
const message = useMessage();
const dialog = useDialog();
const notification = useNotification();

// ❌ 独自の名前を付けない
const i18n = useI18n();
const translate = useI18n();
const nav = useRouter();
```

> **`t` の命名について（3.2.5 省略形ルールの例外）**  
> `t` は1文字であり通常は省略形禁止の対象だが、vue-i18n の公式ドキュメント・OSS コミュニティ全体での標準慣例であるため例外とする。  
> `id` / `url` / `api` と同様に「一般的に知られている略語」として扱う。

---

**i18n キー**

機能単位でネストしたオブジェクト構造にする。機能固有の文言のみを機能名（ニーモニックコード）でネストし、複数機能で共通に使う文言は下表の共通名前空間に統一する。同じ意味の文言を機能ごとに重複定義しない。

| 名前空間 | 用途 |
|---|---|
| `label.*` | 項目ラベル |
| `button.*` | ボタン文言 |
| `errors.*` | エラーメッセージ（`errors.codes.*` はバックエンドのエラーコードとのマッピングに使う。5.16 参照） |
| `status.*` | ステータス表示 |
| `dialog.*` | 確認ダイアログの文言 |
| `validation.*` | 入力チェックメッセージ |
| `placeholder.*` | 入力欄のプレースホルダー |

```ts
export default {
  soMainte: { title: '出荷メンテナンス' },
  label: { soShipNo: '出荷伝票番号', ownerCode: '取引先コード' },
  button: { save: '保存', clear: 'クリア', delete: '削除' },
  errors: { apiFailure: 'サービスに接続できませんでした。' },
};
```

### 3.2 禁止命名パターン

変数名は、意味が一意に定まる名詞・形容詞を使う。以下のような対象や意味が判断できない名前は避ける。

- `data`、`info`、`value`、`temp` など、対象や意味が分からない名前
- 型名を変数名に埋め込んだ名前（`ownerCdStr`、`countInt` 等。詳細は 3.2.3）
- 意味のない1文字の変数名。ただし `i`、`j` などのループカウンターは許容する

```ts
// ✅ 対象・意味が明確
const ownerCd = ref('');
const searchResultCount = ref(0);

// ❌ 対象や意味が分からない、意味のない1文字
const data = ref('');
const v = ref(0);
```

#### 3.2.1 boolean 型

**基本原則：`if` 文の中で読んだときに意味が通り、何を判定しているか分かる名前にする。**

boolean 変数は、肯定形を基本とし、単なるデータ型ではなく、状態・存在・能力などの意味を表す名前にする。

❌ **避ける命名**

- `xxxFlg`、`xxxFlag`、`xxxKbn` など、型や意味が分からない略語
- `isInvalid`、`isNotAvailable` など、条件判定時に二重否定になる否定形
- `exists`、`valid`、`value` など、対象や判定内容が分からない単体の名前
- `shouldXxx`、`needsXxx` など、単純な状態ではなく業務判断と混同しやすい名前

`is` / `has` / `can` は必須の接頭辞ではない。判定の意味に応じて、次のような名前から最も自然なものを選択する。

| 命名 | 表す内容 | 例 |
|---|---|---|
| `is` / `are` | 状態・性質 | `isActive`、`isInitialized`、`areItemsValid` |
| `is...ed` | 特定の処理が完了している状態 | `isLoaded`、`isCalculated`、`isUpdated` |
| `has` | 所有・存在・包含 | `hasPermission`、`hasAttachment`、`hasChildren` |
| `can` | 能力・許可・可能性 | `canEdit`、`canRetry`、`canAllocate` |
| `is...able` | 可能・実行可能な状態 | `isEditable`、`isRetryable`、`isAllocatable` |
| 対象 + 述語 | `is`・`has`・`can` だけでは関係を表しにくい場合 | `userExists`、`orderContainsItem` |
| `is...Required` | 業務上の必要性 | `isApprovalRequired`、`isRetryRequired` |

```ts
const isActive = ref(false);                                             // 有効な状態か
const hasPermission = computed(() => false);                             // 権限を持っているか
const canEdit = ref(true);                                               // 編集できるか
const orderContainsItem = computed(() => order.value.items.length > 0);  // 注文に商品が含まれるか
const isApprovalRequired = computed(() => order.value.amount > 100000);  // 承認が必要かという業務判断

// ❌ 「フラグ」系サフィックス・二重否定
const activeFlg = ref(false);
const isNotAvailable = ref(false);
```

#### 3.2.2 boolean型と`boolean | null` / `boolean | undefined`

値が必ず`true`または`false`のいずれかで確定している場合は、`boolean`を使用する。`boolean | undefined`（または`boolean | null`）は、「未指定」「不明」を`true`/`false`と区別する必要がある場合に限り使用する。

ローカル変数・`ref`・`computed`・関数の引数や戻り値は、原則として確定値の`boolean`を保持する。生成 API クライアントの型や外部データが`boolean | null` / `boolean | undefined`の場合は、コンポーネントに取り込む段階で意味（未指定／false／null＝クリア等）を明確にした上で確定値に変換する。

```ts
// ✅ ローカルのUI状態は確定値のbooleanで保持する
const isBasicInfoOpen = ref<boolean>(true);

// ✅ 外部データ（API・保存値）を取り込む際に確定値へ変換する
const isInputOnly = nodeData.isInputOnly ?? false;

// ✅ 「未指定」と「明示的なfalse」を区別する必要がある場合に限りboolean | undefinedを許容する
let printedFlg: boolean | undefined;
if (form.printedFlag === 'printed') {
  printedFlg = true;
} else if (form.printedFlag === 'notPrinted') {
  printedFlg = false;
}
// printedFlag === 'all' の場合はundefinedのまま送信し、API側で「フィルタしない」を表す

// ❌ 区別が不要な変数にboolean | undefinedを保持したまま使い回す
const isActive = ref<boolean | undefined>(undefined);
```

#### 3.2.3 型名サフィックス

変数名に型名（`xxxStr`、`xxxNum` 等）を付けない。

```ts
// ✅
const ownerCd = ref('');
const shipDate = ref('');

// ❌ 型名サフィックス禁止
const ownerCdStr = ref('');
const shipDateString = ref('');
```

#### 3.2.4 数値の命名

値の意味に応じたサフィックスを付ける。`xxxNum`、`xxxInt` のような型名サフィックスは付けない（3.2.3 参照）。

| 用途 | サフィックス例 | 例 |
|------|------------|-----|
| 件数・個数 | `Count`、`Size` | `itemCount`、`pageSize` |
| 数量 | `Quantity`、`Amount` | `stockQuantity`、`orderAmount` |
| 金額 | `Price`、`Amount`、`Fee` | `unitPrice`、`totalAmount` |
| 順番・順序 | `Order`、`Sequence` | `sortOrder`、`displaySequence` |
| 上限・下限 | `Max`、`Min`、`Limit` | `maxRetryCount`、`limitSize` |

```ts
// ✅
const itemCount = ref(0);
const maxRetryCount = 3;

// ❌ 型名サフィックス禁止（3.2.3 参照）
const itemCountNum = ref(0);
```

#### 3.2.5 省略形

意味が不明確な省略形は禁止。一般的に知られている略語（`id`、`url`、`api`）および業務慣例の略語（`Cd`、`No` 等）は許容する。

```ts
// ✅
const warehouseCd = ref('');  // "Cd" は業務用語の慣例で許容

// ❌ 独自略語禁止
const whCd = ref('');         // "wh" は不明確
const ftchDt = () => { /* ... */ };
```

#### 3.2.6 日付・時刻

共通命名規則（`503967_命名ルール`）に従い、日付・時刻フィールドは以下のサフィックスで統一する。

| サフィックス | 型のイメージ | 例 |
|---|---|---|
| `xxxDate` | 日付のみ（年月日）| `shippingDate`, `rcvDate` |
| `xxxAt` | 日時（タイムスタンプ）| `createdAt`, `updatedAt` |

```ts
// ✅
const shippingDate = ref('');
const createdAt = ref('');

// ❌
const shippingDt = ref('');      // "Dt" は曖昧な略語
const shippingDatetime = ref(''); // 型名の埋め込み
```

#### 3.2.7 区分・種別（`xxxKbn` 禁止）

日本DB由来の「区分（Kbn）」はそのまま使わず、意味合いに応じた英単語に翻訳する。

| 役割 | 使うサフィックス | 例 |
|---|---|---|
| 種類・性質 | `xxxType` | `customerType`（個人/法人）|
| 状態・フェーズ | `xxxStatus` | `shippingStatus`（未出荷/完了）|
| 手段・方式 | `xxxMethod` | `paymentMethod`（現金/クレジット）|
| 分類 | `xxxCategory` | `menuCategory`（大分類/中分類/小分類）|
| 階層・段階 | `xxxLevel` | `menuLevel`（第1階層/第2階層/第3階層）|
| 2択（フラグ的）| `isXxx` | `isDeleted`, `isTaxable` |

```ts
// ✅
const shippingStatus = ref<'pending' | 'completed'>();
const isDeleted = ref(false);

// ❌
const shippingKbn = ref();   // Kbn をそのまま使わない
const deleteFlg = ref(false); // Flg 禁止（3.2.1 参照）
```

#### 3.2.8 コレクション

配列・リスト型の変数名は**複数形**を使う。`xxxList` / `xxxArray` のような型名サフィックスは禁止。

```ts
// ✅
const orders = ref<Order[]>([]);
const activeUsers = computed(() => users.value.filter(u => u.isActive));

// ❌
const orderList = ref<Order[]>([]); // List サフィックス禁止
const userArray = ref<User[]>([]);  // Array サフィックス禁止
```

---

## 4. コメントの書き方

### 4.1 基本理念

コメントは、コードだけでは読み取れない背景・意図・制約・妥協点を補足するために記載する。コメントを追加する前に、変数名・関数分割・型設計で説明できないかを検討する。

| 情報 | 表現方法 | 例 |
|---|---|---|
| What（何をするか） | 変数名・関数名・型名と実装で表現する | `confirmOrder` は注文を確定する処理である |
| How（どのようにするか） | コードで表現する | ステータスを `confirmed` に変更し、確定日時を設定する |
| Why（なぜそうするか） | 必要な場合にコメントで表現する | 出荷ラベル発行後の変更を防ぐ業務ルールがある |
| Who / When（誰が・いつ変更したか） | Git のコミット履歴や案件管理で管理する | 変更者・変更日・案件番号 |

コメントは、現在も有効な内容だけを記載し、実装を変更したときは関連するコメントが実装と一致しているか確認する。一致しないコメントは修正または削除する。

### 4.2 インラインコメント

`//` の後ろには必ずスペースを入れる。次のいずれかに該当する場合に、インラインコメントを記載する。

- 業務ルールの理由を補足する必要がある
- 外部仕様（API 契約・ブラウザ仕様等）との互換性を維持する必要がある
- 性能・セキュリティ上の制約がある
- 一見すると不自然な実装を採用している理由がある

```ts
// ✅ 業務ルールの理由を補足する
// Cognito のトークン更新は同時に1リクエストのみ許可されるため排他制御する
let isRefreshing = false;

// ✅ 特殊な設定値の理由
const maxRetryCount = 3; // 外部APIのRate Limitが1秒間に3回までのため

// ✅ 正しい TODO コメント
// TODO: v3 リリース後に廃止予定の workaround を削除する（CM-12345）

// ❌ スペースなし禁止
//ここで処理を行う

// ❌ コードを繰り返すだけのコメント禁止
// 保存する
const save = async () => { /* ... */ };
```

`TODO` コメントは `// TODO: 説明（チケット番号）` の形式のみ（大文字・コロン必須）とする。

### 4.3 禁止事項

#### 変更履歴をコメントで管理しない

修正箇所を示す Start/End コメントや、作成者・作成日・修正日・修正内容・案件番号などの履歴情報を、コメントで管理しない。変更のまとまりや作業履歴は Git で管理する。

```ts
// ❌ Start/End コメントや変更履歴をソースコードに残さない
// 2026-08-19 U2000-000 オーダーID処理改善 START
confirmOrder(order);
```

#### 不要なコードをコメントアウトしない

修正によって不要になったコードは、コメントアウトしたまま残さず削除する。将来の参考や復元が必要な場合も、Git のコミット履歴で追跡できるため、ソースコード内に保持しない。

```ts
// ✅ 不要なコードは削除する
const save = async (): Promise<void> => {
  await apiCallWithLoading(() => SoMainteApi.saveSo(form.value));
};

// ❌ 不要なコードをコメントアウトしたままにしない
const save = async (): Promise<void> => {
  // await apiCallWithLoading(() => SoMainteApi.saveSoOld(form.value));
  await apiCallWithLoading(() => SoMainteApi.saveSo(form.value));
};
```

`TODO` / `FIXME` のコミットは禁止し、チケット化してコードから削除する。

### 4.4 JSDoc

JSDoc は、その関数や型を呼び出す側に向けて仕様を伝える説明書である。他のファイルから参照される `export` 関数・型のうち、用途が名前から自明でないものに JSDoc を付ける。

```ts
/**
 * 出荷検索条件を API 契約の形式に正規化する。
 *
 * 空文字・null 混在入力を除去し、未入力項目を undefined に統一する。
 *
 * @param input 画面入力値（null や空文字を含む可能性がある）
 * @returns 正規化済みの検索条件
 */
export function normalizeCondition(input: RawCondition): SearchCondition {
  // ...
}
```

| 項目 | ルール |
|---|---|
| 概要文 | 日本語で記載する |
| 概要文末尾 | 句点（`。`）で終わる |
| `@param` / `@returns` | 型は TypeScript が担保するため JSDoc に型を重複記載しない |
| タグ順序 | `@param` → `@returns` → `@throws` |
| タグの説明 | 空にしない（`@param input` だけは NG） |

**必須箇所**

- 他のファイルから参照される `export` 関数・型のうち、用途が名前から自明でないもの
- 複雑な入出力変換・バリデーションロジックを持つ `utils/` 配下の関数
- Pinia ストアの `actions` のうち、副作用（API 呼び出し等）を伴うもの

---

## 5. フレームワーク固有ルール

### 5.1 レイヤー責務

| 層 | 責務 | 禁止事項 |
|---|---|---|
| `.vue`（画面） | テンプレートとイベント接続のみ | 業務ロジックを書かない |
| `use*.ts`（composable） | 画面ロジック・状態管理 | テンプレート描画ロジックを持たない |
| `*Api.ts`（API 層） | API 呼び出しのみ | 業務判断・状態管理を行わない |
| Pinia ストア | 画面を跨ぐ共有状態のみ | 画面固有の状態を持たない |

`<script setup lang="ts">` + Composition API を使用する。Options API は TypeScript との相性が悪く現チームの技術スタックに合っていないため禁止。SFC のブロック順は `<template>` → `<script setup>` → `<style>` とし、1ファイル1コンポーネントを守る。

```vue
<!-- ❌ Options API -->
<script>
export default {
  data() { return { count: 0 }; },
  methods: { increment() { this.count++; } },
};
</script>

<!-- ✅ script setup + Composition API -->
<template>
  <SstButton :text="t('button.save')" @click="save" />
</template>

<script setup lang="ts">
const t = useI18n();
const save = async (): Promise<void> => { /* ... */ };
</script>

<style scoped lang="scss">
.container { padding: 16px; }
</style>
```

### 5.2 Props / Emits

props は型を含めて明示定義する。型情報がないと受け取り側で何が来るか不明になり、ランタイムエラーの原因になる。

```ts
// ❌ 型情報がない
const props = defineProps(['status']);

// ✅ 型・必須・バリデーションまで定義
const props = defineProps({
  status: {
    type: String as PropType<'active' | 'inactive'>,
    required: true,
  },
});
```

props を子コンポーネント内で直接変更しない。子が親の状態を直接書き換えるとデータの流れが追いにくくなりデバッグが困難になるため、変更が必要な場合は `emit` で親へ通知する。

```ts
// ❌ props を直接変更している（Vue が警告を出す）
const props = defineProps<{ value: string }>();
function clear() {
  (props as { value: string }).value = '';
}

// ✅ emit で親へ変更を依頼する
const props = defineProps<{ value: string }>();
const emit = defineEmits<{ 'update:value': [string] }>();
function clear() {
  emit('update:value', '');
}
```

### 5.3 テンプレート記述

`v-for` には必ず `:key` を付与する。key がないと Vue が DOM を効率的に再利用できず、表示の不整合やパフォーマンス低下を招く。

`v-for` と `v-if` を同一要素に書かない。評価順が直感と異なり（`v-for` が先に評価される）、バグを生みやすい。

```vue
<!-- ❌ 同一要素に v-for と v-if -->
<li v-for="user in users" v-if="user.isActive" :key="user.id">...</li>

<!-- ✅ computed で事前にフィルタリングするか、<template> でラップする -->
<template v-for="user in users" :key="user.id">
  <li v-if="user.isActive">...</li>
</template>
```

テンプレートの式は単純に保ち、複雑なロジックは `computed` またはメソッドへ移す。テンプレートはレイアウトの宣言に専念させるべきで、ロジックが混在すると読みにくくなる。

```vue
<!-- ❌ テンプレートに複雑な式が混在 -->
<span>{{ fullName.split(' ').map(w => w[0].toUpperCase() + w.slice(1)).join(' ') }}</span>

<!-- ✅ computed へ移してテンプレートをシンプルに保つ -->
<span>{{ normalizedName }}</span>

<script setup lang="ts">
const fullName = ref('tanaka taro');
const normalizedName = computed(() =>
  fullName.value.split(' ').map(w => w[0].toUpperCase() + w.slice(1)).join(' ')
);
</script>
```

### 5.4 リアクティビティと副作用

算出値（派生値）は `computed` を使う。`computed` 内では副作用を起こさない。computed が副作用を持つと予期しないタイミングで外部状態が変わり、デバッグが困難になる。

ここでの副作用とは、値を返す以外に外部の状態・環境へ影響を与える処理を指す。代表例は以下のとおり。

- API 呼び出し（サーバー状態の参照・更新）
- DOM 操作・画面描画への直接介入（`document.*` 操作など）
- タイマー登録（`setTimeout` / `setInterval`）
- イベント購読・解除（`addEventListener` 等）
- ログ・トレースの送信
- Pinia ストア・外部の `ref` への書き込み

`computed` はこれらを行わず、既存の状態から値を導出するだけの純粋な処理に留める。

```ts
// ❌ computed の中で副作用（API 呼び出し）を起こしている
const displayList = computed(() => {
  fetchData(); // ← computed の中に副作用を置かない
  return list.value.filter(item => item.active);
});

// ✅ 派生値は computed、副作用は明示的な関数または watch で分離
const activeList = computed(() => list.value.filter(item => item.active));

const search = async (): Promise<void> => {
  const result = await SoSearchApi.search(condition);
  list.value = result.data ?? [];
};
```

API 呼び出し・通知・ログ送信などの副作用は、`watch` / イベントハンドラ / 明示的な関数で扱う。  
複雑な `computed` は単純な `computed` に分割する。1つの computed が多くの依存を持つと、変更のたびにすべてを再評価するコストが上がる。

画面の初期値取得（API 取得や初期表示データのセット）は `onMounted` 内で実施する。`<script setup>` のトップレベル（setup 実行時）で直接 API 呼び出しを行うと、コンポーネントの描画タイミングと非同期処理の進行が前後し、`ref` 初期化前の参照エラーや二重実行の原因になりうる。

```vue
<script setup lang="ts">
import { onMounted, ref } from 'vue';

const templateList = ref<ReportConfigTemplateListItem[]>([]);

// ✅ 初期データ取得は onMounted 内で実施する
onMounted(async () => {
  templateList.value = await ReportConfigApi.getTemplateList();
});

// ❌ setup 直下での API 呼び出し・初期化は行わない
const badList = await ReportConfigApi.getTemplateList();
</script>
```

### 5.5 スタイル

画面・共通コンポーネントのスタイルは `<style scoped lang="scss">` を使う。scoped がないとスタイルがグローバルに漏れ、予期しない影響が他コンポーネントに及ぶ。

`scoped` 内では要素セレクター（`button`、`input` 等）の多用を避け、クラスセレクターを使う。要素セレクターは scoped 付きでもパフォーマンスが悪く、第三者コンポーネントに意図せず当たる場合がある。

```scss
/* ❌ 要素セレクター → Vuetify 等のコンポーネントにも当たってしまう */
button { background-color: red; }

/* ✅ クラスセレクター → このコンポーネント内の .save-btn にだけ当たる */
.save-btn { background-color: rgb(var(--v-theme-primary)); }
```

`App.vue`・`MainLayout.vue` 等の全画面共通コンポーネントはグローバルスタイルを許容する。

画面単位での独自スタイル上書きは必要最小限に留める。画面ごとに見た目を個別調整すると、アプリ全体でのデザインの一貫性が失われる。共通コンポーネント（`Sst*` 等）側の props やテーマ設定で表現できないか検討し、それでも対応できない場合に限り `<style scoped>` で調整する。

### 5.6 Sst コンポーネント

テンプレート内の `Sst*` コンポーネントは PascalCase で記述する（`<SstTextField>` ○、`<sst-text-field>` ×）。HTML 要素と Vue コンポーネントを視覚的に区別するため。

入力フォームを持つ画面は `SstForm` を使い、フォームに `id` を付与する。入力系コンポーネント（`SstTextField`、`SstSelect`、`SstCodeName`、`SstDateInput` 等）には画面内で一意の `id` を付与する。`SstForm` のバリデーション・メモライズ機能が `id` をキーとして動作するため。

フォーム入力要素に `:tab` を定義し、Tab キー移動順序を明示する。キーボード操作での業務効率と、アクセシビリティの最低要件を満たすため。

```vue
<SstForm id="searchForm" ref="formRef">
  <SstCodeName id="ownerCd" v-model="condition.ownerCd" :tab="1" required />
  <SstCodeName id="warehouseCd" v-model="condition.warehouseCd" :tab="2" required />
  <SstTextField id="soNo" v-model="condition.soNo" :tab="3" />
</SstForm>
```

閲覧専用画面・認証コールバック・PoC 等、フォーム制御が不要な画面は `SstForm` を省略可能とする。

### 5.7 バリデーション

バリデーションは、入力値の形式を確認する検証と、業務上の妥当性を確認する検証に分けて実施する。フロントエンドとバックエンド（BFF・マイクロサービス）の責務は次のとおりとする。

| 実施範囲 | 検証対象 | 実装方法 |
|---|---|---|
| フロントエンド | 必須、文字数、形式、数値範囲など、入力値単体で判定できる内容 | `Sst*` 入力コンポーネントの `required` / `rules` / `validation-checks` 等の props で実装する |
| バックエンド（BFF・マイクロサービス） | マスタの存在、一意性、状態遷移など、DB や業務ルールに基づく内容 | バックエンド側で検証し、エラーレスポンスを返す |

存在確認・一意性・状態遷移など、業務上の妥当性検証をフロントエンドで重複実装しない。フロントエンドは `apiCall` / `apiCallWithLoading`（5.16 参照）経由でバックエンドから返されたエラーを `useMessage()` で表示するのみに留める。

```ts
// ✅ 形式検証は props で宣言的に行う
<SstTextField v-model="form.warehouseCd" required :maxlength="20" />

// ✅ 業務検証（一意性・存在確認等）はバックエンドのエラーをそのまま表示する
const save = async (): Promise<void> => {
  const valid = await formRef.value?.validateAll();
  if (!valid) return;
  await apiCallWithLoading(() => SoMainteApi.saveSo({ soNo: form.value.soNo }));
};

// ❌ 存在確認などの業務検証をフロントエンドで再実装しない
const save = async (): Promise<void> => {
  const existing = await SoMainteApi.findBySoNo(form.value.soNo);
  if (existing) {
    useMessage().error('既に存在する受注番号です');
    return;
  }
  await apiCallWithLoading(() => SoMainteApi.saveSo({ soNo: form.value.soNo }));
};
```

### 5.8 i18n

画面の表示文字列は `useI18n()` 経由で取得し、直接文字列を書かない。ハードコードされた文字列は多言語対応・一括文言変更の妨げになる。

追加したキーは `ja / en / es / zh` の4ファイルすべてに反映する。一部ロケールにキーが存在しないと、画面にキー名がそのまま表示される。

```vue
<!-- ❌ 文字列を直接書いている -->
<SstButton text="保存" />
<p>データが見つかりませんでした</p>

<!-- ✅ i18n キーで取得 -->
<SstButton :text="t('button.save')" />
<p>{{ t('message.noData') }}</p>

<script setup lang="ts">
const t = useI18n();
</script>
```

### 5.9 TypeScript 型安全

`any` の使用を原則禁止する。`any` は TypeScript の型検査を無効化し、実行時エラーの温床になる。型が不明な場合は `unknown` を使い、型ガードで絞り込む。

```ts
// ❌ any を使うと型チェックが完全に無効になる
function process(data: any) {
  data.nonExistentMethod(); // 実行時エラー — コンパイル時に検出できない
}

// ✅ unknown + 型ガードで安全に絞り込む
function process(data: unknown) {
  if (typeof data === 'string') {
    console.log(data.toUpperCase());
  }
}
```

`@ts-ignore` / `@ts-expect-error` は原則禁止する。コンパイルエラーを隠すだけで根本解決にならず、後続の修正で気付かずに問題が広がる。テストコードで意図的に型違反を確認する場合に限り使用可とし、その際は理由をコメントで残す。

```ts
// ❌ 原則禁止：エラーを隠すだけで根本解決にならない
// @ts-ignore
const result = process(undefined);

// ✅ テストコードで意図的に型違反を確認する場合のみ、理由を添えて許可
// @ts-expect-error 引数なしで呼び出した場合の実行時エラーを検証するテストのため
process();
```

オブジェクトリテラルの型は `as Foo` での断定より、型注釈 `: Foo` を優先する。`as` は型定義が変更されてもエラーにならず、リファクタリング時のバグ混入リスクが高い。

```ts
// ❌ as で断定 → フィールドが増えてもエラーにならない
const condition = { ownerCd: 'OWN001' } as SearchCondition;

// ✅ 型注釈 → フィールド不足をコンパイル時に検出できる
const condition: SearchCondition = {
  ownerCd: 'OWN001',
  warehouseCd: 'WH001',
};
```

### 5.10 import / export

ES Modules（`import/export`）のみ使用する。`namespace` / `require` は禁止。

型のみを使うシンボルには `import type` / `export type` を使う。バンドル時の不要なランタイム依存を防ぎ、型チェックの精度を上げる。

```ts
// ❌ 型と値を同じ import に混在
import { SoSearchRequest, SoSearchApi } from './soSearchApi';

// ✅ 型は import type で分ける
import type { SoSearchRequest } from './soSearchApiType';
import { SoSearchApi } from './soSearchApi';
```

`default export` よりも named export を基本とする。named export はインポート時のスペルミスをコンパイラが検出できる。

```ts
// ❌ default export → インポート時の名前が自由なので追跡しにくい
export default function save() { /* ... */ }

// ✅ named export → 名前が一意に決まり、IDE の補完も効く
export function save() { /* ... */ }
```

### 5.11 定数・Enum の管理場所

定数は、使用範囲に応じて `src/constants/` またはその値を使う機能のローカルファイルへ配置する。

| 使用範囲 | 配置場所 | 実装形式 |
|---|---|---|
| アプリ全体で横断的に使う値（CSRF ヘッダー名等） | `src/constants/` 直下 | `export const` |
| 単一機能内でのみ使う値・状態 | その機能の `<feature>.types.ts` または composable 内 | `as const` オブジェクト / union literal type |

状態を表す値はマジックナンバー・マジックストリングとして業務コードへ直接記述せず、`as const` オブジェクトまたは union literal type で定義する。

```ts
// ✅ as const オブジェクトで状態を定義し、直値の記述を避ける
const CELL_SIZE_OPTIONS = { small: 10, normal: 20, large: 25 } as const;
type CellSize = keyof typeof CELL_SIZE_OPTIONS;
if (cellSize === CELL_SIZE_OPTIONS.small) { /* ... */ }

// ❌ 数値を業務コードへ直接記述しない
if (cellSize === 10) { /* ... */ }
```

```ts
// ✅ src/constants/security.ts — アプリ全体で使う値
export const CSRF_HEADER_NAME = 'X-XSRF-TOKEN';
```

単一機能でしか使わない値を `src/constants/` へ置くと、利用箇所と定義場所が離れて追跡しにくくなる。

### 5.12 変数と制御構文

`var` は禁止。`const` を基本とし、再代入が必要な場合のみ `let` を使う。

```ts
// ❌
var count = 0;
let label = 'hello'; // 再代入しないなら const にする

// ✅
const MAX_COUNT = 100;
let currentIndex = 0; // 再代入が必要な場合のみ let
```

等値比較は `===` / `!==` を使う。`null` との比較は `== null` を例外的に許容する（`null` と `undefined` の両方に一致させたい場合）。

```ts
// ❌ 暗黙の型変換が起きうる
if (ownerCd == '') { /* ... */ }

// ✅ === / !== を使う
if (ownerCd === '') { /* ... */ }

// ✅ null / undefined の両方に一致させたい場合のみ == null を許容する
if (ownerCd == null) { /* ... */ }
```

例外は必ず `new Error(...)` を投げる。文字列や数値を直接 `throw` するとスタックトレースが正しく取れず、障害調査が困難になる。

```ts
// ❌
throw 'validation failed';

// ✅
throw new Error('バリデーションに失敗しました');
```

### 5.13 型断定（as / !）

`as` や `!`（非null断定）は根拠が明白な場合のみ使用する。根拠が自明でない断定には、直前にコメントで安全性の根拠を残す。

```ts
// ✅ 根拠をコメントで明示した上で断定
// API のレスポンス仕様上、このフィールドは必ず存在する（OpenAPI 仕様 §5.3）
const ownerName = response.ownerNm!;
```

実行時チェック（`instanceof`、`in`、型ガード関数）で断定の代替を検討する。

```ts
// as による断定よりも instanceof / in の実行時チェックを優先する
if (error instanceof Error) {
  console.error(error.message);
}
```

`any` 型・`as` 断定・`!` アサーションは下表の条件を満たす場合のみ使用可とし、条件外の使用はレビューで差し戻す。

| 制限対象 | 使用条件 | コメント義務 |
|---|---|---|
| `any` 型 | 生成コード・外部ライブラリの型未整備に限る | 理由を必ずコメントで残す |
| `as` による型断定 | API 仕様等で型が保証されている場合に限る | 保証の根拠（仕様参照等）をコメントで残す |
| `!`（非nullアサーション） | 初期化済みが確実に保証されるスコープに限る | 根拠をコメントで残す |

### 5.14 データ構造

`interface` はオブジェクト構造の定義に使う。`type` は union / tuple / 合成型に使う。

```ts
// interface: オブジェクトの形を定義する場合
interface SearchCondition {
  ownerCd: string;
  warehouseCd: string;
  shipDateStart?: string;
}

// type: union や合成型を表現する場合
type Status = 'active' | 'inactive' | 'pending';
type SearchResult = SearchCondition & { totalCount: number };
```

連想配列が必要な場合は要件に応じて `Record<K, V>` / `Map<K, V>` を使い分ける。

```ts
// Record: キーが静的に決まっている場合（型安全が高い）
const statusLabels: Record<Status, string> = {
  active: '有効',
  inactive: '無効',
  pending: '保留',
};

// Map: キーが動的・実行時に変化する場合
const cache = new Map<string, SoDetailRow>();
cache.set(soNo, row);
```

### 5.15 日付・時刻

バックエンドから返却される日時（timestamp）は ISO 8601 の `Z` サフィックス付き（UTC）文字列であり、画面表示用に変換した値を state / Pinia ストアへ保持せず、表示直前にのみ変換する。

- API から受け取った日時文字列は UTC のまま保持し、加工せずに state / store に置く
- ローカルタイムゾーンでの表示が必要な場合は、`sstUtil().formatDate()` または `Intl.DateTimeFormat` を表示処理（テンプレート・算出プロパティ）の直前でのみ使用する
- 日付型（納期・有効期限等、タイムゾーン変換が不要な業務日付）は `YYYY-MM-DD` 形式の文字列としてそのまま送受信し、`Date` オブジェクトへ変換して保持しない
- 「今日」の判定はクライアント端末時刻に依存せず、バックエンドから返却された基準日時を用いる

```ts
// ✅ API から受け取った UTC 文字列をそのまま保持する
const createdAt = ref(response.createdAt); // ISO8601 UTC 文字列のまま

// ✅ 表示直前にのみローカル表記へ変換する
const displayCreatedAt = computed(() => sstUtil().formatDate(createdAt.value, 'YYYY/MM/DD HH:mm'));

// ❌ 変換後の値を state に保持しない（再変換時に誤差・二重変換の原因になる）
const createdAtJst = ref(dayjs(response.createdAt).add(9, 'hour').format());
```

### 5.16 API 呼び出し・状態管理・エラーハンドリング

API 呼び出しは `apiCall()` または `apiCallWithLoading()` でラップする。エラーハンドリングとローディング制御を一元管理するため、画面や composable から `axios` / `fetch` を直接呼ばない。API クライアント生成は `@/libs/client.ts` に集約し、設定の重複・不整合を防ぐ。

| 関数 | 用途 | ローディング表示 |
|------|------|:---:|
| `apiCall` | 検索・一覧取得・ドロップダウン | なし |
| `apiCallWithLoading` | 保存・削除・更新・重い処理 | あり |

```ts
// ✅ apiCallWithLoading でラップ
const save = async (): Promise<void> => {
  await apiCallWithLoading(() =>
    SoMainteApi.saveSo({ soNo: form.value.soNo })
  );
};

// ❌ axios を直接呼ぶとエラーハンドリングが個別実装になる
const save = async () => {
  try {
    await axios.post('/api/so/save', form.value);
  } catch (e) {
    // 個別実装が散らばる...
  }
};
```

画面固有の状態は composable で管理し、画面を跨ぐ共有状態のみ Pinia ストアに上げる。必要以上にグローバル化すると、どこで状態が変わったか追跡が困難になる。

```ts
// ✅ 画面固有の検索条件は composable のローカル状態で管理する
// useSoMainte.ts
const condition = ref<SearchCondition>({ ownerCd: '', warehouseCd: '' });

// ✅ ログインユーザー情報など画面を跨いで共有する状態は Pinia ストアに上げる
// stores/authStore.ts
export const useAuthStore = defineStore('auth', () => {
  const currentUser = ref<User | null>(null);
  return { currentUser };
});
```

ユーザー通知には `useMessage()` / `useDialog()` を使用する。`window.alert()` / `confirm()` / `prompt()` はデザイン統一・非同期制御の観点から禁止し、独自実装も行わない。

```ts
// ❌ デザインが統一されず、非同期制御もできない
if (confirm('削除しますか？')) {
  await deleteItem();
}

// ✅ useDialog() / useMessage() を使う
const dialog = useDialog();
const message = useMessage();

const confirmed = await dialog.confirm({ text: '削除しますか？' });
if (!confirmed) return;

await deleteItem();
message.success('削除しました。');
```

フォーム送信前に `formRef.value?.validateAll()` を呼び出し、失敗時は処理を中断する。

```ts
const save = async (): Promise<void> => {
  const valid = await formRef.value?.validateAll();
  if (!valid) return;
  await apiCallWithLoading(() => SoMainteApi.saveSo({ /* ... */ }));
};
```

バックエンドのエラーコードは i18n の `errors.codes.*` にマッピングし、画面側でのエラー文字列ハードコードを避ける。

### 5.17 ログの書き方

- API 呼び出しのエラーは `apiCall()` / `apiCallWithLoading()`（5.16 参照）が一元的に捕捉し `useMessage()` で通知するため、画面や composable で個別に `console.error()` を呼んでエラー通知を代替しない
- 調査目的の一時的な `console.log()` はコミット前に削除する。恒常的なログ出力として `console.log()` / `console.debug()` を業務コードに残さない
- OpenTelemetry のトレース（スパン）は `apiCall` / `apiCallWithLoading` 内で自動的に生成・送信される。業務コード（画面・composable）から `tracer.startSpan()` 等を直接呼び出し、独自の属性を手動で追加しない

```ts
// ❌ 個別の console.error でエラー通知を代替する
try {
  await SoMainteApi.saveSo(form.value);
} catch (error) {
  console.error('save failed', error); // apiCallWithLoading を使えば不要
}

// ✅ apiCallWithLoading に任せる（エラー通知・トレースは自動）
await apiCallWithLoading(() => SoMainteApi.saveSo(form.value));
```

```ts
// ❌ 業務コードで OTel スパンを手動生成し、独自属性を付与しない
const span = trace.getTracer('x').startSpan('customSpan');
span.setAttribute('so.no', soNo);

// ✅ apiCall 系のラッパーに任せる（内部で自動的にトレースされる）
await apiCall(() => SoSearchApi.findSo({ soNo }));
```

### 5.18 SstUtil ユーティリティクラス

以下の表に記載された操作については、必ず `SstUtil` ユーティリティクラスを使用し、独自実装を禁止する。  
`SstUtil` が提供する機能を重複実装すると、仕様変更時に修正箇所が分散し、動作不整合を招く。

```ts
// ✅ SstUtil 経由で使用（自動 import されるため import 不要）
const result = sstUtil().multiplyNumber(10, 5); // 50

// ❌ 同等の独自実装を作らない
const myMultiply = (a: number, b: number) => a * b;
```

`SstUtil` の提供機能一覧は `@sst-cm/sst-components` のドキュメントを参照すること。  
`SstUtil` の内容が更新された場合は、本規約も見直し・改訂すること。

---

### 5.19 禁止事項一覧

以下はレビューで差し戻しの対象となる禁止事項をまとめたものである。

| # | 禁止事項 | 代替手段 | 理由（要旨） |
|---|---|---|---|
| 1 | Options API | `<script setup lang="ts">` | 型推論が弱く、現スタックと不整合 |
| 2 | `window.alert()` / `confirm()` / `prompt()` | `useMessage()` / `useDialog()` | デザイン統一・非同期制御が崩れる |
| 3 | テキストの直接記述（ハードコード） | `useI18n()` 経由 | 多言語対応・一括修正の妨げ |
| 4 | `any` 型の無理由使用 | `unknown` + 型ガード | 型検査が無効化され実行時バグを誘発 |
| 5 | `@ts-ignore` の常用 | 型設計を直す | エラーを隠すだけで問題が蓄積する |
| 6 | 自動生成ファイルの手動編集 | 生成元を修正して再生成 | 次回の再生成で上書きされる |
| 7 | 画面・composable からの直接 HTTP 呼び出し | `@/api/` 層 + `apiCall` 系 | エラーハンドリングの一元管理が崩れる |
| 8 | API 層での `new Client(...)` | `@/libs/client.ts` で一元管理 | 設定の重複・不整合が起きやすい |
| 9 | サニタイズなしの `v-html` 使用 | `dompurify` を通す | XSS 脆弱性の直接的な原因になる |
| 10 | scoped なしの `<style>`（一般画面） | `<style scoped>` | スタイルが全画面へ意図せず漏れる |
| 11 | `v-for` と `v-if` の同一要素併用 | computed で分離するか `<template>` でラップ | 評価順バグ・パフォーマンス低下 |
| 12 | props の子コンポーネント内での直接変更 | `emit` で親へ通知 | データフローが追跡不能になる |
| 13 | `TODO` / `FIXME` のコミット | チケット化してコードから削除 | 曖昧な負債が蓄積し、管理不能になる |
| 14 | コメントアウトしたコードのコミット | 削除（履歴は Git で管理） | 不要コードが残るとノイズになる |
| 15 | `SstUtil` と重複する独自実装 | `sstUtil()` 経由で使用 | 仕様変更時に修正箇所が分散し不整合になる |
| 16 | 調査用 `console.log()` のコミット | 削除（5.17 参照） | ログが本番に残り、可読性・パフォーマンスを損なう |

---

## 6. 関連ドキュメント

| ドキュメント |
|-------------|
| 単体テスト規約 |
| 開発手順 |
| GitHub 運用ルール |
| AI 用 instructions |
| 共通開発規約 |

---

## 付録: 更新履歴

| 日付 | 版 | 内容 |
|------|---|------|
| 2026-06-11 | 初版 | 構成確定・Vue/TS 公式ガイドラインを反映・理由・例外を明文化 |
| 2026-06-18 | 第2版 | 規約体系に合わせて章立てを統一 |
| 2026-06-23 | 第3版 | バックエンド規約と構成を統一。MUST/SHOULD 表記を廃止し平文スタイルに変更 |
| 2026-07-07 | 第4版 | 共通規約（503967/503968）との整合を図る。ディレクトリ命名をニーモニックコード方式に修正（連番フォルダ廃止）。動詞 `fetch` → `find`（503967 動詞ルール）。欠落していた命名規則（日付・区分・コレクション）を 3.2.4〜3.2.6 として追加。共通フック推奨 const 名テーブルを 3.1 に追加。SstUtil 利用規約を 5.14 として追加 |
| 2026-08-27 | 第5版 | バックエンド開発規約の更新内容を反映。1.3 のツール適用ルールをライフサイクル表形式に統一。3.2.1 boolean 型の命名ルールを詳細化（is/has/can は必須接頭辞ではない旨、is...ed/is...able/対象+述語/is...Required パターンを追加）。3.2 に変数名の一般原則（data/info/value/temp 等の禁止、意味のない1文字変数の禁止）を追加。3.2.3 数値の命名（Count/Size, Quantity/Amount 等のサフィックス表）を新規追加し、以降の禁止命名パターンを 3.2.4〜3.2.7 に繰り下げ。4章のコメントの書き方を「基本理念／インラインコメント／禁止事項／JSDoc」の4節構成に再編。6章の関連ドキュメント表・2.2 のディレクトリツリー注釈記法をバックエンド規約と統一 |
| 2026-08-27 | 第6版 | 3.2.2としてboolean型と`boolean \| null` / `boolean \| undefined`の使い分け（未指定とfalseの区別が必要な場合のみ許容）を新規追加し、以降の命名パターンを3.2.3〜3.2.8に繰り下げ |
| 2026-08-27 | 第7版 | 5.7として「バリデーション」節を新規追加（形式検証はフロントエンドの props、業務検証はBFF/MSの責務としてフロントエンドでの重複実装を禁止）し、以降の5.7〜5.15を5.8〜5.16に繰り下げ |
| 2026-08-27 | 第8版 | バックエンド開発規約 5.8/5.11/5.7 に対応するフロントエンド節が存在しなかったため新規追加。5.11として「定数・Enum の管理場所」、5.15として「日付・時刻」、5.17として「ログの書き方」を追加し、以降の節番号を5.11〜5.16から5.12〜5.19に繰り下げ。5.7 バリデーション内の「5.14参照」を「5.16参照」に修正し、5.19 禁止事項一覧に console.log 放置禁止の行を追加 |
| 2026-08-27 | 第9版 | 1.1/2.1/2.2.1 のリポジトリ名表記を `sst-vue`（旧）から `{repo}`（現在の実リポジトリ）に修正。5.4に「画面の初期値取得は `onMounted` 内で実施する」ルールを追加（旧v4規約にあり、実コードで一貫して従われているため重要度高と判断）。なおimport順序ルール（Vue→外部→内部）は旧v4規約に記載があったが、現在の実コードでは一貫した順序が守られておらずESLintでも強制されていないため、本規約へは意図的に不追加 |
| 2026-08-27 | 第10版 | レビュー指摘を反映。1.3のコミットメッセージ規約をGit運用ガイドライン（`99.git/guideline.md`）への参照に変更し重複記載を解消。2.2.1のディレクトリツリーに実リポジトリに存在する`assets`/`errorPages`/`layouts`/`plugins`/`router`を追加。3.1のi18nキーに実コード（`ja.ts`）で確認できた共通名前空間（`status`/`dialog`/`validation`/`placeholder`）の表を追加。3.2.7に`xxxCategory`/`xxxLevel`を追加（実i18nキーの`addCategory`/`menuSettingsLevel1-3`で使用実績を確認。`xxxRank`/`xxxReason`は実コードでの使用実績が確認できなかったため見送り）。5.4に「副作用」の具体例（API呼び出し・DOM操作・タイマー登録・イベント購読・ログ送信・ストア書き込み）を追加。5.5に画面固有スタイル上書きを必要最小限に留める方針を追加。5.9（`@ts-ignore`）・5.12（等値比較）・5.16（composable/Piniaの使い分け、`useMessage`/`useDialog`）にコード例を追加 |
