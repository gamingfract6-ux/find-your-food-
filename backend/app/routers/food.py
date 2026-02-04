"""
Food analysis router for AI food detection and nutrition analysis
"""
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models import FoodScan, User
from app.schemas.food import (
    FoodAnalysisResponse,
    FeedbackRequest,
    HistoryResponse,
    DetectedFood
)
from app.services.ai_service import ai_service
from app.services.nutrition_service import nutrition_service
from app.services.image_service import image_service
from typing import List
import time

router = APIRouter(prefix="/food", tags=["Food Analysis"])


@router.post("/analyze", response_model=FoodAnalysisResponse)
async def analyze_food(
    image: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    """
    Analyze uploaded food image and return nutrition information
    """
    start_time = time.time()
    
    try:
        # Read image bytes
        image_bytes = await image.read()
        
        # Save image
        file_path, compressed_bytes = await image_service.save_image(
            image_bytes, image.filename
        )
        image_url = image_service.get_image_url(file_path)
        
        # Analyze with AI
        detected_foods, confidence_score = await ai_service.analyze_image(compressed_bytes)
        
        # Check confidence threshold
        if confidence_score < 0.85:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={
                    "error": "food_not_detected",
                    "message": "Unable to detect food with sufficient confidence. Please try another image.",
                    "confidence": confidence_score
                }
            )
        
        # Calculate total nutrition
        total_nutrition = nutrition_service.calculate_total_nutrition(detected_foods)
        
        # Calculate health score
        health_score = nutrition_service.calculate_health_score(total_nutrition)
        
        # Determine dietary tags
        dietary_tags = nutrition_service.determine_dietary_tags(detected_foods)
        
        # Generate AI insights
        ai_insights = nutrition_service.generate_ai_insights(
            total_nutrition,
            health_score
        )
        
        analysis_time = time.time() - start_time
        
        # Get current user (mock - use first user)
        user = db.query(User).first()
        if not user:
            # Create demo user if none exists
            user = User(
                email="demo@calorai.com",
                google_id="demo_123",
                name="Demo User",
                region="india"
            )
            db.add(user)
            db.commit()
            db.refresh(user)
        
        # Save scan to database
        food_scan = FoodScan(
            user_id=user.id,
            image_url=image_url,
            detected_foods=detected_foods,
            confidence_score=confidence_score,
            total_calories=total_nutrition["total_calories"],
            total_protein=total_nutrition["total_protein"],
            total_carbs=total_nutrition["total_carbs"],
            total_fats=total_nutrition["total_fats"],
            total_fiber=total_nutrition["total_fiber"],
            total_sugar=total_nutrition["total_sugar"],
            total_sodium=total_nutrition["total_sodium"],
            health_score=health_score,
            dietary_tags=dietary_tags,
            ai_insights=ai_insights,
            analysis_time=analysis_time
        )
        db.add(food_scan)
        db.commit()
        db.refresh(food_scan)
        
        # Return response
        return FoodAnalysisResponse(
            id=food_scan.id,
            image_url=image_url,
            detected_foods=[DetectedFood(**f) for f in detected_foods],
            total_calories=total_nutrition["total_calories"],
            total_protein=total_nutrition["total_protein"],
            total_carbs=total_nutrition["total_carbs"],
            total_fats=total_nutrition["total_fats"],
            total_fiber=total_nutrition["total_fiber"],
            total_sugar=total_nutrition["total_sugar"],
            total_sodium=total_nutrition["total_sodium"],
            confidence_score=confidence_score,
            health_score=health_score,
            dietary_tags=dietary_tags,
            ai_insights=ai_insights,
            analysis_time=analysis_time,
            created_at=food_scan.created_at
        )
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analysis failed: {str(e)}"
        )


@router.get("/analysis/{scan_id}", response_model=FoodAnalysisResponse)
async def get_analysis(scan_id: int, db: Session = Depends(get_db)):
    """
    Retrieve a previous food analysis by ID
    """
    food_scan = db.query(FoodScan).filter(FoodScan.id == scan_id).first()
    
    if not food_scan:
        raise HTTPException(status_code=404, detail="Analysis not found")
    
    return FoodAnalysisResponse(
        id=food_scan.id,
        image_url=food_scan.image_url,
        detected_foods=[DetectedFood(**f) for f in food_scan.detected_foods],
        total_calories=food_scan.total_calories,
        total_protein=food_scan.total_protein,
        total_carbs=food_scan.total_carbs,
        total_fats=food_scan.total_fats,
        total_fiber=food_scan.total_fiber,
        total_sugar=food_scan.total_sugar,
        total_sodium=food_scan.total_sodium,
        confidence_score=food_scan.confidence_score,
        health_score=food_scan.health_score,
        dietary_tags=food_scan.dietary_tags,
        ai_insights=food_scan.ai_insights,
        analysis_time=food_scan.analysis_time,
        created_at=food_scan.created_at
    )


@router.get("/history", response_model=List[HistoryResponse])
async def get_history(
    limit: int = 20,
    db: Session = Depends(get_db)
):
    """
    Get user's food scan history
    """
    # MOCK: Get first user
    user = db.query(User).first()
    
    if not user:
        return []
    
    scans = db.query(FoodScan)\
        .filter(FoodScan.user_id == user.id)\
        .order_by(FoodScan.created_at.desc())\
        .limit(limit)\
        .all()
    
    return [
        HistoryResponse(
            id=scan.id,
            image_url=scan.image_url,
            total_calories=scan.total_calories,
            detected_foods_count=len(scan.detected_foods),
            created_at=scan.created_at
        )
        for scan in scans
    ]


@router.post("/feedback")
async def submit_feedback(
    feedback: FeedbackRequest,
    db: Session = Depends(get_db)
):
    """
    Submit feedback on food detection accuracy
    Used to improve AI model over time
    """
    food_scan = db.query(FoodScan).filter(FoodScan.id == feedback.scan_id).first()
    
    if not food_scan:
        raise HTTPException(status_code=404, detail="Scan not found")
    
    # In production, store feedback for model training
    # For now, just acknowledge
    
    return {
        "message": "Feedback received. Thank you for helping us improve!",
        "scan_id": feedback.scan_id
    }
