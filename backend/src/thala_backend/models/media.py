import uuid
from datetime import datetime, timezone
from typing import Any
from uuid import UUID

from sqlalchemy import ARRAY, ForeignKey, Integer, Numeric, String, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID as PGUUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.schema import CheckConstraint

from ..db.base import Base


def utcnow() -> datetime:
    return datetime.now(timezone.utc)


class MusicTrack(Base):
    __tablename__ = "music_tracks"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    title: Mapped[str] = mapped_column(String, nullable=False)
    artist: Mapped[str] = mapped_column(String, nullable=False)
    artwork_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    duration_seconds: Mapped[int] = mapped_column(Integer, nullable=False)
    preview_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)


class VideoEffect(Base):
    __tablename__ = "video_effects"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    name: Mapped[str] = mapped_column(String, nullable=False)
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    config: Mapped[dict[str, Any] | None] = mapped_column(JSONB, nullable=True)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)


class Video(Base):
    __tablename__ = "videos"

    id: Mapped[str] = mapped_column(String, primary_key=True)
    creator_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True), nullable=True)
    creator_handle: Mapped[str] = mapped_column(String, nullable=False)
    creator_name_en: Mapped[str | None] = mapped_column(String, nullable=True)
    creator_name_fr: Mapped[str | None] = mapped_column(String, nullable=True)

    video_url: Mapped[str] = mapped_column(Text, nullable=False)
    video_source: Mapped[str] = mapped_column(String, nullable=False, default="network")
    media_kind: Mapped[str] = mapped_column(String, nullable=False, default="video")

    image_url: Mapped[str | None] = mapped_column(Text, nullable=True)
    gallery_urls: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)
    text_slides: Mapped[list[dict[str, Any]]] = mapped_column(JSONB, nullable=False, default=list)

    aspect_ratio: Mapped[float | None] = mapped_column(Numeric(6, 3), nullable=True)
    thumbnail_url: Mapped[str | None] = mapped_column(Text, nullable=True)

    music_track_id: Mapped[str | None] = mapped_column(ForeignKey("music_tracks.id"), nullable=True)
    effect_id: Mapped[str | None] = mapped_column(ForeignKey("video_effects.id"), nullable=True)

    title_en: Mapped[str] = mapped_column(String, nullable=False)
    title_fr: Mapped[str] = mapped_column(String, nullable=False)
    description_en: Mapped[str] = mapped_column(Text, nullable=False, default="")
    description_fr: Mapped[str] = mapped_column(Text, nullable=False, default="")
    location_en: Mapped[str] = mapped_column(String, nullable=False, default="")
    location_fr: Mapped[str] = mapped_column(String, nullable=False, default="")

    likes: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    comments: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    shares: Mapped[int] = mapped_column(Integer, nullable=False, default=0)
    tags: Mapped[list[str]] = mapped_column(ARRAY(Text), nullable=False, default=list)

    created_at: Mapped[datetime] = mapped_column(default=utcnow)
    updated_at: Mapped[datetime] = mapped_column(default=utcnow, onupdate=utcnow)

    music_track: Mapped[MusicTrack | None] = relationship("MusicTrack")
    effect: Mapped[VideoEffect | None] = relationship("VideoEffect")


class VideoComment(Base):
    __tablename__ = "video_comments"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    video_id: Mapped[str] = mapped_column(ForeignKey("videos.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True), nullable=True)
    content: Mapped[str] = mapped_column(Text, nullable=False)
    created_at: Mapped[datetime] = mapped_column(default=utcnow)


class VideoShare(Base):
    __tablename__ = "video_shares"

    id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    video_id: Mapped[str] = mapped_column(ForeignKey("videos.id", ondelete="CASCADE"), nullable=False)
    user_id: Mapped[UUID | None] = mapped_column(PGUUID(as_uuid=True), nullable=True)
    shared_at: Mapped[datetime] = mapped_column(default=utcnow)


class CreatorFollower(Base):
    __tablename__ = "creator_followers"

    creator_handle: Mapped[str] = mapped_column(String, primary_key=True)
    user_id: Mapped[UUID] = mapped_column(PGUUID(as_uuid=True), primary_key=True)
    followed_at: Mapped[datetime] = mapped_column(default=utcnow)

    __table_args__ = (CheckConstraint("creator_handle <> ''"),)
