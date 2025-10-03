"""Content profile Pydantic schemas for the Thela backend."""
from datetime import datetime

from pydantic import BaseModel, ConfigDict, Field


class ContentProfileResponse(BaseModel):
    """Schema for content profile response with cultural categorization."""

    content_id: str = Field(..., description="Unique content identifier")
    cultural_families: list[str] = Field(
        default_factory=list,
        description="Cultural families/groups (e.g., ['Tuareg', 'Kabyle', 'Shilha'])"
    )
    regions: list[str] = Field(
        default_factory=list,
        description="Geographic regions (e.g., ['Hoggar', 'Algeria', 'Sahara'])"
    )
    languages: list[str] = Field(
        default_factory=list,
        description="Languages used in content (e.g., ['Tamahaq', 'Kabyle', 'French'])"
    )
    topics: list[str] = Field(
        default_factory=list,
        description="Content topics/themes (e.g., ['Music', 'Poetry', 'Dance'])"
    )
    energy: str | None = Field(
        None,
        description="Energy level/mood (e.g., 'Calm', 'High', 'Reflective', 'Warm')"
    )
    sacred_level: str | None = Field(
        None,
        description="Sacred/cultural sensitivity level (e.g., 'guardian_reviewed', 'public_celebration', 'household_practice')"
    )
    is_guardian_approved: bool = Field(
        False,
        description="Whether content has been reviewed and approved by cultural guardians"
    )
    created_at: datetime = Field(..., description="Timestamp when profile was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "content_id": "imzad-rhythms",
                "cultural_families": ["Tuareg"],
                "regions": ["Hoggar", "Algeria", "Sahara"],
                "languages": ["Tamahaq"],
                "topics": ["Music", "Instrumental", "Heritage"],
                "energy": "Calm",
                "sacred_level": "guardian_reviewed",
                "is_guardian_approved": True,
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )
