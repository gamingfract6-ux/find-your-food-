# CalorAI Backend

Premium AI-powered food calorie tracking backend built with FastAPI.

## Features

- 🤖 **AI Food Recognition**: Detect food items from images
- 🥗 **Comprehensive Nutrition Data**: Calories, macros, micros, and more
- 🎯 **Health Scoring**: A+ to D rating system
- 🏷️ **Dietary Tags**: Veg, vegan, keto, high-protein, etc.
- 💡 **AI Insights**: Personalized nutrition recommendations
- 🔐 **Google OAuth**: Secure authentication
- 📊 **History Tracking**: Track all food scans

## Setup Instructions

### Prerequisites

- Python 3.11 or higher
- PostgreSQL database (or use SQLite for development)

### Installation

1. **Clone the repository**
   ```bash
   cd backend
   ```

2. **Create virtual environment**
   ```powershell
   python -m venv venv
   .\venv\Scripts\activate
   ```

3. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure environment**
   ```bash
   # Copy example env file
   copy .env.example .env
   
   # Edit .env with your settings
   # For development, you can use SQLite:
   # DATABASE_URL=sqlite:///./calorai.db
   ```

5. **Run the server**
   ```bash
   cd app
   uvicorn main:app --reload
   ```

6. **Access API Documentation**
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc

## API Endpoints

### Authentication
- `POST /api/auth/google-signin` - Sign in with Google
- `GET /api/auth/me` - Get current user
- `PUT /api/auth/profile` - Update user profile

### Food Analysis
- `POST /api/food/analyze` - Analyze food image
- `GET /api/food/analysis/{id}` - Get analysis by ID
- `GET /api/food/history` - Get scan history
- `POST /api/food/feedback` - Submit feedback

## Testing

### Test Food Analysis

```bash
# Using curl
curl -X POST "http://localhost:8000/api/food/analyze" \
  -H "Content-Type: multipart/form-data" \
  -F "image=@test_food.jpg"
```

### Test with Swagger UI

1. Go to http://localhost:8000/docs
2. Click on `POST /api/food/analyze`
3. Click "Try it out"
4. Upload a food image
5. Execute

## Mock AI Service

Currently using a **mock AI service** that simulates food detection with 15 common foods:
- Indian: biryani, dosa, idli, samosa, dal, chapati, chicken curry
- International: pizza, burger, pasta, sandwich
- Healthy: salad, apple, banana, rice

In production, replace with:
- Trained CNN (EfficientNet, ResNet)
- Vision Transformer (ViT, CLIP)
- Real-time object detection (YOLO, Faster R-CNN)

## Database Schema

See `app/models/` for complete schema:
- `User`: User profiles and preferences
- `FoodScan`: Scan history and results
- `FoodItem`: Nutrition database (optional)

## Architecture

```
backend/
├── app/
│   ├── main.py           # FastAPI app
│   ├── config.py         # Configuration
│   ├── database.py       # Database connection
│   ├── models/           # SQLAlchemy models
│   ├── schemas/          # Pydantic schemas
│   ├── routers/          # API endpoints
│   ├── services/         # Business logic
│   └── data/             # Nutrition data
├── requirements.txt
└── .env.example
```

## Contributing

This is a production-ready backend designed for scalability. For feature requests or issues, please contact the development team.

## License

Proprietary - CalorAI © 2026
