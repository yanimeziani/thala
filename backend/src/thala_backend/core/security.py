from datetime import datetime, timedelta, timezone
from typing import Any, Dict

import jwt
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from passlib.context import CryptContext
from sqlalchemy.ext.asyncio import AsyncSession

from .config import settings


class TokenType:
    ACCESS = "access"
    REFRESH = "refresh"


def _create_token(subject: str, expires_delta: timedelta, token_type: str, extra_claims: Dict[str, Any] | None = None) -> str:
    now = datetime.now(timezone.utc)
    payload: Dict[str, Any] = {
        "sub": subject,
        "iat": int(now.timestamp()),
        "exp": int((now + expires_delta).timestamp()),
        "type": token_type,
    }
    if extra_claims:
        payload.update(extra_claims)

    token = jwt.encode(payload, settings.jwt_secret, algorithm=settings.jwt_algorithm)
    return token


def create_access_token(subject: str, extra_claims: Dict[str, Any] | None = None) -> str:
    expires_delta = timedelta(minutes=settings.access_token_expiration_minutes)
    return _create_token(subject, expires_delta, TokenType.ACCESS, extra_claims)


def create_refresh_token(subject: str, extra_claims: Dict[str, Any] | None = None) -> str:
    expires_delta = timedelta(minutes=settings.refresh_token_expiration_minutes)
    return _create_token(subject, expires_delta, TokenType.REFRESH, extra_claims)


def decode_token(token: str) -> Dict[str, Any]:
    try:
        return jwt.decode(token, settings.jwt_secret, algorithms=[settings.jwt_algorithm])
    except jwt.PyJWTError as exc:  # broad but appropriate for auth flow
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        ) from exc


# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def hash_password(password: str) -> str:
    """Hash a password for storage."""
    return pwd_context.hash(password)


# Security dependencies for FastAPI routes
security = HTTPBearer()


async def get_current_user_id(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> str:
    """
    Dependency to extract and validate the current user ID from JWT token.

    Args:
        credentials: HTTP Bearer token credentials

    Returns:
        User ID (subject) from the token

    Raises:
        HTTPException: If token is invalid or missing required claims
    """
    token = credentials.credentials
    payload = decode_token(token)

    # Validate token type
    token_type = payload.get("type")
    if token_type != TokenType.ACCESS:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Extract user ID
    user_id: str | None = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user_id


async def get_current_user(
    user_id: str = Depends(get_current_user_id),
    db: AsyncSession = Depends(lambda: None),  # Will be overridden by actual db dependency
):
    """
    Dependency to get the current authenticated user from database.

    Note: The db dependency should be properly injected when using this in routes.
    This is a placeholder signature showing the pattern.

    Args:
        user_id: User ID from token
        db: Database session

    Returns:
        User model instance

    Raises:
        HTTPException: If user not found or inactive
    """
    # This will be implemented in the actual routes with proper db injection
    # Example usage in routes:
    # async def my_route(current_user: User = Depends(get_current_user)):
    #     ...
    raise NotImplementedError("This dependency must be used with proper db injection")


def validate_refresh_token(token: str) -> Dict[str, Any]:
    """
    Validate a refresh token and return its payload.

    Args:
        token: Refresh token string

    Returns:
        Token payload

    Raises:
        HTTPException: If token is invalid or not a refresh token
    """
    payload = decode_token(token)

    token_type = payload.get("type")
    if token_type != TokenType.REFRESH:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid token type",
        )

    return payload
