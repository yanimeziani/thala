"""User profile management endpoints for the Thela backend."""
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.user import User
from ...schemas.user import UserProfile, UserResponse, UserUpdate

router = APIRouter(prefix="/users", tags=["users"])


@router.get("/profile", response_model=UserResponse)
async def get_own_profile(
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> UserResponse:
    """Get the authenticated user's own profile with full details."""
    return UserResponse.model_validate(user)


@router.put("/profile", response_model=UserResponse)
async def update_own_profile(
    profile_data: UserUpdate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> UserResponse:
    """Update the authenticated user's own profile."""

    # Update fields if provided
    update_data = profile_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(user, field, value)

    await session.commit()
    await session.refresh(user)

    return UserResponse.model_validate(user)


@router.get("/{handle}", response_model=UserProfile)
async def get_public_user_profile(
    handle: str,
    session: AsyncSession = Depends(get_db),
) -> UserProfile:
    """Get a public user profile by handle (limited fields for privacy)."""

    # In a full implementation, User model would have a 'handle' field
    # For now, we'll search by full_name as a placeholder
    # You might need to add a handle column to the User model

    # This is a placeholder implementation
    # stmt = select(User).where(User.handle == handle)

    # For now, treat handle as a UUID and search by ID
    # In production, you'd want to add a handle field to User model
    stmt = select(User).where(User.full_name.ilike(f"%{handle}%"))
    result = await session.execute(stmt)
    user = result.scalars().first()

    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"User with handle '{handle}' not found"
        )

    return UserProfile.model_validate(user)
