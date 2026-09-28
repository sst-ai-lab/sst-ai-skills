# cm-be-spec

Các skill riêng của `cm-be-spec`. Bật cùng với `sst-common`. Repository này chứa contract TypeSpec và OpenAPI, không có source Java viết tay, nên không bật `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "cm-be-spec@sst-ai-skills": true } }
```

| Skill | Mục đích |
| --- | --- |
| `scaffold-contract` | Contract BFF (TypeSpec) và contract gRPC (OpenAPI YAML) từ tài liệu thiết kế |
| `scaffold-integration-contract` | Contract TypeSpec chỉ ở phía BFF cho các tích hợp bên ngoài |
