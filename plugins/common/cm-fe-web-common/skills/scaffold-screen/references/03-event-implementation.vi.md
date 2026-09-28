# Mẫu triển khai event

Tập hợp các mẫu triển khai từ mục "Định nghĩa event" của tài liệu thiết kế.

## Mapping triển khai từ 詳細設計書 (tài liệu thiết kế chi tiết) (bắt buộc đọc, ưu tiên cao nhất)

Việc triển khai từng event phải chuyển nguyên văn nội dung ghi trong 詳細設計書 thành cấu trúc code theo các đối chiếu dưới đây.
Cấm tự diễn giải theo ý mình, đảo thứ tự, hoặc thêm xử lý không có trong tài liệu.

| Nội dung ghi trong 詳細設計書                                        | Triển khai                                                                                                                                                       |
| -------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `### {イベント定義名}`                                               | Một hàm tương ứng trong composable (`search`/`save`/`clear`/`onXxxClick` v.v.)                                                                                    |
| Các bước có số thứ tự của `#### 処理概要`                            | Triển khai xử lý trong hàm đúng theo thứ tự các bước (cấm bỏ bớt, cấm đảo thứ tự)                                                                                 |
| `共通処理（FW）の場合はイベント定義の記載不要`                       | Không tự triển khai riêng, phó thác cho hành vi của component chuẩn FW (có trường hợp không cần tạo hàm)                                                          |
| Nhánh in đậm `**新規モード場合**` / `**編集モード場合**`             | Phân nhánh `if`/`switch` bằng biến mode như `pcsMod.value === '0'` (tạo mới) / `'1'` (chỉnh sửa). Xử lý của từng nhánh triển khai nguyên văn theo gạch đầu dòng tương ứng trong 詳細設計書 |
| Bảng `入力パラメータマッピング`                                      | Xác định nguồn giá trị của từng field trong object request. Mẫu code tương ứng xem `references/04-api-definition.md`                                              |
| Bảng thiết lập giá trị khởi tạo của `##### 処理モード概要`           | Khi chuyển mode (tạo mới/copy/chỉnh sửa) thì set giá trị khởi tạo cho `form`, và các mục có `入力可/不可` là "không cho nhập" thì đặt `disabled`/`readonly`         |
| Bảng `画面ボタン制御`                                                | Điều khiển `:disabled` (hoặc `v-show`) của button tương ứng theo mode/trạng thái                                                                                  |
| Nội dung có marker `🔴【要詳細設計】` / `🟠【要基本設計書修正】`     | Không triển khai theo suy đoán, dừng phần đó lại và hỏi người dùng (quy tắc #49 của `init.md`)                                                                    |

## Điều kiện bổ sung (mẫu component động)

Nếu tài liệu thiết kế có mục "điều kiện bổ sung", thì chọn điều kiện từ dropdown → thêm mục form một cách động → hiển thị bằng thẻ Chip.

> **⚠️ Lựa chọn của điều kiện bổ sung:**
> Nếu tài liệu thiết kế ghi "lấy từ DB", "code category key: SOADDCONDITION" thì lấy bằng `DropDownApi`. Không hardcode.

```ts
// Lấy các lựa chọn của điều kiện bổ sung từ DB
const addConditionOptions = ref<DropdownResponse['data']>([]);
getDropdownItems('SOADDCONDITION', '', '*', '*').then((res) => {
  addConditionOptions.value = res.data || [];
});
```

```ts
// Định nghĩa kiểu
type AddConditionKey = 'itemCd' | 'itemName' | 'soType' | 'ownerSoKbn' | 'delivSchDateStart' | 'delivSchDateEnd';

type AddConditionItem = {
  value: AddConditionKey;
  label: string; // ← Nhãn hiển thị lấy từ DB (không phải key i18n)
  component: string;
  componentProps: Record<string, unknown>;
};

// Mapping component (không bao gồm label — lấy từ DB)
const addConditionComponentMap: Record<
  AddConditionKey,
  { component: string; componentProps: Record<string, unknown> }
> = {
  itemCd: { component: 'SstTextField', componentProps: {} },
  soType: { component: 'SstSelect', componentProps: { items: soTypeItems } },
  // ... tương ứng với từng key điều kiện
};

const addCondition = ref<AddConditionKey | ''>('');
const conditionItems = ref<AddConditionItem[]>([]);

// Chỉ hiển thị những điều kiện chưa được thêm
const actualAddConditionOptions = computed(() => {
  const addedValues = new Set(conditionItems.value.map((item) => item.value));
  return addConditionOptions.value?.filter((option) => !addedValues.has(option.value as AddConditionKey));
});

// Thêm điều kiện
function onAddConditionChange(oldVal: AddConditionKey | '', newVal: AddConditionKey | '') {
  if (!newVal) return;
  const componentDef = addConditionComponentMap[newVal];
  if (!componentDef) return;
  const dbOption = addConditionOptions.value?.find((opt) => opt.value === newVal);
  conditionItems.value.push({
    value: newVal,
    label: dbOption?.label ?? newVal, // Dùng nguyên label của DB
    ...componentDef,
  });
  addCondition.value = '';
}

// Đóng Chip
// ⚠️ Nếu dùng `t` làm tham số callback sẽ shadow `t` của i18n → dùng tên khác như `el`
function conditionTabClose(item: AddConditionKey) {
  const index = conditionItems.value.findIndex((el) => el.value === item);
  if (index !== -1) conditionItems.value.splice(index, 1);
  form[item] = '';
}
```

> **⚠️ Cấm hardcode label.** Dùng nguyên `label` của `addConditionOptions` lấy từ DB.
> Ở template cũng truyền trực tiếp `item.label` chứ không phải `t(item.label)`.

Phía template:

```html
<!-- ⚠️ Dùng @change (không phải @update:model-value). @change có 2 tham số (oldVal, newVal). -->
<SstSelect
  v-model="addCondition"
  :items="actualAddConditionOptions"
  :label="t('label.addCondition')"
  @change="onAddConditionChange"
/>

<!-- Form điều kiện được thêm động -->
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

<!-- Danh sách thẻ Chip -->
<SstChip
  v-for="item in conditionItems"
  :key="item.value"
  closable
  :model-value="item.label"
  @close="conditionTabClose(item.value)"
/>
```

## Điều khiển bật/tắt button thao tác (onSelectionChanged)

Bản thân mẫu triển khai `onSelectionChanged` xem "Mẫu triển khai onSelectionChanged" trong `references/02-grid-definition.md` (không định nghĩa trùng lặp). Ở đây chỉ nêu ví dụ template phản ánh `confirmDisabled`/`deleteDisabled` đó lên button.

Template:

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

> ⚠️ Màu button: thao tác thuận (xác định, phân bổ) = `#AFF4C6` (xanh), thao tác nghịch (hủy, xóa) = `#FCB3AD` (đỏ). Quy ước giống mục lưu ý của init.md.

## Clear

> ⚠️ `setMemorize` là hàm helper lưu memorize. Định nghĩa như sau:
>
> ```ts
> function setMemorize() {
>   saveMemorizeConfig(MEMORIZE_CONFIG);
> }
> ```
>
> `saveMemorizeConfig` lấy từ `useFormDisplayConfig()`, còn `MEMORIZE_CONFIG` tham chiếu hằng số đã định nghĩa ở đầu composable.

```ts
const clear = (): void => {
  // Nếu có điều kiện bổ sung thì clear
  conditionItems.value = [];
  addCondition.value = '';
  // Khởi tạo lại dữ liệu Grid + phân trang
  gridData.value = [];
  paginationSettings.page = 1;
  paginationSettings.total = 0;
  // Reset Form
  formRef.value?.resetAll();
  // Lấy lại dropdown (làm mới các lựa chọn đã lấy ở init)
  doInit();
  // Memorize
  setMemorize();
};
```

> ⚠️ Hàm `clear` của màn hình tìm kiếm phải reset không chỉ Form mà cả **dữ liệu Grid, phân trang và điều kiện bổ sung**.

## Tìm kiếm

```ts
async function search(): Promise<void> {
  const valid = await formRef.value?.validateAll();
  if (!valid) return;
  paginationSettings.page = 1;
  activeTab.value = 'result'; // ⚠️ Chỉ áp dụng khi có cấu trúc tab (khi Figma chia tab). Nếu là cấu trúc một trang đơn thì không cần dòng này (quy tắc #50 của init.md)
  await getData();
  saveMemorizeConfig(MEMORIZE_CONFIG);
}
```

## Lưu (đăng ký, cập nhật)

```ts
const save = async (): Promise<void> => {
  const valid = await formRef.value?.validateAll()
  if (!valid) return

  // ⚠️ Quy tắc cast:
  // - Nếu tên field của form khớp với kiểu API → có thể cast trực tiếp bằng `{ ...form } as Web.XxxRequest`
  // - Nếu tên field khác nhau → tự tạo object một cách tường minh
  // - ❌ Cấm: `{ ...form } as unknown as Record<string, unknown>` (triple cast bỏ qua type safety)
  // - Chỉ cho phép `as unknown as` khi chuyển đổi kiểu phần tử của mảng
  const res = await {機能名Pascal}Api.save({
    so: { ...form } as Web.{SoMainteSaveSoHeader},
    soDetail: gridData.value as unknown as Web.{SoMainteSaveSoDetail}[],
  })

  // ⚠️ Khi tạo mới thì phản ánh khóa chính của response vào form (cấm bỏ qua response)
  if (pcsMod.value === '0' && res?.soNo) {
    form.soNo = res.soNo
    addTreeItem(form.soNo)
    pcsMod.value = '1'
  }
  pageDirty.markClean()
  message.info(t('information.codes.I00001'))
}
```

## Xóa

```ts
const deleteData = async (): Promise<void> => {
  await {機能名Pascal}Api.delete({
    companyCd: '',   // Lấy từ store nếu cần
    {idField}: {idValue},
  })
}
```

## Thao tác theo lô (xác định, phân bổ, thêm thực tế, xóa v.v.)

Khi chọn nhiều dòng ở màn hình tìm kiếm để xử lý theo lô, **cấm viết riêng từng hàm có logic trùng lặp** (đối tượng bị SonarQube phát hiện trùng code).
Hãy định nghĩa helper `batchAction` dùng chung, và mỗi thao tác chỉ gọi nó.

> **⚠️ Cách dùng đúng của `useDialog`/`useMessage` xem quy tắc #43/#44 của `init.md`** (`dialog.confirm()` nhận tham số dạng object, không tồn tại `message.showXxx` v.v.). Dưới đây là ví dụ sử dụng thực tế trong `batchAction`.

```ts
const dialog = useDialog();
const message = useMessage();

// ── Helper thao tác theo lô dùng chung ──
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

// ── Mỗi thao tác chỉ gọi helper ──
const confirm = () => batchAction(SoSearchApi.batchConfirm, 'message.confirmConfirm');
const allocate = () => batchAction(SoSearchApi.batchAllocate, 'message.confirmAllocate');
const actualAdd = () => batchAction(SoSearchApi.batchActualAdd, 'message.confirmActualAdd');
const deleteData = () => batchAction(SoSearchApi.batchDelete, 'message.confirmDelete');
```

> **Quy tắc:** Nếu từ 3 hàm trở lên lặp lại cùng một mẫu (xác nhận dialog → tạo danh sách → gọi API → thông báo → tìm kiếm lại) thì **bắt buộc dùng chung** (quy tắc #46 của init.md). Cách dùng `dialog`/`message` xem quy tắc #43/#44 của init.md đã nêu ở trên.

## Response API → gán vào dữ liệu grid

```ts
// Nếu kiểu khác nhau thì cast bằng as unknown as
gridData.value = (response.soDetail ?? []) as unknown as { RowType }[];
```
