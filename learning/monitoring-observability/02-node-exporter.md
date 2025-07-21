# Node Exporter

## 1. Node Exporter là gì?
Node Exporter là một thành phần mã nguồn mở thuộc hệ sinh thái Prometheus, dùng để thu thập các chỉ số (metrics) về hệ thống máy chủ như CPU, bộ nhớ, ổ đĩa, mạng, v.v.

## 2. Đặc điểm nổi bật
- Thu thập đa dạng các metrics hệ thống (CPU, RAM, Disk, Network...)
- Dễ dàng triển khai trên nhiều hệ điều hành
- Tích hợp tốt với Prometheus
- Hỗ trợ nhiều collector cho từng loại tài nguyên

## 3. Cách hoạt động
Node Exporter chạy như một service trên máy chủ, mở một HTTP endpoint (mặc định là 9100). Prometheus sẽ định kỳ "scrape" endpoint này để lấy dữ liệu metrics.

## 4. Trường hợp sử dụng phổ biến
- Giám sát tài nguyên vật lý của server
- Theo dõi hiệu suất hệ thống
- Làm nguồn dữ liệu cho cảnh báo về tài nguyên

## 5. Vai trò trong monitoring stack
Node Exporter là nguồn cung cấp metrics hệ thống cho Prometheus, giúp bạn có cái nhìn tổng quan về sức khỏe của hạ tầng vật lý hoặc VM.

## 6. Tham khảo
- [Node Exporter GitHub](https://github.com/prometheus/node_exporter)
- [Tài liệu Node Exporter](https://prometheus.io/docs/guides/node-exporter/) 