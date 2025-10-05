# Logging Fundamentals for DevOps Engineers

## 1. Triết lý và Nguyên tắc Cơ bản

### 1.1 Đơn giản hóa theo Thực tế
- **Nguyên tắc**: Bắt đầu đơn giản, phát triển dần dần
- **Thực tế**: Không cần hệ thống logging hoàn hảo ngay từ đầu
- **Giải pháp ban đầu**:
  - Xuất log ra file
  - Script quét keywords mỗi phút
  - Cảnh báo khi phát hiện error
  - Đảm bảo team có thể làm việc mà không phụ thuộc vào bạn

### 1.2 Khi nào cần Centralized Logging?
- ✅ Hệ thống phân tán (Distributed Systems)
- ✅ Kiến trúc Microservices
- ✅ Yêu cầu phân tích log để cải thiện hệ thống
- ✅ Cần truy vết sự cố một cách bài bản
- ✅ Compliance và Audit requirements
- ✅ Multi-environment (dev/staging/prod)

## 2. Phân loại Log trong Thực tế

### 2.1 Application Logs
- **Mục đích**: Ghi lại hành vi và trạng thái của ứng dụng
- **Ví dụ**: Business logic, API calls, database operations
- **Đặc điểm**: Structured, có context cụ thể

### 2.2 System Logs
- **Mục đích**: Ghi lại log hệ điều hành và các service nền tảng
- **Ví dụ**: Kernel logs, systemd logs, hardware events
- **Đặc điểm**: Unstructured, cần parsing

### 2.3 Infrastructure Logs
- **Mục đích**: Theo dõi trạng thái hạ tầng platform
- **Ví dụ**: Kubernetes events, load balancer logs, gateway logs
- **Đặc điểm**: High-frequency, có patterns

### 2.4 Access Logs
- **Mục đích**: Theo dõi requests đến hệ thống
- **Ví dụ**: Nginx access logs, API gateway logs
- **Đặc điểm**: High volume, cần aggregation

### 2.5 Security & Audit Logs
- **Mục đích**: Ghi lại hoạt động bảo mật và thay đổi cấu hình
- **Ví dụ**: IAM logs, database access logs, configuration changes
- **Đặc điểm**: Sensitive, cần retention lâu dài

### 2.6 Event Logs
- **Mục đích**: Ghi lại sự kiện nghiệp vụ hoặc hệ thống ở mức high-level
- **Ví dụ**: User registration, payment events, system milestones
- **Đặc điểm**: Business-critical, cần correlation

### 2.7 Trace Logs
- **Mục đích**: Theo dõi toàn bộ đường đi của request qua nhiều service
- **Ví dụ**: Distributed tracing, request flow
- **Đặc điểm**: Cross-service, cần correlation ID

## 3. Nguyên tắc Thiết kế Hệ thống Logging

### 3.1 Structured Logging
- **Nguyên tắc**: Chuyển đổi log từ dạng thô sang JSON
- **Lợi ích**: Dễ parse, query và analyze
- **Ví dụ**:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "level": "ERROR",
  "service": "user-service",
  "trace_id": "abc123",
  "message": "Database connection failed",
  "error_code": "DB_CONN_001"
}
```

### 3.2 Context/Correlation ID
- **Nguyên tắc**: Mỗi log phải có context cụ thể
- **Implementation**: 
  - Trace ID cho distributed systems
  - Request ID cho single service
  - User ID cho business context
- **Lợi ích**: Dễ trace và debug

### 3.3 Log Levels Hợp lý
```
DEBUG   → Development debugging
INFO    → Normal operations
WARN    → Potential issues
ERROR   → Error conditions
CRITICAL/FATAL → System failures
```

### 3.4 Bảo mật Log
- **Không log**:
  - Passwords
  - Tokens/Secrets
  - PII (Personal Identifiable Information)
  - Credit card numbers
  - API keys
- **Best practices**: Mask sensitive data, use environment variables

### 3.5 Retention Policy
- **Development/Test**: 7 ngày
- **Production**: 60-90 ngày
- **Security/Audit**: 1-7 năm (tuỳ compliance)
- **Storage tiers**:
  - Hot storage: Recent logs (fast access)
  - Cold storage: Archived logs (cost-effective)

## 4. Kiến trúc Hệ thống Logging Tập trung

### 4.1 Log Producer
- **Định nghĩa**: Nơi log được sinh ra
- **Ví dụ**: Applications, containers, OS, cloud services
- **Responsibility**: Generate structured, contextual logs

### 4.2 Log Collector/Agent
- **Định nghĩa**: Thu thập log tại source và gửi về hệ thống tập trung
- **Ví dụ**: Filebeat, Fluentd, Vector, Logstash
- **Responsibility**: Collect, buffer, và forward logs

### 4.3 Log Transport/Forwarder
- **Định nghĩa**: Truyền tải log từ collector đến storage
- **Ví dụ**: Kafka, Redis, RabbitMQ
- **Responsibility**: Reliable delivery, load balancing

### 4.4 Log Processor
- **Định nghĩa**: Chuyển đổi và enrich log data
- **Ví dụ**: Logstash, Vector processors
- **Responsibility**: Parse, transform, enrich metadata

### 4.5 Log Storage/Index
- **Định nghĩa**: Lưu trữ log lâu dài với khả năng truy vấn
- **Ví dụ**: Elasticsearch, Loki, ClickHouse
- **Responsibility**: Store, index, và enable fast queries

### 4.6 Log Query & Visualization
- **Định nghĩa**: Interface để tìm kiếm và phân tích log
- **Ví dụ**: Kibana, Grafana, Jaeger UI
- **Responsibility**: Search, visualize, và analyze logs

### 4.7 Alert & Integration
- **Định nghĩa**: Chủ động thông báo khi có bất thường
- **Ví dụ**: AlertManager, PagerDuty, Slack
- **Responsibility**: Monitor patterns và trigger alerts

## 5. Lựa chọn Công nghệ

### 5.1 Recommended Stacks

#### 5.1.1 Loki + Grafana Stack
- **Ưu điểm**: Lightweight, cost-effective, Grafana integration
- **Phù hợp**: Small-medium teams, cost-conscious
- **Components**: Loki, Promtail, Grafana

#### 5.1.2 ELK Stack + Buffer
- **Ưu điểm**: Mature, feature-rich, powerful search
- **Phù hợp**: Large-scale, complex requirements
- **Components**: Elasticsearch, Logstash, Kibana, Redis/Kafka

#### 5.1.3 EFK Stack
- **Ưu điểm**: Simplified ELK với Fluentd
- **Phù hợp**: Kubernetes environments
- **Components**: Elasticsearch, Fluentd, Kibana

#### 5.1.4 VEK Stack
- **Ưu điểm**: Modern, high-performance
- **Phù hợp**: High-throughput environments
- **Components**: Vector, Elasticsearch, Kibana
