from datetime import datetime, timedelta, timezone
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...core import security
from ...core.config import settings
from ...core.security import TokenType, decode_token
from ...db.session import get_db
from ...models.user import User
from ...schemas.auth import (
    GoogleTokenRequest,
    RefreshTokenRequest,
    TokenResponse,
)
from ...schemas.user import UserResponse
from ...services.google_oauth import verify_google_token

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/google", response_model=TokenResponse)
async def authenticate_with_google(
    payload: GoogleTokenRequest,
    session: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Exchange a Google ID token for application credentials."""

    google_data = await verify_google_token(payload.id_token)
    sub = google_data.get("sub")
    email = google_data.get("email")
    full_name = google_data.get("name")
    picture = google_data.get("picture")
    locale = google_data.get("locale")

    result = await session.execute(select(User).where(User.google_sub == sub))
    user = result.scalar_one_or_none()

    created = False
    if user is None:
        if not email:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Google account missing email scope.",
            )
        user = User(google_sub=sub, email=email)
        session.add(user)
        created = True

    user.full_name = full_name
    user.picture = picture
    user.locale = locale
    user.profile = {
        "email_verified": google_data.get("email_verified", False),
        "given_name": google_data.get("given_name"),
        "family_name": google_data.get("family_name"),
        "hd": google_data.get("hd"),
    }
    user.touch_last_login()

    await session.commit()
    await session.refresh(user)

    issued_at = datetime.now(timezone.utc)
    access_expires = timedelta(minutes=settings.access_token_expiration_minutes)
    refresh_expires = timedelta(minutes=settings.refresh_token_expiration_minutes)

    access_token = security.create_access_token(str(user.id))
    refresh_token = security.create_refresh_token(str(user.id), {"created": created})

    user_response = UserResponse.model_validate(user)
    return TokenResponse.from_tokens(
        access_token=access_token,
        refresh_token=refresh_token,
        access_expires=access_expires,
        refresh_expires=refresh_expires,
        user=user_response,
        issued_at=issued_at,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_tokens(
    payload: RefreshTokenRequest,
    session: AsyncSession = Depends(get_db),
) -> TokenResponse:
    """Exchange a refresh token for a new access token pair."""

    token_payload = decode_token(payload.refresh_token)
    if token_payload.get("type") != TokenType.REFRESH:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")

    try:
        user_id = UUID(token_payload["sub"])
    except (KeyError, ValueError) as exc:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token") from exc

    result = await session.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User inactive or not found")

    issued_at = datetime.now(timezone.utc)
    access_expires = timedelta(minutes=settings.access_token_expiration_minutes)
    refresh_expires = timedelta(minutes=settings.refresh_token_expiration_minutes)

    access_token = security.create_access_token(str(user.id))
    refresh_token = security.create_refresh_token(str(user.id))
    user_response = UserResponse.model_validate(user)

    return TokenResponse.from_tokens(
        access_token=access_token,
        refresh_token=refresh_token,
        access_expires=access_expires,
        refresh_expires=refresh_expires,
        user=user_response,
        issued_at=issued_at,
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user_profile(
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> UserResponse:
    """Get the currently authenticated user's profile."""
    return UserResponse.model_validate(user)


