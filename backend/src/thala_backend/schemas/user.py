"""User Pydantic schemas for the Thala backend."""
from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserBase(BaseModel):
    """Base user schema with common fields."""

    email: EmailStr = Field(..., description="User's email address")
    full_name: str | None = Field(None, description="User's full name")
    picture: str | None = Field(None, description="URL to user's profile picture")
    locale: str | None = Field(None, max_length=16, description="User's preferred locale (e.g., 'en', 'fr')")
    is_active: bool = Field(True, description="Whether the user account is active")
    profile: dict[str, Any] = Field(
        default_factory=dict,
        description="Additional user profile data stored as JSON",
        examples=[{"bio": "Cultural enthusiast", "interests": ["music", "poetry"]}]
    )

    model_config = ConfigDict(from_attributes=True)


class UserCreate(BaseModel):
    """Schema for creating a new user."""

    google_sub: str = Field(..., max_length=255, description="Google subject identifier")
    email: EmailStr = Field(..., description="User's email address")
    full_name: str | None = Field(None, description="User's full name")
    picture: str | None = Field(None, description="URL to user's profile picture")
    locale: str | None = Field(None, max_length=16, description="User's preferred locale")
    profile: dict[str, Any] = Field(default_factory=dict, description="Additional profile data")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "google_sub": "1234567890",
                "email": "user@example.com",
                "full_name": "Amina Idir",
                "picture": "https://example.com/photo.jpg",
                "locale": "fr",
                "profile": {"bio": "Amazigh storyteller"}
            }
        }
    )


class UserUpdate(BaseModel):
    """Schema for updating an existing user."""

    full_name: str | None = None
    picture: str | None = None
    locale: str | None = Field(None, max_length=16)
    is_active: bool | None = None
    profile: dict[str, Any] | None = None

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "full_name": "Amina Idir",
                "locale": "fr",
                "profile": {"bio": "Cultural ambassador and storyteller"}
            }
        }
    )


class UserResponse(UserBase):
    """Schema for user response with all fields."""

    id: UUID = Field(..., description="Unique user identifier")
    created_at: datetime = Field(..., description="Timestamp when user was created")
    updated_at: datetime = Field(..., description="Timestamp when user was last updated")
    last_login_at: datetime | None = Field(None, description="Timestamp of user's last login")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "email": "amina@example.com",
                "full_name": "Amina Idir",
                "picture": "https://example.com/photo.jpg",
                "locale": "fr",
                "is_active": True,
                "profile": {"bio": "Cultural storyteller"},
                "last_login_at": "2024-04-20T10:30:00Z",
                "created_at": "2024-01-15T08:00:00Z",
                "updated_at": "2024-04-20T10:30:00Z"
            }
        }
    )


class UserProfile(BaseModel):
    """Public user profile schema (limited fields)."""

    id: UUID = Field(..., description="Unique user identifier")
    full_name: str | None = Field(None, description="User's full name")
    picture: str | None = Field(None, description="URL to user's profile picture")
    profile: dict[str, Any] = Field(default_factory=dict, description="Public profile data")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "full_name": "Amina Idir",
                "picture": "https://example.com/photo.jpg",
                "profile": {"bio": "Cultural storyteller"}
            }
        }
    )


# Alias for backward compatibility
UserPublic = UserProfile
