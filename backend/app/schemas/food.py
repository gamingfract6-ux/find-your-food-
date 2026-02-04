"""
Pydantic schemas for food analysis
"""
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
from datetime import datetime


class DetectedFood(BaseModel):
    """Individual detected food item"""
    name: str
    confidence: float
    calories: float
    protein: float
    carbs: float
    fats: float
    fiber: Optional[float] = 0
    sugar: Optional[float] = 0
    sodium: Optional[float] = 0
    portion: str
    weight_grams: float


class FoodAnalysisResponse(BaseModel):
    """Complete food analysis result"""
    id: int
    image_url: str
    detected_foods: List[DetectedFood]
    
    # Nutrition Summary
    total_calories: float
    total_protein: float
    total_carbs: float
    total_fats: float
    total_fiber: float
    total_sugar: float
    total_sodium: float
    
    # Analysis Metadata
    confidence_score: float
    health_score: str
    dietary_tags: List[str]
    ai_insights: str
    analysis_time: float
    created_at: datetime
    
    class Config:
        from_attributes = True


class FoodAnalysisRequest(BaseModel):
    """Request for manual food analysis (if needed)"""
    food_name: str
    portion: str
    weight_grams: Optional[float] = None


class FeedbackRequest(BaseModel):
    """User feedback on food detection accuracy"""
    scan_id: int
    is_accurate: bool
    correct_food_name: Optional[str] = None
    comments: Optional[str] = None


class HistoryResponse(BaseModel):
    """Food scan history item"""
    id: int
    image_url: str
    total_calories: float
    detected_foods_count: int
    created_at: datetime
    
    class Config:
        from_attributes = True
