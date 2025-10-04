# Thala

A TikTok-inspired cultural platform for Amazigh stories, music, and community.

## 📁 Project Structure

```
Thala/
├── mobile/              # Flutter app (iOS/Android/Web/Desktop)
├── backend/             # FastAPI backend + PostgreSQL
├── web/                 # Next.js landing page
├── admin/               # Next.js admin dashboard
├── docs/                # Documentation
├── scripts/             # Development scripts
└── docker-compose.yml   # Local development stack
```

## 🚀 Quick Start

### Prerequisites
- **Flutter** 3.10+ (for mobile app)
- **Node.js** 18+ (for web/admin)
- **Python** 3.11+ (for backend)
- **Docker** (for local services)

### Start Local Development Stack

```bash
# Start all services (PostgreSQL, MeiliSearch, MinIO, Backend)
docker-compose up -d

# Check service health
docker-compose ps
```

Services will be available at:
- **Backend API**: http://localhost:8000
- **PostgreSQL**: localhost:5432
- **MeiliSearch**: http://localhost:7700
- **MinIO Console**: http://localhost:9001

### Run Individual Apps

**Mobile App:**
```bash
cd mobile
flutter pub get
./run_local.sh -- -d macos    # Uses local backend
# OR
flutter run -d macos           # Uses sample data
```

**Landing Page:**
```bash
cd web
npm install
npm run dev                    # http://localhost:3000
```

**Admin Dashboard:**
```bash
cd admin
npm install
npm run dev                    # http://localhost:3000
```

**Backend (standalone):**
```bash
cd backend
uv pip install -e .
uvicorn thala_backend.main:app --reload
```

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** → Quick reference (redirects to docs/)
- **[docs/CLAUDE.md](docs/CLAUDE.md)** → Full development guide
- **[DOKPLOY.md](DOKPLOY.md)** → Deployment instructions
- **[mobile/BACKEND_INTEGRATION.md](mobile/BACKEND_INTEGRATION.md)** → Backend integration guide

## 🏗️ Architecture

### Mobile App (Flutter)
- **Feature-based structure** with clean separation of concerns
- **Graceful degradation** - works offline with sample data
- **Bilingual support** (English/French) throughout
- **Custom shaders** for visual effects (Impeller-based)
- **Provider** for state management

### Backend (FastAPI)
- **PostgreSQL** for data persistence
- **Google OAuth** authentication with JWT
- **S3/MinIO** for media storage
- **Alembic** for database migrations
- **MeiliSearch** integration for fast search

### Web/Admin (Next.js)
- **App Router** with TypeScript
- **Turbopack** for fast builds
- **Tailwind CSS** for styling
- **i18n** for localization

## 🔧 Common Tasks

**Run tests:**
```bash
cd mobile && flutter test
cd backend && pytest
```

**Build for production:**
```bash
cd mobile && flutter build apk          # Android
cd mobile && flutter build ios          # iOS
cd mobile && flutter build web          # Web
cd web && npm run build                 # Landing page
cd admin && npm run build               # Admin dashboard
```

**Database migrations:**
```bash
cd backend
alembic revision --autogenerate -m "description"
alembic upgrade head
```

**View logs:**
```bash
docker-compose logs -f backend
docker-compose logs -f db
```

## 🌍 Environment Variables

Each component requires its own `.env.local` file (see component READMEs):

- **mobile/.env.local** - Backend URL, OAuth client ID
- **backend/.env** - Database, JWT secret, AWS/S3 credentials
- **web/.env.local** - API endpoints, public keys
- **admin/.env.local** - API endpoints, admin credentials

**Never commit `.env.local` files** - they're gitignored.

## 🤝 Contributing

This is a solo project optimized for rapid iteration. Key principles:

- ✅ **Feature-based organization** - easy to navigate
- ✅ **Clear separation** - each component is independent
- ✅ **Graceful degradation** - components work standalone
- ✅ **Consistent patterns** - shared conventions across stack
- ✅ **Documentation first** - guides live with code

## 📄 License

Proprietary - All rights reserved

## 🔗 Links

- **Production**: https://thala.app
- **API Docs**: http://localhost:8000/docs (when running locally)
