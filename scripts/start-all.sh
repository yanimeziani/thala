#!/bin/bash
# Start the entire Thala development stack

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🚀 Starting Thala Development Stack"
echo "===================================="
echo ""

# Start Docker services
echo "📦 Starting Docker services (PostgreSQL, MeiliSearch, MinIO, Backend)..."
cd "${PROJECT_ROOT}"
docker-compose up -d

echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Check service health
echo ""
echo "🔍 Checking service status..."
docker-compose ps

echo ""
echo "✅ Development stack started!"
echo ""
echo "Services available at:"
echo "  • Backend API: http://localhost:8000"
echo "  • API Docs: http://localhost:8000/docs"
echo "  • PostgreSQL: localhost:5432"
echo "  • MeiliSearch: http://localhost:7700"
echo "  • MinIO Console: http://localhost:9001"
echo ""
echo "Next steps:"
echo "  • cd mobile && ./run_local.sh -- -d macos"
echo "  • cd web && npm run dev"
echo "  • cd admin && npm run dev"
echo ""
echo "To stop all services: docker-compose down"
