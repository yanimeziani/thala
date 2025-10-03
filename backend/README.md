# Thala Backend

FastAPI-based backend service for the Thala platform - an Amazigh cultural platform for stories, music, events, and community.

## Features

- 🔐 **Google OAuth Authentication** (JWT tokens)
- 📹 **Video Feed** with engagement (likes, comments, shares)
- 🎵 **Music Library** with bilingual metadata
- 📅 **Cultural Events** management
- 💬 **Messaging System** with threads
- 🏛️ **Community Profiles** and spaces
- 📚 **Archive Entries** for cultural heritage
- 🔍 **Full-text Search** with MeiliSearch
- ☁️ **S3 Media Storage** for videos, images, and audio
- 🌍 **Bilingual Support** (English/French)
- 🚀 **Docker Compose** ready for easy deployment

## Tech Stack

- **Framework**: FastAPI 0.111+
- **Database**: PostgreSQL 16+ with asyncpg
- **ORM**: SQLAlchemy 2.0 (async)
- **Search**: MeiliSearch 1.6+
- **Storage**: S3/MinIO
- **Auth**: Google OAuth + JWT
- **Migrations**: Alembic
- **Rate Limiting**: SlowAPI
- **Validation**: Pydantic v2

## Project Structure

```
backend/
├── src/thala_backend/
│   ├── api/
│   │   ├── routes/          # API endpoints
│   │   │   ├── auth.py      # Authentication
│   │   │   ├── videos.py    # Video feed
│   │   │   ├── music.py     # Music library
│   │   │   ├── events.py    # Cultural events
│   │   │   ├── community.py # Community profiles
│   │   │   ├── archive.py   # Archive entries
│   │   │   ├── messages.py  # Messaging
│   │   │   ├── users.py     # User profiles
│   │   │   ├── search.py    # Search
│   │   │   └── upload.py    # Media uploads
│   │   └── deps.py          # Dependencies
│   ├── core/
│   │   ├── config.py        # Configuration
│   │   └── security.py      # Security utilities
│   ├── db/
│   │   ├── base.py          # SQLAlchemy base
│   │   └── session.py       # Database session
│   ├── models/              # SQLAlchemy models
│   │   ├── user.py
│   │   ├── media.py         # Videos, music, effects
│   │   ├── message.py
│   │   ├── community.py
│   │   ├── archive.py
│   │   ├── event.py
│   │   └── content.py
│   ├── schemas/             # Pydantic schemas
│   │   ├── auth.py
│   │   ├── video.py
│   │   ├── music.py
│   │   ├── event.py
│   │   ├── community.py
│   │   ├── archive.py
│   │   ├── message.py
│   │   └── user.py
│   ├── services/            # Business logic
│   │   ├── auth_service.py      # Authentication
│   │   ├── storage_service.py   # S3 storage
│   │   └── search_service.py    # MeiliSearch
│   └── main.py              # Application entry point
├── alembic/                 # Database migrations
├── docker-compose.yml       # Docker services
├── Dockerfile               # Container image
├── .env.example             # Environment template
├── alembic.ini              # Alembic config
├── nginx.conf               # Nginx config
└── pyproject.toml           # Python dependencies
```

## Quick Start

### Prerequisites

- Python 3.11+
- PostgreSQL 16+ (or use Docker Compose)
- Google OAuth credentials ([Get them here](https://console.cloud.google.com/))
- (Optional) MeiliSearch for search functionality
- (Optional) S3-compatible storage (AWS S3, MinIO, etc.)

### 1. Clone and Setup

```bash
cd backend
cp .env.example .env
# Edit .env with your actual credentials
```

### 2. Install Dependencies

```bash
# Using uv (recommended)
uv pip install -e .

# Or using pip
pip install -e .
```

### 3. Database Setup

```bash
# Run migrations
alembic upgrade head

# Or let the app create tables automatically on startup
```

### 4. Run Development Server

```bash
uvicorn thala_backend.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at:
- **API**: http://localhost:8000/api/v1
- **Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **Health**: http://localhost:8000/health

## Docker Deployment (Recommended for Dokploy)

### Development (All Services)

```bash
docker-compose up -d
```

This starts:
- **backend**: FastAPI app on port 8000
- **db**: PostgreSQL on port 5432
- **meilisearch**: Search engine on port 7700
- **minio**: S3-compatible storage on ports 9000 (API) and 9001 (Console)

### Production (with Nginx)

```bash
docker-compose --profile production up -d
```

This adds:
- **nginx**: Reverse proxy on ports 80/443

### Dokploy Deployment

1. **Push to Git repository**
2. **Create Dokploy app** pointing to your repo
3. **Set environment variables** from `.env.example`
4. **Deploy** using `docker-compose.yml`

The compose file is production-ready with:
- Health checks for all services
- Persistent volumes for data
- Proper networking
- Restart policies
- Non-root user for security

## Environment Variables

### Required

```bash
DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/db
GOOGLE_OAUTH_CLIENT_ID=your_client_id.apps.googleusercontent.com
JWT_SECRET=your_very_secure_secret_key
```

### Optional (with defaults)

```bash
# MeiliSearch
MEILISEARCH_HOST=http://localhost:7700
MEILISEARCH_API_KEY=your_master_key

# S3 Storage
AWS_REGION=us-east-1
AWS_S3_BUCKET=thala-media
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret
S3_ENDPOINT_URL=http://minio:9000  # For MinIO

# CORS
CORS_ALLOWED_ORIGINS=http://localhost:3000,https://yourdomain.com

# Rate Limiting
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS_PER_MINUTE=60
```

See `.env.example` for complete list.

## API Endpoints

### Authentication (Google OAuth only)
- `POST /api/v1/auth/google` - Sign in with Google
- `POST /api/v1/auth/refresh` - Refresh tokens
- `GET /api/v1/auth/me` - Current user profile

### Videos
- `GET /api/v1/videos` - List videos (feed)
- `GET /api/v1/videos/{id}` - Get video details
- `POST /api/v1/videos` - Create video
- `POST /api/v1/videos/{id}/like` - Toggle like
- `POST /api/v1/videos/{id}/comments` - Add comment
- `POST /api/v1/videos/{id}/share` - Record share
- `POST /api/v1/videos/{id}/follow` - Follow creator

### Music
- `GET /api/v1/music` - List music tracks
- `GET /api/v1/music/{id}` - Get track details
- `POST /api/v1/music` - Create track

### Events
- `GET /api/v1/events` - List cultural events
- `GET /api/v1/events/{id}` - Get event details
- `POST /api/v1/events` - Create event

### Community
- `GET /api/v1/community/profiles` - List community profiles
- `POST /api/v1/community/views` - Record view
- `POST /api/v1/community/host-requests` - Submit host request

### Archive
- `GET /api/v1/archive` - List archive entries
- `POST /api/v1/archive/{id}/upvote` - Upvote entry

### Messages
- `GET /api/v1/messages/threads` - List message threads
- `POST /api/v1/messages/threads` - Create thread
- `POST /api/v1/messages/threads/{id}/messages` - Send message

### Search
- `GET /api/v1/search` - Universal search
- `GET /api/v1/search/videos` - Search videos
- `GET /api/v1/search/music` - Search music

### Upload
- `POST /api/v1/upload/video` - Upload video
- `POST /api/v1/upload/image` - Upload image
- `GET /api/v1/upload/presigned-url` - Get presigned URL

Full API documentation at `/docs` when server is running.

## Database Migrations

```bash
# Create a new migration
alembic revision --autogenerate -m "description"

# Apply migrations
alembic upgrade head

# Rollback one migration
alembic downgrade -1

# View migration history
alembic history
```

## Development

### Code Quality

```bash
# Install dev dependencies
pip install -e ".[dev]"

# Run tests (when available)
pytest

# Format code
ruff check --fix .
```

### Database Console

```bash
# Connect to PostgreSQL
psql $DATABASE_URL

# Or with Docker
docker exec -it thala-postgres psql -U thala -d thala
```

### MeiliSearch Console

Visit http://localhost:7700 or use the MeiliSearch dashboard.

### MinIO Console

Visit http://localhost:9001 (credentials: minioadmin/minioadmin)

## Security Considerations

- 🔑 **Change JWT_SECRET** in production (use 32+ random characters)
- 🔐 **Never commit `.env`** file to version control
- 🌐 **Configure CORS** properly for production domains
- 🚦 **Enable rate limiting** to prevent abuse
- 🔒 **Use HTTPS** in production (configure nginx SSL)
- 👤 **Review permissions** for S3 buckets
- 📝 **Monitor logs** for suspicious activity

## Troubleshooting

### Database Connection Error
```bash
# Check DATABASE_URL format
# Should be: postgresql+asyncpg://user:pass@host:5432/database
# Check PostgreSQL is running:
docker-compose ps db
```

### Google OAuth Error
```bash
# Verify GOOGLE_OAUTH_CLIENT_ID is set
# Check redirect URIs in Google Console match your domain
```

### MeiliSearch Not Working
```bash
# Check MeiliSearch is running
docker-compose ps meilisearch

# Verify MEILISEARCH_HOST and MEILISEARCH_API_KEY
# MeiliSearch is optional - app works without it
```

### S3 Upload Failing
```bash
# Check AWS credentials or MinIO setup
# Verify bucket exists
# For MinIO: Create bucket via console at localhost:9001
```

## Production Checklist

- [ ] Set strong `JWT_SECRET` (32+ characters)
- [ ] Configure production `DATABASE_URL`
- [ ] Set up proper CORS origins
- [ ] Enable HTTPS with SSL certificates
- [ ] Configure backup strategy for PostgreSQL
- [ ] Set up monitoring and logging
- [ ] Review rate limiting settings
- [ ] Configure S3 bucket policies
- [ ] Set up MeiliSearch (optional)
- [ ] Test health check endpoint
- [ ] Configure nginx reverse proxy
- [ ] Review Docker resource limits

## License

MIT

## Support

For issues and questions:
- Create an issue in the repository
- Check existing issues for solutions
- Review API documentation at `/docs`

---

Built with ❤️ for the Amazigh community
