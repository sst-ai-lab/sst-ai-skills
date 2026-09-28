# Quy tắc gRPC client (gọi hạ nguồn tới {targetMicroservice})

Áp dụng cho: `**/infrastructure/grpc/**/*.java`

`infrastructure/grpc/{targetLc}`, hoặc `infrastructure/grpc/{targetLc}/<domain>` khi các lần gọi được tách theo từng domain, chứa gRPC client dùng để gọi **`{targetMicroservice}`**. Hãy theo cách bố trí mà repository này đang dùng.

Các repository khác nhau ở chỗ một method của client trả về gì. Mỗi cách làm được giữ lại dưới dạng một biến thể có tên bên dưới. Hãy theo biến thể mà các class `*ClientImpl` hiện có của repository này đang dùng; khi chưa có, hãy hỏi người dùng.

## Kết nối — khai báo trong config, inject dưới dạng bean

> **Quy tắc then chốt:** `@GrpcClient` chỉ được khai báo **trong `GrpcClientConfiguration`** (phơi lại dưới dạng một `@Bean`) — **tuyệt đối không** trên một field bên trong `*ClientImpl`. Hãy theo mẫu dưới đây.

- Khai báo stub hạ nguồn trong **`configuration/GrpcClientConfiguration`** với `@GrpcClient("<channelName>")` trên một field private, và phơi lại nó dưới dạng một `@Bean` của Spring:

  ```java
  @GrpcClient("{grpcChannel}")
  private Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStub;

  @Bean
  Web{TargetPascal}[Tag]ServiceBlockingStub web{TargetPascal}[Tag]ServiceBlockingStubBean() {
    return web{TargetPascal}[Tag]ServiceBlockingStub;
  }
  ```

- Tên channel là **`"{grpcChannel}"`** → được phân giải từ `grpc.client.{grpcChannel}.address` (mặc định `localhost:{port}`). Đừng tự đặt ra tên channel mới cho các lần gọi `{targetMicroservice}`.

## Client interface + impl

- Mỗi lần gọi hạ nguồn có một interface `*Client` và một `*ClientImpl` (`@Component` + `@RequiredArgsConstructor`).
- Phần impl inject **bean stub và MapStruct mapper dưới dạng dependency constructor `private final`** (không có `@GrpcClient` trên field của impl).

### Biến thể `map-to-entities`

- Một method của client map request miền → request gRPC (bằng mapper), gọi blocking stub, và map các dòng trong response gRPC trở lại thành entity:
  ```java
  var resp = stub.[rpc](mapping.toGrpcRequest(request));

  return resp.getRowsList().stream().map(mapping::toEntity).toList();
  ```
- Các stub/message `com.cm.grpc.*` đến từ jar `cm-be-spec` — tuyệt đối không stub chúng ở local.

### Biến thể `raw-response`

- Một method của client map request của service này sang request của `{targetMicroservice}` (qua mapper), gọi blocking stub, và **trả về response thô của `{targetMicroservice}`**. Việc map response trở lại message của service này diễn ra ở **phía người gọi** (gRPC service impl, hoặc service điều phối trên các luồng ghi) — không ở bên trong client:
  ```java
  public Grpc{TargetPascal}[...]SuccessResponse [method](Grpc{ServicePascal}[...]Request request) {
    return web{TargetPascal}[Tag]ServiceBlockingStub.[rpc]([domain]GrpcMapping.to{TargetPascal}Request(request));
  }
  ```
- Các stub/message (`com.cm.grpc.*`) đến từ jar `cm-be-spec` — tuyệt đối không stub chúng ở local.
