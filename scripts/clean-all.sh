#!/bin/bash
# Clean all build artifacts across the monorepo

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🧹 Cleaning Thala Build Artifacts"
echo "=================================="
echo ""

# Clean Flutter
if [ -d "${PROJECT_ROOT}/mobile" ]; then
  echo "📱 Cleaning Flutter build artifacts..."
  cd "${PROJECT_ROOT}/mobile"
  flutter clean
  rm -rf .dart_tool/
  rm -rf build/
  echo "   ✓ Flutter cleaned"
fi

# Clean web
if [ -d "${PROJECT_ROOT}/web" ]; then
  echo "🌐 Cleaning web build artifacts..."
  cd "${PROJECT_ROOT}/web"
  rm -rf .next/
  rm -rf node_modules/.cache/
  echo "   ✓ Web cleaned"
fi

# Clean admin
if [ -d "${PROJECT_ROOT}/admin" ]; then
  echo "⚙️  Cleaning admin build artifacts..."
  cd "${PROJECT_ROOT}/admin"
  rm -rf .next/
  rm -rf node_modules/.cache/
  echo "   ✓ Admin cleaned"
fi

# Clean Python cache
if [ -d "${PROJECT_ROOT}/backend" ]; then
  echo "🐍 Cleaning Python cache..."
  find "${PROJECT_ROOT}/backend" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
  find "${PROJECT_ROOT}/backend" -type f -name "*.pyc" -delete 2>/dev/null || true
  echo "   ✓ Python cache cleaned"
fi

echo ""
echo "✅ All build artifacts cleaned!"
echo ""
echo "To rebuild:"
echo "  • cd mobile && flutter pub get"
echo "  • cd web && npm install"
echo "  • cd admin && npm install"
echo "  • cd backend && uv pip install -e ."
