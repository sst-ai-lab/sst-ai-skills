# イベント実装パターン

設計書の「イベント定義」セクションから実装するパターン集。

## 詳細設計書からの実装マッピング（必読・最優先）

各イベントの実装は、以下の対応で詳細設計書の記載をそのままコード構造に落とし込む。
自己流の解釈・順序の入れ替え・記載にない処理の追加は禁止。

| 詳細設計書の記載                                                   | 実装                                                                                                                                             |
| ------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| `### {イベント定義名}`                                             | composable 内の対応する1関数（`search`/`save`/`clear`/`onXxxClick` 等）                                                                          |
| `#### 処理概要` の番号付きステップ                                 | ステップの順序どおりに関数内の処理を実装する（省略・入替禁止）                                                                                   |
| `共通処理（FW）の場合はイベント定義の記載不要`                     | 独自実装せず、FW標準コンポーネントの挙動に任せる（関数自体を作らない場合もある）                                                                 |
| `**新規モード場合**` / `**編集モード場合**` の太字分岐             | `pcsMod.value === '0'`（新規）/ `'1'`（編集）等のモード変数で `if`/`switch` 分岐する。分岐ごとの処理は詳細設計書の該当箇条書きをそのまま実装する |
| `入力パラメータマッピング` 表                                      | リクエストオブジェクトの各フィールドの値の出所を決定する。対応コードパターンは `references/04-api-definition.md` を参照                                 |
| `##### 処理モード概要` の初期値設定表                              | モード切替（新規/複写/編集）時に `form` の初期値をセットし、`入力可/不可` が「不可」の項目は `disabled`/`readonly` にする                        |
| `画面ボタン制御` 表                                                | 対応ボタンの `:disabled`（または `v-show`）を該当モード/状態に応じて制御する                                                                     |
| `🔴【要詳細設計】` / `🟠【要基本設計書修正】` マーカーが付いた記載 | 推測実装せず、その部分は実装を止めてユーザーに質問する（`init.md` ルール#49）                                                                    |

## 追加条件（動的コンポーネントパターン）

設計書に「追加条件」セクションがある場合、ドロップダウンから条件を選択→動的にフォーム項目を追加→Chipタグで表示。

> **⚠️ 追加条件の選択肢:**
> 設計書に「DBから取得」「コードカテゴリキー: SOADDCONDITION」とある場合は `DropDownApi` で取得する。ハードコードしない。

```ts
// 追加条件の選択肢を DB から取得
const addConditionOptions = ref<DropdownResponse['data']>([]);
getDropdownItems('SOADDCONDITION', '', '*', '*').then((res) => {
  addConditionOptions.value = res.data || [];
});
```

```ts
// 型定義
type AddConditionKey = 'itemCd' | 'itemName' | 'soType' | 'ownerSoKbn' | 'delivSchDateStart' | 'delivSchDateEnd';

type AddConditionItem = {
  value: AddConditionKey;
  label: string; // ← DB から取得した表示ラベル（i18n キーではない）
  component: string;
  componentProps: Record<string, unknown>;
};

// コンポーネントマッピング（label は含めない — DB から取得する）
const addConditionComponentMap: Record<
  AddConditionKey,
  { component: string; componentProps: Record<string, unknown> }
> = {
  itemCd: { component: 'SstTextField', componentProps: {} },
  soType: { component: 'SstSelect', componentProps: { items: soTypeItems } },
  // ... 各条件キーに対応
};

const addCondition = ref<AddConditionKey | ''>('');
const conditionItems = ref<AddConditionItem[]>([]);

// まだ追加されていない条件のみ表示
const actualAddConditionOptions = computed(() => {
  const addedValues = new Set(conditionItems.value.map((item) => item.value));
  return addConditionOptions.value?.filter((option) => !addedValues.has(option.value as AddConditionKey));
});

// 条件追加
function onAddConditionChange(oldVal: AddConditionKey | '', newVal: AddConditionKey | '') {
  if (!newVal) return;
  const componentDef = addConditionComponentMap[newVal];
  if (!componentDef) return;
  const dbOption = addConditionOptions.value?.find((opt) => opt.value === newVal);
  conditionItems.value.push({
    value: newVal,
    label: dbOption?.label ?? newVal, // DB の label をそのまま使う
    ...componentDef,
  });
  addCondition.value = '';
}

// Chip閉じる
// ⚠️ コールバック引数に `t` を使うと i18n の `t` を shadow する → `el` 等の別名を使う
function conditionTabClose(item: AddConditionKey) {
  const index = conditionItems.value.findIndex((el) => el.value === item);
  if (index !== -1) conditionItems.value.splice(index, 1);
  form[item] = '';
}
```

> **⚠️ label はハードコード禁止。** DB取得した `addConditionOptions` の `label` をそのまま使う。
> テンプレートでも `t(item.label)` ではなく `item.label` を直接渡す。

テンプレート側:

```html
<!-- ⚠️ @change を使う（@update:model-value ではない）。@change は (oldVal, newVal) の2引数。 -->
<SstSelect
  v-model="addCondition"
  :items="actualAddConditionOptions"
  :label="t('label.addCondition')"
  @change="onAddConditionChange"
/>

<!-- 動的に追加された条件フォーム -->
<SstRow v-for="item in conditionItems" :key="item.value">
  <SstCol :cols="16">
    <component
      :is="item.component || 'SstTextField'"
      v-model="form[item.value]"
      :label="item.label"
      v-bind="item.componentProps"
    />
  </SstCol>
</SstRow>

<!-- Chip タグ一覧 -->
<SstChip
  v-for="item in conditionItems"
  :key="item.value"
  closable
  :model-value="item.label"
  @close="conditionTabClose(item.value)"
/>
```

## 操作ボタンの有効/無効制御（onSelectionChanged）

`onSelectionChanged` の実装パターン自体は `references/02-grid-definition.md` の「onSelectionChanged の実装パターン」を参照（重複定義しない）。ここではその `confirmDisabled`/`deleteDisabled` をボタンに反映するテンプレート例のみ示す。

テンプレート:

```html
<SstButton
  :color="confirmDisabled ? undefined : '#AFF4C6'"
  :disabled="confirmDisabled"
  prepend-icon="mdi-magnify"
  rounded
  :text="t('button.confirm')"
  variant="elevated"
  @click="confirm"
/>
<SstButton
  :color="deleteDisabled ? undefined : '#FCB3AD'"
  :disabled="deleteDisabled"
  prepend-icon="mdi-delete"
  rounded
  :text="t('button.delete')"
  variant="elevated"
  @click="deleteClick"
/>
```

> ⚠️ ボタン色: 正向操作（確定・引当）= `#AFF4C6`（緑）、逆向操作（取消・削除）= `#FCB3AD`（赤）。init.md 注意事項と同一の規約。

## クリア

> ⚠️ `setMemorize` はメモライズ保存のヘルパー関数。以下のように定義する:
>
> ```ts
> function setMemorize() {
>   saveMemorizeConfig(MEMORIZE_CONFIG);
> }
> ```
>
> `saveMemorizeConfig` は `useFormDisplayConfig()` から取得し、`MEMORIZE_CONFIG` は composable 冒頭で定義した定数を参照する。

```ts
const clear = (): void => {
  // 追加条件がある場合はクリア
  conditionItems.value = [];
  addCondition.value = '';
  // Grid データ + ページネーション初期化
  gridData.value = [];
  paginationSettings.page = 1;
  paginationSettings.total = 0;
  // Form リセット
  formRef.value?.resetAll();
  // ドロップダウン再取得（init で取得した選択肢を最新化）
  doInit();
  // メモライズ
  setMemorize();
};
```

> ⚠️ 検索画面の `clear` は Form だけでなく **Grid データ・ページネーション・追加条件** もすべてリセットすること。

## 検索

```ts
async function search(): Promise<void> {
  const valid = await formRef.value?.validateAll();
  if (!valid) return;
  paginationSettings.page = 1;
  activeTab.value = 'result'; // ⚠️ タブ構成（Figmaでタブ分割されている場合）のみ。単一ページ構成なら本行は不要（init.md 規則 #50）
  await getData();
  saveMemorizeConfig(MEMORIZE_CONFIG);
}
```

## 保存（登録・更新）

```ts
const save = async (): Promise<void> => {
  const valid = await formRef.value?.validateAll()
  if (!valid) return

  // ⚠️ キャストルール:
  // - form のフィールド名が API 型と一致する場合 → `{ ...form } as Web.XxxRequest` で直接キャスト可
  // - フィールド名が異なる場合 → 明示的にオブジェクトを組み立てる
  // - ❌ 禁止: `{ ...form } as unknown as Record<string, unknown>`（トリプルキャストで型安全性バイパス）
  // - 配列の要素型変換のみ `as unknown as` を許容する
  const res = await {機能名Pascal}Api.save({
    so: { ...form } as Web.{SoMainteSaveSoHeader},
    soDetail: gridData.value as unknown as Web.{SoMainteSaveSoDetail}[],
  })

  // ⚠️ 新規作成時はレスポンスの主キーを form に反映する（レスポンス無視禁止）
  if (pcsMod.value === '0' && res?.soNo) {
    form.soNo = res.soNo
    addTreeItem(form.soNo)
    pcsMod.value = '1'
  }
  pageDirty.markClean()
  message.info(t('information.codes.I00001'))
}
```

## 削除

```ts
const deleteData = async (): Promise<void> => {
  await {機能名Pascal}Api.delete({
    companyCd: '',   // 必要に応じてストアから取得
    {idField}: {idValue},
  })
}
```

## バッチ操作（確定・引当・実績追加・削除 等）

検索画面で複数行を選択してバッチ処理する場合、**ロジックが重複する関数を個別に書くのは禁止**（SonarQube 重複コード検出対象）。
共通の `batchAction` ヘルパーを定義し、各操作はそれを呼び出す形にする。

> **⚠️ `useDialog`/`useMessage` の正しい使い方は `init.md` 規則 #43/#44 を参照**（`dialog.confirm()` はオブジェクト引数、`message.showXxx` は存在しない等）。以下は `batchAction` 内での実際の使用例。

```ts
const dialog = useDialog();
const message = useMessage();

// ── 共通バッチ操作ヘルパー ──
async function batchAction(
  apiMethod: (params: { soNo: { soNo: number; exclusionCheck: string }[] }) => Promise<unknown>,
  confirmMessageKey: string,
): Promise<void> {
  const confirmed = await dialog.confirm({ content: t(confirmMessageKey) });
  if (!confirmed) return;
  const soNoList = selectedRows.value.map((row) => ({
    soNo: row.soNo!,
    exclusionCheck: row.exclusionCheck ?? '',
  }));
  await apiMethod({ soNo: soNoList });
  message.info(t('information.codes.I00001'));
  await getData();
}

// ── 各操作はヘルパーを呼ぶだけ ──
const confirm = () => batchAction(SoSearchApi.batchConfirm, 'message.confirmConfirm');
const allocate = () => batchAction(SoSearchApi.batchAllocate, 'message.confirmAllocate');
const actualAdd = () => batchAction(SoSearchApi.batchActualAdd, 'message.confirmActualAdd');
const deleteData = () => batchAction(SoSearchApi.batchDelete, 'message.confirmDelete');
```

> **ルール:** 3つ以上の関数が同じパターン（dialog確認→リスト作成→API呼出→メッセージ→再検索）を繰り返す場合は**必ず共通化**する（init.md 規則 #46）。`dialog`/`message` の使い方は前述の init.md 規則 #43/#44 を参照。

## APIレスポンス → グリッドデータ代入

```ts
// 型が異なる場合は as unknown as でキャスト
gridData.value = (response.soDetail ?? []) as unknown as { RowType }[];
```
