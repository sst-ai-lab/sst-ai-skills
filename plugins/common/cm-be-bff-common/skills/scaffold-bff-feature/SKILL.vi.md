---
name: scaffold-bff-feature
description: Skill dùng để tự động sinh backend phía BFF. Sử dụng trong repository BFF (cm-be-bff-*) khi scaffold một feature BFF mới từ tài liệu thiết kế backend (設計書) — sinh ra BFF Controller, ControllerMapping, gRPC Client/ClientImpl, ServiceMapping và Service/ServiceImpl bằng các stub và model được sinh bởi cm-be-spec. Chỉ sinh phía BFF; phía microservice được sinh trong repository microservice.
---

# Skill backend (phía BFF)

## Thời điểm áp dụng

- Khi cần tự động sinh backend của BFF

## Phạm vi

- **Có sinh:** ① đến ⑦ của BFF (Controller, ControllerMapping, gRPC Client / ClientImpl, ServiceMapping, Service / ServiceImpl)
- **Không sinh:** phía microservice (gRPC service, ServiceMapping, MyBatis Mapper / XML, model lưu trữ, Service / ServiceImpl).
  Được sinh ở phía repository `{targetMicroservice}`.
  Sau khi sinh xong phía BFF, phải trình bày cho người dùng phần "Chuyển giao sang phía microservice" trong `references/preflight-and-checklist.md`.

## Cách sử dụng

Về cách sử dụng chi tiết, hãy tham khảo các file .md dưới đây.

| Mẫu     | Tên file md                                        | Mô tả                   |
| ------------ | --------------------------------------------------- | ---------------------- |
| Tạo mới ban đầu     | `references/inputs-and-naming.md`                   | Tạo mới ban đầu backend (tổng quan, điều kiện tiên quyết, các điểm cần xác nhận với người dùng, quy tắc đặt tên) |
| Tạo mới ban đầu     | `references/file-structure.md`                      | Cấu trúc file/thư mục, luồng dữ liệu |
| Tạo mới ban đầu     | `templates/bff-templates.md`                        | Template file Java (BFF ① đến ⑦) |
| Tạo mới ban đầu     | `references/conversion-rules.md`                    | Quy tắc tự động chuyển đổi từ tài liệu thiết kế, bảng tra nhanh mẫu triển khai |
| Tạo mới ban đầu     | `references/preflight-and-checklist.md`             | Kiểm tra file trước khi thực thi (bắt buộc), checklist thực thi, chuyển giao sang phía microservice, các lưu ý |

## Các giá trị cần quyết định trước khi sinh

Giá trị nào đọc được từ repository thì đọc. Chỉ xác nhận với người dùng những giá trị không đọc được.

| Placeholder        | Cách quyết định                                                                      |
| ----------------------- | --------------------------------------------------------------------------- |
| `{repo}`                | Tên thư mục gốc của repository                                            |
| `{basePackage}`         | Khai báo `package` trong các file Java hiện có (`{basePackagePath}` là dạng thư mục của nó) |
| `{grpcChannel}`         | Tên channel được ghi trong cấu hình gRPC client hiện có                        |
| `{targetMicroservice}`  | Tên repository của microservice được gọi đến — xác nhận với người dùng                |
| Phân loại lớn                  | Chọn từ bảng mapping phân loại lớn trong `references/inputs-and-naming.md` — xác nhận với người dùng |

## Tái sử dụng framework

Trước khi viết mới utility, exception, validation, DTO, hãy kiểm tra xem framework dùng chung (`sst-fw-be-*`) đã có sẵn thứ tương tự hay chưa. Những gì đã có thì không tạo lại, hãy dùng chúng.
