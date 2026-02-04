"""
Food Scan model for storing user scan history
"""
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Text, ARRAY
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from app.database import Base


class FoodScan(Base):
    __tablename__ = "food_scans"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    
    # Image Data
    image_url = Column(String(500), nullable=False)
    
    # Detection Results
    detected_foods = Column(JSONB)  # List of detected food items with details
    confidence_score = Column(Float)  # Overall confidence (0-100)
    portion_estimate = Column(String(100))  # "1 plate", "2 cups", etc.
    
    # Nutrition Summary
    total_calories = Column(Float)
    total_protein = Column(Float)
    total_carbs = Column(Float)
    total_fats = Column(Float)
    total_fiber = Column(Float)
    total_sugar = Column(Float)
    total_sodium = Column(Float)
    
    # Health Analysis
    health_score = Column(String(5))  # A+, A, B, C, D
    dietary_tags = Column(ARRAY(Text))  # veg, vegan, keto, diabetic_friendly
    ai_insights = Column(Text)  # AI-generated insights and recommendations
    
    # Performance
    analysis_time = Column(Float)  # Time taken to analyze in seconds
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", backref="food_scans")
    
    def __repr__(self):
        return f"<FoodScan {self.id} - {self.total_calories}cal>"
