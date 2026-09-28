# Tạo mới backend — cấu trúc file/thư mục, luồng dữ liệu

## Cấu trúc file/thư mục

### BFF ({repo})

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

### Microservice ({targetMicroservice})

Skill này không sinh phần đó. Được sinh ở phía repository `{targetMicroservice}`, theo quy ước microservice của repository đó.

---

## Luồng dữ liệu

```
フロントエンド
  ↓ REST API (BFFリクエスト型)
① Controller  →  ⑥ Service  →  ② Client  →  [BlockingStub]
                                    ↑⑤ServiceMapping (BFF→gRPC変換)
                                              ↓ gRPC
                                            {targetMicroservice}（マイクロサービス側で生成）
```
