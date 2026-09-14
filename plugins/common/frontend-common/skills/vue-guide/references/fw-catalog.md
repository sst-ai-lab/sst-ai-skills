# FW一覧

> このファイルは `yarn generate:ai-docs` で自動生成されています。手動編集しないでください。

## コンポーネント

[FWコンポーネント一覧.md](./fw-components.md)

## ロジック

### SstUtil

| メソッド名                    | 機能概要                                                                                                                                                                                                                     | パラメータ                                                                                                                                               | 戻り値                                    |
| ----------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------- | --- | ---- | ------ | ------ | --- |
| objType                       | オブジェクトの種別を取得                                                                                                                                                                                                     | `obj` - 任意の値                                                                                                                                         | 種別名（例: 'String', 'Number'）          |
| isDef                         | パラメータが定義されているか判定（undefined / null 以外）                                                                                                                                                                    | `val` - 任意の値                                                                                                                                         | 定義されていれば true                     |
| isString                      | 文字列か判定                                                                                                                                                                                                                 | `val` - 任意の値                                                                                                                                         | String の場合 true                        |
| isNumber                      | 数値か判定                                                                                                                                                                                                                   | `val` - 任意の値                                                                                                                                         | Number の場合 true                        |
| isBoolean                     | 真偽値か判定                                                                                                                                                                                                                 | `val` - 任意の値                                                                                                                                         | Boolean の場合 true                       |
| isDate                        | 日付オブジェクトか判定                                                                                                                                                                                                       | `val` - 任意の値                                                                                                                                         | Date の場合 true                          |
| isFile                        | File オブジェクトか判定                                                                                                                                                                                                      | `val` - 任意の値                                                                                                                                         | File の場合 true                          |
| isArray                       | 配列か判定                                                                                                                                                                                                                   | `val` - 任意の値                                                                                                                                         | Array の場合 true                         |
| isFunction                    | 関数か判定                                                                                                                                                                                                                   | `val` - 任意の値                                                                                                                                         | Function の場合 true                      |
| isObject                      | オブジェクトか判定                                                                                                                                                                                                           | `val` - 任意の値                                                                                                                                         | Object の場合 true                        |
| isNodeList                    | NodeList か判定                                                                                                                                                                                                              | `val` - 任意の値                                                                                                                                         | NodeList の場合 true                      |
| isElement                     | DOM Element か判定                                                                                                                                                                                                           | `val` - 任意の値                                                                                                                                         | Element を含む場合 true                   |
| isVnode                       | Vue の VNode か判定                                                                                                                                                                                                          | `val` - 任意の値                                                                                                                                         | componentOptions を持つ場合 true          |
| isVueComponent                | Vue コンポーネントか判定                                                                                                                                                                                                     | `val` - 任意の値                                                                                                                                         | $root を持つ場合 true                     |
| toString                      | 型変換 任意の値→文字列                                                                                                                                                                                                       | `val` - 任意の値                                                                                                                                         | 文字列表現                                |
| generateUUID                  | UUID を生成                                                                                                                                                                                                                  | なし                                                                                                                                                     | RFC 4122 version 4 形式の UUID            |
| toDate                        | 任意の値を Date オブジェクトに変換                                                                                                                                                                                           | `val` - 日付として扱う値                                                                                                                                 | 有効な日付の場合 Date、無効時は null      |
| formatNumber                  | 数値をフォーマット                                                                                                                                                                                                           | `val` - 数値<br>`dec` - 小数点以下の桁数<br>`dsep` - 小数点記号<br>`tsep` - 千分位記号                                                                   | フォーマット済み文字列                    |
| formatWithComma               | カンマ区切り（数値を千分位カンマ区切り文字列に変換）                                                                                                                                                                         | `num` - 対象数値<br>`decimalPlaces` - 小数点以下の桁数                                                                                                   | -                                         |
| formatDecimal                 | 小数点フォーマット（指定桁数の小数点表示）                                                                                                                                                                                   | `num` - 対象数値<br>`decimalPlaces` - 小数点以下の桁数                                                                                                   | -                                         |
| stringToNumber                | 文字列→数値変換                                                                                                                                                                                                              | `str` - 文字列                                                                                                                                           | 数値（変換失敗時は null）                 |
| formatDate                    | 日付をフォーマット                                                                                                                                                                                                           | `val` - 日付値<br>`format` - 出力フォーマット（デフォルト: "YYYY/MM/DD"）                                                                                | フォーマット済み日付文字列、無効時は null |
| getYearGap                    | 日付差（年単位）を計算                                                                                                                                                                                                       | `date1` - 開始日付<br>`date2` - 終了日付                                                                                                                 | -                                         |
| getMonthGap                   | 日付差（月単位）を計算                                                                                                                                                                                                       | `date1` - 開始日付<br>`date2` - 終了日付                                                                                                                 | -                                         |
| getDayGap                     | 日付差（日単位）を計算                                                                                                                                                                                                       | `date1` - 開始日付<br>`date2` - 終了日付                                                                                                                 | -                                         |
| parseDate                     | 日付解析（複数シグネチャ対応） - parseDate(val): 自動解析 - parseDate(val, format): フォーマット指定解析 - parseDate(year, month, day): 年月日から構築 - parseDate(year, month, day, hour, minute, second): 完全日時から構築 | なし                                                                                                                                                     | -                                         |
| getCurrentDate                | システム日付取得                                                                                                                                                                                                             | `format` - 未指定時は Date、指定時はフォーマット済み文字列                                                                                               | -                                         |
| getCurrentDateTime            | システム日時取得                                                                                                                                                                                                             | `format` - 未指定時は Date、指定時はフォーマット済み文字列                                                                                               | -                                         |
| getYear                       | 年取得                                                                                                                                                                                                                       | `date` - 対象日付（省略時はシステム日付）<br>`format` - フォーマット文字列（省略時は"YYYY"）                                                             | -                                         |
| getMonth                      | 月取得                                                                                                                                                                                                                       | `date` - 対象日付（省略時はシステム日付）<br>`format` - フォーマット文字列（省略時は"MM"）                                                               | -                                         |
| getDay                        | 日取得                                                                                                                                                                                                                       | `date` - 対象日付（省略時はシステム日付）<br>`format` - フォーマット文字列（省略時は"DD"）                                                               | -                                         |
| getDayCountOfMonth            | 指定された年月の月の日数を取得                                                                                                                                                                                               | `year` - 年<br>`month` - 月                                                                                                                              | 日数、無効時は null                       |
| getDayCountOfYear             | 指定された年の日数を取得                                                                                                                                                                                                     | `year` - 年                                                                                                                                              | 日数（うるう年対応）、無効時は null       |
| getStartOfMonth               | 指定された日付の月初を取得                                                                                                                                                                                                   | `date` - 対象日付                                                                                                                                        | -                                         |
| getEndOfMonth                 | 指定された日付の月末を取得                                                                                                                                                                                                   | `date` - 対象日付                                                                                                                                        | -                                         |
| getFirstDayOfMonth            | 指定された年月の月の初日の曜日を取得                                                                                                                                                                                         | `val` - 年月                                                                                                                                             | 0(日曜日)〜6(土曜日)                      |
| prevDay                       | 前日を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| nextDay                       | 翌日を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| prevMonth                     | 前月を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| nextMonth                     | 翌月を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| prevYear                      | 前年を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| nextYear                      | 翌年を取得                                                                                                                                                                                                                   | `val` - 基準日                                                                                                                                           | -                                         |
| getWeekNumber                 | 指定された日付の週番号を取得                                                                                                                                                                                                 | `val` - 対象日付                                                                                                                                         | -                                         |
| addDate                       | 日付に指定された数量を加算                                                                                                                                                                                                   | `val` - 元の日付<br>`num` - 加算する数値<br>`type` - 加算単位(day, week, month, year)                                                                    | -                                         |
| subtractDate                  | 日付に指定された数量を減算                                                                                                                                                                                                   | `val` - 元の日付<br>`num` - 減算する数値<br>`type` - 減算単位(day, week, month, year)                                                                    | -                                         |
| isEquals                      | 共通比較（＝）                                                                                                                                                                                                               | `value1` - 比較対象値1<br>`value2` - 比較対象値2                                                                                                         | 相等の場合 true                           |
| isInRange                     | 範囲内判定（min <= val <= max）                                                                                                                                                                                              | なし                                                                                                                                                     | -                                         |
| isOutOfRange                  | 範囲外判定（val < min または val > max）                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| isBlank                       | ブランクチェック（空文字列）                                                                                                                                                                                                 | なし                                                                                                                                                     | 空文字列または未定義の場合 true           |
| isNotBlank                    | 非ブランクチェック（空文字列ではない）                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| addNumber                     | 数値加算                                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| sumArray                      | 配列内 SUM（数値の合計）                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| isGreaterThan                 | 通用比较（＞）                                                                                                                                                                                                               | `value1` - 比較対象値1<br>`value2` - 比較対象値2                                                                                                         | -                                         |
| isGreaterThanOrEqual          | 通用比较（＞＝）                                                                                                                                                                                                             | `value1` - 比較対象値1<br>`value2` - 比較対象値2                                                                                                         | -                                         |
| isLessThan                    | 通用比较（＜）                                                                                                                                                                                                               | `value1` - 比較対象値1<br>`value2` - 比較対象値2                                                                                                         | -                                         |
| isLessThanOrEqual             | 通用比较（＜＝）                                                                                                                                                                                                             | `value1` - 比較対象値1<br>`value2` - 比較対象値2                                                                                                         | -                                         |
| isDateInRange                 | 日付範囲内チェック                                                                                                                                                                                                           | `targetDate` - チェック対象日付<br>`startDate` - 開始日付<br>`endDate` - 終了日付                                                                        | -                                         |
| isDateOutOfRange              | 日付範囲外チェック                                                                                                                                                                                                           | `targetDate` - チェック対象日付<br>`startDate` - 開始日付<br>`endDate` - 終了日付                                                                        | -                                         |
| isFirstDayOfMonth             | 月初日付判定                                                                                                                                                                                                                 | `date` - チェック対象日付                                                                                                                                | -                                         |
| isLastDayOfMonth              | 月末日付判定                                                                                                                                                                                                                 | `date` - チェック対象日付                                                                                                                                | -                                         |
| isDateWithinYears             | 指定年数以内日付比較                                                                                                                                                                                                         | `date` - チェック対象日付<br>`years` - 比較年数                                                                                                          | -                                         |
| isDateWithinMonths            | 指定月数以内日付比較                                                                                                                                                                                                         | `date` - チェック対象日付<br>`months` - 比較月数                                                                                                         | -                                         |
| isDateWithinDays              | 指定日数以内日付比較                                                                                                                                                                                                         | `date` - チェック対象日付<br>`days` - 比較日数                                                                                                           | -                                         |
| getCurrentTime                | システム時刻取得                                                                                                                                                                                                             | `format` - フォーマット（例: "HH:MM:SS"）                                                                                                                | -                                         |
| getHourFromTime               | 時取得（HHMMSS形式から時を取得）                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| getMinuteFromTime             | 分取得（HHMMSS形式から分を取得）                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| getSecondFromTime             | 秒取得（HHMMSS形式から秒を取得）                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| parseTime                     | 時刻を解析する - parseTime(val) - parseTime(val, format) - parseTime(hour, minute, second)                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| formatTime                    | 時刻フォーマット                                                                                                                                                                                                             | `time` - 対象時刻<br>`format` - フォーマット（例: "HH:MM:SS"）                                                                                           | -                                         |
| isTimeInRange                 | 時刻範囲内チェック                                                                                                                                                                                                           | `target` - チェック対象時刻<br>`start` - 範囲開始時刻<br>`end` - 範囲終了時刻                                                                            | -                                         |
| isTimeOutOfRange              | 時刻範囲外チェック                                                                                                                                                                                                           | `target` - チェック対象時刻<br>`start` - 範囲開始時刻<br>`end` - 範囲終了時刻                                                                            | -                                         |
| isTimeWithinHours             | 指定時数以内かどうか                                                                                                                                                                                                         | `time` - 比較対象時刻<br>`hours` - 時間数                                                                                                                | -                                         |
| isTimeWithinMinutes           | 指定分数以内かどうか                                                                                                                                                                                                         | `time` - 比較対象時刻<br>`minutes` - 分数                                                                                                                | -                                         |
| isTimeWithinSeconds           | 指定秒数以内かどうか                                                                                                                                                                                                         | `time` - 比較対象時刻<br>`seconds` - 秒数                                                                                                                | -                                         |
| addDateTime                   | ２つ日時の加算                                                                                                                                                                                                               | `dateTime` - 日付時間<br>`value` - 加算する数値<br>`unit` - 単位（year, month, day, hour, minute, second）                                               | -                                         |
| subtractDateTime              | ２つ日時の減算                                                                                                                                                                                                               | `dateTime` - 日付時間<br>`value` - 減算する数値<br>`unit` - 単位（year, month, day, hour, minute, second）                                               | -                                         |
| getDateTimeGap                | ２つ日時の差分値を取得                                                                                                                                                                                                       | `dateTime1` - 日付時間1<br>`dateTime2` - 日付時間2<br>`unit` - 単位                                                                                      | -                                         |
| parseDateTime                 | 型変換 文字（各種フォーマット）→ 日付                                                                                                                                                                                        | `val` - 日付時刻文字列                                                                                                                                   | -                                         |
| formatDateTime                | 日付時刻フォーマット                                                                                                                                                                                                         | `val` - 対象値<br>`format` - フォーマット                                                                                                                | -                                         |
| getDateTimePart               | 指定フォーマットで日付・時刻の各部分を取得                                                                                                                                                                                   | `date` - 日付<br>`part` - year                                                                                                                           | month                                     | day | hour | minute | second | -   |
| getDateTimeWithFormat         | フォーマット指定で日時を取得                                                                                                                                                                                                 | `date` - 日付<br>`format` - フォーマット                                                                                                                 | -                                         |
| dateTimeInRange               | 範囲内検証（値の型自動判定）                                                                                                                                                                                                 | `targetValue` - チェック対象値<br>`startValue` - 開始値<br>`endValue` - 終了値<br>`valueType` - 値の型                                                   | -                                         |
| dateTimeOutOfRange            | 範囲外検証（値の型自動判定）                                                                                                                                                                                                 | `targetValue` - チェック対象値<br>`startValue` - 開始値<br>`endValue` - 終了値<br>`valueType` - 値の型                                                   | -                                         |
| isNull                        | Nullチェック                                                                                                                                                                                                                 | `val` - チェック対象の値                                                                                                                                 | -                                         |
| isNotNull                     | 非Nullチェック                                                                                                                                                                                                               | `val` - チェック対象の値                                                                                                                                 | -                                         |
| isNumericString               | 数値文字チェック（数値または数値文字列かチェック）                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| isAlpha                       | 英字チェック（英字のみかチェック）                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| isAlphanumeric                | 英数字チェック（英数字のみかチェック）                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| isHalfWidth                   | 半角文字チェック（半角文字のみかチェック）                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| isFullWidth                   | 全角文字チェック（全角文字のみかチェック）                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| isPhoneNumber                 | 電話番号チェック（日本の電話番号形式かチェック）                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| isPostalCode                  | 郵便番号チェック（日本の郵便番号形式かチェック）                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| isEmail                       | メール形式チェック（メールアドレス形式かチェック）                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| isURL                         | URL形式チェック（URL形式かチェック）                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| matchesPattern                | 正規表現チェック（指定した正規表現にマッチするかチェック）                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| hasLength                     | 文字数チェック（指定した文字数と一致するかチェック）                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| hasByteLength                 | バイト数チェック（指定したバイト数と一致するかチェック）                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| isEqual                       | 等価判定（==）                                                                                                                                                                                                               | `a` - 値1<br>`b` - 値2                                                                                                                                   | -                                         |
| isInteger                     | 整数判定                                                                                                                                                                                                                     | `val` - チェック対象値                                                                                                                                   | -                                         |
| isDecimal                     | 小数判定                                                                                                                                                                                                                     | `val` - チェック対象値                                                                                                                                   | -                                         |
| isZero                        | ゼロ判定                                                                                                                                                                                                                     | `val` - チェック対象値                                                                                                                                   | -                                         |
| subtractNumber                | 数値減算（a - b）                                                                                                                                                                                                            | なし                                                                                                                                                     | -                                         |
| multiplyNumber                | 数値乗算（a \* b）                                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| divideNumber                  | 数値除算（a / b）                                                                                                                                                                                                            | なし                                                                                                                                                     | -                                         |
| moduloNumber                  | 数値余り（a % b）                                                                                                                                                                                                            | なし                                                                                                                                                     | -                                         |
| getDifference                 | 数値差取得（絶対値）                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| roundNumber                   | 四捨五入                                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| ceilNumber                    | 切り上げ                                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| floorNumber                   | 切り捨て                                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| getIntegerDigits              | 桁数取得（整数部の桁数）                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| getDecimalDigits              | 小数点以下の桁数取得                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| merge                         | オブジェクトマージ                                                                                                                                                                                                           | `target` - コピー先<br>`sources` - コピー元（可変引数）                                                                                                  | -                                         |
| mergeArray                    | 配列マージ（値をディープコピー）                                                                                                                                                                                             | `target` - ターゲット配列<br>`sources` - ソース配列                                                                                                      | -                                         |
| formatFileSize                | ファイルサイズを見やすい文字列へ変換 - `useSiUnits: false`（デフォルト）: 1024 進数（KiB / MiB / GiB / TiB） - `useSiUnits: true`: SI 単位 1000 進数（KB / MB / GB / TB）                                                    | `bytes` - バイト数<br>`decimals` - 小数点以下桁数（デフォルト: 2）<br>`useSiUnits` - true = SI（1000 進）/ false = 2進数（1024 進）（デフォルト: false） | -                                         |
| setLocalStorage               | localStorage に値を保存 文字列以外は自動で JSON.stringify してから保存する。 容量超過（QuotaExceededError）や循環参照による stringify 失敗時は 例外をキャッチして `false` を返す（例外は外部へ伝播しない）。                 | `key` - キー名<br>`value` - 保存値（オブジェクト・配列は JSON に変換される）                                                                             | 保存成功時 true、失敗時 false             |
| removeLocalStorage            | localStorage から値を削除                                                                                                                                                                                                    | `key` - キー名                                                                                                                                           | -                                         |
| flattenObject                 | ネストしたオブジェクトをフラット化                                                                                                                                                                                           | `obj` - 対象オブジェクト<br>`delimiter` - キーの区切り文字                                                                                               | -                                         |
| unflattenObject               | フラットなオブジェクトをネスト構造に復元                                                                                                                                                                                     | `obj` - 対象オブジェクト<br>`delimiter` - キーの区切り文字                                                                                               | -                                         |
| on                            | イベントバインド                                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| off                           | イベント解除                                                                                                                                                                                                                 | なし                                                                                                                                                     | -                                         |
| once                          | 一度だけ発火するイベントをバインド                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| scrollBarWidth                | ブラウザの縦スクロールバーの幅を取得する                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| hasClass                      | 要素に指定したクラスが存在するか判定                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| addClass                      | 要素にクラスを追加                                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| removeClass                   | 要素からクラスを削除                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| getStyle                      | 要素のスタイル取得                                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| setStyle                      | 要素のスタイル設定                                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| getCookie                     | Cookie取得                                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| setCookie                     | Cookie設定                                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| removeCookie                  | Cookie削除                                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| throttle                      | throttle（関数スロットリング）                                                                                                                                                                                               | なし                                                                                                                                                     | -                                         |
| debounce                      | debounce（関数デバウンス）                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| addResizeListener             | resizeイベントを追加                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| removeResizeListener          | resizeイベントを削除                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| addHoverListener              | hoverイベントを追加                                                                                                                                                                                                          | なし                                                                                                                                                     | -                                         |
| removeHoverListener           | hoverイベントを削除                                                                                                                                                                                                          | なし                                                                                                                                                     | -                                         |
| addTouchStart                 | touchstartイベントを追加                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| addTouchMove                  | touchmoveイベントを追加                                                                                                                                                                                                      | なし                                                                                                                                                     | -                                         |
| addTouchEnd                   | touchendイベントを追加                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| removeTouchStart              | touchstartイベントを削除                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| removeTouchMove               | touchmoveイベントを削除                                                                                                                                                                                                      | なし                                                                                                                                                     | -                                         |
| removeTouchEnd                | touchendイベントを削除                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| trim                          | 前後の空白を除去                                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| ShiftJIStoUTF8                | ShiftJIS→UTF-8 変換                                                                                                                                                                                                          | なし                                                                                                                                                     | -                                         |
| UTF8toShiftJIS                | UTF-8→ShiftJIS 変換                                                                                                                                                                                                          | なし                                                                                                                                                     | -                                         |
| concatenateStrings            | 文字連結                                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| joinStringsWithoutDelimiter   | 可変引数の文字列連結（区切りなし）                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| joinStringsWithDelimiter      | 可変引数の文字列連結（区切りあり）                                                                                                                                                                                           | なし                                                                                                                                                     | -                                         |
| arrayToStringWithoutDelimiter | 配列文字列→1文字列（区切りなし）                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| arrayToStringWithDelimiter    | 配列文字列→1文字列（区切りあり）                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| stringToArrayWithDelimiter    | 文字列→配列文字列（区切り文字で分割）                                                                                                                                                                                        | なし                                                                                                                                                     | -                                         |
| padLeft                       | 左文字埋め（0 埋め）                                                                                                                                                                                                         | なし                                                                                                                                                     | -                                         |
| padLeftWithSpace              | 左文字埋め（半角スペース）                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| padRightWithSpace             | 右文字埋め（半角スペース）                                                                                                                                                                                                   | なし                                                                                                                                                     | -                                         |
| padLeftWithChar               | 左文字埋め（任意文字）                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| padRightWithChar              | 右文字埋め（任意文字）                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| substring                     | 文字切り出し（指定位置）                                                                                                                                                                                                     | なし                                                                                                                                                     | -                                         |
| substringLeft                 | 文字切り出し（左から）                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| substringRight                | 文字切り出し（右から）                                                                                                                                                                                                       | なし                                                                                                                                                     | -                                         |
| getLength                     | 文字列長取得                                                                                                                                                                                                                 | なし                                                                                                                                                     | -                                         |
| getByteLength                 | バイト数取得                                                                                                                                                                                                                 | なし                                                                                                                                                     | -                                         |
| trimLeft                      | 左側の空白を除去                                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| trimRight                     | 右側の空白を除去                                                                                                                                                                                                             | なし                                                                                                                                                     | -                                         |
| replaceString                 | 文字列置換（指定文字列→指定文字列）                                                                                                                                                                                          | なし                                                                                                                                                     | -                                         |
| toHalfWidth                   | 全角→半角変換                                                                                                                                                                                                                | なし                                                                                                                                                     | -                                         |
| toFullWidth                   | 半角→全角変換                                                                                                                                                                                                                | なし                                                                                                                                                     | -                                         |
| maskWithAsterisk              | 指定範囲をアスタリスクにマスク                                                                                                                                                                                               | なし                                                                                                                                                     | -                                         |

### 使用例

- objType

  ```javascript
  sstUtil().objType({}); // "Object"
  sstUtil().objType([]); // "Array"
  ```

- isBoolean

  ```javascript
  sstUtil().isBoolean(true); // true
  sstUtil().isBoolean(1); // false
  ```

- isFunction

  ```javascript
  sstUtil().isFunction(() => {}); // true
  sstUtil().isFunction(123); // false
  ```

- isVnode

  ```javascript
  sstUtil().isVnode({ componentOptions: { tag: 'div' } }); // true
  sstUtil().isVnode({ tag: 'div' }); // false
  ```

- toDate

  ```javascript
  sstUtil().toDate('2024-01-15'); // Date object
  sstUtil().toDate('invalid'); // null
  ```

- formatDecimal

  ```javascript
  sstUtil().formatDecimal(123.4, 2); // "123.40"
  sstUtil().formatDecimal(100, 3); // "100.000"
  ```

- getYearGap

  ```javascript
  sstUtil().getYearGap(new Date(2020, 0, 15), new Date(2024, 0, 15)); // 4
  ```

- parseDate

  ```javascript
  sstUtil().parseDate('2024/01/15'); // Date object
  sstUtil().parseDate('20240115', 'YYYYMMDD'); // Date object
  sstUtil().parseDate(2024, 1, 15); // Date object
  ```

- getCurrentDate

  ```javascript
  sstUtil().getCurrentDate(); // Date object
  sstUtil().getCurrentDate('YYYY/MM/DD'); // "2024/11/24"
  ```

- getMonth

  ```javascript
  sstUtil().getMonth(new Date(2024, 0, 15)); // "01"
  sstUtil().getMonth(new Date(2024, 11, 15), 'M'); // "12"
  ```

- getDayCountOfYear

  ```javascript
  sstUtil().getDayCountOfYear(2024); // 366
  sstUtil().getDayCountOfYear(2023); // 365
  ```

- getStartOfMonth

  ```javascript
  sstUtil().getStartOfMonth(new Date(2024, 0, 15)); // Jan 01 2024 00:00:00
  ```

- nextDay

  ```javascript
  sstUtil().nextDay(new Date(2024, 0, 15)); // Jan 16 2024
  ```

- getWeekNumber

  ```javascript
  sstUtil().getWeekNumber(new Date(2024, 0, 15)); // 3
  sstUtil().getWeekNumber(null); // null
  ```

- isEquals

  ```javascript
  sstUtil().isEquals(5, 5); // true
  sstUtil().isEquals('test', 'test'); // true
  sstUtil().isEquals(null, undefined); // false
  ```

- isNotBlank

  ```javascript
  sstUtil().isNotBlank('test'); // true
  sstUtil().isNotBlank(''); // false
  ```

- isGreaterThan

  ```javascript
  sstUtil().isGreaterThan(10, 5); // true
  sstUtil().isGreaterThan(5, 10); // false
  ```

- isLessThanOrEqual

  ```javascript
  sstUtil().isLessThanOrEqual(10, 10); // true
  sstUtil().isLessThanOrEqual(10, 5); // false
  ```

- isDateOutOfRange

  ```javascript
  sstUtil().isDateOutOfRange(new Date(2024, 1, 15), new Date(2024, 0, 1), new Date(2024, 0, 31)); // true
  ```

- isDateWithinMonths

  ```javascript
  sstUtil().isDateWithinMonths(new Date(2024, 10, 15), 3); // true
  ```

- getMinuteFromTime

  ```javascript
  sstUtil().getMinuteFromTime('143045'); // "30"
  ```

- formatTime

  ```javascript
  sstUtil().formatTime('143045'); // "14:30:45"
  sstUtil().formatTime(new Date(), 'HH:MM'); // "14:30"
  ```

- isTimeWithinHours

  ```javascript
  sstUtil().isTimeWithinHours('143000', 2); // depends on current time
  ```

- addDateTime

  ```javascript
  sstUtil().addDateTime('20240115143045', 7, 'day'); // "20240122143045"
  sstUtil().addDateTime('2024/01/15 14:30:45', 5, 'hour'); // "2024/01/15 19:30:45"
  ```

- getDateTimeGap

  ```javascript
  sstUtil().getDateTimeGap('20240101', '20240115', 'day'); // 14
  sstUtil().getDateTimeGap('20240101000000', '20240101120000', 'hour'); // 12
  ```

- getDateTimePart

  ```javascript
  sstUtil().getDateTimePart(new Date(), 'year'); // "2024"
  sstUtil().getDateTimePart(new Date(), 'month'); // "11"
  ```

- dateTimeInRange

  ```javascript
  sstUtil().dateTimeInRange('20240115', '20240101', '20240131', 'date'); // true
  sstUtil().dateTimeInRange(15, 10, 20, 'number'); // true
  ```

- isNull

  ```javascript
  sstUtil().isNull(null); // true
  sstUtil().isNull(undefined); // true
  sstUtil().isNull(0); // false
  ```

- isHalfWidth

  ```javascript
  sstUtil().isHalfWidth('abc123'); // true
  sstUtil().isHalfWidth('全角'); // false
  ```

- isURL

  ```javascript
  sstUtil().isURL('https://example.com'); // true
  ```

- isInteger

  ```javascript
  sstUtil().isInteger(5); // true
  sstUtil().isInteger(5.5); // false
  ```

- subtractNumber

  ```javascript
  sstUtil().subtractNumber(10, 3); // 7
  ```

- ceilNumber

  ```javascript
  sstUtil().ceilNumber(1.21, 1); // 1.3
  ```

- merge

  ```javascript
  sstUtil().merge({ a: 1 }, { b: 2 }); // { a: 1, b: 2 }
  ```

- on

  ```javascript
  sstUtil().on(element, 'click', handler);
  ```

- addClass

  ```javascript
  sstUtil().addClass(element, 'active');
  ```

- setCookie

  ```javascript
  sstUtil().setCookie('username', 'john', 7); // 7日間有効
  ```

- removeResizeListener

  ```javascript
  sstUtil().removeResizeListener(element, handler);
  ```

- addTouchMove

  ```javascript
  sstUtil().addTouchMove(element, handler);
  ```

- trim

  ```javascript
  sstUtil().trim(' hello '); // "hello"
  ```

- arrayToStringWithoutDelimiter

  ```javascript
  sstUtil().arrayToStringWithoutDelimiter(['A', 'B', 'C']); // "ABC"
  ```

- padLeftWithSpace

  ```javascript
  sstUtil().padLeftWithSpace('AB', 5); // "   AB"
  ```

- substringLeft

  ```javascript
  sstUtil().substringLeft('Hello World', 5); // "Hello"
  ```

- replaceString

  ```javascript
  sstUtil().replaceString('hello world', 'world', 'JS'); // "hello JS"
  ```

### excelUtils

Excel ユーティリティ関数 ブラウザ上での xlsx 出力と、xlsx テンプレートの先頭行ヘッダー解析を行うための 共通ユーティリティを提供します。 主要なエクスポート: - `excelUtils()`: Excel 操作用 API を取得する関数 - `SstExcelApi`: excelUtils が返す API オブジェクトの型定義 提供する機能カテゴリ: - **テンプレート解析**: `extractHeadersFromTemplate` - **通常エクスポート**: `downloadRowsAsExcel` - **テンプレート準拠エクスポート**: `downloadRowsAsExcelFromTemplate` 制約: - テンプレート解析は `exceljs` の `workbook.xlsx.load` を使用するため、 旧来の `.xls` テンプレートは対象外です。 - 出力形式は `.xlsx` 固定です。

| メソッド名                 | 機能概要                                                                                              | パラメータ                                                    | 戻り値                                 |
| -------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | -------------------------------------- |
| extractHeadersFromTemplate | xlsx テンプレートの先頭行からヘッダー一覧を取得します。                                               | `templateFile` - xlsx テンプレートファイル                    | 先頭行から抽出したヘッダー文字列の配列 |
| downloadRowsAsExcel        | 行データをそのまま xlsx としてダウンロードします。 列順は行データ全体のキー出現順を基準に決定します。 | `rows` - 出力対象の行データ配列<br>`options` - 出力オプション | ダウンロード完了を待機する Promise     |

### useDialog

ダイアログ表示機能 アプリケーション内でダイアログを表示するための機能を提供します。 表示されたダイアログはユーザーの操作（肯定／否定）を待ち、結果を Promise<boolean> として返します。 主要なエクスポート: - `useDialog()`: ダイアログ表示用の関数 - `DialogApi`: useDialog が返す API オブジェクトの型定義 - `DialogOptions`: ダイアログ表示オプションの型定義 提供するメソッド: - `show(options)`: 任意のオプションでダイアログを表示 - `confirm(options)`: 確認ダイアログ（OK / キャンセル）を表示 - `info(options)`: 情報ダイアログ（キャンセルボタン非表示）を表示 - `success(options)`: 成功スタイルのダイアログを表示 - `warning(options)`: 警告スタイルのダイアログを表示 - `error(options)`: エラースタイルのダイアログを表示

| メソッド名 | 機能概要                                                                                    | パラメータ             | 戻り値           |
| ---------- | ------------------------------------------------------------------------------------------- | ---------------------- | ---------------- |
| show       | 任意のオプションでダイアログを表示します。 Promise<boolean> を返し、true が肯定（OK）です。 | options: DialogOptions | Promise<boolean> |
| confirm    | 確認ダイアログを表示します（OK / キャンセル）。                                             | options: DialogOptions | Promise<boolean> |
| info       | 情報ダイアログを表示します（キャンセルボタン非表示）。                                      | options: DialogOptions | Promise<boolean> |
| success    | 成功（success）スタイルのダイアログを表示します。                                           | options: DialogOptions | Promise<boolean> |
| warning    | 警告（warning）スタイルのダイアログを表示します。                                           | options: DialogOptions | Promise<boolean> |
| error      | エラー（error）スタイルのダイアログを表示します。                                           | options: DialogOptions | Promise<boolean> |

### useMessage

メッセージ表示機能 アプリケーション内でメッセージ（トースト/アラート）を表示するための機能を提供します。 メッセージはユーザーが手動で閉じるまで表示され続けます。 主要なエクスポート: - `useMessage()`: メッセージ表示用の関数 - `createMessage(type, title, content)`: メッセージをキューへ追加する関数 - `mountMessageContainer(appContext?)`: メッセージ表示コンテナをマウントする関数 - `MessageApi`: useMessage が返す API オブジェクトの型定義 提供するメソッド: - `info(content)`: 情報メッセージ（タイトルなし）を表示 - `infoWithTitle(title, content)`: 情報メッセージ（タイトルあり）を表示 - `success(content)`: 成功メッセージ（タイトルなし）を表示 - `successWithTitle(title, content)`: 成功メッセージ（タイトルあり）を表示 - `warning(content)`: 警告メッセージ（タイトルなし）を表示 - `warningWithTitle(title, content)`: 警告メッセージ（タイトルあり）を表示 - `error(content)`: エラーメッセージ（タイトルなし）を表示 - `errorWithTitle(title, content)`: エラーメッセージ（タイトルあり）を表示 - `closeAll()`: すべてのメッセージを閉じる - `closeInfo()`: 情報メッセージのみを閉じる - `closeSuccess()`: 成功メッセージのみを閉じる - `closeWarning()`: 警告メッセージのみを閉じる - `closeError()`: エラーメッセージのみを閉じる

| メソッド名       | 機能概要                         | パラメータ                     | 戻り値 |
| ---------------- | -------------------------------- | ------------------------------ | ------ |
| info             | 情報メッセージ（タイトルなし）   | content: string                | void   |
| infoWithTitle    | 情報メッセージ（タイトルあり）   | title: string, content: string | void   |
| success          | 成功メッセージ（タイトルなし）   | content: string                | void   |
| successWithTitle | 成功メッセージ（タイトルあり）   | title: string, content: string | void   |
| warning          | 警告メッセージ（タイトルなし）   | content: string                | void   |
| warningWithTitle | 警告メッセージ（タイトルあり）   | title: string, content: string | void   |
| error            | エラーメッセージ（タイトルなし） | content: string                | void   |
| errorWithTitle   | エラーメッセージ（タイトルあり） | title: string, content: string | void   |
| closeAll         | すべてのメッセージを閉じる       | なし                           | void   |
| closeInfo        | 情報メッセージのみを閉じる       | なし                           | void   |
| closeSuccess     | 成功メッセージのみを閉じる       | なし                           | void   |
| closeWarning     | 警告メッセージのみを閉じる       | なし                           | void   |
| closeError       | エラーメッセージのみを閉じる     | なし                           | void   |

### useNotification

通知表示機能 アプリケーション内で通知（トースト）を表示するための機能を提供します。 通知は指定時間後に自動で閉じます（デフォルト: 3秒）。 主要なエクスポート: - `useNotification()`: 通知表示用の関数 - `createMessage(type, title, content, duration?)`: 通知をキューへ追加する関数 - `mountMessageContainer(appContext?)`: 通知表示コンテナをマウントする関数 - `NotificationApi`: useNotification が返す API オブジェクトの型定義 提供するメソッド: - `info(content, duration?)`: 情報通知（タイトルなし）を表示 - `infoWithTitle(title, content, duration?)`: 情報通知（タイトルあり）を表示 - `success(content, duration?)`: 成功通知（タイトルなし）を表示 - `successWithTitle(title, content, duration?)`: 成功通知（タイトルあり）を表示 - `warning(content, duration?)`: 警告通知（タイトルなし）を表示 - `warningWithTitle(title, content, duration?)`: 警告通知（タイトルあり）を表示 - `error(content, duration?)`: エラー通知（タイトルなし）を表示 - `errorWithTitle(title, content, duration?)`: エラー通知（タイトルあり）を表示

| メソッド名       | 機能概要                   | パラメータ                                        | 戻り値 |
| ---------------- | -------------------------- | ------------------------------------------------- | ------ |
| info             | 情報通知（タイトルなし）   | content: string, duration?: number                | void   |
| infoWithTitle    | 情報通知（タイトルあり）   | title: string, content: string, duration?: number | void   |
| success          | 成功通知（タイトルなし）   | content: string, duration?: number                | void   |
| successWithTitle | 成功通知（タイトルあり）   | title: string, content: string, duration?: number | void   |
| warning          | 警告通知（タイトルなし）   | content: string, duration?: number                | void   |
| warningWithTitle | 警告通知（タイトルあり）   | title: string, content: string, duration?: number | void   |
| error            | エラー通知（タイトルなし） | content: string, duration?: number                | void   |
| errorWithTitle   | エラー通知（タイトルあり） | title: string, content: string, duration?: number | void   |

## Composables / エクスポート一覧

`@sst-cm/sst-components` からエクスポートされている composable・ユーティリティ・型の一覧。

| エクスポート名       | 種類            | 説明                                                                                                                       |
| -------------------- | --------------- | -------------------------------------------------------------------------------------------------------------------------- |
| `sstUtil`            | ユーティリティ  | 汎用ヘルパー関数群                                                                                                         |
| `excelUtils`         | ユーティリティ  | Excel テンプレート解析と xlsx 出力を提供するユーティリティ                                                                 |
| `useDialog`          | composable      | ダイアログを表示し `Promise<boolean>` を返す（`confirm`/`info`/`success`/`warning`/`error`）                               |
| `useMessage`         | composable      | メッセージ（アラート）を表示する（`info`/`success`/`warning`/`error` + `WithTitle` 版 + `closeAll`）。手動で閉じるまで表示 |
| `useNotification`    | composable      | 通知（トースト）を表示する（`info`/`success`/`warning`/`error` + `WithTitle` 版）。デフォルト3秒で自動消去                 |
| `useI18n`            | composable      | 多言語の翻訳関数 `t()` を取得する                                                                                          |
| `setLocale`          | 関数            | 言語を切り替える                                                                                                           |
| `setProjectLocale`   | 関数            | プロジェクト側の多言語メッセージを登録する                                                                                 |
| `currentLang`        | リアクティブRef | 現在の言語コード（例: `'ja'`）                                                                                             |
| `useSstHotkey`       | composable      | キーボードショートカットを登録する                                                                                         |
| `useSstHotkeyScope`  | composable      | スコープ付きホットキー登録（画面ごとに分離）                                                                               |
| `useFormChange`      | composable      | フォーム変更検知（低レベル）                                                                                               |
| `usePageChange`      | composable      | 画面離脱時ダーティチェック（`markClean` / `confirmValueChanged`）                                                          |
| `useCopyable`        | composable      | クリップボードコピー＋1.5秒フィードバック。`{ copied, copyToClipboard }` を返す                                            |
| `createSstVueConfig` | 関数            | Vuetify設定を構築するヘルパー                                                                                              |
| `CellEditorType`     | 型/enum         | SstGridのセルエディタ種別（`Select`, `Date`, `Number`, `Input`, `DateTime`, `Action`, `CodeName` 等）                      |

> **注意**: `useI18n`, `setLocale`, `useDialog`, `useMessage`, `useNotification`, `sstUtil` はプロジェクトの `unplugin-auto-import` 設定で**自動インポート**される。手動 import は不要。

### 使い方まとめ（AI生成時の正しいパターン）

```typescript
// ⭕ 正しい
const message = useMessage();
message.success('保存が完了しました');
message.error(t('errors.codes.efw-001-040-000-001'));
message.errorWithTitle('エラー', '保存に失敗しました');

// ❌ 間違い — 解構（destructure）禁止
const { showMessage } = useMessage(); // showMessage は存在しない

// ⭕ 正しい
const dialog = useDialog();
const ok = await dialog.confirm({ title: '確認', content: '削除しますか？' });

// ⭕ 正しい
const notify = useNotification();
notify.success('処理完了');
notify.infoWithTitle('情報', '開始しました', 5000);
```

### validationChecks プリセット名一覧

入力コンポーネントの `validationChecks` プロパティに渡せるプリセット名:

| プリセット名          | 説明                             |
| --------------------- | -------------------------------- |
| `required`            | 必須チェック                     |
| `email`               | メール形式                       |
| `phone`               | 電話番号形式（090-1234-5678）    |
| `halfwidthkana`       | 半角カナのみ                     |
| `hiragana`            | ひらがなのみ                     |
| `katakana`            | 全角カナのみ                     |
| `fullwithkana`        | ひらがな＋全角カナ               |
| `alpha`               | 半角英字のみ                     |
| `number`              | 数値（小数点・カンマ可）         |
| `integer`             | 整数のみ                         |
| `digits`              | 半角数字のみ（正の整数）         |
| `positiveint`         | 正の整数のみ                     |
| `positiveintdec`      | 正の整数＋小数                   |
| `nonnegativeint`      | 0以上の整数                      |
| `nonnegativeintdec`   | 0以上の整数＋小数                |
| `alnum`               | 半角英数のみ                     |
| `alint`               | 半角英数（大文字英字＋数字）     |
| `alintslash`          | 半角英数＋スラッシュ             |
| `alintunderline`      | 半角英数＋アンダーライン         |
| `alnumsymbol`         | 半角英数＋記号                   |
| `alnumkanasymbol`     | 半角英数＋カナ＋記号             |
| `alnumhyphenasterisk` | 半角英数＋ハイフン＋アスタリスク |
| `alnumhyphen`         | 半角英数＋ハイフン               |
| `telnum`              | 電話番号（数字＋ハイフン）       |
| `faxnum`              | FAX番号                          |
| `zipnum`              | 郵便番号                         |
| `date`                | 日付形式（YYYYMMDD）             |
| `rangedate`           | 日付範囲                         |
| `day`                 | 日のみ                           |
| `yearmonth`           | 年月形式（YYYYMM）               |
| `time`                | 時刻形式                         |
| `datetime`            | 日時形式                         |
| `jancode`             | JANコード（EAN-8/EAN-13）        |

**使用例:**

```vue
<SstTextField v-model="code" label="コード" :validationChecks="['alint']" :maxlen="10" />
<SstTextField v-model="email" label="メール" :validationChecks="['email']" required />
```

### copyable プロパティ（共通）

以下の入力コンポーネントは `copyable` プロパティ（`boolean`, デフォルト `false`）に対応しています。`true` にすると入力フィールド内にコピーアイコンが表示され、クリックで値をクリップボードにコピーします。

対応コンポーネント: `SstTextField`, `SstTextArea`, `SstNumberInput`, `SstSelect`, `SstCodeName`, `SstDateInput`, `SstDateTimeInput`, `SstTimePicker`, `SstTreeSelect`, `SstYearMonthPicker`, `SstVirtualScrollSelect`

```vue
<SstTextField v-model="code" label="コード" copyable />
```
