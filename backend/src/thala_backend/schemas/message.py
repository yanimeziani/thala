"""Messaging-related Pydantic schemas for the Thala backend."""
from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class MessageThreadResponse(BaseModel):
    """Schema for message thread response."""

    id: str = Field(..., description="Unique thread identifier")
    title_en: str = Field(..., description="Thread title in English")
    title_fr: str = Field(..., description="Thread title in French")
    last_message_en: str = Field("", description="Preview of last message in English")
    last_message_fr: str = Field("", description="Preview of last message in French")
    unread_count: int = Field(0, ge=0, description="Number of unread messages")
    participants: list[str] = Field(
        default_factory=list,
        description="List of participant handles (e.g., [@user1, @user2])"
    )
    avatar_url: str | None = Field(None, description="URL to thread/conversation avatar")
    created_at: datetime = Field(..., description="Timestamp when thread was created")
    updated_at: datetime = Field(..., description="Timestamp when thread was last updated")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "thread-001",
                "title_en": "Village elders",
                "title_fr": "Les anciens du village",
                "last_message_en": "We are gathering near the cedar grove at dusk.",
                "last_message_fr": "Nous nous retrouvons près du bosquet de cèdres au crépuscule.",
                "unread_count": 3,
                "participants": ["@aziza", "@amir"],
                "avatar_url": "https://example.com/avatars/village-elders.jpg",
                "created_at": "2024-04-16T17:00:00Z",
                "updated_at": "2024-04-16T18:30:00Z"
            }
        }
    )


class MessageCreate(BaseModel):
    """Schema for creating a new message."""

    thread_id: str = Field(..., description="ID of the thread this message belongs to")
    author_handle: str = Field(..., description="Handle of the message author")
    author_display_name: str = Field(..., description="Display name of the message author")
    body: str = Field(..., min_length=1, description="Message content")
    delivery_status: Literal["pending", "sent", "delivered", "read", "failed"] = Field(
        "sent",
        description="Message delivery status"
    )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "thread_id": "thread-001",
                "author_handle": "@amina",
                "author_display_name": "Amina Taleb",
                "body": "Grateful. The elders will appreciate hearing the songs.",
                "delivery_status": "sent"
            }
        }
    )


class MessageResponse(BaseModel):
    """Schema for message response."""

    id: UUID = Field(..., description="Unique message identifier")
    thread_id: str = Field(..., description="ID of the thread this message belongs to")
    author_handle: str = Field(..., description="Handle of the message author")
    author_display_name: str = Field(..., description="Display name of the message author")
    body: str = Field(..., description="Message content")
    delivery_status: str = Field(..., description="Message delivery status")
    created_at: datetime = Field(..., description="Timestamp when message was created")

    model_config = ConfigDict(
        from_attributes=True,
        json_schema_extra={
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174002",
                "thread_id": "thread-001",
                "author_handle": "@amina",
                "author_display_name": "Amina Taleb",
                "body": "Grateful. The elders will appreciate hearing the songs.",
                "delivery_status": "read",
                "created_at": "2024-04-16T18:12:00Z"
            }
        }
    )


class ContactHandleResponse(BaseModel):
    """Schema for contact handle in messaging context."""

    handle: str = Field(..., description="User handle (e.g., @username)")
    display_name: str = Field(..., description="Display name for the contact")
    avatar_url: str | None = Field(None, description="URL to contact's avatar")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "handle": "@amina",
                "display_name": "Amina Taleb",
                "avatar_url": "https://example.com/avatars/amina.jpg"
            }
        }
    )
