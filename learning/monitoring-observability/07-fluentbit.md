# Fluent Bit

## 1. Fluent Bit là gì?
Fluent Bit là một công cụ mã nguồn mở, nhẹ, hiệu năng cao dùng để thu thập, xử lý và chuyển tiếp log từ nhiều nguồn tới các hệ thống lưu trữ như Elasticsearch, Kafka, Loki, Fluentd...

## 2. Đặc điểm nổi bật
- Kích thước nhỏ gọn, tiêu tốn rất ít tài nguyên (CPU, RAM)
- Khởi động nhanh, phù hợp cho môi trường container, edge, IoT
- Hỗ trợ nhiều input/output plugin cơ bản
- Dễ dàng tích hợp với Fluentd, Elasticsearch, Loki, Kafka...
- Cấu hình đơn giản, dễ triển khai tự động

## 3. Cách hoạt động
Fluent Bit thường được triển khai như một log agent trên mỗi node hoặc container. Nó thu thập log từ file, syslog, container..., có thể filter, parse, chuyển đổi cơ bản rồi chuyển tiếp log tới hệ thống lưu trữ trung tâm (Elasticsearch, Loki, Fluentd...).

## 4. Trường hợp sử dụng phổ biến
- Làm log agent trên node, pod, container trong Kubernetes
- Thu thập log nhẹ, chuyển tiếp về Fluentd hoặc hệ thống log trung tâm
- Dùng ở môi trường tài nguyên hạn chế (IoT, edge)

## 5. Vai trò trong monitoring stack
Fluent Bit là log forwarder/agent, đảm nhận việc thu thập log tại nguồn (node, container) và chuyển tiếp về Fluentd hoặc hệ thống lưu trữ log tập trung, giúp hệ thống log linh hoạt, hiệu quả và tiết kiệm tài nguyên.

## 6. Tham khảo
- [Fluent Bit Official](https://fluentbit.io/)
- [Tài liệu Fluent Bit](https://docs.fluentbit.io/manual/)