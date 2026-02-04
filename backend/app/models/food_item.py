"""
Food Item model for nutrition database
"""
from sqlalchemy import Column, Integer, String, Float, Text, ARRAY
from sqlalchemy.dialects.postgresql import JSONB
from app.database import Base


class FoodItem(Base):
    __tablename__ = "food_items"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(255), nullable=False, index=True)
    category = Column(String(100))  # grains, vegetables, protein, dairy, etc.
    
    # Nutrition per 100g
    calories_per_100g = Column(Float, nullable=False)
    protein = Column(Float)  # grams
    carbs = Column(Float)  # grams
    fats = Column(Float)  # grams
    fiber = Column(Float)  # grams
    sugar = Column(Float)  # grams
    sodium = Column(Float)  # mg
    
    # Additional Nutrients (JSON)
    vitamins = Column(JSONB)  # {"vitamin_a": 100, "vitamin_c": 50, ...}
    minerals = Column(JSONB)  # {"iron": 2.5, "calcium": 100, ...}
    
    # Classification
    region = Column(String(50))  # india, usa, international
    dietary_tags = Column(ARRAY(Text))  # veg, vegan, gluten_free, dairy_free, etc.
    
    # Metadata
    description = Column(Text)  # Brief description
    common_serving_size = Column(String(100))  # "1 cup", "1 medium", etc.
    
    def __repr__(self):
        return f"<FoodItem {self.name} - {self.calories_per_100g}cal/100g>"
