# Prometheus

## 1. Prometheus là gì?
Prometheus là một hệ thống mã nguồn mở dùng để giám sát và cảnh báo, ban đầu được phát triển tại SoundCloud. Prometheus được thiết kế để thu thập, lưu trữ và truy vấn dữ liệu dạng chuỗi thời gian (time-series), rất phù hợp cho các hệ thống động như cloud-native, Kubernetes.

## 2. Đặc điểm nổi bật
- Mô hình dữ liệu đa chiều (time-series với tên metric và các nhãn key/value)
- Ngôn ngữ truy vấn mạnh mẽ (PromQL)
- Thu thập dữ liệu theo cơ chế pull qua HTTP
- Hỗ trợ phát hiện dịch vụ (service discovery) và cấu hình tĩnh
- Tích hợp cảnh báo với Alertmanager
- Có giao diện trực quan hóa cơ bản, dễ tích hợp với Grafana

## 3. Cách hoạt động
Prometheus định kỳ "scrape" (kéo) dữ liệu metrics từ các endpoint đã cấu hình (ví dụ: Node Exporter, cAdvisor, ứng dụng tự export). Dữ liệu được lưu trữ dưới dạng chuỗi thời gian. Người dùng có thể truy vấn dữ liệu bằng PromQL để trực quan hóa hoặc tạo rule cảnh báo.

## 4. Trường hợp sử dụng phổ biến
- Giám sát hạ tầng (server, VM, container)
- Giám sát hiệu năng ứng dụng
- Cảnh báo khi hệ thống gặp sự cố hoặc vượt ngưỡng SLA

## 5. Vai trò trong monitoring stack
Prometheus là trung tâm thu thập metrics. Nó lấy dữ liệu từ Node Exporter, cAdvisor, custom exporter, lưu trữ, cung cấp dữ liệu cho Alertmanager (cảnh báo) và Grafana (trực quan hóa).

## 6. Tham khảo
- [Tài liệu chính thức Prometheus](https://prometheus.io/docs/introduction/overview/)
- [Prometheus GitHub](https://github.com/prometheus/prometheus) 