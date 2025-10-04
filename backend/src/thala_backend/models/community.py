from datetime import datetime, timezone
from enum import Enum
from typing import Any
from uuid import UUID

from sqlalchemy import ARRAY, BigInteger, ForeignKey, Identity, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class HostRequestStatus(str, Enum):
    """Community host request status enum."""
    PENDING = "pending"
    REVIEWED = "reviewed"
    APPROVED = "approved"
    REJECTED = "rejected"


class CommunityView(Base):
    """Community view tracking model."""
    __tablename__ = "community_views"

    id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(start=1, cycle=True),
        primary_key=True
    )
    community_id: Mapped[str] = mapped_column(String, nullable=False)
    user_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<CommunityView(id={self.id}, community_id={self.community_id!r})>"


class CommunityHostRequest(Base):
    """Community host request model."""
    __tablename__ = "community_host_requests"

    id: Mapped[int] = mapped_column(
        BigInteger,
        Identity(start=1, cycle=True),
        primary_key=True
    )
    name: Mapped[str] = mapped_column(String, nullable=False)
    email: Mapped[str] = mapped_column(String, nullable=False)
    message: Mapped[str] = mapped_column(Text, nullable=False)
    user_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True), nullable=True)
    status: Mapped[str] = mapped_column(
        String,
        nullable=False,
        default=HostRequestStatus.PENDING.value
    )
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<CommunityHostRequest(id={self.id}, name={self.name!r}, status={self.status!r})>"


class CommunityProfile(Base):
    """Community profile model with detailed information."""
    __tablename__ = "community_profiles"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    space: Mapped[dict[str, Any]] = mapped_column(JSONB, nullable=False)
    region: Mapped[str] = mapped_column(String, nullable=False)
    languages: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    priority: Mapped[float] = mapped_column(Numeric, nullable=False, default=0)
    cards: Mapped[list[dict[str, Any]]] = mapped_column(JSONB, nullable=False, default=list)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<CommunityProfile(id={self.id!r}, region={self.region!r})>"
