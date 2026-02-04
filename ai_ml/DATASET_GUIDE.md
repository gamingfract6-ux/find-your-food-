# Dataset Preparation Guide

## Overview
This guide helps you collect and prepare food image datasets for training.

## Step 1: Download Public Datasets

### Food-101 Dataset
```bash
wget http://data.vision.ee.ethz.ch/cvl/food-101.tar.gz
tar -xzf food-101.tar.gz
```

### Indian Food Dataset (Kaggle)
```bash
# Install Kaggle CLI
pip install kaggle

# Download dataset
kaggle datasets download -d iamsouravbanerjee/indian-food-dataset

# Extract
unzip indian-food-dataset.zip -d indian_food/
```

### Custom Data Sources
- **Google Images**: Use `icrawler` or `bing-image-downloader`
- **Instagram**: Scrape with `instaloader` (respect ToS)
- **Restaurants**: Partner for licensed images
- **User submissions**: Crowd-source from beta users

## Step 2: Data Organization

### Directory Structure
```
dataset/
├── train/ (70%)
│   ├── biryani/
│   ├── dosa/
│   ├── pizza/
│   └── ...
├── val/ (15%)
│   └── ...
└── test/ (15%)
    └── ...
```

### Automated Organization Script
```python
import shutil
from pathlib import Path
import random

def organize_dataset(source_dir, output_dir, split=(0.7, 0.15, 0.15)):
    """Split dataset into train/val/test"""
    
    for food_class in Path(source_dir).iterdir():
        if not food_class.is_dir():
            continue
        
        images = list(food_class.glob('*.jpg'))
        random.shuffle(images)
        
        train_size = int(len(images) * split[0])
        val_size = int(len(images) * split[1])
        
        # Split
        train_imgs = images[:train_size]
        val_imgs = images[train_size:train_size + val_size]
        test_imgs = images[train_size + val_size:]
        
        # Copy to respective folders
        for split_name, split_imgs in [
            ('train', train_imgs),
            ('val', val_imgs),
            ('test', test_imgs)
        ]:
            dest_dir = Path(output_dir) / split_name / food_class.name
            dest_dir.mkdir(parents=True, exist_ok=True)
            
            for img in split_imgs:
                shutil.copy(img, dest_dir / img.name)
```

## Step 3: Data Cleaning

### Remove Duplicates
```python
from imagededup.methods import PHash

phasher = PHash()
encodings = phasher.encode_images(image_dir='dataset/train')
duplicates = phasher.find_duplicates(encoding_map=encodings)

# Remove duplicates
for file, dups in duplicates.items():
    for dup in dups:
        Path(dup).unlink()
```

### Validate Images
```python
from PIL import Image

def validate_images(directory):
    """Remove corrupted images"""
    for img_path in Path(directory).rglob('*.jpg'):
        try:
            img = Image.open(img_path)
            img.verify()
        except Exception:
            print(f"Removing corrupted: {img_path}")
            img_path.unlink()
```

## Step 4: Nutrition Database

### Create `nutrition_db.json`
```json
{
    "biryani": {
        "calories_per_100g": 200,
        "protein_per_100g": 6,
        "carbs_per_100g": 30,
        "fats_per_100g": 7,
        "fiber_per_100g": 2,
        "sugar_per_100g": 1,
        "sodium_per_100g": 400
    },
    "dosa": {
        "calories_per_100g": 120,
        "protein_per_100g": 3,
        ...
    }
}
```

### Populate from USDA Database
```python
import requests

def fetch_nutrition(food_name):
    """Fetch from USDA FoodData Central API"""
    api_key = 'YOUR_API_KEY'
    url = f'https://api.nal.usda.gov/fdc/v1/foods/search'
    
    params = {
        'api_key': api_key,
        'query': food_name,
        'pageSize': 1
    }
    
    response = requests.get(url, params=params)
    data = response.json()
    
    # Extract nutrition from first result
    # ... parse and return
```

## Step 5: Data Augmentation

Already implemented in `train_model.py`:
- Random rotation
- Zoom
- Flip
- Color jitter

## Step 6: Pre-processing

### Resize Images
```bash
# Using ImageMagick
find dataset/ -name "*.jpg" -exec mogrify -resize 512x512^ -gravity center -extent 512x512 {} \;
```

### Format Conversion
```python
from PIL import Image

def convert_to_jpg(directory):
    """Convert all images to JPEG"""
    for img_path in Path(directory).rglob('*'):
        if img_path.suffix.lower() in ['.png', '.webp', '.bmp']:
            img = Image.open(img_path).convert('RGB')
            new_path = img_path.with_suffix('.jpg')
            img.save(new_path, 'JPEG', quality=95)
            img_path.unlink()
```

## Dataset Statistics

### Calculate Class Distribution
```python
from collections import Counter

def get_class_distribution(data_dir):
    class_counts = Counter()
    
    for food_dir in Path(data_dir).iterdir():
        if food_dir.is_dir():
            class_counts[food_dir.name] = len(list(food_dir.glob('*.jpg')))
    
    return class_counts
```

### Target Distribution
- Minimum: 500 images per class
- Recommended: 1000+ images per class
- Balanced: Equal samples per class (use oversampling/undersampling)

## Quality Checklist

- [ ] All images are food-related
- [ ] Minimum 500 images per class
- [ ] No duplicates
- [ ] No corrupted files
- [ ] Proper train/val/test split
- [ ] Images are 512x512 or larger
- [ ] JPEG format
- [ ] Nutrition database complete
- [ ] Balanced class distribution

## Estimated Time
- Download datasets: 2-4 hours
- Organization: 1 hour
- Cleaning: 2-3 hours
- Nutrition database: 4-6 hours

**Total**: ~10-15 hours
