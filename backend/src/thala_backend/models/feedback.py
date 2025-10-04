"""Feedback model for bug reports and feature requests."""
from datetime import datetime, timezone
from enum import Enum
from typing import Optional
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, Enum as SQLEnum, String, Text
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


class FeedbackType(str, Enum):
    """Feedback type enumeration."""

    BUG = "bug"
    FEATURE = "feature"
    GENERAL = "general"


class FeedbackStatus(str, Enum):
    """Feedback status enumeration."""

    NEW = "new"
    REVIEWING = "reviewing"
    PLANNED = "planned"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    WONT_FIX = "wont_fix"
    DUPLICATE = "duplicate"


class Feedback(Base):
    """Feedback model for bug reports and feature requests."""

    __tablename__ = "feedback"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)

    # User information
    user_id: Mapped[Optional[UUID]] = mapped_column(nullable=True)
    user_email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    user_name: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)

    # Feedback details
    feedback_type: Mapped[FeedbackType] = mapped_column(
        SQLEnum(FeedbackType, native_enum=False, length=50),
        nullable=False,
        default=FeedbackType.GENERAL,
    )
    title: Mapped[str] = mapped_column(String(500), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)

    # Device/platform information
    platform: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)  # ios, android, web
    app_version: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    device_info: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Status and priority
    status: Mapped[FeedbackStatus] = mapped_column(
        SQLEnum(FeedbackStatus, native_enum=False, length=50),
        nullable=False,
        default=FeedbackStatus.NEW,
    )
    priority: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)  # low, medium, high, critical

    # Admin notes
    admin_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Flags
    is_public: Mapped[bool] = mapped_column(Boolean, default=False)
    has_screenshot: Mapped[bool] = mapped_column(Boolean, default=False)
    screenshot_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)

    # Timestamps
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    resolved_at: Mapped[Optional[datetime]] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )

    def __repr__(self) -> str:
        """String representation."""
        return f"<Feedback(id={self.id!r}, type={self.feedback_type!r}, status={self.status!r})>"
