1. Tìm hiểu các logging stack
Grafana - Loki
Logs -> promtail -> grafana loki -> grafana

EFK stack
Collector & shipper(fluentd, fluentbit) -> elasticsearch -> kibana
EFK stack (buffer)
Collector & shipper(fluentd, fluentbit) -> buffer (redis, kafka) -> elasticsearch -> kibana

ELK stack
Collector (beats) -> logstash -> elasticsearch -> kibana 

VEK
source -> transforms -> sinks

2. So sánh & phân tích logging stack
Hiểu rõ bài toán đang gặp phải, điểm mạnh yếu của từng công cụ để áp dụng cho phù hợp

# Tiêu chí lựa chọn công nghệ (giữa elasticsearch và loki, vẽ bảng so sánh với các tiêu chí tôi đặt ra bên dưới):
Đặc tính dữ liệu log là gì?
Mô hình truy vấn?
Tốc độ ghi & lưu trữ?
hệ sinh thái tích hợp?
Vận hành & chi phí?

# Bản chất kiến trúc & công cụ (giữa elasticsearch và loki,vẽ bảng so sánh với các tiêu chí tôi đặt ra bên dưới)
Bản chất/kiến trúc
Điểm mạnh là gì?
Hạn chế là gì?
Khi nào dùng?

# Agent/processor (giữa vector, fluentbit, fluentd, logstash, vẽ bảng so sánh với các tiêu chí tôi đặt ra ở dưới)
Footprint
Transform
Vai trò ưa dùng
Output/route
Khi nào chọn


3. Triển khai hệ thống log tập trung ở hạ tầng nào?
Có 3 hạ tầng chính
Trên server
Trong container
Trên cụm K8S

Không recommend triển khai trên container, tuy nhanh chóng, nhưng: mất nhiều thời gian để điều tra nguyên nhân gây lỗi, phải vào trong container để điều tra (yêu cầu là container đó còn sống), môi trường container không có đầy đủ các câu lệnh


4. Thiết lập ban đầu