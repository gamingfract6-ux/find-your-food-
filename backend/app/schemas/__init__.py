"""
Schemas package - exports all Pydantic schemas
"""
from app.schemas.auth import (
    GoogleAuthRequest,
    UserCreate,
    UserProfile,
    UserResponse,
    TokenResponse
)
from app.schemas.food import (
    DetectedFood,
    FoodAnalysisResponse,
    FoodAnalysisRequest,
    FeedbackRequest,
    HistoryResponse
)

__all__ = [
    "GoogleAuthRequest",
    "UserCreate", 
    "UserProfile",
    "UserResponse",
    "TokenResponse",
    "DetectedFood",
    "FoodAnalysisResponse",
    "FoodAnalysisRequest",
    "FeedbackRequest",
    "HistoryResponse"
]
