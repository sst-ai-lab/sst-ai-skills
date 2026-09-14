# バックエンドを新規作成する — Javaファイルテンプレート（マイクロサービス ⑧〜⑭）

### ⑧ マイクロサービス gRPCサービス

```java
package {msBasePackage}.grpc.[中分類lc].[小分類lc];

@GrpcService
@RequiredArgsConstructor
public class [中分類Pascal][小分類Pascal][機能名Pascal]Grpc extends [タグ結合]ServiceImplBase {

    private final [中分類Pascal][小分類Pascal][機能名Pascal]Service [中分類lc][小分類Pascal][機能名Pascal]Service;

    // 検索系
    @Override
    public void [operationId](
            [gRPCリクエスト型] request,
            StreamObserver<[gRPCレスポンス型]> responseObserver) {
        [gRPCレスポンス型] response = [中分類lc][小分類Pascal][機能名Pascal]Service.[API名lc](request);
        responseObserver.onNext(response);
        responseObserver.onCompleted();
    }

    // 登録・更新・削除系（戻り値なし gRPC でも Empty を返す）
    @Override
    public void [operationId](
            [gRPCリクエスト型] request,
            StreamObserver<com.google.protobuf.Empty> responseObserver) {
        [中分類lc][小分類Pascal][機能名Pascal]Service.[API名lc](request);
        responseObserver.onNext(com.google.protobuf.Empty.getDefaultInstance());
        responseObserver.onCompleted();
    }

}
```

### ⑨ マイクロサービス ServiceMapping

```java
package {msBasePackage}.infrastructure.mapping.[中分類lc].[小分類lc];

@Mapper(
    componentModel = "spring",
    unmappedTargetPolicy = ReportingPolicy.IGNORE,
    nullValueCheckStrategy = NullValueCheckStrategy.ALWAYS,
    collectionMappingStrategy = CollectionMappingStrategy.ADDER_PREFERRED
)
public interface [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping {

    // ListResponse<Entity> → gRPC レスポンス変換
    // ※gRPC配列フィールドは自動で [フィールド名]List になるため @Mapping で対応
    @Mapping(target = "[gRPCの配列フィールド名]List", source = "data")
    [gRPCレスポンス型] to[API名Pascal]Response(ListResponse<[Entityクラス]> listResponse);

}
```

### ⑩ マイクロサービス MyBatis Mapper インターフェース

```java
package {msBasePackage}.persistence.mapper.[中分類lc].[小分類lc];

@Mapper
public interface [機能名Pascal]Mapper {

    // 検索系
    List<[機能名Pascal][API名Pascal]Response> [API名lc]([機能名Pascal][API名Pascal]Request request);

    // 登録系
    int insert[機能名Pascal]([機能名Pascal][API名Pascal]Request request);

    // 更新系
    int update[機能名Pascal]([機能名Pascal][API名Pascal]Request request);

    // 削除系
    int delete[機能名Pascal]([機能名Pascal][API名Pascal]Request request);

}
```

### ⑪ マイクロサービス 永続化モデル（Request / Response）

```java
// Request
package {msBasePackage}.persistence.model.[中分類lc].[小分類lc];

@Data
public class [機能名Pascal][API名Pascal]Request {
    // 設計書のパラメータ定義に従ってフィールドを定義
    private String companyCd;
    private Long soNo;
    // ...
}

// Response（検索系のみ。登録・更新・削除系は不要）
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class [機能名Pascal][API名Pascal]Response {
    // 設計書の出力パラメータ定義に従ってフィールドを定義
    private String companyCd;
    private Long soNo;
    // ...
}
```

### ⑫ マイクロサービス サービス インターフェース

```java
package {msBasePackage}.service.[中分類lc].[小分類lc];

public interface [中分類Pascal][小分類Pascal][機能名Pascal]Service {

    // 検索系
    [gRPCレスポンス型] [API名lc]([gRPCリクエスト型] request)
        throws ForbiddenException, NotFoundException, BadRequestException;

    // 登録・更新・削除系（戻り値なし）
    void [API名lc]([gRPCリクエスト型] request)
        throws ForbiddenException, NotFoundException, BadRequestException;

}
```

### ⑬ マイクロサービス サービス 実装クラス

```java
package {msBasePackage}.service.[中分類lc].[小分類lc];

@Service
@RequiredArgsConstructor
public class [中分類Pascal][小分類Pascal][機能名Pascal]ServiceImpl implements [中分類Pascal][小分類Pascal][機能名Pascal]Service {

    private final [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping;
    private final [機能名Pascal]Mapper [機能名lc]Mapper;

    // ------- 検索系 -------
    @Override
    public [gRPCレスポンス型] [API名lc]([gRPCリクエスト型] request) {
        // gRPC リクエスト → 永続化モデル へ手動マッピング
        [機能名Pascal][API名Pascal]Request searchRequest = new [機能名Pascal][API名Pascal]Request();
        searchRequest.setCompanyCd(request.getCompanyCd());
        // ... 設計書の入力パラメータ定義に従う

        List<[機能名Pascal][API名Pascal]Response> dataList = [機能名lc]Mapper.[API名lc](searchRequest);

        ListResponse<[機能名Pascal][API名Pascal]Response> listResponse = new ListResponse<>();
        listResponse.setData(dataList);

        return [中分類lc][小分類Pascal][機能名Pascal]ServiceMapping.to[API名Pascal]Response(listResponse);
    }

    // ------- 登録・更新系（@Transactional 付与） -------
    @Override
    @Transactional
    public void [API名lc]([gRPCリクエスト型] request) {
        [機能名Pascal][API名Pascal]Request insertRequest = new [機能名Pascal][API名Pascal]Request();
        insertRequest.setCompanyCd(request.getCompanyCd());
        // ... 設計書のデータ更新定義に従う

        [機能名lc]Mapper.insert[機能名Pascal](insertRequest);
    }

    // ------- 削除系（@Transactional 付与） -------
    @Override
    @Transactional
    public void [API名lc]([gRPCリクエスト型] request) {
        [機能名Pascal][API名Pascal]Request deleteRequest = new [機能名Pascal][API名Pascal]Request();
        deleteRequest.setCompanyCd(request.getCompanyCd());
        deleteRequest.setSoNo(request.getSoNo());

        [機能名lc]Mapper.delete[機能名Pascal](deleteRequest);
    }

}
```

### ⑭ MyBatis Mapper XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
  "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="{msBasePackage}.persistence.mapper.[中分類lc].[小分類lc].[機能名Pascal]Mapper">

    <!-- ===== 検索系 ===== -->
    <resultMap
        type="{msBasePackage}.persistence.model.[中分類lc].[小分類lc].[機能名Pascal][API名Pascal]Response"
        id="[機能名Pascal][API名Pascal]Result">
        <!-- 設計書のSQL定義に従ってカラムマッピングを定義 -->
        <!-- DB物理列名（大文字）→ Java フィールド名（lowerCamelCase）-->
        <result property="soNo"       column="SONO"/>
        <result property="companyCd"  column="COMPANYCD"/>
        <!-- ... -->
    </resultMap>

    <select
        id="[API名lc]"
        parameterType="{msBasePackage}.persistence.model.[中分類lc].[小分類lc].[機能名Pascal][API名Pascal]Request"
        resultMap="[機能名Pascal][API名Pascal]Result">
        <!-- 設計書の SQL 定義をそのまま記載 -->
        SELECT
            T.SONO        AS SONO,
            T.COMPANYCD   AS COMPANYCD
            <!-- ... -->
        FROM
            T_SO T
        WHERE
            T.COMPANYCD = #{companyCd}
            AND T.SONO   = #{soNo}
    </select>

    <!-- ===== 登録系 ===== -->
    <insert
        id="insert[機能名Pascal]"
        parameterType="{msBasePackage}.persistence.model.[中分類lc].[小分類lc].[機能名Pascal][API名Pascal]Request">
        INSERT INTO T_SO (
            COMPANYCD,
            SONO
            <!-- 設計書のデータ更新定義に従う -->
        ) VALUES (
            #{companyCd},
            #{soNo}
        )
    </insert>

    <!-- ===== 更新系 ===== -->
    <update
        id="update[機能名Pascal]"
        parameterType="{msBasePackage}.persistence.model.[中分類lc].[小分類lc].[機能名Pascal][API名Pascal]Request">
        UPDATE T_SO SET
            ACTFLG      = #{actFlg}
            <!-- 設計書のデータ更新定義に従う -->
        WHERE
            COMPANYCD = #{companyCd}
            AND SONO  = #{soNo}
    </update>

    <!-- ===== 削除系 ===== -->
    <delete
        id="delete[機能名Pascal]"
        parameterType="{msBasePackage}.persistence.model.[中分類lc].[小分類lc].[機能名Pascal][API名Pascal]Request">
        DELETE FROM T_SO
        WHERE
            COMPANYCD = #{companyCd}
            AND SONO  = #{soNo}
    </delete>

</mapper>
```
