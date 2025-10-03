"""Thela Backend - FastAPI application entry point."""

import logging
from contextlib import asynccontextmanager
from typing import AsyncGenerator

from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.middleware.gzip import GZipMiddleware
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from fastapi.responses import JSONResponse
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.util import get_remote_address

from .api.routes import api_router
from .core.config import settings
from .db.base import Base
from .db.session import engine

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


# Rate limiter setup
limiter = Limiter(
    key_func=get_remote_address,
    default_limits=[f"{settings.rate_limit_requests_per_minute}/minute"]
    if settings.rate_limit_enabled
    else [],
)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    """Application lifespan manager for startup and shutdown events."""
    # Startup
    logger.info("Starting Thala Backend...")

    # Create database tables automatically (plug-and-play)
    try:
        async with engine.begin() as conn:
            await conn.run_sync(Base.metadata.create_all)
        logger.info("Database schema initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize database schema: {e}")
        raise

    # Initialize MeiliSearch indexes if configured (optional)
    if settings.meilisearch_host:
        try:
            from .services.search_service import get_search_service
            search_service = get_search_service()
            await search_service.initialize_indexes()
            logger.info("MeiliSearch indexes initialized")
        except Exception as e:
            logger.warning(f"MeiliSearch initialization skipped: {e}")

    logger.info(f"Thela Backend started successfully on {settings.api_v1_prefix}")

    yield

    # Shutdown
    logger.info("Shutting down Thela Backend...")
    await engine.dispose()
    logger.info("Thela Backend shutdown complete")


def create_app() -> FastAPI:
    """Create and configure the FastAPI application."""

    app = FastAPI(
        title=settings.app_name,
        description="Thela - Amazigh cultural platform backend API",
        version="1.0.0",
        lifespan=lifespan,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
    )

    # Security middleware - Trusted Host
    # app.add_middleware(
    #     TrustedHostMiddleware,
    #     allowed_hosts=["*"],  # Configure based on your deployment
    # )

    # CORS middleware
    if settings.cors_allowed_origins:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_allowed_origins,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
            expose_headers=["*"],
        )
    else:
        # Development: Allow all origins
        app.add_middleware(
            CORSMiddleware,
            allow_origins=["*"],
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # Gzip compression
    app.add_middleware(GZipMiddleware, minimum_size=1000)

    # Rate limiting
    if settings.rate_limit_enabled:
        app.state.limiter = limiter
        app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
        logger.info(
            f"Rate limiting enabled: {settings.rate_limit_requests_per_minute} req/min"
        )

    # Global exception handler
    @app.exception_handler(Exception)
    async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
        logger.error(f"Unhandled exception: {exc}", exc_info=True)
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "detail": "Internal server error",
                "type": "internal_error",
            },
        )

    # Health check endpoint
    @app.get("/health", tags=["Health"])
    async def health_check() -> dict:
        """Health check endpoint for monitoring."""
        return {
            "status": "healthy",
            "service": "thela-backend",
            "version": "1.0.0",
        }

    # Include API routes
    app.include_router(api_router, prefix=settings.api_v1_prefix)

    return app


# Application instance
app = create_app()
