#!/bin/bash
# Stop all Thala development services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🛑 Stopping Thala Development Stack"
echo "===================================="
echo ""

cd "${PROJECT_ROOT}"
docker-compose down

echo ""
echo "✅ All services stopped!"
