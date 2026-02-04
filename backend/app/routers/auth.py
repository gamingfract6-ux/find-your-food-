"""
Authentication router for Google OAuth and user management
"""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import User
from app.schemas.auth import (
    GoogleAuthRequest,
    TokenResponse,
    UserResponse,
    UserProfile
)
from datetime import datetime, timedelta
from jose import JWTError, jwt
from app.config import settings
import httpx

router = APIRouter(prefix="/auth", tags=["Authentication"])


def create_access_token(data: dict):
    """Create JWT access token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt


async def verify_google_token(id_token: str) -> dict:
    """
    Verify Google ID token and extract user info
    In production, use google.oauth2.id_token.verify_oauth2_token
    """
    # MOCK: For development, skip actual Google verification
    # In production, implement proper Google token verification
    return {
        "email": "user@example.com",
        "sub": "google_user_id_123",
        "name": "Test User",
        "picture": "https://example.com/avatar.jpg"
    }


@router.post("/google-signin", response_model=TokenResponse)
async def google_signin(
    auth_request: GoogleAuthRequest,
    db: Session = Depends(get_db)
):
    """
    Authenticate user with Google ID token
    Creates new user if first time, returns existing user otherwise
    """
    try:
        # Verify Google token
        google_user = await verify_google_token(auth_request.id_token)
        
        # Check if user exists
        user = db.query(User).filter(User.email == google_user["email"]).first()
        
        if not user:
            # Create new user
            user = User(
                email=google_user["email"],
                google_id=google_user["sub"],
                name=google_user.get("name", ""),
                profile_pic=google_user.get("picture"),
                region="india"  # Default region
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        
        # Create access token
        access_token = create_access_token(
            data={"sub": user.email, "user_id": user.id}
        )
        
        return TokenResponse(
            access_token=access_token,
            user=UserResponse.from_orm(user)
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Authentication failed: {str(e)}"
        )


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    profile: UserProfile,
    db: Session = Depends(get_db),
    # In production, add current_user dependency from JWT token
):
    """
    Update user profile information
    """
    # MOCK: Get first user for development
    # In production, get current_user from JWT token
    user = db.query(User).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Update fields
    for key, value in profile.model_dump(exclude_unset=True).items():
        setattr(user, key, value)
    
    db.commit()
    db.refresh(user)
    
    return UserResponse.from_orm(user)


@router.get("/me", response_model=UserResponse)
async def get_current_user(db: Session = Depends(get_db)):
    """
    Get current user profile
    """
    # MOCK: Return first user for development
    user = db.query(User).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return UserResponse.from_orm(user)
