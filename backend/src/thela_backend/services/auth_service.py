"""Authentication service for Thela backend."""
from datetime import datetime, timedelta, timezone
from typing import Dict, Tuple

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.config import settings
from ..core.security import (
    create_access_token,
    create_refresh_token,
    validate_refresh_token,
)
from ..models.user import User
from ..schemas.auth import TokenResponse
from ..schemas.user import UserResponse
from .google_oauth import verify_google_token


class AuthService:
    """Service for handling authentication operations."""

    def __init__(self, db: AsyncSession):
        """
        Initialize the authentication service.

        Args:
            db: Database session
        """
        self.db = db

    async def authenticate_with_google(self, google_id_token: str) -> TokenResponse:
        """
        Authenticate a user using Google OAuth token.

        This method:
        1. Verifies the Google ID token
        2. Creates or retrieves the user from database
        3. Generates JWT access and refresh tokens
        4. Updates last login timestamp

        Args:
            google_id_token: Google ID token from OAuth flow

        Returns:
            TokenResponse with access token, refresh token, and user info

        Raises:
            HTTPException: If Google token is invalid
        """
        # Verify Google token
        google_payload = await verify_google_token(google_id_token)

        # Extract user info from Google payload
        google_sub = google_payload["sub"]
        email = google_payload["email"]
        full_name = google_payload.get("name")
        picture = google_payload.get("picture")
        locale = google_payload.get("locale")

        # Find or create user
        user = await self._get_or_create_user(
            google_sub=google_sub,
            email=email,
            full_name=full_name,
            picture=picture,
            locale=locale,
        )

        # Update last login
        user.touch_last_login()
        await self.db.commit()
        await self.db.refresh(user)

        # Generate tokens
        return await self._generate_token_response(user)

    async def refresh_access_token(self, refresh_token: str) -> TokenResponse:
        """
        Refresh access token using a valid refresh token.

        Args:
            refresh_token: Valid refresh token

        Returns:
            TokenResponse with new access token, same refresh token, and user info

        Raises:
            HTTPException: If refresh token is invalid or user not found
        """
        # Validate refresh token
        payload = validate_refresh_token(refresh_token)

        # Get user ID from token
        user_id = payload.get("sub")
        if not user_id:
            from fastapi import HTTPException, status

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload",
            )

        # Retrieve user
        user = await self._get_user_by_id(user_id)
        if not user:
            from fastapi import HTTPException, status

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found",
            )

        if not user.is_active:
            from fastapi import HTTPException, status

            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User is inactive",
            )

        # Generate new access token (keep same refresh token)
        return await self._generate_token_response(user, reuse_refresh_token=refresh_token)

    async def _get_or_create_user(
        self,
        google_sub: str,
        email: str,
        full_name: str | None = None,
        picture: str | None = None,
        locale: str | None = None,
    ) -> User:
        """
        Retrieve existing user or create new one based on Google sub.

        Args:
            google_sub: Google subject identifier
            email: User email
            full_name: User full name
            picture: Profile picture URL
            locale: User locale

        Returns:
            User instance
        """
        # Try to find existing user by google_sub
        stmt = select(User).where(User.google_sub == google_sub)
        result = await self.db.execute(stmt)
        user = result.scalar_one_or_none()

        if user:
            # Update user info if changed
            updated = False
            if user.email != email:
                user.email = email
                updated = True
            if full_name and user.full_name != full_name:
                user.full_name = full_name
                updated = True
            if picture and user.picture != picture:
                user.picture = picture
                updated = True
            if locale and user.locale != locale:
                user.locale = locale
                updated = True

            if updated:
                await self.db.commit()
                await self.db.refresh(user)

            return user

        # Create new user
        user = User(
            google_sub=google_sub,
            email=email,
            full_name=full_name,
            picture=picture,
            locale=locale,
            is_active=True,
            profile={},
        )
        self.db.add(user)
        await self.db.commit()
        await self.db.refresh(user)

        return user

    async def _get_user_by_id(self, user_id: str) -> User | None:
        """
        Retrieve user by ID.

        Args:
            user_id: User UUID

        Returns:
            User instance or None if not found
        """
        stmt = select(User).where(User.id == user_id)
        result = await self.db.execute(stmt)
        return result.scalar_one_or_none()

    async def _generate_token_response(
        self, user: User, reuse_refresh_token: str | None = None
    ) -> TokenResponse:
        """
        Generate token response with access and refresh tokens.

        Args:
            user: User instance
            reuse_refresh_token: Optional refresh token to reuse (for token refresh)

        Returns:
            TokenResponse with tokens and user info
        """
        user_id_str = str(user.id)

        # Generate tokens
        access_token = create_access_token(subject=user_id_str)

        if reuse_refresh_token:
            refresh_token = reuse_refresh_token
        else:
            refresh_token = create_refresh_token(subject=user_id_str)

        # Create expiration deltas
        access_expires = timedelta(minutes=settings.access_token_expiration_minutes)
        refresh_expires = timedelta(minutes=settings.refresh_token_expiration_minutes)

        # Convert user to response schema
        user_response = UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            picture=user.picture,
            locale=user.locale,
            is_active=user.is_active,
            profile=user.profile,
            last_login_at=user.last_login_at,
            created_at=user.created_at,
            updated_at=user.updated_at,
        )

        # Create token response
        return TokenResponse.from_tokens(
            access_token=access_token,
            refresh_token=refresh_token,
            access_expires=access_expires,
            refresh_expires=refresh_expires,
            user=user_response,
            issued_at=datetime.now(timezone.utc),
        )


def get_auth_service(db: AsyncSession) -> AuthService:
    """
    Dependency to get an AuthService instance.

    Args:
        db: Database session

    Returns:
        AuthService instance
    """
    return AuthService(db)
