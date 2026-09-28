# Quy trình tạo mới frontend

Tài liệu này giải thích quy trình tạo mới các file frontend dựa trên tài liệu thiết kế.
Chi tiết hãy Read từng file tham chiếu tương ứng.

> **🚨 Các quy tắc dễ bị bỏ sót (bắt buộc kiểm tra trước khi sinh code):**
>
> 1. **Grid columnDefs**: Cột nhập liệu có số ký tự trong tài liệu thiết kế → bắt buộc chỉ định `cellEditorParams: { maxLength: N }` (**bao gồm cả cột Number**)
> 2. **Grid columnDefs**: Cột nhập liệu có dấu bắt buộc trong tài liệu thiết kế → bắt buộc chỉ định `cellEditorParams: { rules: [{ required: true, message: t('...') }] }`
> 3. **Cột thao tác của Grid**: `cellRenderer: CellEditorType.Action` (không phải `cellEditor`) + `cellRendererParams: { actions: [...] }`
> 4. **PascalCase**: Mọi component Sst đều viết theo PascalCase như `<SstTextField>` (cấm `<sst-text-field>`)
> 5. **Filter của SstTreeview**: Dùng prop `filterable`. Không tự viết TextField + filter bằng computed
> 6. **pageChanged**: Ghi `page`/`size` trở lại biến rồi mới tìm kiếm lại (không phải `pageNumber`/`pageSize`)
> 7. **getData()**: Khi phân trang phía server, bắt buộc truyền `page` / `size` cho API
> 8. **Cột Select của Grid**: Không chỉ định mảng rỗng `[]` cho `cellEditorParams.items`. Hãy truyền `.value` của ref lấy được từ DropDownApi trong init()
> 9. **usePageChange (màn hình đăng ký)**: Không chỉ khai báo mà phải gọi `markClean()` / `confirmValueChanged()` vào thời điểm thích hợp
> 10. **Key i18n của Grid headerName**: Dùng `t('label.xxx')`. Cấm namespace tự đặt như `t('grid.xxx')`
> 11. **items của SstSelect/SstRadio**: Mặc định đã là `label`/`value` nên không viết `item-title="label" item-value="value"` (dư thừa)
> 12. **SstCodeName**: `:code-type` là prop bắt buộc. Cấm lược bỏ (bắt buộc chỉ định `CodeNameType.OWNER`, v.v.)
> 13. **paginationSettings**: Tên field là `page`/`size`/`total`/`pageSizes`/`enabled`. Cấm `pageNumber`/`pageSize`/`totalCount`
> 14. **pagination-mode="server"**: Viết tường minh trên SstGrid của màn hình tìm kiếm (không lược bỏ)
> 15. **Import tường minh ở mọi nơi sử dụng**: `useI18n`, `useMessage`, `useDialog`, `useNotification`, `sstUtil`, `useSstHotkeyScope`, `usePageChange`, `CellEditorType`, `useFormDisplayConfig`, v.v. **bắt buộc phải có câu lệnh `import` tường minh**. Nguồn import xem bảng tương ứng trong SKILL.md
> 16. **Cấm import trùng lặp từ cùng một package**: Khi `import` nhiều lần từ cùng một package thì **gộp vào 1 dòng**. Ví dụ: `import { CellEditorType, useI18n, useSstHotkeyScope } from '@sst-cm/sst-fw-web'` (không tách thành 2 dòng)
> 17. **Handler @selection-changed**: Lấy mảng các dòng được chọn bằng `event.selectRows`. Cấm gọi trực tiếp AG Grid API. Pattern triển khai xem `references/02-grid-definition.md` và `references/03-event-implementation.md`
> 18. **Cấm viết tay kiểu trong ApiType.ts**: Bắt buộc alias các kiểu `Web.*` của `@sst-cm/fe-web-client`. Không tự định nghĩa bằng `Record<string, unknown>` hay kiểu object literal
> 19. **Inject localeCd**: Chỉ inject `localeCd: getLocaleCd()` vào request đối với API mà SQL trong tài liệu thiết kế có 「言語コード」 (mã ngôn ngữ, locale_cd). Nếu không có thì không thêm. Phần triển khai tuân theo pattern `getLocaleCd()` trong `references/04-api-definition.md` và phải viết ở **tầng API** (`{tên chức năng}Api.ts`). Không inject trực tiếp ở phía composable
> 20. **Cấm TODO/triển khai rỗng cho Lookup**: Khi có `SstCodeName` được chỉ định `:iconclick`, hàm `iconclick` bắt buộc phải là triển khai hoàn chỉnh mở dialog Lookup bằng `showLookupDialog.value = true`. Cấm `// TODO` hoặc hàm rỗng. Phía template cũng bắt buộc đặt `<SstDialog>` + `<CommonLookup>`, và import `CommonLookup` trong `<script setup>`. Pattern triển khai xem bộ khung composable trong `references/01-template-structure.md`
> 21. **Tuân thủ nghiêm cách viết Hotkey**: Giá trị trả về của `useSstHotkeyScope` là **`useSstHotkey`** (không phải `registerHotkey`). Tham số scope cũng bắt buộc. Tên phím viết **chữ thường** (`'f3'`). Callback truyền bằng tham chiếu hàm (`search`). Pattern đúng: `const { useSstHotkey } = useSstHotkeyScope({ scope: SCREEN_ID }); useSstHotkey('f3', search)`. ❌ Cấm `registerHotkey('F3', () => search())`
> 22. **`:iconclick` của SstCodeName tuân theo tài liệu thiết kế**: Với `SstCodeName` mà 項目定義 (định nghĩa hạng mục) trong tài liệu thiết kế có `ルックアップ: ✔` thì bắt buộc chỉ định prop `:iconclick`. Cấm lược bỏ `:iconclick` để né việc triển khai Lookup. Kết quả là quy tắc #20 chắc chắn có hiệu lực và bắt buộc triển khai hoàn chỉnh dialog Lookup. SstCodeName **không có** `ルックアップ: ✔` trong tài liệu thiết kế thì không cần `:iconclick`. **Trước khi triển khai**, hãy trích xuất toàn bộ các dòng ứng với `SstCodeName` từ bảng 項目定義 của tài liệu thiết kế, liệt kê giá trị cột `ルックアップ` (có ✔ hay không) rồi mới bắt tay triển khai (nhận ra sau khi triển khai sẽ phải làm lại nhiều và là nguyên nhân gây bỏ sót). Sau khi sinh code, ở bước self-check của quy tắc #51 hãy đối chiếu để xác nhận số lượng ✔ trong danh sách này và số lần xuất hiện `:iconclick` trong `.vue` **khớp hoàn toàn**
> 23. **Key của Lookup phải viết HOA + bắt buộc dùng computed**: `currentLookupKey` bắt buộc định nghĩa bằng `computed`, và map giá trị của `currentLookupType` sang **chữ HOA** bằng `switch` (ví dụ: `case 'owner': return 'OWNER'`). Cấm cách gán trực tiếp bằng `ref('')`. `LookupType` là định danh chữ thường (`'owner'`/`'warehouse'`), còn giá trị cuối cùng truyền cho `:lookup-key` là chữ HOA (`'OWNER'`/`'WAREHOUSE'`)
> 24. **Cấm hardcode tiếng Nhật trong template**: Chuỗi hiển thị trong `<template>` bắt buộc dùng key i18n qua `t('xxx')`. Cấm nhúng trực tiếp chuỗi tiếng Nhật như `"読み込み中..."` hay `"データなし"`. Phần hiển thị loading/lỗi/rỗng trong các slot như `#detail` cũng phải dùng `t('information.codes.xxx')`
> 25. **Cấm trùng tên tham số callback**: Không dùng `t` làm tham số callback của `findIndex`/`filter`/`map`, v.v. (sẽ shadow `t = useI18n()` của i18n). Thay vào đó dùng `el`, `item`, `entry`, `c`, v.v. Ví dụ: `conditionItems.value.findIndex((el) => el.value === item)` ✅ / `...findIndex((t) => t.value === item)` ❌
> 26. **Gọi doInit() bên trong onMounted**: Cấm gọi ngay `doInit()` ở top level của composable. Hãy gọi bằng `onMounted(async () => { await doInit(); ... })`. Nếu ở top level thì lỗi khởi tạo sẽ bị che mất và phát sinh vấn đề ref của template chưa được resolve
> 27. **Shape đúng của MEMORIZE_CONFIG**: Bắt buộc chỉ định 4 field `{ screenId, gridRefs, formRefs, trackedFieldIds }`. Dạng `{ screenId, items }` là pattern cũ và bị cấm. **Điểm cần lưu ý**: (a) `useFormDisplayConfig()` gọi **không có tham số** — `useFormDisplayConfig(MEMORIZE_CONFIG)` là sai. (b) Giá trị trả về là `{ getMemorizeConfig, saveMemorizeConfig }` — không tồn tại `loadMemorizeConfig`. (c) `gridRefs` / `formRefs` ở **dạng Record** `{ grid: gridRef }` / `{ form: formRef }` — mảng `[gridRef]` là sai
> 28. **Thống nhất dùng async/await**: Mọi hàm bất đồng bộ trong composable đều viết bằng `async/await`. Không trộn lẫn với chuỗi `.then()`. `getData()` cũng phải viết là `async function getData()`
> 29. **Chỉ định :code-type bằng hằng số CodeNameType**: `:code-type` của `SstCodeName` bắt buộc dùng hằng số như `CodeNameType.OWNER` / `CodeNameType.WAREHOUSE`. Cấm chuỗi literal như `"SHIPTO"`. Nếu `CodeNameType` chưa có giá trị tương ứng thì bổ sung định nghĩa vào `src/constants/codeNameType.ts` rồi mới dùng (`import { CodeNameType } from '@/constants/codeNameType'`)
> 30. **Cấm any trong onLookupSelected**: Tham số của handler chọn Lookup không dùng `any`, hãy định nghĩa và dùng kiểu `LookupRow` (`{ code?: string; name?: string; [key: string]: unknown }`)
> 31. **Giá trị ngày mặc định gom về biến `today`**: `sstUtil().getCurrentDate('YYYYMMDD')` chỉ **gọi một lần duy nhất ở đầu composable dưới dạng `const today = ...`**, và mỗi field của form tham chiếu `today`. Cấm gọi inline theo từng field như `shipSchDateStart: sstUtil().getCurrentDate(), shipSchDateEnd: sstUtil().getCurrentDate()` (dư thừa và gây lệch thời điểm gọi)
> 32. **`:dateFormat` của SstDateInput**: Giá trị model của hạng mục ngày luôn là `YYYYMMDD` (không có dấu phân cách). **Format hiển thị** chỉ định bằng prop `:dateFormat`. Mặc định là `YYYY/MM/DD` nên nếu cột 「フォーマット」 (format) của tài liệu thiết kế là `YYYY/MM/DD` hoặc không ghi thì có thể lược bỏ `:dateFormat`. Nếu tài liệu thiết kế ghi giá trị khác mặc định như `YYYY-MM-DD` hay `YYYY年MM月DD日` thì phải viết tường minh kiểu `:dateFormat="'YYYY-MM-DD'"`
> 33. **:code-type phải khớp ý nghĩa nghiệp vụ của field**: `:code-type` của `SstCodeName` phải chỉ định giá trị tương ứng với **thực thể nghiệp vụ mà field đó biểu diễn**. Cấm copy-paste từ field khác rồi dùng lại CodeNameType khác. Ví dụ: gán `CodeNameType.OWNER` (chủ hàng) cho `transportCd` (công ty vận chuyển) là **sai**. Nếu `CodeNameType` không có giá trị tương ứng thì bổ sung vào `src/constants/codeNameType.ts` rồi mới dùng
> 34. **Xử lý response của save() (màn hình đăng ký)**: Trong `save()` ở chế độ tạo mới (`pcsMod='0'`), bắt buộc triển khai việc **phản ánh khóa chính (soNo, v.v.) trả về từ response API vào form** và thêm vào cây. Không được bỏ qua response. Pattern: `const res = await Api.save({...}); if (pcsMod.value === '0') { form.soNo = res.soNo ?? ''; addTreeItem(form.soNo); pcsMod.value = '1'; } pageDirty.markClean()`
> 35. **Chỉ viết import trong file có sử dụng**: Nếu `CodeNameType` chỉ dùng trong template của `.vue` thì import trong `<script setup>` của `.vue`, không import vào composable (`use*.ts`). Chỉ import những symbol thực sự dùng bên trong composable. **Import không dùng (dead code) sẽ là vi phạm Critical trên SonarQube**
> 36. **Nén các phép gán dài trong loadData bằng mapping helper**: Khi số field gán từ response API vào form **vượt quá 20**, cấm viết từng dòng `form.xxx = String(header.xxx ?? '')` (vượt Cognitive Complexity + hơn 100 dòng). Thay vào đó hãy nén bằng **mảng mapping field + vòng lặp**: `const fields = ['ownerCd', 'warehouseCd', ...] as const; fields.forEach((f) => { form[f] = sstUtil().toString(header[f]) })`. Chỉ những field có cách chuyển kiểu khác (số・ngày) mới viết riêng
> 37. **Chỉ destructure trong `.vue` những giá trị dùng trong template**: Các biến được lấy ra từ object return của composable trong `<script setup>` của `.vue` phải **giới hạn ở những giá trị thực sự được tham chiếu trong template**. Những giá trị không dùng trong template (như `statusItems` chỉ được tham chiếu bên trong columnDefs) thì không lấy ra. Biến lấy ra mà không dùng sẽ là vi phạm dead code của SonarQube
> 38. **Quy tắc chỉ định cellEditor cho cột không cho sửa**: Với cột `editable: false` hãy tuân thủ: (1) Chỉ **cột Date/DateTime** mới được chỉ định `cellEditor: CellEditorType.Date` (dùng cho format hiển thị). (2) **Các cột không phải Date như Select/Input/Number** thì **không chỉ định** `cellEditor` / `cellEditorParams` (không cần cho hiển thị, gây nhầm lẫn). (3) `cellEditorParams` (`items`, v.v.) chỉ chỉ định cho cột `editable: true`
> 39. **`:tab` phải gán đầy đủ cho mọi component nhập liệu**: Bất kể số field trong tài liệu thiết kế, hãy gán `:tab="N"` cho **toàn bộ component nhập liệu** như `SstTextField`/`SstNumberInput`/`SstDateInput`/`SstSelect`/`SstCodeName`/`SstRadio`/`SstTimePicker`, v.v. Các field trong panel thông tin bổ sung (soSupplementInfo01〜20, v.v.) cũng cấm lược bỏ. Nếu không, thứ tự focus của phím Tab sẽ bị ngắt
> 40. **Giới hạn cast `as unknown as`**: Cấm **triple cast bỏ qua hoàn toàn type safety** như `{ ...form } as unknown as Record<string, unknown>`. Trong save() hãy map tường minh từ form sang kiểu API. Pattern: (1) Nếu tên field của form khớp với kiểu API → `{ ...form } as Web.XxxRequest` (có thể cast trực tiếp). (2) Nếu tên field khác nhau → dựng object một cách tường minh. `as unknown as` chỉ được phép dùng cho **chuyển kiểu phần tử của mảng** (`gridData.value as unknown as Web.XxxDetail[]`)
> 41. **Không có tham số hàm không dùng**: Không khai báo tham số không dùng trong định nghĩa hàm. Cấm pattern như `hiddenPanelClick(key: string, _name: string)` trong template hiện có. Chỉ định nghĩa tham số được dùng: `hiddenPanelClick(key: string)`
> 42. **Lược bỏ chú thích kiểu `Ref<T>`**: Không viết chú thích kiểu dư thừa như `const formRef: Ref<{ resetAll: () => void; validateAll: () => Promise<boolean> } | undefined> = ref()`. Thay vào đó hãy để suy luận qua generic của `ref`: `const formRef = ref<{ resetAll: () => void; validateAll: () => Promise<boolean> }>()`
> 43. **Tham số của `useDialog` là object (cấm chuỗi)**: `dialog.confirm()` / `dialog.info()`, v.v. nhận object kiểu `DialogOptions`. ✅ `dialog.confirm({ content: t('message.xxx') })` / ❌ `dialog.confirm(t('message.xxx'))` (truyền trực tiếp chuỗi là **sai**). Các field chính của `DialogOptions`: `{ title?: string, content?: string, persistent?: boolean, positiveText?: string, negativeText?: string }`
> 44. **Tên method của `useMessage`**: `info` / `success` / `warning` / `error` + bản `WithTitle` (`infoWithTitle(title, content)`, v.v.) + `closeAll()`. **Không tồn tại `showInfo` / `showSuccess` / `showError` / `showWarning`**. Pattern đúng: `message.info(t('information.codes.I00001'))` / `message.successWithTitle('Hoàn tất', 'Đã lưu')`
> 45. **`useI18n()` được gọi ở cả .vue và composable (đúng về mặt thiết kế)**: Gọi `const t = useI18n()` ở **cả** `<script setup>` của `.vue` và composable (`use*.ts`) là bình thường. `useI18n()` theo pattern singleton state, nên gọi ở nhiều nơi vẫn tham chiếu cùng một trạng thái dịch. `t` ở phía `.vue` dùng trong template, `t` ở phía composable dùng bên trong composable (trong các `computed` như `columnDefs`, `tabItems`, `statusTypeItems`, v.v.). **Cấm pattern return `t` từ composable rồi dùng trong `.vue`** (lẫn lộn trách nhiệm)
> 46. **Cấm code trùng lặp trong thao tác batch (DRY)**: Ở màn hình tìm kiếm, khi có **từ 3 hàm trở lên** cùng pattern (xác nhận dialog → tạo danh sách → gọi API → thông báo → tìm kiếm lại) như xác định・phân bổ・thêm thực tế・xóa, hãy định nghĩa một hàm helper `batchAction` dùng chung và mỗi thao tác chỉ gọi nó. Copy-paste viết 4 hàm là vi phạm code trùng lặp của SonarQube. Pattern xem mục 「バッチ操作」 (thao tác batch) trong `references/03-event-implementation.md`
> 47. **Phương châm xử lý lỗi của `getData()`**: Khi gọi API bằng `apiCall` / `apiCallWithLoading` thì phía framework đã xử lý lỗi tập trung nên không cần `try/catch`. Nếu gọi API trực tiếp và dùng `try/finally` (chỉ để điều khiển loading) thì hãy thiết kế không viết block `catch` (lỗi sẽ tự động được xử lý ở tầng trên). Chỉ viết `try/finally` + **`catch` riêng** khi cần đưa thêm feedback cho người dùng
> 48. **詳細設計書 là đầu vào bắt buộc**: Nếu chỉ được cung cấp 基本設計書 mà không tìm thấy/không được cung cấp 詳細設計書 tương ứng (`docs/02.詳細設計/**/*.md`) thì không bắt đầu triển khai, hãy yêu cầu người dùng cung cấp 詳細設計書. Cấm suy đoán logic sự kiện hay tham số API chỉ từ phần văn xuôi của 基本設計書 để triển khai
> 49. **Cấm suy đoán ở các marker (🔴🟠) của 詳細設計書**: Những chỗ có gắn `（基本設計に記載なし）🔴【要詳細設計】` / `🟠【要基本設計書修正】` (xử lý sự kiện・mapping tham số・giá trị mặc định/điều khiển button, v.v.) thì không được suy đoán nội dung rồi viết code. Hãy dừng triển khai chỗ đó và hỏi người dùng. Những chỗ không gắn marker thì tiếp tục triển khai như bình thường
> 50. **Cấu trúc màn hình ưu tiên Figma hơn template trong `references/01-template-structure.md`**: Cấu trúc `SstTabs` (tab điều kiện/tab kết quả) của màn hình tìm kiếm chỉ là ví dụ chuẩn khi Figma chia tab. Nếu trong Figma điều kiện tìm kiếm và kết quả tìm kiếm nằm cùng một trang (không có chuyển tab) thì không dùng `SstTabs`/`#condition`/`#result`, hãy đặt block điều kiện và block kết quả trực tiếp trong trang, theo thứ tự từ trên xuống. Các quy ước style như bố trí button・gom nhóm bằng `SstCard`, v.v. vẫn áp dụng bất kể có tab hay không
> 51. **Self-check trước khi hoàn tất sinh code (cấu trúc layout・Lookup・vị trí button・thông tin hệ thống)**: Sau khi sinh `.vue`, trước khi commit hãy kiểm tra lại: (a) cấu trúc chia tab/trang đơn có khớp với Figma không, (b) **số lượng** `SstCodeName` có `ルックアップ: ✔` trong bảng 項目定義 của tài liệu thiết kế và **số lần xuất hiện** `:iconclick` trong `.vue` đã sinh có thực sự đếm và khớp nhau không (nếu lệch dù chỉ 1 thì coi là vi phạm quy tắc #22 và sửa ngay. Không dựa vào ký ức 「có lẽ đã gắn rồi」, bắt buộc phải đếm), (c) vị trí button trên màn hình (phía trên/phía dưới, v.v.) có khớp với Figma không (quy tắc #52), (d) khi có cột audit `add*`/`upd*` nhưng không thấy panel `panel.systemInfo` trong mockup màn hình thì đã xác nhận với người dùng về việc có cần thêm hay không chưa (quy tắc #53. Không tự ý thêm cũng không tự ý lược bỏ), (e) mọi `SstCodeName` dùng `v-model:name` đã gắn `@retrieve-data` chưa (quy tắc #54), (f) trong `<template>` có lẫn tag native của Vuetify kiểu `<v-xxx>` không (quy tắc #55). Hãy đối chiếu screenshot Figma đã lấy với `.vue` đã sinh để xác nhận
> 52. **Vị trí button của màn hình đăng ký・bảo trì không phải cố định ở đáy màn hình**: Ví dụ template màn hình đăng ký trong `references/01-template-structure.md` dùng utility class `position-fixed` + `style="top:...;right:..."` inline để cho button nổi gần phía trên trang, đó chỉ là ví dụ chuẩn; không được mặc định tạo thanh cố định ở đáy màn hình kiểu `position: fixed; bottom: 0`. Bắt buộc kiểm tra vị trí button thực tế trên Figma (vị trí・hướng canh lề) và điều chỉnh các giá trị `top`/`right`/`left`/`bottom` cho khớp
> 53. **Không tự quyết định có panel thông tin hệ thống (`panel.systemInfo`) hay không, hãy xác nhận với người dùng**: Với màn hình đăng ký・bảo trì mà 項目定義 của tài liệu thiết kế có các cột audit `add*`/`upd*` (ngày giờ đăng ký・người đăng ký・thiết bị đăng ký・ngày giờ cập nhật・người cập nhật・thiết bị cập nhật・cờ hiệu lực, v.v.), nếu **trong mockup màn hình của 基本設計書 (Figma/ảnh layout) không vẽ panel tương đương `panel.systemInfo`** thì không tự quyết định có thêm hay không (cấm cả tự ý thêm và tự ý lược bỏ), mà trước khi bắt tay triển khai hãy hỏi người dùng: 「項目定義 có cột audit nhưng không thấy panel thông tin hệ thống trong mockup màn hình. Có thêm không?」. Chỉ khi người dùng đồng ý thêm thì mới triển khai theo 「システム情報パネルの標準構成」 (cấu trúc chuẩn của panel thông tin hệ thống) trong `references/01-template-structure.md`. Nếu mockup màn hình đã vẽ panel thông tin hệ thống thì không cần xác nhận, triển khai luôn
> 54. **Cấm lược bỏ `@retrieve-data` của `SstCodeName` khi dùng `v-model:name`**: `:iconclick` (quy tắc #22) chỉ bắt buộc khi tài liệu thiết kế có `ルックアップ: ✔`, nhưng `@retrieve-data` thì không liên quan đến điều đó và **bắt buộc với mọi `SstCodeName` có liên kết field tên bằng `v-model:name`** (để tự động lấy tên khi nhập mã, không liên quan đến việc có dialog Lookup hay không). Pattern triển khai handler xem mục 「SstCodeName」 trong `references/01-template-structure.md` (dùng kiểu `CodeNameResponse`, chuyển giá trị bằng `sstUtil().toString()`)
> 55. **Cấm dùng trực tiếp component Vuetify**: Cấm viết trực tiếp trong `<template>` các component native của Vuetify như `<v-card-text>`/`<v-btn>`/`<v-text-field>`/`<v-select>`/`<v-dialog>`, v.v. **Bắt buộc dùng các component wrapper `Sst*` do `@sst-cm/sst-fw-web` cung cấp (`SstCard`/`SstCardText`/`SstCardTitle`/`SstButton`/`SstTextField`/`SstSelect`/`SstDialog`, v.v.)**. Nếu không tìm thấy component `Sst*` tương ứng với UI mong muốn thì không tự ý fallback sang `v-*`, hãy xác nhận với người dùng

## Danh sách file tham chiếu

Khi triển khai, hãy Read các file sau theo nhu cầu:

| File                                    | Nội dung                                                              |
| --------------------------------------- | --------------------------------------------------------------------- |
| `references/01-template-structure.md`     | Template màn hình tìm kiếm/đăng ký + khung composable + bảng component |
| `references/02-grid-definition.md`         | SstGrid + columnDefs + pagination + pageChanged + getData             |
| `references/03-event-implementation.md`         | Pattern thêm điều kiện/điều khiển chọn/tìm kiếm/lưu/xóa               |
| `references/04-api-definition.md`              | types.ts/ApiType.ts/Api.ts/client.ts/DropDown/CodeName                |
| `references/05-i18n-layout.md`   | Quy tắc i18n + Figma MCP + layout SstRow/SstCol                       |

## Chuẩn bị trước: đọc tài liệu thiết kế (bắt buộc・làm đầu tiên)

Khi người dùng đính kèm tài liệu thiết kế, **có trường hợp nội dung không được truyền vào context của đoạn chat**.
Nếu `filePath` của file đính kèm tồn tại thì bắt buộc Read file đó.

Đặc biệt bắt buộc đọc 2 file sau:

1. **基本設計書** (file `.md` trong thư mục thiết kế cơ bản) → layout (link Figma)・項目定義・chuyển màn hình
2. **詳細設計書** (file `.md` trong thư mục thiết kế chi tiết) → định nghĩa sự kiện・khái quát xử lý・mapping tham số API・giá trị mặc định/điều khiển button theo mode

### 詳細設計書 là đầu vào bắt buộc (blocker・cấm sinh code chỉ với 基本設計書)

> **Không bắt đầu triển khai với chức năng không tồn tại 詳細設計書 (`docs/02.詳細設計/**/\*.md`, sản phẩm sinh bởi agent `detail-design-fe`).\*\***
> Nếu chỉ được đưa 基本設計書 thì hãy yêu cầu người dùng tạo・cung cấp 詳細設計書 rồi kết thúc
> (cấm 「vì không có 詳細設計書 nên suy đoán trực tiếp từ 基本設計書 để triển khai」 — vì nguồn gốc của logic sự kiện・tham số API
> không được cấu trúc hóa, dựa vào suy đoán của AI sẽ gây sai lệch đặc tả).

### Phân chia vai trò giữa 基本設計書 và 詳細設計書

| Tài liệu thiết kế | Thông tin phụ trách                                                                                                                                          |
| ---------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 基本設計書 | Layout (link Figma)・項目定義 (thuộc tính như kiểu/số ký tự/bắt buộc/dropdown, v.v.)・chuyển màn hình                                                          |
| 詳細設計書 | Danh sách định nghĩa sự kiện・khái quát xử lý của từng sự kiện (trình tự triển khai)・luồng xử lý・bảng mapping tham số đầu vào・phân nhánh mode (mới/sửa)・khái quát mode xử lý (thiết lập giá trị mặc định/điều khiển button màn hình) |

### Quy tắc phản ánh cấu trúc 詳細設計書 → triển khai

Từng thành phần của 詳細設計書 (format sinh bởi `detail-design-fe`) được đưa vào triển khai theo tương ứng dưới đây.
Không diễn giải theo cách riêng, hãy tuân theo bảng tương ứng này.

| Thành phần của 詳細設計書                                                            | Phản ánh vào triển khai                                                                                                                                                             |
| ----------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Heading `### {tên định nghĩa sự kiện}`                                              | Cho tương ứng với 1 hàm tương ứng trong composable (`search`/`save`/`clear`/`onXxxClick`, v.v.)                                                                                      |
| Các bước có số của `#### 処理概要` (khái quát xử lý)                                 | Triển khai xử lý đúng theo thứ tự các bước (không tự đổi thứ tự・không lược bỏ)                                                                                                      |
| Dòng ghi `共通処理（FW）の場合はイベント定義の記載不要`                              | Vì là hành vi chuẩn của framework nên không cần tự triển khai (giao sự kiện đó cho hành vi FW hiện có)                                                                               |
| Bảng `入力パラメータマッピング` (`パラメータ名`/`項目名`/`取得元`)                   | Quyết định nguồn gốc giá trị của từng field trong object request API. Phân loại của cột `取得元` và tương ứng với code xem 「入力パラメータマッピング → リクエスト実装」 trong `references/04-api-definition.md` |
| Phân nhánh in đậm `**新規モード場合**` / `**編集モード場合**`                        | Triển khai thành phân nhánh `if`/`switch` theo biến mode như `pcsMod` (chi tiết xem `references/03-event-implementation.md`)                                                          |
| Bảng 「初期値設定」 của `##### 処理モード概要` (`項目名`/`初期値`/`入力可/不可`/`備考`) | Phản ánh vào việc set giá trị mặc định khi đổi mode・điều khiển `disabled`/`readonly` của field. Nếu có ghi chú 「未記載項目は基本設計の項目定義に従う」 thì các field không ghi sẽ dùng 項目定義 của 基本設計書 |
| Bảng `画面ボタン制御` (`項目名`/`利用可否`/`備考`)                                   | Phản ánh vào điều khiển `:disabled` (hoặc `v-show`) của button tương ứng                                                                                                             |
| Câu thông báo (`エラーメッセージ「…」を表示する`)                                    | Dùng nguyên văn câu chữ của 基本設計/詳細設計 làm giá trị của key i18n (không tự diễn đạt lại)                                                                                       |

### Kiểm tra marker (🔴🟠) của 詳細設計書 (bắt buộc・blocker)

> Trong 詳細設計書 có gắn marker chỉ ra những chỗ thiếu thông tin:
>
> - `（基本設計に記載なし）🔴【要詳細設計】` … chờ bổ sung từ phía thiết kế chi tiết (mapping đầu vào API・định nghĩa tham số, v.v.)
> - `（基本設計に記載なし）🟠【要基本設計書修正】` … thiếu sót ở phía 基本設計書 (chưa cấp số ID chức năng, v.v.)
> - Nếu trong cùng thư mục có `<機能名>.markers.md` (file sidecar liệt kê marker) thì trước tiên hãy đọc nó để nắm toàn bộ.

**Nếu chỗ đang định triển khai (xử lý sự kiện・tham số API・giá trị mặc định/điều khiển button, v.v.)
có gắn marker 🔴 hoặc 🟠 thì không được suy đoán để triển khai.**
Hãy dừng triển khai, chỉ rõ chỗ đó và hỏi người dùng (cũng cấm tạm triển khai bằng comment TODO rồi đi tiếp).
Những chỗ không gắn marker thì có thể tiếp tục triển khai như bình thường (không cần dừng toàn bộ chức năng).

### Lấy design từ Figma (bắt buộc・blocker)

> **Màn hình frontend chắc chắn có link Figma.**
> Nếu không tìm thấy thì không bắt đầu triển khai, hãy thông báo cho người dùng rồi kết thúc.

Nếu section `## レイアウト` (layout) của 基本設計書 có URL Figma thì
**hãy gọi song song `get_design_context` + `get_screenshot` rồi mới sinh code**.
Chi tiết xem section Figma MCP trong `references/05-i18n-layout.md`.

> **Cấu trúc màn hình (chia tab hay trang đơn, tỉ lệ cột, v.v.) luôn ưu tiên layout Figma thực tế
> hơn ví dụ template trong `references/01-template-structure.md`.** Cấu trúc `SstTabs` của template
> chỉ là ví dụ mặc định; nếu trong Figma không có chuyển tab thì triển khai theo cấu trúc trang đơn.

## Các mục cần xác nhận với người dùng

| Mục                      | Thời điểm xác nhận                           | Ví dụ    |
| ------------------------ | -------------------------------------------- | -------- |
| **★ Số ticket Kanjiro**  | **Luôn xác nhận đầu tiên (không trích được từ tài liệu thiết kế)** | **123**  |
| 大分類 (phân loại lớn)   | Trích tự động từ tài liệu thiết kế           | Web      |
| 中分類 (phân loại trung) | Trích tự động từ tài liệu thiết kế           | Core     |
| 小分類 (phân loại nhỏ)   | Trích tự động từ tài liệu thiết kế           | Xuất hàng |
| Tên chức năng            | Trích tự động từ tài liệu thiết kế           | soMainte |
| ID chức năng             | Trích tự động từ tài liệu thiết kế           | 003      |

## Thông tin đọc từ tài liệu thiết kế

| Mục của tài liệu thiết kế | Mục đích sử dụng                                                 |
| ---------- | ---------------------------------------------------------------- |
| 大分類     | Dựng ID chức năng (ví dụ: Web → `w`). Không xuất hiện trong thư mục |
| 中分類     | Xác định thư mục 中分類 (ví dụ: コア → `core`, chỉ mnemonic)      |
| 小分類     | Xác định thư mục 小分類 (ví dụ: 出荷 → `so`, chỉ mnemonic)        |
| Tên chức năng | Cơ sở cho tên file・tên folder chức năng (lowerCamelCase, không số thứ tự) |
| ID chức năng | Không dùng cho tên thư mục (dùng cho APPKEY・mã message, v.v.)   |

## Cấu trúc thư mục・file

```
{repo}/
├── {menuFile}                                ← Thêm liên kết giữa APPKEY và file vue
└── src/
    ├── api/
    │   └── {thư mục 中分類}/
    │       └── {thư mục 小分類}/
    │           └── {tên chức năng}Api/
    │               ├── {tên chức năng}Api.ts        ← Wrapper API
    │               └── {tên chức năng}ApiType.ts    ← Định nghĩa kiểu API
    └── views/
        └── {thư mục 中分類}/
            └── {thư mục 小分類}/
                └── {tên chức năng}/
                    ├── {tên chức năng}.vue         ← Template
                    ├── use{TênChứcNăngPascal}.ts   ← composable
                    └── {tên chức năng}.types.ts    ← Định nghĩa kiểu tầng View
```

> **Đặt tên thư mục không dùng mã số, thống nhất chỉ dùng mã mnemonic (cũng không thêm số thứ tự).**
> Ví dụ: `040_so` ❌ → `so` ✅, `003_soMainte` ❌ → `soMainte` ✅

### Danh sách thư mục 中分類

Thư mục 中分類 (tài liệu thiết kế → tên thư mục) phải khớp với tên thư mục hiện có dưới `src/views/`.

> Chức năng local không trộn lẫn với `core`/`option` (tách sang thư mục riêng).

### Danh sách thư mục 小分類

Thư mục 小分類 (tài liệu thiết kế → tên thư mục) phải khớp với tên thư mục hiện có dưới thư mục 中分類.

## Thêm vào {menuFile}

```ts
{APPKEY}: {
  name: '{tên hiển thị màn hình}',
  path: '{tên chức năng}',
  url: 'views/{thư mục 中分類}/{thư mục 小分類}/{tên chức năng}/{tên chức năng}.vue',
},
```

## Trình tự triển khai

1. [ ] **Tạo branch làm việc** ← `git checkout -b feature/<tên chức năng>`
2. [ ] Đọc tên chức năng・ID chức năng・大分類・中分類・小分類 từ tài liệu thiết kế
3. [ ] **Kiểm tra marker (🔴🟠) của 詳細設計書** — nếu ở những chỗ cần cho triển khai (xử lý sự kiện・mapping tham số・giá trị mặc định/điều khiển button) có marker chưa giải quyết thì hỏi người dùng tại đây và chỉ đi tiếp sau khi được xác nhận
4. [ ] Lấy URL Figma và gọi song song `get_design_context` + `get_screenshot` — xác nhận cấu trúc là chia tab hay trang đơn. Đồng thời (a) trích toàn bộ các dòng `SstCodeName` trong bảng 項目定義 và ghi lại số lượng `ルックアップ: ✔` (quy tắc #22/#51), (b) nếu có cột audit `add*`/`upd*` mà không thấy `panel.systemInfo` trong mockup màn hình thì xác nhận với người dùng về việc có cần thêm hay không tại đây (quy tắc #53)
5. [ ] Tạo thư mục・file (5 file)
6. [ ] `{tên chức năng}.types.ts` → định nghĩa kiểu
7. [ ] `{tên chức năng}ApiType.ts` → định nghĩa kiểu API
8. [ ] `{tên chức năng}Api.ts` → wrapper API
9. [ ] `use{TênChứcNăngPascal}.ts` → logic
10. [ ] `{tên chức năng}.vue` → template
11. [ ] Thêm APPKEY vào `{menuFile}`
12. [ ] Thêm API client vào `libs/client.ts` (khi cần)
13. [ ] **Kiểm tra・thêm key đa ngữ (bắt buộc・cấm lược bỏ)** — cả 4 ngôn ngữ
14. [ ] **Self-check (quy tắc #50/#51)** — kiểm tra cấu trúc layout của `.vue` đã sinh (chia tab/trang đơn) có khớp Figma không, số lượng `ルックアップ: ✔` đã ghi ở bước 4 và số lần xuất hiện `:iconclick` trong `.vue` có thực sự đếm và khớp không, mọi `SstCodeName` dùng `v-model:name` đã gắn `@retrieve-data` (quy tắc #54) chưa, có lẫn tag native của Vuetify (`<v-xxx>`) không (quy tắc #55)
15. [ ] **Commit source do AI sinh** ← `git commit -m "#<số ticket> [ai] <tên chức năng> 初期生成"`
16. [ ] Build・kiểm tra hoạt động (sửa tay dùng prefix `[manual]`)

## Lưu ý

- **Nghiêm cấm ghi đè lên file hiện có**: nếu đã tồn tại thì phải xác nhận với người dùng rồi mới ghi đè
- **Không được sửa class sinh bởi OpenAPI**: không thay đổi bất cứ gì dưới `node_modules/@sst-cm/fe-web-client`
- **Cấm thêm field không có trong tài liệu thiết kế**: định nghĩa kiểu chỉ theo 項目定義 của tài liệu thiết kế
- **Ưu tiên dùng sstUtil**: `getCurrentDate`, `toString`, v.v. hãy dùng `sstUtil()`, không tự viết logic thay thế
- **Quy ước style button**: tìm kiếm = `color="primary"` + `variant="elevated"`, xóa trắng = `variant="outlined"`, thao tác = `#AFF4C6` (xanh lá), hủy/xóa = `#FCB3AD` (đỏ)
- **Chọn component theo cột thuộc tính của tài liệu thiết kế**: 「số」→ `SstNumberInput`, 「chữ」→ `SstTextField`
- **【Chỉ khi sinh lần đầu】Tạo branch + commit `[ai]`**: với các lần Claude sửa sau lần sinh đầu tiên thì theo luồng thông thường
