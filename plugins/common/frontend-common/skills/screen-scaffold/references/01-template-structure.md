# テンプレート構造

検索画面・登録画面の標準テンプレートとcomposable骨格。

## 検索画面の標準テンプレート

> **⚠️ レイアウト構造（タブ分割か単一ページか）は必ずFigmaの実際のレイアウトを優先する。**
> 以下の `SstTabs`（条件タブ + 結果タブ）構成は、Figmaで検索条件と検索結果が別タブに
> 分かれているケースの標準例にすぎない。Figmaで検索条件と検索結果が同一ページ内に
> 縦に並んでいる（タブ切替が存在しない）場合は、`SstTabs`/`#condition`/`#result` を使わず、
> 条件ブロック（`SstForm`）→ 結果ブロック（グリッド）をページ内に直接、上から順に配置すること。
> ボタン配置・`SstCard` によるグループ分け・列比率などのスタイル規約は、タブ有無に関わらずそのまま適用する。

検索画面は、Figmaでタブ分割されている場合に `SstTabs`（条件タブ + 結果タブ）を使用する。

- **`SstForm` は `#condition` スロットの内側に配置する**（SstTabs の外側に置かない）
- 条件タブ内のボタン（検索・クリア）は **フォームの先頭行**に配置し、`div.button-group.button-group--floating` で囲む
- 条件フォームの項目は `SstCard` + `SstCardTitle` + `SstCardText` でグループ分けする（`SstPanel` は使わない）
- Figmaの比率に合わせて左右の `SstCol` を分ける（例: 基本条件 `:cols="14"`、追加条件 `:cols="10"`）

```html
<template>
  <SstTabs v-model="activeTab" v-model:tabs="tabItems" :closable="false">
    <template #condition>
      <SstForm id="form" ref="formRef">
        <!-- ① ボタン行（先頭に配置） -->
        <SstRow justify="end">
          <SstCol align="end" :cols="24" :gap="8">
            <div class="button-group button-group--floating">
              <SstButton
                prepend-icon="mdi-close"
                rounded
                :tab="14"
                :text="t('button.clear')"
                variant="outlined"
                @click="clear"
              />
              <SstButton
                color="primary"
                prepend-icon="mdi-magnify"
                rounded
                :tab="15"
                :text="t('button.search')"
                variant="elevated"
                @click="search"
              />
            </div>
          </SstCol>
        </SstRow>
        <!-- ② フォーム項目（SstCard で分区） -->
        <SstRow>
          <SstCol :cols="14">
            <SstCard variant="outlined">
              <SstCardTitle>{{ t('panel.basicCondition') }}</SstCardTitle>
              <SstCardText>
                <SstRow>
                  <SstCol :cols="12">
                    <SstCodeName
                      id="ownerCd"
                      v-model="form.ownerCd"
                      v-model:name="form.ownerNm"
                      :code-type="CodeNameType.OWNER"
                      :iconclick="ownerCdIconclick"
                      :label="t('label.ownerCode')"
                      :maxlength="20"
                      required
                      :tab="1"
                      @retrieve-data="handleFetchOwnerCd"
                    />
                  </SstCol>
                  <SstCol :cols="12">
                    <!-- 項目B -->
                  </SstCol>
                </SstRow>
              </SstCardText>
            </SstCard>
          </SstCol>
          <SstCol :cols="10">
            <SstCard variant="outlined">
              <SstCardTitle>{{ t('panel.additionalCondition') }}</SstCardTitle>
              <SstCardText>
                <!-- 追加条件 -->
              </SstCardText>
            </SstCard>
          </SstCol>
        </SstRow>
      </SstForm>
    </template>
    <template #result>
      <!-- 結果タブ: 操作ボタン + グリッド -->
    </template>
  </SstTabs>
  <!-- Lookup ダイアログ（SstTabs の外に配置） -->
  <SstDialog v-model="showLookupDialog" width="900">
    <CommonLookup v-if="currentLookupType" :lookup-key="currentLookupKey" @row-select="onLookupSelected" />
  </SstDialog>
</template>

<script setup lang="ts">
  import { use{機能名Pascal} } from './use{機能名Pascal}'
  import { useI18n } from '@sst-cm/sst-fw-web'
  import CommonLookup from '{commonLookupImportPath}'
  // ⚠️ CodeNameType はテンプレートで :code-type="CodeNameType.OWNER" のように使う場合ここで import
  import { CodeNameType } from '@/constants/codeNameType'

  const t = useI18n()

  // ⚠️ テンプレートで実際に使う値だけを展開する（未使用の展開は SonarQube デッドコード違反）
  const {
    formRef,
    form,
    clear,
    // ... composableが返す値（テンプレートで使うもののみ）
  } = use{機能名Pascal}()
</script>
```

## 登録・メンテナンス画面の標準テンプレート

登録画面（メンテナンス画面）は検索画面と構造が異なる。

- **左カラム: SstTreeview**（出荷番号等のツリー） + **右カラム: SstTabs**（入力フォーム + 明細グリッド）
- **⚠️ ボタン位置は画面下部固定ではない**: `SstTabs` の外側・ページ右上付近に `position-fixed` ユーティリティクラス + インラインstyle（例: `style="top:110px;right:30px"`）で浮かせて配置する（下記テンプレート例参照）。**Figmaの実際のボタン位置を必ず確認し、上下のオフセット値（`top`）はFigmaのレイアウトに合わせて調整する**（一律で画面最下部に固定しない）。この点はレイアウト構造と同様、テンプレートよりFigmaの実際の見た目を優先する（`references/init.md` 規則 #50 と同じ考え方）
- **SstPanel** でセクション分割し、`SstCard` でヘッダ情報を括る
- パネルは **横2列配置** (`SstCol :cols="12"` × 2) — 左が常時表示、右が非表示可能（`:hidden` + `@append-icon-click`）
- **⚠️ システム情報パネルの要否はユーザーに確認する**: 登録日時・登録者・登録端末・更新日時・更新者・更新端末・有効フラグ等の監査項目（`add*`/`upd*`列）が項目定義にあるのに、基本設計書の画面モックアップに `t('panel.systemInfo')` に相当するパネルが見当たらない場合は、自己判断で追加/省略を決めず、実装前にユーザーへ追加要否を確認する（`init.md` 規則 #53）。ユーザーが追加を了承した場合、右側の非表示可能パネルの1つとして実装する。画面モックアップに既にシステム情報パネルが描かれている場合は確認不要でそのまま実装する。標準フィールド構成は本テンプレート例と「システム情報パネルの標準構成」節を参照
- `usePageChange()` でダーティチェック（ページ離脱時の未保存警告）を行う

```html
<template>
  <div>
    <SstRow>
      <!-- 左カラム: ツリー（表示/非表示切替あり） -->
      <SstCol v-show="timeTreeShowFlg" :cols="treeLength">
        <SstTreeview
          id="soNoTreeView"
          v-model="form.soNoTreeView"
          v-model:opened="openedNodes"
          :allow-deselect="false"
          :filter-label="t('label.shipScheduleNo')"
          :filter-length="20"
          filterable
          item-label="label"
          item-value="id"
          :items="treeItems"
          select-strategy="single-leaf"
          @item-select="onTreeItemSelect"
        />
      </SstCol>
      <!-- 右カラム: タブ（条件=入力フォーム、結果=明細グリッド） -->
      <SstCol :cols="otherColLength">
        <SstTabs v-model="activeTab" v-model:tabs="tabItems" :closable="false">
          <template #condition>
            <SstForm id="form" ref="formRef">
              <!-- ⚠️ ボタン空行（実際のボタンは SstTabs の外側に position-fixed で配置）— この空 SstRow は省略禁止 -->
              <SstRow class="button-toolbar-row">
                <SstCol :cols="24"> </SstCol>
              </SstRow>
              <SstRow>
                <SstCol :cols="24">
                  <!-- ヘッダ情報カード -->
                  <SstCard :title="`*${t('tab.basic')}`" variant="outlined">
                    <template #append>
                      <!-- パネル表示/非表示メニュー -->
                      <SstMenu v-model="panelHidMenuOpen" :close-on-content-click="false" location="bottom start">
                        <template #activator="{ props }">
                          <span v-bind="props" style="cursor: pointer">
                            <SstIcon size="small"> mdi-format-list-bulleted </SstIcon>
                          </span>
                        </template>
                        <SstCard style="min-width: 400px; max-width: 600px" variant="flat">
                          <SstCardText class="pa-3">
                            <SstChip
                              v-for="field in hiddenPanelKeyList"
                              :key="field.key"
                              closable
                              size="small"
                              style="margin-left: 3px"
                              @click:close="showPanelHandle(field.key)"
                            >
                              {{ field.name }}
                            </SstChip>
                          </SstCardText>
                        </SstCard>
                      </SstMenu>
                    </template>
                    <SstCardText>
                      <!-- ステータス + 基本項目 -->
                      <SstRow>
                        <SstCol :align="'center'" :cols="3">
                          <SstChip
                            v-if="pcsMod == '1'"
                            id="status"
                            v-model="form.status"
                            color="rgb(234, 221, 255)"
                            :interactive="false"
                            variant="flat"
                          />
                        </SstCol>
                        <SstCol :cols="5">
                          <SstTextField
                            id="soNo"
                            v-model="form.soNo"
                            :clearable="false"
                            :label="t('label.soNo')"
                            readonly
                            variant="plain"
                          />
                        </SstCol>
                        <SstCol :cols="10">
                          <SstSelect
                            id="soType"
                            v-model="form.soType"
                            :items="soTypeItems"
                            :label="t('label.slipType')"
                            required
                            :tab="1"
                          />
                        </SstCol>
                      </SstRow>
                      <!-- パネル（横2列: 左=常時表示 / 右=非表示可能） -->
                      <SstRow>
                        <SstCol :cols="12">
                          <SstPanel
                            id="baseInfo"
                            v-model="form.basePanelFlg"
                            elevation="3"
                            :title="`*${t('panel.baseInfo')}`"
                            variant="accordion"
                          >
                            <SstRow>
                              <SstCol :cols="12">
                                <SstCodeName
                                  id="ownerCd"
                                  v-model="form.ownerCd"
                                  v-model:name="form.ownerName"
                                  :code-type="CodeNameType.OWNER"
                                  :iconclick="ownerCdIconclick"
                                  :label="t('label.ownerCode')"
                                  :maxlength="20"
                                  required
                                  :tab="2"
                                  @retrieve-data="handleFetchOwnerCd"
                                />
                              </SstCol>
                            </SstRow>
                          </SstPanel>
                        </SstCol>
                        <SstCol :cols="12" :hidden="hidden.subInfoHidden">
                          <SstPanel
                            v-model="form.subInfoFlg"
                            append-icon="mdi-close"
                            elevation="3"
                            :hidden="hidden.subInfoHidden"
                            :title="t('panel.subInfo')"
                            variant="accordion"
                            @append-icon-click="hiddenPanelClick('subInfoHidden', t('panel.subInfo'))"
                          >
                            <!-- 非表示可能パネルの中身（機能固有。詳細は設計書に従う） -->
                          </SstPanel>
                        </SstCol>
                        <!-- ⚠️ システム情報パネル: add*/upd* 監査列があるのにモックアップになければユーザーに追加要否を確認（詳細は「システム情報パネルの標準構成」節） -->
                        <SstCol :cols="12" :hidden="hidden.systemInfoHidden">
                          <SstPanel
                            v-model="form.systemInfo"
                            append-icon="mdi-close"
                            elevation="3"
                            :hidden="hidden.systemInfoHidden"
                            prepend-icon="mdi-information-outline"
                            :title="t('panel.systemInfo')"
                            variant="accordion"
                            @append-icon-click="hiddenPanelClick('systemInfoHidden', t('panel.systemInfo'))"
                          >
                            <SstRow>
                              <SstCol :cols="12">
                                <SstSelect
                                  id="actFlg"
                                  v-model="form.actFlg"
                                  item-title="label"
                                  item-value="value"
                                  :items="actFlgItems"
                                  :label="t('label.actFlg')"
                                  :tab="71"
                                  width="100%"
                                />
                              </SstCol>
                            </SstRow>
                            <SstRow>
                              <SstCol :cols="12">
                                <SstDateTimeInput
                                  id="addDateTime"
                                  v-model="form.addDateTime"
                                  disabled
                                  :label="t('label.addDateTime')"
                                />
                              </SstCol>
                              <SstCol :cols="12">
                                <SstDateTimeInput
                                  id="updDateTime"
                                  v-model="form.updDateTime"
                                  disabled
                                  :label="t('label.updDateTime')"
                                />
                              </SstCol>
                            </SstRow>
                            <SstRow>
                              <SstCol :cols="12">
                                <SstTextField
                                  id="addUserName"
                                  v-model="form.addUserName"
                                  disabled
                                  :label="t('label.addUserCode')"
                                  width="100%"
                                />
                              </SstCol>
                              <SstCol :cols="12">
                                <SstTextField
                                  id="updUserName"
                                  v-model="form.updUserName"
                                  disabled
                                  :label="t('label.updUserCode')"
                                  width="100%"
                                />
                              </SstCol>
                            </SstRow>
                            <SstRow>
                              <SstCol :cols="12">
                                <SstTextField
                                  id="addTerminalCd"
                                  v-model="form.addTerminalCd"
                                  disabled
                                  :label="t('label.addTerminalCode')"
                                  width="100%"
                                />
                              </SstCol>
                              <SstCol :cols="12">
                                <SstTextField
                                  id="updTerminalCd"
                                  v-model="form.updTerminalCd"
                                  disabled
                                  :label="t('label.updTerminalCode')"
                                  width="100%"
                                />
                              </SstCol>
                            </SstRow>
                          </SstPanel>
                        </SstCol>
                      </SstRow>
                    </SstCardText>
                  </SstCard>
                </SstCol>
              </SstRow>
            </SstForm>
          </template>
          <template #result>
            <!-- ⚠️ ボタン空行（実際のボタンは SstTabs の外側に position-fixed で配置）— この空 SstRow は省略禁止 -->
            <SstRow class="button-toolbar-row">
              <SstCol :cols="24" />
            </SstRow>
            <SstRow>
              <SstCol :cols="24">
                <SstGrid
                  id="grid"
                  ref="gridRef"
                  v-model="gridData"
                  :column-defs="columnDefs"
                  filter
                  pagination-mode="client"
                  show-checkbox-column
                  sortable
                  :toolbar-config="{
                    showInsert: true,
                    showCopy: true,
                    showDelete: true,
                    showColVis: true,
                    showPinCol: true,
                    showExport: true,
                    showSettings: true,
                    showImport: true,
                  }"
                  width="100%"
                  @grid-ready="onDetailGridReady"
                />
              </SstCol>
            </SstRow>
          </template>
        </SstTabs>
      </SstCol>
    </SstRow>
    <!-- ボタン行（⚠️ 画面下部固定ではなく、右上付近に浮かせる。top値はFigmaの実際の位置に合わせて調整する） -->
    <SstRow class="button-toolbar-row position-fixed" justify="end" style="top:110px;right:30px">
      <SstCol align="end" :cols="24" :gap="8">
        <SstButton
          id="saveBtn"
          :color="'#AFF4C6'"
          prepend-icon="mdi-check"
          rounded
          :tab="72"
          :text="t('button.save')"
          variant="flat"
          @click="save"
        />
        <SstButton
          prepend-icon="mdi-close"
          rounded
          :tab="75"
          :text="t('button.clear')"
          variant="outlined"
          @click="clearForm"
        />
      </SstCol>
    </SstRow>
  </div>

  <!-- Lookup ダイアログ -->
  <SstDialog v-model="showLookupDialog" width="900">
    <CommonLookup v-if="currentLookupType" :lookup-key="currentLookupKey" @row-select="onLookupSelected" />
  </SstDialog>
</template>
```

### 登録画面の script setup

```ts
<script setup lang="ts">
import { use{機能名Pascal} } from './use{機能名Pascal}'
import CommonLookup from '{commonLookupImportPath}'
// ⚠️ CodeNameType をテンプレートで使う場合はここで import（composable ではなくここ）
import { CodeNameType } from '@/constants/codeNameType'

const t = useI18n()

// ⚠️ テンプレートで実際に使う値だけを展開する
// composable 内部でのみ使う値（columnDefs 内で参照する statusItems 等）はここで展開しない
// 未使用の展開変数は SonarQube デッドコード違反になる
const {
  formRef,
  form,
  gridData,
  gridRef,
  columnDefs,
  tabItems,
  activeTab,
  treeItems,
  timeTreeShowFlg,
  treeLength,
  otherColLength,
  openedNodes,
  hidden,
  hiddenPanelKeyList,
  panelHidMenuOpen,
  pcsMod,
  fieldDisabled,
  buttonDisabled,
  showLookupDialog,
  currentLookupType,
  currentLookupKey,
  save,
  clearForm,
  newForm,
  onTreeItemSelect,
  onDetailGridReady,
  ownerCdIconclick,
  handleFetchOwnerCd,
  onLookupSelected,
  hiddenPanelClick,
  showPanelHandle,
} = use{機能名Pascal}()
</script>
```

> **ボタンの CSS について**: 上記テンプレート例のボタン行は `position-fixed`（フレームワーク提供のユーティリティクラス）+ インライン `style="top:...;right:..."` だけで位置を決める。`.button-group--fixed`（`position:fixed; bottom:0`）のような自作の画面下部固定CSSは**作成しない**こと（旧パターンであり、Figmaの実際のボタン位置と一致しない可能性が高い）

> **検索画面との主な違い:**
>
> - ボタンは `position-fixed` ユーティリティクラス + インラインstyleでページ上の任意の位置（Figmaに合わせる。上記例は右上）に浮かせる。検索画面は `button-group--floating`（フォーム先頭行、通常フロー）
> - `SstPanel` でセクションを分割する（検索画面は `SstCard` + `SstCardTitle`）
> - パネル非表示機能: `:hidden` + `append-icon="mdi-close"` + `@append-icon-click` + `SstMenu` + `SstChip` パターン
> - 左カラムにツリー (`SstTreeview filterable`) を配置
> - グリッドは `pagination-mode="client"` + `toolbar-config` でツールバーを表示（行追加・コピー・削除等）
> - `usePageChange()` でダーティチェック
> - **システム情報パネル（`panel.systemInfo`）**（`add*`/`upd*` 監査列がある場合。検索画面にはないパターン）。画面モックアップにない場合は自己判断せずユーザーに確認（`init.md` 規則 #53）

## composable 骨格（use{機能名Pascal}.ts）

> **⚠️ composable には以下の機能を必ず含めること:**
>
> - **`:tab` 属性**: すべてのフォーム入力コンポーネントに `:tab="N"` でタブ順序を指定する（1から連番）
> - **Hotkey**: `useSstHotkeyScope` を使ってキーボードショートカットを登録する。システム共通ルール:
>   - **F3=検索 / F4=複製 / F6=新規 / F7=保存 / F8=クリア / F9=実行**
>   - その画面に存在するボタンに対応するキーをすべて登録する（画面種別での区別なし）
> - **メモライズ**: 設計書に `メモライズ: ✔` がある場合、`useFormDisplayConfig` で前回入力値を保存・復元する
> - **Lookup ダイアログ**: `SstCodeName` に `:iconclick` でダイアログを開く処理を追加する。**`// TODO` や空実装は禁止** — `:iconclick` を指定した全ての `SstCodeName` に対して `showLookupDialog.value = true` で Lookup を開く完全な関数を実装すること。テンプレートの `<SstDialog>` + `<CommonLookup>` も省略禁止（検索画面・登録画面とも）
> - **sstUtil の活用**: 日付取得は `sstUtil().getCurrentDate('YYYYMMDD')` を使い、`new Date()` で自作しない
> - **Grid Select 列の dropdown**: `init()` で `DropDownApi` を呼んで items を取得し、`cellEditorParams.items` に `.value` を渡す。**`items: []` は禁止**
> - **多言語変数は `computed` で囲む**: `t()` を使う変数（`tabItems`, `columnDefs`, `statusTypeItems` 等）は必ず `computed(() => [...])` で宣言する
> - **usePageChange（登録画面のみ）**: 保存成功後に `markClean()`、画面離脱前に `confirmValueChanged()` を呼ぶ

### システム情報パネルの標準構成（追加はユーザー確認後）

登録・メンテナンス画面で、対象エンティティに `add*`/`upd*` 監査列（登録日時・登録者・登録端末・更新日時・更新者・更新端末・有効フラグ等）が項目定義にあるが、**基本設計書のモックアップに `panel.systemInfo` に相当するパネルが明示されていない**場合は、自己判断で追加/省略を決めず先にユーザーに確認する（`init.md` 規則 #53）。ユーザーが追加を了承した場合、または画面モックアップに既にパネルが描かれている場合に、`panel.systemInfo` パネルを右側の非表示可能パネルとして配置する。フィールド構成:

| フィールド                                         | コンポーネント     | 備考                                  |
| -------------------------------------------------- | ------------------ | ------------------------------------- |
| `actFlg`（有効フラグ）                             | `SstSelect`        | `actFlgItems`（DropDownApi 等）を渡す |
| `addDateTime` / `updDateTime`（登録/更新日時）     | `SstDateTimeInput` | `disabled`                            |
| `addUserName` / `updUserName`（登録者/更新者）     | `SstTextField`     | `disabled`                            |
| `addTerminalCd` / `updTerminalCd`（登録/更新端末） | `SstTextField`     | `disabled`                            |

`form` にはこれらのフィールド + `systemInfo`（パネル開閉フラグ）を追加し、`hidden` には `systemInfoHidden` を追加する（既存の `subInfoHidden` と同じパターン）。テンプレート例は上記の登録画面テンプレートの「システム情報パネル」ブロックを参照。

```ts
import { reactive, ref, computed, onMounted } from 'vue'
import { useI18n, useMessage, useDialog, sstUtil, useSstHotkeyScope } from '@sst-cm/sst-fw-web'
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig'
import type { {RequestType}, {ResponseType} } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}ApiType'
import { {機能名Pascal}Api } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}Api'
import { DropDownApi } from '{dropDownApiDir}/dropDownApi'

// ⚠️ import ルール:
// - すべての使用シンボルは明示的に import を書く（このファイルで実際に使うものだけ）
// - 同じパッケージからの import は1行にまとめる（重複行禁止）
// - useI18n, useMessage, useDialog, useNotification, sstUtil, useSstHotkeyScope, usePageChange, CellEditorType → '@sst-cm/sst-fw-web'
// - useFormDisplayConfig → '@/composables/sstMemorizeConfig'
// - CodeNameType → テンプレートでのみ使う場合は .vue の <script setup> で import。composable で使う場合のみここで import

export const use{機能名Pascal} = () => {
  const t = useI18n()
  const message = useMessage()
  const dialog = useDialog()  // バッチ操作の確認ダイアログに使用

  // ── Hotkey（システム共通: F3=検索, F4=複製, F6=新規, F7=保存, F8=クリア, F9=実行） ──
  // → この画面に存在するボタンに対応するキーをすべて登録する
  const SCREEN_ID = '{featureName}'
  const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID })
  useSstHotkey('f3', search)   // 検索
  useSstHotkey('f8', clear)    // クリア
  useSstHotkey('f9', execute)  // 実行

  // ── フォーム ──
  // ⚠️ ref のジェネリクスで型指定（Ref<T> 型注釈は冗長なので使わない）
  const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()
  const gridRef = ref<InstanceType<any>>()

  // ⚠️ 日付の初期値は today 変数を一度だけ宣言し、各フィールドで再利用する
  // ❌ 禁止: shipSchDateStart: sstUtil().getCurrentDate(), shipSchDateEnd: sstUtil().getCurrentDate()
  // ✅ 正しい: today を宣言 → フォームフィールドで today を参照
  const today = sstUtil().getCurrentDate('YYYYMMDD') as string

  const form: Form = reactive<Form>({
    ownerCd: '',
    warehouseCd: '',
    shipSchDateStart: today,
    shipSchDateEnd: today,
    // ... 他のフィールド
  })

  // ── 多言語変数は computed で囲む（t() を使う変数はすべて） ──
  // ⚠️ tabItems/activeTab はFigmaでタブ分割されている場合のみ宣言する。単一ページ構成なら不要（init.md 規則 #50）
  const tabItems = computed(() => [
    { value: 'condition', label: t('tab.searchCondition') },
    { value: 'result', label: t('tab.searchResult') },
  ])

  // ⚠️ Radio の items も t() を使うなら computed で囲む
  const statusTypeItems = computed(() => [
    { label: t('status.match'), value: '0' },
    { label: t('status.before'), value: '1' },
    { label: t('status.after'), value: '2' },
  ])

  // ── メモライズ ──
  // ⚠️ useFormDisplayConfig() は引数なしで呼ぶ。MEMORIZE_CONFIG を引数に渡すのは禁止
  // ⚠️ 戻り値は { getMemorizeConfig, saveMemorizeConfig } — loadMemorizeConfig は存在しない
  const { getMemorizeConfig, saveMemorizeConfig } = useFormDisplayConfig()
  const MEMORIZE_FIELD_IDS = ['ownerCd', 'warehouseCd']
  // ⚠️ MEMORIZE_CONFIG は必ず以下4フィールドを持つ。{ screenId, items } 形式は禁止
  // ⚠️ gridRefs / formRefs は Record<string, Ref> 形式。配列 [gridRef] は禁止
  const MEMORIZE_CONFIG = {
    screenId: SCREEN_ID,
    gridRefs: { grid: gridRef },
    formRefs: { form: formRef },
    trackedFieldIds: MEMORIZE_FIELD_IDS,
  }

  // ⚠️ doInit() は必ず onMounted 内で呼ぶ（トップレベル即時呼出し禁止）
  // トップレベルで呼ぶと初期化エラーが握りつぶされ、onMounted 前の状態で動作する
  onMounted(async () => {
    await doInit()
    getMemorizeConfig(MEMORIZE_CONFIG)
  })

  // ── Lookup ダイアログ ──
  type LookupType = 'owner' | 'warehouse' | null
  const currentLookupType = ref<LookupType>(null)
  const showLookupDialog = ref(false)
  const currentLookupKey = computed(() => {
    switch (currentLookupType.value) {
      case 'owner':
        return 'OWNER'
      case 'warehouse':
        return 'WAREHOUSE'
      default:
        return ''
    }
  })

  function ownerCdIconclick() {
    currentLookupType.value = 'owner'
    showLookupDialog.value = true
  }
  // ⚠️ onLookupSelected の引数に any を使わない — LookupRow 型を定義する
  type LookupRow = { code?: string; name?: string; [key: string]: unknown }
  function onLookupSelected(row: LookupRow) {
    switch (currentLookupType.value) {
      case 'owner':
        form.ownerCd = sstUtil().toString(row.code)
        form.ownerNm = sstUtil().toString(row.name)
        break
    }
    showLookupDialog.value = false
    currentLookupType.value = null
  }

  const clear = (): void => {
    formRef.value?.resetAll()
  }

  return { formRef, form, clear }
}
```

### 登録画面の composable 骨格

検索画面との違い: `usePageChange`（ダーティチェック）、`useRouter`/`useRoute`、ツリー幅制御、パネル非表示制御。
Hotkeyはシステム共通ルール（F3=検索/F4=複製/F6=新規/F7=保存/F8=クリア/F9=実行）に従い、画面に存在するボタン分を登録する。

```ts
import { reactive, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { CellEditorType, useI18n, useMessage, sstUtil, usePageChange, useSstHotkeyScope } from '@sst-cm/sst-fw-web'
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig'
import type { {RequestType}, {ResponseType} } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}ApiType'
import { {機能名Pascal}Api } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}Api'
import { DropDownApi } from '{dropDownApiDir}/dropDownApi'
// ⚠️ CodeNameType は composable 内で直接使用する場合のみ import する
// テンプレートでのみ使う場合は .vue の <script setup> で import すること

export const use{機能名Pascal} = () => {
  const t = useI18n()
  const message = useMessage()
  const router = useRouter()
  const route = useRoute()

  // ── ダーティチェック ──
  const pageDirty = usePageChange()
  // ⚠️ 使い方:
  // - pageDirty.markClean()           → 保存成功後 / クリア後 / 初期データ読込後
  // - pageDirty.confirmValueChanged() → 新規/コピー/ツリー切替/画面離脱前（false なら操作キャンセル）

  // ── Hotkey（システム共通: F3=検索, F4=複製, F6=新規, F7=保存, F8=クリア, F9=実行） ──
  // → この画面に存在するボタンに対応するキーをすべて登録する
  const SCREEN_ID = '{featureName}'
  const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID })
  useSstHotkey('f4', copyForm)    // 複製
  useSstHotkey('f6', newForm)     // 新規
  useSstHotkey('f7', save)        // 保存
  useSstHotkey('f8', clearForm)   // クリア

  // ── フォーム ──
  // ⚠️ ref のジェネリクスで型指定（Ref<T> 型注釈は冗長なので使わない）
  const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()
  const gridRef = ref<InstanceType<any>>()
  const form = reactive<Form>({ /* 初期値 */ })
  const gridData = ref<RowType[]>([])

  // ── メモライズ ──
  // ⚠️ useFormDisplayConfig() は引数なしで呼ぶ。MEMORIZE_CONFIG を引数に渡すのは禁止
  // ⚠️ 戻り値は { getMemorizeConfig, saveMemorizeConfig } — loadMemorizeConfig は存在しない
  const { getMemorizeConfig, saveMemorizeConfig } = useFormDisplayConfig()
  const MEMORIZE_FIELD_IDS = ['ownerCd', 'warehouseCd'] // 設計書のメモライズ対象項目を指定
  // ⚠️ MEMORIZE_CONFIG は必ず以下4フィールドを持つ。{ screenId, items } 形式は禁止
  // ⚠️ gridRefs / formRefs は Record<string, Ref> 形式。配列 [gridRef] は禁止
  const MEMORIZE_CONFIG = {
    screenId: SCREEN_ID,
    gridRefs: { grid: gridRef },
    formRefs: { form: formRef },
    trackedFieldIds: MEMORIZE_FIELD_IDS,
  }

  // ── ツリー幅制御 ──
  const timeTreeShowFlg = ref(true)
  const treeLength = ref(4)
  const otherColLength = computed(() => (timeTreeShowFlg.value ? 24 - treeLength.value : 24))
  const treeItems = ref<TreeNode[]>([])
  const openedNodes = ref<string[]>([])

  async function onTreeItemSelect(item: any) {
    if (!await pageDirty.confirmValueChanged()) return
    await loadData(item)
    pageDirty.markClean()
  }

  // ── パネル表示/非表示 ──
  // ⚠️ add*/upd* 監査列を持つ機能で systemInfoHidden を使う場合（ユーザーがシステム情報パネル追加を了承済みの場合のみ定義する）。「システム情報パネルの標準構成」参照
  const hidden = reactive<Record<string, boolean>>({
    subInfoHidden: false,
    systemInfoHidden: false,
  })
  const panelHidMenuOpen = ref(false)
  const hiddenPanelKeyList = computed(() =>
    Object.entries(hidden)
      .filter(([, val]) => val)
      .map(([key]) => ({ key, name: t(`panel.${key.replace('Hidden', '')}`) }))
  )
  // ⚠️ 使用しない引数は宣言しない（未使用パラメータは SonarQube 違反）
  function hiddenPanelClick(key: string) {
    hidden[key] = true
  }
  function showPanelHandle(key: string) {
    hidden[key] = false
  }

  // ── モード制御（詳細設計書「処理モード概要」対応） ──
  // ⚠️ pcsMod は '0'=新規登録モード / '1'=編集モード。newForm/copyForm では '0'、loadData 成功後は '1' にする
  const pcsMod = ref<'0' | '1'>('0')
  // ⚠️ 詳細設計書の「初期値設定」表（項目名/初期値/入力可・不可/備考）は
  //    フィールドごとの disabled をこの1つの computed に集約する。
  //    テンプレートには `:disabled="fieldDisabled.warehouseCd"` のように参照させ、
  //    フィールドごとに ref を個別宣言しない（モード追加時の書き漏れを防ぐため）。
  const fieldDisabled = computed(() => ({
    // 詳細設計書「初期値設定」表の 入力可/不可 = 不可 の項目のみ列挙する
    bizType: pcsMod.value === '1',
    ownerCd: pcsMod.value === '1',
    warehouseCd: pcsMod.value === '1',
  }))
  // ⚠️ 詳細設計書の「画面ボタン制御」表（項目名/利用可否/備考）も同様に1つの computed に集約する
  const buttonDisabled = computed(() => ({
    save: false,
    delete: pcsMod.value === '0',
  }))

  // ── 多言語変数は computed で囲む ──
  const tabItems = computed(() => [
    { value: 'condition', label: t('tab.basic') },
    { value: 'result', label: t('tab.detail') },
  ])
  const columnDefs = computed(() => [ /* ... */ ])

  // ── 操作 ──
  async function save() {
    const valid = await formRef.value?.validateAll()
    if (!valid) return
    // ⚠️ save では response を受け取り、新規時は返却された主キーを form に反映する
    // ⚠️ `as unknown as Record<string, unknown>` のようなトリプルキャストは禁止
    //    form フィールドが API 型と一致する場合は `{ ...form } as Web.XxxRequest` で直接キャスト可
    const res = await {機能名Pascal}Api.save({
      header: { ...form } as Web.{SaveHeaderRequest},
      detail: gridData.value as unknown as Web.{SaveDetailRequest}[],
    })
    // 新規モードの場合、レスポンスの主キーを反映
    if (pcsMod.value === '0' && res?.soNo) {
      form.soNo = res.soNo
      addTreeItem(form.soNo)
      pcsMod.value = '1'
    }
    pageDirty.markClean()
    message.info(t('information.codes.I00001'))
    saveMemorizeConfig(MEMORIZE_CONFIG)
  }

  // ── データ読込（loadData / loadSoData） ──
  // ⚠️ フィールド数が20個を超える場合、1行ずつ代入するのは禁止（SonarQube: Cognitive Complexity 超過）
  // → フィールドマッピング配列 + ループで圧縮する
  async function loadData(soNo: string) {
    const res = await {機能名Pascal}Api.getSoInfo({ soNo })
    const header = res?.soHeader
    if (!header) return

    // 文字列フィールド一括マッピング（同じ変換ロジックのフィールドをまとめる）
    const stringFields = [
      'ownerCd', 'ownerName', 'warehouseCd', 'warehouseName',
      'shipToCd', 'shipToName', 'transportCd', 'transportName',
      // ... 設計書のフィールドを列挙
    ] as const
    stringFields.forEach((f) => {
      ;(form as Record<string, unknown>)[f] = sstUtil().toString(header[f as keyof typeof header])
    })

    // 型変換が異なるフィールドは個別に書く
    form.soQty = header.soQty != null ? Number(header.soQty) : null
    form.shipSchDate = sstUtil().toString(header.shipSchDate)

    // 明細グリッド
    gridData.value = (res.soDetail ?? []) as unknown as RowType[]
    pageDirty.markClean()
  }

  async function clearForm() {
    if (!await pageDirty.confirmValueChanged()) return
    formRef.value?.resetAll()
    gridData.value = []
    pageDirty.markClean()
  }

  async function newForm() {
    if (!await pageDirty.confirmValueChanged()) return
    formRef.value?.resetAll()
    gridData.value = []
    pageDirty.markClean()
  }

  // ── ライフサイクル ──
  // ⚠️ doInit() は必ず onMounted 内で呼ぶ（トップレベル即時呼出し禁止）
  onMounted(async () => {
    await doInit()
    getMemorizeConfig(MEMORIZE_CONFIG)
  })

  return {
    formRef, form, gridData, gridRef, columnDefs,
    tabItems, activeTab,
    treeItems, timeTreeShowFlg, treeLength, otherColLength, openedNodes,
    hidden, hiddenPanelKeyList, panelHidMenuOpen,
    pcsMod, fieldDisabled, buttonDisabled,
    showLookupDialog, currentLookupType, currentLookupKey,
    save, clearForm, newForm, onTreeItemSelect, onDetailGridReady,
    ownerCdIconclick, handleFetchOwnerCd, onLookupSelected,
    hiddenPanelClick, showPanelHandle,
  }
}
```

## コンポーネント対応表

> **詳細仕様（プロパティ・スロット・イベント・使用例）が必要な場合は `../../vue-guide/references/fw-components.md` を参照。**

### コンポーネント命名規則

> テンプレート内は必ず **PascalCase**（`<SstTextField>`）。kebab-case（`<sst-text-field>`）は禁止。

### 単票項目（フォーム）

| 設計書コンポーネント | Vueコンポーネント    | 型               | 備考                                                                                            |
| -------------------- | -------------------- | ---------------- | ----------------------------------------------------------------------------------------------- |
| SstTextField         | `<SstTextField>`     | `string`         | `v-model`, `id`, `:label`                                                                       |
| SstTexField          | `<SstTextField>`     | `string`         | 設計書上のタイポ。SstTextFieldと同じ                                                            |
| SstNumberInput       | `<SstNumberInput>`   | `number \| null` | `v-model`, `id`, `:label`, `:maxlength`                                                         |
| SstDateInput         | `<SstDateInput>`     | `string`         | `v-model`, `id`, `:label`                                                                       |
| SstDateTimeInput     | `<SstDateTimeInput>` | `string`         | `v-model`, `id`, `:label`。日時入力                                                             |
| SstTimePicker        | `<SstTimePicker>`    | `string`         | `v-model`, `:label`。時間入力（HH:mm）                                                          |
| SstSelect            | `<SstSelect>`        | `string`         | `v-model`, `:items`, `:label`                                                                   |
| SstRadio             | `<SstRadio>`         | `string`         | `v-model`, `:items`, `:label`                                                                   |
| SstCheckbox          | `<SstCheckbox>`      | `string`         | `v-model`, `:items`                                                                             |
| SstCodeName          | `<SstCodeName>`      | `string`         | `v-model`(コード), `v-model:name`(名称), **`:code-type`(必須)**, `:iconclick`, `@retrieve-data` |
| SstAvatar            | `<SstAvatar>`        | -                | 表示専用                                                                                        |
| SstButton            | `<SstButton>`        | -                | `@click`, `text`, `variant`, `prepend-icon`                                                     |

### SstCodeName

> **⚠️ `@retrieve-data` は `v-model:name` を使う場合、省略禁止（init.md 規則 #54）。** `:iconclick` は設計書の `ルックアップ: ✔` の有無で要否が変わる（規則 #22）が、`@retrieve-data` はコード入力時の自動名称取得のために常に必要。

```html
<SstCodeName
  id="ownerCd"
  v-model="form.ownerCd"
  v-model:name="form.ownerName"
  :code-type="CodeNameType.OWNER"
  :iconclick="ownerCdIconclick"
  :label="t('label.ownerCode')"
  :maxlength="20"
  required
  @retrieve-data="handleFetchOwnerCd"
/>
```

```ts
import { CodeNameType } from '@/constants/codeNameType';
// ⚠️ sstUtil を優先使用（init.md 注意事項）。String() で直接キャストしない
const handleFetchOwnerCd = (data?: CodeNameResponse): void => {
  form.ownerName = data?.data?.name != null ? sstUtil().toString(data.data.name) : '';
};
```

### レイアウトコンポーネント

| 設計書コンポーネント | Vueコンポーネント | 説明                                                                       |
| -------------------- | ----------------- | -------------------------------------------------------------------------- |
| SstPanel             | `<SstPanel>`      | `variant="accordion"`, `elevation="3"`, `:title`, `v-model`(boolean), `id` |
| SstTabs              | `<SstTabs>`       | `v-model`(activeTab), `v-model:tabs`(tabItems), `:closable="false"`        |
| SstTreeview          | `<SstTreeview>`   | `filterable` prop でフィルタ表示（自前で作らない）                         |

> ⚠️ `tabItems` は必ず `computed(() => [...])` で宣言すること。`ref([...])` や plain 配列は禁止（言語切替えに反応しない）。

### SstTreeview のフィルタ

> `filterable` prop を `true` にするだけ。**自前で TextField + computed フィルタを書かない。**

```html
<SstTreeview
  id="soNoTreeView"
  v-model="form.soNoTreeView"
  v-model:opened="openedNodes"
  :allow-deselect="false"
  :filter-label="t('label.shipScheduleNo')"
  :filter-length="20"
  filterable
  item-label="label"
  item-value="id"
  :items="treeItems"
  select-strategy="single-leaf"
  @item-select="onTreeItemSelect"
/>
```

### items のフィールド名（全コンポーネント共通）

> すべての `Sst*` コンポーネントの `:items` デフォルトフィールド名は **`value`** と **`label`**。
> DropDownAPI レスポンスも同じ形式なので `item-title` / `item-value` の指定は不要。

```html
<!-- デフォルト value/label → 指定不要 -->
<SstSelect v-model="form.field" :items="items" />
<SstRadio v-model="form.field" :items="items" />
<SstTabs v-model="activeTab" v-model:tabs="items" />

<!-- データが { value, name } の場合のみ指定 -->
<SstSelect v-model="form.field" :items="items" item-title="name" />
```

> ⚠️ `{ value, label }` に `item-title="label"` を書くのは冗長（禁止）。
