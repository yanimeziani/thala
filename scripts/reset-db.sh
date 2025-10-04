#!/bin/bash
# Reset and migrate the database

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🗄️  Resetting Thala Database"
echo "============================"
echo ""

read -p "⚠️  This will delete all data. Continue? (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Cancelled."
  exit 0
fi

echo ""
echo "📦 Stopping backend service..."
cd "${PROJECT_ROOT}"
docker-compose stop backend

echo "🗑️  Dropping database..."
docker-compose exec db psql -U thala -d postgres -c "DROP DATABASE IF EXISTS thala;"
docker-compose exec db psql -U thala -d postgres -c "CREATE DATABASE thala;"

echo "🔄 Running migrations..."
docker-compose start backend
sleep 3
docker-compose exec backend alembic upgrade head

echo ""
echo "✅ Database reset complete!"
echo ""
echo "To seed sample data, run your seed script or load fixtures."
