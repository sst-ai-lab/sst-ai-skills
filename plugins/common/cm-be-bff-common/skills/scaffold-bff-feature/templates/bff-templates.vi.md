# Tạo mới backend — template file Java (BFF ① đến ⑦)

## Template file Java

### ① Controller của BFF

```java
package {basePackage}.controller.[中分類lc].[小分類lc];

@RestController
@RequiredArgsConstructor
public class [中分類Pascal][小分類Pascal][機能名Pascal]Controller implements [タグ結合]Api {

    private final [機能名Pascal]Service [機能名lc]Service;
    private final [中分類Pascal][小分類Pascal][機能名Pascal]ControllerMapping [中分類lc][小分類Pascal][機能名Pascal]ControllerMapping;

    // ------- 検索系（レスポンスあり） -------
    @Override
    public ResponseEntity<[タグ結合][API名Pascal]SuccessResponse> [operationId](
            @Valid [タグ結合][API名Pascal]Request request) {
        ListResponse<[BFF詳細レスポンス型]> data = [機能名lc]Service.[API名lc](request);
        return ResponseEntity.ok(
            [中分類lc][小分類Pascal][機能名Pascal]ControllerMapping.to[API名Pascal]SuccessResponse(data));
    }

    // ------- 登録・更新・削除系（レスポンスなし） -------
    @Override
    public ResponseEntity<Void> [operationId](
            @Valid [タグ結合][API名Pascal]Request request) {
        [機能名lc]Service.[API名lc](request);
        return ResponseEntity.ok().build();
    }

}
```

### ④ BFF ControllerMapping

```java
package {basePackage}.infrastructure.mapping.[中分類lc].[小分類lc];

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [中分類Pascal][小分類Pascal][機能名Pascal]ControllerMapping {

    // 検索系：ListResponse → HTTP SuccessResponse へのラップ
    // ※レスポンスの配列フィールドが 1 つの場合（例: soList）
    @Mapping(target = "[BFFの配列フィールド名]", source = "data")
    [タグ結合][API名Pascal]SuccessResponse to[API名Pascal]SuccessResponse(
        ListResponse<[BFF詳細レスポンス型]> source
    );

}
```

> **⚠️ Lưu ý**: Nếu API thuộc nhóm đăng ký, cập nhật, xóa không có response thì không cần ControllerMapping.

### ② Interface gRPC client của BFF

```java
package {basePackage}.infrastructure.grpc.[中分類lc].[小分類lc];

public interface [中分類Pascal][小分類Pascal][機能名Pascal]Client {

    // 検索系
    [gRPCレスポンス型] [API名lc]([タグ結合][API名Pascal]Request request);

    // 登録・更新・削除系（gRPC レスポンス型は void の代わりに専用 Response を返す）
    [gRPCレスポンス型] [API名lc]([タグ結合][API名Pascal]Request request);

}
```

### ③ Class triển khai gRPC client của BFF

```java
package {basePackage}.infrastructure.grpc.[中分類lc].[小分類lc];

@Component
@RequiredArgsConstructor
public class [中分類Pascal][小分類Pascal][機能名Pascal]ClientImpl implements [中分類Pascal][小分類Pascal][機能名Pascal]Client {

    private final [タグ結合]ServiceBlockingStub [タグ結合lc]ServiceBlockingStub;

    private final [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping;

    @Override
    public [gRPCレスポンス型] [API名lc]([タグ結合][API名Pascal]Request request) {
        [gRPCリクエスト型] grpcRequest =
            [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping.to[API名Pascal]Request(request);
        return [タグ結合lc]ServiceBlockingStub.[operationId](grpcRequest);
    }

}
```

> **⚠️ Stub được khai báo thành Bean trong `configuration/GrpcClientConfiguration.java` và được truyền vào ClientImpl bằng constructor injection**. Các field của ClientImpl phải là `private final`.
>
> Trong `GrpcClientConfiguration.java`, thêm 2 thứ sau cho mỗi stub được dùng.
>
> ```java
> // ① チャネルからスタブを取得（このクラスの中だけで @GrpcClient を使う）
> @GrpcClient("{grpcChannel}")
> private [タグ結合]ServiceBlockingStub [タグ結合lc]ServiceBlockingStub;
>
> // ② Bean として公開し、ClientImpl がコンストラクタで受け取れるようにする
> @Bean
> [タグ結合]ServiceBlockingStub [タグ結合lc]ServiceBlockingStubBean() {
>     return [タグ結合lc]ServiceBlockingStub;
> }
> ```
>
> ```java
> // ❌ ClientImpl のフィールドに @GrpcClient を付けない
> ```

### ⑤ BFF ServiceMapping

```java
package {basePackage}.infrastructure.mapping.[中分類lc].[小分類lc];

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping {

    // BFF → gRPC リクエスト変換（フィールド名が同じなら自動マッピング）
    [gRPCリクエスト型] to[API名Pascal]Request([タグ結合][API名Pascal]Request source);

    // gRPC → BFF レスポンス変換
    // ※gRPC配列フィールドは自動で [フィールド名]List になるため @Mapping で対応
    @Mapping(target = "[BFFフィールド名]", source = "[gRPCフィールド名]List")
    ListResponse<[BFF詳細レスポンス型]> to[API名Pascal]Response([gRPCレスポンス型] source);

}
```

### ⑥ Interface service của BFF

```java
package {basePackage}.service.[中分類lc].[小分類lc];

public interface [機能名Pascal]Service {

    // 検索系
    ListResponse<[BFF詳細レスポンス型]> [API名lc]([タグ結合][API名Pascal]Request request);

    // 登録・更新・削除系（レスポンスなし）
    void [API名lc]([タグ結合][API名Pascal]Request request);

}
```

### ⑦ Class triển khai service của BFF

```java
package {basePackage}.service.[中分類lc].[小分類lc];

@Slf4j
@Service
@RequiredArgsConstructor
public class [機能名Pascal]ServiceImpl implements [機能名Pascal]Service {

    private final [中分類Pascal][小分類Pascal][機能名Pascal]Client [中分類lc][小分類Pascal][機能名Pascal]Client;
    private final [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping;

    // 検索系
    @Override
    public ListResponse<[BFF詳細レスポンス型]> [API名lc]([タグ結合][API名Pascal]Request request) {
        [gRPCレスポンス型] response = [中分類lc][小分類Pascal][機能名Pascal]Client.[API名lc](request);
        return [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping.to[API名Pascal]Response(response);
    }

    // 登録・更新・削除系
    @Override
    public void [API名lc]([タグ結合][API名Pascal]Request request) {
        [中分類lc][小分類Pascal][機能名Pascal]Client.[API名lc](request);
    }

}
```
