# Machine Learning Foundations for DevOps Engineers

## 📋 Overview
Tài liệu này tổng hợp kiến thức cơ bản về Machine Learning từ video [ML Foundations](https://www.youtube.com/watch?v=BUTjcAjfMgY) và bổ sung các tools/kiến thức DevOps cần biết để tham gia vào dự án ML/AI.

## 🧠 Trí tuệ và Mô hình Thế giới

### 1.1 Khái niệm cơ bản
- **Trí tuệ** đòi hỏi sự hiểu biết về cách thế giới vận hành
- **Mô hình thế giới** giúp nén thực tế phức tạp thành dạng có thể hình dung được
- **Mô hình** cho phép đưa ra dự đoán (ví dụ: mây đen → trời sắp mưa)

### 1.2 DevOps Perspective
```yaml
# Example: Monitoring model performance
apiVersion: v1
kind: ConfigMap
metadata:
  name: model-monitoring-config
data:
  config.yaml: |
    model_metrics:
      - accuracy
      - precision
      - recall
      - f1_score
    infrastructure_metrics:
      - cpu_usage
      - memory_usage
      - gpu_utilization
      - response_time
```

## 🤖 Machine Learning (ML): Thuật ngữ chung

### 2.1 Định nghĩa
- **ML** = "Giúp máy tính thực hiện các tác vụ mà không cần hướng dẫn rõ ràng"
- Khác với phát triển phần mềm truyền thống dựa trên hướng dẫn từng bước

### 2.2 Các giai đoạn chính

#### 2.2.1 Huấn luyện (Training)
```python
# Example: Training pipeline
from sklearn.linear_model import LinearRegression
import pandas as pd

# 1. Thu thập dữ liệu
training_data = pd.read_csv('training_data.csv')

# 2. Đưa dữ liệu cho thuật toán học
model = LinearRegression()
model.fit(training_data[['feature1', 'feature2']], training_data['target'])

# 3. Kết quả là mô hình học máy
# model now contains learned parameters
```

#### 2.2.2 Suy luận (Inference)
```python
# Example: Inference service
from fastapi import FastAPI
import joblib

app = FastAPI()
model = joblib.load('trained_model.pkl')

@app.post("/predict")
async def predict(data: dict):
    prediction = model.predict([data['features']])
    return {"prediction": prediction[0]}
```

### 2.3 DevOps Tools cho Training Pipeline

#### 2.3.1 MLflow - Model Lifecycle Management
```yaml
# Example: MLflow tracking
apiVersion: apps/v1
kind: Deployment
metadata:
  name: mlflow-server
spec:
  replicas: 1
  selector:
    matchLabels:
      app: mlflow
  template:
    spec:
      containers:
      - name: mlflow
        image: mlflow:latest
        ports:
        - containerPort: 5000
        env:
        - name: MLFLOW_TRACKING_URI
          value: "sqlite:///mlflow.db"
```

#### 2.3.2 Kubeflow - ML Workflow Orchestration
```yaml
# Example: Kubeflow pipeline
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
  name: ml-training-pipeline
spec:
  templates:
  - name: data-preprocessing
    container:
      image: python:3.8
      command: ["python", "preprocess.py"]
  - name: model-training
    container:
      image: tensorflow:latest
      command: ["python", "train.py"]
  - name: model-evaluation
    container:
      image: python:3.8
      command: ["python", "evaluate.py"]
```

### 2.4 Huấn luyện Mô hình: Khái niệm cốt lõi

#### 2.4.1 Mục tiêu
- Tìm các giá trị tham số tương ứng với hàm mất mát nhỏ nhất
- Giảm thiểu sự khác biệt giữa dự đoán và dữ liệu thực tế

#### 2.4.2 Hàm mất mát (Loss Function)
```python
# Example: Loss function monitoring
import prometheus_client
from prometheus_client import Counter, Histogram

# Metrics for monitoring
prediction_errors = Counter('model_prediction_errors_total', 'Total prediction errors')
prediction_latency = Histogram('model_prediction_duration_seconds', 'Prediction latency')

def predict_with_monitoring(features):
    start_time = time.time()
    try:
        prediction = model.predict(features)
        prediction_latency.observe(time.time() - start_time)
        return prediction
    except Exception as e:
        prediction_errors.inc()
        raise e
```

### 2.5 Các kỹ thuật ML truyền thống

#### 2.5.1 Hồi quy Logistic
```python
# Example: Logistic regression deployment
from sklearn.linear_model import LogisticRegression
import joblib

# Train model
model = LogisticRegression()
model.fit(X_train, y_train)

# Save model
joblib.dump(model, 'logistic_model.pkl')
```

#### 2.5.2 Cây quyết định
```python
# Example: Decision tree with model versioning
from sklearn.tree import DecisionTreeClassifier
import mlflow

with mlflow.start_run():
    model = DecisionTreeClassifier(max_depth=5)
    model.fit(X_train, y_train)
    
    # Log model
    mlflow.sklearn.log_model(model, "decision_tree")
    
    # Log parameters
    mlflow.log_param("max_depth", 5)
    mlflow.log_metric("accuracy", model.score(X_test, y_test))
```

### 2.6 Hạn chế: Kỹ thuật đặc trưng (Feature Engineering)
- Đòi hỏi lượng lớn thời gian và kiến thức chuyên môn
- DevOps cần hiểu về data pipeline và feature store

```yaml
# Example: Feature store with Feast
apiVersion: apps/v1
kind: Deployment
metadata:
  name: feast-feature-store
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: feast-server
        image: feast:latest
        ports:
        - containerPort: 6566
        env:
        - name: FEAST_CORE_URL
          value: "feast-core:6565"
```

## 🧠 Deep Learning (DL): Học tự động các đặc trưng

### 3.1 Định nghĩa
- **DL** = "Loại học máy cụ thể liên quan đến việc huấn luyện mạng thần kinh"
- Có thể tự học các đặc trưng tối ưu cho một nhiệm vụ cụ thể

### 3.2 Mạng thần kinh (Neural Networks)

#### 3.2.1 Nguyên lý hoạt động
```python
# Example: Simple neural network
import tensorflow as tf

model = tf.keras.Sequential([
    tf.keras.layers.Dense(128, activation='relu', input_shape=(784,)),
    tf.keras.layers.Dropout(0.2),
    tf.keras.layers.Dense(64, activation='relu'),
    tf.keras.layers.Dense(10, activation='softmax')
])

model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])
```

#### 3.2.2 DevOps cho Neural Networks
```yaml
# Example: GPU-enabled training deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: neural-network-training
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: training
        image: tensorflow:latest
        resources:
          requests:
            nvidia.com/gpu: 1
            memory: "8Gi"
            cpu: "4"
          limits:
            nvidia.com/gpu: 1
            memory: "16Gi"
            cpu: "8"
        volumeMounts:
        - name: training-data
          mountPath: /data
        - name: model-storage
          mountPath: /models
```

### 3.3 Các loại nơ-ron và hàm kích hoạt

#### 3.3.1 Hàm kích hoạt phổ biến
- **ReLU**: `f(x) = max(0, x)`
- **Sigmoid**: `f(x) = 1/(1 + e^(-x))`
- **Tanh**: `f(x) = (e^x - e^(-x))/(e^x + e^(-x))`
- **Softmax**: Chuyển đổi đầu vào thành phân phối xác suất

#### 3.3.2 Monitoring Activation Functions
```python
# Example: Monitoring activation function performance
import tensorflow as tf
from tensorflow.keras.callbacks import Callback

class ActivationMonitor(Callback):
    def on_epoch_end(self, epoch, logs=None):
        # Monitor activation patterns
        layer_outputs = self.model.predict(self.validation_data[0])
        tf.summary.scalar('activation_stats', tf.reduce_mean(layer_outputs))
```

### 3.4 Kiến trúc mạng

#### 3.4.1 Mạng thần kinh truyền thẳng (Feed-forward)
```python
# Example: Feed-forward network deployment
apiVersion: v1
kind: Service
metadata:
  name: feed-forward-model
spec:
  selector:
    app: feed-forward-model
  ports:
  - port: 8080
    targetPort: 8080
  type: LoadBalancer
```

#### 3.4.2 Mạng thần kinh tích chập (CNN)
```python
# Example: CNN for image processing
model = tf.keras.Sequential([
    tf.keras.layers.Conv2D(32, 3, activation='relu', input_shape=(28, 28, 1)),
    tf.keras.layers.MaxPooling2D(),
    tf.keras.layers.Conv2D(64, 3, activation='relu'),
    tf.keras.layers.Flatten(),
    tf.keras.layers.Dense(128, activation='relu'),
    tf.keras.layers.Dense(10, activation='softmax')
])
```

#### 3.4.3 Transformer
- Cách mạng hóa xử lý ngôn ngữ tự nhiên
- Kiến trúc đằng sau các mô hình ngôn ngữ lớn

### 3.5 Huấn luyện: Gradient Descent

#### 3.5.1 Nguyên lý
- Hàm mất mát phức tạp hơn mô hình tuyến tính
- Có "địa hình lởm chởm" của các đỉnh và thung lũng
- Gradient cho biết hướng dốc nhất

#### 3.5.2 Các biến thể
```python
# Example: Different optimizers
optimizers = {
    'sgd': tf.keras.optimizers.SGD(learning_rate=0.01),
    'adam': tf.keras.optimizers.Adam(learning_rate=0.001),
    'rmsprop': tf.keras.optimizers.RMSprop(learning_rate=0.001)
}
```

#### 3.5.3 DevOps cho Gradient Descent
```yaml
# Example: Distributed training with Horovod
apiVersion: apps/v1
kind: Job
metadata:
  name: distributed-training
spec:
  parallelism: 4
  template:
    spec:
      containers:
      - name: training
        image: horovod/horovod:latest
        command: ["horovodrun", "-np", "4", "python", "train.py"]
        env:
        - name: HOROVOD_RING
          value: "nccl"
```

### 3.6 Siêu tham số (Hyperparameters)

#### 3.6.1 Định nghĩa
- Các giá trị hướng dẫn quá trình huấn luyện
- Không phải tham số mô hình được học từ dữ liệu
- Được đặt thủ công hoặc điều chỉnh thông qua tối ưu hóa

#### 3.6.2 Các siêu tham số phổ biến
```python
# Example: Hyperparameter configuration
hyperparameters = {
    'epochs': 100,
    'learning_rate': 0.001,
    'batch_size': 32,
    'dropout_rate': 0.2,
    'hidden_layers': [128, 64, 32]
}
```

#### 3.6.3 DevOps cho Hyperparameter Tuning
```yaml
# Example: Hyperparameter tuning with Katib
apiVersion: kubeflow.org/v1beta1
kind: Experiment
metadata:
  name: hyperparameter-tuning
spec:
  objective:
    type: maximize
    goal: 0.99
    objectiveMetricName: accuracy
  algorithm:
    algorithmName: random
  parallelTrialCount: 3
  maxTrialCount: 12
  maxFailedTrialCount: 3
  parameters:
  - name: learning_rate
    parameterType: double
    feasibleSpace:
      min: "0.01"
      max: "0.1"
  - name: batch_size
    parameterType: int
    feasibleSpace:
      min: "16"
      max: "128"
```

## 🎯 Reinforcement Learning (RL): Học qua thử và sai

### 4.1 Định nghĩa
- Máy tính có thể học thông qua thử và sai
- Tương tác trực tiếp với môi trường
- Không bị ràng buộc bởi nhãn của con người

### 4.2 Cách hoạt động

#### 4.2.1 Vòng lặp phản hồi
```python
# Example: RL environment setup
import gym
import numpy as np

env = gym.make('CartPole-v1')
state = env.reset()

for step in range(1000):
    action = model.predict(state)  # Model decides action
    next_state, reward, done, info = env.step(action)
    
    # Update model based on reward
    model.update(state, action, reward, next_state)
    
    if done:
        break
    state = next_state
```

#### 4.2.2 DevOps cho RL
```yaml
# Example: RL training environment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rl-training-environment
spec:
  replicas: 1
  template:
    spec:
      containers:
      - name: rl-agent
        image: rl-training:latest
        env:
        - name: ENVIRONMENT_NAME
          value: "CartPole-v1"
        - name: MODEL_PATH
          value: "/models/rl_model"
        volumeMounts:
        - name: model-storage
          mountPath: /models
```

### 4.3 Mục tiêu: Tối đa hóa hàm phần thưởng

#### 4.3.1 Hàm phần thưởng
```python
# Example: Reward function monitoring
class RewardMonitor:
    def __init__(self):
        self.total_reward = 0
        self.episode_count = 0
    
    def log_reward(self, reward):
        self.total_reward += reward
        tf.summary.scalar('episode_reward', reward)
    
    def log_episode(self):
        self.episode_count += 1
        avg_reward = self.total_reward / self.episode_count
        tf.summary.scalar('average_reward', avg_reward)
```

### 4.4 Các thuật toán RL hiện đại

#### 4.4.1 PPO (Proximal Policy Optimization)
- Được sử dụng trong RLHF (Reinforcement Learning from Human Feedback)
- OpenAI sử dụng để tạo ChatGPT

#### 4.4.2 GRPO (Group Relative Policy Optimization)
- DeepSeek sử dụng trong DeepSeek R1
- Kết hợp PPO với hình phạt KL divergence

## 📊 Dữ liệu: Thành phần quan trọng nhất

### 5.1 Nguyên tắc "Garbage in, garbage out"
- Nếu có dữ liệu xấu → mô hình xấu
- Bất kể thuật toán tinh vi đến mức nào

### 5.2 Hai thuộc tính của dữ liệu tốt

#### 5.2.1 Số lượng
- Nhiều dữ liệu tốt hơn ít dữ liệu
- Thiếu dữ liệu → overfitting

#### 5.2.2 Chất lượng
- **Độ chính xác**: Sự đúng đắn của dữ liệu
- **Tính đa dạng**: Tính đại diện của dữ liệu

### 5.3 DevOps cho Data Pipeline

#### 5.3.1 Data Versioning với DVC
```yaml
# Example: DVC configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: dvc-config
data:
  .dvc/config: |
    [core]
      remote = myremote
    ['remote "myremote"']
      url = s3://my-bucket/dvc
      storagepath = /data
```

#### 5.3.2 Data Pipeline với Apache Airflow
```python
# Example: Airflow DAG for data processing
from airflow import DAG
from airflow.operators.python_operator import PythonOperator
from datetime import datetime

dag = DAG('data_pipeline', start_date=datetime(2024, 1, 1))

def extract_data():
    # Extract data from sources
    pass

def transform_data():
    # Transform and clean data
    pass

def load_data():
    # Load data to storage
    pass

extract_task = PythonOperator(task_id='extract', python_callable=extract_data, dag=dag)
transform_task = PythonOperator(task_id='transform', python_callable=transform_data, dag=dag)
load_task = PythonOperator(task_id='load', python_callable=load_data, dag=dag)

extract_task >> transform_task >> load_task
```

#### 5.3.3 Data Quality Monitoring
```python
# Example: Data quality checks
import great_expectations as ge

def validate_data_quality():
    context = ge.get_context()
    
    # Validate data schema
    validator = context.get_validator(
        batch_request=batch_request,
        expectation_suite=expectation_suite_name
    )
    
    # Check for missing values
    validator.expect_column_values_to_not_be_null("target")
    
    # Check data types
    validator.expect_column_values_to_be_of_type("age", "int")
    
    # Check value ranges
    validator.expect_column_values_to_be_between("age", 0, 120)
    
    return validator.validate()
```

## 🛠️ DevOps Tools & Best Practices cho ML/AI

### 6.1 Model Serving

#### 6.1.1 TensorFlow Serving
```yaml
# Example: TensorFlow Serving deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tensorflow-serving
spec:
  replicas: 3
  template:
    spec:
      containers:
      - name: serving
        image: tensorflow/serving:latest
        ports:
        - containerPort: 8500
        - containerPort: 8501
        env:
        - name: MODEL_NAME
          value: "my_model"
        - name: MODEL_BASE_PATH
          value: "/models"
        volumeMounts:
        - name: model-storage
          mountPath: /models
```

#### 6.1.2 Seldon Core
```yaml
# Example: Seldon deployment
apiVersion: machinelearning.seldon.io/v1
kind: SeldonDeployment
metadata:
  name: ml-model
spec:
  name: ml-model
  predictors:
  - name: default
    replicas: 3
    graph:
      name: classifier
      type: MODEL
      modelUri: s3://my-bucket/model
      serviceAccountName: seldon-init-container
```

### 6.2 Model Monitoring

#### 6.2.1 Prometheus Metrics
```python
# Example: Custom metrics for ML models
from prometheus_client import Counter, Histogram, Gauge

# Model performance metrics
prediction_counter = Counter('model_predictions_total', 'Total predictions made')
prediction_latency = Histogram('model_prediction_duration_seconds', 'Prediction latency')
model_accuracy = Gauge('model_accuracy', 'Model accuracy')

def predict_with_metrics(features):
    start_time = time.time()
    
    try:
        prediction = model.predict(features)
        prediction_counter.inc()
        prediction_latency.observe(time.time() - start_time)
        return prediction
    except Exception as e:
        # Log error metrics
        raise e
```

#### 6.2.2 Model Drift Detection
```python
# Example: Drift detection
import numpy as np
from scipy import stats

def detect_drift(reference_data, current_data):
    # Statistical drift detection
    reference_mean = np.mean(reference_data)
    current_mean = np.mean(current_data)
    
    # T-test for drift
    t_stat, p_value = stats.ttest_ind(reference_data, current_data)
    
    if p_value < 0.05:
        return True, f"Drift detected: p-value={p_value}"
    
    return False, "No significant drift detected"
```

### 6.3 A/B Testing cho Models

#### 6.3.1 Traffic Splitting
```yaml
# Example: A/B testing configuration
apiVersion: v1
kind: ConfigMap
metadata:
  name: ab-testing-config
data:
  config.yaml: |
    experiments:
      - name: model-comparison
        traffic_split:
          model_a: 50
          model_b: 50
        metrics:
          - accuracy
          - latency
          - user_satisfaction
```

#### 6.3.2 Canary Deployment
```yaml
# Example: Canary deployment for ML models
apiVersion: apps/v1
kind: Deployment
metadata:
  name: model-canary
spec:
  replicas: 1  # Small percentage
  template:
    spec:
      containers:
      - name: model-server
        image: model:canary
        env:
        - name: MODEL_VERSION
          value: "v2.0.0-canary"
```

### 6.4 Security cho ML Models

#### 6.4.1 Model Encryption
```python
# Example: Model encryption
import cryptography
from cryptography.fernet import Fernet

def encrypt_model(model_path, key):
    with open(model_path, 'rb') as f:
        model_data = f.read()
    
    f = Fernet(key)
    encrypted_data = f.encrypt(model_data)
    
    with open(f"{model_path}.encrypted", 'wb') as f:
        f.write(encrypted_data)
```

#### 6.4.2 Input Validation
```python
# Example: Input validation for ML models
from pydantic import BaseModel, validator
import numpy as np

class ModelInput(BaseModel):
    features: list
    
    @validator('features')
    def validate_features(cls, v):
        if len(v) != 784:  # Expected feature count
            raise ValueError('Feature count must be 784')
        
        if not all(isinstance(x, (int, float)) for x in v):
            raise ValueError('All features must be numeric')
        
        return v
```

### 6.5 CI/CD cho ML

#### 6.5.1 GitHub Actions Workflow
```yaml
# Example: ML CI/CD pipeline
name: ML Model CI/CD
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v2
    
    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.8
    
    - name: Install dependencies
      run: |
        pip install -r requirements.txt
    
    - name: Run tests
      run: |
        python -m pytest tests/
    
    - name: Validate model performance
      run: |
        python scripts/validate_model.py
    
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
    - name: Deploy to staging
      run: |
        kubectl apply -f k8s/staging/
    
    - name: Run smoke tests
      run: |
        python scripts/smoke_test.py
    
    - name: Deploy to production
      run: |
        kubectl apply -f k8s/production/
```

## 📚 Tổng kết

### 6.1 Các ý chính
1. **Giải quyết vấn đề** đòi hỏi mô hình thế giới chính xác
2. **ML** cung cấp cách điều chỉnh mô hình cho thực tế
3. **DL** sử dụng mạng thần kinh để học đặc trưng
4. **RL** cho phép học qua tương tác với môi trường
5. **Dữ liệu** là thành phần quan trọng nhất

### 6.2 DevOps Checklist cho ML/AI Projects
- [ ] **Model Versioning**: MLflow, DVC
- [ ] **Model Serving**: TensorFlow Serving, Seldon Core
- [ ] **Monitoring**: Prometheus, Grafana
- [ ] **A/B Testing**: Traffic splitting, canary deployment
- [ ] **Security**: Model encryption, input validation
- [ ] **CI/CD**: Automated testing, deployment
- [ ] **Data Pipeline**: Airflow, DVC
- [ ] **Infrastructure**: Kubernetes, GPU support
- [ ] **Observability**: Logging, metrics, tracing

### 6.3 Key Takeaway
> "Mặc dù có rất nhiều toán học và các thuật toán phức tạp trong học máy, việc huấn luyện các mô hình tốt phụ thuộc vào việc có dữ liệu tốt."

---

*Source: [ML Foundations Video](https://www.youtube.com/watch?v=BUTjcAjfMgY)*
*Last updated: January 2024*
*For DevOps engineers working with ML/AI systems*
