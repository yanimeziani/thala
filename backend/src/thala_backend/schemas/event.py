"""Event-related Pydantic schemas for the Thala backend."""
from datetime import datetime
from typing import Any, Literal

from pydantic import BaseModel, ConfigDict, Field


class CulturalEventResponse(BaseModel):
    """Schema for cultural event response."""

    id: str = Field(..., description="Unique event identifier")
    title: dict[str, Any] = Field(
        ...,
        description="Localized event title (e.g., {'en': 'Title', 'fr': 'Titre'})"
    )
    date_label: dict[str, Any] = Field(
        ...,
        description="Localized human-readable date label"
    )
    location: dict[str, Any] = Field(
        ...,
        description="Localized location information"
    )
    description: dict[str, Any] = Field(
        ...,
        description="Localized event description"
    )
    additional_detail: dict[str, Any] | None = Field(
        None,
        description="Additional localized details about the event"
    )
    mode: Literal["in_person", "online", "hybrid"] = Field(
        ...,
        description="Event mode/format"
    )
    start_at: datetime = Field(..., description="Event start timestamp")
    end_at: datetime | None = Field(None, description="Event end timestamp (optional)")
    tags: list[dict[str, Any]] = Field(
        default_factory=list,
        description="Localized event tags/categories"
    )
    cta_label: dict[str, Any] = Field(
        ...,
        description="Localized call-to-action button label"
    )
    cta_note: dict[str, Any] = Field(
        ...,
        description="Localized call-to-action note/message"
    )
    background_colors: list[str] = Field(
        default_factory=list,
        description="Background gradient colors for event card"
    )
    hero_image_url: str | None = Field(None, description="URL to hero/banner image")

    # Host/community information
    host_name: str | None = Field(None, description="Name of the event host")
    host_handle: str | None = Field(None, description="Handle/username of the event host")
    is_host_verified: bool = Field(False, description="Whether the host is verified")

    # Interest tracking
    interested_count: int = Field(0, description="Number of users interested in this event")
    is_user_interested: bool = Field(False, description="Whether the current user is interested (runtime field)")
    interested_users: list[str] = Field(
        default_factory=list,
        description="List of user IDs or handles interested in this event (runtime field)"
    )

    created_at: datetime = Field(..., description="Timestamp when event was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "agadir-film-night",
                "title": {
                    "en": "Agadir Amazigh Film Night",
                    "fr": "Soirée cinéma amazighe à Agadir"
                },
                "date_label": {
                    "en": "March 23, 2024 · 19:00",
                    "fr": "23 mars 2024 · 19 h 00"
                },
                "location": {
                    "en": "Agadir, Morocco",
                    "fr": "Agadir, Maroc"
                },
                "description": {
                    "en": "Screenings of shorts celebrating Amazigh storytellers followed by a Q&A with local directors.",
                    "fr": "Projection de courts métrages mettant en lumière des conteurs amazighs, suivie d'une discussion avec des réalisateurs locaux."
                },
                "additional_detail": {
                    "en": "Hosted at Dar Lfenn. Doors open at 18:30. Seats are limited—RSVP required.",
                    "fr": "Organisé à Dar Lfenn. Ouverture des portes à 18 h 30. Places limitées : réservation obligatoire."
                },
                "mode": "in_person",
                "start_at": "2024-03-23T19:00:00+00:00",
                "end_at": "2024-03-23T22:00:00+00:00",
                "tags": [
                    {"en": "Cinema", "fr": "Cinéma"},
                    {"en": "Community", "fr": "Communauté"}
                ],
                "cta_label": {
                    "en": "Reserve a seat",
                    "fr": "Réserver une place"
                },
                "cta_note": {
                    "en": "We will follow up with availability details for Agadir Amazigh Film Night.",
                    "fr": "Nous vous contacterons avec les détails de disponibilité pour la soirée cinéma amazighe d'Agadir."
                },
                "background_colors": ["#2A1B4A", "#36254F", "#4B2C6B"],
                "hero_image_url": "https://images.unsplash.com/photo-1542204165-65bf26472b9b",
                "created_at": "2024-01-15T08:00:00Z"
            }
        }
    )
