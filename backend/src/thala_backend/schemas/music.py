"""Music-related Pydantic schemas for the Thala backend."""
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class MusicTrackBase(BaseModel):
    """Base music track schema with common fields."""

    title: str = Field(..., description="Track title")
    artist: str = Field(..., description="Artist name")
    artwork_url: str | None = Field(None, description="URL to track artwork/cover image")
    duration_seconds: int = Field(..., ge=0, description="Track duration in seconds")
    preview_url: str | None = Field(None, description="URL to audio preview/sample")

    model_config = ConfigDict(from_attributes=True)


class MusicTrackCreate(MusicTrackBase):
    """Schema for creating a new music track."""

    id: str = Field(..., description="Unique track identifier")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id": "imzad-dawn",
                "title": "Imzad Dawn",
                "artist": "Tassili Ensemble",
                "artwork_url": "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=600&q=80",
                "duration_seconds": 252,
                "preview_url": "https://example.com/preview/imzad-dawn.mp3"
            }
        }
    )


class MusicTrackResponse(MusicTrackBase):
    """Schema for music track response with all fields."""

    id: str = Field(..., description="Unique track identifier")
    created_at: datetime = Field(..., description="Timestamp when track was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "imzad-dawn",
                "title": "Imzad Dawn",
                "artist": "Tassili Ensemble",
                "artwork_url": "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=600&q=80",
                "duration_seconds": 252,
                "preview_url": "https://example.com/preview/imzad-dawn.mp3",
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )
