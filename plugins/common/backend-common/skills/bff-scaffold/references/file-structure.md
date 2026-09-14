# バックエンドを新規作成する — ファイル/ディレクトリ構造・データフロー

## ファイル/ディレクトリ構造

### BFF（{repo}）

```
{repo}/src/main/java/{basePackagePath}/
├── controller/[中分類lc]/[小分類lc]/
│   └── [中分類Pascal][小分類Pascal][機能名Pascal]Controller.java        ← ①
├── infrastructure/
│   ├── grpc/[中分類lc]/[小分類lc]/
│   │   ├── [中分類Pascal][小分類Pascal][機能名Pascal]Client.java          ← ②
│   │   └── [中分類Pascal][小分類Pascal][機能名Pascal]ClientImpl.java      ← ③
│   └── mapping/[中分類lc]/[小分類lc]/
│       ├── [中分類Pascal][小分類Pascal][機能名Pascal]ControllerMapping.java  ← ④
│       └── [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping.java     ← ⑤
└── service/[中分類lc]/[小分類lc]/
    ├── [機能名Pascal]Service.java                                          ← ⑥
    └── [機能名Pascal]ServiceImpl.java                                      ← ⑦
```

### マイクロサービス（{targetMicroservice}）

```
{targetMicroservice}/src/main/
├── java/{msBasePackagePath}/
│   ├── grpc/[中分類lc]/[小分類lc]/
│   │   └── [中分類Pascal][小分類Pascal][機能名Pascal]Grpc.java             ← ⑧
│   ├── infrastructure/mapping/[中分類lc]/[小分類lc]/
│   │   └── [中分類Pascal][小分類Pascal][機能名Pascal]ServiceMapping.java   ← ⑨
│   ├── persistence/
│   │   ├── mapper/[中分類lc]/[小分類lc]/
│   │   │   └── [機能名Pascal]Mapper.java                                   ← ⑩
│   │   └── model/[中分類lc]/[小分類lc]/
│   │       ├── [機能名Pascal][API名Pascal]Request.java  （API数分）         ← ⑪
│   │       └── [機能名Pascal][API名Pascal]Response.java （API数分）         ← ⑪
│   └── service/[中分類lc]/[小分類lc]/
│       ├── [中分類Pascal][小分類Pascal][機能名Pascal]Service.java           ← ⑫
│       └── [中分類Pascal][小分類Pascal][機能名Pascal]ServiceImpl.java       ← ⑬
└── resources/mybatis/mapper/[中分類lc]/[小分類lc]/
    └── [機能名Pascal]Mapper.xml                                            ← ⑭
```

---

## データフロー

```
フロントエンド
  ↓ REST API (BFFリクエスト型)
① Controller  →  ⑥ Service  →  ② Client  →  [BlockingStub]
                                    ↑⑤ServiceMapping (BFF→gRPC変換)
                                              ↓ gRPC
                                            ⑧ gRPCサービス
                                              ↓
                                           ⑫ Service
                                            ↑⑨ServiceMapping (gRPC→gRPC変換)
                                              ↓
                                            ⑩ Mapper → ⑭ Mapper.xml → DB
```
