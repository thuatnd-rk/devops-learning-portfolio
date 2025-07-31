# Các lệnh Docker hữu ích mà có thể ít người xài tới

> **Nguồn:** [DevOps Vietnam - Các lệnh Docker hữu ích mà có thể ít người xài tới](https://devops.vn/posts/cac-lenh-docker-huu-ich-ma-co-the-it-nguoi-xai-toi/)  
> **Tác giả:** Phat Lưu  
> **Ngày đăng:** 30/07/2025

Khi mới dùng Docker, ai cũng quen thuộc với mấy lệnh như `docker run` hay `docker build`. Nhưng có thể bạn chưa biết còn cả một kho tàng các lệnh khác ít người dùng tới nhưng lại cực kỳ hữu ích trong một vài trường hợp oái oăm.

## 1. `docker system df`: Phân tích chi tiết dung lượng đĩa

Lệnh này cho bạn một cái nhìn tổng quan về dung lượng đĩa mà các đối tượng của Docker đang chiếm dụng, từ image, container, volume cho đến build cache. Rất quan trọng để quản lý tài nguyên hệ thống.

```bash
docker system df
```

## 2. `docker inspect`: Soi sâu vào metadata của đối tượng

Khi bạn cần soi sâu vào bên trong một đối tượng Docker, `docker inspect` là công cụ không thể thiếu. Nó trả về một file JSON chứa toàn bộ thông tin chi tiết từ cấu hình mạng, biến môi trường, cho đến trạng thái lúc chạy.

```bash
docker inspect [OPTIONS] NAME|ID [NAME|ID...]
```

## 3. `docker history`: Truy vết lịch sử các lớp của image

Lệnh này giúp chúng ta truy vết lại lịch sử các layer của một image. Thường dùng khi cần tối ưu Dockerfile. Nhìn vào kết quả, bạn có thể dễ dàng phát hiện ra những lớp nào đang làm phình to image một cách không cần thiết.

```bash
docker history --no-trunc --human nginx:alpine
```

## 4. `docker export`: Xuất hệ thống file của container

Lệnh này sẽ xuất toàn bộ hệ thống file của một container ra thành một file nén dạng tar, nhưng không bao gồm metadata hay lịch sử của image. Hữu ích trong các môi trường air-gapped.

```bash
docker export -o my-container.tar my-container
cat my-container.tar | docker import - my-new-image:latest
```

## 5. `docker events`: Giám sát các hoạt động của Docker

Lệnh này cho phép bạn theo dõi các sự kiện diễn ra từ Docker daemon theo thời gian thực, ví dụ như khi một container được khởi động, dừng lại, hay một image được tải về. Có thể tích hợp vào các hệ thống giám sát để theo dõi và cảnh báo.

```bash
docker events --filter 'type=container' --filter 'event=start' --since '2025-05-04' --format '{{.Time}} {{.Type}} {{.Actor.Attributes.name}} {{.Action}}' | \
awk 'BEGIN { printf "%-25s %-10s %-30s %-10s\n", "TIME", "TYPE", "CONTAINER", "ACTION"; print "--------------------------------------------------------------------------------------------"; }
     { printf "%-25s %-10s %-30s %-10s\n", $1, $2, $3, $4 }'
```

## 6. `docker top`: Xem các tiến trình đang chạy trong container

Giống như lệnh `top` trên Linux, lệnh này cho phép bạn xem nhanh các tiến trình đang chạy bên trong một container mà không cần phải `exec` vào trong. Đây là một cách nhanh và an toàn để kiểm tra xem tiến trình nào đang chiếm dụng nhiều tài nguyên.

```bash
docker top my-container aux
```

## 7. `docker diff`: Kiểm tra các thay đổi trên hệ thống file

Lệnh này sẽ liệt kê những thay đổi như thêm, sửa, xóa trên hệ thống file của một container kể từ khi nó được khởi tạo. Đặc biệt hữu ích trong các cuộc kiểm tra tuân thủ hoặc đánh giá bảo mật để phát hiện những thay đổi trái phép.

```bash
docker diff my-container
```

## 8. `docker trust`: Quản lý việc ký và xác thực image

Đây là một tính năng bảo mật nâng cao, cho phép bạn quản lý content trust để đảm bảo các image được sử dụng đều đã được ký và xác thực về nguồn gốc. Trong các môi trường yêu cầu bảo mật cao, việc này giúp ngăn chặn nguy cơ sử dụng các image độc hại.

```bash
docker trust signer add --key my-key.pub my-registry.com/my-image
```

## 9. `docker save` và `docker load`: Lưu và tải image

Hai lệnh này cho phép bạn lưu image ra file và tải image từ file. Điều này rất hữu ích khi bạn cần chuyển image giữa các máy không có kết nối internet hoặc muốn backup image.

```bash
docker save -o my-image.tar nginx:latest
docker load -i my-image.tar
```

## 10. `docker stats`: Theo dõi tài nguyên của container

Đây là một công cụ tích hợp sẵn để theo dõi việc sử dụng tài nguyên của CPU, bộ nhớ, mạng, I/O của các container đang chạy theo thời gian thực. Dù trong môi trường production người ta thường dùng các hệ thống giám sát chuyên nghiệp, lệnh này vẫn rất tiện lợi để gỡ lỗi nhanh trên máy local.

```bash
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" my-container
```

## 11. `docker volume inspect`: Kiểm tra chi tiết của volume

Khi gặp các sự cố liên quan đến volume, lệnh này giúp kiểm tra các metadata của một Docker volume, chẳng hạn như điểm mount và driver đang sử dụng. Rất cần thiết để gỡ lỗi các vấn đề về quyền truy cập hoặc sai đường dẫn.

```bash
docker volume inspect my-volume
```

## 12. `docker buildx`: Xây dựng image nâng cao

`docker buildx` là một phần mở rộng của `docker build` với nhiều tính năng mạnh mẽ như xây dựng image đa kiến trúc, tối ưu cache, và sử dụng builder từ xa. Sử dụng để tạo ra một image duy nhất có thể chạy được trên cả máy chủ cloud (x86) và thiết bị biên (ARM).

```bash
docker buildx build --platform linux/amd64,linux/arm64 -t my-app:latest --push .
```

## Tóm tắt

Đó là các lệnh Docker hữu ích mà có thể ít người biết đến. Dĩ nhiên là không phải ngày nào bạn cũng dùng đến chúng, nhưng việc biết đến sự tồn tại của những công cụ này sẽ giúp bạn có thêm nhiều lựa chọn khi xử lý các vấn đề khó. Nó giúp hiểu sâu hơn về cách Docker hoạt động và tự tin hơn khi gặp sự cố.

## Các trường hợp sử dụng phổ biến

| Lệnh | Trường hợp sử dụng |
|------|-------------------|
| `docker system df` | Quản lý tài nguyên, dọn dẹp hệ thống |
| `docker inspect` | Debug container, kiểm tra cấu hình |
| `docker history` | Tối ưu Dockerfile, phân tích image |
| `docker export` | Backup container, chuyển môi trường |
| `docker events` | Monitoring, logging, automation |
| `docker top` | Debug performance, kiểm tra process |
| `docker diff` | Security audit, compliance check |
| `docker trust` | Security, image verification |
| `docker save/load` | Backup, offline deployment |
| `docker stats` | Performance monitoring |
| `docker volume inspect` | Debug storage issues |
| `docker buildx` | Multi-architecture builds |

## Lưu ý

- Các lệnh này phù hợp cho việc debug và quản lý Docker trong môi trường development
- Trong production, nên sử dụng các công cụ monitoring chuyên nghiệp
- Luôn test các lệnh trên môi trường development trước khi áp dụng vào production 