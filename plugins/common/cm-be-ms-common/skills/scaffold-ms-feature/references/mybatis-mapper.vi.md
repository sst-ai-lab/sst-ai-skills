# Quy tắc MyBatis mapper XML

Áp dụng cho: `**/mybatis/**/*.xml`

Các quy tắc dưới đây áp dụng cho mọi MyBatis mapper PostgreSQL của một microservice. Ở những chỗ các repository khác nhau (cách bố trí XML, hành vi `ON CONFLICT`), mỗi cách làm được giữ lại dưới dạng một biến thể có tên bên dưới. Hãy theo biến thể mà mapper XML hiện có của repository này đang dùng; khi chưa có, hãy hỏi người dùng. Các quy tắc mapper ClickHouse thuộc về repository dùng ClickHouse, không thuộc tài liệu này.

## Cấu trúc

- Bắt đầu bằng DOCTYPE MyBatis 3.0 và đặt `namespace` thành **tên đầy đủ của mapper interface** — nó phải trùng khớp chính xác, nếu không các statement sẽ không bind được.
- Một `id` của `<select>/<insert>/<update>/<delete>` cho mỗi method của interface, với `parameterType` / `resultMap` (hoặc `resultType`) tương ứng.

## Mapping cột ↔ property là tường minh (không tự động camel-case)

`mybatis.configuration.map-underscore-to-camel-case` là **`false`** trong các service này. MyBatis sẽ **không** chuyển `ship_sch_date` → `shipSchDate`. Vì vậy bạn phải làm cho các cột khớp với property của entity bằng **một trong hai cách**:

- khai báo một `<resultMap>` map từng `property` tới `column` của nó (mẫu chiếm ưu thế — xem `{referenceMapperXml}`), **hoặc**
- đặt alias cho từng cột được select đúng bằng tên property (`select so.ownersono as ownerSoNo`).

Khi bạn thêm một field vào entity, hãy thêm cả `<result>` tương ứng (hoặc alias cột) ở đây — một cột không được map sẽ bị bỏ lặng lẽ.

- Giữ các danh sách cột dùng chung trong các đoạn `<sql>` tái sử dụng được (`<include refid="..."/>`).
- `... AS "headerName"` — lưu ý dấu ngoặc kép để giữ camel-case trong PostgreSQL.

## SQL phải trung thực với thiết kế

SQL được sinh/sửa phải tái tạo truy vấn của tài liệu thiết kế **nguyên trạng** — đây là quy tắc cứng:

- **Không được bỏ hay "đơn giản hoá"** các JOIN, subquery, `COALESCE(...)`, `GROUP BY`, window function, hay điều kiện lọc.
- **Giữ nguyên cú pháp đặc thù PostgreSQL**: các phép cast kiểu (`::TEXT`, `::numeric`, `::date`), `COALESCE`, `DISTINCT ON`, v.v. Đây là database PostgreSQL — đừng viết lại thành các dạng tương đương chỉ thuần ANSI.
- Giữ các từ khoá SQL viết hoa (theo kỳ vọng của Prettier-SQL / Checkstyle).

Các điểm cụ thể hơn:

- Giữ nguyên phép tính trên ngày và phần cú pháp đặc thù PostgreSQL còn lại: định dạng ngày `TO_CHAR(...)` / `TO_DATE(...)`, `interval '1 day'`, cast `::regclass`, tra cứu `information_schema`, `LOWER(...)`, v.v.
- Escape các toán tử so sánh làm hỏng XML: bọc `>=` / `<` trong `<![CDATA[ ... ]]>` (xem `{referenceMapperXml}`).
- Đừng bỏ cột khỏi danh sách mảng/cột, và giữ nguyên cấu trúc `unnest(...) … ON CONFLICT`.

## Chú thích — nguy hiểm của `--`

Các mapper hiện có ghi chú các cột bằng chú thích `--` ở cuối dòng (ví dụ `so.sono as sono, --出荷予定番号`). Cách này chỉ hoạt động **vì** mỗi `--` là thứ cuối cùng trên dòng vật lý của nó. Một chú thích `--` sẽ lặng lẽ biến **toàn bộ phần sau nó trên cùng một dòng** thành chú thích, nên nó nguy hiểm nếu SQL bị định dạng lại, bị minify, hoặc một đoạn bị chuyển lên một dòng đã có chú thích — đặc biệt là bên trong các block động `<if>`/`<foreach>`.

- **Ưu tiên chú thích dạng block `/* … */`** cho các ghi chú inline — đây là kiểu bắt buộc cho SQL mới được sinh ra.
- Nếu bạn giữ một chú thích `--`, nó phải là **token cuối cùng trên dòng của nó**, với một dấu xuống dòng trước bất kỳ SQL tiếp theo. Tuyệt đối không đặt SQL sau `--` trên cùng dòng, và tuyệt đối không để editor/formatter nối một dòng `--` vào SQL phía sau.

## SQL động & các lệnh ghi

- Dùng `<if>`, `<choose>`, `<foreach>` cho SQL có điều kiện/theo lô; phòng trường hợp `<foreach>` rỗng sinh ra SQL không hợp lệ (ví dụ `IN ()`).
- Các lệnh `update`/`insert` theo lô trả về số dòng bị ảnh hưởng; service so sánh nó với số dòng kỳ vọng để kiểm tra optimistic-lock / toàn vẹn (xem [service-layer.md](service-layer.md)) — hãy giữ cho lệnh đếm số dòng chính xác.
- Các lệnh ghi chạm vào bảng nghiệp vụ phải đặt các cột audit (`upd*` / `add*`) và tôn trọng cột optimistic-lock `exclusioncheck`.
- Các lệnh ghi chạm vào bảng log thì đặt các cột audit (`addusercd` / `addusername` / `addterminalcd`, và `adddatetime` qua `CURRENT_TIMESTAMP`).

---

## Bố cục XML — chính sách `mybatis-xml-layout`

### Biến thể `mapper-per-domain`

MyBatis mapper XML nằm ở `src/main/resources/mybatis/mapper/core/<domain>/<Name>Mapper.xml` và được ghép cặp với một interface `@Mapper` tại `{basePackage}.persistence.mapper.core.<domain>.<Name>Mapper`. Được nạp qua `mybatis.mapper-locations=classpath*:mybatis/**/*.xml`.

### Biến thể `mapper-plus-mapping`

XML của MyBatis nằm dưới `src/main/resources/mybatis/` và được chia thành hai loại (cả hai đều
được nạp bởi `mapper-locations: classpath*:mybatis/**/*.xml`):

- **`mybatis/mapper/<Name>Mapper.xml`** — các câu lệnh SQL; `namespace` = tên đầy đủ của
  mapper interface.
- **`mybatis/mapping/<Name>Mapping.xml`** — các định nghĩa `<resultMap>` dưới một namespace logic
  riêng, được các câu lệnh tham chiếu tới.

Hãy map tường minh mọi cột trong một `<resultMap>` (trong file `mapping/`), hoặc đặt alias cho cột đúng bằng tên property.

### Biến thể `mapper-tree`

XML của MyBatis nằm dưới `src/main/resources/mybatis/mapper/**` (nạp qua `mapper-locations: classpath*:mybatis/**/*.xml`). Các mapper interface nằm dưới `…persistence.mapper.core.**`. Nơi lưu dữ liệu là **PostgreSQL** (DB `{database}`).

> Một repository có hai datasource có thể thay vào đó giữ mapper XML của PostgreSQL dưới `mybatis/postgres/**` (các interface trong `…persistence.mapper.postgres.**`) để tách nó khỏi nơi lưu thứ hai. Hãy theo cách bố trí mà repository này đang dùng.

---

## UNNEST batch upsert — chính sách `unnest-on-conflict`

### Biến thể `do-nothing`

Các lần ghi thông lượng cao dùng một câu lệnh PostgreSQL duy nhất
`INSERT … SELECT … FROM unnest(<arrays>) … ON CONFLICT DO NOTHING` thay vì
insert từng dòng:

- Bind **một mảng cho mỗi cột**, theo **cùng thứ tự** với danh sách cột — một mảng lệch vị trí
  sẽ lặng lẽ ghi sai cột.
- Phân giải kiểu phần tử của mảng qua `typeHandler` mảng của dự án trên mỗi tham số `#{...}`
  (nó đặt đúng kiểu PostgreSQL). Hãy khớp mỗi mảng với kiểu cột của nó; đừng thêm
  các cast `::type[]` dư thừa trừ khi một tham số thực sự cần.
- Kết thúc bằng **`ON CONFLICT (<pk>) DO NOTHING`** — đây chính là thứ làm cho các lô được tiêu thụ lại
  trở nên idempotent. Đừng thay nó bằng một `INSERT` thuần (sẽ lỗi khi trùng) trừ khi
  thiết kế thực sự muốn ngữ nghĩa upsert-update.
- Chú thích: một chú thích dòng `--` nuốt phần còn lại của dòng, điều này rủi ro bên trong
  các block mảng/câu lệnh. Ưu tiên `/* … */`; nếu dùng `--`, hãy giữ nó là token cuối trên dòng.

### Biến thể `do-update-or-nothing`

- **Upsert theo lô** là luồng ghi chính, qua PostgreSQL `INSERT … SELECT … FROM unnest(#{…Arr, typeHandler=…}, …) … ON CONFLICT (<pk>) DO UPDATE/NOTHING`:
  - Các mảng đến từ một params builder, mỗi mảng được bind qua `typeHandler` mảng của dự án — **thứ tự phần tử mảng phải khớp chính xác thứ tự cột**; typeHandler đặt kiểu phần tử mảng PostgreSQL, nên không cần cast `::type[]`.
  - Kết thúc bằng **`ON CONFLICT (<pk>) DO UPDATE …`** cho các upsert dạng đọc-sửa-ghi (ví dụ số dư) hoặc `DO NOTHING` cho các insert idempotent — hãy khớp với ý định của câu lệnh hiện có.
  - Giữ câu lệnh theo tập hợp, không phải theo từng dòng — service lo việc chia chunk (xem [service-layer.md](service-layer.md)).
