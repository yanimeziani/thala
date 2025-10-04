#!/bin/bash
# Quick script to run the Flutter app with local backend

echo "🚀 Starting Thala app with local backend..."
echo ""
echo "Make sure your backend is running at http://localhost:8000"
echo "If not, run: cd ../backend && uvicorn thala_backend.main:app --reload"
echo ""

flutter run -d macos --dart-define THELA_API_URL=http://localhost:8000
