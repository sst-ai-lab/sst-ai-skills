# Danh sách FW

==Công khai qua javadoc==

## Ràng buộc validation

### Kiểm tra chuỗi

| Tên ràng buộc     | Mô tả                                              | Thuộc tính chính                                                                | Ví dụ sử dụng                                                            |
| ----------------- | -------------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| @NotBlank         | Kiểm tra field không phải null và không phải rỗng   | message                                                                         | `@NotBlank private String name;`                                         |
| @NotNull          | Kiểm tra field không phải null                      | message                                                                         | `@NotNull private String id;`                                            |
| @Size             | Kiểm tra độ dài chuỗi nằm trong khoảng cho phép     | min, max                                                                        | `@Size(min=3, max=50) private String name;`                              |
| @Pattern          | Kiểm tra chuỗi khớp với biểu thức chính quy          | regexp                                                                          | `@Pattern(regexp="[A-Z0-9]+") private String code;`                      |
| @Email            | Kiểm tra là định dạng địa chỉ email hợp lệ           | message                                                                         | `@Email private String email;`                                           |
| @URL              | Kiểm tra là định dạng URL hợp lệ                     | message                                                                         | `@URL private String website;`                                           |
| @NormalizedString | Kiểm tra dạng chuẩn hóa Unicode                      | form (NFC/NFD/NFKC/NFKD)                                                        | `@NormalizedString(form=NFC) private String text;`                       |
| @Password         | Kiểm tra yêu cầu độ phức tạp của mật khẩu            | minLength, requireUppercase, requireLowercase, requireDigit, requireSpecialChar | `@Password(minLength=8, requireUppercase=true) private String password;` |

### Kiểm tra ngày / ngày giờ

| Tên ràng buộc       | Mô tả                                                          | Thuộc tính chính                  | Ví dụ sử dụng                                                                      |
| ------------------- | -------------------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------- |
| @DateFormat         | Kiểm tra định dạng ngày                                         | pattern                           | `@DateFormat(pattern="yyyy-MM-dd") private String date;`                           |
| @DateTimeFormat     | Kiểm tra định dạng ngày giờ                                     | pattern                           | `@DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss") private String dateTime;`          |
| @MinDate            | Kiểm tra ngày sau giá trị nhỏ nhất                              | value                             | `@MinDate("2024-01-01") private LocalDate date;`                                   |
| @MaxDate            | Kiểm tra ngày trước giá trị lớn nhất                            | value                             | `@MaxDate("2024-12-31") private LocalDate date;`                                   |
| @MinDateTime        | Kiểm tra ngày giờ sau giá trị nhỏ nhất                          | value                             | `@MinDateTime("2024-01-01T00:00:00") private LocalDateTime dateTime;`              |
| @MaxDateTime        | Kiểm tra ngày giờ trước giá trị lớn nhất                        | value                             | `@MaxDateTime("2024-12-31T23:59:59") private LocalDateTime dateTime;`              |
| @PastOrPresent      | Kiểm tra ngày giờ thuộc quá khứ hoặc hiện tại                   | message                           | `@PastOrPresent private LocalDate birthDate;`                                      |
| @FutureOrPresent    | Kiểm tra ngày giờ thuộc tương lai hoặc hiện tại                 | message                           | `@FutureOrPresent private LocalDate eventDate;`                                    |
| @ChronologicalDates | Kiểm tra ngày bắt đầu trước ngày kết thúc (mức class)           | startField, endField              | `@ChronologicalDates(startField="startDate", endField="endDate")`                  |
| @DateWithinInterval | Kiểm tra ngày nằm trong khoảng thời gian (mức class)            | startField, endField, targetField | `@DateWithinInterval(startField="start", endField="end", targetField="milestone")` |

### Kiểm tra số

| Tên ràng buộc | Mô tả                                                | Thuộc tính chính  | Ví dụ sử dụng                                               |
| ----------- | ------------------------------------------------------ | ----------------- | ----------------------------------------------------------- |
| @Digits     | Kiểm tra ràng buộc số chữ số phần nguyên và phần thập phân | integer, fraction | `@Digits(integer=10, fraction=2) private BigDecimal price;` |
| @DecimalMin | Kiểm tra giá trị nhỏ nhất                                | value, inclusive  | `@DecimalMin("0.01") private BigDecimal amount;`            |
| @DecimalMax | Kiểm tra giá trị lớn nhất                                | value, inclusive  | `@DecimalMax("999999.99") private BigDecimal amount;`       |

## Các lớp utility

### Xử lý file

#### FileCsvUtil

Cung cấp chức năng đọc và ghi file CSV.

| Tên method    | Tóm tắt chức năng             | Tham số                                                                                                                                                                                                                       | Giá trị trả về            |
| ------------- | ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| parse         | Phân tích CSV thành danh sách DTO | `(1) inputStream: InputStream` - File CSV<br>`(2) clazz: Class<T>` - Lớp DTO<br>`(3) schema: CsvSchema` - Schema (có thể bỏ qua)<br>`(4) charset: Charset` - Bộ mã ký tự (có thể bỏ qua, mặc định UTF-8) | `List<T>` - Danh sách DTO     |
| write         | Ghi danh sách DTO ra CSV | `(1) data: List<T>` - Danh sách DTO<br>`(2) clazz: Class<T>` - Lớp DTO<br>`(3) schema: CsvSchema` - Schema (có thể bỏ qua)<br>`(4) charset: Charset` - Bộ mã ký tự (có thể bỏ qua)                               | `byte[]` - Mảng byte CSV  |
| defaultSchema | Lấy schema mặc định | `(1) clazz: Class<T>` - Lớp DTO                                                                                                                                                                                                   | `CsvSchema` - Schema CSV |

#### FilePdfUtil

Cung cấp chức năng xử lý PDF (trích xuất, ghép, tách).

| Tên method       | Tóm tắt chức năng    | Tham số                                                                                                      | Giá trị trả về                       |
| ---------------- | -------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| extractPages     | Trích xuất trang cụ thể | `(1) pdfBytes: byte[]` - Dữ liệu PDF gốc<br>`(2) pageNumbers: List<Integer>` - Danh sách số trang (bắt đầu từ 1)       | `byte[]` - PDF đã trích xuất             |
| extractPageRange | Trích xuất khoảng trang | `(1) pdfBytes: byte[]` - Dữ liệu PDF gốc<br>`(2) startPage: int` - Trang bắt đầu<br>`(3) endPage: int` - Trang kết thúc | `byte[]` - PDF đã trích xuất             |
| mergePdfs        | Ghép nhiều PDF        | `(1) pdfs: List<byte[]>` - Danh sách dữ liệu PDF                                                                   | `byte[]` - PDF đã ghép             |
| splitIntoPages   | Tách PDF theo từng trang | `(1) pdfBytes: byte[]` - Dữ liệu PDF                                                                           | `List<byte[]>` - Danh sách PDF của từng trang |
| getPageCount     | Lấy số trang       | `(1) pdfBytes: byte[]` - Dữ liệu PDF                                                                           | `int` - Số trang                     |
| isValidPdf       | Kiểm tra định dạng PDF        | `(1) pdfBytes: byte[]` - Dữ liệu PDF                                                                           | `boolean` - true nếu hợp lệ           |

#### FileImageUtil

Cung cấp chức năng xử lý ảnh (đổi kích thước, nén, ảnh thu nhỏ).

| Tên method         | Tóm tắt chức năng | Tham số                                                                                                                                | Giá trị trả về                |
| ------------------ | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| resize             | Đổi kích thước ảnh   | `(1) imageBytes: byte[]` - Dữ liệu ảnh<br>`(2) width: int` - Chiều rộng<br>`(3) height: int` - Chiều cao<br>`(4) mode: ResizeModeEnum` - Chế độ đổi kích thước | `byte[]` - Ảnh đã đổi kích thước |
| createThumbnail    | Tạo ảnh thu nhỏ | `(1) imageBytes: byte[]` - Dữ liệu ảnh<br>`(2) size: int` - Kích thước ảnh thu nhỏ                                                               | `byte[]` - Ảnh thu nhỏ     |
| compress           | Nén ảnh       | `(1) imageBytes: byte[]` - Dữ liệu ảnh<br>`(2) quality: float` - Chất lượng (0.0-1.0)                                                           | `byte[]` - Ảnh đã nén     |
| getImageDimensions | Lấy kích thước ảnh | `(1) imageBytes: byte[]` - Dữ liệu ảnh                                                                                                     | `Dimension` - Chiều rộng và chiều cao        |

Chế độ đổi kích thước: `FIT` (giữ tỉ lệ khung hình, nằm trong khung), `FILL` (giữ tỉ lệ khung hình, lấp đầy khung), `EXACT` (đúng kích thước)

#### FileTabularUtil

Cung cấp chức năng xử lý file tích hợp CSV và Excel.

| Tên method | Tóm tắt chức năng             | Tham số                                                                                                                                       | Giá trị trả về            |
| ---------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------- |
| parseAuto  | Tự động nhận dạng và phân tích CSV/Excel  | `(1) inputStream: InputStream` - File<br>`(2) clazz: Class<T>` - Lớp DTO<br>`(3) fileType: TabularFileTypeEnum` - Loại file (có thể bỏ qua) | `List<T>` - Danh sách DTO     |
| write      | Ghi danh sách DTO ra file | `(1) data: List<T>` - Danh sách DTO<br>`(2) clazz: Class<T>` - Lớp DTO<br>`(3) fileType: TabularFileTypeEnum` - Loại file                     | `byte[]` - Dữ liệu file |

Loại file: `CSV`, `XLS` (Excel 97-2003), `XLSX` (Excel 2007 trở lên)

#### FileZipUtil

Cung cấp chức năng xử lý file nén ZIP.

| Tên method  | Tóm tắt chức năng         | Tham số                                                    | Giá trị trả về                                     |
| ----------- | ------------------------- | ------------------------------------------------------------- | -------------------------------------------------- |
| zip         | Nén file thành ZIP       | `(1) files: Map<String, byte[]>` - Map tên file và dữ liệu | `byte[]` - Dữ liệu nén ZIP                           |
| unzip       | Giải nén file ZIP       | `(1) zipBytes: byte[]` - Dữ liệu ZIP                            | `Map<String, byte[]>` - Map tên file và dữ liệu |
| listEntries | Lấy danh sách file trong ZIP | `(1) zipBytes: byte[]` - Dữ liệu ZIP                            | `List<String>` - Danh sách tên file                  |

### Utility mở rộng

#### StringExtension

Cung cấp các method mở rộng cho xử lý chuỗi.

| Phân loại        | Tên method           | Tóm tắt chức năng                | Tham số                                                                                                                      | Giá trị trả về |
| ---------------- | -------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Padding       | leftPad              | Thêm ký tự chỉ định vào bên trái       | `(1) str: String` - Chuỗi đích<br>`(2) size: int` - Kích thước cuối cùng<br>`(3) padChar: char/String` - Ký tự padding                   | `String`   |
| Padding       | rightPad             | Thêm ký tự chỉ định vào bên phải       | `(1) str: String` - Chuỗi đích<br>`(2) size: int` - Kích thước cuối cùng<br>`(3) padChar: char/String` - Ký tự padding                   | `String`   |
| Padding       | leftPadByCount       | Thêm padding vào bên trái theo số lần chỉ định         | `(1) str: String` - Chuỗi đích<br>`(2) count: int` - Số lần padding<br>`(3) padStr: String` - Chuỗi padding                  | `String`   |
| Nối / tách       | join                 | Nối chuỗi (không có ký tự phân tách)       | `(1) ...strings: String[]` - Mảng chuỗi                                                                                         | `String`   |
| Nối / tách       | joinWith             | Nối chuỗi có ký tự phân tách     | `(1) delimiter: String` - Ký tự phân tách<br>`(2) ...strings: String[]` - Mảng chuỗi                                                 | `String`   |
| Nối / tách       | split                | Tách chuỗi                     | `(1) str: String` - Chuỗi đích<br>`(2) delimiter: String/char` - Ký tự phân tách                                                     | `String[]` |
| Chuỗi con       | substringBefore      | Lấy phần trước ký tự phân tách           | `(1) str: String` - Chuỗi đích<br>`(2) separator: String` - Ký tự phân tách                                                          | `String`   |
| Chuỗi con       | substringAfter       | Lấy phần sau ký tự phân tách           | `(1) str: String` - Chuỗi đích<br>`(2) separator: String` - Ký tự phân tách                                                          | `String`   |
| Chuỗi con       | substringBeforeLast  | Lấy phần trước ký tự phân tách cuối cùng     | `(1) str: String` - Chuỗi đích<br>`(2) separator: String` - Ký tự phân tách                                                          | `String`   |
| Chuỗi con       | substringAfterLast   | Lấy phần sau ký tự phân tách cuối cùng     | `(1) str: String` - Chuỗi đích<br>`(2) separator: String` - Ký tự phân tách                                                          | `String`   |
| Chuỗi con       | mid                  | Lấy chuỗi con theo vị trí chỉ định       | `(1) str: String` - Chuỗi đích<br>`(2) pos: int` - Vị trí bắt đầu<br>`(3) len: int` - Độ dài                                            | `String`   |
| Kiểm tra loại ký tự   | isNull               | Kiểm tra là null hoặc chuỗi rỗng         | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isNotNull            | Kiểm tra không phải null và không phải chuỗi rỗng   | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isBlank              | Kiểm tra là null hoặc chỉ gồm khoảng trắng         | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isNotBlank           | Kiểm tra không phải null và không chỉ gồm khoảng trắng   | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isNumeric            | Kiểm tra chỉ gồm chữ số                   | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isAlpha              | Kiểm tra chỉ gồm chữ cái                   | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isAlphanumeric       | Kiểm tra chỉ gồm chữ và số                 | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isHalfWidth          | Kiểm tra chỉ gồm ký tự nửa chiều rộng               | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Kiểm tra loại ký tự   | isFullWidth          | Kiểm tra chỉ gồm ký tự toàn chiều rộng               | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Chuyển đổi độ rộng           | toHalfwidth          | Chuyển ký tự toàn chiều rộng sang nửa chiều rộng             | `(1) str: String` - Chuỗi đích                                                                                                  | `String`   |
| Chuyển đổi độ rộng           | toFullwidth          | Chuyển ký tự nửa chiều rộng sang toàn chiều rộng             | `(1) str: String` - Chuỗi đích                                                                                                  | `String`   |
| Masking       | maskAll              | Mask toàn bộ                     | `(1) str: String` - Chuỗi đích<br>`(2) maskChar: char` - Ký tự mask                                                             | `String`   |
| Masking       | maskAllButLast       | Mask tất cả trừ N ký tự cuối          | `(1) str: String` - Chuỗi đích<br>`(2) visibleCount: int` - Số ký tự hiển thị<br>`(3) maskChar: char` - Ký tự mask                     | `String`   |
| Masking       | maskRange            | Mask khoảng chỉ định                 | `(1) str: String` - Chuỗi đích<br>`(2) start: int` - Vị trí bắt đầu<br>`(3) end: int` - Vị trí kết thúc<br>`(4) maskChar: char` - Ký tự mask | `String`   |
| Encoding | shiftJisToUtf8       | Chuyển từ Shift_JIS sang UTF-8         | `(1) str: String` - Chuỗi đích                                                                                                  | `String`   |
| Encoding | utf8ToShiftJis       | Chuyển từ UTF-8 sang Shift_JIS         | `(1) str: String` - Chuỗi đích                                                                                                  | `String`   |
| Encoding | convertEncoding      | Chuyển đổi bộ mã ký tự                 | `(1) str: String` - Chuỗi đích<br>`(2) from: Charset` - Nguồn chuyển đổi<br>`(3) to: Charset` - Đích chuyển đổi                                    | `String`   |
| Validation   | isEmail              | Kiểm tra là định dạng địa chỉ email         | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Validation   | isUrl                | Kiểm tra là định dạng URL                    | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Validation   | isPhoneNumber        | Kiểm tra là định dạng số điện thoại               | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Validation   | isPostalCode         | Kiểm tra là định dạng mã bưu chính               | `(1) str: String` - Chuỗi đích                                                                                                  | `boolean`  |
| Validation   | matchesPattern       | Kiểm tra có khớp biểu thức chính quy | `(1) str: String` - Chuỗi đích<br>`(2) pattern: String` - Biểu thức chính quy                                                              | `boolean`  |
| Validation   | hasLengthBetween     | Kiểm tra độ dài chuỗi nằm trong khoảng           | `(1) str: String` - Chuỗi đích<br>`(2) min: int` - Độ dài nhỏ nhất<br>`(3) max: int` - Độ dài lớn nhất                                            | `boolean`  |
| Validation   | hasByteLengthBetween | Kiểm tra độ dài byte nằm trong khoảng           | `(1) str: String` - Chuỗi đích<br>`(2) min: int` - Độ dài byte nhỏ nhất<br>`(3) max: int` - Độ dài byte lớn nhất                                | `boolean`  |

#### BigDecimalExtension

Cung cấp các method mở rộng cho xử lý số.

| Tên method              | Tóm tắt chức năng                   | Tham số                                                                                           | Giá trị trả về |
| ----------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------ |
| sum                     | Tính tổng nhiều giá trị (null được coi là 0) | `(1) ...values: BigDecimal[]` - Mảng số                                                             | `BigDecimal` |
| within                  | Kiểm tra giá trị nằm trong khoảng                    | `(1) value: BigDecimal` - Giá trị đích<br>`(2) min: BigDecimal` - Giá trị nhỏ nhất<br>`(3) max: BigDecimal` - Giá trị lớn nhất | `boolean`    |
| outside                 | Kiểm tra giá trị nằm ngoài khoảng                    | `(1) value: BigDecimal` - Giá trị đích<br>`(2) min: BigDecimal` - Giá trị nhỏ nhất<br>`(3) max: BigDecimal` - Giá trị lớn nhất | `boolean`    |
| difference              | Lấy hiệu của 2 giá trị                     | `(1) left: BigDecimal` - Giá trị 1<br>`(2) right: BigDecimal` - Giá trị 2                                        | `BigDecimal` |
| isInteger               | Kiểm tra là số nguyên                          | `(1) value: BigDecimal` - Giá trị đích                                                                     | `boolean`    |
| isDecimal               | Kiểm tra có phần thập phân                  | `(1) value: BigDecimal` - Giá trị đích                                                                     | `boolean`    |
| isZero                  | Kiểm tra bằng 0                          | `(1) value: BigDecimal` - Giá trị đích                                                                     | `boolean`    |
| roundHalfUp             | Làm tròn nửa lên                            | `(1) value: BigDecimal` - Giá trị đích<br>`(2) scale: int` - Số chữ số thập phân                                      | `BigDecimal` |
| roundUp                 | Làm tròn lên                            | `(1) value: BigDecimal` - Giá trị đích<br>`(2) scale: int` - Số chữ số thập phân                                      | `BigDecimal` |
| roundDown               | Làm tròn xuống                            | `(1) value: BigDecimal` - Giá trị đích<br>`(2) scale: int` - Số chữ số thập phân                                      | `BigDecimal` |
| getIntegerDigitCount    | Lấy số chữ số phần nguyên                  | `(1) value: BigDecimal` - Giá trị đích                                                                     | `int`        |
| getFractionalDigitCount | Lấy số chữ số phần thập phân                  | `(1) value: BigDecimal` - Giá trị đích                                                                     | `int`        |

#### LocalDateExtension

Cung cấp các method mở rộng cho xử lý ngày.

| Tên method     | Tóm tắt chức năng       | Tham số                                                                                           | Giá trị trả về |
| -------------- | ----------------------- | ---------------------------------------------------------------------------------------------------- | --------- |
| within         | Kiểm tra ngày nằm trong khoảng      | `(1) date: LocalDate` - Ngày đích<br>`(2) start: LocalDate` - Ngày bắt đầu<br>`(3) end: LocalDate` - Ngày kết thúc | `boolean` |
| outside        | Kiểm tra ngày nằm ngoài khoảng      | `(1) date: LocalDate` - Ngày đích<br>`(2) start: LocalDate` - Ngày bắt đầu<br>`(3) end: LocalDate` - Ngày kết thúc | `boolean` |
| withinDays     | Kiểm tra có trong N ngày kể từ ngày cơ sở | `(1) base: LocalDate` - Ngày cơ sở<br>`(2) target: LocalDate` - Ngày đích<br>`(3) days: int` - Số ngày         | `boolean` |
| withinMonths   | Kiểm tra có trong N tháng kể từ ngày cơ sở | `(1) base: LocalDate` - Ngày cơ sở<br>`(2) target: LocalDate` - Ngày đích<br>`(3) months: int` - Số tháng       | `boolean` |
| withinYears    | Kiểm tra có trong N năm kể từ ngày cơ sở | `(1) base: LocalDate` - Ngày cơ sở<br>`(2) target: LocalDate` - Ngày đích<br>`(3) years: int` - Số năm        | `boolean` |
| isBusinessDay  | Kiểm tra là ngày làm việc (ngày thường)    | `(1) date: LocalDate` - Ngày đích<br>`(2) holidays: Set<LocalDate>` - Tập ngày lễ (có thể bỏ qua)              | `boolean` |
| isStartOfMonth | Kiểm tra là ngày đầu tháng            | `(1) date: LocalDate` - Ngày đích                                                                       | `boolean` |
| isEndOfMonth   | Kiểm tra là ngày cuối tháng            | `(1) date: LocalDate` - Ngày đích                                                                       | `boolean` |
| toString       | Định dạng thành chuỗi    | `(1) date: LocalDate` - Ngày đích<br>`(2) pattern: String/DateTimeFormatter` - Định dạng (có thể bỏ qua)   | `String`  |

#### LocalTimeExtension

Cung cấp các method mở rộng cho xử lý thời gian.

| Tên method      | Tóm tắt chức năng                           | Tham số                                                                                               | Giá trị trả về |
| --------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------- | --------- |
| within          | Kiểm tra thời gian nằm trong khoảng (hỗ trợ qua nửa đêm) | `(1) time: LocalTime` - Thời gian đích<br>`(2) start: LocalTime` - Thời gian bắt đầu<br>`(3) end: LocalTime` - Thời gian kết thúc | `boolean` |
| outside         | Kiểm tra thời gian nằm ngoài khoảng                 | `(1) time: LocalTime` - Thời gian đích<br>`(2) start: LocalTime` - Thời gian bắt đầu<br>`(3) end: LocalTime` - Thời gian kết thúc | `boolean` |
| diffHours       | Lấy chênh lệch giờ                       | `(1) start: LocalTime` - Thời gian bắt đầu<br>`(2) end: LocalTime` - Thời gian kết thúc                                     | `long`    |
| diffMinutes     | Lấy chênh lệch phút                         | `(1) start: LocalTime` - Thời gian bắt đầu<br>`(2) end: LocalTime` - Thời gian kết thúc                                     | `long`    |
| diffSeconds     | Lấy chênh lệch giây                         | `(1) start: LocalTime` - Thời gian bắt đầu<br>`(2) end: LocalTime` - Thời gian kết thúc                                     | `long`    |
| isCrossMidnight | Kiểm tra khoảng thời gian có vắt qua nửa đêm             | `(1) start: LocalTime` - Thời gian bắt đầu<br>`(2) end: LocalTime` - Thời gian kết thúc                                     | `boolean` |
| toString        | Định dạng thành chuỗi               | `(1) time: LocalTime` - Thời gian đích<br>`(2) pattern: String/DateTimeFormatter` - Định dạng (có thể bỏ qua)     | `String`  |

#### LocalDateTimeExtension

Cung cấp các method mở rộng cho xử lý ngày giờ.

| Tên method | Tóm tắt chức năng     | Tham số                                                                                                               | Giá trị trả về |
| ---------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| within     | Kiểm tra ngày giờ nằm trong khoảng   | `(1) dateTime: LocalDateTime` - Ngày giờ đích<br>`(2) start: LocalDateTime` - Ngày giờ bắt đầu<br>`(3) end: LocalDateTime` - Ngày giờ kết thúc | `boolean` |
| outside    | Kiểm tra ngày giờ nằm ngoài khoảng   | `(1) dateTime: LocalDateTime` - Ngày giờ đích<br>`(2) start: LocalDateTime` - Ngày giờ bắt đầu<br>`(3) end: LocalDateTime` - Ngày giờ kết thúc | `boolean` |
| toString   | Định dạng thành chuỗi | `(1) dateTime: LocalDateTime` - Ngày giờ đích<br>`(2) pattern: String/DateTimeFormatter` - Định dạng (có thể bỏ qua)             | `String`  |

### Bảo mật

#### SqlInputSanitizer

Cung cấp chức năng làm sạch (sanitize) và kiểm tra dữ liệu đầu vào SQL.

| Tên method         | Tóm tắt chức năng       | Tham số                            | Giá trị trả về |
| ------------------ | ----------------------- | ---------------------------------- | --------- |
| escapeSql          | Escape các ký tự đặc biệt của SQL | `(1) input: String` - Chuỗi đầu vào   | `String`  |
| isValidIdentifier  | Kiểm tra là identifier SQL hợp lệ   | `(1) identifier: String` - Identifier  | `boolean` |
| sanitizeIdentifier | Kiểm tra và lấy identifier      | `(1) identifier: String` - Identifier  | `String`  |
| isValidOrderBy     | Kiểm tra là mệnh đề ORDER BY hợp lệ  | `(1) orderBy: String` - Mệnh đề ORDER BY | `boolean` |
| isValidLimit       | Kiểm tra là giá trị LIMIT hợp lệ     | `(1) limit: String` - Giá trị LIMIT      | `boolean` |

!!! warning "Quan trọng"
Việc sanitize SQL là phương án cuối cùng. Hãy sử dụng truy vấn tham số hóa (parameterized query) bất cứ khi nào có thể.

#### OutputMasker

Cung cấp chức năng masking giá trị đầu ra.

| Tên method      | Tóm tắt chức năng            | Tham số                                                                                                             | Giá trị trả về |
| --------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------- |
| maskEmail       | Mask địa chỉ email       | `(1) email: String` - Địa chỉ email                                                                                   | `String` |
| maskPhoneNumber | Mask số điện thoại             | `(1) phone: String` - Số điện thoại                                                                                         | `String` |
| maskCreditCard  | Mask số thẻ tín dụng | `(1) cardNumber: String` - Số thẻ                                                                                  | `String` |
| maskPartial     | Mask một phần               | `(1) value: String` - Chuỗi đích<br>`(2) visibleStart: int` - Số ký tự hiển thị ở đầu<br>`(3) visibleEnd: int` - Số ký tự hiển thị ở cuối | `String` |

#### UrlValidator

Cung cấp chức năng kiểm tra URL.

| Tên method        | Tóm tắt chức năng                          | Tham số                                                                        | Giá trị trả về |
| ----------------- | --------------------------------- | --------------------------------------------------------------------------------- | --------- |
| isValid           | Kiểm tra là URL hợp lệ                   | `(1) url: String` - Chuỗi URL                                                     | `boolean` |
| isValidWithScheme | Kiểm tra là URL có scheme chỉ định           | `(1) url: String` - Chuỗi URL<br>`(2) allowedSchemes: Set<String>` - Scheme được phép | `boolean` |
| isSafeUrl         | Kiểm tra là URL an toàn (whitelist) | `(1) url: String` - Chuỗi URL<br>`(2) allowedHosts: Set<String>` - Host được phép     | `boolean` |

#### RequestContext / RequestContextHolder

Lưu giữ thông tin người dùng và các thuộc tính theo từng request. `RequestContext` (`com.fw.core.dto`) là vật chứa, `RequestContextHolder` (`com.fw.grpc.core.dto`) là cửa lấy dữ liệu từ context của gRPC.

`RequestContext`

| Tên method     | Tóm tắt chức năng    | Tham số                                                     | Giá trị trả về         |
| -------------- | -------------------- | ----------------------------------------------------------- | ---------------------- |
| getUser        | Lấy thông tin người dùng   | Không có                                                        | `SecurityUserDto`      |
| setUser        | Thiết lập thông tin người dùng   | `(1) user: SecurityUserDto` - Thông tin người dùng                   | `void`                 |
| getAttribute   | Lấy thuộc tính           | `(1) name: String` - Tên thuộc tính                                 | `Object`               |
| setAttribute   | Thiết lập thuộc tính           | `(1) name: String` - Tên thuộc tính<br>`(2) value: Object` - Giá trị      | `void`                 |
| getAttributes  | Lấy danh sách thuộc tính       | Không có                                                        | `Map<String, Object>`  |

`RequestContextHolder` (static. Chỉ dùng được ở phía server / client gRPC)

| Tên method   | Tóm tắt chức năng                                      | Tham số                                             | Giá trị trả về   |
| ------------ | --------------------------------------------- | ------------------------------------------------------ | ---------------- |
| getContext   | Lấy `RequestContext` hiện tại (null nếu không có) | Không có                                                   | `RequestContext` |
| getAttribute | Lấy thuộc tính                                    | `(1) name: String` - Tên thuộc tính                            | `Object`         |
| setAttribute | Thiết lập thuộc tính                                    | `(1) name: String` - Tên thuộc tính<br>`(2) value: Object` - Giá trị | `void`           |

Ở BFF (phía HTTP) không có context của gRPC, nên thông tin xác thực được lấy từ `SecurityContextHolder` của Spring Security.

### Event streaming

#### EventStreamHub

Cung cấp các chức năng cốt lõi của event streaming.

| Tên method          | Tóm tắt chức năng           | Tham số                                                                                                                                | Giá trị trả về           |
| ------------------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| publish             | Phát hành event     | `(1) envelope: EventEnvelope<T>` - Event                                                                               | `void`                   |
| subscribe           | Đăng ký (subscribe) stream   | `(1) streamId: String` - ID của stream<br>`(2) consumer: Consumer<EventEnvelope<T>>` - Consumer                                        | `Disposable`             |
| subscribeWithReplay | Đăng ký kèm replay | `(1) streamId: String` - ID của stream<br>`(2) consumer: Consumer<EventEnvelope<T>>` - Consumer<br>`(3) replayCount: int` - Số lượng replay | `Disposable`             |
| unsubscribe         | Hủy đăng ký         | `(1) disposable: Disposable` - Subscription                                                                         | `void`                   |
| getBuffer           | Lấy buffer     | `(1) streamId: String` - ID của stream                                                                                     | `List<EventEnvelope<T>>` |

#### EventEnvelope

Xây dựng event envelope.

| Tên method | Tóm tắt chức năng       | Tham số                                                                | Giá trị trả về            |
| ---------- | -------------- | ------------------------------------------------------------------------- | ------------------------- |
| builder    | Tạo builder | `(1) eventId: UUID` - ID của event<br>`(2) streamId: String` - ID của stream | `EventEnvelopeBuilder<T>` |

Các method của builder: `payload(T)`, `source(String)`, `stage(String)`, `occurredAt(OffsetDateTime)`, `attributes(Map<String, Object>)`, `build()`

## Các lớp exception

### Exception dựa trên HTTP status

| Lớp exception                  | HTTP status | Mô tả                   | Constructor                                                                  |
| --------------------------- | -------------- | ---------------------- | ------------------------------------------------------------------------------- |
| BadRequestException         | 400            | Request không hợp lệ       | `(errorCode)`, `(errorCode, args)`, `(errorCode, cause)`, `(errorCode, errors)` |
| UnauthorizedException       | 401            | Cần xác thực             | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ForbiddenException          | 403            | Từ chối truy cập           | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| NotFoundException           | 404            | Không tìm thấy tài nguyên | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ConflictException           | 409            | Xung đột tài nguyên           | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| TooManyRequestsException    | 429            | Vượt giới hạn tần suất         | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ServerErrorException        | 500            | Lỗi nội bộ server     | `()`, `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                  |
| ServiceUnavailableException | 503            | Dịch vụ không khả dụng       | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |

### Exception đặc biệt

| Lớp exception                     | Mô tả                                             | Trường hợp sử dụng                               |
| ------------------------------ | ------------------------------------------------ | -------------------------------------- |
| InvalidRequestPayloadException | Payload của request không hợp lệ (kèm chi tiết field) | Khi validation của request body thất bại |
| CsvProcessingException         | Lỗi xử lý CSV                                    | Khi đọc / ghi CSV thất bại            |
| ImageProcessingException       | Lỗi xử lý ảnh                                   | Khi đổi kích thước / nén ảnh thất bại               |

## Mã lỗi

Cung cấp hệ thống mã lỗi được chuẩn hóa (định dạng `EB-001-XXX-XXX-XXX`).

| Phân loại       | Mã lỗi              | Mô tả                       |
| -------------- | ------------------------- | -------------------------- |
| Request     | REQUEST_PARAMETER_INVALID | Tham số request không hợp lệ |
| Request     | REQUEST_BODY_INVALID      | Body của request không hợp lệ     |
| Request     | REQUEST_HEADER_INVALID    | Header của request không hợp lệ   |
| Xác thực / phân quyền     | AUTHENTICATION_REQUIRED   | Cần xác thực                 |
| Xác thực / phân quyền     | AUTHENTICATION_FAILED     | Xác thực thất bại                 |
| Xác thực / phân quyền     | AUTHORIZATION_FAILED      | Phân quyền thất bại                 |
| Tài nguyên       | RESOURCE_NOT_FOUND        | Không tìm thấy tài nguyên     |
| Tài nguyên       | RESOURCE_CONFLICT         | Tài nguyên bị xung đột             |
| Tài nguyên       | RESOURCE_ALREADY_EXISTS   | Tài nguyên đã tồn tại         |
| Validation | VALIDATION_ERROR          | Lỗi validation       |
| Validation | FIELD_REQUIRED            | Field bắt buộc chưa được nhập     |
| Validation | FIELD_INVALID             | Giá trị của field không hợp lệ       |
| Hệ thống       | INTERNAL_SERVER_ERROR     | Lỗi nội bộ server     |
| Hệ thống       | SERVICE_UNAVAILABLE       | Dịch vụ không khả dụng         |

## Hỗ trợ đa quốc tế hóa

Hỗ trợ đa ngôn ngữ cho các thông báo lỗi.

- Tiếng Anh (mặc định): `messages.properties`
- Tiếng Nhật: `messages-ja-jp.properties`

## Các lớp DTO

### SecurityUserDto

| Field  | Kiểu          | Mô tả           |
| ----------- | ----------- | -------------- |
| userId      | String      | ID người dùng     |
| username    | String      | Tên người dùng     |
| email       | String      | Địa chỉ email |
| roles       | Set<String> | Role         |
| authorities | Set<String> | Quyền         |

### RequestContext

| Field | Kiểu     | Mô tả         |
| ---------- | ------ | ------------ |
| requestId  | String | ID của request |
| tenantId   | String | ID của tenant   |
| locale     | Locale | Locale     |
| timezone   | ZoneId | Múi giờ |

### ListResponse<T>

| Field | Kiểu                   | Mô tả         |
| ---------- | -------------------- | ------------ |
| items      | List<T>              | Danh sách dữ liệu |
| metadata   | ListResponseMetadata | Metadata   |

### ListResponseMetadata

| Field | Kiểu   | Mô tả             |
| ---------- | ---- | ---------------- |
| page       | int  | Số trang hiện tại |
| size       | int  | Kích thước trang     |
| total      | long | Tổng số bản ghi       |
| totalPages | int  | Tổng số trang     |

---

# Ví dụ sử dụng

## FileCsvUtil

```java
// CSVファイルの読み取り
List<UserDto> users = FileCsvUtil.parse(inputStream, UserDto.class, null, null);

// CSVファイルの書き込み
byte[] csvBytes = FileCsvUtil.write(users, UserDto.class, null, null);

// カスタムスキーマを使用
CsvSchema schema = CsvSchema.builder().setUseHeader(true).setColumnSeparator(',').build();

List<UserDto> users = FileCsvUtil.parse(inputStream, UserDto.class, schema, StandardCharsets.UTF_8);
```

## FilePdfUtil

```java
// 特定ページの抽出
byte[] extracted = FilePdfUtil.extractPages(pdfBytes, List.of(1, 3, 5));

// ページ範囲の抽出
byte[] range = FilePdfUtil.extractPageRange(pdfBytes, 2, 5);

// 複数PDFの結合
byte[] merged = FilePdfUtil.mergePdfs(List.of(pdf1, pdf2, pdf3));

// PDFを1ページずつ分割
List<byte[]> pages = FilePdfUtil.splitIntoPages(pdfBytes);

// ページ数の取得
int pageCount = FilePdfUtil.getPageCount(pdfBytes);
```

## FileImageUtil

```java
// 画像のリサイズ
byte[] resized = FileImageUtil.resize(imageBytes, 800, 600, ResizeModeEnum.FIT);

// サムネイルの作成
byte[] thumbnail = FileImageUtil.createThumbnail(imageBytes, 150);

// 画像の圧縮
byte[] compressed = FileImageUtil.compress(imageBytes, 0.8f);

// 画像サイズの取得
Dimension size = FileImageUtil.getImageDimensions(imageBytes);
```

## FileTabularUtil

```java
// CSV・Excelの自動判別読み取り
List<UserDto> users = FileTabularUtil.parseAuto(inputStream, UserDto.class, null);

// Excelファイルへの書き込み
byte[] excelBytes = FileTabularUtil.write(users, UserDto.class, TabularFileTypeEnum.XLSX);
```

## FileZipUtil

```java
// ZIP圧縮
Map<String, byte[]> files = Map.of("file1.txt", data1, "file2.txt", data2);

byte[] zipBytes = FileZipUtil.zip(files);

// ZIP解凍
Map<String, byte[]> extractedFiles = FileZipUtil.unzip(zipBytes);

// ファイル一覧の取得
List<String> fileNames = FileZipUtil.listEntries(zipBytes);
```

## StringExtension

```java
// パディング
String padded = StringExtension.leftPad("123", 5, '0'); // "00123"

// 結合・分割
String joined = StringExtension.joinWith(",", "A", "B", "C"); // "A,B,C"

String[] parts = StringExtension.split("A,B,C", ","); // ["A", "B", "C"]

// 部分文字列
String before = StringExtension.substringBefore("id=123", "="); // "id"

String after = StringExtension.substringAfter("id=123", "="); // "123"

// 文字種チェック
boolean isNum = StringExtension.isNumeric("12345"); // true

boolean isAlpha = StringExtension.isAlpha("Hello"); // true

// 幅変換
String half = StringExtension.toHalfwidth("ＡＢＣ"); // "ABC"

// マスキング
String masked = StringExtension.maskAllButLast("1234567890", 4, '*'); // "******7890"

// バリデーション
boolean isEmail = StringExtension.isEmail("test@example.com"); // true
```

## BigDecimalExtension

```java
// 合計
BigDecimal total = BigDecimalExtension.sum(
  new BigDecimal("10.50"),
  new BigDecimal("20.25"),
  null, // 0として扱われる
  new BigDecimal("5.75")
); // 36.50

// 範囲判定
boolean inRange = BigDecimalExtension.within(new BigDecimal("5.50"), new BigDecimal("0.01"), new BigDecimal("100.00")); // true

// 四捨五入
BigDecimal rounded = BigDecimalExtension.roundHalfUp(new BigDecimal("123.456"), 2); // 123.46

// 型チェック
boolean isInt = BigDecimalExtension.isInteger(new BigDecimal("42")); // true

boolean hasDecimal = BigDecimalExtension.isDecimal(new BigDecimal("42.50")); // true
```

## LocalDateExtension

```java
// 範囲判定
boolean inRange = LocalDateExtension.within(
  LocalDate.of(2024, 6, 15),
  LocalDate.of(2024, 1, 1),
  LocalDate.of(2024, 12, 31)
); // true

// 相対範囲判定
boolean withinDays = LocalDateExtension.withinDays(LocalDate.of(2024, 6, 15), LocalDate.of(2024, 6, 20), 30); // true

// 営業日判定
Set<LocalDate> holidays = Set.of(LocalDate.of(2024, 12, 25));

boolean isBusiness = LocalDateExtension.isBusinessDay(LocalDate.of(2024, 12, 25), holidays); // false

// 月末判定
boolean isEnd = LocalDateExtension.isEndOfMonth(LocalDate.of(2024, 2, 29)); // true
```

## LocalTimeExtension

```java
// 範囲判定（通常）
boolean inRange = LocalTimeExtension.within(LocalTime.of(14, 30), LocalTime.of(9, 0), LocalTime.of(17, 0)); // true

// 範囲判定（深夜跨ぎ）
boolean inRangeNight = LocalTimeExtension.within(
  LocalTime.of(2, 0), // 2 AM
  LocalTime.of(22, 0), // 10 PM
  LocalTime.of(6, 0) // 6 AM
); // true

// 時間差取得
long hours = LocalTimeExtension.diffHours(LocalTime.of(9, 0), LocalTime.of(17, 30)); // 8

// 深夜跨ぎ判定
boolean crosses = LocalTimeExtension.isCrossMidnight(LocalTime.of(22, 0), LocalTime.of(6, 0)); // true
```

## LocalDateTimeExtension

```java
// 範囲判定
boolean inRange = LocalDateTimeExtension.within(
  LocalDateTime.of(2024, 6, 15, 14, 30),
  LocalDateTime.of(2024, 1, 1, 0, 0),
  LocalDateTime.of(2024, 12, 31, 23, 59)
); // true

// フォーマット
String formatted = LocalDateTimeExtension.toString(LocalDateTime.of(2024, 6, 15, 14, 30), "yyyy/MM/dd HH:mm"); // "2024/06/15 14:30"
```

## Bảo mật

```java
// SqlInputSanitizer - SQLインジェクション対策
SqlInputSanitizer sanitizer = new SqlInputSanitizer();

// SQLエスケープ
String escaped = sanitizer.escapeSql("O'Brien"); // "O''Brien"

// 識別子検証
if (sanitizer.isValidIdentifier("users")) {
  String safeTable = sanitizer.sanitizeIdentifier("users");
  // 安全に使用
}

// ORDER BY検証
if (sanitizer.isValidOrderBy("name ASC")) {
  // 安全にORDER BY句を使用
}

// OutputMasker - 出力マスキング
OutputMasker masker = new OutputMasker();

String maskedEmail = masker.maskEmail("test@example.com"); // "t***@example.com"

String maskedPhone = masker.maskPhoneNumber("090-1234-5678"); // "090-****-5678"

String maskedCard = masker.maskCreditCard("1234567890123456"); // "************3456"

// UrlValidator - URL検証
UrlValidator validator = new UrlValidator();

boolean isValid = validator.isValid("https://example.com"); // true

boolean isSafe = validator.isValidWithScheme("https://example.com", Set.of("https")); // true

// RequestContextHolder - gRPC のリクエストコンテキスト
RequestContext context = RequestContextHolder.getContext(); // 無い場合は null
SecurityUserDto user = (context != null) ? context.getUser() : null;

RequestContextHolder.setAttribute("tenantCd", tenantCd);
Object tenantCd = RequestContextHolder.getAttribute("tenantCd");
```

## Event streaming

```java
// イベント発行
EventEnvelope<String> envelope = EventEnvelope.builder(UUID.randomUUID(), "order-123")
  .payload("Order processed")
  .source("order-service")
  .stage("fulfillment")
  .occurredAt(OffsetDateTime.now())
  .attributes(Map.of("priority", "high"))
  .build();

eventStreamHub.publish(envelope);

// ストリーム購読
Disposable subscription = eventStreamHub.subscribe("order-123", (event) -> {
  System.out.println("Received: " + event.getPayload());
});

// リプレイ付き購読
Disposable replaySubscription = eventStreamHub.subscribeWithReplay(
  "order-123",
  (event) -> {
    System.out.println("Event: " + event.getPayload());
  },
  10 // 直近10件をリプレイ
);

// 購読解除
eventStreamHub.unsubscribe(subscription);
```

## Xử lý exception

```java
// BadRequestException - パラメータ不正
throw new BadRequestException(ErrorCodeEnum.REQUEST_PARAMETER_INVALID);

// BadRequestException - バリデーションエラー付き
List<InvalidRequestExceptionRecord> errors = List.of(
  new InvalidRequestExceptionRecord("email", "Invalid email format", "test@"),
  new InvalidRequestExceptionRecord("password", "Password too short", "123")
);

throw new BadRequestException(ErrorCodeEnum.REQUEST_BODY_INVALID, errors);

// UnauthorizedException - 認証失敗
throw new UnauthorizedException(ErrorCodeEnum.AUTHENTICATION_REQUIRED);

// NotFoundException - リソース未検出
throw new NotFoundException(ErrorCodeEnum.RESOURCE_NOT_FOUND, "User", userId);

// ConflictException - データ競合
throw new ConflictException(ErrorCodeEnum.RESOURCE_CONFLICT, "Email already exists");
```

## Sử dụng mã lỗi

```java
import com.fw.core.constant.ErrorCodeEnum;

// エラーコードから列挙型を取得
ErrorCodeEnum errorCode = ErrorCodeEnum.fromValue("EB-001-000-000-001");

// エラーコードが有効か判定
boolean isValid = ErrorCodeEnum.is("EB-001-000-000-001");

// エラーコード文字列を取得
String code = ErrorCodeEnum.REQUEST_PARAMETER_INVALID.getErrorCode();
```

## Thông báo quốc tế hóa

```java
// MessageSourceを注入
@Autowired
private MessageSource messageSource;

// ロケールに応じたメッセージを取得
String message = messageSource.getMessage(errorCode.getErrorCode(), args, LocaleContextHolder.getLocale());
```
