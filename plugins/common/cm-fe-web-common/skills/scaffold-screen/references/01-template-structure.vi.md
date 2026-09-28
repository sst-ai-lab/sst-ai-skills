# Cấu trúc template

Template chuẩn cho màn hình tìm kiếm / màn hình đăng ký và bộ khung composable.

## Template chuẩn của màn hình tìm kiếm

> **⚠️ Cấu trúc layout (chia tab hay trang đơn) bắt buộc phải ưu tiên layout thực tế trên Figma.**
> Cấu hình `SstTabs` (tab điều kiện + tab kết quả) dưới đây chỉ là ví dụ chuẩn cho trường hợp Figma tách
> điều kiện tìm kiếm và kết quả tìm kiếm thành hai tab riêng biệt. Nếu trên Figma điều kiện tìm kiếm và
> kết quả tìm kiếm được xếp dọc trong cùng một trang (không có chuyển tab), thì không dùng `SstTabs`/`#condition`/`#result`,
> mà đặt trực tiếp trong trang theo thứ tự từ trên xuống: block điều kiện (`SstForm`) → block kết quả (grid).
> Các quy ước style như vị trí button, phân nhóm bằng `SstCard`, tỷ lệ cột... vẫn được áp dụng y như vậy, bất kể có tab hay không.

Màn hình tìm kiếm sử dụng `SstTabs` (tab điều kiện + tab kết quả) khi được chia tab trên Figma.

- **Đặt `SstForm` bên trong slot `#condition`** (không đặt ra ngoài SstTabs)
- Các button trong tab điều kiện (tìm kiếm, xóa) đặt ở **hàng đầu tiên của form**, bọc bằng `div.button-group.button-group--floating`
- Các mục của form điều kiện được phân nhóm bằng `SstCard` + `SstCardTitle` + `SstCardText` (không dùng `SstPanel`)
- Chia `SstCol` trái/phải theo tỷ lệ trên Figma (ví dụ: điều kiện cơ bản `:cols="14"`, điều kiện bổ sung `:cols="10"`)

```html
<template>
  <SstTabs v-model="activeTab" v-model:tabs="tabItems" :closable="false">
    <template #condition>
      <SstForm id="form" ref="formRef">
        <!-- ① Hàng button (đặt ở đầu) -->
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
        <!-- ② Các mục của form (phân khu bằng SstCard) -->
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
                    <!-- Mục B -->
                  </SstCol>
                </SstRow>
              </SstCardText>
            </SstCard>
          </SstCol>
          <SstCol :cols="10">
            <SstCard variant="outlined">
              <SstCardTitle>{{ t('panel.additionalCondition') }}</SstCardTitle>
              <SstCardText>
                <!-- Điều kiện bổ sung -->
              </SstCardText>
            </SstCard>
          </SstCol>
        </SstRow>
      </SstForm>
    </template>
    <template #result>
      <!-- Tab kết quả: button thao tác + grid -->
    </template>
  </SstTabs>
  <!-- Dialog Lookup (đặt ngoài SstTabs) -->
  <SstDialog v-model="showLookupDialog" width="900">
    <CommonLookup v-if="currentLookupType" :lookup-key="currentLookupKey" @row-select="onLookupSelected" />
  </SstDialog>
</template>

<script setup lang="ts">
  import { use{機能名Pascal} } from './use{機能名Pascal}'
  import { useI18n } from '@sst-cm/sst-fw-web'
  import CommonLookup from '{commonLookupImportPath}'
  // ⚠️ Nếu dùng CodeNameType trong template theo kiểu :code-type="CodeNameType.OWNER" thì import tại đây
  import { CodeNameType } from '@/constants/codeNameType'

  const t = useI18n()

  // ⚠️ Chỉ destructure những giá trị thực sự dùng trong template (destructure mà không dùng sẽ vi phạm dead code của SonarQube)
  const {
    formRef,
    form,
    clear,
    // ... các giá trị composable trả về (chỉ những gì dùng trong template)
  } = use{機能名Pascal}()
</script>
```

## Template chuẩn của màn hình đăng ký・bảo trì

Màn hình đăng ký (màn hình bảo trì) có cấu trúc khác với màn hình tìm kiếm.

- **Cột trái: SstTreeview** (tree của số xuất hàng v.v.) + **cột phải: SstTabs** (form nhập liệu + grid chi tiết)
- **⚠️ Vị trí button không phải là cố định ở đáy màn hình**: đặt nổi ở bên ngoài `SstTabs`, gần góc trên phải của trang bằng utility class `position-fixed` + style inline (ví dụ: `style="top:110px;right:30px"`) (xem ví dụ template bên dưới). **Bắt buộc kiểm tra vị trí button thực tế trên Figma và điều chỉnh giá trị offset trên/dưới (`top`) theo layout của Figma** (không cố định tất cả ở đáy màn hình). Điểm này, giống như cấu trúc layout, ưu tiên hình thức thực tế trên Figma hơn template (cùng cách nghĩ với quy tắc #50 của `references/init.md`)
- Phân chia section bằng **SstPanel**, bọc thông tin header bằng `SstCard`
- Panel được **xếp 2 cột ngang** (`SstCol :cols="12"` × 2) — bên trái luôn hiển thị, bên phải có thể ẩn (`:hidden` + `@append-icon-click`)
- **⚠️ Xác nhận với người dùng về việc có cần panel thông tin hệ thống hay không**: nếu các mục audit như ngày giờ đăng ký・người đăng ký・thiết bị đăng ký・ngày giờ cập nhật・người cập nhật・thiết bị cập nhật・cờ hiệu lực (các cột `add*`/`upd*`) có trong 項目定義 (định nghĩa mục) nhưng trong mockup màn hình của 基本設計書 (tài liệu thiết kế cơ bản) lại không thấy panel tương ứng với `t('panel.systemInfo')`, thì không tự ý quyết định thêm/bỏ, mà phải xác nhận với người dùng về việc có cần thêm hay không trước khi implement (`init.md` quy tắc #53). Nếu người dùng đồng ý thêm, hãy implement nó như một trong các panel có thể ẩn ở bên phải. Nếu trong mockup màn hình đã vẽ panel thông tin hệ thống thì không cần xác nhận, cứ implement như vậy. Về cấu trúc field chuẩn, xem ví dụ template này và mục "Cấu trúc chuẩn của panel thông tin hệ thống"
- Thực hiện dirty check (cảnh báo chưa lưu khi rời trang) bằng `usePageChange()`

```html
<template>
  <div>
    <SstRow>
      <!-- Cột trái: tree (có chuyển đổi hiện/ẩn) -->
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
      <!-- Cột phải: tab (condition = form nhập liệu, result = grid chi tiết) -->
      <SstCol :cols="otherColLength">
        <SstTabs v-model="activeTab" v-model:tabs="tabItems" :closable="false">
          <template #condition>
            <SstForm id="form" ref="formRef">
              <!-- ⚠️ Hàng trống cho button (button thực tế đặt bên ngoài SstTabs bằng position-fixed) — cấm lược bỏ SstRow trống này -->
              <SstRow class="button-toolbar-row">
                <SstCol :cols="24"> </SstCol>
              </SstRow>
              <SstRow>
                <SstCol :cols="24">
                  <!-- Card thông tin header -->
                  <SstCard :title="`*${t('tab.basic')}`" variant="outlined">
                    <template #append>
                      <!-- Menu hiện/ẩn panel -->
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
                      <!-- Trạng thái + các mục cơ bản -->
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
                      <!-- Panel (2 cột ngang: trái = luôn hiển thị / phải = có thể ẩn) -->
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
                            <!-- Nội dung của panel có thể ẩn (riêng theo từng chức năng. Chi tiết theo tài liệu thiết kế) -->
                          </SstPanel>
                        </SstCol>
                        <!-- ⚠️ Panel thông tin hệ thống: nếu có cột audit add*/upd* mà mockup không có thì xác nhận với người dùng về việc có cần thêm hay không (chi tiết xem mục "Cấu trúc chuẩn của panel thông tin hệ thống") -->
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
            <!-- ⚠️ Hàng trống cho button (button thực tế đặt bên ngoài SstTabs bằng position-fixed) — cấm lược bỏ SstRow trống này -->
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
    <!-- Hàng button (⚠️ không cố định ở đáy màn hình, mà đặt nổi gần góc trên phải. Giá trị top điều chỉnh theo vị trí thực tế trên Figma) -->
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

  <!-- Dialog Lookup -->
  <SstDialog v-model="showLookupDialog" width="900">
    <CommonLookup v-if="currentLookupType" :lookup-key="currentLookupKey" @row-select="onLookupSelected" />
  </SstDialog>
</template>
```

### script setup của màn hình đăng ký

```ts
<script setup lang="ts">
import { use{機能名Pascal} } from './use{機能名Pascal}'
import CommonLookup from '{commonLookupImportPath}'
// ⚠️ Nếu dùng CodeNameType trong template thì import tại đây (không phải trong composable)
import { CodeNameType } from '@/constants/codeNameType'

const t = useI18n()

// ⚠️ Chỉ destructure những giá trị thực sự dùng trong template
// Những giá trị chỉ dùng bên trong composable (như statusItems được tham chiếu trong columnDefs) thì không destructure ở đây
// Biến destructure không được dùng sẽ vi phạm dead code của SonarQube
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

> **Về CSS của button**: hàng button trong ví dụ template trên chỉ xác định vị trí bằng `position-fixed` (utility class do framework cung cấp) + `style="top:...;right:..."` inline. **Không tạo** CSS tự viết để cố định ở đáy màn hình như `.button-group--fixed` (`position:fixed; bottom:0`) (đó là pattern cũ và rất có khả năng không khớp với vị trí button thực tế trên Figma)

> **Các điểm khác biệt chính so với màn hình tìm kiếm:**
>
> - Button được đặt nổi ở vị trí bất kỳ trên trang bằng utility class `position-fixed` + style inline (khớp với Figma. Ví dụ trên là góc trên phải). Màn hình tìm kiếm dùng `button-group--floating` (hàng đầu của form, luồng thông thường)
> - Phân chia section bằng `SstPanel` (màn hình tìm kiếm dùng `SstCard` + `SstCardTitle`)
> - Chức năng ẩn panel: pattern `:hidden` + `append-icon="mdi-close"` + `@append-icon-click` + `SstMenu` + `SstChip`
> - Đặt tree (`SstTreeview filterable`) ở cột trái
> - Grid hiển thị toolbar bằng `pagination-mode="client"` + `toolbar-config` (thêm dòng, copy, xóa v.v.)
> - Dirty check bằng `usePageChange()`
> - **Panel thông tin hệ thống (`panel.systemInfo`)** (khi có các cột audit `add*`/`upd*`. Pattern không có ở màn hình tìm kiếm). Nếu không có trong mockup màn hình thì không tự quyết định mà hỏi người dùng (`init.md` quy tắc #53)

## Bộ khung composable (use{機能名Pascal}.ts)

> **⚠️ composable bắt buộc phải bao gồm các chức năng sau:**
>
> - **Thuộc tính `:tab`**: chỉ định thứ tự tab bằng `:tab="N"` cho tất cả các component nhập liệu của form (số liên tiếp từ 1)
> - **Hotkey**: đăng ký phím tắt bằng `useSstHotkeyScope`. Quy tắc chung của hệ thống:
>   - **F3=tìm kiếm / F4=nhân bản / F6=tạo mới / F7=lưu / F8=xóa / F9=thực thi**
>   - Đăng ký tất cả các phím tương ứng với những button tồn tại trên màn hình đó (không phân biệt theo loại màn hình)
> - **Memorize**: nếu tài liệu thiết kế có `メモライズ: ✔` (memorize) thì lưu và phục hồi giá trị nhập liệu lần trước bằng `useFormDisplayConfig`
> - **Dialog Lookup**: thêm xử lý mở dialog cho `SstCodeName` bằng `:iconclick`. **Cấm để `// TODO` hoặc implement rỗng** — với tất cả `SstCodeName` có chỉ định `:iconclick`, phải implement hàm hoàn chỉnh mở Lookup bằng `showLookupDialog.value = true`. `<SstDialog>` + `<CommonLookup>` trong template cũng cấm lược bỏ (cả màn hình tìm kiếm và màn hình đăng ký)
> - **Tận dụng sstUtil**: lấy ngày dùng `sstUtil().getCurrentDate('YYYYMMDD')`, không tự viết bằng `new Date()`
> - **dropdown của cột Select trong Grid**: gọi `DropDownApi` trong `init()` để lấy items và truyền `.value` vào `cellEditorParams.items`. **Cấm `items: []`**
> - **Bọc biến đa ngôn ngữ bằng `computed`**: các biến dùng `t()` (`tabItems`, `columnDefs`, `statusTypeItems` v.v.) bắt buộc phải khai báo bằng `computed(() => [...])`
> - **usePageChange (chỉ màn hình đăng ký)**: gọi `markClean()` sau khi lưu thành công, gọi `confirmValueChanged()` trước khi rời màn hình

### Cấu trúc chuẩn của panel thông tin hệ thống (chỉ thêm sau khi xác nhận với người dùng)

Ở màn hình đăng ký・bảo trì, nếu entity đối tượng có các cột audit `add*`/`upd*` (ngày giờ đăng ký・người đăng ký・thiết bị đăng ký・ngày giờ cập nhật・người cập nhật・thiết bị cập nhật・cờ hiệu lực v.v.) trong 項目定義, nhưng **mockup của 基本設計書 không thể hiện rõ panel tương ứng với `panel.systemInfo`**, thì không tự quyết định thêm/bỏ mà phải hỏi người dùng trước (`init.md` quy tắc #53). Khi người dùng đồng ý thêm, hoặc khi mockup màn hình đã vẽ panel đó, thì đặt panel `panel.systemInfo` như một panel có thể ẩn ở bên phải. Cấu trúc field:

| Field                                                         | Component          | Ghi chú                                 |
| ------------------------------------------------------------- | ------------------ | --------------------------------------- |
| `actFlg` (cờ hiệu lực)                                        | `SstSelect`        | Truyền `actFlgItems` (DropDownApi v.v.) |
| `addDateTime` / `updDateTime` (ngày giờ đăng ký/cập nhật)     | `SstDateTimeInput` | `disabled`                              |
| `addUserName` / `updUserName` (người đăng ký/người cập nhật)  | `SstTextField`     | `disabled`                              |
| `addTerminalCd` / `updTerminalCd` (thiết bị đăng ký/cập nhật) | `SstTextField`     | `disabled`                              |

Thêm các field này + `systemInfo` (cờ đóng/mở panel) vào `form`, và thêm `systemInfoHidden` vào `hidden` (cùng pattern với `subInfoHidden` hiện có). Ví dụ template xem block "panel thông tin hệ thống" trong template màn hình đăng ký ở trên.

```ts
import { reactive, ref, computed, onMounted } from 'vue'
import { useI18n, useMessage, useDialog, sstUtil, useSstHotkeyScope } from '@sst-cm/sst-fw-web'
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig'
import type { {RequestType}, {ResponseType} } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}ApiType'
import { {機能名Pascal}Api } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}Api'
import { DropDownApi } from '{dropDownApiDir}/dropDownApi'

// ⚠️ Quy tắc import:
// - Viết import tường minh cho mọi symbol được sử dụng (chỉ những gì thực sự dùng trong file này)
// - Gộp các import từ cùng một package vào 1 dòng (cấm dòng trùng lặp)
// - useI18n, useMessage, useDialog, useNotification, sstUtil, useSstHotkeyScope, usePageChange, CellEditorType → '@sst-cm/sst-fw-web'
// - useFormDisplayConfig → '@/composables/sstMemorizeConfig'
// - CodeNameType → nếu chỉ dùng trong template thì import ở <script setup> của .vue. Chỉ import tại đây khi dùng trong composable

export const use{機能名Pascal} = () => {
  const t = useI18n()
  const message = useMessage()
  const dialog = useDialog()  // dùng cho dialog xác nhận của thao tác batch

  // ── Hotkey (chung của hệ thống: F3=tìm kiếm, F4=nhân bản, F6=tạo mới, F7=lưu, F8=xóa, F9=thực thi) ──
  // → Đăng ký tất cả các phím tương ứng với những button tồn tại trên màn hình này
  const SCREEN_ID = '{featureName}'
  const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID })
  useSstHotkey('f3', search)   // tìm kiếm
  useSstHotkey('f8', clear)    // xóa
  useSstHotkey('f9', execute)  // thực thi

  // ── Form ──
  // ⚠️ Chỉ định kiểu bằng generic của ref (chú thích kiểu Ref<T> là dư thừa nên không dùng)
  const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()
  const gridRef = ref<InstanceType<any>>()

  // ⚠️ Giá trị khởi tạo của ngày: khai báo biến today một lần duy nhất và tái sử dụng ở từng field
  // ❌ Cấm: shipSchDateStart: sstUtil().getCurrentDate(), shipSchDateEnd: sstUtil().getCurrentDate()
  // ✅ Đúng: khai báo today → tham chiếu today ở các field của form
  const today = sstUtil().getCurrentDate('YYYYMMDD') as string

  const form: Form = reactive<Form>({
    ownerCd: '',
    warehouseCd: '',
    shipSchDateStart: today,
    shipSchDateEnd: today,
    // ... các field khác
  })

  // ── Bọc biến đa ngôn ngữ bằng computed (tất cả các biến dùng t()) ──
  // ⚠️ Chỉ khai báo tabItems/activeTab khi Figma chia tab. Nếu là cấu trúc trang đơn thì không cần (init.md quy tắc #50)
  const tabItems = computed(() => [
    { value: 'condition', label: t('tab.searchCondition') },
    { value: 'result', label: t('tab.searchResult') },
  ])

  // ⚠️ items của Radio nếu dùng t() thì cũng phải bọc bằng computed
  const statusTypeItems = computed(() => [
    { label: t('status.match'), value: '0' },
    { label: t('status.before'), value: '1' },
    { label: t('status.after'), value: '2' },
  ])

  // ── Memorize ──
  // ⚠️ Gọi useFormDisplayConfig() không có tham số. Cấm truyền MEMORIZE_CONFIG làm tham số
  // ⚠️ Giá trị trả về là { getMemorizeConfig, saveMemorizeConfig } — loadMemorizeConfig không tồn tại
  const { getMemorizeConfig, saveMemorizeConfig } = useFormDisplayConfig()
  const MEMORIZE_FIELD_IDS = ['ownerCd', 'warehouseCd']
  // ⚠️ MEMORIZE_CONFIG bắt buộc có đủ 4 field sau. Cấm dạng { screenId, items }
  // ⚠️ gridRefs / formRefs ở dạng Record<string, Ref>. Cấm dạng mảng [gridRef]
  const MEMORIZE_CONFIG = {
    screenId: SCREEN_ID,
    gridRefs: { grid: gridRef },
    formRefs: { form: formRef },
    trackedFieldIds: MEMORIZE_FIELD_IDS,
  }

  // ⚠️ doInit() bắt buộc gọi trong onMounted (cấm gọi ngay ở top-level)
  // Nếu gọi ở top-level thì lỗi khởi tạo bị che mất và màn hình chạy ở trạng thái trước onMounted
  onMounted(async () => {
    await doInit()
    getMemorizeConfig(MEMORIZE_CONFIG)
  })

  // ── Dialog Lookup ──
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
  // ⚠️ Không dùng any cho tham số của onLookupSelected — hãy định nghĩa kiểu LookupRow
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

### Bộ khung composable của màn hình đăng ký

Khác biệt so với màn hình tìm kiếm: `usePageChange` (dirty check), `useRouter`/`useRoute`, điều khiển độ rộng tree, điều khiển ẩn panel.
Hotkey tuân theo quy tắc chung của hệ thống (F3=tìm kiếm/F4=nhân bản/F6=tạo mới/F7=lưu/F8=xóa/F9=thực thi), đăng ký cho những button tồn tại trên màn hình.

```ts
import { reactive, ref, computed, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { CellEditorType, useI18n, useMessage, sstUtil, usePageChange, useSstHotkeyScope } from '@sst-cm/sst-fw-web'
import { useFormDisplayConfig } from '@/composables/sstMemorizeConfig'
import type { {RequestType}, {ResponseType} } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}ApiType'
import { {機能名Pascal}Api } from '@/api/{中分類}/{小分類}/{機能名}Api/{機能名}Api'
import { DropDownApi } from '{dropDownApiDir}/dropDownApi'
// ⚠️ Chỉ import CodeNameType khi sử dụng trực tiếp bên trong composable
// Nếu chỉ dùng trong template thì phải import ở <script setup> của .vue

export const use{機能名Pascal} = () => {
  const t = useI18n()
  const message = useMessage()
  const router = useRouter()
  const route = useRoute()

  // ── Dirty check ──
  const pageDirty = usePageChange()
  // ⚠️ Cách dùng:
  // - pageDirty.markClean()           → sau khi lưu thành công / sau khi xóa / sau khi đọc dữ liệu ban đầu
  // - pageDirty.confirmValueChanged() → tạo mới/copy/chuyển tree/trước khi rời màn hình (nếu false thì hủy thao tác)

  // ── Hotkey (chung của hệ thống: F3=tìm kiếm, F4=nhân bản, F6=tạo mới, F7=lưu, F8=xóa, F9=thực thi) ──
  // → Đăng ký tất cả các phím tương ứng với những button tồn tại trên màn hình này
  const SCREEN_ID = '{featureName}'
  const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID })
  useSstHotkey('f4', copyForm)    // nhân bản
  useSstHotkey('f6', newForm)     // tạo mới
  useSstHotkey('f7', save)        // lưu
  useSstHotkey('f8', clearForm)   // xóa

  // ── Form ──
  // ⚠️ Chỉ định kiểu bằng generic của ref (chú thích kiểu Ref<T> là dư thừa nên không dùng)
  const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()
  const gridRef = ref<InstanceType<any>>()
  const form = reactive<Form>({ /* giá trị khởi tạo */ })
  const gridData = ref<RowType[]>([])

  // ── Memorize ──
  // ⚠️ Gọi useFormDisplayConfig() không có tham số. Cấm truyền MEMORIZE_CONFIG làm tham số
  // ⚠️ Giá trị trả về là { getMemorizeConfig, saveMemorizeConfig } — loadMemorizeConfig không tồn tại
  const { getMemorizeConfig, saveMemorizeConfig } = useFormDisplayConfig()
  const MEMORIZE_FIELD_IDS = ['ownerCd', 'warehouseCd'] // chỉ định các mục memorize theo tài liệu thiết kế
  // ⚠️ MEMORIZE_CONFIG bắt buộc có đủ 4 field sau. Cấm dạng { screenId, items }
  // ⚠️ gridRefs / formRefs ở dạng Record<string, Ref>. Cấm dạng mảng [gridRef]
  const MEMORIZE_CONFIG = {
    screenId: SCREEN_ID,
    gridRefs: { grid: gridRef },
    formRefs: { form: formRef },
    trackedFieldIds: MEMORIZE_FIELD_IDS,
  }

  // ── Điều khiển độ rộng tree ──
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

  // ── Hiện/ẩn panel ──
  // ⚠️ Trường hợp dùng systemInfoHidden ở chức năng có cột audit add*/upd* (chỉ định nghĩa khi người dùng đã đồng ý thêm panel thông tin hệ thống). Xem "Cấu trúc chuẩn của panel thông tin hệ thống"
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
  // ⚠️ Không khai báo tham số không sử dụng (tham số không dùng vi phạm SonarQube)
  function hiddenPanelClick(key: string) {
    hidden[key] = true
  }
  function showPanelHandle(key: string) {
    hidden[key] = false
  }

  // ── Điều khiển mode (tương ứng "処理モード概要" của 詳細設計書 - tài liệu thiết kế chi tiết) ──
  // ⚠️ pcsMod là '0'=mode đăng ký mới / '1'=mode chỉnh sửa. Trong newForm/copyForm đặt '0', sau khi loadData thành công đặt '1'
  const pcsMod = ref<'0' | '1'>('0')
  // ⚠️ Bảng "初期値設定" (thiết lập giá trị khởi tạo) của 詳細設計書 (tên mục/giá trị khởi tạo/cho phép nhập・không cho phép/ghi chú)
  //    thì gom disabled của từng field vào 1 computed duy nhất này.
  //    Trong template cho tham chiếu theo kiểu `:disabled="fieldDisabled.warehouseCd"`,
  //    không khai báo ref riêng cho từng field (để tránh viết thiếu khi thêm mode).
  const fieldDisabled = computed(() => ({
    // Chỉ liệt kê các mục có cho phép nhập/không cho phép = không cho phép trong bảng "初期値設定" của 詳細設計書
    bizType: pcsMod.value === '1',
    ownerCd: pcsMod.value === '1',
    warehouseCd: pcsMod.value === '1',
  }))
  // ⚠️ Bảng "画面ボタン制御" (điều khiển button màn hình) của 詳細設計書 (tên mục/khả dụng hay không/ghi chú) cũng gom vào 1 computed tương tự
  const buttonDisabled = computed(() => ({
    save: false,
    delete: pcsMod.value === '0',
  }))

  // ── Bọc biến đa ngôn ngữ bằng computed ──
  const tabItems = computed(() => [
    { value: 'condition', label: t('tab.basic') },
    { value: 'result', label: t('tab.detail') },
  ])
  const columnDefs = computed(() => [ /* ... */ ])

  // ── Thao tác ──
  async function save() {
    const valid = await formRef.value?.validateAll()
    if (!valid) return
    // ⚠️ Trong save phải nhận response, khi tạo mới thì phản ánh khóa chính được trả về vào form
    // ⚠️ Cấm triple cast kiểu `as unknown as Record<string, unknown>`
    //    Nếu các field của form khớp với kiểu API thì có thể cast trực tiếp bằng `{ ...form } as Web.XxxRequest`
    const res = await {機能名Pascal}Api.save({
      header: { ...form } as Web.{SaveHeaderRequest},
      detail: gridData.value as unknown as Web.{SaveDetailRequest}[],
    })
    // Trường hợp mode tạo mới, phản ánh khóa chính từ response
    if (pcsMod.value === '0' && res?.soNo) {
      form.soNo = res.soNo
      addTreeItem(form.soNo)
      pcsMod.value = '1'
    }
    pageDirty.markClean()
    message.info(t('information.codes.I00001'))
    saveMemorizeConfig(MEMORIZE_CONFIG)
  }

  // ── Đọc dữ liệu (loadData / loadSoData) ──
  // ⚠️ Nếu số field vượt quá 20, cấm gán từng dòng một (SonarQube: vượt Cognitive Complexity)
  // → Nén lại bằng mảng mapping field + vòng lặp
  async function loadData(soNo: string) {
    const res = await {機能名Pascal}Api.getSoInfo({ soNo })
    const header = res?.soHeader
    if (!header) return

    // Mapping hàng loạt các field kiểu chuỗi (gom các field có cùng logic chuyển đổi)
    const stringFields = [
      'ownerCd', 'ownerName', 'warehouseCd', 'warehouseName',
      'shipToCd', 'shipToName', 'transportCd', 'transportName',
      // ... liệt kê các field theo tài liệu thiết kế
    ] as const
    stringFields.forEach((f) => {
      ;(form as Record<string, unknown>)[f] = sstUtil().toString(header[f as keyof typeof header])
    })

    // Các field có chuyển đổi kiểu khác nhau thì viết riêng
    form.soQty = header.soQty != null ? Number(header.soQty) : null
    form.shipSchDate = sstUtil().toString(header.shipSchDate)

    // Grid chi tiết
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

  // ── Lifecycle ──
  // ⚠️ doInit() bắt buộc gọi trong onMounted (cấm gọi ngay ở top-level)
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

## Bảng đối chiếu component

> **Nếu cần đặc tả chi tiết (property・slot・event・ví dụ sử dụng), hãy kiểm tra danh sách component do `@sst-cm/sst-fw-web` cung cấp.**

### Quy tắc đặt tên component

> Trong template bắt buộc dùng **PascalCase** (`<SstTextField>`). Cấm kebab-case (`<sst-text-field>`).

### Mục đơn lẻ (form)

| Component trong tài liệu thiết kế | Component Vue        | Kiểu      | Ghi chú                                                                                        |                                         |
| --------------------------------- | -------------------- | --------- | ---------------------------------------------------------------------------------------------- | --------------------------------------- |
| SstTextField                      | `<SstTextField>`     | `string`  | `v-model`, `id`, `:label`                                                                      |                                         |
| SstTexField                       | `<SstTextField>`     | `string`  | Lỗi typo trong tài liệu thiết kế. Giống SstTextField                                           |                                         |
| SstNumberInput                    | `<SstNumberInput>`   | `number \ | null`                                                                                          | `v-model`, `id`, `:label`, `:maxlength` |
| SstDateInput                      | `<SstDateInput>`     | `string`  | `v-model`, `id`, `:label`                                                                      |                                         |
| SstDateTimeInput                  | `<SstDateTimeInput>` | `string`  | `v-model`, `id`, `:label`. Nhập ngày giờ                                                       |                                         |
| SstTimePicker                     | `<SstTimePicker>`    | `string`  | `v-model`, `:label`. Nhập thời gian (HH:mm)                                                    |                                         |
| SstSelect                         | `<SstSelect>`        | `string`  | `v-model`, `:items`, `:label`                                                                  |                                         |
| SstRadio                          | `<SstRadio>`         | `string`  | `v-model`, `:items`, `:label`                                                                  |                                         |
| SstCheckbox                       | `<SstCheckbox>`      | `string`  | `v-model`, `:items`                                                                            |                                         |
| SstCodeName                       | `<SstCodeName>`      | `string`  | `v-model`(mã), `v-model:name`(tên), **`:code-type`(bắt buộc)**, `:iconclick`, `@retrieve-data` |                                         |
| SstAvatar                         | `<SstAvatar>`        | -         | Chỉ dùng để hiển thị                                                                           |                                         |
| SstButton                         | `<SstButton>`        | -         | `@click`, `text`, `variant`, `prepend-icon`                                                    |                                         |

### SstCodeName

> **⚠️ Khi dùng `v-model:name` thì cấm lược bỏ `@retrieve-data` (init.md quy tắc #54).** `:iconclick` thì có cần hay không tùy theo tài liệu thiết kế có `ルックアップ: ✔` (lookup) hay không (quy tắc #22), nhưng `@retrieve-data` luôn cần thiết để tự động lấy tên khi nhập mã.

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
// ⚠️ Ưu tiên dùng sstUtil (lưu ý trong init.md). Không cast trực tiếp bằng String()
const handleFetchOwnerCd = (data?: CodeNameResponse): void => {
  form.ownerName = data?.data?.name != null ? sstUtil().toString(data.data.name) : '';
};
```

### Component layout

| Component trong tài liệu thiết kế | Component Vue   | Mô tả                                                                      |
| --------------------------------- | --------------- | -------------------------------------------------------------------------- |
| SstPanel                          | `<SstPanel>`    | `variant="accordion"`, `elevation="3"`, `:title`, `v-model`(boolean), `id` |
| SstTabs                           | `<SstTabs>`     | `v-model`(activeTab), `v-model:tabs`(tabItems), `:closable="false"`        |
| SstTreeview                       | `<SstTreeview>` | Hiển thị filter bằng prop `filterable` (không tự làm)                      |

> ⚠️ `tabItems` bắt buộc phải khai báo bằng `computed(() => [...])`. Cấm `ref([...])` hoặc mảng thuần (sẽ không phản ứng với việc chuyển đổi ngôn ngữ).

### Filter của SstTreeview

> Chỉ cần đặt prop `filterable` thành `true`. **Không tự viết TextField + computed filter.**

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

### Tên field của items (chung cho mọi component)

> Tên field mặc định của `:items` ở tất cả các component `Sst*` là **`value`** và **`label`**.
> Response của DropDownAPI cũng cùng định dạng nên không cần chỉ định `item-title` / `item-value`.

```html
<!-- Mặc định value/label → không cần chỉ định -->
<SstSelect v-model="form.field" :items="items" />
<SstRadio v-model="form.field" :items="items" />
<SstTabs v-model="activeTab" v-model:tabs="items" />

<!-- Chỉ chỉ định khi dữ liệu ở dạng { value, name } -->
<SstSelect v-model="form.field" :items="items" item-title="name" />
```

> ⚠️ Viết `item-title="label"` cho `{ value, label }` là dư thừa (cấm).
