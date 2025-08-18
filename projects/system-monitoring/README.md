## Hệ thống Monitoring – Hands‑on Lab

Dự án này là một môi trường thực hành (hands‑on) giúp bạn học và lab về giám sát hệ thống: thu thập metrics, logs, health check, cảnh báo và trực quan hóa.

### Thành phần chính
- **Prometheus**: Thu thập metrics, đánh giá rule, gửi alert.
- **Alertmanager**: Nhận và route cảnh báo (email, chat…).
- **Grafana**: Dashboard và trực quan hóa metrics/logs.
- **Loki**: Lưu trữ logs ở dạng chỉ mục nhãn (labels), tối ưu truy vấn.
- **Fluent Bit**: Thu thập logs container Docker và đẩy vào Loki.
- **cAdvisor**: Expose metrics về container (CPU, Memory, IO…).
- **Node Exporter**: Expose metrics của máy chủ (CPU, RAM, Disk…).
- **Blackbox Exporter**: Kiểm tra HTTP/HTTPS endpoint (UP/DOWN, latency, SSL…).

Tất cả được dựng bằng `docker-compose` để khởi chạy nhanh trong môi trường học tập/lab.

### Yêu cầu
- Docker và Docker Compose
- Các cổng chưa bị chiếm: 9090 (Prometheus), 9093 (Alertmanager), 3003 (Grafana), 3100 (Loki), 2020 (Fluent Bit HTTP), 8080 (cAdvisor), 9115 (Blackbox), 9100 (Node Exporter)

### Cài đặt nhanh
1) Di chuyển vào thư mục dự án
```bash
cd projects/system-monitoring
```

2) (Khuyến nghị) Cập nhật target của Node Exporter trong `prometheus/prometheus.yml`:
- Mặc định đang trỏ tới một địa chỉ ví dụ: `10.0.1.15:9100`.
- Hãy sửa thành IP của host máy bạn (Linux thường là `172.17.0.1:9100`) hoặc `host.docker.internal:9100` (được Docker Desktop hỗ trợ) để Prometheus (chạy trong container) có thể scrape được Node Exporter (chạy `network_mode: host`).

3) (Tuỳ chọn) Cấu hình Alertmanager SMTP trong `alertmanager/alertmanager.yml` bằng tài khoản email của bạn. Lưu ý không commit thông tin nhạy cảm.

4) Khởi chạy toàn bộ stack
```bash
docker compose up -d
```

5) Truy cập dịch vụ
- Grafana: `http://localhost:3003` (mặc định tài khoản: admin / admin)
- Prometheus: `http://localhost:9090`
- Alertmanager: `http://localhost:9093`
- Loki API: `http://localhost:3100` (dùng qua Grafana để truy vấn logs)
- Fluent Bit metrics: `http://localhost:2020/api/v1/metrics/prometheus`
- cAdvisor UI: `http://localhost:8080`
- Blackbox Exporter: `http://localhost:9115`

### Dashboards (Grafana)
Các dashboard được provision tự động từ `grafana/provisioning/dashboards`:
- `Host Overview Dashboard` (file: `node-monitoring-dashboard.json`): Toàn cảnh CPU, RAM, Disk, chi tiết theo core/mode.
- `Container Monitoring Overview` (file: `container-monitoring-dashboard.json`): CPU/Memory/Network/Disk theo container từ cAdvisor.
- `Service Health Monitoring` (file: `service-health-dashboard.json`): Trạng thái UP/DOWN, response time, HTTP status, SSL expiry từ Blackbox.

Datasource:
- Prometheus (mặc định): `http://prometheus:9090`
- Loki: `http://loki:3100`

### Alerting
- Cấu hình Alertmanager: `alertmanager/alertmanager.yml` (SMTP Gmail ví dụ). Hãy thay `smtp_auth_password` và địa chỉ email theo của bạn.
- Rule Prometheus:
  - `prometheus/alerts/general.rules.yml`: CPU cao, container down (ví dụ).
  - `prometheus/alerts/log.rules.yml`: Alert dựa trên lượng log (khi đã gắn nhãn/level phù hợp từ Fluent Bit → Loki → Grafana/LokQL).
  - `prometheus/alerts/service.rules.yml`: Alert khi dịch vụ DOWN, chậm, SSL sắp hết hạn (Blackbox).

### Thu thập logs (Fluent Bit → Loki)
- Input: Tail file JSON của Docker tại `/var/lib/docker/containers/*/*.log` (Docker_Mode On, Parser `docker`).
- Lua filter: `get_container_name.lua` để thêm nhãn `container_name` từ container id.
- Bộ lọc `modify` thêm nhãn khi log có chuỗi `TOKEN_USAGE_METRICS` (ví dụ dùng học tập để sinh label `metric_type=token_usage`).
- Output: Đẩy vào Loki với labels: `container_id`, `container_name`, `metric_type`.
- Mở HTTP server (`:2020`) để Prometheus scrape metrics của Fluent Bit nếu cần.

Gợi ý học tập:
- Bật filter `grep` trong `fluent-bit/fluent-bit.conf` để chỉ lấy các dòng log theo pattern bạn cần (ví dụ FLOW_COMPLETION_TIME…).
- Thử thêm Lua parser khác (đã mount sẵn mẫu script) để trích xuất field phục vụ alert/logQL.

### Health check dịch vụ (Blackbox)
- Module HTTP 2xx được định nghĩa trong `blackbox/blackbox.yml`.
- Cập nhật danh sách dịch vụ cần check tại job `service-health` trong `prometheus/prometheus.yml` → `static_configs.targets`.
- Cơ chế `relabel_configs` đã map instance thành tên ngắn gọn trên dashboard/alerts.

### Lưu trữ dữ liệu
- Prometheus TSDB: `./prometheus/data`
- Loki: `./loki/data` (retention mặc định 168h trong `loki/config.yml`)
- Grafana: `./grafana/data`

### Cấu trúc thư mục
```
projects/system-monitoring/
  ├─ docker-compose.yml
  ├─ prometheus/
  │  ├─ prometheus.yml
  │  └─ alerts/
  ├─ alertmanager/
  │  └─ alertmanager.yml
  ├─ grafana/
  │  └─ provisioning/
  │     ├─ datasources/
  │     └─ dashboards/
  ├─ loki/
  │  └─ config.yml
  ├─ fluent-bit/
  │  ├─ fluent-bit.conf
  │  └─ parsers.conf
  └─ blackbox/
     └─ blackbox.yml
```

### Lệnh hữu ích
```bash
# Xem trạng thái dịch vụ
docker compose ps

# Xem logs theo dịch vụ
docker compose logs -f prometheus
docker compose logs -f grafana
docker compose logs -f fluent-bit

# Truy vấn nhanh Prometheus từ UI: http://localhost:9090
# Ví dụ: 100 - (irate(node_cpu_seconds_total{mode="idle"}[5m]) * 100)

# Truy vấn logs Loki trong Grafana (Explore)
# Ví dụ LogQL: {container_name="prometheus"} |= "error"

# Dừng và xóa stack
docker compose down
```

### Troubleshooting
- **Prometheus không thấy Node Exporter**: Kiểm tra target trong `prometheus.yml`. Hãy dùng IP của host (ví dụ `172.17.0.1:9100`) hoặc `host.docker.internal:9100` nếu khả dụng. Đảm bảo port 9100 mở.
- **Không thấy dashboard Grafana**: Kiểm tra provisioning path `grafana/provisioning/dashboards` đã mount đúng trong `docker-compose.yml` và container `grafana` đã chạy.
- **Fluent Bit không đẩy được logs sang Loki**: Kiểm tra `loki:3100` có chạy; xác thực labels/fields trong `fluent-bit.conf`; đảm bảo mount lua scripts đúng đường dẫn.
- **Blackbox không có dữ liệu**: Xem `service-health` trong `prometheus.yml`, kiểm tra `relabel_configs` và module `http_2xx` của Blackbox.

### Ý tưởng mở rộng/lab thêm
- Thêm channel alert khác (Slack, Telegram…).
- Viết thêm rule cảnh báo tùy nhu cầu (disk > 90%, memory > 90%…).
- Bổ sung dashboard cho ứng dụng riêng (business metrics, SLI/SLO).
- So sánh pipeline logs dùng Fluent Bit vs Promtail.
- Dùng external storage cho Loki/Prometheus, thay đổi retention.

