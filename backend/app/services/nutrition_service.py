"""
Nutrition service for calculating health metrics and insights
"""
from typing import List, Dict, Tuple
import random


class NutritionService:
    """Service for nutrition calculations and health insights"""
    
    # Daily recommended values (average adult)
    DAILY_RECOMMENDATIONS = {
        "calories": 2000,
        "protein": 50,
        "carbs": 275,
        "fats": 78,
        "fiber": 28,
        "sugar": 50,
        "sodium": 2300
    }
    
    def __init__(self):
        pass
    
    def calculate_health_score(self, nutrition: Dict) -> str:
        """
        Calculate health score based on nutrition balance
        
        Returns: A+, A, B, C, or D
        """
        score_points = 0
        
        # Calorie range check (not too high, not too low)
        if 300 <= nutrition["total_calories"] <= 700:
            score_points += 30
        elif nutrition["total_calories"] > 700:
            score_points += 15
        
        # Protein content (higher is better)
        if nutrition["total_protein"] >= 20:
            score_points += 25
        elif nutrition["total_protein"] >= 10:
            score_points += 15
        
        # Fiber content (higher is better)
        if nutrition["total_fiber"] >= 5:
            score_points += 20
        elif nutrition["total_fiber"] >= 2:
            score_points += 10
        
        # Sugar content (lower is better)
        if nutrition["total_sugar"] <= 10:
            score_points += 15
        elif nutrition["total_sugar"] <= 20:
            score_points += 8
        
        # Sodium content (lower is better)
        if nutrition["total_sodium"] <= 500:
            score_points += 10
        elif nutrition["total_sodium"] <= 1000:
            score_points += 5
        
        # Convert to letter grade
        if score_points >= 85:
            return "A+"
        elif score_points >= 70:
            return "A"
        elif score_points >= 55:
            return "B"
        elif score_points >= 40:
            return "C"
        else:
            return "D"
    
    def determine_dietary_tags(self, detected_foods: List[Dict]) -> List[str]:
        """
        Determine dietary tags based on detected foods
        """
        tags = set()
        
        # Food classification
        meat_foods = ["burger", "chicken curry"]
        veg_foods = ["dosa", "idli", "dal", "chapati", "rice", "salad", "samosa"]
        vegan_foods = ["dosa", "idli", "dal", "rice", "salad", "apple", "banana"]
        
        food_names = [f["name"].lower() for f in detected_foods]
        
        # Check if veg/non-veg
        has_meat = any(food in food_names for food in meat_foods)
        has_only_veg = all(food in veg_foods for food in food_names)
        has_only_vegan = all(food in vegan_foods for food in food_names)
        
        if has_meat:
            tags.add("non_veg")
        elif has_only_veg:
            tags.add("vegetarian")
        
        if has_only_vegan:
            tags.add("vegan")
        
        # Check if low sugar
        total_sugar = sum(f.get("sugar", 0) for f in detected_foods)
        if total_sugar < 10:
            tags.add("low_sugar")
        
        # Check if high protein
        total_protein = sum(f.get("protein", 0) for f in detected_foods)
        if total_protein >= 25:
            tags.add("high_protein")
        
        # Check if low carb (keto-friendly)
        total_carbs = sum(f.get("carbs", 0) for f in detected_foods)
        if total_carbs < 30:
            tags.add("keto_friendly")
        
        return list(tags)
    
    def generate_ai_insights(self, nutrition: Dict, health_score: str, user_profile: Dict = None) -> str:
        """
        Generate AI-powered insights and recommendations
        """
        insights = []
        
        # Calorie insight
        daily_calories = self.DAILY_RECOMMENDATIONS["calories"]
        cal_percentage = (nutrition["total_calories"] / daily_calories) * 100
        
        if cal_percentage > 40:
            insights.append(f"⚠️ This meal contains {int(cal_percentage)}% of your daily calorie needs.")
        else:
            insights.append(f"✅ This meal is {int(cal_percentage)}% of your daily calories - well balanced!")
        
        # Sugar insight
        if nutrition["total_sugar"] > 20:
            insights.append(f"🍬 High sugar content detected ({nutrition['total_sugar']:.1f}g). Consider reducing sugar intake.")
        
        # Protein insight
        if nutrition["total_protein"] < 10:
            insights.append("💪 Low protein content. Add nuts, eggs, or lean meat for better satiety.")
        elif nutrition["total_protein"] >= 25:
            insights.append(f"💪 Excellent protein content ({nutrition['total_protein']:.1f}g)!")
        
        # Sodium insight
        if nutrition["total_sodium"] > 1000:
            insights.append(f"🧂 High sodium ({nutrition['total_sodium']:.0f}mg). Drink plenty of water.")
        
        # Fiber insight
        if nutrition["total_fiber"] < 3:
            insights.append("🌾 Low fiber. Add vegetables or whole grains for better digestion.")
        
        # Health score feedback
        if health_score in ["A+", "A"]:
            insights.append("🌟 Great choice! This meal has excellent nutritional balance.")
        elif health_score == "B":
            insights.append("👍 Good meal choice. Could be improved with more vegetables.")
        else:
            insights.append("⚡ Consider adding more whole foods and vegetables for better nutrition.")
        
        return " ".join(insights)
    
    def calculate_total_nutrition(self, detected_foods: List[Dict]) -> Dict:
        """
        Calculate total nutrition from detected foods
        """
        return {
            "total_calories": sum(f.get("calories", 0) for f in detected_foods),
            "total_protein": sum(f.get("protein", 0) for f in detected_foods),
            "total_carbs": sum(f.get("carbs", 0) for f in detected_foods),
            "total_fats": sum(f.get("fats", 0) for f in detected_foods),
            "total_fiber": sum(f.get("fiber", 0) for f in detected_foods),
            "total_sugar": sum(f.get("sugar", 0) for f in detected_foods),
            "total_sodium": sum(f.get("sodium", 0) for f in detected_foods),
        }


# Global nutrition service instance
nutrition_service = NutritionService()
