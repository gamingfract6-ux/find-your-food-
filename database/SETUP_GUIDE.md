# Database Setup Guide

## PostgreSQL Installation

### Windows
```bash
# Download from https://www.postgresql.org/download/windows/
# Or use chocolatey
choco install postgresql
```

### Initialize Database
```sql
-- Create database
CREATE DATABASE find_your_food_db;

-- Create user
CREATE USER food_app_user WITH PASSWORD 'your_secure_password';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE find_your_food_db TO food_app_user;
```

## Database Migrations

### Using Alembic
```bash
# Install
pip install alembic

# Initialize
alembic init migrations

# Create migration
alembic revision --autogenerate -m "Initial tables"

# Apply migration
alembic upgrade head
```

### Migration Script
```python
# migrations/versions/001_initial.py
"""Initial tables

Revision ID: 001
"""

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

def upgrade():
    # Users table
    op.create_table(
        'users',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('email', sa.String(255), unique=True, nullable=False),
        sa.Column('google_id', sa.String(255), unique=True, nullable=False),
        sa.Column('name', sa.String(255)),
        sa.Column('profile_picture', sa.String(500)),
        sa.Column('age', sa.Integer()),
        sa.Column('gender', sa.String(20)),
        sa.Column('height', sa.Float()),
        sa.Column('weight', sa.Float()),
        sa.Column('fitness_goal', sa.String(50)),
        sa.Column('dietary_preference', sa.String(50)),
        sa.Column('allergies', postgresql.ARRAY(sa.String())),
        sa.Column('region', sa.String(50)),
        sa.Column('is_premium', sa.Boolean(), default=False),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.func.now()),
    )
    
    # Food scans table
    op.create_table(
        'food_scans',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('user_id', sa.Integer(), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('image_url', sa.String(500), nullable=False),
        sa.Column('detected_foods', postgresql.JSONB),
        sa.Column('total_calories', sa.Float()),
        sa.Column('total_protein', sa.Float()),
        sa.Column('total_carbs', sa.Float()),
        sa.Column('total_fats', sa.Float()),
        sa.Column('total_fiber', sa.Float()),
        sa.Column('total_sugar', sa.Float()),
        sa.Column('total_sodium', sa.Float()),
        sa.Column('health_score', sa.String(5)),
        sa.Column('dietary_tags', postgresql.ARRAY(sa.String())),
        sa.Column('ai_insights', sa.Text()),
        sa.Column('meal_type', sa.String(20)),
        sa.Column('analysis_time', sa.Float()),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    
    # Food items table (nutrition database)
    op.create_table(
        'food_items',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name', sa.String(255), unique=True, nullable=False),
        sa.Column('calories_per_100g', sa.Float()),
        sa.Column('protein_per_100g', sa.Float()),
        sa.Column('carbs_per_100g', sa.Float()),
        sa.Column('fats_per_100g', sa.Float()),
        sa.Column('fiber_per_100g', sa.Float()),
        sa.Column('sugar_per_100g', sa.Float()),
        sa.Column('sodium_per_100g', sa.Float()),
        sa.Column('category', sa.String(50)),
        sa.Column('is_vegetarian', sa.Boolean()),
        sa.Column('is_vegan', sa.Boolean()),
        sa.Column('common_allergens', postgresql.ARRAY(sa.String())),
    )
    
    # Create indexes
    op.create_index('idx_users_email', 'users', ['email'])
    op.create_index('idx_users_google_id', 'users', ['google_id'])
    op.create_index('idx_food_scans_user_id', 'food_scans', ['user_id'])
    op.create_index('idx_food_scans_created_at', 'food_scans', ['created_at'])

def downgrade():
    op.drop_table('food_items')
    op.drop_table('food_scans')
    op.drop_table('users')
```

## Populate Food Items

### Seed Script
```python
# scripts/seed_food_items.py
import json
from backend.app.database import SessionLocal
from backend.app.models.food_item import FoodItem

def seed_food_items():
    db = SessionLocal()
    
    # Load from JSON
    with open('data/food_nutrition.json', 'r') as f:
        foods = json.load(f)
    
    for food_data in foods:
        food_item = FoodItem(**food_data)
        db.add(food_item)
    
    db.commit()
    print(f"Seeded {len(foods)} food items")

if __name__ == '__main__':
    seed_food_items()
```

### Sample Data
```json
[
  {
    "name": "biryani",
    "calories_per_100g": 200,
    "protein_per_100g": 6,
    "carbs_per_100g": 30,
    "fats_per_100g": 7,
    "fiber_per_100g": 2,
    "sugar_per_100g": 1,
    "sodium_per_100g": 400,
    "category": "main_dish",
    "is_vegetarian": false,
    "is_vegan": false,
    "common_allergens": []
  }
]
```

## Database Optimization

### Add Partitioning (for large datasets)
```sql
-- Partition food_scans by month
CREATE TABLE food_scans_2024_01 PARTITION OF food_scans
    FOR VALUES FROM ('2024-01-01') TO ('2024-02-01');
```

### Performance Tuning
```sql
-- Analyze tables
ANALYZE users;
ANALYZE food_scans;

-- Create materialized view for analytics
CREATE MATERIALIZED VIEW user_stats AS
SELECT 
    user_id,
    COUNT(*) as total_scans,
    AVG(total_calories) as avg_calories,
    SUM(total_calories) as total_calories
FROM food_scans
GROUP BY user_id;

-- Refresh periodically
REFRESH MATERIALIZED VIEW user_stats;
```

## Backup Strategy

### Automated Backups
```bash
#!/bin/bash
# backup.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups"
DB_NAME="find_your_food_db"

pg_dump $DB_NAME | gzip > $BACKUP_DIR/backup_$DATE.sql.gz

# Keep only last 7 days
find $BACKUP_DIR -name "backup_*.sql.gz" -mtime +7 -delete
```

### Restore
```bash
gunzip < backup_20240204.sql.gz | psql find_your_food_db
```

## Connection Pooling

### Using PgBouncer
```ini
# pgbouncer.ini
[databases]
find_your_food_db = host=localhost port=5432

[pgbouncer]
pool_mode = transaction
max_client_conn = 100
default_pool_size = 20
```

## Monitoring

### Install pg_stat_statements
```sql
CREATE EXTENSION pg_stat_statements;

-- View slow queries
SELECT 
    query,
    calls,
    mean_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;
```

## Checklist

- [ ] PostgreSQL installed
- [ ] Database created
- [ ] Migrations run
- [ ] Food items seeded
- [ ] Indexes created
- [ ] Backup script configured
- [ ] Connection pooling setup
- [ ] Monitoring enabled
