1. Tìm hiểu các logging stack

### Grafana - Loki
- Logs -> Promtail (hoặc Fluent Bit) -> Grafana Loki -> Grafana/Tempo (truy vết) -> Alerting
- Tư tưởng: lưu trữ log theo nhãn (labels), tách metadata (labels) ra khỏi nội dung log (log line). Tối ưu chi phí lưu trữ, tốc độ truy vấn theo nhãn.

### EFK stack
- Collector & shipper (Fluent Bit/Fluentd) -> Elasticsearch -> Kibana
- EFK stack (có buffer)
  - Collector & shipper (Fluent Bit/Fluentd) -> Buffer (Redis/Kafka) -> Elasticsearch -> Kibana
- Tư tưởng: lưu trữ tài liệu dạng JSON có thể lập chỉ mục (index), truy vấn full-text mạnh, aggregations phong phú.

### ELK stack
- Collector (Beats) -> Logstash -> Elasticsearch -> Kibana
- Phù hợp khi cần pipeline transform phức tạp (Logstash) và hệ Beats đa dạng (Filebeat, Metricbeat, Winlogbeat...).

### Vector + Elasticsearch/Loki (VEK)
- Source -> Transforms -> Sinks
- Vector có thể thay Fluent Bit/Fluentd/Logstash trong nhiều trường hợp nhờ hiệu năng cao (Rust), cấu hình thống nhất, nhiều plugin.

2. So sánh & phân tích logging stack

Hiểu rõ bài toán, dữ liệu log, mô hình truy vấn, yêu cầu SLA, ngân sách, kỹ năng đội ngũ trước khi chọn.

### Tiêu chí lựa chọn công nghệ (Elasticsearch vs Loki)

| Tiêu chí | Elasticsearch | Loki |
|---|---|---|
| Đặc tính dữ liệu | Tài liệu JSON được index; mạnh với cấu trúc/field rõ | Log line + labels; chỉ index labels, không index nội dung |
| Mô hình truy vấn | Full-text, fuzzy, aggregations, DSL mạnh (KQL/Lucene) | Truy vấn theo labels rất nhanh; nội dung log dùng regex/line scan |
| Tốc độ ghi | Cao, nhưng index nhiều field có thể tốn CPU/IO | Rất cao, do chỉ index labels; ghi rẻ hơn |
| Dung lượng lưu trữ | Lớn hơn do index + replicas; cần tối ưu mapping/ILM | Thấp hơn đáng kể nhờ kiến trúc chunk/compaction |
| Chi phí vận hành | Cao (cluster ES, heap, tuning GC, shard/index mgmt) | Thấp-hợp lý; đơn giản hơn (boltdb-shipper, object storage) |
| Hệ sinh thái | Rất phong phú: Beats, Logstash, Curator, ILM, Kibana | Tích hợp tốt với Grafana, Promtail, Tempo, Alerting |
| Tính năng nâng cao | ML anomaly, transforms, enrich, vector search (mới) | LogQL, ruler, retention per-tenant, multi-tenant đơn giản |
| Khi nào dùng | Cần full-text, phân tích sâu, BI log, compliance nặng | Observability cost-effective, SRE/K8S logs, label-based queries |
| Rủi ro | Tuning phức tạp, chi phí phần cứng cao | Regex/line-scan chậm với nội dung nặng; cần thiết kế labels tốt |

Gợi ý nhanh:
- Nếu bài toán đòi hỏi tìm kiếm toàn văn, phân tích nâng cao, báo cáo pháp lý: chọn Elasticsearch.
- Nếu trọng tâm là SRE/ops, truy vấn theo service/pod/namespace/level, tối ưu chi phí: chọn Loki.

### Bản chất kiến trúc & công cụ

#### Elasticsearch
- Bản chất/kiến trúc: Cluster các node master/data/ingest; sharding, replication, index lifecycle management (ILM).
- Điểm mạnh:
  - Tìm kiếm full-text mạnh, aggregations, pipeline ingest phong phú.
  - Hệ sinh thái Beats/Logstash/Kibana trưởng thành.
- Hạn chế:
  - Tuning phức tạp (heap, shard count, index template).
  - Chi phí phần cứng và vận hành cao khi scale.
- Khi nào dùng:
  - Nhu cầu phân tích log sâu, tìm kiếm mờ, compliance, báo cáo.
  - Dữ liệu log có cấu trúc rõ, cần join với nguồn dữ liệu khác.

#### Loki
- Bản chất/kiến trúc: Chỉ index labels, log line lưu dạng chunk; sử dụng object storage + boltdb-shipper; microservices (distributor, ingester, querier, compactor).
- Điểm mạnh:
  - Chi phí rẻ, ingest nhanh, vận hành đơn giản, scale-out tốt.
  - Tích hợp chặt với Grafana/Tempo/Prometheus.
- Hạn chế:
  - Không tối ưu full-text, phụ thuộc regex/line scan khi lọc nội dung.
  - Thiết kế labels kém sẽ gây chi phí truy vấn cao và cardinality bùng nổ.
- Khi nào dùng:
  - K8S logs, microservices, SRE observability, multi-tenant cost-effective.

3. Agent/processor (Vector, Fluent Bit, Fluentd, Logstash)

| Tiêu chí | Vector | Fluent Bit | Fluentd | Logstash |
|---|---|---|---|---|
| Footprint | Rất nhẹ, Rust, hiệu năng cao | Rất nhẹ (C), cực nhanh | Nặng hơn (Ruby), linh hoạt | Nặng (JVM), tốn CPU/RAM |
| Transform | `remap` (VRL) mạnh, thống nhất | Filter cơ bản, Lua | Plugin phong phú, Ruby filter | Filter mạnh, Grok, pipeline |
| Vai trò ưa dùng | Agent thống nhất cho edge/forwarder | Agent sidecar/daemonset ở K8S | Aggregator/forwarder truyền thống | Ingest/transform trung tâm |
| Output/route | Nhiều sinks (ES, Loki, S3, Kafka...) | Nhiều outputs phổ biến | Rất nhiều plugin output | Phong phú, tốt với ES |
| Khi nào chọn | Muốn hiệu năng + cấu hình hiện đại | Cần cực nhẹ, ít tài nguyên | Cần plugin hệ sinh thái lớn | Cần pipeline phức tạp, ES-centric |

Gợi ý:
- K8S: ưu tiên Fluent Bit hoặc Vector làm DaemonSet.
- Trung tâm (trước ES): Logstash hoặc Vector (tối ưu chi phí).
- Cần transform phức tạp nhưng hiệu năng: Vector.
- Muốn bám chặt hệ sinh thái Elastic: Beats + Logstash.

4. Triển khai hệ thống log tập trung ở hạ tầng nào?

Có 3 hạ tầng chính:
- Trên server (VM/Bare metal)
- Trong container
- Trên cụm K8S

### Trên server
- Mô hình:
  - Agent (Fluent Bit/Vector) trên mỗi server đọc `journald`/file log -> đẩy về Kafka/Redis (tùy) -> ES hoặc Loki.
- Ưu điểm:
  - Dễ kiểm soát nguồn log hệ thống, không phụ thuộc nền tảng container.
  - Đơn giản cho monolith/legacy.
- Nhược điểm:
  - Quản trị vòng đời agent theo máy; thiếu metadata ứng dụng/container.

### Trong container
Không recommend triển khai collector ở trong từng container ứng dụng. Tuy nhanh chóng, nhưng:
- Mất thời gian điều tra nguyên nhân lỗi; phải chui vào container (yêu cầu container còn sống).
- Môi trường container không đầy đủ công cụ điều tra, khó chuẩn hóa cấu hình.
- Khó kiểm soát tài nguyên và bảo mật; rủi ro làm nhiễu ứng dụng.
Thay vào đó, dùng DaemonSet ở node hoặc sidecar tiêu chuẩn hóa khi thật sự cần.

### Trên cụm K8S
- Mô hình khuyến nghị:
  - DaemonSet (Fluent Bit/Vector/Promtail) đọc container runtime logs (`/var/log/containers`, `journald`) -> đẩy về backend (Loki/ES).
  - Tùy lưu lượng: thêm hàng đợi (Kafka/REDIS) làm buffer chống backpressure.
- Ưu điểm:
  - Tự động gắn metadata K8S (namespace, pod, container, labels).
  - Dễ scale và quản lý bằng Helm/Kustomize.
- Nhược điểm:
  - Cần phân bổ tài nguyên hợp lý để tránh ảnh hưởng workload.
  - Cần chính sách retention, multi-tenant, bảo mật network.