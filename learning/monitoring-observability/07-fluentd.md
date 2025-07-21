# Fluentd

## 1. Fluentd là gì?
Fluentd là một công cụ mã nguồn mở dùng để thu thập, chuyển đổi và chuyển tiếp log từ nhiều nguồn tới các hệ thống lưu trữ như Elasticsearch, Kafka, S3...

## 2. Đặc điểm nổi bật
- Hỗ trợ nhiều input/output plugin
- Dễ dàng cấu hình pipeline xử lý log
- Khả năng mở rộng cao
- Tích hợp tốt với các hệ thống log hiện đại

## 3. Cách hoạt động
Fluentd thu thập log từ nhiều nguồn (file, syslog, ứng dụng...), xử lý (filter, parse, transform) và chuyển tiếp tới đích (Elasticsearch, Kafka...).

## 4. Trường hợp sử dụng phổ biến
- Thu thập log tập trung từ nhiều ứng dụng, server
- Chuyển đổi định dạng log
- Gửi log tới Elasticsearch để phân tích, trực quan hóa

## 5. Vai trò trong monitoring stack
Fluentd là "log shipper" trung tâm, đảm nhận việc thu thập và chuyển log về Elasticsearch, giúp hệ thống có log tập trung, dễ tìm kiếm và phân tích.

## 6. Tham khảo
- [Fluentd Official](https://www.fluentd.org/)
- [Tài liệu Fluentd](https://docs.fluentd.org/) 