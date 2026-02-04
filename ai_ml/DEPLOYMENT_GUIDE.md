# Model Deployment Guide

## Deployment Options

### Option 1: Cloud Deployment (Recommended for MVP)

#### AWS SageMaker
```python
# sagemaker_deploy.py
import boto3
import sagemaker
from sagemaker.pytorch import PyTorchModel

# Initialize
sagemaker_session = sagemaker.Session()
role = 'arn:aws:iam::YOUR_ACCOUNT:role/SageMakerRole'

# Upload model to S3
model_data = sagemaker_session.upload_data(
    path='models/best_model.pth',
    key_prefix='food-recognition'
)

# Create PyTorch model
pytorch_model = PyTorchModel(
    model_data=model_data,
    role=role,
    framework_version='2.0',
    py_version='py310',
    entry_point='inference.py'
)

# Deploy
predictor = pytorch_model.deploy(
    instance_type='ml.g4dn.xlarge',  # GPU instance
    initial_instance_count=1,
    endpoint_name='food-recognition-endpoint'
)
```

#### Google Cloud AI Platform
```bash
# Upload model
gsutil cp models/best_model.pth gs://your-bucket/models/

# Deploy
gcloud ai-platform versions create v1 \
    --model=food_recognition \
    --origin=gs://your-bucket/models/ \
    --runtime-version=2.11 \
    --framework=pytorch \
    --python-version=3.10 \
    --machine-type=n1-standard-4
```

### Option 2: TensorFlow Serving (Self-Hosted)

#### Convert PyTorch to ONNX to TensorFlow
```python
import torch
import onnx
from onnx_tf.backend import prepare

# Export to ONNX
torch.onnx.export(
    model,
    dummy_input,
    "model.onnx",
    export_params=True,
    opset_version=13
)

# Convert to TensorFlow
onnx_model = onnx.load("model.onnx")
tf_rep = prepare(onnx_model)
tf_rep.export_graph("saved_model")
```

#### Docker Container
```dockerfile
# Dockerfile
FROM tensorflow/serving:latest

COPY saved_model /models/food_recognition/1

ENV MODEL_NAME=food_recognition
EXPOSE 8501
```

```bash
# Build and run
docker build -t food-recognition-serving .
docker run -p 8501:8501 food-recognition-serving
```

### Option 3: On-Device (Mobile)

#### Convert to TFLite
```python
import tensorflow as tf

# Load SavedModel
converter = tf.lite.TFLiteConverter.from_saved_model('saved_model')

# Optimize
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]

# Convert
tflite_model = converter.convert()

# Save
with open('model.tflite', 'wb') as f:
    f.write(tflite_model)
```

#### Flutter Integration
```dart
// pubspec.yaml
dependencies:
  tflite_flutter: ^0.10.0

// Load model
import 'package:tflite_flutter/tflite_flutter.dart';

class OnDeviceAI {
  late Interpreter interpreter;
  
  Future<void> loadModel() async {
    interpreter = await Interpreter.fromAsset('assets/model.tflite');
  }
  
  Future<List<double>> predict(List<List<List<double>>> input) async {
    var output = List.filled(100, 0.0).reshape([1, 100]);
    interpreter.run(input, output);
    return output[0];
  }
}
```

## Production Backend Integration

### Update FastAPI Service
```python
# backend/app/services/ai_service_v2.py
from typing import Optional
import httpx

class ProductionAIService:
    def __init__(self, endpoint_url: str):
        self.endpoint_url = endpoint_url
        self.client = httpx.AsyncClient(timeout=30.0)
    
    async def analyze_image(self, image_bytes: bytes):
        """Call deployed model endpoint"""
        
        response = await self.client.post(
            f'{self.endpoint_url}/predict',
            files={'image': image_bytes},
            headers={'Content-Type': 'multipart/form-data'}
        )
        
        if response.status_code != 200:
            raise Exception(f"Model inference failed: {response.text}")
        
        return response.json()
```

### Environment Configuration
```bash
# .env
AI_MODEL_ENDPOINT=https://your-sagemaker-endpoint.amazonaws.com
AI_MODEL_API_KEY=your_api_key
```

## Model Versioning

### A/B Testing Setup
```python
class ModelRouter:
    def __init__(self):
        self.model_v1 = load_model('v1')
        self.model_v2 = load_model('v2')
    
    async def predict(self, image, user_id):
        # Route 10% to v2, 90% to v1
        if hash(user_id) % 10 == 0:
            return await self.model_v2.predict(image)
        else:
            return await self.model_v1.predict(image)
```

### Canary Deployment
```yaml
# kubernetes/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: food-model-v1
spec:
  replicas: 9  # 90% traffic
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: food-model-v2
spec:
  replicas: 1  # 10% traffic
```

## Monitoring & Logging

### Model Performance Tracking
```python
from prometheus_client import Counter, Histogram

prediction_counter = Counter(
    'model_predictions_total',
    'Total predictions',
    ['model_version', 'food_class']
)

prediction_latency = Histogram(
    'model_prediction_latency_seconds',
    'Prediction latency'
)

@prediction_latency.time()
async def predict_with_metrics(image):
    result = await model.predict(image)
    prediction_counter.labels(
        model_version='v1',
        food_class=result['class']
    ).inc()
    return result
```

### Logging
```python
from loguru import logger

logger.add(
    "logs/model_{time}.log",
    rotation="500 MB",
    retention="10 days",
    level="INFO"
)

logger.info(
    "Prediction",
    extra={
        "confidence": confidence,
        "food_class": food_class,
        "latency_ms": latency
    }
)
```

## Cost Optimization

### Auto-scaling
```yaml
# AWS Auto Scaling Policy
{
  "TargetValue": 70.0,  # CPU utilization
  "ScaleInCooldown": 300,
  "ScaleOutCooldown": 60
}
```

### Batch Processing
```python
# Process multiple images in batch
async def batch_predict(images: List[bytes]):
    # Combine into batch tensor
    batch = torch.stack([preprocess(img) for img in images])
    
    # Single forward pass
    with torch.no_grad():
        outputs = model(batch)
    
    return outputs
```

### Caching
```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=1000)
def get_cached_prediction(image_hash: str):
    # Return cached result if exists
    pass

def predict_with_cache(image_bytes):
    image_hash = hashlib.md5(image_bytes).hexdigest()
    
    # Check cache
    cached = get_cached_prediction(image_hash)
    if cached:
        return cached
    
    # Predict and cache
    result = model.predict(image_bytes)
    get_cached_prediction(image_hash, result)
    return result
```

## Rollback Strategy

### Quick Rollback
```bash
# Kubernetes
kubectl rollout undo deployment/food-model

# SageMaker
aws sagemaker update-endpoint \
    --endpoint-name food-recognition \
    --endpoint-config-name previous-config
```

## Performance Benchmarks

### Target Metrics:
- **Latency**: <200ms (p95)
- **Throughput**: 100 requests/sec
- **Uptime**: 99.9%
- **Cost**: <$0.01 per prediction

## Checklist

- [ ] Model converted to production format
- [ ] Endpoint deployed and tested
- [ ] Monitoring & logging configured
- [ ] Auto-scaling enabled
- [ ] A/B testing setup (optional)
- [ ] Rollback plan tested
- [ ] Cost alerts configured
- [ ] Documentation updated
- [ ] Team trained on deployment

**Estimated Deployment Time**: 1-2 weeks
