# Tính năng gateway — tạo mới ban đầu

Tài liệu này dựng khung một **tính năng gateway M2M của {serviceLc}**: một gRPC endpoint hướng {serviceLc} được phục vụ bằng cách
gọi `{targetMicroservice}` qua gRPC rồi biến đổi lại kết quả. Service này chỉ có một hình dạng —
**gRPC impl → gRPC client {targetLc} → remap bằng MapStruct** (với một service điều phối chỉ dành cho
các luồng ghi/nhiều bước) — và **không sở hữu database nào**. Các template bên dưới là bộ khung; các
quy tắc chi tiết từng dòng nằm ở `../references/*.md`.

**Điều kiện tiên quyết:** spec OpenAPI/proto đã được build, nên cả các stub {serviceLc} (`Web{ServicePascal}…`,
API của service này) và các stub {targetLc} hạ nguồn (`Web{TargetPascal}…`) đều đã tồn tại dưới dạng jar nội bộ.

> **Ngoài phạm vi:** database / MyBatis / `@Transactional` (không có datasource — lấy dữ liệu từ
> `{targetMicroservice}`); Kafka / Redis / phần hạ tầng M2M-token (không thuộc việc dựng khung tính năng);
> `com.cm.grpc.*` / `com.fw.core.*` (jar nội bộ bên ngoài — tuyệt đối không stub); `build/`;
> **test**. **Package gốc:** `{basePackage}`.

**Tái sử dụng framework dùng chung — đừng phát minh lại:** trước khi viết một exception hay mã lỗi,
hãy kiểm tra framework dùng chung trước — tái sử dụng `com.fw.core.exception.*` (`ForbiddenException`,
`NotFoundException`, `BadRequestException`) + `ErrorCodeEnum`.

## Đầu vào cần thu thập trước

Hãy hỏi; đánh dấu bất cứ điều gì chưa rõ là "cần xác nhận / 要確認" (đừng tự nghĩ ra):

1. **ID & tên chức năng (機能ID・機能名)** → tên class.
2. **gRPC service + RPC của {ServicePascal}**: `Web{ServicePascal}…ServiceImplBase` được sinh ra và RPC cần
   cài đặt, cùng các message request/response `Grpc{ServicePascal}…` của nó.
3. **Lời gọi {targetLc} hạ nguồn**: gRPC service/method nào của `{targetMicroservice}` (stub `Web{TargetPascal}…`) và
   các message request/response `Grpc{TargetPascal}…` của nó cung cấp dữ liệu.
4. **Đọc hay ghi/nhiều bước?** Một luồng đọc đơn giản có thể gọi client thẳng từ gRPC
   impl; một luồng ghi hoặc nhiều bước thì đi qua một service điều phối.

## Cách đặt tên

Cách đặt tên theo phân loại thiết kế dùng chung. Chuỗi tính năng {serviceLc} (các class impl bỏ tiền tố `Web`;
các stub được sinh ra thì giữ nó):

| Tầng                                    | Mẫu                                                                                           | Ví dụ                                                            |
| ---------------------------------------- | ------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ |
| gRPC impl                                | `[{ServicePascal}Tag]GrpcService` kế thừa `Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase` được sinh ra | `{ServicePascal}SoSoSearchGrpcService` / `Web{ServicePascal}SoSoSearchServiceImplBase` |
| Client {TargetPascal}                              | `{TargetPascal}[Tag]Client` + `{TargetPascal}[Tag]ClientImpl`                                                         | `{TargetPascal}{ServicePascal}SoSearchClient(Impl)`                                    |
| MapStruct                                | `[Domain]GrpcMapping`                                                                             | `SoSearchGrpcMapping`                                              |
| Service điều phối (ghi/nhiều bước) | `[Tag]Service` + `[Tag]ServiceImpl`                                                               | `{ServicePascal}SoUpdateService(Impl)`                                       |

Các message {ServicePascal} = `Grpc{ServicePascal}…`; các message/stub {targetLc} hạ nguồn = `Grpc{TargetPascal}…` /
`Web{TargetPascal}…ServiceBlockingStub` — tất cả đều bên ngoài (`com.cm.grpc.*`), tuyệt đối không stub.

## Bản đồ file / thư mục (chỉ trong repo này)

```
src/main/java/{basePackagePath}/
├─ grpc/{serviceLc}/<domain>/[{ServicePascal}Tag]GrpcService.java               ← ⑤ gRPC impl (chỉ uỷ quyền)
├─ infrastructure/
│  ├─ grpc/{targetLc}/<domain>/
│  │  ├─ {TargetPascal}[Tag]Client.java                                   ← ② interface client
│  │  └─ {TargetPascal}[Tag]ClientImpl.java                               ← ② impl client (@Component)
│  └─ mapping/[Domain]GrpcMapping.java                          ← ③ MapStruct ({serviceLc} ↔ {targetLc})
├─ service/                                                     ← ④ điều phối (chỉ cho ghi/nhiều bước)
│  ├─ [Tag]Service.java
│  └─ [Tag]ServiceImpl.java
└─ configuration/GrpcClientConfiguration.java                  ← ① thêm stub hạ nguồn + @Bean
```

## Luồng dữ liệu

```
@GrpcService impl  (delegate-only)
  → (read) {targetLc} client directly, or (write/multi-step) orchestration service
      → {TargetPascal}[Tag]ClientImpl: mapper.to{TargetPascal}Request({serviceLc}) → blocking stub on channel "{grpcChannel}" → raw {targetLc} response
      → {targetMicroservice} (:{port})
  → caller maps {targetLc}→{serviceLc} (mapper.to{ServicePascal}Response) → onNext + onCompleted
```

Client trả về response {targetLc} **thô**; việc map {targetLc}→{serviceLc} diễn ra ở phía người gọi
(gRPC impl, hoặc service điều phối trên các luồng ghi) — không ở bên trong client.

## Thứ tự sinh code

1. ③ MapStruct mapping (`to{TargetPascal}Request` + `to{ServicePascal}Response`)
2. ② Interface + impl của client {TargetPascal}
3. ① Đăng ký stub hạ nguồn trong `GrpcClientConfiguration` (+ `@Bean`)
4. ④ Service điều phối — chỉ cho luồng ghi/nhiều bước
5. ⑤ gRPC impl

---

## Các template

### ① GrpcClientConfiguration — đăng ký stub hạ nguồn

Áp dụng `../references/grpc-client.md`. Khai báo blocking stub {targetLc} với
`@GrpcClient("{grpcChannel}")` trên một field private **ở đây** và phơi lại nó dưới dạng một `@Bean` — **tuyệt đối không**
đặt `@GrpcClient` trên một field của `*ClientImpl`. Channel luôn là `"{grpcChannel}"`.

```java
package {basePackage}.configuration;

@Configuration
@ConditionalOnClass(ManagedChannel.class)
public class GrpcClientConfiguration {

    @GrpcClient("{grpcChannel}")
    private Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;

    /** Phơi blocking stub [Tag] của {targetLc} dưới dạng một Spring bean. */
    @Bean
    Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStubBean() {
        return web{TargetPascal}[Tag]ServiceBlockingStub;
    }
}
```

### ② Client {TargetPascal} — `infrastructure/grpc/{targetLc}/<domain>/{TargetPascal}[Tag]Client.java` + `…Impl.java`

`@Component` + `@RequiredArgsConstructor`; inject **bean stub** (`@Bean` từ ①) và
mapper dưới dạng `private final`. Map {serviceLc}→{targetLc} qua mapper, gọi stub, **trả về
response {targetLc} thô**.

```java
public interface {TargetPascal}[Tag]Client {
    Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request);
}
```

```java
package {basePackage}.infrastructure.grpc.{targetLc}.[domain];

@Component
@RequiredArgsConstructor
public class {TargetPascal}[Tag]ClientImpl implements {TargetPascal}[Tag]Client {

    private final Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;
    private final [Domain]GrpcMapping [domain]GrpcMapping;

    @Override
    public Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request) {
        return web{TargetPascal}[Tag]ServiceBlockingStub.[{targetLc}Rpc]([domain]GrpcMapping.to{TargetPascal}Request(request));
    }
}
```

### ③ MapStruct mapping — `infrastructure/mapping/[Domain]GrpcMapping.java`

Áp dụng `../references/mapstruct-mapping.md`. Header chuẩn; **interface phẳng —
không có `BaseMapping`**; chỉ thêm `collectionMappingStrategy = ADDER_PREFERRED` khi map
các field `repeated`/collection. Chỉ map những chiều mà use case cần; cho các
item/detail lồng nhau method riêng của chúng.

```java
package {basePackage}.infrastructure.mapping;

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED   // chỉ khi có field repeated/collection
)
public interface [Domain]GrpcMapping {

    Grpc{TargetPascal}[...]Request to{TargetPascal}Request(Grpc{ServicePascal}[...]Request request);          // {serviceLc} → {targetLc}
    Grpc{ServicePascal}[...]Response to{ServicePascal}Response(Grpc{TargetPascal}[...]SuccessResponse source); // {targetLc} → {serviceLc}

    Grpc{ServicePascal}[...]Item to{ServicePascal}Item(Grpc{TargetPascal}[...]Item source);                   // lồng nhau (các list được nối tự động)
    Grpc{ServicePascal}[...]Detail to{ServicePascal}Detail(Grpc{TargetPascal}[...]Detail source);
}
```

Đổi tên các field không khớp bằng `@Mapping(target = …, source = …)`; với các field `repeated` hãy map
tới tên logic (không phải `…List`).

### ④ Service điều phối — `service/[Tag]Service.java` + `…ServiceImpl.java` (chỉ cho ghi/nhiều bước)

Một luồng đọc đơn giản thì bỏ qua phần này và gọi client từ gRPC impl. Áp dụng
`../references/service-layer.md`: interface + impl `@Service`
(`@RequiredArgsConstructor`, các dependency `private final` = (các) client {targetLc} + mapper nếu nó định hình
response). **Không `@Transactional`, không DB.** Kiểm tra dữ liệu vào → gọi (các) client {targetLc} → map/
tổng hợp → trả về message {serviceLc}. Throw các exception có kiểu `com.fw.core.exception.*`
(`ForbiddenException` / `BadRequestException` / `NotFoundException`) khi lỗi; đừng
nuốt lỗi gRPC hạ nguồn.

```java
public interface [Tag]Service {
    Grpc{ServicePascal}[...]Response [method](Grpc{ServicePascal}[...]Request request);
}
```

```java
package {basePackage}.service;

@Service
@RequiredArgsConstructor
public class [Tag]ServiceImpl implements [Tag]Service {

    private final {TargetPascal}[Tag]Client {targetLc}[Tag]Client;
    private final [Domain]GrpcMapping [domain]GrpcMapping;

    @Override
    public Grpc{ServicePascal}[...]Response [method](Grpc{ServicePascal}[...]Request request) {
        // kiểm tra dữ liệu vào (ví dụ throw ForbiddenException khi thiếu phạm vi/quyền)
        Grpc{TargetPascal}[...]SuccessResponse {targetLc}Response = {targetLc}[Tag]Client.[method](request);
        return [domain]GrpcMapping.to{ServicePascal}Response({targetLc}Response);
    }
}
```

### ⑤ gRPC impl — `grpc/{serviceLc}/<domain>/[{ServicePascal}Tag]GrpcService.java`

`@Slf4j @GrpcService @RequiredArgsConstructor`, `extends Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase`.
**Chỉ uỷ quyền:** inject client {targetLc} + mapper (luồng đọc đơn giản) hoặc service
điều phối (ghi/nhiều bước); gọi nó, map {targetLc}→{serviceLc} nếu impl sở hữu bước đó, rồi
`onNext` + `onCompleted`. Không có logic nghiệp vụ; đừng bắt các exception miền (mapping `Status`
trung tâm).

```java
package {basePackage}.grpc.{serviceLc}.[domain];

@Slf4j
@GrpcService
@RequiredArgsConstructor
public class [{ServicePascal}Tag]GrpcService extends Web[{ServicePascal}Tag]ServiceGrpc.Web[{ServicePascal}Tag]ServiceImplBase {

    private final {TargetPascal}[Tag]Client {targetLc}[Tag]Client;       // luồng đọc đơn giản
    private final [Domain]GrpcMapping [domain]GrpcMapping;
    // private final [Tag]Service [tag]Service;           // thay thế cho luồng ghi/nhiều bước

    @Override
    public void [rpc](
            Grpc{ServicePascal}[...]Request request,
            StreamObserver<Grpc{ServicePascal}[...]Response> responseObserver) {
        Grpc{TargetPascal}[...]SuccessResponse {targetLc}Response = {targetLc}[Tag]Client.[method](request);   // đọc
        responseObserver.onNext([domain]GrpcMapping.to{ServicePascal}Response({targetLc}Response));
        responseObserver.onCompleted();
    }
}
```

## Danh sách kiểm tra hoàn thành

1. gRPC impl: `@GrpcService`, kế thừa `Web[{ServicePascal}Tag]ServiceImplBase`, chỉ uỷ quyền, `onNext` + `onCompleted`, không bắt exception.
2. Client {TargetPascal}: stub được khai báo `@GrpcClient("{grpcChannel}")` + `@Bean` trong `GrpcClientConfiguration`; `*ClientImpl` inject bean stub + mapper dưới dạng `private final` (không có `@GrpcClient` trên impl); trả về response {targetLc} thô.
3. MapStruct: header chuẩn (phẳng, không `BaseMapping`; `ADDER_PREFERRED` chỉ khi có collection); `to{TargetPascal}Request` / `to{ServicePascal}Response` (+ lồng nhau) theo nhu cầu của use case.
4. Service điều phối (chỉ khi ghi/nhiều bước): `@Service`, không `@Transactional`/DB; exception có kiểu; gọi (các) client {targetLc}.
5. Không DB/MyBatis; không thêm Kafka/Redis/M2M; không test; không stub `com.cm.grpc.*` / `com.fw.core.*`; không sửa `build/`.
