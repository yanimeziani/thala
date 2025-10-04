"""Community-related Pydantic schemas for the Thala backend."""
from datetime import datetime
from typing import Any, Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class CommunityViewCreate(BaseModel):
    """Schema for recording a community view."""

    community_id: str = Field(..., description="ID of the community being viewed")
    user_id: UUID | None = Field(None, description="ID of the user viewing (null for anonymous)")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "community_id": "fk2q",
                "user_id": "123e4567-e89b-12d3-a456-426614174000"
            }
        }
    )


class CommunityHostRequestCreate(BaseModel):
    """Schema for creating a community host request."""

    name: str = Field(..., min_length=1, description="Requester's name")
    email: EmailStr = Field(..., description="Requester's email address")
    message: str = Field(..., min_length=1, description="Request message/description")
    user_id: UUID | None = Field(None, description="User ID if authenticated, null for anonymous")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "name": "Leila Amour",
                "email": "leila@example.com",
                "message": "Requesting to host a pop up radio hour featuring village choirs.",
                "user_id": "123e4567-e89b-12d3-a456-426614174000"
            }
        }
    )


class CommunityHostRequestResponse(BaseModel):
    """Schema for community host request response."""

    id: int = Field(..., description="Unique request identifier")
    name: str = Field(..., description="Requester's name")
    email: str = Field(..., description="Requester's email address")
    message: str = Field(..., description="Request message/description")
    user_id: UUID | None = Field(None, description="User ID if authenticated")
    status: Literal["pending", "reviewed", "approved", "rejected"] = Field(
        ...,
        description="Request status"
    )
    created_at: datetime = Field(..., description="Timestamp when request was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": 1,
                "name": "Leila Amour",
                "email": "leila@example.com",
                "message": "Requesting to host a pop up radio hour featuring village choirs.",
                "user_id": "123e4567-e89b-12d3-a456-426614174000",
                "status": "pending",
                "created_at": "2024-04-18T10:00:00Z"
            }
        }
    )


class CommunityProfileResponse(BaseModel):
    """Schema for community profile response with detailed information."""

    id: str = Field(..., description="Unique community profile identifier")
    space: dict[str, Any] = Field(
        ...,
        description="Community space details including name, description, location, members, tags"
    )
    region: str = Field(..., description="Geographic region (e.g., 'Québec · Canada')")
    languages: list[str] = Field(
        default_factory=list,
        description="Languages used by the community (e.g., ['Kabyle', 'Français'])"
    )
    priority: float = Field(..., description="Display priority/ranking for the community")
    cards: list[dict[str, Any]] = Field(
        default_factory=list,
        description="Community information cards (mission, activities, resources, contact, etc.)"
    )
    created_at: datetime = Field(..., description="Timestamp when profile was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "fk2q",
                "space": {
                    "id": "fk2q",
                    "name": {
                        "en": "Kabyle Forum of Québec City",
                        "fr": "Forum Kabyle de la Ville de Québec"
                    },
                    "description": {"en": "", "fr": ""},
                    "location": {
                        "en": "Québec City, QC",
                        "fr": "Ville de Québec, QC"
                    },
                    "imageUrl": "https://images.unsplash.com/photo-1489515217757-5fd1be406fef",
                    "memberCount": 420,
                    "tags": ["Kabyle", "Québec", "Diaspora", "Culture", "Yennayer"]
                },
                "region": "Québec · Canada",
                "languages": ["Kabyle", "Français"],
                "priority": 1.0,
                "cards": [
                    {
                        "id": "mission",
                        "kind": "mission",
                        "title": {
                            "en": "Purpose & Mission",
                            "fr": "But / Mission"
                        },
                        "body": {
                            "en": "Preserve and promote Amazigh and Kabyle culture in Québec through seasonal events, workshops, practical resources, and support for new arrivals.",
                            "fr": "Préserver et promouvoir la culture amazighe et kabyle à Québec par des évènements, ateliers, ressources pratiques et un soutien aux nouveaux arrivants."
                        }
                    }
                ],
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )
