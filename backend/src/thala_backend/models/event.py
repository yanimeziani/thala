from datetime import datetime, timezone
from enum import Enum
from typing import Any
import uuid

from sqlalchemy import ARRAY, Boolean, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class EventMode(str, Enum):
    """Cultural event mode enum."""
    IN_PERSON = "in_person"
    ONLINE = "online"
    HYBRID = "hybrid"


class CulturalEvent(Base):
    """Cultural event model for Amazigh events and gatherings."""
    __tablename__ = "cultural_events"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    title: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    date_label: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    location: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    description: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    additional_detail: Mapped[dict[str, Any] | None] = mapped_column(JSONB, nullable=True)
    mode: Mapped[str] = mapped_column(String, nullable=False)
    start_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    end_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    tags: Mapped[list[dict[str, Any]]] = mapped_column(JSONB, nullable=False, default=list)
    cta_label: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    cta_note: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    background_colors: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    hero_image_url: Mapped[str | None] = mapped_column(Text, nullable=True)

    # Host/community information
    host_name: Mapped[str | None] = mapped_column(String, nullable=True)
    host_handle: Mapped[str | None] = mapped_column(String, nullable=True)
    is_host_verified: Mapped[bool] = mapped_column(Boolean, nullable=False, default=False)

    # Interest tracking
    interested_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)

    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<CulturalEvent(id={self.id!r}, mode={self.mode!r}, start_at={self.start_at})>"


class EventInterest(Base):
    """Junction table tracking user interest in events."""
    __tablename__ = "event_interests"
    __table_args__ = (
        UniqueConstraint("event_id", "user_id", name="uq_event_interest"),
    )

    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    event_id: Mapped[str] = mapped_column(String, ForeignKey("cultural_events.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False, default=utcnow)

    def __repr__(self) -> str:
        return f"<EventInterest(event_id={self.event_id!r}, user_id={self.user_id!r})>"
