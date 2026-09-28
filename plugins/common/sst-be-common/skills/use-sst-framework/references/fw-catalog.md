# FW一覧

==javadocで公開する==

## バリデーション制約

### 文字列検証

| 制約名            | 説明                                         | 主要属性                                                                        | 使用例                                                                   |
| ----------------- | -------------------------------------------- | ------------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
| @NotBlank         | フィールドが null または空白でないことを検証 | message                                                                         | `@NotBlank private String name;`                                         |
| @NotNull          | フィールドが null でないことを検証           | message                                                                         | `@NotNull private String id;`                                            |
| @Size             | 文字列の長さが範囲内であることを検証         | min, max                                                                        | `@Size(min=3, max=50) private String name;`                              |
| @Pattern          | 文字列が正規表現パターンに一致することを検証 | regexp                                                                          | `@Pattern(regexp="[A-Z0-9]+") private String code;`                      |
| @Email            | 有効なメールアドレス形式であることを検証     | message                                                                         | `@Email private String email;`                                           |
| @URL              | 有効なURL形式であることを検証                | message                                                                         | `@URL private String website;`                                           |
| @NormalizedString | Unicode正規化形式を検証                      | form (NFC/NFD/NFKC/NFKD)                                                        | `@NormalizedString(form=NFC) private String text;`                       |
| @Password         | パスワード複雑性要件を検証                   | minLength, requireUppercase, requireLowercase, requireDigit, requireSpecialChar | `@Password(minLength=8, requireUppercase=true) private String password;` |

### 日付・日時検証

| 制約名              | 説明                                                 | 主要属性                          | 使用例                                                                             |
| ------------------- | ---------------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------------- |
| @DateFormat         | 日付フォーマットを検証                               | pattern                           | `@DateFormat(pattern="yyyy-MM-dd") private String date;`                           |
| @DateTimeFormat     | 日時フォーマットを検証                               | pattern                           | `@DateTimeFormat(pattern="yyyy-MM-dd HH:mm:ss") private String dateTime;`          |
| @MinDate            | 日付が最小値より後であることを検証                   | value                             | `@MinDate("2024-01-01") private LocalDate date;`                                   |
| @MaxDate            | 日付が最大値より前であることを検証                   | value                             | `@MaxDate("2024-12-31") private LocalDate date;`                                   |
| @MinDateTime        | 日時が最小値より後であることを検証                   | value                             | `@MinDateTime("2024-01-01T00:00:00") private LocalDateTime dateTime;`              |
| @MaxDateTime        | 日時が最大値より前であることを検証                   | value                             | `@MaxDateTime("2024-12-31T23:59:59") private LocalDateTime dateTime;`              |
| @PastOrPresent      | 日時が過去または現在であることを検証                 | message                           | `@PastOrPresent private LocalDate birthDate;`                                      |
| @FutureOrPresent    | 日時が未来または現在であることを検証                 | message                           | `@FutureOrPresent private LocalDate eventDate;`                                    |
| @ChronologicalDates | 開始日が終了日より前であることを検証（クラスレベル） | startField, endField              | `@ChronologicalDates(startField="startDate", endField="endDate")`                  |
| @DateWithinInterval | 日付が期間内であることを検証（クラスレベル）         | startField, endField, targetField | `@DateWithinInterval(startField="start", endField="end", targetField="milestone")` |

### 数値検証

| 制約名      | 説明                           | 主要属性          | 使用例                                                      |
| ----------- | ------------------------------ | ----------------- | ----------------------------------------------------------- |
| @Digits     | 整数部と小数部の桁数制約を検証 | integer, fraction | `@Digits(integer=10, fraction=2) private BigDecimal price;` |
| @DecimalMin | 最小数値を検証                 | value, inclusive  | `@DecimalMin("0.01") private BigDecimal amount;`            |
| @DecimalMax | 最大数値を検証                 | value, inclusive  | `@DecimalMax("999999.99") private BigDecimal amount;`       |

## ユーティリティクラス

### ファイル操作

#### FileCsvUtil

CSVファイルの読み取りと書き込み機能を提供します。

| メソッド名    | 機能概要                 | パラメータ                                                                                                                                                                                          | 戻り値                    |
| ------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------- |
| parse         | CSVをDTOリストへ解析     | `(1) inputStream: InputStream` - CSVファイル<br>`(2) clazz: Class<T>` - DTOクラス<br>`(3) schema: CsvSchema` - スキーマ（省略可）<br>`(4) charset: Charset` - 文字コード（省略可、デフォルトUTF-8） | `List<T>` - DTOリスト     |
| write         | DTOリストをCSVへ書き込み | `(1) data: List<T>` - DTOリスト<br>`(2) clazz: Class<T>` - DTOクラス<br>`(3) schema: CsvSchema` - スキーマ（省略可）<br>`(4) charset: Charset` - 文字コード（省略可）                               | `byte[]` - CSVバイト配列  |
| defaultSchema | デフォルトスキーマを取得 | `(1) clazz: Class<T>` - DTOクラス                                                                                                                                                                   | `CsvSchema` - CSVスキーマ |

#### FilePdfUtil

PDF操作（抽出、結合、分割）機能を提供します。

| メソッド名       | 機能概要             | パラメータ                                                                                                   | 戻り値                               |
| ---------------- | -------------------- | ------------------------------------------------------------------------------------------------------------ | ------------------------------------ |
| extractPages     | 特定ページを抽出     | `(1) pdfBytes: byte[]` - 元PDFデータ<br>`(2) pageNumbers: List<Integer>` - ページ番号リスト（1始まり）       | `byte[]` - 抽出されたPDF             |
| extractPageRange | ページ範囲を抽出     | `(1) pdfBytes: byte[]` - 元PDFデータ<br>`(2) startPage: int` - 開始ページ<br>`(3) endPage: int` - 終了ページ | `byte[]` - 抽出されたPDF             |
| mergePdfs        | 複数PDFを結合        | `(1) pdfs: List<byte[]>` - PDFデータリスト                                                                   | `byte[]` - 結合されたPDF             |
| splitIntoPages   | PDFを1ページずつ分割 | `(1) pdfBytes: byte[]` - PDFデータ                                                                           | `List<byte[]>` - 各ページのPDFリスト |
| getPageCount     | ページ数を取得       | `(1) pdfBytes: byte[]` - PDFデータ                                                                           | `int` - ページ数                     |
| isValidPdf       | PDF形式を検証        | `(1) pdfBytes: byte[]` - PDFデータ                                                                           | `boolean` - 有効な場合true           |

#### FileImageUtil

画像処理（リサイズ、圧縮、サムネイル）機能を提供します。

| メソッド名         | 機能概要         | パラメータ                                                                                                                                | 戻り値                        |
| ------------------ | ---------------- | ----------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------- |
| resize             | 画像をリサイズ   | `(1) imageBytes: byte[]` - 画像データ<br>`(2) width: int` - 幅<br>`(3) height: int` - 高さ<br>`(4) mode: ResizeModeEnum` - リサイズモード | `byte[]` - リサイズされた画像 |
| createThumbnail    | サムネイルを作成 | `(1) imageBytes: byte[]` - 画像データ<br>`(2) size: int` - サムネイルサイズ                                                               | `byte[]` - サムネイル画像     |
| compress           | 画像を圧縮       | `(1) imageBytes: byte[]` - 画像データ<br>`(2) quality: float` - 品質（0.0-1.0）                                                           | `byte[]` - 圧縮された画像     |
| getImageDimensions | 画像サイズを取得 | `(1) imageBytes: byte[]` - 画像データ                                                                                                     | `Dimension` - 幅と高さ        |

リサイズモード: `FIT` (アスペクト比保持・枠内)、`FILL` (アスペクト比保持・枠を埋める)、`EXACT` (正確なサイズ)

#### FileTabularUtil

CSV・Excel統合ファイル処理機能を提供します。

| メソッド名 | 機能概要                      | パラメータ                                                                                                                                       | 戻り値                    |
| ---------- | ----------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------- |
| parseAuto  | CSV・Excelを自動判別して解析  | `(1) inputStream: InputStream` - ファイル<br>`(2) clazz: Class<T>` - DTOクラス<br>`(3) fileType: TabularFileTypeEnum` - ファイルタイプ（省略可） | `List<T>` - DTOリスト     |
| write      | DTOリストをファイルへ書き込み | `(1) data: List<T>` - DTOリスト<br>`(2) clazz: Class<T>` - DTOクラス<br>`(3) fileType: TabularFileTypeEnum` - ファイルタイプ                     | `byte[]` - ファイルデータ |

ファイルタイプ: `CSV`、`XLS` (Excel 97-2003)、`XLSX` (Excel 2007以降)

#### FileZipUtil

ZIPアーカイブ操作機能を提供します。

| メソッド名  | 機能概要                  | パラメータ                                                    | 戻り値                                             |
| ----------- | ------------------------- | ------------------------------------------------------------- | -------------------------------------------------- |
| zip         | ファイルをZIPへ圧縮       | `(1) files: Map<String, byte[]>` - ファイル名とデータのマップ | `byte[]` - ZIP圧縮データ                           |
| unzip       | ZIPアーカイブを解凍       | `(1) zipBytes: byte[]` - ZIPデータ                            | `Map<String, byte[]>` - ファイル名とデータのマップ |
| listEntries | ZIP内のファイル一覧を取得 | `(1) zipBytes: byte[]` - ZIPデータ                            | `List<String>` - ファイル名リスト                  |

### 拡張ユーティリティ

#### StringExtension

文字列操作の拡張メソッドを提供します。

| カテゴリ         | メソッド名           | 機能概要                         | パラメータ                                                                                                                      | 戻り値     |
| ---------------- | -------------------- | -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| パディング       | leftPad              | 左側を指定文字でパディング       | `(1) str: String` - 対象文字列<br>`(2) size: int` - 最終サイズ<br>`(3) padChar: char/String` - パディング文字                   | `String`   |
| パディング       | rightPad             | 右側を指定文字でパディング       | `(1) str: String` - 対象文字列<br>`(2) size: int` - 最終サイズ<br>`(3) padChar: char/String` - パディング文字                   | `String`   |
| パディング       | leftPadByCount       | 左側に指定回数パディング         | `(1) str: String` - 対象文字列<br>`(2) count: int` - パディング回数<br>`(3) padStr: String` - パディング文字列                  | `String`   |
| 結合・分割       | join                 | 文字列を結合（区切りなし）       | `(1) ...strings: String[]` - 文字列配列                                                                                         | `String`   |
| 結合・分割       | joinWith             | 文字列を区切り文字付きで結合     | `(1) delimiter: String` - 区切り文字<br>`(2) ...strings: String[]` - 文字列配列                                                 | `String`   |
| 結合・分割       | split                | 文字列を分割                     | `(1) str: String` - 対象文字列<br>`(2) delimiter: String/char` - 区切り文字                                                     | `String[]` |
| 部分文字列       | substringBefore      | 区切り文字より前を取得           | `(1) str: String` - 対象文字列<br>`(2) separator: String` - 区切り文字                                                          | `String`   |
| 部分文字列       | substringAfter       | 区切り文字より後を取得           | `(1) str: String` - 対象文字列<br>`(2) separator: String` - 区切り文字                                                          | `String`   |
| 部分文字列       | substringBeforeLast  | 最後の区切り文字より前を取得     | `(1) str: String` - 対象文字列<br>`(2) separator: String` - 区切り文字                                                          | `String`   |
| 部分文字列       | substringAfterLast   | 最後の区切り文字より後を取得     | `(1) str: String` - 対象文字列<br>`(2) separator: String` - 区切り文字                                                          | `String`   |
| 部分文字列       | mid                  | 位置指定で部分文字列を取得       | `(1) str: String` - 対象文字列<br>`(2) pos: int` - 開始位置<br>`(3) len: int` - 長さ                                            | `String`   |
| 文字種チェック   | isNull               | nullまたは空文字列か判定         | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isNotNull            | nullでも空文字列でもないか判定   | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isBlank              | nullまたは空白のみか判定         | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isNotBlank           | nullでも空白のみでもないか判定   | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isNumeric            | 数値のみか判定                   | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isAlpha              | 英字のみか判定                   | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isAlphanumeric       | 英数字のみか判定                 | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isHalfWidth          | 半角文字のみか判定               | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 文字種チェック   | isFullWidth          | 全角文字のみか判定               | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| 幅変換           | toHalfwidth          | 全角文字を半角へ変換             | `(1) str: String` - 対象文字列                                                                                                  | `String`   |
| 幅変換           | toFullwidth          | 半角文字を全角へ変換             | `(1) str: String` - 対象文字列                                                                                                  | `String`   |
| マスキング       | maskAll              | 全体をマスク                     | `(1) str: String` - 対象文字列<br>`(2) maskChar: char` - マスク文字                                                             | `String`   |
| マスキング       | maskAllButLast       | 最後のN文字以外をマスク          | `(1) str: String` - 対象文字列<br>`(2) visibleCount: int` - 表示文字数<br>`(3) maskChar: char` - マスク文字                     | `String`   |
| マスキング       | maskRange            | 指定範囲をマスク                 | `(1) str: String` - 対象文字列<br>`(2) start: int` - 開始位置<br>`(3) end: int` - 終了位置<br>`(4) maskChar: char` - マスク文字 | `String`   |
| エンコーディング | shiftJisToUtf8       | Shift_JISからUTF-8へ変換         | `(1) str: String` - 対象文字列                                                                                                  | `String`   |
| エンコーディング | utf8ToShiftJis       | UTF-8からShift_JISへ変換         | `(1) str: String` - 対象文字列                                                                                                  | `String`   |
| エンコーディング | convertEncoding      | 文字コードを変換                 | `(1) str: String` - 対象文字列<br>`(2) from: Charset` - 変換元<br>`(3) to: Charset` - 変換先                                    | `String`   |
| バリデーション   | isEmail              | メールアドレス形式か判定         | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| バリデーション   | isUrl                | URL形式か判定                    | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| バリデーション   | isPhoneNumber        | 電話番号形式か判定               | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| バリデーション   | isPostalCode         | 郵便番号形式か判定               | `(1) str: String` - 対象文字列                                                                                                  | `boolean`  |
| バリデーション   | matchesPattern       | 正規表現パターンに一致するか判定 | `(1) str: String` - 対象文字列<br>`(2) pattern: String` - 正規表現                                                              | `boolean`  |
| バリデーション   | hasLengthBetween     | 文字列長が範囲内か判定           | `(1) str: String` - 対象文字列<br>`(2) min: int` - 最小長<br>`(3) max: int` - 最大長                                            | `boolean`  |
| バリデーション   | hasByteLengthBetween | バイト長が範囲内か判定           | `(1) str: String` - 対象文字列<br>`(2) min: int` - 最小バイト長<br>`(3) max: int` - 最大バイト長                                | `boolean`  |

#### BigDecimalExtension

数値操作の拡張メソッドを提供します。

| メソッド名              | 機能概要                            | パラメータ                                                                                           | 戻り値       |
| ----------------------- | ----------------------------------- | ---------------------------------------------------------------------------------------------------- | ------------ |
| sum                     | 複数の値を合計（nullは0として扱う） | `(1) ...values: BigDecimal[]` - 数値配列                                                             | `BigDecimal` |
| within                  | 値が範囲内か判定                    | `(1) value: BigDecimal` - 対象値<br>`(2) min: BigDecimal` - 最小値<br>`(3) max: BigDecimal` - 最大値 | `boolean`    |
| outside                 | 値が範囲外か判定                    | `(1) value: BigDecimal` - 対象値<br>`(2) min: BigDecimal` - 最小値<br>`(3) max: BigDecimal` - 最大値 | `boolean`    |
| difference              | 2値の差分を取得                     | `(1) left: BigDecimal` - 値1<br>`(2) right: BigDecimal` - 値2                                        | `BigDecimal` |
| isInteger               | 整数か判定                          | `(1) value: BigDecimal` - 対象値                                                                     | `boolean`    |
| isDecimal               | 小数部があるか判定                  | `(1) value: BigDecimal` - 対象値                                                                     | `boolean`    |
| isZero                  | ゼロか判定                          | `(1) value: BigDecimal` - 対象値                                                                     | `boolean`    |
| roundHalfUp             | 四捨五入                            | `(1) value: BigDecimal` - 対象値<br>`(2) scale: int` - 小数桁数                                      | `BigDecimal` |
| roundUp                 | 切り上げ                            | `(1) value: BigDecimal` - 対象値<br>`(2) scale: int` - 小数桁数                                      | `BigDecimal` |
| roundDown               | 切り捨て                            | `(1) value: BigDecimal` - 対象値<br>`(2) scale: int` - 小数桁数                                      | `BigDecimal` |
| getIntegerDigitCount    | 整数部の桁数を取得                  | `(1) value: BigDecimal` - 対象値                                                                     | `int`        |
| getFractionalDigitCount | 小数部の桁数を取得                  | `(1) value: BigDecimal` - 対象値                                                                     | `int`        |

#### LocalDateExtension

日付操作の拡張メソッドを提供します。

| メソッド名     | 機能概要                | パラメータ                                                                                           | 戻り値    |
| -------------- | ----------------------- | ---------------------------------------------------------------------------------------------------- | --------- |
| within         | 日付が範囲内か判定      | `(1) date: LocalDate` - 対象日付<br>`(2) start: LocalDate` - 開始日<br>`(3) end: LocalDate` - 終了日 | `boolean` |
| outside        | 日付が範囲外か判定      | `(1) date: LocalDate` - 対象日付<br>`(2) start: LocalDate` - 開始日<br>`(3) end: LocalDate` - 終了日 | `boolean` |
| withinDays     | 基準日からN日以内か判定 | `(1) base: LocalDate` - 基準日<br>`(2) target: LocalDate` - 対象日<br>`(3) days: int` - 日数         | `boolean` |
| withinMonths   | 基準日からN月以内か判定 | `(1) base: LocalDate` - 基準日<br>`(2) target: LocalDate` - 対象日<br>`(3) months: int` - 月数       | `boolean` |
| withinYears    | 基準日からN年以内か判定 | `(1) base: LocalDate` - 基準日<br>`(2) target: LocalDate` - 対象日<br>`(3) years: int` - 年数        | `boolean` |
| isBusinessDay  | 営業日（平日）か判定    | `(1) date: LocalDate` - 対象日<br>`(2) holidays: Set<LocalDate>` - 祝日セット（省略可）              | `boolean` |
| isStartOfMonth | 月初日か判定            | `(1) date: LocalDate` - 対象日                                                                       | `boolean` |
| isEndOfMonth   | 月末日か判定            | `(1) date: LocalDate` - 対象日                                                                       | `boolean` |
| toString       | 文字列へフォーマット    | `(1) date: LocalDate` - 対象日<br>`(2) pattern: String/DateTimeFormatter` - フォーマット（省略可）   | `String`  |

#### LocalTimeExtension

時刻操作の拡張メソッドを提供します。

| メソッド名      | 機能概要                           | パラメータ                                                                                               | 戻り値    |
| --------------- | ---------------------------------- | -------------------------------------------------------------------------------------------------------- | --------- |
| within          | 時刻が範囲内か判定（深夜跨ぎ対応） | `(1) time: LocalTime` - 対象時刻<br>`(2) start: LocalTime` - 開始時刻<br>`(3) end: LocalTime` - 終了時刻 | `boolean` |
| outside         | 時刻が範囲外か判定                 | `(1) time: LocalTime` - 対象時刻<br>`(2) start: LocalTime` - 開始時刻<br>`(3) end: LocalTime` - 終了時刻 | `boolean` |
| diffHours       | 時間差を取得                       | `(1) start: LocalTime` - 開始時刻<br>`(2) end: LocalTime` - 終了時刻                                     | `long`    |
| diffMinutes     | 分差を取得                         | `(1) start: LocalTime` - 開始時刻<br>`(2) end: LocalTime` - 終了時刻                                     | `long`    |
| diffSeconds     | 秒差を取得                         | `(1) start: LocalTime` - 開始時刻<br>`(2) end: LocalTime` - 終了時刻                                     | `long`    |
| isCrossMidnight | 範囲が深夜を跨ぐか判定             | `(1) start: LocalTime` - 開始時刻<br>`(2) end: LocalTime` - 終了時刻                                     | `boolean` |
| toString        | 文字列へフォーマット               | `(1) time: LocalTime` - 対象時刻<br>`(2) pattern: String/DateTimeFormatter` - フォーマット（省略可）     | `String`  |

#### LocalDateTimeExtension

日時操作の拡張メソッドを提供します。

| メソッド名 | 機能概要             | パラメータ                                                                                                               | 戻り値    |
| ---------- | -------------------- | ------------------------------------------------------------------------------------------------------------------------ | --------- |
| within     | 日時が範囲内か判定   | `(1) dateTime: LocalDateTime` - 対象日時<br>`(2) start: LocalDateTime` - 開始日時<br>`(3) end: LocalDateTime` - 終了日時 | `boolean` |
| outside    | 日時が範囲外か判定   | `(1) dateTime: LocalDateTime` - 対象日時<br>`(2) start: LocalDateTime` - 開始日時<br>`(3) end: LocalDateTime` - 終了日時 | `boolean` |
| toString   | 文字列へフォーマット | `(1) dateTime: LocalDateTime` - 対象日時<br>`(2) pattern: String/DateTimeFormatter` - フォーマット（省略可）             | `String`  |

### セキュリティ

#### SqlInputSanitizer

SQL入力のサニタイゼーションと検証機能を提供します。

| メソッド名         | 機能概要                | パラメータ                         | 戻り値    |
| ------------------ | ----------------------- | ---------------------------------- | --------- |
| escapeSql          | SQL特殊文字をエスケープ | `(1) input: String` - 入力文字列   | `String`  |
| isValidIdentifier  | 有効なSQL識別子か判定   | `(1) identifier: String` - 識別子  | `boolean` |
| sanitizeIdentifier | 識別子を検証・取得      | `(1) identifier: String` - 識別子  | `String`  |
| isValidOrderBy     | 有効なORDER BY句か判定  | `(1) orderBy: String` - ORDER BY句 | `boolean` |
| isValidLimit       | 有効なLIMIT値か判定     | `(1) limit: String` - LIMIT値      | `boolean` |

!!! warning "重要"
SQLサニタイゼーションは最後の手段です。可能な限りパラメータ化クエリを使用してください。

#### OutputMasker

出力値のマスキング機能を提供します。

| メソッド名      | 機能概要                     | パラメータ                                                                                                             | 戻り値   |
| --------------- | ---------------------------- | ---------------------------------------------------------------------------------------------------------------------- | -------- |
| maskEmail       | メールアドレスをマスク       | `(1) email: String` - メールアドレス                                                                                   | `String` |
| maskPhoneNumber | 電話番号をマスク             | `(1) phone: String` - 電話番号                                                                                         | `String` |
| maskCreditCard  | クレジットカード番号をマスク | `(1) cardNumber: String` - カード番号                                                                                  | `String` |
| maskPartial     | 部分的にマスク               | `(1) value: String` - 対象文字列<br>`(2) visibleStart: int` - 先頭表示文字数<br>`(3) visibleEnd: int` - 末尾表示文字数 | `String` |

#### UrlValidator

URL検証機能を提供します。

| メソッド名        | 機能概要                          | パラメータ                                                                        | 戻り値    |
| ----------------- | --------------------------------- | --------------------------------------------------------------------------------- | --------- |
| isValid           | 有効なURLか判定                   | `(1) url: String` - URL文字列                                                     | `boolean` |
| isValidWithScheme | 指定スキームのURLか判定           | `(1) url: String` - URL文字列<br>`(2) allowedSchemes: Set<String>` - 許可スキーム | `boolean` |
| isSafeUrl         | 安全なURLか判定（ホワイトリスト） | `(1) url: String` - URL文字列<br>`(2) allowedHosts: Set<String>` - 許可ホスト     | `boolean` |

#### RequestContext / RequestContextHolder

リクエスト単位のユーザー情報と属性を保持する。`RequestContext`（`com.fw.core.dto`）が入れ物、`RequestContextHolder`（`com.fw.grpc.core.dto`）が gRPC コンテキストからの取得口。

`RequestContext`

| メソッド名     | 機能概要             | パラメータ                                                  | 戻り値                 |
| -------------- | -------------------- | ----------------------------------------------------------- | ---------------------- |
| getUser        | ユーザー情報を取得   | なし                                                        | `SecurityUserDto`      |
| setUser        | ユーザー情報を設定   | `(1) user: SecurityUserDto` - ユーザー情報                   | `void`                 |
| getAttribute   | 属性を取得           | `(1) name: String` - 属性名                                 | `Object`               |
| setAttribute   | 属性を設定           | `(1) name: String` - 属性名<br>`(2) value: Object` - 値      | `void`                 |
| getAttributes  | 属性一覧を取得       | なし                                                        | `Map<String, Object>`  |

`RequestContextHolder`（static。gRPC サーバー・クライアント側でのみ利用可能）

| メソッド名   | 機能概要                                      | パラメータ                                             | 戻り値           |
| ------------ | --------------------------------------------- | ------------------------------------------------------ | ---------------- |
| getContext   | 現在の `RequestContext` を取得（無い場合 null） | なし                                                   | `RequestContext` |
| getAttribute | 属性を取得                                    | `(1) name: String` - 属性名                            | `Object`         |
| setAttribute | 属性を設定                                    | `(1) name: String` - 属性名<br>`(2) value: Object` - 値 | `void`           |

BFF（HTTP 側）では gRPC コンテキストが無いため、認証情報は Spring Security の `SecurityContextHolder` から取得する。

### イベントストリーミング

#### EventStreamHub

イベントストリーミングの中核機能を提供します。

| メソッド名          | 機能概要           | パラメータ                                                                                                                                | 戻り値                   |
| ------------------- | ------------------ | ----------------------------------------------------------------------------------------------------------------------------------------- | ------------------------ |
| publish             | イベントを発行     | `(1) envelope: EventEnvelope<T>` - イベント                                                                                               | `void`                   |
| subscribe           | ストリームを購読   | `(1) streamId: String` - ストリームID<br>`(2) consumer: Consumer<EventEnvelope<T>>` - コンシューマ                                        | `Disposable`             |
| subscribeWithReplay | リプレイ付きで購読 | `(1) streamId: String` - ストリームID<br>`(2) consumer: Consumer<EventEnvelope<T>>` - コンシューマ<br>`(3) replayCount: int` - リプレイ数 | `Disposable`             |
| unsubscribe         | 購読を解除         | `(1) disposable: Disposable` - サブスクリプション                                                                                         | `void`                   |
| getBuffer           | バッファを取得     | `(1) streamId: String` - ストリームID                                                                                                     | `List<EventEnvelope<T>>` |

#### EventEnvelope

イベントエンベロープを構築します。

| メソッド名 | 機能概要       | パラメータ                                                                | 戻り値                    |
| ---------- | -------------- | ------------------------------------------------------------------------- | ------------------------- |
| builder    | ビルダーを作成 | `(1) eventId: UUID` - イベントID<br>`(2) streamId: String` - ストリームID | `EventEnvelopeBuilder<T>` |

ビルダーメソッド: `payload(T)`, `source(String)`, `stage(String)`, `occurredAt(OffsetDateTime)`, `attributes(Map<String, Object>)`, `build()`

## 例外クラス

### HTTPステータスベース例外

| 例外クラス                  | HTTPステータス | 説明                   | コンストラクタ                                                                  |
| --------------------------- | -------------- | ---------------------- | ------------------------------------------------------------------------------- |
| BadRequestException         | 400            | 無効なリクエスト       | `(errorCode)`, `(errorCode, args)`, `(errorCode, cause)`, `(errorCode, errors)` |
| UnauthorizedException       | 401            | 認証が必要             | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ForbiddenException          | 403            | アクセス拒否           | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| NotFoundException           | 404            | リソースが見つからない | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ConflictException           | 409            | リソース競合           | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| TooManyRequestsException    | 429            | レート制限超過         | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |
| ServerErrorException        | 500            | 内部サーバーエラー     | `()`, `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                  |
| ServiceUnavailableException | 503            | サービス利用不可       | `(errorCode)`, `(errorCode, cause)`, `(errorCode, args)`                        |

### 特殊例外

| 例外クラス                     | 説明                                             | 使用場面                               |
| ------------------------------ | ------------------------------------------------ | -------------------------------------- |
| InvalidRequestPayloadException | 無効なリクエストペイロード（フィールド詳細付き） | リクエストボディのバリデーション失敗時 |
| CsvProcessingException         | CSV処理エラー                                    | CSV読み取り・書き込み失敗時            |
| ImageProcessingException       | 画像処理エラー                                   | 画像リサイズ・圧縮失敗時               |

## エラーコード

標準化されたエラーコード体系（`EB-001-XXX-XXX-XXX`形式）を提供します。

| カテゴリ       | エラーコード              | 説明                       |
| -------------- | ------------------------- | -------------------------- |
| リクエスト     | REQUEST_PARAMETER_INVALID | リクエストパラメータが不正 |
| リクエスト     | REQUEST_BODY_INVALID      | リクエストボディが不正     |
| リクエスト     | REQUEST_HEADER_INVALID    | リクエストヘッダーが不正   |
| 認証・認可     | AUTHENTICATION_REQUIRED   | 認証が必要                 |
| 認証・認可     | AUTHENTICATION_FAILED     | 認証に失敗                 |
| 認証・認可     | AUTHORIZATION_FAILED      | 認可に失敗                 |
| リソース       | RESOURCE_NOT_FOUND        | リソースが見つからない     |
| リソース       | RESOURCE_CONFLICT         | リソースが競合             |
| リソース       | RESOURCE_ALREADY_EXISTS   | リソースが既に存在         |
| バリデーション | VALIDATION_ERROR          | バリデーションエラー       |
| バリデーション | FIELD_REQUIRED            | 必須フィールドが未入力     |
| バリデーション | FIELD_INVALID             | フィールドの値が不正       |
| システム       | INTERNAL_SERVER_ERROR     | 内部サーバーエラー         |
| システム       | SERVICE_UNAVAILABLE       | サービスが利用不可         |

## 国際化サポート

エラーメッセージの多言語対応をサポートします。

- 英語（デフォルト）: `messages.properties`
- 日本語: `messages-ja-jp.properties`

## DTOクラス

### SecurityUserDto

| フィールド  | 型          | 説明           |
| ----------- | ----------- | -------------- |
| userId      | String      | ユーザーID     |
| username    | String      | ユーザー名     |
| email       | String      | メールアドレス |
| roles       | Set<String> | ロール         |
| authorities | Set<String> | 権限           |

### RequestContext

| フィールド | 型     | 説明         |
| ---------- | ------ | ------------ |
| requestId  | String | リクエストID |
| tenantId   | String | テナントID   |
| locale     | Locale | ロケール     |
| timezone   | ZoneId | タイムゾーン |

### ListResponse<T>

| フィールド | 型                   | 説明         |
| ---------- | -------------------- | ------------ |
| items      | List<T>              | データリスト |
| metadata   | ListResponseMetadata | メタデータ   |

### ListResponseMetadata

| フィールド | 型   | 説明             |
| ---------- | ---- | ---------------- |
| page       | int  | 現在のページ番号 |
| size       | int  | ページサイズ     |
| total      | long | 総件数           |
| totalPages | int  | 総ページ数       |

---

# 使用例

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

## セキュリティ

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

## イベントストリーミング

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

## 例外処理

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

## エラーコード使用

```java
import com.fw.core.constant.ErrorCodeEnum;

// エラーコードから列挙型を取得
ErrorCodeEnum errorCode = ErrorCodeEnum.fromValue("EB-001-000-000-001");

// エラーコードが有効か判定
boolean isValid = ErrorCodeEnum.is("EB-001-000-000-001");

// エラーコード文字列を取得
String code = ErrorCodeEnum.REQUEST_PARAMETER_INVALID.getErrorCode();
```

## 国際化メッセージ

```java
// MessageSourceを注入
@Autowired
private MessageSource messageSource;

// ロケールに応じたメッセージを取得
String message = messageSource.getMessage(errorCode.getErrorCode(), args, LocaleContextHolder.getLocale());
```
