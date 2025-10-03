# Thala Backend - Deployment Guide

This guide covers deploying the Thala backend to Dokploy or any Docker-based platform.

## Quick Deploy to Dokploy

### 1. Prerequisites
- Git repository with this backend code
- Dokploy account and instance
- Google OAuth Client ID ([Get one here](https://console.cloud.google.com/))

### 2. Environment Setup

In Dokploy, add these environment variables:

```bash
# Required
DATABASE_URL=postgresql+asyncpg://username:password@host:5432/thala
GOOGLE_OAUTH_CLIENT_ID=your_id.apps.googleusercontent.com
JWT_SECRET=generate_with_openssl_rand_hex_32

# Optional (MeiliSearch)
MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_API_KEY=your_master_key

# Optional (S3)
AWS_REGION=us-east-1
AWS_S3_BUCKET=thala-media
AWS_ACCESS_KEY_ID=your_key
AWS_SECRET_ACCESS_KEY=your_secret

# CORS
CORS_ALLOWED_ORIGINS=https://yourdomain.com,https://www.yourdomain.com
```

### 3. Deploy

1. Create new Dokploy application
2. Connect to your Git repository
3. Select `backend` as the build context
4. Choose "Docker Compose" as deployment type
5. Add environment variables from above
6. Click "Deploy"

Dokploy will:
- Build the Docker image
- Start PostgreSQL, MeiliSearch, and MinIO
- Run database migrations
- Start the FastAPI application

### 4. Verify Deployment

Check health endpoint:
```bash
curl https://your-domain.com/health
```

Should return:
```json
{
  "status": "healthy",
  "service": "thala-backend",
  "version": "1.0.0"
}
```

## Manual Docker Compose Deployment

### 1. Clone Repository

```bash
git clone your-repo-url
cd backend
```

### 2. Configure Environment

```bash
cp .env.example .env
nano .env  # Edit with your values
```

### 3. Start Services

```bash
# Development
docker-compose up -d

# Production (with Nginx)
docker-compose --profile production up -d
```

### 4. Initialize Database

```bash
# Run migrations
docker-compose exec backend alembic upgrade head

# Or tables are auto-created on startup
```

### 5. Create MinIO Bucket (if using MinIO)

```bash
# Open MinIO console: http://localhost:9001
# Login: minioadmin / minioadmin
# Create bucket named: thala-media
# Set access policy to public or custom
```

## Production Optimizations

### 1. Database

```bash
# Use managed PostgreSQL (AWS RDS, DigitalOcean, etc.)
DATABASE_URL=postgresql+asyncpg://user:pass@managed-db-host:5432/thala

# Or configure PostgreSQL with connection pooling:
# Max connections: 100
# Shared buffers: 256MB
# Effective cache size: 1GB
```

### 2. Storage

```bash
# Use AWS S3 for production storage
AWS_REGION=us-east-1
AWS_S3_BUCKET=thala-production-media
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

# Or DigitalOcean Spaces
S3_ENDPOINT_URL=https://nyc3.digitaloceanspaces.com
AWS_S3_BUCKET=thala-media
```

### 3. Scaling

```bash
# Multiple backend instances (update docker-compose.yml)
backend:
  deploy:
    replicas: 3
    resources:
      limits:
        cpus: '1'
        memory: 1G
      reservations:
        cpus: '0.5'
        memory: 512M
```

### 4. Monitoring

Add health checks to monitoring tools:
```bash
# Health endpoint
https://your-domain.com/health

# Database connection check
docker-compose exec backend python -c "from thala_backend.db.session import engine; import asyncio; asyncio.run(engine.connect())"
```

### 5. Backups

PostgreSQL backup:
```bash
# Daily backup
docker-compose exec db pg_dump -U thala thala > backup_$(date +%Y%m%d).sql

# Automated with cron
0 2 * * * cd /path/to/backend && docker-compose exec -T db pg_dump -U thala thala | gzip > /backups/thala_$(date +\%Y\%m\%d).sql.gz
```

## SSL/HTTPS Setup

### Option 1: Let's Encrypt with Certbot

```bash
# Install certbot
apt-get install certbot python3-certbot-nginx

# Generate certificate
certbot --nginx -d api.yourdomain.com

# Auto-renewal (add to cron)
0 0 * * * certbot renew --quiet
```

### Option 2: Manual SSL Certificates

```bash
# Place certificates
mkdir -p backend/ssl
cp fullchain.pem backend/ssl/cert.pem
cp privkey.pem backend/ssl/key.pem

# Update docker-compose.yml nginx volumes
volumes:
  - ./ssl:/etc/nginx/ssl:ro

# Uncomment HTTPS section in nginx.conf
```

## Troubleshooting

### Backend Won't Start

```bash
# Check logs
docker-compose logs backend

# Common issues:
# 1. DATABASE_URL incorrect
# 2. Missing JWT_SECRET
# 3. Invalid GOOGLE_OAUTH_CLIENT_ID
```

### Database Connection Errors

```bash
# Verify PostgreSQL is running
docker-compose ps db

# Test connection
docker-compose exec db psql -U thala -d thala -c "SELECT 1;"

# Check DATABASE_URL format
# Correct: postgresql+asyncpg://user:pass@host:5432/db
```

### Upload Failures

```bash
# Check S3/MinIO credentials
docker-compose logs minio

# Verify bucket exists
# MinIO: http://localhost:9001
# AWS: Check S3 console

# Test upload endpoint
curl -X POST http://localhost:8000/api/v1/upload/image \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "file=@test.jpg"
```

### MeiliSearch Not Indexing

```bash
# Check MeiliSearch is running
docker-compose ps meilisearch

# View logs
docker-compose logs meilisearch

# Manually trigger index sync (when implemented)
curl -X POST http://localhost:8000/api/v1/admin/sync-search \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN"
```

## Performance Tuning

### Backend

```dockerfile
# Increase workers (Dockerfile)
CMD ["uvicorn", "thala_backend.main:app",
     "--host", "0.0.0.0",
     "--port", "8000",
     "--workers", "4",
     "--limit-concurrency", "1000",
     "--backlog", "2048"]
```

### PostgreSQL

```yaml
# docker-compose.yml
db:
  command:
    - "postgres"
    - "-c"
    - "max_connections=200"
    - "-c"
    - "shared_buffers=512MB"
    - "-c"
    - "effective_cache_size=2GB"
    - "-c"
    - "work_mem=16MB"
```

### Nginx

```nginx
# nginx.conf
worker_processes auto;
events {
    worker_connections 4096;
}

http {
    # Gzip
    gzip on;
    gzip_types text/plain application/json;

    # Caching
    proxy_cache_path /var/cache/nginx levels=1:2
                     keys_zone=api_cache:10m
                     max_size=1g
                     inactive=60m;
}
```

## Monitoring Setup

### 1. Application Logs

```bash
# View real-time logs
docker-compose logs -f backend

# Export logs to file
docker-compose logs backend > logs/backend.log

# Use log aggregation (optional)
# - Papertrail
# - Datadog
# - New Relic
```

### 2. Metrics

```bash
# Add Prometheus metrics (future enhancement)
pip install prometheus-fastapi-instrumentator

# In main.py
from prometheus_fastapi_instrumentator import Instrumentator
Instrumentator().instrument(app).expose(app)
```

### 3. Uptime Monitoring

Set up external monitoring:
- [UptimeRobot](https://uptimerobot.com)
- [Pingdom](https://www.pingdom.com)
- [StatusCake](https://www.statuscake.com)

Monitor: `https://your-domain.com/health`

## Security Hardening

### 1. Firewall Rules

```bash
# Allow only necessary ports
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp  # SSH
ufw enable

# Deny direct access to services
# Only nginx should be publicly accessible
```

### 2. Rate Limiting

Already configured in the application:
- 60 requests per minute per IP (default)
- Configurable via `RATE_LIMIT_REQUESTS_PER_MINUTE`

Additional nginx rate limiting in `nginx.conf`.

### 3. Secrets Management

```bash
# Use Docker secrets or environment variable providers
# Never commit .env to Git

# Example with Docker secrets:
docker secret create jwt_secret jwt_secret.txt
docker service update --secret-add jwt_secret backend
```

### 4. Database Security

```bash
# Use strong passwords
# Restrict network access
# Enable SSL for database connections
DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/db?ssl=require
```

## Rollback Procedure

```bash
# 1. Keep previous Docker image
docker tag thala-backend:latest thala-backend:backup

# 2. If deployment fails, rollback
docker-compose down
docker tag thala-backend:backup thala-backend:latest
docker-compose up -d

# 3. Rollback database migrations
docker-compose exec backend alembic downgrade -1
```

## Maintenance

### Updates

```bash
# Pull latest code
git pull origin main

# Rebuild and restart
docker-compose build backend
docker-compose up -d backend

# Run new migrations
docker-compose exec backend alembic upgrade head
```

### Database Maintenance

```bash
# Vacuum database
docker-compose exec db vacuumdb -U thala -d thala -v

# Analyze tables
docker-compose exec db psql -U thala -d thala -c "ANALYZE;"
```

## Support

For deployment issues:
1. Check logs: `docker-compose logs`
2. Review health endpoint: `/health`
3. Verify environment variables
4. Consult README.md for configuration details

---

Happy Deploying! 🚀
