# 🚀 Deploy Thala Backend to Dokploy

This guide will help you deploy the Thala backend to Dokploy in **under 5 minutes**.

## Prerequisites

- Dokploy instance running
- GitHub account connected to Dokploy
- Google OAuth Client ID ([Get one here](https://console.cloud.google.com/apis/credentials))

## Step 1: Create Dokploy Application

1. Log in to your Dokploy dashboard
2. Click **"Create Application"**
3. Select **"Docker Compose"** as deployment type
4. Connect your GitHub repository: `yanimeziani/thala`

## Step 2: Configure Settings

### Basic Settings
- **Branch**: `main`
- **Compose Path**: (leave empty or `.`)
- **Watch Paths**: `backend/` (optional - for auto-deploy on backend changes)

### Build Settings
- Everything else can be left as default

## Step 3: Add Environment Variables

Copy **ALL** content from [`backend/.env.example`](./backend/.env.example) and paste it into Dokploy's Environment Variables section.

Then, **only modify this one line**:

```env
GOOGLE_OAUTH_CLIENT_ID=YOUR_ACTUAL_CLIENT_ID_HERE
```

### 📋 Quick Copy Environment Variables

```env
# Copy everything below this line ⬇️

POSTGRES_USER=thala
POSTGRES_PASSWORD=YbgdwCSWmX7qtM6cXqAi
POSTGRES_DB=thala
POSTGRES_PORT=5432
DATABASE_URL=postgresql+asyncpg://thala:YbgdwCSWmX7qtM6cXqAi@db:5432/thala

JWT_SECRET=99d224e68e4abbd160bd52d52ba06590551668fe534128c605a66c3295a3ae40
ACCESS_TOKEN_EXPIRATION_MINUTES=60
REFRESH_TOKEN_EXPIRATION_MINUTES=20160
JWT_ALGORITHM=HS256

GOOGLE_OAUTH_CLIENT_ID=

AWS_REGION=us-east-1
AWS_S3_BUCKET=thala-media
AWS_ACCESS_KEY_ID=minioadmin
AWS_SECRET_ACCESS_KEY=J9LMxCtv5wVUkTpcdcrS
S3_ENDPOINT_URL=http://minio:9000

MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_API_KEY=122ff50f0b715b6713101746a90af6f25e4b074cc8d45bf0c73ff6c9d282b365
MEILISEARCH_INDEX_PREFIX=thala
MEILI_ENV=production
MEILI_NO_ANALYTICS=true

MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=J9LMxCtv5wVUkTpcdcrS
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001

CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080
RATE_LIMIT_ENABLED=true
RATE_LIMIT_REQUESTS_PER_MINUTE=60
RATE_LIMIT_BURST=10

APP_NAME=Thala Backend
API_V1_PREFIX=/api/v1
LOG_LEVEL=INFO
BACKEND_PORT=8000
```

### ⚠️ Don't Forget!
Replace the `GOOGLE_OAUTH_CLIENT_ID=` line with your actual Google OAuth Client ID.

## Step 4: Deploy

1. Click **"Save"** to save your environment variables
2. Click **"Deploy"** to start the deployment

Dokploy will:
- ✅ Clone your repository
- ✅ Build the Docker images
- ✅ Start PostgreSQL, MeiliSearch, MinIO, and Backend containers
- ✅ Run database migrations
- ✅ Start the FastAPI application

## Step 5: Verify Deployment

### Check Health Endpoint

Once deployed, access your application's health endpoint:

```bash
curl https://your-dokploy-url.com/health
```

Expected response:
```json
{
  "status": "healthy",
  "service": "thala-backend",
  "version": "1.0.0"
}
```

### API Documentation

Access the interactive API docs at:
- Swagger UI: `https://your-dokploy-url.com/docs`
- ReDoc: `https://your-dokploy-url.com/redoc`

## Production Checklist

Before going to production, update these environment variables:

### 🔒 Security
- [ ] Generate a new `JWT_SECRET`: `openssl rand -hex 32`
- [ ] Update `POSTGRES_PASSWORD` to a strong password
- [ ] Update `MEILISEARCH_API_KEY` to a new key

### 🌐 CORS
- [ ] Update `CORS_ALLOWED_ORIGINS` with your production domains
```env
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com,https://app.yourdomain.com
```

### 💾 Storage (Optional)
If using AWS S3 instead of MinIO:
```env
AWS_ACCESS_KEY_ID=your_aws_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
# Remove or comment out: S3_ENDPOINT_URL=http://minio:9000
```

### 🔍 Search (Optional)
For managed MeiliSearch:
```env
MEILISEARCH_HOST=https://your-meilisearch-url.com
MEILISEARCH_API_KEY=your_production_key
```

## Troubleshooting

### Build Fails
- Check that `Compose Path` is empty or set to `.`
- Verify all environment variables are set

### MeiliSearch Unhealthy
- This is expected and handled automatically
- Backend will connect once MeiliSearch starts

### Can't Access API
- Check Dokploy logs for errors
- Verify `GOOGLE_OAUTH_CLIENT_ID` is set correctly
- Ensure port 8000 is exposed in Dokploy settings

## Support

- [Backend README](./backend/README.md) - Full backend documentation
- [Deployment Guide](./backend/DEPLOYMENT.md) - Advanced deployment options
- [GitHub Issues](https://github.com/yanimeziani/thala/issues) - Report bugs

---

**That's it!** 🎉 Your Thala backend is now deployed and ready to use.
