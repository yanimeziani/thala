"""Pydantic schemas for the Thela backend API."""

# Archive schemas
from .archive import ArchiveEntryResponse

# Auth schemas
from .auth import GoogleTokenRequest, RefreshTokenRequest, TokenResponse

# Community schemas
from .community import (
    CommunityHostRequestCreate,
    CommunityHostRequestResponse,
    CommunityProfileResponse,
    CommunityViewCreate,
)

# Content schemas
from .content import ContentProfileResponse

# Event schemas
from .event import CulturalEventResponse

# Message schemas
from .message import (
    ContactHandleResponse,
    MessageCreate,
    MessageResponse,
    MessageThreadResponse,
)

# Music schemas
from .music import MusicTrackBase, MusicTrackCreate, MusicTrackResponse

# User schemas
from .user import UserCreate, UserProfile, UserResponse, UserUpdate

# Video schemas
from .video import (
    CreatorFollowerResponse,
    LocalizedText,
    VideoBase,
    VideoCommentCreate,
    VideoCommentResponse,
    VideoCreate,
    VideoEffectResponse,
    VideoResponse,
    VideoUpdate,
)

__all__ = [
    # Archive
    "ArchiveEntryResponse",
    # Auth
    "GoogleTokenRequest",
    "RefreshTokenRequest",
    "TokenResponse",
    # Community
    "CommunityHostRequestCreate",
    "CommunityHostRequestResponse",
    "CommunityProfileResponse",
    "CommunityViewCreate",
    # Content
    "ContentProfileResponse",
    # Event
    "CulturalEventResponse",
    # Message
    "ContactHandleResponse",
    "MessageCreate",
    "MessageResponse",
    "MessageThreadResponse",
    # Music
    "MusicTrackBase",
    "MusicTrackCreate",
    "MusicTrackResponse",
    # User
    "UserCreate",
    "UserProfile",
    "UserResponse",
    "UserUpdate",
    # Video
    "CreatorFollowerResponse",
    "LocalizedText",
    "VideoBase",
    "VideoCommentCreate",
    "VideoCommentResponse",
    "VideoCreate",
    "VideoEffectResponse",
    "VideoResponse",
    "VideoUpdate",
]
