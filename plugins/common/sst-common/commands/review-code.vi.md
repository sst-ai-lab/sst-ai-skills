---
description: Review mã nguồn đã thay đổi theo tiêu chuẩn của mọi plugin đang được bật có cung cấp skill check-* (check-conventions, check-security, ...). Hỏi xem cần review những thay đổi nào, sau đó chỉ đánh giá theo đúng các tiêu chuẩn đó.
argument-hint: phạm vi tùy chọn — một file, một thư mục, một tên nhánh, "staged", "last commit"; để trống thì sẽ được hỏi
allowed-tools: Bash(git status:*), Bash(git diff:*), Bash(git log:*), Bash(git show:*), Bash(git symbolic-ref:*), Bash(git fetch:*), Bash(git grep:*), Read, Grep, Glob, Skill
---

Review mã nguồn đã thay đổi theo các tiêu chuẩn phát triển của repository này.

Tham số phạm vi cho lần gọi này: $ARGUMENTS

**Mỗi câu trả lời chỉ dùng một ngôn ngữ. Không bao giờ pha trộn.** Hãy chọn một lần, trước khi bạn viết bất cứ điều gì, và giữ nguyên nó cho
toàn bộ phần trả lời — câu hỏi về phạm vi, danh sách file, các phát hiện, dòng kết.

Hãy chọn theo cách sau, áp dụng quy tắc đầu tiên phù hợp:

1. ngôn ngữ mà người dùng đã dùng để viết cho bạn, nếu họ có viết văn xuôi
2. ngôn ngữ đã được dùng trước đó trong cuộc hội thoại này
3. tiếng Anh

Một lệnh `/sst-common:review-code` trơ trọi không kèm văn xuôi là trường hợp 3. Ngôn ngữ của file này, của `SKILL.md`, và của các
tài liệu tham chiếu **không** quyết định điều đó — chúng được viết bằng bất cứ ngôn ngữ nào mà chúng tình cờ
được viết, và đó không phải là tín hiệu về người đọc.

Một ngoại lệ: văn bản bạn trích dẫn từ một tài liệu tham chiếu giữ nguyên ngôn ngữ của tài liệu đó, bởi vì một
trích dẫn đã bị dịch thì không còn có thể đối chiếu lại với nguồn của nó. Một quy tắc tiếng Nhật
được trích dẫn bên trong một câu trả lời tiếng Anh là đúng và là điều được mong đợi.

## 1. Xác định phạm vi — mỗi lần đều phải làm

**Mỗi lần gọi tự xác định phạm vi của riêng nó.** Bất cứ điều gì đã thống nhất trước đó trong cuộc hội thoại này thuộc
về một lần gọi trước đó và không được mang sang. Việc vừa mới review một thứ gì đó không phải là
câu trả lời cho lần chạy này. Hãy hỏi lại.

Chỉ bỏ qua câu hỏi **khi và chỉ khi** chính lần gọi này có kèm tham số phạm vi.

### Hãy đo lường trước khi nói

Chạy đúng những lệnh sau, và không gì khác, trước từ đầu tiên bạn nói:

```
git status --short
git diff --stat
git diff --staged --stat
git symbolic-ref --short refs/remotes/origin/HEAD
git log --oneline <that-default-branch>..HEAD
```

Chạy các lệnh này chưa phải là review. Đọc file mã nguồn thì là review, nên chưa mở file nào cho tới khi người dùng chọn phạm vi.

### Sau đó hãy nói cho người dùng biết bạn đã tìm thấy gì, bằng lời

Hãy nói thay đổi này trông như đang nói về điều gì và nó chạm tới những khu vực nào — tên package, tầng, tính năng hoặc
tên màn hình. "11 file, 125 dòng thêm mới" không cho họ biết điều gì mà họ chưa biết; "6 file Java trải trên
các service auth và các controller thủ công" cho họ biết họ đang đứng ở đâu. Các con số thuộc về phần
trong ngoặc sau phần lời, chứ không phải thay cho phần lời.

Hãy giữ nó trong vài dòng ngắn. Một danh sách các khu vực thì đọc được; một câu mang sáu cụm chú thích trong ngoặc
thì không. Nếu có hơn khoảng ba khu vực bị chạm tới, hãy dùng gạch đầu dòng, mỗi khu vực một dòng.

Hai điều không bao giờ được xuất hiện:

- **Tường thuật lại quy trình của chính bạn.** Không phải "Tôi đã chạy các lệnh bắt buộc", không phải "Giờ để tôi xem các
  diff". Người dùng yêu cầu một bản review, không phải một bản ghi lại lượt của bạn.
- **Phần đường ống của git.** Staged so với unstaged so với untracked là việc ghi chép của bạn, không phải quyết định của họ.
  Chỉ nhắc tới nó ở nơi nó làm thay đổi những gì họ sẽ nhận được.

### Sau đó hãy đưa ra các phạm vi

Hãy hỏi cần review những thay đổi nào và **dừng lại. Chờ câu trả lời.** Đừng đọc file mã nguồn, đừng
nạp skill, đừng review bất cứ điều gì cho tới khi nó đến.

Hãy giữ danh sách ngắn và trung thực:

- **Bỏ mọi lựa chọn mà khi đo thì rỗng.** Đừng in nó ra chỉ để thông báo rằng nó rỗng.
- **Khi hai lựa chọn bao phủ cùng một thứ, hãy liệt kê nó một lần** và ghi chú phần trùng lặp trong nửa câu.
  Đừng bao giờ in cùng một nội dung hai lần dưới hai con số.
- **Hãy đặt tên mỗi lựa chọn theo câu hỏi mà nó trả lời**, không phải theo lệnh git của nó. "Những gì tôi đang viết ngay
  lúc này", "những gì pull request sẽ hiển thị" — người phát triển đang chọn một câu hỏi, không phải một lệnh.

Toàn bộ tập hợp để chọn ra, trước khi bỏ bớt và gộp lại:

1. Công việc chưa commit — mọi thứ đã sửa đổi, đã staged hoặc chưa được theo dõi
2. Chỉ phần đã staged
3. Commit cuối cùng — hãy nêu dòng tiêu đề của nó
4. Toàn bộ nhánh này so với một nhánh gốc — mặc định là nhánh mà `origin/HEAD` trỏ tới, và hãy nói đó là
   bao nhiêu commit. Nếu `origin/<base>` thiếu ở máy cục bộ hoặc đã cũ, hãy fetch nó trước khi diff
5. Một file hoặc thư mục mà người dùng nêu tên

Hãy khuyến nghị đúng một lựa chọn và đưa ra nửa câu lý do. Áp dụng quy tắc đầu tiên còn đúng:

- có công việc chưa commit → **1**, đó là những gì người dùng vừa mới viết
- nếu không thì nhánh đang đi trước nhánh gốc của nó → **4**
- nếu không thì → **3**

Hãy kết lại bằng một câu hỏi đơn giản. Khi mọi lựa chọn khi đo đều rỗng, hãy nói rằng cây làm việc sạch và không có
gì để review — đừng đặt một câu hỏi mà không câu trả lời nào có thể thỏa mãn.

## 2. Hiển thị những gì nằm trong phạm vi

Hãy liệt kê mọi file trong phạm vi kèm loại thay đổi của nó (đã sửa / đã thêm / đã xóa / đã đổi tên), sau đó nói
trong một dòng phạm vi là gì. Không review bất cứ thứ gì ngoài danh sách đó.

Hãy dừng lại và nói rõ ra, mà không review, khi:

- phạm vi hóa ra là rỗng
- nó không chứa file nào được bất kỳ tiêu chuẩn nào tìm thấy ở bước 3 bao phủ — tài liệu, cấu hình và
  các file build không phải là vi phạm của một tiêu chuẩn viết mã

## 3. Nạp các quy tắc

Lệnh này không mang theo tiêu chuẩn nào của riêng nó. Chúng đến từ các plugin khác đang được bật trong
repository này: **mọi skill có tên bắt đầu bằng `check-` (`check-conventions`, `check-security`,
...), trong bất kỳ plugin đang được bật nào, đều là một tập tiêu chuẩn**, và phần description của nó nói nó bao phủ
những file nào. Một skill có tên khác không phải là một tiêu chuẩn, kể cả khi tên hoặc description của nó có nhắc tới
review — `code-review` và `security-review` tìm bug, và đó không phải là điều lệnh này
làm.

1. Hãy liệt kê các skill có sẵn và chọn ra mọi `<plugin>:check-*`.
2. Hãy giữ lại mỗi skill có description bao phủ một loại file trong phạm vi. Nhiều skill có thể bao phủ cùng một file —
   một tập dùng cho toàn bộ stack và các bổ sung riêng của một service — và khi đó tất cả chúng đều áp dụng cho nó.
3. Hãy nạp mỗi skill được giữ lại và đi theo nó tới mọi tài liệu tham chiếu mà nó trỏ tới, bao gồm cả các tài liệu
   nằm trong các skill khác của cùng plugin đó. Hãy đọc tất cả.
4. Hãy nói bạn đã nạp những tiêu chuẩn nào và mỗi tiêu chuẩn bao phủ những file nào, mỗi tiêu chuẩn một dòng.

Khi một loại file trong phạm vi không được tiêu chuẩn nào bao phủ, hãy nói ra điều đó và để các file đó ra ngoài bản
review. Khi không có tiêu chuẩn nào bao phủ bất cứ thứ gì trong phạm vi, hãy dừng lại ở đó.

**Những tài liệu đó là cơ sở duy nhất cho một vi phạm.** Nếu chúng không nói điều đó, thì đó không phải là một
vi phạm — bất kể đoạn mã trông sai đến đâu. Khi một skill xếp hạng các tài liệu của nó — một tiêu chuẩn trên
một checklist, chẳng hạn — hãy đi theo thứ hạng của nó.

## 4. Review phần thay đổi, không phải cả file

Hãy đánh giá phần diff. Một vấn đề đã tồn tại từ trước trên một dòng mà thay đổi này không chạm tới thì nằm ngoài phạm vi, kể cả
khi nó nằm trong một file thuộc phạm vi.

Một file được đổi tên không phải là một file mới. Nội dung của nó đi theo cùng việc đổi tên, nên chỉ những dòng mà
diff đánh dấu là đã thêm hoặc đã thay đổi mới nằm trong phạm vi — phần còn lại là công việc trước đó của người khác, cho dù
đường dẫn trông mới đến đâu.

Hãy làm việc qua phạm vi theo từng file. Đừng dừng ở phát hiện đầu tiên, và đừng lấy mẫu — một
file trong phạm vi là một file bạn phải đọc.

Hãy lấy số dòng từ một công cụ in ra chúng, không bao giờ lấy từ việc đếm. Phần đầu hunk chỉ nói một
hunk bắt đầu ở đâu, và việc đếm các dòng của một diff hoặc của output `git show` sẽ lệch đi vài dòng. Trước khi bạn
báo cáo, hãy lấy mọi số dòng từ output có đánh số của file tại revision được review:

- khi cây làm việc đang ở revision đó — công việc chưa commit, hoặc một cây sạch mà `HEAD` của nó là
  commit được review, như trong CI — hãy Read file và dùng các số dòng mà Read in ra;
- nếu không thì hãy chạy `git grep -n -F '<exact code on that line>' <revision> -- <path>`.

## 5. Báo cáo

Chỉ các phát hiện: không mở đầu, không tổng kết cuối, không khen ngợi, không nhắc lại đoạn mã làm gì.

Với mỗi phát hiện, hãy đưa ra, theo thứ tự này:

- đường dẫn file tính từ gốc repository và dòng hoặc khoảng dòng
- quy tắc bạn đã áp dụng, được trích dẫn nguyên văn từ tài liệu tham chiếu, bằng ngôn ngữ mà tài liệu
  đó được viết, kèm theo định danh mà tài liệu đó đặt cho nó — một số mục hoặc một
  ID checklist. Khi một tài liệu ở hạng thấp hơn xung đột với một tài liệu ở hạng cao hơn, hãy trích dẫn tài liệu hạng cao hơn và
  nói rằng tài liệu kia khác biệt. Hãy sao chép câu đó ra từ file bạn đã đọc — đừng bao giờ gõ lại nó từ
  ký ức, rút ngắn nó, dàn lại dòng hay dịch nó. Một quy tắc bạn không tìm thấy trong tài liệu thì không phải là một
  quy tắc: hãy bỏ phát hiện đó thay vì diễn giải lại một quy tắc để đặt vào chỗ trống
- điều cần thay đổi, một cách cụ thể

Mỗi vị trí một phát hiện. Khi cùng một nguyên nhân gốc xuất hiện ở một file hoặc dòng khác, hãy báo cáo nó
ở đó như một phát hiện riêng của nó thay vì nhắc tới nó bên trong một cách sửa — nếu không thì tọa độ của nó bị
mất. Hai vị trí là hai phát hiện kể cả khi chúng vi phạm cùng một quy tắc hoặc nằm cách nhau vài dòng,
và hai quy tắc khác nhau tại một vị trí cũng là hai phát hiện.

Bất cứ điều gì mà các tiêu chuẩn không bao phủ là một gợi ý, không phải một vi phạm: hãy gắn nhãn nó là một gợi ý
và nói rõ rằng các tiêu chuẩn không đề cập tới nó.

Nếu không có gì để báo cáo, hãy nói như vậy trong một dòng.

## 6. Không bao giờ sửa đổi bất cứ thứ gì

Đây là một bản review. Đừng sửa, tạo, xóa, stage, commit hay format bất kỳ file nào — kể cả để
minh họa một cách sửa. Một chế độ sửa mà một skill `check-*` cung cấp không áp dụng cho lệnh này.
Thay vào đó hãy trình bày phần thay đổi dưới dạng văn bản trong báo cáo.
