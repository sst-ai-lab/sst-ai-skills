# sst-fw-be-common

Quy tắc viết các thư viện framework backend của SST (`sst-fw-be-*`), dùng chung cho cả sáu repository. Bật cùng với `sst-common` và `sst-be-common`.

```json
{ "enabledPlugins": { "sst-common@sst-ai-skills": true, "sst-be-common@sst-ai-skills": true, "sst-fw-be-common@sst-ai-skills": true } }
```

## Nội dung

Chưa có skill nào. Tiêu chuẩn backend và catalog framework lấy từ `sst-be-common`; skill riêng của một repository framework nằm trong plugin service của nó (xem `plugins/services/sst-fw-be-core`).

## Chưa viết

Quy tắc viết một module framework. Sáu repository hiện vẫn giữ quy tắc riêng của mình, tổng 683 dòng; phần dùng chung sẽ thành skill ở đây, còn phần của riêng một repository thì đưa vào plugin service của nó.
