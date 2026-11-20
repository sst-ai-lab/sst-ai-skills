# AI Content Studio – Cấu trúc Prompt & Skill và các nội dung AI thu thập

## 1. Kiến trúc Prompt

AI Content Studio tổ chức hướng dẫn cho AI Agent thành **hai phần**:

| Thành phần | Nội dung và vai trò |
|---|---|
| **Assistant** – `00_AIの話し方.md` | Khai báo vai trò AI là **trợ lý ảo** của nền tảng e-learning doanh nghiệp; quy định cách giao tiếp, phản hồi, thu thập thông tin và xử lý những điều chưa biết. Hướng dẫn chung này áp dụng xuyên suốt hội thoại. |
| **Skills** – mỗi kỹ năng một file | Mỗi Skill có **Name** (tên), **Description** (mô tả khi nào sử dụng) và **Instructions** (hướng dẫn thực hiện). AI lựa chọn Skill phù hợp với yêu cầu, có thể phối hợp nhiều Skill cho một tác vụ. |

Ví dụ, để tạo Curriculum, AI sử dụng Skill thu thập thông tin để xác định những gì cần hỏi, rồi áp dụng Skill thiết kế Curriculum. Khi tạo câu hỏi hoặc Skill Check, AI áp dụng các Skill tương ứng. Kiến trúc này có thể mở rộng: nếu hệ thống triển khai **AI Quality Check** trong tương lai, có thể bổ sung Skill hướng dẫn kiểm tra chất lượng nội dung. Đây là ví dụ về khả năng mở rộng, **chưa phải Skill hiện có**.

### Cơ chế hội thoại và áp dụng Skill

AI Content Studio trước hết là **trợ lý AI có thể trò chuyện và giải đáp thắc mắc thông thường**. Người dùng có thể hỏi đáp, trao đổi ý tưởng hoặc nhờ giải thích mà không cần bắt đầu quy trình tạo nội dung.

Khi người dùng **muốn tạo hoặc chỉnh sửa nội dung của hệ thống** — như Ngân hàng câu hỏi, Curriculum hoặc Skill Check — AI mới **áp dụng các Skill phù hợp** để hướng dẫn quy trình, thu thập những thông tin còn thiếu, đề xuất phương án và xác nhận trước khi tạo.

Với hội thoại thông thường, AI **không tự động đặt các câu hỏi cấu hình** hay chuyển sang quy trình tạo nội dung. Việc áp dụng Skill phụ thuộc vào yêu cầu thực tế của người dùng; mô tả này không khẳng định cách thức kỹ thuật nạp Skill vào ngữ cảnh.

## 2. Danh sách Skill hiện tại

| File Skill | Chức năng |
|---|---|
| `01_対話の進め方.md` | Hướng dẫn quy trình trao đổi, xác nhận trước khi tạo và xử lý thay đổi. |
| `02_ヒアリング項目.md` | Danh sách các nội dung AI cần hỏi hoặc tự đề xuất trước khi tạo. |
| `03_カリキュラム設計の方針.md` | Quy tắc thiết kế cấu trúc, thời lượng và phân bổ câu hỏi trong Curriculum. |
| `04_設問の品質の方針.md` | Quy tắc chất lượng câu hỏi, độ khó, đáp án và giải thích. |
| `05_スキルチェックの方針.md` | Quy tắc thiết kế và lựa chọn câu hỏi cho Skill Check. |

## 3. Những nội dung AI hỏi người dùng trước khi tạo

**Cách đọc bảng:** Cột **Cách AI xử lý** mô tả hành động của AI, không phải thao tác người dùng phải thực hiện. **Hỏi** = AI hỏi người dùng khi thiếu thông tin, kèm lựa chọn hoặc đề xuất phù hợp; **Tóm tắt** = AI tự đề xuất dựa trên yêu cầu/tài liệu và đưa vào bản tóm tắt để người dùng xác nhận, không hỏi riêng từng mục. AI không hỏi lại thông tin đã có hoặc thông tin người dùng giao AI quyết định. Chỉ áp dụng các mục liên quan đến nội dung được yêu cầu tạo.

### 3.1. Xác định phạm vi ban đầu

| STT | Nội dung | AI hỏi gì / xử lý thế nào? | Cách AI xử lý |
|---|---|---|---|
| 1 | Phạm vi tạo | Bạn muốn AI hỗ trợ tạo **Ngân hàng câu hỏi**, **Curriculum**, **Skill Check** hay **trọn gói** (Curriculum, câu hỏi và Skill Check)? | **Hỏi**; các thành phần có thể được tạo riêng. Đề xuất trọn gói nếu người dùng chưa chỉ định phạm vi. |
| 2 | Cách tiếp tục | Muốn AI **hỏi lần lượt từng mục**, hay **tự viết yêu cầu/gửi tài liệu trước**? | **Hỏi**; đề xuất hỏi lần lượt. |
| 3 | Nguồn nội dung | Có tài liệu đào tạo hoặc chủ đề để AI dựa vào chưa? | **Hỏi trong chat** nếu chưa có cả tài liệu lẫn chủ đề. |

**Lưu ý:** Skill Check là một phạm vi tạo độc lập, không bắt buộc đi kèm Curriculum. Bảng này là **đề xuất điều chỉnh nghiệp vụ** so với lựa chọn phạm vi trong Skill gốc `02_Các mục thu thập.md`; các file Skill tiếng Việt gốc được giữ nguyên để đối chiếu.

### 3.2. Khi tạo Curriculum

| STT | Nội dung | AI hỏi gì / xử lý thế nào? | Cách AI xử lý |
|---|---|---|---|
| 1 | Đối tượng học viên | Chương trình dành cho ai? | **Hỏi**; đề xuất đối tượng phù hợp với tài liệu, kèm 2–3 lựa chọn. |
| 2 | Mục tiêu học tập | Sau khi học xong, học viên cần biết hoặc làm được gì? | **Hỏi**; đưa 2–3 mục tiêu phù hợp với tài liệu và đối tượng. |
| 3 | Quy mô chương trình | Muốn quy mô **nhỏ, vừa hay lớn**? | **Hỏi khi không có tài liệu**; đề xuất **vừa**. Nếu có tài liệu, AI đề xuất theo mục lục và đưa vào tóm tắt. |
| 4 | Tên và mô tả Curriculum | Chương trình sẽ có tên và phần giới thiệu như thế nào? | **Tóm tắt**; AI đề xuất từ tài liệu và đối tượng. |
| 5 | Danh sách chương | Có những chương nào, thứ tự ra sao, mỗi chương có bao nhiêu chủ đề và thời lượng bao lâu? | **Tóm tắt**; AI đề xuất theo cấu trúc tài liệu. |
| 6 | Nội dung loại trừ | Có chương nào của tài liệu không đưa vào chương trình không? Vì sao? | **Tóm tắt**; nếu không có, ghi “Không có”. |

### 3.3. Khi tạo câu hỏi

| STT | Nội dung | AI hỏi gì / xử lý thế nào? | Cách AI xử lý |
|---|---|---|---|
| 1 | Số câu hỏi | Mỗi chủ đề cần **1, 2 hay 3 câu hỏi**? | **Hỏi**; đề xuất **2 câu/chủ đề**. |
| 2 | Tỉ lệ độ khó | Muốn phân bổ câu **dễ, trung bình, khó** như thế nào? | **Hỏi**; đưa 2–3 phương án tỉ lệ phù hợp với đối tượng và tài liệu. |
| 3 | Số câu theo độ khó | Với tổng số câu đã chọn, mỗi mức độ khó có bao nhiêu câu? | **Tóm tắt**; AI tính để tổng khớp số câu đã chọn. |
| 4 | Thời gian làm bài | Mỗi câu cần bao nhiêu thời gian? | **Tóm tắt**; AI đề xuất theo độ dài và độ khó từng câu. |
| 5 | Giải thích đáp án | Giải thích đáp án ở mức nào? | **Tóm tắt**; đề xuất lý do đáp án đúng **và** lý do từng đáp án sai. |
| 6 | Ngôn ngữ câu hỏi | Câu hỏi được viết bằng ngôn ngữ nào? | **Tóm tắt**; theo ngôn ngữ hội thoại, không tự đổi theo ngôn ngữ tài liệu. |

### 3.4. Khi tạo Skill Check

| STT | Nội dung | AI hỏi gì / xử lý thế nào? | Cách AI xử lý |
|---|---|---|---|
| 1 | Mục đích đánh giá | Đánh giá **trước khi học** hay **xác nhận sau khi học**? | **Hỏi**; đề xuất **sau khi học**. |
| 2 | Số câu đánh giá | Skill Check cần bao nhiêu câu? | **Hỏi**; đưa 3 phương án theo số chương, đề xuất **2 câu/chương**. |
| 3 | Số câu theo độ khó | Có bao nhiêu câu dễ, trung bình và khó? | **Tóm tắt**; AI phân bổ theo mục đích đánh giá. |
| 4 | Nguồn câu hỏi | Sử dụng câu hỏi đã có trong Curriculum hay cần câu mới? | **Tóm tắt**; ưu tiên câu hỏi Curriculum nếu có. Trường hợp mục đích/nguồn chưa rõ, AI có thể hỏi thêm theo Skill thiết kế Skill Check. |
| 5 | Lựa chọn “Chưa có kinh nghiệm” (`未経験`) | Có hiển thị lựa chọn này không? | **Tóm tắt**; hiện ở đánh giá trước học, ẩn ở đánh giá sau học. |
| 6 | Nhóm phân tích | Kết quả đánh giá thuộc nhóm phân tích nào? | **Tóm tắt**; dùng nhóm phù hợp đã có hoặc đề xuất tạo nhóm mới. |
| 7 | Đối tượng và thời điểm làm bài | Ai được làm bài, khi nào được bắt đầu? | **Tóm tắt**; mặc định người học nội bộ, có thể làm ngay sau khi lưu. |
| 8 | Thời gian giới hạn | Tổng thời gian làm Skill Check là bao lâu? | **Tóm tắt**; bằng tổng thời gian của các câu. |
| 9 | Ngày chuẩn báo cáo | Dùng ngày nào để lập báo cáo? | **Tóm tắt**; mặc định ngày hiện tại. |

## 4. Quy tắc AI thực hiện sau khi thu thập thông tin

| Nhóm | Quy tắc chính |
|---|---|
| Hội thoại | Xác định yêu cầu → làm rõ phạm vi → hỏi mục còn thiếu → **hiển thị tóm tắt để xác nhận** → tạo và báo cáo. Không bỏ qua bước xác nhận trước khi tạo. |
| Curriculum | Cấu trúc **4 cấp**, tới cấp chủ đề; nếu tạo câu hỏi thì **ít nhất 1 câu/chủ đề**. Phân bổ số câu theo lượng nội dung, thời lượng theo độ dài chủ đề. |
| Chất lượng câu hỏi | Độ khó phản ánh yêu cầu ghi nhớ, áp dụng hoặc kết hợp; đáp án sai phải hợp lý; giải thích dựa trên nguồn; thời gian phù hợp độ dài và độ khó. |
| Skill Check | Sau học có câu dễ, trung bình, khó và **ít nhất 1 câu khó**; trước học ưu tiên dễ và trung bình. Phủ đều các chương, sắp xếp câu từ dễ đến khó. |
| Thay đổi | Sửa nhỏ có thể thực hiện ngay; sửa lớn phải xác nhận ảnh hưởng. Nếu thay đổi ở bước tóm tắt, AI cập nhật tóm tắt để xác nhận lại. |

## 5. Quản lý Prompt & Skill trên giao diện

AI Content Studio đã bổ sung **giao diện xem và cập nhật Assistant/Skill**. Người quản trị có thể xem nội dung đang cấu hình và điều chỉnh các hướng dẫn AI trực tiếp trên UI, thuận tiện cho quá trình **phát triển, kiểm thử và bảo trì**, không cần chỉnh sửa file thủ công mỗi lần tinh chỉnh Prompt. Khi có chức năng mới, có thể bổ sung Skill tương ứng trong phạm vi khả năng hệ thống hỗ trợ.

---

**Lưu ý khi đối chiếu:** Danh sách trên mô tả các **đầu mục AI cần thu thập hoặc xác nhận**, không phải kịch bản câu chữ cố định. AI chỉ hỏi những mục còn thiếu và phù hợp với phạm vi người dùng yêu cầu; các mục ghi **Tóm tắt** vẫn được người dùng xem và sửa trước khi tạo.
