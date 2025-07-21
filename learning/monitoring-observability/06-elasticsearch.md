# Elasticsearch

## 1. Elasticsearch là gì?
Elasticsearch là một công cụ tìm kiếm và phân tích dữ liệu phân tán, mã nguồn mở, rất mạnh mẽ, thường dùng để lưu trữ và truy vấn log, dữ liệu phi cấu trúc.

## 2. Đặc điểm nổi bật
- Lưu trữ, tìm kiếm, phân tích dữ liệu cực nhanh
- Hỗ trợ dữ liệu phi cấu trúc, JSON
- Khả năng mở rộng cao, phân tán
- Tích hợp tốt với Fluentd, Logstash, Kibana

## 3. Cách hoạt động
Elasticsearch lưu trữ dữ liệu dưới dạng document (JSON), cho phép tìm kiếm, phân tích dữ liệu theo thời gian thực. Fluentd sẽ gửi log vào Elasticsearch, từ đó có thể truy vấn hoặc trực quan hóa qua Kibana/Grafana.

## 4. Trường hợp sử dụng phổ biến
- Lưu trữ và tìm kiếm log tập trung
- Phân tích dữ liệu phi cấu trúc
- Làm backend cho các hệ thống phân tích dữ liệu lớn

## 5. Vai trò trong monitoring stack
Elasticsearch là nơi lưu trữ log tập trung, cho phép tìm kiếm, phân tích log hiệu quả, hỗ trợ phát hiện sự cố nhanh chóng.

## 6. Tham khảo
- [Elasticsearch Official](https://www.elastic.co/elasticsearch/)
- [Tài liệu Elasticsearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/index.html) 