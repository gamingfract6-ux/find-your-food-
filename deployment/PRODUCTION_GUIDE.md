# Production Deployment Guide

## Pre-Deployment Checklist

### Backend
- [ ] Environment variables configured
- [ ] Database migrations ready
- [ ] API documented (Swagger/ReDoc)
- [ ] Rate limiting enabled
- [ ] CORS configured
- [ ] Logging setup
- [ ] Health check endpoint
- [ ] Error monitoring (Sentry)

### Frontend
- [ ] API endpoints configured
- [ ] Assets optimized
- [ ] App icons prepared
- [ ] Splash screen ready
- [ ] Build configurations set
- [ ] Analytics integrated (Firebase/Mixpanel)
- [ ] Crash reporting enabled

---

## Backend Deployment

### Option 1: AWS Elastic Beanstalk

```bash
# Install EB CLI
pip install awsebcli

# Initialize
eb init -p python-3.11 find-your-food-api

# Create environment
eb create production

# Deploy
eb deploy
```

### Option 2: Google Cloud Run

```bash
# Build container
gcloud builds submit --tag gcr.io/PROJECT_ID/food-api

# Deploy
gcloud run deploy food-api \
    --image gcr.io/PROJECT_ID/food-api \
    --platform managed \
    --region us-central1 \
    --allow-unauthenticated
```

### Option 3: Docker + DigitalOcean/Heroku

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY backend/ .

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```bash
# Build
docker build -t find-your-food-api .

# Run
docker run -p 8000:8000 --env-file .env find-your-food-api
```

### Environment Variables (Production)
```bash
# .env.production
DATABASE_URL=postgresql://user:pass@host:5432/db
SECRET_KEY=your-very-secure-secret-key
GOOGLE_CLIENT_ID=your-google-client-id
GOOGLE_CLIENT_SECRET=your-google-client-secret
AI_MODEL_ENDPOINT=https://your-model-endpoint.com
ALLOWED_ORIGINS=https://yourapp.com
ENVIRONMENT=production
```

---

## Frontend Deployment

### Android Release

#### Step 1: Configure Build
```groovy
// android/app/build.gradle
android {
    defaultConfig {
        applicationId "com.findyourfood.app"
        versionCode 1
        versionName "1.0.0"
    }
    
    signingConfigs {
        release {
            storeFile file('keystore.jks')
            storePassword System.getenv('KEYSTORE_PASSWORD')
            keyAlias 'upload'
            keyPassword System.getenv('KEY_PASSWORD')
        }
    }
}
```

#### Step 2: Generate Keystore
```bash
keytool -genkey -v \
    -keystore upload-keystore.jks \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload
```

#### Step 3: Build APK/AAB
```bash
# Build App Bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release
```

#### Step 4: Upload to Play Store
1. Create app in Google Play Console
2. Upload AAB file
3. Fill store listing
4. Set pricing & distribution
5. Submit for review

### iOS Release

#### Step 1: Configure Xcode
```bash
# Update bundle identifier in Xcode
# Set version and build number
# Configure signing & capabilities
```

#### Step 2: Build Archive
```bash
flutter build ipa --release
```

#### Step 3: TestFlight
1. Open Xcode → Upload to App Store Connect
2. Process build
3. Add to TestFlight
4. Invite testers

#### Step 4: App Store Submission
1. Create app in App Store Connect
2. Upload screenshots (6.5", 5.5")
3. Fill app information
4. Submit for review

---

## Cloud Services Setup

### Firebase (Analytics + Crashlytics)

```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_analytics: ^10.7.0
  firebase_crashlytics: ^3.4.0
```

```dart
// Initialize
await Firebase.initializeApp();
FirebaseAnalytics.instance.logEvent(name: 'food_scanned');
```

### Google OAuth Setup

1. Create project in Google Cloud Console
2. Configure OAuth consent screen
3. Create OAuth 2.0 credentials
4. Add authorized domains
5. Download configuration files

---

## Database Migration

### Production Database Setup

```bash
# Create production database
CREATE DATABASE find_your_food_prod;

# Run migrations
alembic upgrade head

# Seed initial data
python scripts/seed_food_items.py
```

### Backup Schedule
```bash
# Cron job for daily backup
0 2 * * * /usr/local/bin/backup_db.sh
```

---

## CI/CD Pipeline

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Cloud Run
        run: |
          gcloud auth activate-service-account --key-file=${{ secrets.GCP_KEY }}
          gcloud builds submit --tag gcr.io/$PROJECT_ID/food-api
          gcloud run deploy food-api --image gcr.io/$PROJECT_ID/food-api
  
  android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - name: Build APK
        run: flutter build apk --release
      - name: Upload to Play Store
        uses: r0adkll/upload-google-play@v1
        with:
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          packageName: com.findyourfood.app
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
```

---

## Monitoring & Analytics

### Backend Monitoring (Prometheus + Grafana)

```python
# Add metrics
from prometheus_client import Counter, Histogram

requests_total = Counter('http_requests_total', 'Total requests')
request_duration = Histogram('http_request_duration_seconds', 'Request duration')
```

### Error Tracking (Sentry)

```python
import sentry_sdk

sentry_sdk.init(
    dsn="your-sentry-dsn",
    environment="production",
    traces_sample_rate=0.1,
)
```

### App Analytics

```dart
FirebaseAnalytics.instance.logEvent(
  name: 'food_analyzed',
  parameters: {
    'food_type': 'biryani',
    'confidence': 0.95,
  },
);
```

---

## Security Checklist

- [ ] HTTPS enabled (SSL certificate)
- [ ] API keys stored in environment variables
- [ ] Rate limiting configured
- [ ] CORS properly set
- [ ] SQL injection prevented (use ORM)
- [ ] XSS protection enabled
- [ ] CSRF tokens  (for web)
- [ ] Input validation on all endpoints
- [ ] Secrets not in version control
- [ ] Dependencies vulnerability scanned

---

## Performance Optimization

### Backend
- [ ] Database queries optimized
- [ ] Caching implemented (Redis)
- [ ] CDN for static files
- [ ] Gzip compression enabled
- [ ] Connection pooling

### Frontend
- [ ] Images optimized
- [ ] Code minified
- [ ] Lazy loading implemented
- [ ] App size < 50MB
- [ ] Startup time < 3 seconds

---

## Post-Deployment

### Monitoring
1. Check error rates in Sentry
2. Monitor API latency
3. Track user analytics
4. Review crash reports

### Support
1. Set up support email
2. Create FAQ documentation
3. Monitor app store reviews
4. Respond to user feedback

---

## Rollback Plan

### Backend
```bash
# Rollback to previous version
eb deploy --version previous-version-label
```

### Mobile
- Keep previous version available
- Use staged rollout (10% → 50% → 100%)
- Monitor crash rates before full rollout

---

## Cost Estimation

### Monthly Costs (1000 active users)
- Cloud hosting (Backend): $20-50
- Database (PostgreSQL): $15-30
- AI Model inference: $50-150
- Firebase (Analytics): Free tier
- Cloud storage: $5-10
- Domain & SSL: $15/year
- **Total**: ~$100-250/month

---

## Timeline

**Week 1-2**: Setup infrastructure
**Week 3**: Backend deployment
**Week 4**: App store submissions
**Week 5-6**: Beta testing
**Week 7**: Production launch

**Total**: ~2 months to production
