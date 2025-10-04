"""Video and media-related Pydantic schemas for the Thala backend."""
from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class LocalizedText(BaseModel):
    """Helper schema for bilingual text content (English and French)."""

    en: str = Field(..., description="English text")
    fr: str = Field(..., description="French text")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "en": "Amazigh heritage",
                "fr": "Patrimoine amazigh"
            }
        }
    )


class VideoEffectResponse(BaseModel):
    """Schema for video effect response."""

    id: str = Field(..., description="Unique effect identifier")
    name: str = Field(..., description="Effect name")
    description: str | None = Field(None, description="Effect description")
    config: dict[str, Any] | None = Field(None, description="Effect configuration as JSON")
    created_at: datetime = Field(..., description="Timestamp when effect was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "warm_glow",
                "name": "Warm Glow",
                "description": "Adds golden tones for sunset moods.",
                "config": {"preset": "warm"},
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )


class MusicTrackResponse(BaseModel):
    """Schema for music track response (embedded in video)."""

    id: str = Field(..., description="Unique track identifier")
    title: str = Field(..., description="Track title")
    artist: str = Field(..., description="Artist name")
    artwork_url: str | None = Field(None, description="URL to track artwork")
    duration_seconds: int = Field(..., ge=0, description="Track duration in seconds")
    preview_url: str | None = Field(None, description="URL to audio preview")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "imzad-dawn",
                "title": "Imzad Dawn",
                "artist": "Tassili Ensemble",
                "artwork_url": "https://example.com/artwork.jpg",
                "duration_seconds": 252,
                "preview_url": "https://example.com/preview.mp3"
            }
        }
    )


class VideoBase(BaseModel):
    """Base video schema with common fields."""

    creator_handle: str = Field(..., description="Creator's handle (e.g., @username)")
    creator_name_en: str | None = Field(None, description="Creator's name in English")
    creator_name_fr: str | None = Field(None, description="Creator's name in French")

    video_url: str = Field(..., description="URL to video file")
    video_source: Literal["network", "asset", "local"] = Field(
        "network",
        description="Video source type"
    )
    media_kind: Literal["video", "image", "post"] = Field(
        "video",
        description="Type of media content"
    )

    image_url: str | None = Field(None, description="URL to static image (for image/post types)")
    gallery_urls: list[str] = Field(
        default_factory=list,
        description="List of gallery image URLs for swipeable content"
    )
    text_slides: list[dict[str, str]] = Field(
        default_factory=list,
        description="Text slides with localized content for scrollable posts"
    )

    aspect_ratio: float | None = Field(None, ge=0, description="Video aspect ratio (width/height)")
    thumbnail_url: str | None = Field(None, description="URL to video thumbnail")

    music_track_id: str | None = Field(None, description="Associated music track ID")
    effect_id: str | None = Field(None, description="Applied video effect ID")

    title_en: str = Field(..., description="Video title in English")
    title_fr: str = Field(..., description="Video title in French")
    description_en: str = Field("", description="Video description in English")
    description_fr: str = Field("", description="Video description in French")
    location_en: str = Field("", description="Location name in English")
    location_fr: str = Field("", description="Location name in French")

    tags: list[str] = Field(default_factory=list, description="Content tags (e.g., #Amazigh, #Music)")

    model_config = ConfigDict(from_attributes=True)


class VideoCreate(VideoBase):
    """Schema for creating a new video."""

    id: str = Field(..., description="Unique video identifier")
    creator_id: UUID | None = Field(None, description="Creator's user ID (if authenticated)")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "atlas-sunrise-001",
                "creator_id": "123e4567-e89b-12d3-a456-426614174000",
                "creator_handle": "@tamountmedia",
                "creator_name_en": "Tamount Media",
                "creator_name_fr": "Tamount Media",
                "video_url": "https://example.com/video.mp4",
                "video_source": "network",
                "media_kind": "video",
                "aspect_ratio": 1.778,
                "thumbnail_url": "https://example.com/thumb.jpg",
                "effect_id": "cool_mist",
                "title_en": "Atlas sunrise in wide frame",
                "title_fr": "Aube sur le Haut Atlas en grand angle",
                "description_en": "A filmmaker tracks first light spilling over the High Atlas.",
                "description_fr": "Un cinéaste suit la première lumière sur le Haut Atlas.",
                "location_en": "High Atlas, Morocco",
                "location_fr": "Haut Atlas, Maroc",
                "tags": ["#Atlas", "#Sunrise", "#Cinematography"]
            }
        }
    )


class VideoUpdate(BaseModel):
    """Schema for updating an existing video."""

    title_en: str | None = None
    title_fr: str | None = None
    description_en: str | None = None
    description_fr: str | None = None
    location_en: str | None = None
    location_fr: str | None = None
    tags: list[str] | None = None
    music_track_id: str | None = None
    effect_id: str | None = None
    thumbnail_url: str | None = None


class VideoResponse(VideoBase):
    """Schema for video response with all fields."""

    id: str = Field(..., description="Unique video identifier")
    creator_id: UUID | None = Field(None, description="Creator's user ID")

    likes: int = Field(0, ge=0, description="Number of likes")
    comments: int = Field(0, ge=0, description="Number of comments")
    shares: int = Field(0, ge=0, description="Number of shares")

    created_at: datetime = Field(..., description="Timestamp when video was created")
    updated_at: datetime = Field(..., description="Timestamp when video was last updated")

    music_track: MusicTrackResponse | None = Field(None, description="Associated music track details")
    effect: VideoEffectResponse | None = Field(None, description="Applied video effect details")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "atlas-sunrise-001",
                "creator_id": "123e4567-e89b-12d3-a456-426614174000",
                "creator_handle": "@tamountmedia",
                "creator_name_en": "Tamount Media",
                "creator_name_fr": "Tamount Media",
                "video_url": "https://example.com/video.mp4",
                "video_source": "network",
                "media_kind": "video",
                "image_url": None,
                "gallery_urls": [],
                "text_slides": [],
                "aspect_ratio": 1.778,
                "thumbnail_url": "https://example.com/thumb.jpg",
                "music_track_id": None,
                "effect_id": "cool_mist",
                "title_en": "Atlas sunrise in wide frame",
                "title_fr": "Aube sur le Haut Atlas en grand angle",
                "description_en": "A filmmaker tracks first light spilling over the High Atlas.",
                "description_fr": "Un cinéaste suit la première lumière sur le Haut Atlas.",
                "location_en": "High Atlas, Morocco",
                "location_fr": "Haut Atlas, Maroc",
                "likes": 3520,
                "comments": 209,
                "shares": 274,
                "tags": ["#Atlas", "#Sunrise", "#Cinematography", "#WideFrame"],
                "created_at": "2024-04-18T07:00:00Z",
                "updated_at": "2024-04-20T10:00:00Z",
                "music_track": None,
                "effect": {
                    "id": "cool_mist",
                    "name": "Cool Mist",
                    "description": "Soft cyan lift with a gentle haze.",
                    "config": {"preset": "cool"},
                    "created_at": "2024-01-15T08:00:00Z"
                }
            }
        }
    )


class VideoCommentCreate(BaseModel):
    """Schema for creating a video comment."""

    video_id: str = Field(..., description="ID of the video being commented on")
    content: str = Field(..., min_length=1, description="Comment content")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "video_id": "atlas-sunrise-001",
                "content": "The framing on this sunrise is incredible."
            }
        }
    )


class VideoCommentResponse(BaseModel):
    """Schema for video comment response."""

    id: UUID = Field(..., description="Unique comment identifier")
    video_id: str = Field(..., description="ID of the video")
    user_id: UUID | None = Field(None, description="Commenter's user ID")
    content: str = Field(..., description="Comment content")
    created_at: datetime = Field(..., description="Timestamp when comment was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174001",
                "video_id": "atlas-sunrise-001",
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "content": "The framing on this sunrise is incredible.",
                "created_at": "2024-04-20T11:30:00Z"
            }
        }
    )


class CreatorFollowerResponse(BaseModel):
    """Schema for creator follower relationship response."""

    creator_handle: str = Field(..., description="Handle of the creator being followed")
    user_id: UUID = Field(..., description="ID of the user following the creator")
    followed_at: datetime = Field(..., description="Timestamp when follow relationship was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "creator_handle": "@tamountmedia",
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "followed_at": "2024-04-15T09:00:00Z"
            }
        }
    )
