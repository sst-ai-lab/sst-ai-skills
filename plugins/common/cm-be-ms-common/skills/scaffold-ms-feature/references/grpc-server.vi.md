# Quy tắc tầng gRPC server

Áp dụng cho: `**/grpc/**/*.java`

Các class trong `grpc/core/<domain>` là điểm vào phía trong của service, đến từ BFF. Mỗi class là một adapter mỏng uỷ quyền cho một `*Service`.

## Hình dạng

- `@GrpcService` (`net.devh.boot.grpc.server.service.GrpcService`) + `@RequiredArgsConstructor`; inject `*Service` dưới dạng một field `private final`.
- `extends` **`*ServiceImplBase` được sinh ra** từ `com.cm.grpc.*` và `@Override` method RPC. Tuyệt đối không tạo/stub class base hay các kiểu message request/response — chúng đến từ jar `cm-be-spec`.
- **Chỉ uỷ quyền — không có logic nghiệp vụ.** Gọi service, rồi `responseObserver.onNext(response)` tiếp theo là `responseObserver.onCompleted()`.

## Xử lý lỗi

Một exception advice toàn cục đã được nối vào sẵn. `GrpcGlobalExceptionHandler` (`@GrpcAdvice`, trong `com.fw.grpc.core.exception.handler`) được gRPC server starter tự động đăng ký trong mọi service có phụ thuộc vào nó, trừ khi service tự khai báo một handler bean riêng. **Do đó phần gRPC impl không tự dịch các lỗi miền.**

Những gì advice đã map sẵn:

| Được tầng service throw ra                                 | `Status` gRPC         |
| ---------------------------------------------------------- | --------------------- |
| `BadRequestException`, `InvalidRequestPayloadException`     | `INVALID_ARGUMENT`    |
| `NotFoundException`                                        | `NOT_FOUND`           |
| `ConflictException`                                        | `ALREADY_EXISTS`      |
| `UnauthorizedException`                                    | `UNAUTHENTICATED`     |
| `ForbiddenException`                                       | `PERMISSION_DENIED`   |
| `UnprocessableEntityException`                             | `FAILED_PRECONDITION` |
| `ServiceUnavailableException`                              | `UNAVAILABLE`         |
| `TooManyRequestsException`                                 | `RESOURCE_EXHAUSTED`  |
| `StatusRuntimeException` từ một lời gọi gRPC upstream       | được chuyển tiếp nguyên trạng, giữ nguyên status và trailer ban đầu |
| `DataAccessException`, hoặc bất kỳ exception nào khác       | `INTERNAL`            |

- **Hãy throw một exception có kiểu từ `com.fw.core.exception.*`** (tất cả đều extend `ServerErrorException`) và để advice map nó. Đừng bắt nó trong gRPC impl để tự chuyển đổi bằng tay.
- Advice còn gắn thêm các trailer `x-error-code` và `x-errors`, nhờ đó một `BadRequestException` mang theo các `InvalidRequestExceptionRecord` sẽ đến được phía gọi kèm chi tiết theo từng field. Bắt exception tại chỗ sẽ làm mất phần chi tiết đó.
- Chỉ bắt tại chỗ **khi** gặp một exception ngoài họ exception nói trên mà cần một status cụ thể — ví dụ `IllegalArgumentException`, nếu không sẽ đến phía gọi dưới dạng `INTERNAL`:

  ```java
  } catch (IllegalArgumentException e) {
      responseObserver.onError(
          Status.INVALID_ARGUMENT.withDescription(e.getMessage()).asRuntimeException());
  }
  ```

  Hãy ưu tiên throw `BadRequestException` từ service để advice xử lý, thay vì thêm một đoạn catch như vậy.
- Tuyệt đối không nuốt exception: luôn kết thúc observer, qua `onCompleted()` hoặc `onError(...)`.
