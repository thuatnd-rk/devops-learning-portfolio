I. Kubernetes Cluster
1 cluster production thường có 3 node, và tốt nhất là số lượng node lẻ 3, 5, 7
Lý do:
- đảm bảo tính HA, khi 1 node gặp sự cố, 2 node còn tại vẫn đủ để tạo thành quorum (đa số) và cluster vẫn hoạt động bình thường
- cơ chế Quorum, Quorum = (N/2)+1, Quorum đưa ra định nghĩa về số node được phép hỏng trong cluster, tức là, số node còn lại phải chiếm đa số (>= quorum) ví dụ 3 node, Quorum = 2 -> chỉ 1 node được phép hỏng
- tránh split brain

2. Pod

3. Node

4. Service
- Là lớp trừu tượng để các service giao tiếp lẫn nhau

5. Configmap



II. Identity and Access Management

III. Deploying Applications in Kubernetes

IV. Running Applications in Kubernetes