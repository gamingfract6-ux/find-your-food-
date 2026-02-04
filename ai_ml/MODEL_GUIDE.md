# AI Model Architecture & Training Guide

## Model Selection

### Recommended Architecture: **EfficientNetV2-B0**

**Why EfficientNetV2:**
- State-of-the-art accuracy for food recognition
- Optimized for mobile deployment (4.3M parameters)
- Fast inference time (~50ms on mobile)
- Pre-trained on ImageNet, easy to fine-tune
- Excellent balance of accuracy vs size

### Alternative Models:
1. **Vision Transformer (ViT-Tiny)** - Higher accuracy, slower
2. **MobileNetV3** - Faster, lower accuracy
3. **ResNet50** - Good baseline
4. **Food-101 pre-trained** - Domain-specific starting point

---

## Dataset Requirements

### Training Dataset Structure
```
dataset/
├── train/
│   ├── biryani/
│   │   ├── img001.jpg
│   │   ├── img002.jpg
│   │   └── ...
│   ├── dosa/
│   ├── pizza/
│   └── ... (100+ categories)
├── val/
│   └── ... (same structure)
└── test/
    └── ... (same structure)
```

### Dataset Sources:
1. **Food-101** (101k images, 101 classes)
2. **Indian Food Dataset** (Kaggle - 12 Indian dishes)
3. **UEC FOOD-100** (Japanese food)
4. **Custom scraped data** (Google Images, Instagram)

### Data Collection Guidelines:
- **Minimum per class**: 500 images
- **Image size**: 512x512 minimum
- **Variety**: Different angles, lighting, portions
- **Annotations**: Food name, portion size, ingredients

### Data Augmentation:
```python
- Random rotation (±20°)
- Random zoom (0.8-1.2x)
- Horizontal flip
- Brightness/contrast adjustment
- Color jitter
- Random crop
```

---

## Training Pipeline

### Hardware Requirements:
- **GPU**: NVIDIA RTX 3090 / A100 (recommended)
- **RAM**: 32GB minimum
- **Storage**: 100GB SSD
- **Training time**: 24-48 hours

### Training Parameters:
```yaml
model: efficientnet_v2_b0
input_size: 224x224
batch_size: 32
learning_rate: 0.001
optimizer: AdamW
scheduler: CosineAnnealingLR
epochs: 100
early_stopping_patience: 10
```

### Training Stages:
1. **Stage 1**: Freeze backbone, train head (10 epochs)
2. **Stage 2**: Unfreeze all, fine-tune (50 epochs)
3. **Stage 3**: Lower LR, final tuning (40 epochs)

---

## Model Optimization

### Quantization (TFLite/ONNX):
```python
# INT8 quantization
- Reduces model size by 4x
- Maintains 95%+ accuracy
- Enables mobile GPU acceleration
```

### Pruning:
```python
# Remove 30-50% of weights
- Sparse model execution
- Faster inference
- Smaller model size
```

### Knowledge Distillation:
```python
# Teacher: EfficientNetV2-L
# Student: EfficientNetV2-B0
# Temperature: 3.0
```

---

## Production Deployment

### Deployment Options:

#### Option 1: Cloud Inference (Recommended)
```
FastAPI Backend → TensorFlow Serving
- Auto-scaling
- Model versioning
- A/B testing
- Cost: ~$100/month
```

#### Option 2: On-Device Inference
```
Mobile App → TFLite Model
- No internet required
- Privacy-focused
- Faster inference
- Larger app size (+50MB)
```

#### Option 3: Hybrid
```
Simple foods → On-device
Complex foods → Cloud API
```

### Model Serving Stack:
- **Framework**: TensorFlow Serving / TorchServe
- **Container**: Docker
- **Orchestration**: Kubernetes
- **Monitoring**: Prometheus + Grafana
- **Logging**: ELK Stack

---

## Model Versioning

### Version Control:
```
models/
├── v1.0.0/ (Initial release)
├── v1.1.0/ (Added 20 Indian foods)
├── v1.2.0/ (Improved portion estimation)
└── v2.0.0/ (New architecture)
```

### Model Registry:
- **MLflow** or **W&B** for experiment tracking
- **DVC** for data/model versioning
- **S3/GCS** for model storage

---

## Performance Metrics

### Target Metrics:
- **Top-1 Accuracy**: >85%
- **Top-5 Accuracy**: >95%
- **Inference Time**: <100ms
- **Model Size**: <20MB
- **Confidence Threshold**: 85%

### Evaluation:
```python
Metrics to track:
- Accuracy per food category
- Confusion matrix
- Precision/Recall/F1
- mAP (mean Average Precision)
- Inference latency (p50, p95, p99)
```

---

## Integration Roadmap

### Phase 1: MVP (Current - Mock AI)
✅ Mock service with 15 foods

### Phase 2: Beta (Month 1-2)
- Train model on 50 food classes
- Deploy to cloud (AWS SageMaker)
- Integrate with FastAPI

### Phase 3: Production (Month 3-4)
- Scale to 200+ food classes
- On-device inference for common foods
- Real-time model updates

### Phase 4: Advanced (Month 5-6)
- Multi-food detection
- Ingredient-level recognition
- Portion size estimation with depth
- Personalized model per user

---

## Cost Estimation

### Training Costs:
- **GPU Cloud**: $2-5/hour × 48 hours = $100-250
- **Dataset licensing**: $0-500
- **Storage**: $10/month

### Inference Costs (10k requests/day):
- **Cloud API**: $50-150/month
- **On-device**: $0 (one-time training cost)

---

## Next Steps

1. ✅ Set up Google Cloud / AWS account
2. ✅ Collect/download datasets
3. ✅ Run training pipeline
4. ✅ Evaluate model performance
5. ✅ Optimize for mobile
6. ✅ Deploy to cloud
7. ✅ Integrate with backend
8. ✅ Monitor and iterate

**Estimated Timeline**: 2-3 months for production-ready model
