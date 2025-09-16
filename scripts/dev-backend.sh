#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "🐍 Starting Backend for Local Development..."

# Check if we're in the right directory
if [ ! -f "backend/requirements.txt" ]; then
    echo "❌ Please run this script from the project root directory"
    exit 1
fi

# Check if PostgreSQL is running (either in Docker or locally)
echo "🔍 Checking PostgreSQL connection..."
if ! python -c "
import psycopg2
try:
    conn = psycopg2.connect('postgresql://postgres:postgres@localhost:5432/workflow_builder')
    conn.close()
    print('✅ PostgreSQL connection successful')
except Exception as e:
    print('❌ PostgreSQL connection failed:', e)
    print('💡 Make sure to run: ./scripts/dev-db.sh')
    exit(1)
" 2>/dev/null; then
    echo "❌ Cannot connect to PostgreSQL database"
    echo "💡 Make sure to run: ./scripts/dev-db.sh first"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "backend/venv" ]; then
    echo "📦 Creating Python virtual environment..."
    cd backend
    python -m venv venv
    cd ..
fi

# Activate virtual environment and install dependencies
echo "📦 Installing Python dependencies..."
cd backend
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt > /dev/null 2>&1

# Set environment variables for local development
export DATABASE_URL="postgresql://postgres:postgres@localhost:5432/workflow_builder"
export JWT_SECRET="dev-secret-key-change-in-production"

# Run database migrations
echo "📊 Running database migrations..."
python -m alembic upgrade head

# Seed database if needed
echo "🌱 Ensuring database has sample data..."
python seed_data.py

echo ""
echo "✅ Backend setup complete!"
echo "🚀 Starting FastAPI server on http://localhost:8080"
echo "📚 API Documentation: http://localhost:8080/docs"
echo ""
echo "💡 Demo credentials:"
echo "   Email: demo@example.com"
echo "   Password: demo123"
echo ""
echo "📋 Press Ctrl+C to stop the server"
echo ""

# Start the FastAPI server
uvicorn app.main:app --host 0.0.0.0 --port 8080 --reload
