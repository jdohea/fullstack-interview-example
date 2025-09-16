#!/bin/bash

# Change to project root directory
cd "$(dirname "$0")/.."

echo "🐘 Starting PostgreSQL Database for Local Development..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Start only the PostgreSQL service
echo "🔧 Starting PostgreSQL service..."
docker-compose up -d postgres

# Wait for PostgreSQL to be ready
echo "⏳ Waiting for PostgreSQL to be ready..."
until docker-compose exec -T postgres pg_isready -U postgres >/dev/null 2>&1; do
    echo "   Still waiting for PostgreSQL..."
    sleep 2
done

echo "✅ PostgreSQL is ready!"

# Run database migrations if needed
echo "📊 Running database migrations..."
cd backend
python -m alembic upgrade head 2>/dev/null || echo "⚠️  Migrations may need to be run manually"

# Seed the database if tables are empty
echo "🌱 Seeding database with sample data..."
python seed_data.py 2>/dev/null || echo "⚠️  Database seeding may need to be run manually"

cd ..

echo ""
echo "✅ Database setup complete!"
echo "🔗 PostgreSQL Connection: postgresql://postgres:postgres@localhost:5432/workflow_builder"
echo ""
echo "📋 To stop the database, run: docker-compose stop postgres"
echo "📋 To remove database data, run: docker-compose down -v"
