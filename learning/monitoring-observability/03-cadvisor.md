# cAdvisor

## 1. cAdvisor là gì?
cAdvisor (Container Advisor) là một công cụ mã nguồn mở của Google, dùng để thu thập, tổng hợp, xử lý và xuất metrics về hiệu suất của các container (chủ yếu là Docker).

## 2. Đặc điểm nổi bật
- Thu thập metrics chi tiết về container: CPU, memory, network, filesystem...
- Tự động phát hiện container đang chạy
- Giao diện web trực quan hóa metrics
- Tích hợp tốt với Prometheus

## 3. Cách hoạt động
cAdvisor chạy như một daemon trên node, tự động phát hiện và thu thập metrics từ các container. Metrics được expose qua HTTP endpoint (mặc định 8080 hoặc 4194), Prometheus sẽ scrape endpoint này.

## 4. Trường hợp sử dụng phổ biến
- Giám sát hiệu suất container trong môi trường Docker/Kubernetes
- Phân tích bottleneck tài nguyên ở cấp độ container

## 5. Vai trò trong monitoring stack
cAdvisor cung cấp metrics chi tiết về container cho Prometheus, giúp bạn giám sát sâu sát các workload chạy trên nền tảng container.

## 6. Tham khảo
- [cAdvisor GitHub](https://github.com/google/cadvisor)
- [Tài liệu Prometheus cAdvisor](https://prometheus.io/docs/guides/cadvisor/) 