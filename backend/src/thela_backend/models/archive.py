from datetime import datetime, timezone
from typing import Any

from sqlalchemy import Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class ArchiveEntry(Base):
    """Archive entry model for cultural heritage items."""
    __tablename__ = "archive_entries"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    title: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    summary: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    era: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    category: Mapped[str | None] = mapped_column(String, nullable=True)
    thumbnail_url: Mapped[str] = mapped_column(Text, nullable=False)
    community_upvotes: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    registered_users: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    required_approval_percent: Mapped[float] = mapped_column(Numeric, nullable=False, default=0)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<ArchiveEntry(id={self.id!r}, category={self.category!r})>"
