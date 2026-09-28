---
name: check-conventions
description: Skill dùng để review mã Java đã thay đổi và MyBatis mapper XML theo バックエンド開発規約 (quy ước phát triển backend). Use when reviewing changed Java code or MyBatis mapper XML (pull request or local diff) in any SST Java repository — a BFF, a microservice, a framework library (sst-fw-be-*) or a standalone Java tool — against the backend development conventions (開発規約) — package structure, layer responsibilities, class suffixes, naming, comments/Javadoc, MapStruct, MyBatis, exceptions, DI, validation, logging, constants/Enum, transactions, date/time, annotation usage. Also the rule source for the /sst-common:review-code command.
---

# Skill review mã nguồn

## Thời điểm áp dụng

- Khi cần review mã Java đã thay đổi và MyBatis mapper XML trong pull request hoặc bản diff ở máy cục bộ

## Cách sử dụng

Tiêu chuẩn đánh giá chỉ lấy căn cứ từ các file .md dưới đây. Những điều không được ghi ở đó thì không phải là vi phạm quy ước.

| Mẫu | Tên file md | Mô tả |
| -------- | ------------ | ---- |
| Đánh giá | `references/backend-conventions.md` | Toàn văn 開発規約 |

## Quy trình review

1. Đọc `references/backend-conventions.md`
2. Xem bản diff chứ không phải toàn bộ file. Các vi phạm đã tồn tại ở những chỗ không thay đổi thì không thuộc đối tượng. File được đổi tên không phải là file mới. Chỉ những dòng mà diff chỉ ra là thêm mới hoặc thay đổi mới thuộc đối tượng, nội dung được mang sang thì không thuộc đối tượng.
3. Xác định tầng (layer) của từng file từ package, rồi áp dụng các quy tắc về trách nhiệm của tầng và cấu trúc package
4. Kiểm tra tên dựa theo bảng hậu tố class và quy tắc đặt tên biến
5. Khi còn do dự thì kiểm tra lại câu chữ của quy ước. Nếu quy ước không viết như vậy thì không được khẳng định như vậy

## Cách báo cáo

- Trích dẫn nguyên văn câu chữ của quy ước đã áp dụng, sau đó viết nội dung sửa cụ thể
- Trích dẫn phải được sao chép nguyên vẹn từ file đã đọc. Không viết lại theo ký ức, không lược bỏ, không dịch. Quy tắc nào không tìm thấy trong tài liệu thì không phải là quy tắc, nên hãy rút lại điểm chỉ ra đó.
- Mỗi vị trí chỉ nêu một điểm chỉ ra. Nếu cùng nguyên nhân đó xuất hiện ở file hoặc dòng khác thì báo cáo cả ở đó
- Những điều không được ghi trong quy ước (bug, bảo mật, hiệu năng) cũng có thể báo cáo, nhưng phải ghi rõ đó không phải là vi phạm quy ước

## Các mục không đưa vào review

Những mục mà bên quy ước còn chưa chốt thì không báo là vi phạm.

| Mục trong quy ước | Tình trạng |
| --- | --- |
| 5.2 `unmappedTargetPolicy = ERROR` | Code của mọi repository đang dùng `IGNORE`. Bên quy ước còn ghi 検討事項 |
| 5.2 Gom cấu hình `@Mapper` vào `BaseMapping` | Chỉ một số repository đã áp dụng |

## Placeholder trong quy ước

Tại các mục 2.1・2.2・3・5.8 của `references/backend-conventions.md`, những giá trị thay đổi theo từng repository được viết dưới dạng placeholder. Hãy đọc từ repository là đối tượng review để diễn giải. Không cần hỏi người dùng.

| Placeholder     | Cách đọc                                                 |
| -------------------- | -------------------------------------------------------------------------- |
| `{repo}`             | Tên thư mục gốc của repository                                           |
| `{basePackage}`      | Khai báo `package` của file là đối tượng review. Khớp với cấu trúc ngay dưới `src/main/java/` |
| `{ApplicationClass}` | Tên class được gắn `@SpringBootApplication`. Nếu không có thì không thực hiện đánh giá mục 2.2   |

Ở những repository không có class application như library (`sst-fw-be-*`), cấu trúc package ở mục 2.2 là quy ước dành cho BFF・microservice nên không áp dụng. Các chương 3・4・5 thì áp dụng.
