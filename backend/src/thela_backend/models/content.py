from datetime import datetime, timezone

from sqlalchemy import ARRAY, Boolean, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class ContentProfile(Base):
    """Content profile model for cultural content categorization and filtering."""
    __tablename__ = "content_profiles"

    content_id: Mapped[str] = mapped_column(String, primary_key=True)
    cultural_families: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    regions: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    languages: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    topics: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    energy: Mapped[str | None] = mapped_column(String, nullable=True)
    sacred_level: Mapped[str | None] = mapped_column(String, nullable=True)
    is_guardian_approved: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<ContentProfile(content_id={self.content_id!r}, is_guardian_approved={self.is_guardian_approved})>"
