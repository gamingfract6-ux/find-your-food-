"""
Model deployment and inference service
Integrates trained model with FastAPI backend
"""

import torch
import torch.nn as nn
from torchvision import transforms, models
from PIL import Image
import io
import json
from typing import List, Tuple, Dict
import numpy as np


class ProductionFoodRecognizer:
    """Production-ready food recognition service"""
    
    def __init__(self, model_path: str, class_names_path: str):
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
        self.model = self._load_model(model_path)
        self.class_names = self._load_class_names(class_names_path)
        self.transform = self._get_transform()
        self.nutrition_db = self._load_nutrition_db()
    
    def _load_model(self, model_path: str) -> nn.Module:
        """Load trained model"""
        checkpoint = torch.load(model_path, map_location=self.device)
        
        # Initialize model architecture
        model = models.efficientnet_v2_s(pretrained=False)
        num_classes = len(checkpoint.get('class_names', []))
        in_features = model.classifier[1].in_features
        model.classifier = nn.Sequential(
            nn.Dropout(p=0.3),
            nn.Linear(in_features, num_classes)
        )
        
        # Load weights
        model.load_state_dict(checkpoint['model_state_dict'])
        model = model.to(self.device)
        model.eval()
        
        return model
    
    def _load_class_names(self, path: str) -> List[str]:
        """Load food class names"""
        with open(path, 'r') as f:
            return json.load(f)
    
    def _load_nutrition_db(self) -> Dict:
        """Load nutrition database"""
        with open('nutrition_db.json', 'r') as f:
            return json.load(f)
    
    def _get_transform(self):
        """Preprocessing transform"""
        return transforms.Compose([
            transforms.Resize(256),
            transforms.CenterCrop(224),
            transforms.ToTensor(),
            transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
        ])
    
    async def analyze_image(self, image_bytes: bytes) -> Tuple[List[Dict], float]:
        """
        Analyze food image and return detected foods
        
        Returns:
            (detected_foods, overall_confidence)
        """
        # Load and preprocess image
        image = Image.open(io.BytesIO(image_bytes)).convert('RGB')
        input_tensor = self.transform(image).unsqueeze(0).to(self.device)
        
        # Inference
        with torch.no_grad():
            outputs = self.model(input_tensor)
            probabilities = torch.nn.functional.softmax(outputs, dim=1)
            top5_prob, top5_idx = torch.topk(probabilities, 5)
        
        # Get top prediction
        top_prob = top5_prob[0][0].item()
        top_idx = top5_idx[0][0].item()
        
        if top_prob < 0.85:
            # Low confidence
            raise ValueError("Food not detected with sufficient confidence")
        
        # Get food details
        food_name = self.class_names[top_idx]
        nutrition = self.nutrition_db.get(food_name, {})
        
        # Estimate portion size (simple heuristic for now)
        portion_grams = self._estimate_portion_size(image)
        
        # Calculate nutrition for portion
        detected_food = {
            'name': food_name.title(),
            'confidence': top_prob,
            'calories': nutrition.get('calories_per_100g', 0) * (portion_grams / 100),
            'protein': nutrition.get('protein_per_100g', 0) * (portion_grams / 100),
            'carbs': nutrition.get('carbs_per_100g', 0) * (portion_grams / 100),
            'fats': nutrition.get('fats_per_100g', 0) * (portion_grams / 100),
            'fiber': nutrition.get('fiber_per_100g', 0) * (portion_grams / 100),
            'sugar': nutrition.get('sugar_per_100g', 0) * (portion_grams / 100),
            'sodium': nutrition.get('sodium_per_100g', 0) * (portion_grams / 100),
            'portion': f"{portion_grams}g",
            'weight_grams': portion_grams
        }
        
        return [detected_food], top_prob
    
    def _estimate_portion_size(self, image: Image.Image) -> float:
        """
        Estimate portion size from image
        TODO: Implement depth-based estimation or object detection
        """
        # Simple heuristic based on image analysis
        # In production, use a separate portion estimation model
        width, height = image.size
        area = width * height
        
        # Rough estimation (needs improvement)
        if area < 100000:
            return 100  # Small portion
        elif area < 500000:
            return 200  # Medium portion
        else:
            return 300  # Large portion


# Integration with existing FastAPI backend
"""
Replace in backend/app/services/ai_service.py:

from .model_inference import ProductionFoodRecognizer

class AIFoodRecognitionService:
    def __init__(self):
        self.model = ProductionFoodRecognizer(
            model_path='./models/best_model.pth',
            class_names_path='./models/class_names.json'
        )
    
    async def analyze_image(self, image_bytes: bytes):
        return await self.model.analyze_image(image_bytes)
"""
