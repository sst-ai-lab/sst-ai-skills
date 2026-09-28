# Quy ước phát triển: Backend (Java / Spring Boot)

## 1. Mở đầu

### 1.1 Mục đích và phạm vi áp dụng của quy ước này

Quy ước này định nghĩa các quy tắc và khuyến nghị mà lập trình viên backend (Java / Spring Boot) phải tuân thủ.  
Phạm vi áp dụng là toàn bộ repository backend của dự án này (các file `.java`).

### 1.2 Quy ước tham khảo

Quy ước này được xây dựng dựa trên style guide chính thức dưới đây và cấu hình Checkstyle của dự án.  
Đối với những nội dung không được ghi trong quy ước này, hãy tham khảo tài liệu dưới đây.

| Quy ước | URL |
|------|-----|
| Google Java Style Guide | [https://google.github.io/styleguide/javaguide.html](https://google.github.io/styleguide/javaguide.html) |

### 1.3 Về các quy tắc được áp dụng và kiểm tra tự động bằng công cụ

Trong dự án này, việc format, phân tích tĩnh và test được tự động hóa bằng công cụ. Phán định cuối cùng của từng công cụ tuân theo plugin quy ước Gradle dùng chung (`com.sst.fw.build`???) và cấu hình của từng repository.  
Nếu có khác biệt giữa quy ước này và cấu hình công cụ, lấy cấu hình công cụ làm chuẩn.

| Thời điểm | Công cụ / Command | Nội dung | Khi thất bại |
|---|---|---|---|
| Khi lưu file | Prettier (khi `editor.formatOnSave` được bật) | Tự động format trên editor | Kiểm tra lại xử lý lưu file |
| `git commit` | lint-staged → Prettier | Format các file `.java` / `.sql` đã stage và stage lại nội dung sau khi format | Commit thất bại |
| `git commit` | commitlint | Kiểm tra commit message theo định dạng Conventional Commits | Commit thất bại |
| Trước `git push` | `./gradlew clean check` | Thực thi Prettier, Checkstyle, SpotBugs, JUnit | Hủy push |
| Sau `git push` | AWS CodeBuild (SonarQube / Amazon Inspector) | Phán định quality gate, quét lỗ hổng của SBOM | Xử lý tùy theo kết quả CI |

Các kiểm tra chính bao gồm trong `./gradlew clean check` như sau.

| Công cụ | Vai trò | Cách xử lý |
|---|---|---|
| Prettier | Kiểm tra chênh lệch format của Java / SQL | Vi phạm thì build thất bại |
| Checkstyle | Kiểm tra quy ước source code dựa trên Google Java Style Guide | Vi phạm thì build thất bại |
| SpotBugs | Phân tích tĩnh các bug pattern, vấn đề tiềm ẩn | Vi phạm thì build thất bại |
| JUnit | Thực thi unit test | Test thất bại thì build thất bại |
| JaCoCo | Sinh báo cáo coverage | Hiện tại không đặt ngưỡng |
| ErrorProne / NullAway | Kiểm tra lỗi và an toàn null tại thời điểm compile | Hiện tại chỉ cảnh báo |

Các cấu hình dùng chung như Checkstyle, SpotBugs được quản lý ở `sst-fw-be-starter-platform`, phía từng repository không ghi đè nội dung kiểm tra.  
Ngoài ra, thứ tự sắp xếp import (nằm ngoài phạm vi của Prettier), nội dung viết trong Markdown・YAML・JSON, cách đặt tên và quyết định thiết kế về mặt nghiệp vụ thì lập trình viên tự kiểm tra thủ công.

File cấu hình Checkstyle: `sst-fw-be-starter-platform/fw-be-starter-build/src/main/resources/com/fw/build/checkstyle.xml`

---

## 2. Cấu trúc dự án

### 2.1 GitHub repository

**Framework (tiền tố sst-fw-)**

[sst-fw-be-starter-platform](https://github.com/suzuyo-cm/sst-fw-be-starter-platform)<br>
[sst-fw-be-core](https://github.com/suzuyo-cm/sst-fw-be-core)<br>
[sst-fw-be-http](https://github.com/suzuyo-cm/sst-fw-be-http)<br>
[sst-fw-be-grpc](https://github.com/suzuyo-cm/sst-fw-be-grpc)<br>
[sst-fw-be-security](https://github.com/suzuyo-cm/sst-fw-be-security)<br>

**Ứng dụng (tiền tố cm-be-)**

[cm-be-spec](https://github.com/suzuyo-cm/cm-be-spec)<br>
[{repo}](https://github.com/suzuyo-cm/{repo})<br>

### 2.2 Cấu trúc package

Ranh giới trách nhiệm của từng tầng (Controller / Service / gRPC client / Mapping) được định nghĩa như sau.  
`dto/` dùng cho HTTP request/response, `model/` dùng cho gRPC message, phân biệt rõ mục đích sử dụng.

Package của chức năng nghiệp vụ được tổ chức theo cấp bậc `{domain}/{subdomain}/{feature}`. `{domain}` biểu thị phân loại trung, `{subdomain}` biểu thị phân loại nhỏ, và folder chức năng dùng tên chức năng lowerCamelCase không chứa số thứ tự. Mỗi tầng sử dụng cùng folder phân loại・chức năng, giữ được sự tương ứng giữa tên chức năng và tên class.

#### 2.2.1 BFF

```
...
src/main/java/{basePackage}/　　　　　　　　　　　　　　　　　　　　　    　　 **
├── {ApplicationClass}.java                                                 ** Điểm khởi đầu (entry point) của Spring Boot
├── controller/                                                             ** Folder controller
│   └── {domain}/                                                           ** Phân loại trung (ví dụ: core)
│       └── {subdomain}/                                                    ** Phân loại nhỏ (ví dụ: so)
│           └── {feature}/                                                  ** Tên chức năng lowerCamelCase (ví dụ: soPlanSearch)
│               └── {Feature}Controller.java                                ** File controller
├── service/                                                                ** Folder service
│   ├── auth/                                                               ** Folder service xác thực
│   └── {domain}/                                                           ** Phân loại trung
│       └── {subdomain}/                                                    ** Phân loại nhỏ
│           └── {feature}/                                                  ** Tên chức năng
│               ├── {Feature}Service.java                                   ** File service
│               └── {Feature}ServiceImpl.java                               **
├── infrastructure/                                                         **
│   ├── grpc/                                                               ** Folder grpc
│   │   └── {domain}/                                                       ** Phân loại trung
│   │       └── {subdomain}/                                                ** Phân loại nhỏ
│   │           └── {feature}/                                              ** Tên chức năng
│   │               ├── {Feature}Client.java                                ** File client
│   │               └── {Feature}ClientImpl.java                            **
│   ├── mapping/                                                            ** Folder mapping
│   │   └── {domain}/                                                       ** Phân loại trung
│   │       └── {subdomain}/                                                ** Phân loại nhỏ
│   │           └── {feature}/                                              ** Tên chức năng
│   │               ├── {Feature}ServiceMapping.java                        ** File mapping cho service
│   │               └── {Feature}ControllerMapping.java                     ** File mapping cho controller
│   ├── message/                                                            ** Folder Kafka producer (gửi message bất đồng bộ)
│   ├── repository/                                                         ** Folder quản lý session Redis
│   ├── azure/                                                              ** Folder Azure Computer Vision (OCR)
│   ├── bedrock/                                                            ** Folder AWS Bedrock (AI)
│   ├── logging/                                                            ** Folder log vận hành (操作ログ)
│   └── zxing/                                                              ** Folder xử lý barcode
├── dto/                                                                    ** Folder class dữ liệu chỉ dùng nội bộ BFF
│   ├── app/                                                                ** Trạng thái ứng dụng (context quyền hạn v.v.)
│   ├── request/                                                            ** Request nội bộ BFF
│   └── response/                                                           ** Response nội bộ BFF
├── model/                                                                  ** Folder class bổ sung・mở rộng model OpenAPI
├── security/                                                               ** Folder xác thực・phân quyền JWT
├── configuration/                                                          ** Folder configuration
│   └── GrpcClientConfiguration.java                                        **
├── annotation/                                                             ** Folder annotation tự định nghĩa
├── aspect/                                                                 ** Folder AOP (xử lý xuyên suốt như log vận hành)
├── common/                                                                 ** Folder exception dùng chung・xử lý JSON
├── constant/                                                               ** Folder class hằng số
└── util/                                                                   ** Folder utility
...
```

#### 2.2.2 Microservice

```
...
src/main/java/{basePackage}/
├── {ApplicationClass}.java                                                 ** Điểm khởi đầu (entry point) của Spring Boot
├── grpc/                                                                    ** Folder gRPC
│   └── {domain}/                                                           ** Phân loại trung
│       └── {subdomain}/                                                    ** Phân loại nhỏ
│           └── {feature}/                                                  ** Tên chức năng
│               └── {Feature}Grpc.java                                     ** File service gRPC
├── service/                                                                ** Folder service
│   └── {domain}/                                                           ** Phân loại trung
│       └── {subdomain}/                                                    ** Phân loại nhỏ
│           └── {feature}/                                                  ** Tên chức năng
│               ├── {Feature}Service.java                                  ** File service
│               └── {Feature}ServiceImpl.java                              **
├── infrastructure/                                                         **
│   └── mapping/                                                            ** Folder mapping
│       └── {domain}/                                                       ** Phân loại trung
│           └── {subdomain}/                                                ** Phân loại nhỏ
│               └── {feature}/                                              ** Tên chức năng
│                   └── {Feature}ServiceMapping.java                       ** File mapping cho service
├── persistence/                                                            **
│   ├── mapper/                                                             ** Folder mapper
│   │   └── {domain}/                                                       ** Phân loại trung
│   │       └── {subdomain}/                                                ** Phân loại nhỏ
│   │           └── {feature}/                                              ** Tên chức năng
│   │               └── {feature}Mapper.java                                ** File mapper
│   └── model/                                                              ** Folder model
│       └── {domain}/                                                       ** Phân loại trung
│           └── {subdomain}/                                                ** Phân loại nhỏ
│               └── {feature}/                                              ** Tên chức năng
│                   └── {Feature}Entity.java                                ** File entity
├── dto/                                                                    ** Folder class dữ liệu dùng nội bộ microservice
├── configuration/                                                          ** Folder configuration
├── helper/                                                                 ** Folder helper
├── util/                                                                   ** Folder utility
...
```

XML của MyBatis (`src/main/resources/mybatis/mapper/`) cũng được đặt theo hệ thống phân loại `{domain}/{subdomain}/{feature}/`.

---

## 3. Quy tắc đặt tên

> Về cách đặt tên các thuật ngữ nghiệp vụ (đối tác giao dịch・kho・tên domain v.v.), hãy tham khảo phần định nghĩa thuật ngữ trong [DB命名規則](../common/503847_feature_db_convention.md).

| Đối tượng | Quy tắc | Ví dụ |
|------|------|----|
| Tên class | UpperCamelCase | `OrderService`, `StockController` |
| Tên interface | UpperCamelCase | `OrderService`, `StockRepository` |
| Enum / Record / annotation | UpperCamelCase | `OrderStatus`, `OrderDto` |
| Tên method | lowerCamelCase | `findOrderById()`, `updateStock()` |
| Tên biến | lowerCamelCase | `orderId`, `warehouseCode` |
| Hằng số | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_PAGE_SIZE` |
| Tên package | Toàn bộ chữ thường | `{basePackage}` |
| Tham số kiểu (type parameter) | 1 ký tự hoặc dạng `XxxT` | `T`, `E`, `ResponseT` |

### 3.1 Cách đặt tên riêng theo kỹ thuật (hậu tố class)

Để có thể phán đoán vai trò từ tên file, thống nhất các hậu tố như sau.

| Tầng | Hậu tố | Ví dụ |
|------|----------|-----|
| Controller | `Controller` | `OrderController` |
| Interface Service | Không có hậu tố | `OrderService` |
| Implementation của Service | `ServiceImpl` | `OrderServiceImpl` |
| Implementation của gRPC service | `Grpc` | `OrderGrpc` |
| Interface gRPC client | `Client` | `OrderClient` |
| Implementation của gRPC client | `ClientImpl` | `OrderClientImpl` |
| Mapping của Service | `ServiceMapping` | `OrderServiceMapping` |
| Mapping của Controller | `ControllerMapping` | `OrderControllerMapping` |
| Mapper MyBatis | `Mapper` | `OrderMapper` |
| Entity | `Entity` | `OrderEntity` |

### 3.2 Tên biến

Đặt tên dựa trên tên cột DB hoặc thuật ngữ tiếng Anh đã được định nghĩa trong spec nghiệp vụ. Nếu tên cột DB là `snake_case` thì chuyển sang `camelCase` cho phù hợp quy tắc đặt tên của Java, nhưng không thay thế bản thân từ đó bằng một từ tiếng Anh khác hay chữ romaji tiếng Nhật.

| Tên cột DB | Tên biến Java | Ghi chú |
|---|---|---|
| `item_id` | `itemId` | Giữ nguyên từ và ý nghĩa của DB |
| `rcv_qty` | `rcvQty` | Giữ nguyên từ viết tắt đã được phê duyệt `rcv` |
| `is_active` | `isActive` | Giữ nguyên ý nghĩa giá trị đúng/sai |
| `warehouse_cd` | `warehouseCd` | Giữ nguyên hậu tố code theo quy ước DB |

- Field, biến local, tham số method viết bằng lower camel case (`camelCase`)
- Không sử dụng chữ romaji tiếng Nhật (`soshiki`, `kanri`, `kenpin` v.v.)
- Chỉ sử dụng những từ viết tắt đã được phê duyệt trong quy ước đặt tên chung hoặc quy ước đặt tên DB; những từ không có trong danh sách thì về nguyên tắc không viết tắt
- Tránh những tên không rõ đối tượng hay ý nghĩa như `data`, `info`, `value`, `temp`
- Không nhúng tên kiểu vào tên biến (không dùng `orderString`, `countInt` v.v.)
- Không sử dụng tên biến 1 ký tự vô nghĩa. Tuy nhiên, `i`, `j` v.v. chỉ được phép dùng cho biến đếm vòng lặp

```java
// ✅ Giữ nguyên từ ngữ của DB・thuật ngữ nghiệp vụ và chỉ rõ đối tượng
String warehouseCode;
Integer rcvQty;
LocalDate shippingDate;

// ❌ Romaji tiếng Nhật, từ mơ hồ, nhúng tên kiểu
String soukoCd;
Integer dataInt;
LocalDate dateValue;
```

#### 3.2.1 Kiểu boolean

**Nguyên tắc cơ bản: đặt tên sao cho khi đọc trong câu lệnh `if` thì có nghĩa và hiểu được đang phán định điều gì.**

Biến boolean lấy dạng khẳng định làm cơ bản, và đặt tên biểu thị ý nghĩa như trạng thái・sự tồn tại・khả năng, chứ không chỉ đơn thuần là kiểu dữ liệu.

❌ **Cách đặt tên nên tránh**

- Các từ viết tắt có nguồn gốc tiếng Nhật không rõ kiểu hay ý nghĩa như `xxxFlg`, `xxxFlag`, `xxxKbn`
- Dạng phủ định gây phủ định kép khi phán định điều kiện như `isInvalid`, `isNotAvailable`
- Những tên không rõ đối tượng hay nội dung phán định như `exists`, `valid`, `value`
- Những tên dễ bị lẫn với phán đoán nghiệp vụ thay vì trạng thái đơn thuần như `shouldXxx`, `needsXxx`

`is`, `has`, `can` không phải là tiền tố bắt buộc. Tùy theo ý nghĩa của phán định, chọn tên tự nhiên nhất trong số các dạng sau.

| Cách đặt tên | Nội dung biểu thị | Ví dụ |
|---|---|---|
| `is` / `are` | Trạng thái・tính chất | `isActive`, `isInitialized`, `areItemsValid` |
| `is...ed` | Trạng thái một xử lý cụ thể đã hoàn tất | `isLoaded`, `isCalculated`, `isUpdated` |
| `has` | Sở hữu・tồn tại・bao hàm | `hasPermission`, `hasAttachment`, `hasChildren` |
| `can` | Khả năng・cho phép・tính khả thi | `canEdit`, `canRetry`, `canAllocate` |
| `is...able` | Trạng thái có thể・thực thi được | `isEditable`, `isRetryable`, `isAllocatable` |
| Đối tượng + vị ngữ | Khi chỉ dùng `is`・`has`・`can` khó biểu thị được quan hệ | `userExists`, `orderContainsItem` |
| `is...Required` | Sự cần thiết về mặt nghiệp vụ | `isApprovalRequired`, `isRetryRequired` |

Các từ như `exists`, `contains`, `includes`, `supports`, `requires`, `allows`, `matches` có thể dùng làm tên biến. Khi giữ kết quả phán định vào biến, hãy đặt tên sao cho hiểu được đối tượng và nội dung phán định. Khi biểu thị khả năng hoặc sự cho phép thì dùng `canXxx`; khi biểu thị trạng thái hay tính chất có thể thực thi bằng tính từ thì có thể dùng `isXxxable`. Không dùng `able` đứng một mình hay dạng `xxxAble` có thứ tự từ không tự nhiên, mà phải là tính từ tự nhiên trong tiếng Anh.

```java
boolean isActive = ...;                 // Có đang ở trạng thái hiệu lực hay không
boolean hasPermission = ...;            // Có quyền hạn hay không
boolean canEdit = ...;                  // Có thể sửa hay không
boolean orderContainsItem = ...;        // Đơn hàng có chứa sản phẩm hay không
boolean systemSupportsEncryption = ...; // Có hỗ trợ mã hóa hay không
boolean userExists = ...;               // Kết quả phán định có chỉ rõ đối tượng
boolean isApprovalRequired = ...;       // Phán đoán nghiệp vụ về việc có cần phê duyệt hay không
```

Ngoài ra, khi biểu thị sự sở hữu・bao hàm đơn thuần thì ưu tiên dạng `has` như `hasItem`, và khi cần làm rõ quan hệ giữa các đối tượng thì dùng dạng đối tượng đứng trước như `orderContainsItem`.

#### 3.2.2 Kiểu boolean và kiểu Boolean

Khi giá trị chắc chắn được xác định là `true` hoặc `false`, hãy dùng kiểu nguyên thủy `boolean`. Về nguyên tắc không dùng kiểu `Boolean`, chỉ dùng khi cần xử lý `null` với ý nghĩa "không chỉ định", "không rõ", "NULL trên DB".

Không dùng `Boolean` cho những biến hay field của DTO mà không cần phân biệt `null` và `false`. Khi sử dụng, phải làm rõ về mặt thiết kế rằng `null` có ý nghĩa gì.

| Vị trí sử dụng | Kiểu | Quy tắc |
|---|---|---|
| Biến local・tham số・giá trị trả về | `boolean` | Về nguyên tắc dùng `boolean`. Không dùng `Boolean` |
| Tham số kiểu của generics | `Boolean` | Chỉ dùng khi không thể chỉ định kiểu nguyên thủy, như `List<Boolean>`, `Optional<Boolean>` |
| Field Entity tương ứng cột cho phép NULL của DB | `Boolean` | Chỉ dùng khi cần giữ giá trị NULL của DB |
| DTO cập nhật một phần JSON (PATCH) | `Boolean` | Chỉ dùng khi cần phân biệt `null` (không chỉ định) và `false` (chỉ định tường minh) |

#### Getter của kiểu boolean và kiểu Boolean

Lombok và OpenAPI Generator có quy tắc tự sinh getter cho kiểu boolean khác nhau. Hãy ý thức class đó được sinh bởi cái nào, rồi kiểm tra tên getter ở phía gọi.

**Lombok (DTO / Entity)**

Hành vi khác nhau giữa kiểu nguyên thủy `boolean` và kiểu wrapper `Boolean`. Với `boolean` thì không làm trùng lặp tiền tố `is` của tên field, còn `Boolean` thì luôn dùng tiền tố `get`.

```java
// Kiểu boolean: getter là isActive()
private boolean active;

// Kiểu Boolean: getter là getActive()
private Boolean active;

// Khi kiểu boolean và tên field có tiền tố is: không trùng lặp, getter vẫn là isActive()
private boolean isActive;

// Khi kiểu Boolean và tên field có tiền tố is: getter trở thành getIsActive()
private Boolean isActive;
```

**DTO do OpenAPI Generator sinh ra**

Model được sinh ra luôn xuất ra dưới dạng kiểu wrapper `Boolean`, và bất kể tên field có tiền tố `is` hay không, getter luôn có tiền tố `get` (không có xử lý coi như `boolean` nguyên thủy và giữ tiền tố `is` như Lombok).

```java
// cm-be-spec/build/generated/.../AuthCommonEntraPostTokenRequest.java
private Boolean forceLogin = false;
public Boolean getForceLogin() { ... }

// Property có tiền tố is như isActive thì getter cũng trở thành getIsActive()
```

#### 3.2.3 Kiểu String

Sử dụng danh từ có ý nghĩa rõ ràng về giá trị. Không thêm hậu tố tên kiểu như `xxxStr`, `xxxString`.

```java
// ✅
String orderId;
String warehouseName;
String warehouseCode;

// ❌
String orderIdStr;
String nameString;
```

#### 3.2.4 Kiểu số (int / long / double v.v.)

Thêm hậu tố phù hợp với ý nghĩa của giá trị. Không thêm hậu tố tên kiểu như `xxxNum`, `xxxInt`.

| Mục đích | Ví dụ hậu tố | Ví dụ |
|------|------------|-----|
| Số lượng bản ghi・số cái | `Count`, `Size` | `itemCount`, `pageSize` |
| Số lượng | `Quantity`, `Amount` | `stockQuantity`, `orderAmount` |
| Số tiền | `Price`, `Amount`, `Fee` | `unitPrice`, `totalAmount` |
| Thứ tự・trình tự | `Order`, `Sequence` | `sortOrder`, `displaySequence` |
| Giới hạn trên・dưới | `Max`, `Min`, `Limit` | `maxRetryCount`, `limitSize` |

---

## 4. Cách viết comment

### 4.1 Triết lý cơ bản

Comment được viết để bổ sung bối cảnh・ý định・ràng buộc・điểm thỏa hiệp mà chỉ đọc code thì không nắm được. Trước khi thêm comment, hãy xem xét liệu có thể diễn đạt bằng tên biến・tách method・thiết kế class hay không.

| Thông tin | Cách biểu đạt | Ví dụ |
|---|---|---|
| What (làm gì) | Biểu đạt bằng tên biến・tên method・tên class và phần implementation | `confirmOrder` là xử lý chốt đơn hàng |
| How (làm như thế nào) | Biểu đạt bằng code | Đổi status sang `CONFIRMED` và set thời điểm chốt |
| Why (vì sao làm như vậy) | Biểu đạt bằng comment khi cần thiết | Có quy tắc nghiệp vụ ngăn thay đổi sau khi phát hành nhãn xuất hàng |
| Who / When (ai・khi nào thay đổi) | Quản lý bằng lịch sử commit của Git hoặc quản lý dự án | Người thay đổi・ngày thay đổi・số hiệu case |

Comment chỉ ghi nội dung hiện tại vẫn còn hiệu lực, và khi thay đổi implementation thì phải kiểm tra comment liên quan có khớp với implementation hay không. Comment không khớp thì sửa hoặc xóa.

### 4.2 Comment inline

Comment implementation (`//`) chỉ giới hạn ở việc bổ sung cho phần implementation hoàn tất trong nội bộ class đó, và được viết ở method `private` hoặc field `private`. Sau `//` bắt buộc phải có một dấu cách.

Với class, method, field `public` hoặc `protected` được tham chiếu từ file khác, hãy ghi spec・ràng buộc bằng Javadoc chứ không phải comment inline.

Trong các trường hợp thuộc một trong những điều sau đây thì viết comment inline.

- Cần bổ sung lý do của quy tắc nghiệp vụ
- Cần duy trì tính tương thích với spec bên ngoài
- Có ràng buộc về hiệu năng・bảo mật・transaction
- Có lý do cho việc áp dụng một implementation trông thoạt nhìn không tự nhiên

#### Bổ sung khi khó hiểu mục đích từ code

Khi chỉ đọc code không hiểu được mục đích hay đối tượng của xử lý, ví dụ như khi gọi library・framework bên ngoài, SQL phức tạp, hay block gom nhiều xử lý, thì có thể viết comment bổ sung cho What. Không giải thích nội dung xử lý một cách từng chữ, mà ghi ngắn gọn mục đích・đối tượng・tiền đề không đọc được từ code.

Comment chỉ ghi nội dung hiện tại vẫn còn hiệu lực, và khi thay đổi implementation thì phải kiểm tra comment liên quan có khớp với implementation hay không. Comment không khớp thì sửa hoặc xóa.

```java
// ✅ Vì chỉ đọc code khó hiểu mục đích nên bổ sung mục đích của xử lý
// Sau khi chốt xuất hàng thì thực hiện phân bổ tồn kho, và dùng kết quả phân bổ ở xử lý xuất hàng tiếp theo.
allocateStock(order);

// ✅ Lý do của giá trị cấu hình đặc biệt
int maxRetry = 3; // Vì Rate Limit của API bên ngoài chỉ cho tối đa 3 lần trong 1 giây

// ✅ Bối cảnh của quy tắc nghiệp vụ đặc biệt
// Do quy tắc mới kèm theo việc chi phí logistics tăng cao, áp dụng phụ phí cho hàng cỡ lớn kể cả ngoài đảo xa.
if (item.isLarge() && !address.isIsland()) {
    fee += 1000;
}

// ✅ Lý do duy trì tương thích với spec bên ngoài
request.setHeader("X-Client-Version", clientVersion); // Vì client cũ tham chiếu header này

// ✅ Ràng buộc về hiệu năng
Pageable pageable = PageRequest.of(page, 100); // Vì giới hạn số bản ghi lấy tối đa từ DB là 100

// ✅ Ràng buộc về bảo mật
recordLoginResult(userId); // Không xuất password hay token ra tra cứu log・APM

// ✅ Lý do về ranh giới transaction
publisher.publish(event); // Vì gửi sau khi commit DB để không thông báo dữ liệu đã rollback

// ❌ Lặp lại tên method và nội dung xử lý
validateOrder(order); // Kiểm tra đơn hàng

// ❌ Không giải thích ý nghĩa hay lý do của giá trị
int timeout = 30; // Timeout

// ❌ Giải thích lại nguyên xi code
int itemCount = items.size(); // Lấy số lượng sản phẩm
```

### 4.3 Những điều bị cấm

#### Không quản lý lịch sử thay đổi bằng comment

Không quản lý bằng comment hay Javadoc các comment Start/End chỉ ra vị trí sửa, hay các thông tin lịch sử như người tạo・ngày tạo・ngày sửa・nội dung sửa・số hiệu case. Đơn vị thay đổi và lịch sử công việc được quản lý bằng Git.

```java
// ❌ Không để lại comment Start/End hay lịch sử thay đổi trong source code
// 2026-08-19 U2000-000 オーダーID処理改善 START
// 2026-08-21 山田 U2000-001 対応開始
confirmOrder(order);
```

#### Không comment out code không cần thiết

Code trở nên không cần thiết do việc sửa đổi thì phải xóa, không để lại ở dạng comment out. Kể cả khi cần tham khảo hay phục hồi trong tương lai, vì có thể truy vết bằng lịch sử commit của Git nên không giữ lại trong source code.

```java
// ✅ Xóa code không cần thiết
public void processOrder(String orderId) {
    validateOrder(orderId);
    updateOrder(orderId);
}

// ❌ Không để code không cần thiết ở dạng comment out
public void processOrder(String orderId) {
    // validateOrder(orderId);
    // updateOrder(orderId);
    newProcessOrder(orderId);
}
```

### 4.4 Javadoc

Javadoc (`/** ... */`) là bản hướng dẫn truyền đạt spec cho phía gọi class hay method đó. Với các phần tử `public` hoặc `protected` được tham chiếu từ file khác, hãy ghi bằng Javadoc các spec・ràng buộc mà phía gọi cần biết. Logic phức tạp của các phần tử `private` hoàn tất trong nội bộ class thì ghi ở comment inline, không ghi vào Javadoc.

#### 4.4.1 Quy tắc viết

- Ở phần đầu, ghi ngắn gọn bằng 1 câu tiếng Nhật nó làm gì, và câu tóm tắt kết thúc bằng dấu chấm (`.`). Không dùng các cụm từ khuôn mẫu dài dòng như "Class này là", "Method này là"
- Bằng `@param`, `@return`, `@throws` v.v., ghi spec của tham số・giá trị trả về・exception, cùng các ràng buộc mà phía gọi cần biết như hành vi khi null・giá trị rỗng・giá trị biên・khi bất thường
- Về nguyên tắc viết bằng tiếng Nhật. `@author` chỉ được ghi cho người tạo bản đầu tiên. Người thay đổi・ngày thay đổi・nội dung thay đổi sau bản đầu được quản lý bằng lịch sử Git, không ghi thêm vào Javadoc. Không ghi `@since`, lịch sử sửa đổi, số hiệu case tương ứng
- Method `@Override` có thể lược bỏ nếu hợp đồng đã được giải thích đầy đủ trong Javadoc của lớp cha. Khi bổ sung spec hay ràng buộc riêng của implementation thì dùng `{@inheritDoc}`

```java
/**
 * Lấy đơn hàng được chỉ định.
 *
 * @param orderId ID đơn hàng. Không cho phép null hoặc chuỗi rỗng.
 * @return Thông tin đơn hàng
 * @throws NotFoundException Khi đơn hàng được chỉ định không tồn tại
 * @throws BadRequestException Khi ID đơn hàng là null hoặc chuỗi rỗng
 */
public Order findById(String orderId) {
    // ...
}
```

```java
/**
 * Tìm kiếm đơn hàng khớp với điều kiện được chỉ định.
 *
 * <p>Khi không có đơn hàng phù hợp thì trả về list rỗng.</p>
 *
 * @param condition Điều kiện tìm kiếm. Không thể chỉ định null.
 * @return Danh sách đơn hàng. Khi không có kết quả thì là list rỗng
 * @throws BadRequestException Khi điều kiện tìm kiếm là null hoặc không hợp lệ
 */
public List<Order> search(OrderSearchCondition condition) {
    // ...
}
```

```java
/**
 * Chốt đơn hàng.
 *
 * <p>Việc gọi với cùng một ID đơn hàng được xử lý mang tính idempotent.</p>
 *
 * @param orderId ID đơn hàng cần chốt
 * @return Đơn hàng sau khi chốt
 * @throws NotFoundException Khi đơn hàng không tồn tại
 * @throws ConflictException Khi đã xuất hàng rồi
 */
public Order confirm(String orderId) {
    // ...
}
```

```java
/**
 * {@inheritDoc}
 *
 * <p>Kết quả tìm kiếm được lọc theo quyền hạn của người dùng.</p>
 */
@Override
public Order findById(String orderId) {
    // ...
}
```

**Những nơi bắt buộc**

- Class, interface, Enum, Record, annotation `public`
- Inner class, inner interface, inner Enum, inner Record, inner annotation `public` hoặc `protected`
- Method `public` hoặc `protected` (có thể loại trừ getter / setter và method có gắn `@Test`)

---

## 5. Quy tắc riêng của framework

### 5.1 Trách nhiệm của từng tầng

| Tầng | Trách nhiệm | Điều cấm |
|----|------|----------|
| Controller | Tiếp nhận request・validation・trả về response | Không viết logic nghiệp vụ |
| Service | Logic nghiệp vụ・quản lý transaction | Không truy cập DB trực tiếp |
| gRPC Client | Giao tiếp tới microservice hạ nguồn | Không thực hiện phán đoán nghiệp vụ |
| Mapper / Mapping | Chỉ chuyển đổi object | Không chứa logic |

### 5.2 MapStruct (mapping DTO)

Nếu phân tán cấu hình `@Mapper` ra từng class thì khi thay đổi các cấu hình chung như `componentModel` sẽ phải sửa toàn bộ file. Bằng cách tập trung vào `BaseMapping`, thay đổi chỉ tập trung vào 1 file. Ngoài ra, bằng cách đặt `unmappedTargetPolicy = ERROR`, có thể phát hiện việc bỏ sót mapping khi thêm field ngay tại thời điểm compile, ngăn được sự cố dữ liệu bị mất một cách âm thầm lúc runtime.

- Cấu hình annotation `@Mapper` được tập trung vào `BaseMapping`, các class Mapping riêng lẻ chỉ kế thừa
- Lấy `unmappedTargetPolicy = ERROR` làm nguyên tắc, phát hiện bỏ sót mapping bằng lỗi build
- `dto/` dùng cho HTTP request/response, `model/` dùng cho gRPC message, phân biệt rõ mục đích sử dụng

**Trách nhiệm của Mapper**

- Class Mapping chỉ đảm nhiệm việc chuyển đổi object bằng MapStruct
- Không implement trong Mapper các xử lý có tác dụng phụ như parse chuỗi JSON, validation nghiệp vụ, file I/O. Hãy xử lý ở tầng Service và chỉ truyền cho Mapper các giá trị đơn giản đã chuyển đổi xong
- Không viết trực tiếp logic mapping hay validation vào class gRPC Client

**Ví dụ xấu (thực hiện phán đoán nghiệp vụ・chuyển đổi trong gRPC Client)**: Nếu implement trong Client phần xử lý throw `BadRequestException` khi parse chuỗi JSON thất bại, hay phần validation đầu vào thực hiện trước khi build request, thì tầng Client sẽ mang trách nhiệm vượt quá "giao tiếp tới microservice hạ nguồn". Những xử lý như vậy phải đặt ở tầng Service.

```java
// ❌ Không thực hiện validation・throw exception ở gRPC Client
public CreateResponse create(String publicTargetsJson) {
    List<PublicTarget> targets = parsePublicTargets(publicTargetsJson); // Đang implement parse JSON + throw exception trong Client
    return stub.create(toRequest(targets));
}

// ✅ Validation・parse thực hiện ở Service, chỉ truyền cho Client giá trị đã chuyển đổi
// Service
public CreateResponse create(String publicTargetsJson) {
    List<PublicTarget> targets = validateAndParse(publicTargetsJson);
    return {feature}Client.create(targets);
}
```

**Vấn đề cần xem xét**
Muốn dùng Mapstruct config để không phải thiết lập cùng một property mỗi lần.
Về nguyên tắc thực hiện bằng Mapstruct, nhưng cũng cần có cách xử lý khi có ngoại lệ.

### 5.3 MyBatis (truy cập dữ liệu)

- Tham số query bắt buộc phải dùng `#{}` (cấm ghép SQL bằng `${}`)

```xml
<!-- ✅ Prepared statement -->
WHERE order_id = #{orderId}

<!-- ❌ Nguy hiểm injection -->
WHERE order_id = ${orderId}
```

### 5.4 Xử lý exception・error handling

Các trường hợp là lỗi về mặt nghiệp vụ thì sử dụng các class exception riêng được định nghĩa trong `sst-fw-be-core`.  
Việc chuyển đổi exception sang response được tập trung tại global handler của từng module, cấm việc tạo response bằng `try-catch` riêng lẻ trong Controller.

- Ở Controller, không dùng `try-catch` để bắt exception nghiệp vụ
- Ở Controller, không tự `throw` exception nghiệp vụ. Việc phán đoán tính hợp lệ về mặt nghiệp vụ được thực hiện ở Service, còn Controller xử lý nguyên vẹn kết quả đó (response khi bình thường hoặc exception được lan truyền tới)
- Exception phát sinh ở Service hay Client thì không được nuốt hay chuyển đổi thành response khác tại Controller, mà phải cho lan truyền tới global handler
- Controller chỉ tập trung vào việc tiếp nhận request, validation giá trị đầu vào, gọi Service, và trả về response khi bình thường
- Khi cần chuyển đổi exception của API bên ngoài hay DB thành exception riêng khác, hãy xử lý ở Client gọi API bên ngoài hoặc Service thực hiện phán đoán nghiệp vụ, chứ không phải ở Controller

```java
// ✅ Ở Controller không bắt exception, cho lan truyền tới global handler
@PostMapping
public OrderResponse create(@RequestBody CreateOrderRequest request) {
    return orderService.create(request);
}

// ❌ Không bắt exception nghiệp vụ ở Controller để tạo response riêng lẻ
@PostMapping
public ResponseEntity<OrderResponse> create(@RequestBody CreateOrderRequest request) {
    try {
        return ResponseEntity.ok(orderService.create(request));
    } catch (ConflictException exception) {
        return ResponseEntity.status(HttpStatus.CONFLICT).body(null);
    }
}

// ❌ Không thực hiện phán đoán nghiệp vụ ở Controller và tự throw exception
@PostMapping
public OrderResponse create(@RequestBody CreateOrderRequest request) {
    if (orderService.exists(request.getOrderId())) {
        throw new ConflictException(ErrorCodeEnum.ORDER_ALREADY_EXISTS);
    }
    return orderService.create(request);
}
```

### 5.5 DI (dependency injection)

Field injection (`@Autowired`) bị cấm vì có những vấn đề sau.
(1) Vì không thể inject nếu không có Spring container nên trong unit test không thể viết `new XxxServiceImpl()` để truyền mock.
(2) Các class phụ thuộc dễ tăng lên một cách âm thầm, khó nhận ra class đang phình to.
(3) Không thể gắn `final` nên không thể làm immutable. Nếu dùng constructor injection thì giải quyết được tất cả những điều này.

Sử dụng constructor injection. Đơn giản hóa bằng `@RequiredArgsConstructor` của Lombok. Cấm field injection (`@Autowired`).

```java
// ✅
@Service
@RequiredArgsConstructor
public class OrderServiceImpl implements OrderService {
    private final OrderMapper orderMapper;
}

// ❌ Cấm field injection
@Autowired
private OrderMapper orderMapper;
```

### 5.6 Validation

Validation được thực hiện tách thành kiểm tra định dạng của giá trị đầu vào và kiểm tra tính hợp lệ về mặt nghiệp vụ. Trách nhiệm của BFF và microservice như sau.

| Nơi thực hiện | Đối tượng kiểm tra | Phương pháp implement |
|---|---|---|
| BFF | Các nội dung có thể phán định chỉ bằng bản thân request như bắt buộc, số ký tự, định dạng, phạm vi số, giá trị enum | Mô tả bằng TypeSpec và kiểm tra bằng Bean Validation được tự động sinh ra |
| Microservice | Các nội dung dựa trên DB hay quy tắc nghiệp vụ như sự tồn tại của master, tính duy nhất, chuyển trạng thái, tính nhất quán giữa nhiều mục | Kiểm tra thủ công ở tầng Service |

#### Validation của BFF

Việc kiểm tra về mặt hình thức đối với API mà BFF công khai thì về nguyên tắc được mô tả trong TypeSpec. Không được thêm・sửa thủ công annotation Jakarta Bean Validation vào Controller hay DTO được sinh ra.

```typespec
// cm-be-spec/src/tsp/.../xxx.tsp
model CreateOrderRequest {
    @doc("ID đơn hàng")
    orderId: string;

    @doc("Số lượng")
    @minValue(1)
    quantity: integer;
}
```

Với định nghĩa trên, DTO được sinh ra sẽ được gắn các ràng buộc như sau.

```java
public class CreateOrderRequest {
        @NotNull
        private String orderId;

        @NotNull
        @Min(value = 1)
        private Integer quantity;
}
```

Trong TypeSpec, hãy mô tả các ràng buộc có thể phán định chỉ bằng bản thân request như chỉ định bắt buộc, `@minLength`/`@maxLength`, `@pattern`, `@minValue`/`@maxValue`, `@format("email")`, `enum`/`union`.

#### Message validation

Trong `message()` của annotation Bean Validation, không ghi trực tiếp câu chữ tiếng Nhật v.v., mà chỉ định mã lỗi (message ID, ví dụ: `EB-001-000-000-013`). Câu dịch tương ứng với message ID được đăng ký vào file properties (tiếng Anh・tiếng Nhật), và Spring sẽ chuyển đổi theo header `Accept-Language`. Câu dịch này sẽ được trả về cho client khi global handler chuyển đổi sang error response.

Các ràng buộc tiêu chuẩn đã được gán sẵn message ID mặc định. Khi chỉ định message ID khác với mặc định, hoặc khi thêm ràng buộc không được tự động sinh ra từ TypeSpec, hãy sử dụng `@extension` của TypeSpec.

```typespec
// Chỉ thay thế message ID của @Size đã được tự động sinh ra
@maxLength(20)
@extension("x-size-message", "EB-XXX-XXX-XXX-XXX")
warehouseCd: string;

// Thêm @NotBlank không được tự động sinh ra, và chỉ định trực tiếp message ID trong annotation
@extension("x-field-extra-annotation", "@NotBlank(message = \"EB-001-000-000-004\")\n")
alias: string;
```

#### Validation ở phía microservice (gRPC)

Ở phía gRPC/Protobuf, các ràng buộc của TypeSpec không được tự động phản ánh vào validation. Generator `protobuf-schema` sinh ra kiểu và số hiệu field, nhưng không sinh ra các ràng buộc như `@minLength`/`@pattern`. Ngoài ra, trong proto3, giá trị scalar chưa được set sẽ trở thành giá trị mặc định (chuỗi rỗng, `0`, `false` v.v.), nên dù là mục đã được kiểm tra ở BFF thì phía microservice vẫn phải kiểm tra lại.

Ở tầng Service, tùy theo nhu cầu hãy implement kiểm tra bắt buộc, tham chiếu master, tính duy nhất, chuyển trạng thái, tính nhất quán giữa nhiều mục v.v. Với lỗi thì dùng các class exception của `sst-fw-be-core` và `ErrorCodeEnum`, nếu không thể biểu đạt bằng cái có sẵn thì có thể thêm mới. Tuy nhiên, không ghi trực tiếp message mà đăng ký message ID vào `messages.properties`/`messages_ja.properties` để duy trì hỗ trợ đa ngôn ngữ (xem 5.6 "Message validation").

```java
// Ví dụ implement thủ công (microservice)
private {Feature}Entity getHeaderOrThrow(String companyCd, String lookupKey)
    throws NotFoundException, BadRequestException {
    if (lookupKey == null || lookupKey.isBlank()) {
        throw new BadRequestException(ErrorCodeEnum.REQUEST_PARAMETER_INVALID);
    }
    ...
}
```

Vì phạm vi・độ chi tiết cần kiểm tra phụ thuộc vào nội dung implement của service và cấu trúc DB, nên quy ước này không quy định đồng nhất. Người implement của từng microservice hãy tự phán đoán và implement các kiểm tra cần thiết ở tầng Service (kiểm tra bắt buộc, tính toàn vẹn tham chiếu master, tính hợp lệ của chuyển trạng thái v.v.).

### 5.7 Cách viết log

Trong dự án này, các loại log dưới đây được dùng phân biệt theo mục đích.

#### 5.7.1 Log thao tác

Log thao tác là log để về sau có thể truy vết các thao tác của người dùng. Đối tượng là các endpoint của class có gắn `@RestController` ở BFF, và được ghi tự động bằng AOP.

- Log thao tác ghi lại thông tin người dùng, HTTP method, đường dẫn API, request・response, kết quả xử lý, thời gian xử lý và thông tin exception.
- Log thao tác được gửi bất đồng bộ tới microservice chuyên về log, và lưu vào bảng log thao tác của RDS. Thời gian chờ gửi log không được ảnh hưởng tới response của API nghiệp vụ.
- Chỉ khi không cần xuất log thao tác thì mới có thể gắn `@SkipOperationLog` vào class hoặc method.
- Việc gắn `@SkipOperationLog` là ngoại lệ, về nguyên tắc phải xuất log thao tác. Khi gắn, hãy ghi comment ngay trước annotation về lý do không xuất log.

```java
// Vì health check không phải thao tác của người dùng nên không ghi log thao tác.
@SkipOperationLog
@GetMapping("/health")
public HealthResponse health() {
    // ...
}
```

#### 5.7.2 Tra cứu log

**Phản ánh nội dung của quy ước tra cứu log**

#### 5.7.3 Log dùng cho khối lượng công việc

**Phản ánh nội dung của quy ước log dùng cho khối lượng công việc**

#### 5.7.4 Log APM

Không gắn thủ công vào trace・log・metrics của APM các thuộc tính hay tham số riêng của logic nghiệp vụ bằng implementation riêng lẻ. Không thêm việc set thuộc tính dành cho APM hay annotation chuyên dụng vào logic nghiệp vụ như Controller・Service, mà hãy sử dụng cơ chế tự động gắn・tự động capture của nền tảng chung.

```java
// ❌ Không thao tác trực tiếp Span API của OpenTelemetry trong logic nghiệp vụ để gắn thuộc tính riêng lẻ
@Service
public class OrderServiceImpl implements OrderService {
    public Order confirm(String orderId) {
        Span span = Span.current();
        span.setAttribute("order.id", orderId);
        span.setAttribute("order.status", "CONFIRMED");
        span.addEvent("order confirmed");
        // ...
    }
}

// ❌ Không thêm annotation chuyên dụng cho instrumentation APM vào method nghiệp vụ
@WithSpan("OrderService.confirm")
public Order confirm(@SpanAttribute("order.id") String orderId) {
    // ...
}
```

#### 5.7.5 Log server

Các sự kiện về mặt nghiệp vụ thì ghi vào DB dùng cho tra cứu log, còn sự cố về mặt kỹ thuật thì kiểm tra bằng APM. Không xuất log server thông thường từ ứng dụng nghiệp vụ với mục đích truy vết bắt đầu・kết thúc xử lý, thực thi SQL, exception.

Chỉ khi cần điều tra tạm thời trong lúc phát triển thì mới được dùng `log.debug()`. Ở môi trường production không bật mức `DEBUG`. Sau khi điều tra xong, hãy xóa `log.debug()` đã thêm tạm thời.

**Nội dung sẽ sửa trong tương lai**
Tạo `BaseService` có gắn `@Slf4j` và cho từng service kế thừa. Khi phương pháp implement được chốt thì sẽ ghi ví dụ.

### 5.8 Nơi quản lý hằng số・Enum

Hằng số・Enum được đặt ở package `constant/` hoặc bên trong class sử dụng, tùy theo phạm vi sử dụng.

| Phạm vi sử dụng | Nơi đặt | Hình thức implement |
|---|---|---|
| Giá trị dùng xuyên suốt ở toàn bộ chức năng trong dự án (đường dẫn xác thực v.v.) | Ngay dưới package `constant/` | Class `final` / Enum |
| Giá trị・trạng thái dùng chung ở nhiều class của cùng một nghiệp vụ | Dưới `constant/{domain}/{subdomain}/` | Class `final` / Enum |
| Giá trị chỉ dùng trong một class duy nhất | Bên trong class sử dụng | `private static final` |

- Giá trị biểu thị trạng thái thì định nghĩa bằng Enum chứ không phải hằng số (`String`/`int` v.v.)
- Hằng số・Enum dùng chung trong nghiệp vụ thì đặt dưới `constant/{domain}/{subdomain}/`
- Giá trị chỉ dùng ở một class duy nhất thì không tạo mới class hằng số, mà định nghĩa là `private static final` của class sử dụng

**Ví dụ chia sẻ toàn dự án**: `SecurityPathConstant` (đường dẫn bỏ qua xác thực), `JwtClaimConstant` (key claim của JWT) được tham chiếu từ nhiều domain như `WebSecurityConfiguration`, nên đặt ngay dưới `{basePackage}.constant`.

**Ví dụ dùng chung trong nghiệp vụ**: `soPlanStatusEnum` được dùng từ nhiều chức năng trong nghiệp vụ dự định xuất hàng thì đặt dưới `{basePackage}.constant.core.so`. Để phán định trạng thái dự định xuất hàng có phải là "dự định" hay không, không ghi trực tiếp giá trị số như `100` mà dùng `ShippingPlanStatusEnum.PLANNED`.

```java
@RequiredArgsConstructor
public enum ShippingPlanStatusEnum {
    PLANNED(100),
    SHIPPED(700),
    CANCELED(999);

    private final int code;
}
```

```java
// ✅ Sử dụng Enum để phán định trạng thái
if (shippingPlanStatus == ShippingPlanStatusEnum.PLANNED) {
    // ...
}

// ❌ Không ghi trực tiếp mã DB vào code nghiệp vụ
if (shippingPlanStatusCode == 100) {
    // ...
}
```

```
{basePackage}/
├── constant/                                ** Chia sẻ ở toàn bộ chức năng trong dự án
│   ├── SecurityPathConstant.java
│   ├── JwtClaimConstant.java
│   └── core/                                ** {domain}
│       └── so/                              ** {subdomain}
│           └── SoOrderStatusEnum.java       ** Giá trị phân loại dùng chung trong nghiệp vụ xuất hàng
└── service/core/so/soPlanSearch/
    └── SoPlanSearchServiceImpl.java         ** Hằng số chỉ của class này thì định nghĩa bên trong class
```

**Anti-pattern**: Nếu đặt giá trị chỉ dùng ở một class duy nhất vào dưới `constant/` thì nơi sử dụng và nơi định nghĩa sẽ cách xa nhau, khó truy vết. Ngoài ra, không được ghi trực tiếp để phán định các giá trị có thể quản lý bằng hằng số・Enum như mã DB hay giá trị trạng thái. Lý do là ý nghĩa của giá trị và nơi thay đổi sẽ bị phân tán, dẫn tới bỏ sót sửa khi thay đổi giá trị mã.

### 5.9 Quản lý transaction

Về phương pháp implement cụ thể, sẽ ghi sau khi cách vận hành công cụ CDC + bảng Outbox được chốt.


- Method thuộc hệ tham chiếu thì gắn `@Transactional(readOnly = true)` ở mức class
- Chỉ method thuộc hệ cập nhật thì ghi đè `@Transactional` ở mức method
- Không gắn `@Transactional` vào method `private` (vì AOP proxy không có tác dụng)

```java
@Service
@Transactional(readOnly = true)
public class OrderServiceImpl implements OrderService {
    public Order findById(String orderId) { ... }

    @Transactional
    public void updateOrder(OrderDto dto) { ... }
}
```

---

### 5.10 Đặc tả ngôn ngữ Java

> ※ Dưới đây là các khuyến nghị ở mức ngôn ngữ Java, không phải riêng của Spring Boot

- Làm cho immutable ở mức tối đa có thể (tích cực gắn `final`)
- Không tạo method trả về `null`. Khi giá trị trả về không tồn tại thì dùng `Optional<T>`
- Việc ép kiểu của `instanceof` thì viết bằng Pattern Matching

> **Khuyến nghị**: Tích cực tận dụng Record・Sealed Classes・Pattern Matching của Java 25

```java
// Record: sử dụng cho DTO hoặc Value Object
public record DecodedBarcodeResult(String format, String value) {}

// Pattern Matching
// ❌ Cách viết truyền thống: kiểm tra kiểu và ép kiểu tách thành các dòng riêng
if (authentication instanceof JwtAuthenticationToken) {
    JwtAuthenticationToken jwtAuth = (JwtAuthenticationToken) authentication;
    return jwtAuth.getToken();
}

// ✅ Pattern Matching: bind vào biến đồng thời với kiểm tra kiểu
if (authentication instanceof JwtAuthenticationToken jwtAuth) {
    return jwtAuth.getToken();
}
```

**Lý do dùng Record**: Nếu tạo DTO hay Value Object bằng class thông thường thì phải implement thủ công `equals()`/`hashCode()`/`toString()`/getter, và khi thêm field mà quên cập nhật những thứ này thì sẽ trở thành mầm mống của bug. Record tự động sinh những thứ đó từ danh sách tham số của constructor, nên vừa giảm lượng code vừa ngăn được việc bỏ sót cập nhật. Ngoài ra, vì toàn bộ field tự động trở thành `final` nên có thể cưỡng chế Value Object immutable.

**Lý do dùng Pattern Matching**: `instanceof` truyền thống tách kiểm tra kiểu và ép kiểu thành 2 dòng, nên có thể xảy ra lỗi quên viết ép kiểu, hoặc nhầm lẫn giữa biến đã kiểm tra kiểu và biến thực sự được ép kiểu. Pattern Matching bind vào biến ngay khi kiểm tra kiểu, nên không cần ép kiểu, giảm được rủi ro bỏ sót ép kiểu và `ClassCastException`.

**Trường hợp dùng Sealed Classes**: Enum chỉ có thể cho tất cả các biến thể có cùng cấu trúc (chỉ có tên), còn Sealed Classes vừa giới hạn các subtype được phép bằng `permits`, vừa cho phép mỗi biến thể có field khác nhau. Hiệu quả trong các trường hợp sau.

- Biểu thị trạng thái mà cấu trúc dữ liệu đi kèm khác nhau theo từng trạng thái (ví dụ: khi biểu thị status của đơn hàng, muốn cho mỗi trạng thái có mục khác nhau như đã chốt thì có `confirmedAt`, đã hủy thì có `canceledReason`)
- Khi muốn phân nhánh response bên ngoài hay kết quả xử lý theo kiểu như "kiểu khi thành công" và "kiểu khi thất bại"
- Khi muốn kết hợp biểu thức `switch` với Pattern Matching để khi có subtype được thêm mới trong tương lai thì phát hiện được việc thiếu nhánh trong `switch` hiện có bằng lỗi compile

```java
public sealed interface OrderStatus permits OrderConfirmed, OrderCanceled {}
public record OrderConfirmed(Instant confirmedAt) implements OrderStatus {}
public record OrderCanceled(String canceledReason) implements OrderStatus {}
```

### 5.11 Ngày・giờ

#### Việc phát sinh thời điểm cho kiểu timestamp được thực hiện ở DB

Thời gian hiện tại của ngày giờ đăng ký・ngày giờ cập nhật (`created_at`/`updated_at` v.v.) không được sinh ra ở application server, mà sinh ra bằng `clock_timestamp()` của PostgreSQL. Không được truyền vào INSERT/UPDATE thời điểm được sinh ra từ Service bằng `Instant.now()` v.v.

**Cấm: không sử dụng `now()` và `CURRENT_TIMESTAMP`.**
Những hàm này bị cố định ở thời điểm bắt đầu transaction. Để lấy thời gian hiện tại, **luôn luôn sử dụng `clock_timestamp()`.**

```sql
-- Khi INSERT thì chỉ định clock_timestamp() cho created_at/updated_at
INSERT INTO order_header (order_id, created_at, updated_at)
VALUES (#{orderId}, clock_timestamp(), clock_timestamp());

-- Khi UPDATE thì chỉ định clock_timestamp() trong câu SET
UPDATE order_header
SET status = #{status},
    updated_at = clock_timestamp()
WHERE order_id = #{orderId};
```

Không được truyền thẳng vào cột timestamp thời điểm được sinh ra ở phía ứng dụng.

#### Trong ứng dụng, dữ liệu kiểu timestamp được quản lý bằng UTC

Giá trị lưu trong DB và timestamp trong giao tiếp API được thống nhất theo UTC, và ở phía Java được xử lý bằng `Instant` (hoặc `OffsetDateTime` theo UTC). Không giữ ở tầng Service giá trị đã chuyển đổi sang múi giờ cụ thể như JST.

- Kiểu ngày giờ của API (HTTP) được gửi・nhận theo ISO 8601 có hậu tố `Z` (UTC). Chuỗi không có `Z`・không có offset sẽ khiến TZ không xác định nên không sử dụng
- Kiểu ngày của API (HTTP) (`DATE`. Hạn giao hàng・hạn hiệu lực v.v.) không cần chuyển đổi TZ nên gửi・nhận nguyên dạng theo định dạng `YYYY-MM-DD` v.v.
- gRPC sử dụng kiểu `google.protobuf.Timestamp`. Vì được biểu diễn bằng giây Unix epoch nên UTC được đảm bảo ở mức kiểu dữ liệu
- Khi INSERT vào cột TIMESTAMPTZ hay chỉ định điều kiện tìm kiếm, nếu truyền chuỗi không có offset TZ thì sẽ bị diễn giải theo thiết lập `TimeZone` của session, gây lệch thời gian ngoài ý muốn. Bắt buộc phải chuyển sang UTC hoặc dùng chuỗi có offset

```java
// ✅ Xử lý như Instant theo UTC
Instant createdAt = entity.getCreatedAt(); // Cột TIMESTAMPTZ được nhận như Instant theo UTC

// ❌ Không giữ giá trị đã chuyển sang JST trong ứng dụng hay DB
OffsetDateTime createdAtJst = createdAt.atOffset(ZoneOffset.ofHours(9));
entity.setCreatedAt(createdAtJst.toInstant()); // Không đăng ký lại giá trị sau khi chuyển đổi
```

#### Chỉ thực hiện chuyển đổi múi giờ ở những nơi cần thiết

Chỉ khi cần biểu diễn khác UTC, ví dụ như hiển thị cho frontend hay xuất ra file gửi kết quả thực tế (CSV v.v.), thì mới chuyển đổi ngay trước lúc tạo response・xuất file. Không giữ giá trị sau khi chuyển đổi vào DB hay trạng thái nội bộ.

```java
// ✅ Chỉ chuyển đổi TZ ngay trước khi tạo response・xuất file
ZonedDateTime displayTime = createdAt.atZone(ZoneId.of("Asia/Tokyo"));
```

Việc phán định "hôm nay" của ngày nghiệp vụ (hạn giao hàng・hạn hiệu lực v.v.) không được dùng trực tiếp thời gian của application server hay `CURRENT_DATE` của DB. Hãy tính bằng cách chuyển đổi thời gian hiện tại lấy được từ DB bằng `clock_timestamp()` sang múi giờ của thiết bị được truyền từ frontend.

```sql
-- Lấy thời gian hiện tại của DB bằng clock_timestamp()
SELECT clock_timestamp();
```

```java
// ✅ Chuyển thời gian hiện tại phát sinh ở DB sang TZ của thiết bị để tính "hôm nay"
Instant now = timeMapper.selectCurrentTimestamp(); // Thời gian hiện tại của DB lấy bằng clock_timestamp()
LocalDate today = now.atZone(ZoneId.of(clientTimeZone)).toLocalDate();
```

#### Phân biệt cách dùng các kiểu

Không sử dụng `java.util.Date` / `Calendar`, với kiểu ngày・giờ hãy sử dụng package `java.time`.

| Kiểu | Mục đích |
|---|---|
| `LocalDate` | Ngày nghiệp vụ không có múi giờ như hạn giao hàng・hạn hiệu lực |
| `Instant` | timestamp xử lý duy nhất theo UTC như DB・giao tiếp API・JWT・session |
| `OffsetDateTime` | timestamp chỉ rõ offset cố định (ví dụ: `+09:00`) |
| `ZonedDateTime` | Kết quả chuyển đổi dựa trên quy tắc múi giờ của khu vực như `Asia/Tokyo` |
| `Duration` | Thời gian trôi qua như timeout・hạn hiệu lực |

`OffsetDateTime` giữ offset cố định, còn `ZonedDateTime` giữ `ZoneId`. Khi cần chuyển đổi dựa trên quy tắc lịch của khu vực như giờ mùa hè thì sử dụng `ZonedDateTime`.

### 5.12 Xử lý bất đồng bộ

Xử lý bất đồng bộ trong microservice có 2 dạng: xử lý hoàn tất trong nội bộ một service, và xử lý liên kết giữa các service. Trong cả hai trường hợp đều không dùng `@Async`, mà thực thi xử lý bất đồng bộ thông qua Kafka.

Về phương pháp implement cụ thể, sẽ ghi sau khi cách vận hành công cụ CDC + bảng Outbox được chốt.

### 5.13 Phương châm sử dụng annotation

Các annotation được phép sử dụng được sắp xếp theo từng tầng (layer).
Những annotation dùng chung xuyên tầng (Lombok, validation v.v.) được tổng hợp riêng.
Khi thêm annotation không có ghi ở đây, trước hết hãy xem xét liệu có thể thay thế bằng annotation hiện có hay không.

#### Tầng Controller

| Annotation | Mục đích |
|---|---|
| `@RestController` | Định nghĩa component |
| `@SkipOperationLog` | Loại trừ khỏi việc xuất log thao tác (sử dụng ngoại lệ. Xem 5.7.1) |
| `@RequiredArgsConstructor` | DI (Lombok) |

#### Tầng Service

| Annotation | Mục đích |
|---|---|
| `@Service`, `@RequiredArgsConstructor` | Định nghĩa component・DI |
| `@Transactional` | Ranh giới transaction (xem 5.9) |

#### Tầng gRPC Client / Mapper

| Annotation | Mục đích |
|---|---|
| `@RequiredArgsConstructor` | DI (Lombok) |
| `@Mapper` (`org.mapstruct.Mapper`), `@Mapping`, `@CollectionMappingStrategy` | Chuyển đổi DTO/gRPC message (MapStruct. Xem 5.2) |
| `@Mapper` (`org.apache.ibatis.annotations.Mapper`) | Interface mapper của MyBatis |
| `@CircuitBreaker` | Ngắt mạch khi gọi service hạ nguồn (Resilience4j) |

#### DTO・Entity (model)

| Annotation | Mục đích |
|---|---|
| `@Getter`, `@Builder`, `@AllArgsConstructor`, `@NoArgsConstructor`, `@EqualsAndHashCode`, `@Data` | Sinh boilerplate bằng Lombok |
| `@NotBlank`, `@Min`/`@Max`, `@Future`/`@FutureOrPresent`/`@Past`/`@PastOrPresent`, `@ChronologicalDates`, `@MaxDate` | Kiểm tra giá trị đầu vào |
| `@JsonProperty`, `@JsonAlias`, `@JsonIgnoreProperties` | Điều khiển tên property JSON・tên thay thế・cho phép property chưa biết |
| `@Nullable`, `@NonNull` (`org.jspecify.annotations`) | Chỉ rõ cho phép null・không cho phép null |

DTO request/response mà BFF công khai (sản phẩm sinh ra của `cm-be-spec`) thì không được thêm・sửa thủ công các annotation trên (xem 5.6). Các annotation trên được áp dụng cho DTO nội bộ・Entity viết tay.

#### Tầng Configuration

| Annotation | Mục đích |
|---|---|
| `@Configuration`, `@Bean` | Định nghĩa Bean |
| `@ConfigurationProperties`, `@EnableConfigurationProperties`, `@Validated` | Bind・kiểm tra giá trị cấu hình |
| `@ConditionalOnProperty`, `@ConditionalOnBean`, `@ConditionalOnClass`, `@ConditionalOnMissingBean` | Đăng ký Bean có điều kiện |
| `@Primary`, `@Qualifier`, `@Lazy` | Xếp thứ tự ưu tiên khi có nhiều implementation・khởi tạo trễ |

---

## 6. Tài liệu liên quan

| Tài liệu |
|-------------|
| 単体テスト規約 |
| 開発手順 |
| GitHub 運用ルール | 
| AI用 instructions |
| 共通開発規約 |

---