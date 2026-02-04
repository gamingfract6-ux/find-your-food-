"""
User model for authentication and profile management
"""
from sqlalchemy import Column, Integer, String, Float, DateTime, ARRAY, Text
from sqlalchemy.sql import func
from app.database import Base


class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), unique=True, nullable=False, index=True)
    google_id = Column(String(255), unique=True, nullable=False, index=True)
    name = Column(String(255))
    profile_pic = Column(String(500))
    
    # Profile Information
    age = Column(Integer)
    height = Column(Float)  # in cm
    weight = Column(Float)  # in kg
    gender = Column(String(20))  # male, female, other
    
    # Preferences
    fitness_goal = Column(String(50))  # weight_loss, weight_gain, maintenance, muscle_gain
    dietary_preference = Column(String(50))  # vegetarian, vegan, non_veg, keto, etc.
    allergies = Column(ARRAY(Text))  # list of allergies
    region = Column(String(50))  # india, usa, etc. for food accuracy
    
    # Metadata
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    
    def __repr__(self):
        return f"<User {self.email}>"
