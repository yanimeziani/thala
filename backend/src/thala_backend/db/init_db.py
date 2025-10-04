from sqlalchemy.ext.asyncio import AsyncEngine

from .base import metadata


async def init_models(engine: AsyncEngine) -> None:
    """Create database tables at startup if they do not exist."""

    async with engine.begin() as conn:
        await conn.run_sync(metadata.create_all)
