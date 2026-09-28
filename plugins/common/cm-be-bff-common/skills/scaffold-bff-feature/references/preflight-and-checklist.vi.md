# Tạo mới backend — kiểm tra file trước khi thực thi, checklist thực thi, các lưu ý

## Kiểm tra file trước khi thực thi (bắt buộc)

**Trước khi bắt đầu sinh file, nhất định phải thực hiện các kiểm tra dưới đây. Nếu không kiểm tra được thì phải dừng công việc và báo cho người dùng.**

### Các bước kiểm tra

Dẫn xuất `[タグ結合]` từ tài liệu thiết kế (ví dụ: `WebCoreSoSoMainte`), rồi kiểm tra xem 2 file jar dưới đây có chứa class đích hay không.

#### 1. Kiểm tra interface HTTP API của BFF

```bash
# Trường hợp Windows
jar -tf %USERPROFILE%\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar | findstr "[タグ結合]"

# Trường hợp PowerShell
jar -tf "$env:USERPROFILE\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar" | Select-String "[タグ結合]"
```

Ví dụ về kết quả đầu ra mong đợi:

```
com/cm/http/api/WebCoreSoSoMainteApi.class
com/cm/http/model/WebCoreSoSoMainteGetSoRequest.class
com/cm/http/model/WebCoreSoSoMainteGetSoSuccessResponse.class
...
```

#### 2. Kiểm tra stub gRPC

```bash
# Trường hợp Windows
jar -tf %USERPROFILE%\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar | findstr "[タグ結合]"

# Trường hợp PowerShell
jar -tf "$env:USERPROFILE\.m2\repository\com.cm\cm-be-spec\1.0.0-SNAPSHOT\cm-be-spec-1.0.0-SNAPSHOT.jar" | Select-String "[タグ結合]"
```

Ví dụ về kết quả đầu ra mong đợi:

```
com/cm/grpc/WebCoreSoSoMainteServiceGrpc.class
com/cm/grpc/GrpcWebCoreSoSoMainteGetSoRequestOuterClass.class
...
```

### Tiêu chí đánh giá

| Kết quả kiểm tra                       | Cách xử lý                                                      |
| ------------------------------ | --------------------------------------------------------- |
| ✅ Đã kiểm tra được cả hai class    | → Bắt đầu sinh file                                  |
| ❌ Thiếu dù chỉ một class | → **Dừng công việc** và báo thông điệp dưới đây cho người dùng |

#### Thông điệp khi dừng (truyền nguyên văn cho người dùng)

```
⚠️ Công việc đã bị dừng vì build chưa hoàn tất.

Không tìm thấy các class sau:
- [tên class không tìm thấy]

Hãy kiểm tra xem việc sinh và publish `cm-be-spec` đã hoàn tất chưa,
và `com.cm:cm-be-spec` có phân giải được từ JFrog Artifactory hay không, rồi thử lại.

Lệnh kiểm tra (tại repository này):

  ./gradlew classes
```

---

## Checklist thực thi

Khi sinh, hãy tiến hành theo thứ tự dưới đây (**tiền đề là việc sinh OpenAPI và build bằng skill OpenAPI đã hoàn tất trước đó**):

1. [ ] **Tạo branch làm việc** ← tạo branch bằng `git checkout -b feature/<機能名>` rồi mới bắt đầu sinh
2. [ ] Thực hiện kiểm tra file trước khi thực thi (xem phần "Kiểm tra file trước khi thực thi (bắt buộc)" ở trên) ← **nếu không tìm thấy class thì dừng lại**
3. [ ] Tạo ⑤ BFF ServiceMapping
4. [ ] Tạo ② interface gRPC client của BFF
5. [ ] Tạo ③ class triển khai gRPC client của BFF
6. [ ] Tạo ④ BFF ControllerMapping (chỉ nhóm tìm kiếm)
7. [ ] Tạo ⑥ interface BFF Service
8. [ ] Tạo ⑦ class triển khai BFF Service
9. [ ] Tạo ① controller của BFF
10. [ ] **Commit source do AI sinh ra** ← commit bằng `git commit -m "#<チケット番号> [ai] <機能名> 初期生成"` để ghi lại mốc ranh giới của lần sinh đầu tiên
11. [ ] Build và kiểm tra hoạt động (nếu cần **sửa tay sau lần sinh đầu tiên** thì mỗi lần commit với prefix `[manual]`)
12. [ ] **Trình bày phần chuyển giao sang phía microservice** ← truyền cho người dùng phần "Chuyển giao sang phía microservice" dưới đây

> **⚠️ Phạm vi**: Việc tạo branch ở bước 1, commit `[ai]` ở bước 10 và commit `[manual]` ở bước 11 **chỉ thực hiện trong luồng sinh lần đầu bằng skill này**.
> Nếu dùng Claude để sửa sau lần sinh đầu tiên thì tuân theo luồng phát triển thông thường, không cần tạo branch hay commit đặc biệt.

---

## Chuyển giao sang phía microservice

Skill này không sinh file phía microservice. Sau khi sinh xong phía BFF, hãy trình bày những nội dung dưới đây cho người dùng và
hướng dẫn họ thực hiện công việc sinh tương ứng ở phía repository `{targetMicroservice}`.

| Mục chuyển giao                         | Nội dung                                                                 |
| ------------------------------------ | -------------------------------------------------------------------- |
| Repository đích                       | `{targetMicroservice}`                                               |
| Tài liệu thiết kế                               | Tài liệu thiết kế đã dùng để sinh phía BFF (bao gồm định nghĩa SQL)                           |
| ID chức năng, tên chức năng, phân loại lớn/trung/nhỏ | Các giá trị đã trích xuất từ tài liệu thiết kế                                                 |
| `[タグ結合]`                         | Ví dụ: `WebCoreSoSoMainte` (triển khai `[タグ結合]ServiceImplBase`)      |
| Danh sách API                              | Kiểu request/response gRPC và loại API (tìm kiếm/đăng ký/cập nhật/xóa) theo từng `[operationId]` |

Những mục không có trong tài liệu thiết kế (phạm vi quyền, có phát hành event Kafka hay không, v.v.) sẽ được xác nhận với người dùng ở phía `scaffold-ms-feature`.

---

## Các lưu ý

- **Nghiêm cấm ghi đè lên file hiện có**: nếu file cùng tên chức năng đã tồn tại, phải xác nhận với người dùng rồi mới ghi đè
- **Không chỉnh sửa trực tiếp các class được sinh bởi OpenAPI**: `com.cm.http.model.*` / `com.cm.http.api.*` / `com.cm.grpc.*` là
  API bên ngoài tồn tại trong jar phụ thuộc của `cm-be-spec`, không có thực thể trong repository này. Cũng cấm tạo mới hay stub hóa chúng
- **Không chỉnh sửa trực tiếp đầu ra của annotation processor**: sản phẩm sinh ra của MapStruct / Lombok được xuất ra
  dưới `build/generated/sources/annotationProcessor/java/main`
- **Lưu ý tên field dạng mảng của MapStruct**: thuộc tính dạng mảng của gRPC sẽ tự động thành `[フィールド名]List` (ví dụ: `soDetail` → `soDetailList`), nên phải mapping tường minh bằng `@Mapping`
- **[Chỉ khi sinh lần đầu] Nhất định tạo branch làm việc rồi mới bắt đầu sinh**: hãy tách branch bằng `git checkout -b feature/<機能名>`. Ví dụ tên branch: `feature/so-mainte`
- **[Chỉ khi sinh lần đầu] Sau khi AI sinh xong thì nhất định commit rồi mới sửa tay**: để sau này có thể phân biệt được source do AI sinh và source sửa tay, hãy dùng các prefix commit dưới đây (nếu sửa bằng Claude sau lần sinh đầu tiên thì tuân theo luồng phát triển thông thường, không cần làm việc này)

  | prefix     | Ý nghĩa                                  | Ví dụ (số ticket: 123)         |
  | ---------- | ------------------------------------- | ------------------------------- |
  | `[ai]`     | Source do Claude sinh ra              | `#123 [ai] soMainte 初期生成`   |
  | `[manual]` | Source do người sửa tay (1 lần sau khi kiểm tra hoạt động) | `#123 [manual] soMainte 手修正` |

  ```bash
  # Nhất định thực hiện ngay sau khi AI sinh (trước khi sửa tay)
  git add .
  git commit -m "#<チケット番号> [ai] <機能名> 初期生成"

  # Thực hiện gộp 1 lần tại thời điểm đã kiểm tra được hoạt động
  git add .
  git commit -m "#<チケット番号> [manual] <機能名> 手修正"
  ```

  Việc tổng hợp số step được thực hiện như sau:

  ```bash
  # Phần do AI sinh
  git log --pretty=format:"%H" --grep="\[ai\]" | xargs -I{} git show --stat {}

  # Phần sửa tay (diff so với thời điểm commit [ai])
  git diff <aiコミットハッシュ> HEAD --stat
  ```
