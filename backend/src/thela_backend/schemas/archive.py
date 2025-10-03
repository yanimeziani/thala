"""Archive-related Pydantic schemas for the Thela backend."""
from datetime import datetime
from typing import Any

from pydantic import BaseModel, ConfigDict, Field


class ArchiveEntryResponse(BaseModel):
    """Schema for archive entry response."""

    id: str = Field(..., description="Unique archive entry identifier")
    title: dict[str, Any] = Field(
        ...,
        description="Localized title (e.g., {'en': 'Title', 'fr': 'Titre'})"
    )
    summary: dict[str, Any] = Field(
        ...,
        description="Localized summary/description"
    )
    era: dict[str, Any] = Field(
        ...,
        description="Localized era/time period information"
    )
    category: str | None = Field(None, description="Archive category (e.g., 'Textile', 'Audio', 'Archive')")
    thumbnail_url: str = Field(..., description="URL to thumbnail image")
    community_upvotes: int = Field(0, ge=0, description="Number of community upvotes")
    registered_users: int = Field(0, ge=0, description="Number of registered users who reviewed")
    required_approval_percent: float = Field(
        0,
        ge=0,
        le=100,
        description="Required approval percentage threshold"
    )
    created_at: datetime = Field(..., description="Timestamp when entry was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "ancestral-tar",
                "title": {
                    "en": "Ancestral Tar Artwork",
                    "fr": "Œuvre ancestrale du tar"
                },
                "summary": {
                    "en": "Exploring embroidered motifs from Aurès artisans preserved since 1920.",
                    "fr": "Motifs brodés des artisanes de l'Aurès conservés depuis 1920."
                },
                "era": {
                    "en": "Aurès · 1920s",
                    "fr": "Aurès · Années 1920"
                },
                "category": "Textile",
                "thumbnail_url": "https://images.unsplash.com/photo-1500530855697-b586d89ba3ee",
                "community_upvotes": 8200,
                "registered_users": 12000,
                "required_approval_percent": 60,
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )
