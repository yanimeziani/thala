"""Feedback schemas for API requests and responses."""
from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, Field

from ..models.feedback import FeedbackStatus, FeedbackType


class FeedbackCreate(BaseModel):
    """Schema for creating new feedback."""

    feedback_type: FeedbackType = Field(..., description="Type of feedback: bug, feature, or general")
    title: str = Field(..., min_length=1, max_length=500, description="Feedback title/summary")
    description: str = Field(..., min_length=1, description="Detailed feedback description")

    # Optional user information (for non-authenticated users)
    user_email: Optional[str] = Field(None, max_length=255, description="User email (optional)")
    user_name: Optional[str] = Field(None, max_length=255, description="User name (optional)")

    # Device/platform information
    platform: Optional[str] = Field(None, max_length=50, description="Platform: ios, android, web")
    app_version: Optional[str] = Field(None, max_length=50, description="App version")
    device_info: Optional[str] = Field(None, description="Device information")

    screenshot_url: Optional[str] = Field(None, max_length=500, description="Screenshot URL if uploaded")

    class Config:
        """Pydantic config."""

        json_schema_extra = {
            "example": {
                "feedback_type": "bug",
                "title": "Video playback freezes on iOS",
                "description": "When scrolling through the feed, videos sometimes freeze after playing for 3-4 seconds.",
                "user_email": "user@example.com",
                "user_name": "Ahmed",
                "platform": "ios",
                "app_version": "1.0.0",
                "device_info": "iPhone 14 Pro, iOS 17.2",
            }
        }


class FeedbackUpdate(BaseModel):
    """Schema for updating feedback (admin only)."""

    status: Optional[FeedbackStatus] = Field(None, description="Feedback status")
    priority: Optional[str] = Field(None, max_length=20, description="Priority: low, medium, high, critical")
    admin_notes: Optional[str] = Field(None, description="Admin notes")
    is_public: Optional[bool] = Field(None, description="Make feedback visible to all users")

    class Config:
        """Pydantic config."""

        json_schema_extra = {
            "example": {
                "status": "in_progress",
                "priority": "high",
                "admin_notes": "Working on fix for next release",
                "is_public": True,
            }
        }


class FeedbackResponse(BaseModel):
    """Schema for feedback response."""

    id: UUID = Field(..., description="Unique feedback identifier")
    user_id: Optional[UUID] = Field(None, description="User ID (if authenticated)")
    user_email: Optional[str] = Field(None, description="User email")
    user_name: Optional[str] = Field(None, description="User name")

    feedback_type: FeedbackType = Field(..., description="Type of feedback")
    title: str = Field(..., description="Feedback title")
    description: str = Field(..., description="Feedback description")

    platform: Optional[str] = Field(None, description="Platform")
    app_version: Optional[str] = Field(None, description="App version")
    device_info: Optional[str] = Field(None, description="Device information")

    status: FeedbackStatus = Field(..., description="Feedback status")
    priority: Optional[str] = Field(None, description="Priority level")
    admin_notes: Optional[str] = Field(None, description="Admin notes")

    is_public: bool = Field(..., description="Is publicly visible")
    has_screenshot: bool = Field(..., description="Has screenshot attached")
    screenshot_url: Optional[str] = Field(None, description="Screenshot URL")

    created_at: datetime = Field(..., description="Creation timestamp")
    updated_at: datetime = Field(..., description="Last update timestamp")
    resolved_at: Optional[datetime] = Field(None, description="Resolution timestamp")

    class Config:
        """Pydantic config."""

        from_attributes = True
        json_schema_extra = {
            "example": {
                "id": "123e4567-e89b-12d3-a456-426614174000",
                "user_id": "123e4567-e89b-12d3-a456-426614174001",
                "user_email": "user@example.com",
                "user_name": "Ahmed",
                "feedback_type": "bug",
                "title": "Video playback freezes on iOS",
                "description": "When scrolling through the feed, videos sometimes freeze.",
                "platform": "ios",
                "app_version": "1.0.0",
                "device_info": "iPhone 14 Pro, iOS 17.2",
                "status": "new",
                "priority": None,
                "admin_notes": None,
                "is_public": False,
                "has_screenshot": False,
                "screenshot_url": None,
                "created_at": "2025-10-04T12:00:00Z",
                "updated_at": "2025-10-04T12:00:00Z",
                "resolved_at": None,
            }
        }
