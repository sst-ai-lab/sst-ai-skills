# Vue screen (`.vue`) rules

Applies to: `**/*.vue`

Screens live under `src/views/<中分類>/<小分類>/<seq>_<feature>/<Feature>.vue` and become routes (file-based, `unplugin-vue-router`). Match the numbered classification folders.

## Component & script style

- Always `<script setup lang="ts">` with the **Composition API**. No Options API, no plain JS.
- Build the UI from the in-house **`Sst*` components** (`SstForm`, `SstRow`, `SstCol`, `SstTextField`, `SstButton`, `SstGrid`, `SstRichText`, …) from `@sst-cm/sst-fw-web` — they are **auto-registered** (see the component catalog [`fw-components.md`](fw-components.md)). Vuetify components are also available.
- **PascalCase 必須**: テンプレート内のすべての Sst コンポーネントは PascalCase で書く（`<SstTextField>`）。kebab-case（`<sst-text-field>`）は禁止。
- **import ルール**: composable (`.ts`) 内では使用するすべてのシンボルに明示的 `import` を書く。同じパッケージからの import は1行にまとめる。詳細は `screen-scaffold` skill（`../../screen-scaffold/SKILL.md`）の import ルールを参照。

## Keep the screen thin (co-located composable)

- Put feature logic in the co-located **`use<Feature>.ts`** composable and types in **`<feature>.types.ts`**; the `.vue` wires template ↔ composable (refs, handlers) and stays presentational.
- Shared cross-screen state goes in a **Pinia store** (`src/stores`), not in the component.

## i18n — never hardcode text

- All labels/messages come from i18n — use the project's `useI18n` composable (from `@sst-cm/sst-fw-web`). **Do not hardcode display strings.**
- **After generating code, read `src/locales/ja.ts` and verify every `t()` key used in the generated code exists.** If a key is missing, add it to **all four** locale files `src/locales/{ja,en,es,zh}.ts`. Skipping this step causes raw key names to display on screen.

## Form controls — tab order

- All form input components (`SstTextField`, `SstCodeName`, `SstDateInput`, `SstSelect`, `SstRadio`, `SstNumberInput`, …) **must** have a `:tab` attribute specifying the focus order when the user presses Tab. Number sequentially from `1`.

```html
<SstCodeName id="ownerCd" v-model="form.ownerCd" :tab="1" ... />
<SstCodeName id="warehouseCd" v-model="form.warehouseCd" :tab="2" ... />
<SstDateInput v-model="form.startDate" :tab="3" ... />
```

## Hotkeys (keyboard shortcuts)

- Every screen should register hotkeys using `useSstHotkeyScope` from `@sst-cm/sst-fw-web`.
- Import `useSstHotkeyScope` explicitly from `@sst-cm/sst-fw-web`.
- Standard hotkey assignments (use those that apply to the screen):

| Key | Action | Typical usage |
|-----|--------|---------------|
| `f3` | 検索 (Search) | Search screens |
| `f4` | 複製 (Copy) | Maintenance screens |
| `f6` | 新規 (New) | Maintenance screens |
| `f7` | 保存 (Save) | Maintenance / Create screens |
| `f8` | クリア (Clear) | Search / Maintenance screens |
| `f9` | 実行 (Execute) | Batch operation screens |

```ts
import { useSstHotkeyScope } from '@sst-cm/sst-fw-web';

const SCREEN_ID = '<featureName>';
const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID });
useSstHotkey('f3', search);
useSstHotkey('f8', clear);
```

## Memorize (メモライズ) — persisting user input

- When the design document marks a field with `メモライズ: ✔`, use `useFormDisplayConfig` (from `@/composables/sstMemorizeConfig`) to save / restore the user's last-entered values.
- Define a `MEMORIZE_CONFIG` with `screenId`, `gridRefs`, `formRefs`, and `trackedFieldIds` (the field IDs that should be memorized).
- Call `getMemorizeConfig` on `onMounted` (restore) and `saveMemorizeConfig` after a successful search or save (persist).

```ts
const SCREEN_ID = '<featureName>';
const MEMORIZE_FIELD_IDS = ['ownerCd', 'warehouseCd']; // メモライズ対象

const { getMemorizeConfig, saveMemorizeConfig } = useFormDisplayConfig();

const MEMORIZE_CONFIG = {
  screenId: SCREEN_ID,
  gridRefs: { grid: gridRef },
  formRefs: { form: formRef },
  trackedFieldIds: MEMORIZE_FIELD_IDS,
};

// restore on mount
onMounted(() => {
  getMemorizeConfig(MEMORIZE_CONFIG);
});

// persist after search
async function search() {
  const valid = await formRef.value?.validateAll();
  if (!valid) return;
  await getData();
  saveMemorizeConfig(MEMORIZE_CONFIG);
}
```

## Lookup dialog (SstCodeName + SstDialog + CommonLookup)

- When the design document specifies `ルックアップ: ✔` on a `SstCodeName` field, wire up **both**:
  1. `@retrieve-data` — auto-fill the name when a code is typed and blurred.
  2. `:iconclick` — open a `SstDialog` containing the `CommonLookup` component for manual selection.

```html
<!-- Template -->
<SstCodeName
  id="ownerCd"
  v-model="form.ownerCd"
  v-model:name="form.ownerNm"
  :code-type="CodeType.OWNER"
  :iconclick="ownerCdIconclick"
  :label="t('label.ownerCode')"
  required
  :tab="1"
  @retrieve-data="handleFetchOwnerCd"
/>

<SstDialog v-model="showLookupDialog" width="900">
  <CommonLookup
    v-if="currentLookupType"
    :lookup-key="currentLookupKey"
    @row-select="onLookupSelected"
  />
</SstDialog>
```

```ts
// Script
import CommonLookup from '{commonLookupImportPath}';

type LookupType = 'owner' | 'warehouse' | null;
const currentLookupType = ref<LookupType>(null);
const showLookupDialog = ref(false);

function ownerCdIconclick() {
  currentLookupType.value = 'owner';
  showLookupDialog.value = true;
}

function onLookupSelected(row: CommonLookupResultRow) {
  switch (currentLookupType.value) {
    case 'owner':
      form.ownerCd = sstUtil().toString(row.ownerCd);
      form.ownerNm = sstUtil().toString(row.ownerName);
      break;
  }
  showLookupDialog.value = false;
  currentLookupType.value = null;
}
```

## Data & feedback

- **API calls go through the feature's `@/api/.../<feature>Api` module** — never call `@sst-cm/fe-web-client` or `axios` directly from a screen. See [`api-client.md`](api-client.md).
- User feedback via `useMessage()` / `useDialog()` / `useNotification()` (from `@sst-cm/sst-fw-web`) — not `window.alert`/`confirm`.
- Sanitize any HTML with `dompurify` before rendering; prefer `sstUtil` helpers over ad-hoc utilities.
- Don't generate tests.
