# Jaeger

## 1. Jaeger là gì?
Jaeger là một hệ thống mã nguồn mở dùng để theo dõi truy vết (distributed tracing) các request trong hệ thống phân tán, giúp phân tích hiệu năng và xác định bottleneck.

## 2. Đặc điểm nổi bật
- Thu thập, lưu trữ và trực quan hóa trace
- Hỗ trợ chuẩn OpenTracing, OpenTelemetry
- Tích hợp tốt với nhiều ngôn ngữ, framework
- Giao diện web trực quan

## 3. Cách hoạt động
Ứng dụng gửi trace (theo chuẩn OpenTracing/OpenTelemetry) tới Jaeger. Jaeger lưu trữ, xử lý và hiển thị trace trên giao diện web hoặc tích hợp với Grafana.

## 4. Trường hợp sử dụng phổ biến
- Theo dõi luồng request qua nhiều service (microservices)
- Phân tích hiệu năng, xác định điểm nghẽn
- Debug hệ thống phân tán

## 5. Vai trò trong monitoring stack
Jaeger cung cấp khả năng tracing, giúp bạn hiểu rõ luồng xử lý, phát hiện bottleneck và tối ưu hệ thống phân tán.

## 6. Tham khảo
- [Jaeger Official](https://www.jaegertracing.io/)
- [Tài liệu Jaeger](https://www.jaegertracing.io/docs/) 