---
name: hearing-items
title: Các mục thu thập (ヒアリング項目)
description: >-
  Checklist các mục quyết định cùng người dùng trước khi tạo mới curriculum, câu hỏi, skill check: mục cần hỏi, và mục không hỏi mà quyết theo đề xuất rồi ghi vào tóm tắt trước khi tạo. Dùng khi tạo mới.
---
# Các mục thu thập

Trước khi tạo mới, quyết định đủ mọi mục liên quan tới thứ sẽ tạo. Mỗi mục thuộc một trong hai loại sau.

- 【Hỏi】 Nếu chưa biết thì hỏi bằng câu hỏi dạng chọn. Kèm một lựa chọn đề xuất, và một câu nói mục đó ảnh hưởng tới điều gì.
- 【Tóm tắt】 Không hỏi, quyết theo đề xuất rồi ghi vào tóm tắt trước khi tạo. Người dùng sửa được ở bước tóm tắt.

Quy tắc chung:

- Mục biết được từ hội thoại, tài liệu, các câu trả lời trước thì dù là 【Hỏi】 cũng không hỏi, mà ghi vào tóm tắt.
- Lựa chọn tạo từ tài liệu và hội thoại. Không chép nguyên văn lời của các lựa chọn viết ở đây.
- Mục người dùng giao cho AI quyết, hoặc mục không trả lời, thì quyết theo đề xuất.
- Không xử lý các mục của phần không tạo (không tạo câu hỏi, không tạo skill check).
- Thứ tự hỏi là thứ tự từ trên xuống của danh sách này.

## 1. Quyết định đầu tiên

- **Phạm vi tạo** 【Hỏi】: ngân hàng câu hỏi / curriculum / skill check / trọn gói (curriculum, câu hỏi, skill check). Ba thành phần có thể tạo riêng; nếu người dùng chỉ định một phần hoặc kết hợp cụ thể thì giữ đúng phạm vi đó, không ép chọn trọn gói. Khi chưa rõ, có thể đề xuất trọn gói nhưng giải thích ngắn gọn từng lựa chọn.
- **Cách tiếp tục** 【Hỏi】: hỏi từng mục / người dùng tự viết yêu cầu trước hoặc gửi tài liệu. Đề xuất là hỏi từng mục.
- **Nguồn nội dung**: tài liệu hoặc chủ đề. Khi chưa có cả hai thì hỏi trong chat.

## 2. Curriculum

- **Đối tượng** 【Hỏi】: ảnh hưởng tới độ khó, thuật ngữ, tình huống. Lựa chọn: 2–3 đối tượng, gồm người đọc mà tài liệu nhắm tới và các đối tượng lân cận. Đề xuất là người đọc mà tài liệu nhắm tới.
- **Mục tiêu học** 【Hỏi】: ảnh hưởng tới trọng tâm, và câu hỏi hỏi về điều gì. Lựa chọn: 2–3 điều học viên làm được sau khi học xong, lấy từ tài liệu và đối tượng.
- **Quy mô** 【Hỏi: chỉ khi không có tài liệu】: 3 mức nhỏ, vừa, lớn, kèm số chương và thời lượng học ước chừng. Đề xuất là vừa. Khi có tài liệu thì quyết theo mục lục của tài liệu 【Tóm tắt】.
- **Tên và mô tả curriculum** 【Tóm tắt】: từ tài liệu và đối tượng.
- **Danh sách chương** 【Tóm tắt】: tên và thứ tự chương, số chủ đề và thời lượng học của mỗi chương. Từ cấu trúc tài liệu.
- **Chương tài liệu không đưa vào** 【Tóm tắt】: chương không đưa vào và lý do. Không có thì ghi 「không có」.

## 3. Câu hỏi (khi tạo câu hỏi)

- **Phạm vi kiến thức/chủ đề** 【Hỏi nếu chưa rõ】: xác định từ yêu cầu hoặc tài liệu. Khi tạo ngân hàng câu hỏi độc lập, không yêu cầu chương hay chủ đề cấp 4 của curriculum.

- **Số lượng câu hỏi** 【Hỏi】: nếu tạo câu hỏi gắn curriculum, hỏi số câu mỗi chủ đề (1, 2, 3; đề xuất 2). Nếu chỉ tạo ngân hàng câu hỏi, hỏi tổng số câu hoặc số câu theo nhóm chủ đề, không yêu cầu có curriculum. Đề xuất lượng phù hợp phạm vi và nguồn.
- **Tỉ lệ độ khó** 【Hỏi】: ảnh hưởng tới điều câu hỏi hỏi (dễ: nhớ quy định; trung bình: áp dụng vào tình huống; khó: kết hợp nhiều quy định). Lựa chọn: 2–3 tổ hợp tỉ lệ, theo đối tượng và chất liệu của tài liệu.
- **Số câu mỗi độ khó** 【Tóm tắt】: tính từ tỉ lệ và tổng số câu, cho tổng khớp với tổng số câu.
- **Thời gian làm bài** 【Tóm tắt】: đặt từng câu theo độ khó, ghi khoảng giây của mỗi độ khó.
- **Giải thích** 【Tóm tắt】: vì sao đáp án đúng, và vì sao từng đáp án sai.
- **Ngôn ngữ** 【Tóm tắt】: ngôn ngữ của hội thoại. Không đổi chỉ vì tài liệu viết bằng ngôn ngữ khác.

## 4. Skill check (khi tạo skill check)

- **Phạm vi đánh giá** 【Hỏi nếu chưa rõ】: curriculum đã chọn, nhóm chủ đề/kiến thức, hoặc phạm vi người dùng chỉ định. Skill check không bắt buộc gắn curriculum.

- **Mục đích** 【Hỏi】: xác nhận sau khi học / đánh giá trước khi học. Ảnh hưởng tới thời điểm dùng, lựa chọn D, nhóm phân tích. Đề xuất là xác nhận sau khi học.
- **Số câu** 【Hỏi】: ảnh hưởng tới thời gian làm và độ phủ phạm vi. Đưa 2–3 phương án theo phạm vi đánh giá đã xác nhận; chỉ dùng số chương và đề xuất 2 câu/chương khi skill check thực sự gắn curriculum.
- **Số câu mỗi độ khó** 【Tóm tắt】: theo chính sách skill check.
- **Nguồn câu hỏi** 【Hỏi nếu chưa rõ】: sử dụng câu hỏi thuộc curriculum đã chọn, sử dụng câu hỏi từ ngân hàng câu hỏi, hoặc tạo câu hỏi mới vào ngân hàng rồi dùng cho skill check. Nếu yêu cầu đã nêu rõ nguồn thì không hỏi lại; nếu AI có thể đề xuất nguồn phù hợp, ghi đề xuất và lý do vào tóm tắt để xác nhận.
- **Lựa chọn D 「未経験」 (chưa có kinh nghiệm)** 【Tóm tắt】: hiện khi đánh giá trước khi học, không hiện khi xác nhận sau khi học.
- **Nhóm phân tích** 【Tóm tắt】: từ mục đích và đối tượng. Có nhóm sẵn phù hợp thì dùng nhóm đó, không thì ghi tạo mới kèm tên.
- **Loại người làm bài và cho phép làm bài** 【Tóm tắt】: người học trong công ty, làm được ngay sau khi lưu.
- **Thời gian giới hạn** 【Tóm tắt】: tổng thời gian làm bài của các câu.
- **Ngày chuẩn của báo cáo** 【Tóm tắt】: hôm nay.
