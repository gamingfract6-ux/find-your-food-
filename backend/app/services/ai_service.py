import time
import os
import json
from typing import List, Dict, Tuple
import io
import random

# Try to import optional dependencies
try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

try:
    from PIL import Image
    HAS_PIL = True
except ImportError:
    HAS_PIL = False

# Try to import Gemini, fallback to Mock if missing
try:
    import google.generativeai as genai
    HAS_GEMINI = True and HAS_PIL
except ImportError:
    HAS_GEMINI = False
    print("[AI] WARNING: google-generativeai not found. Using Mock AI.")

class MockAIService:
    """Fallback Mock Service when Gemini is not available"""
    def __init__(self):
        print("[AI] Initializing Mock AI Service (Fallback)")
    
    async def analyze_image(self, image_bytes: bytes) -> Tuple[List[Dict], float]:
        print("[AI] Mock Analysis Triggered")
        # Return a generic result so app works
        return [{
            "name": "Mock Food",
            "confidence": 0.99,
            "calories": 250,
            "protein": 10,
            "carbs": 30,
            "fats": 10,
            "fiber": 2,
            "sugar": 5,
            "sodium": 300,
            "portion": "1 serving",
            "weight_grams": 100
        }], 0.99

    async def get_chat_response(self, message: str) -> str:
        return "I am currently in Offline Mode because my brain (Google AI) could not be loaded. Please check backend logs."

    def get_food_info(self, food_name: str) -> Dict:
        return None

class AIFoodRecognitionService:
    """
    Real AI service using Google Gemini Vision
    """
    
    def __init__(self):
        """Initialize the AI service with Google API Key"""
        if not HAS_GEMINI:
            self.model = None
            return

        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            print("[AI] WARNING: GOOGLE_API_KEY not found. AI features will fail.")
            self.model = None
            return

        try:
            genai.configure(api_key=api_key)
            self.model = genai.GenerativeModel('gemini-pro-vision')
            print("[AI] Gemini Vision Service initialized successfully")
            
            # Initialize text model for chat
            self.chat_model = genai.GenerativeModel('gemini-pro')
            
        except Exception as e:
            print(f"[AI] Failed to initialize Gemini: {e}")
            self.model = None
            self.chat_model = None
            
# Global AI service instance
if HAS_GEMINI:
    ai_service = AIFoodRecognitionService()
else:
    ai_service = MockAIService()
    
    async def get_chat_response(self, message: str) -> str:
        """
        Get response from AI Coach (Gemini Pro)
        """
        if not self.chat_model:
            return "I'm having trouble connecting to my brain right now. Please check the API key."
            
        try:
            prompt = f"""
            You are an expert AI Nutrition Coach named "CalorAI Coach". 
            Your goal is to help users eat healthy, lose weight, and build muscle.
            Keep your answers short, encouraging, and emoji-friendly.
            
            User: {message}
            
            Coach:
            """
            response = self.chat_model.generate_content(prompt)
            return response.text
        except Exception as e:
            print(f"[AI] Chat Error: {e}")
            return "I'm having a bit of trouble thinking right now. Ask me again in a moment!"
    
    async def analyze_image(self, image_bytes: bytes) -> Tuple[List[Dict], float]:
        """
        Analyze food image using Gemini Vision
        
        Args:
            image_bytes: Image file bytes
            
        Returns:
            Tuple of (detected_foods, confidence_score)
        """
        if not self.model:
            # Fallback for when API key is missing (Return empty to prompt user)
            print("[AI] Error: Model not initialized (Missing API Key)")
            return [], 0.0

        if not HAS_PIL:
             print("[AI] Error: PIL not installed")
             return [], 0.0

        start_time = time.time()
        
        try:
            # Load image for Gemini
            image = Image.open(io.BytesIO(image_bytes))
            
            # Prompt for Gemini
            prompt = """
            Analyze this image and identify any food items. 
            Return ONLY a valid JSON array of objects. Do not use Markdown code blocks.
            Each object should have:
            - name (string): Name of the food
            - confidence (float): 0.0 to 1.0
            - calories (float): Estimated calories per 100g
            - protein (float): Estimated protein (g) per 100g
            - carbs (float): Estimated carbs (g) per 100g
            - fats (float): Estimated fats (g) per 100g
            - fiber (float): Estimated fiber (g) per 100g
            - sugar (float): Estimated sugar (g) per 100g
            - sodium (float): Estimated sodium (mg) per 100g
            - portion (string): Estimated portion size description (e.g. "1 cup", "1 slice")
            - weight_grams (int): Estimated weight of the portion in the image
            
            If no food is detected, return an empty array [].
            """
            
            # Generate response
            response = self.model.generate_content([prompt, image])
            response_text = response.text
            
            # Clean response (remove markdown if present)
            if response_text.startswith("```json"):
                response_text = response_text.replace("```json", "").replace("```", "")
            
            # Parse JSON
            detected_foods = json.loads(response_text)
            
            # Calculate overall confidence
            if detected_foods:
                overall_confidence = sum(f.get("confidence", 0.8) for f in detected_foods) / len(detected_foods)
            else:
                overall_confidence = 0.0
                
            return detected_foods, round(overall_confidence, 2)

        except Exception as e:
            print(f"[AI] Error analyzing image: {e}")
            # Identify if it's a safety block or other error
            return [], 0.0
    
    def get_food_info(self, food_name: str) -> Dict:
        """
        Get nutrition info for a specific food (Text-only Gemini)
        """
        # For now, we rely on the visual analysis. 
        # In a full upgrade, we would add a text-only Gemini fallback here.
        return None

