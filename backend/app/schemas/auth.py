"""
Pydantic schemas for authentication
"""
from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime


class GoogleAuthRequest(BaseModel):
    """Request schema for Google authentication"""
    id_token: str


class UserCreate(BaseModel):
    """Schema for creating a new user"""
    email: EmailStr
    google_id: str
    name: str
    profile_pic: Optional[str] = None


class UserProfile(BaseModel):
    """Schema for updating user profile"""
    age: Optional[int] = None
    height: Optional[float] = None
    weight: Optional[float] = None
    gender: Optional[str] = None
    fitness_goal: Optional[str] = None
    dietary_preference: Optional[str] = None
    allergies: Optional[List[str]] = None
    region: Optional[str] = "india"


class UserResponse(BaseModel):
    """Response schema for user data"""
    id: int
    email: str
    name: str
    profile_pic: Optional[str]
    age: Optional[int]
    height: Optional[float]
    weight: Optional[float]
    gender: Optional[str]
    fitness_goal: Optional[str]
    dietary_preference: Optional[str]
    allergies: Optional[List[str]]
    region: Optional[str]
    created_at: datetime
    
    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    """JWT token response"""
    access_token: str
    token_type: str = "bearer"
    user: UserResponse
