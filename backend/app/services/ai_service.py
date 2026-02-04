"""
AI Service for food recognition and analysis
This is a MOCK service that simulates AI food detection
In production, replace with real trained model (EfficientNet, ViT, etc.)
"""
import random
import time
from typing import List, Dict, Tuple
from PIL import Image
import io


class AIFoodRecognitionService:
    """
    Mock AI service for food recognition
    Simulates deep learning model inference
    """
    
    # Mock food database with common foods
    FOOD_DATABASE = {
        "biryani": {
            "category": "indian",
            "calories_per_100g": 200,
            "protein": 6.5,
            "carbs": 35.0,
            "fats": 4.5,
            "fiber": 1.5,
            "sugar": 2.0,
            "sodium": 380
        },
        "pizza": {
            "category": "italian",
            "calories_per_100g": 266,
            "protein": 11.0,
            "carbs": 33.0,
            "fats": 10.0,
            "fiber": 2.3,
            "sugar": 3.7,
            "sodium": 598
        },
        "burger": {
            "category": "american",
            "calories_per_100g": 295,
            "protein": 17.0,
            "carbs": 24.0,
            "fats": 14.0,
            "fiber": 1.5,
            "sugar": 5.0,
            "sodium": 497
        },
        "dosa": {
            "category": "indian",
            "calories_per_100g": 133,
            "protein": 3.9,
            "carbs": 25.0,
            "fats": 1.8,
            "fiber": 1.2,
            "sugar": 0.5,
            "sodium": 115
        },
        "samosa": {
            "category": "indian",
            "calories_per_100g": 262,
            "protein": 5.0,
            "carbs": 28.0,
            "fats": 14.0,
            "fiber": 3.0,
            "sugar": 1.5,
            "sodium": 422
        },
        "apple": {
            "category": "fruit",
            "calories_per_100g": 52,
            "protein": 0.3,
            "carbs": 14.0,
            "fats": 0.2,
            "fiber": 2.4,
            "sugar": 10.4,
            "sodium": 1
        },
        "banana": {
            "category": "fruit",
            "calories_per_100g": 89,
            "protein": 1.1,
            "carbs": 23.0,
            "fats": 0.3,
            "fiber": 2.6,
            "sugar": 12.0,
            "sodium": 1
        },
        "rice": {
            "category": "grain",
            "calories_per_100g": 130,
            "protein": 2.7,
            "carbs": 28.0,
            "fats": 0.3,
            "fiber": 0.4,
            "sugar": 0.1,
            "sodium": 1
        },
        "dal": {
            "category": "indian",
            "calories_per_100g": 116,
            "protein": 9.0,
            "carbs": 20.0,
            "fats": 0.4,
            "fiber": 7.9,
            "sugar": 1.8,
            "sodium": 238
        },
        "chapati": {
            "category": "indian",
            "calories_per_100g": 297,
            "protein": 11.8,
            "carbs": 51.0,
            "fats": 5.0,
            "fiber": 7.3,
            "sugar": 1.0,
            "sodium": 318
        },
        "pasta": {
            "category": "italian",
            "calories_per_100g": 158,
            "protein": 5.8,
            "carbs": 31.0,
            "fats": 0.9,
            "fiber": 1.8,
            "sugar": 2.7,
            "sodium": 6
        },
        "chicken curry": {
            "category": "indian",
            "calories_per_100g": 166,
            "protein": 24.0,
            "carbs": 5.0,
            "fats": 5.5,
            "fiber": 1.0,
            "sugar": 2.0,
            "sodium": 340
        },
        "salad": {
            "category": "healthy",
            "calories_per_100g": 33,
            "protein": 1.4,
            "carbs": 6.3,
            "fats": 0.3,
            "fiber": 2.1,
            "sugar": 3.1,
            "sodium": 28
        },
        "sandwich": {
            "category": "american",
            "calories_per_100g": 245,
            "protein": 10.0,
            "carbs": 32.0,
            "fats": 8.0,
            "fiber": 2.8,
            "sugar": 5.5,
            "sodium": 512
        },
        "idli": {
            "category": "indian",
            "calories_per_100g": 58,
            "protein": 2.0,
            "carbs": 12.0,
            "fats": 0.2,
            "fiber": 0.6,
            "sugar": 0.3,
            "sodium": 42
        }
    }
    
    def __init__(self):
        """Initialize the AI service"""
        self.model_loaded = True
        print("[AI] Food Recognition Service initialized (MOCK MODE)")
    
    async def analyze_image(self, image_bytes: bytes) -> Tuple[List[Dict], float]:
        """
        Analyze food image and detect food items
        
        Args:
            image_bytes: Image file bytes
            
        Returns:
            Tuple of (detected_foods, confidence_score)
        """
        start_time = time.time()
        
        # Simulate image preprocessing
        try:
            image = Image.open(io.BytesIO(image_bytes))
            # Simulate model inference delay
            await self._simulate_processing(0.5, 1.5)
        except Exception as e:
            raise ValueError(f"Invalid image: {str(e)}")
        
        # Mock detection: randomly detect 1-3 food items
        num_foods = random.randint(1, 3)
        available_foods = list(self.FOOD_DATABASE.keys())
        detected_food_names = random.sample(available_foods, num_foods)
        
        detected_foods = []
        overall_confidence = random.uniform(0.85, 0.98)
        
        for food_name in detected_food_names:
            food_data = self.FOOD_DATABASE[food_name]
            
            # Estimate portion size (mock)
            portion_grams = random.choice([100, 150, 200, 250, 300])
            portion_text = self._estimate_portion_text(food_name, portion_grams)
            
            # Calculate nutrition based on portion
            multiplier = portion_grams / 100.0
            
            detected_foods.append({
                "name": food_name,
                "confidence": round(random.uniform(0.85, 0.99), 2),
                "calories": round(food_data["calories_per_100g"] * multiplier, 1),
                "protein": round(food_data["protein"] * multiplier, 1),
                "carbs": round(food_data["carbs"] * multiplier, 1),
                "fats": round(food_data["fats"] * multiplier, 1),
                "fiber": round(food_data.get("fiber", 0) * multiplier, 1),
                "sugar": round(food_data.get("sugar", 0) * multiplier, 1),
                "sodium": round(food_data.get("sodium", 0) * multiplier, 1),
                "portion": portion_text,
                "weight_grams": portion_grams
            })
        
        analysis_time = time.time() - start_time
        
        return detected_foods, round(overall_confidence, 2)
    
    def _estimate_portion_text(self, food_name: str, grams: float) -> str:
        """Convert grams to human-readable portion"""
        portions = {
            "rice": f"{int(grams/150)} cup" if grams >= 150 else "1 cup",
            "biryani": f"{int(grams/200)} plate" if grams >= 200 else "1 plate",
            "pizza": f"{int(grams/100)} slice" if grams >= 100 else "1 slice",
            "burger": "1 burger",
            "dosa": f"{int(grams/60)} piece" if grams >= 60 else "1 piece",
            "samosa": f"{int(grams/50)} piece" if grams >= 50 else "1 piece",
            "apple": "1 medium",
            "banana": "1 medium",
            "idli": f"{int(grams/30)} piece" if grams >= 30 else "1 piece",
        }
        return portions.get(food_name, f"{grams}g")
    
    async def _simulate_processing(self, min_delay: float, max_delay: float):
        """Simulate AI model processing time"""
        import asyncio
        delay = random.uniform(min_delay, max_delay)
        await asyncio.sleep(delay)
    
    def get_food_info(self, food_name: str) -> Dict:
        """Get nutrition info for a specific food"""
        return self.FOOD_DATABASE.get(food_name.lower())


# Global AI service instance
ai_service = AIFoodRecognitionService()
