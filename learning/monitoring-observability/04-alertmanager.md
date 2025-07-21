# Alertmanager

## 1. Alertmanager là gì?
Alertmanager là một thành phần trong hệ sinh thái Prometheus, dùng để quản lý, xử lý và gửi cảnh báo (alert) dựa trên rule do Prometheus phát hiện.

## 2. Đặc điểm nổi bật
- Quản lý, nhóm, lọc và định tuyến cảnh báo
- Hỗ trợ gửi cảnh báo qua nhiều kênh: email, Slack, Telegram, webhook...
- Hỗ trợ silencing (tạm dừng cảnh báo), inhibition (ngăn chặn cảnh báo trùng lặp)
- Dễ dàng tích hợp với Prometheus

## 3. Cách hoạt động
Prometheus gửi alert tới Alertmanager khi rule bị vi phạm. Alertmanager sẽ xử lý, nhóm, lọc và gửi cảnh báo tới các kênh đã cấu hình.

## 4. Trường hợp sử dụng phổ biến
- Gửi cảnh báo hệ thống tới DevOps, SRE, admin
- Quản lý cảnh báo tập trung cho nhiều môi trường

## 5. Vai trò trong monitoring stack
Alertmanager là trung tâm xử lý và phân phối cảnh báo, đảm bảo thông tin sự cố đến đúng người, đúng kênh, đúng thời điểm.

## 6. Tham khảo
- [Alertmanager GitHub](https://github.com/prometheus/alertmanager)
- [Tài liệu Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) 