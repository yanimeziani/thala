import asyncio
from typing import Any, Dict

from fastapi import HTTPException, status
from google.auth.transport import requests
from google.oauth2 import id_token

from ..core.config import settings


async def verify_google_token(token: str) -> Dict[str, Any]:
    """Validate a Google ID token and return its decoded payload."""

    if not settings.google_client_id:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Google OAuth is not configured.",
        )

    loop = asyncio.get_running_loop()

    def _verify() -> Dict[str, Any]:
        request = requests.Request()
        return id_token.verify_oauth2_token(token, request, settings.google_client_id)

    try:
        payload: Dict[str, Any] = await loop.run_in_executor(None, _verify)
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid Google token.",
        ) from exc

    return payload
