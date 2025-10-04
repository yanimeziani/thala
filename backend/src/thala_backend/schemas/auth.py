"""Authentication request/response schemas."""

from datetime import datetime, timedelta
from typing import Optional

from pydantic import BaseModel, ConfigDict, Field

from .user import UserResponse


class GoogleTokenRequest(BaseModel):
    """Request to authenticate with Google ID token."""

    id_token: str = Field(..., description="Google OAuth ID token")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "id_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE4MmU0..."
            }
        }
    )


class RefreshTokenRequest(BaseModel):
    """Request to refresh access token."""

    refresh_token: str = Field(..., description="Refresh token")

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
            }
        }
    )


class TokenResponse(BaseModel):
    """JWT token response with user data."""

    access_token: str = Field(..., description="JWT access token")
    refresh_token: str = Field(..., description="JWT refresh token")
    token_type: str = Field(default="bearer", description="Token type")
    expires_in: int = Field(..., description="Access token expiration in seconds")
    user: UserResponse = Field(..., description="Authenticated user data")

    @classmethod
    def from_tokens(
        cls,
        access_token: str,
        refresh_token: str,
        access_expires: timedelta,
        refresh_expires: timedelta,
        user: UserResponse,
        issued_at: Optional[datetime] = None,
    ) -> "TokenResponse":
        """Create TokenResponse from tokens and user."""
        return cls(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=int(access_expires.total_seconds()),
            user=user,
        )

    model_config = ConfigDict(
        json_schema_extra={
            "example": {
                "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
                "token_type": "bearer",
                "expires_in": 3600,
                "user": {
                    "id": "123e4567-e89b-12d3-a456-426614174000",
                    "email": "user@example.com",
                    "full_name": "John Doe",
                },
            }
        }
    )
