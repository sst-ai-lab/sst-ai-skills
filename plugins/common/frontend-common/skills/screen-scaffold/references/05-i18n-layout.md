# 多言語・レイアウト

i18n 規則と Figma MCP を使ったレイアウト生成。

## i18n キー形式

> 複数画面で使い回す共通語彙（ラベル・ボタン・パネル・タブ・バリデーションメッセージ等）は、画面名プレフィックスを付けず **フラットキー** を使う。画面固有のトップレベル（例: 画面全体のタイトル）に限り、機能名（ニーモニックコード）でネストしてよい。

```ts
// ✅ 正しい（複数画面で使い回す共通語彙 → フラット）
t('label.ownerCode');
t('button.search');
t('panel.searchCondition');

// ✅ 正しい（画面固有のトップレベルタイトル → 機能名ネスト。実例: login.title, aiChat.title, ocr.title）
t('soMainte.title');

// ❌ 誤り（共通語彙カテゴリ `label` の下に画面名を割り込ませる）
t('soPlanSearch.label.ownerCode');
```

共通語彙は `label.xxx`, `button.xxx`, `panel.xxx`, `tab.xxx`, `validation.xxx` 等のカテゴリ別キーに置く。画面固有のトップレベルキー（`<機能名>.title` 等）を新設する場合も、その画面の他の文言（ラベル等）まで機能名の下にネストしないこと — あくまで共通カテゴリに置けない画面固有のトップレベル項目だけが対象。

## 既存キーを優先して流用する（最重要）

> **新しいキーを作る前に `src/locales/ja.ts` を読んで既存キーを確認すること。**

よくある命名ミス:
| 使いたいもの | 誤（新規） | 正（既存キー） |
|-------------|-----------|--------------|
| 伝票タイプ | `label.soType` | `label.slipType` |
| 取引先コード | `label.ownerCd` | `label.ownerCode` |
| 倉庫コード | `label.warehouseCd` | `label.warehouseCode` |
| 出荷先コード | `label.shipperCd` | `label.shipperCode` |
| 取引先出荷区分 | `label.ownerSoKbn` | `label.shipDiv` |
| 引当バッチキー | `label.allocBatchKey` | `label.pickBatchKey` |
| 複製ボタン | `button.duplicate` | `button.copy` |

## 多言語追加ルール

- 使用するキーを **4言語すべて** (`ja.ts`/`en.ts`/`zh.ts`/`es.ts`) に追加
- コード生成後、必ず `src/locales/ja.ts` を確認し使用キーが存在するかチェック

```ts
// ja.ts 追加例
panel: {
  soBaseInfo: '出荷メイン情報',
},
label: {
  soSlipNo: '出荷伝票番号',
  regDateTime: '登録日時',
},
```

---

## Figma MCP デザイン取得

### URL 変換ルール

設計書の embed URL → MCP 用 URL:

```
# embed 形式
https://embed.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}&embed-host=share

# MCP に渡す形式
https://www.figma.com/design/{fileKey}/{fileName}?node-id={nodeId}
```

### ツール使い分け

| ツール               | 用途                                                  |
| -------------------- | ----------------------------------------------------- |
| `get_design_context` | コンポーネント種別・プロパティ・テキスト内容          |
| `get_screenshot`     | **`SstCol :cols` 算出に必須**（カラム比率の視覚確認） |

> **両ツールを必ず並列で呼び出すこと。**

### 活用手順

1. 設計書の「レイアウト」セクションから Figma URL を取得
2. `get_design_context` + `get_screenshot` を同時に呼び出す
3. スクリーンショットから cols 比率を読み取る
4. 生成コードから Sst コンポーネントを選定
5. 組み合わせてテンプレート生成

### Figma → Sst コンポーネント変換

| Figma UI要素     | Sst コンポーネント               |
| ---------------- | -------------------------------- |
| テキスト入力     | `<SstTextField>`                 |
| 数値入力         | `<SstNumberInput>`               |
| 日付入力         | `<SstDateInput>`                 |
| プルダウン       | `<SstSelect>`                    |
| ラジオボタン     | `<SstRadio>`                     |
| チェックボックス | `<SstCheckbox>`                  |
| コード+名称      | `<SstCodeName>`                  |
| ボタン           | `<SstButton>`                    |
| アコーディオン   | `<SstPanel variant="accordion">` |
| タブ             | `<SstTabs>`                      |
| グリッド         | `<SstGrid>`                      |
| ツリー           | `<SstTreeview>`                  |

---

## SstRow / SstCol レイアウト（24カラムグリッド）

`SstCol` の `:cols` で占有幅を指定（合計 = 24）。

### よく使う分割パターン

| レイアウト           | cols       | 使用場面             |
| -------------------- | ---------- | -------------------- |
| 全幅                 | `24`       | ボタン行・グリッド   |
| 2等分                | `12` × 2   | 横並び2項目          |
| 3等分                | `8` × 3    | 横並び3項目          |
| 4等分                | `6` × 4    | 横並び4項目          |
| ツリー+フォーム(1:5) | `4` + `20` | 左ツリー＋右フォーム |
| ツリー+フォーム(1:3) | `6` + `18` | 左ツリー＋右フォーム |

### cols 算出手順

1. `get_screenshot` でスクリーンショット取得
2. 各行のアイテム数と幅比率を視覚的に読み取る
3. 比率を 24 に換算
4. 同じ `SstRow` 内の合計が **24** であることを確認

### チェックリスト

- [ ] 同じ `SstRow` 内の `:cols` 合計が **24**
- [ ] ツリー比率は `get_screenshot` で視覚確認済み
- [ ] ボタン行は `justify="space-between"` or `justify="end"`
- [ ] パネル内項目は `:cols="12"` の2列配置を基本
