import uuid
from datetime import datetime, timezone
from enum import Enum
from uuid import UUID

from sqlalchemy import ARRAY, ForeignKey, Integer, String, Text
from sqlalchemy.dialects.postgresql import UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class DeliveryStatus(str, Enum):
    """Message delivery status enum."""
    PENDING = "pending"
    SENT = "sent"
    DELIVERED = "delivered"
    READ = "read"
    FAILED = "failed"


class MessageThread(Base):
    """Message thread model for conversations."""
    __tablename__ = "message_threads"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    title_en: Mapped[str] = mapped_column(String, nullable=False)
    title_fr: Mapped[str] = mapped_column(String, nullable=False)
    last_message_en: Mapped[str] = mapped_column(Text, nullable=False, default="")
    last_message_fr: Mapped[str] = mapped_column(Text, nullable=False, default="")
    unread_count: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    participants: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    avatar_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=utcnow, onupdate=utcnow)

    def __repr__(self) -> str:
        return f"<MessageThread(id={self.id!r}, title_en={self.title_en!r})>"


class Message(Base):
    """Individual message model."""
    __tablename__ = "messages"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    thread_id: Mapped[str] = mapped_column(
        ForeignKey("message_threads.id", ondelete="CASCADE"),
        nullable=False
    )
    author_handle: Mapped[str] = mapped_column(String, nullable=False)
    author_display_name: Mapped[str] = mapped_column(String, nullable=False)
    body: Mapped[str] = mapped_column(Text, nullable=False)
    delivery_status: Mapped[str] = mapped_column(String, nullable=False, default=DeliveryStatus.SENT.value)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)

    def __repr__(self) -> str:
        return f"<Message(id={self.id!r}, author_handle={self.author_handle!r}, thread_id={self.thread_id!r})>"
