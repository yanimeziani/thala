"""Community profiles and spaces endpoints for the Thela backend."""
from typing import Optional

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.community import CommunityHostRequest, CommunityProfile, CommunityView
from ...models.user import User
from ...schemas.community import (
    CommunityHostRequestCreate,
    CommunityHostRequestResponse,
    CommunityProfileResponse,
    CommunityViewCreate,
)

router = APIRouter(prefix="/community", tags=["community"])


@router.get("/profiles", response_model=list[CommunityProfileResponse])
async def list_community_profiles(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
) -> list[CommunityProfileResponse]:
    """List community profiles with pagination, ordered by priority."""

    stmt = (
        select(CommunityProfile)
        .offset(skip)
        .limit(limit)
        .order_by(CommunityProfile.priority.desc(), CommunityProfile.created_at.desc())
    )

    result = await session.execute(stmt)
    profiles = result.scalars().all()

    return [CommunityProfileResponse.model_validate(profile) for profile in profiles]


@router.get("/profiles/{profile_id}", response_model=CommunityProfileResponse)
async def get_community_profile(
    profile_id: str,
    session: AsyncSession = Depends(get_db),
) -> CommunityProfileResponse:
    """Get a single community profile by ID."""

    stmt = select(CommunityProfile).where(CommunityProfile.id == profile_id)
    result = await session.execute(stmt)
    profile = result.scalar_one_or_none()

    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Community profile with id '{profile_id}' not found"
        )

    return CommunityProfileResponse.model_validate(profile)


@router.post("/views", status_code=status.HTTP_201_CREATED)
async def record_community_view(
    view_data: CommunityViewCreate,
    session: AsyncSession = Depends(get_db),
) -> dict[str, str]:
    """Record a community view (can be authenticated or anonymous)."""

    # Verify community exists
    community_stmt = select(CommunityProfile).where(CommunityProfile.id == view_data.community_id)
    community_result = await session.execute(community_stmt)
    if community_result.scalar_one_or_none() is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Community with id '{view_data.community_id}' not found"
        )

    # Create view record
    view = CommunityView(
        community_id=view_data.community_id,
        user_id=view_data.user_id,
    )

    session.add(view)
    await session.commit()

    return {"status": "success", "message": "Community view recorded"}


@router.post("/host-requests", response_model=CommunityHostRequestResponse, status_code=status.HTTP_201_CREATED)
async def submit_host_request(
    request_data: CommunityHostRequestCreate,
    session: AsyncSession = Depends(get_db),
) -> CommunityHostRequestResponse:
    """Submit a community host request (can be authenticated or anonymous)."""

    # Create host request
    host_request = CommunityHostRequest(
        name=request_data.name,
        email=request_data.email,
        message=request_data.message,
        user_id=request_data.user_id,
        status="pending",
    )

    session.add(host_request)
    await session.commit()
    await session.refresh(host_request)

    return CommunityHostRequestResponse.model_validate(host_request)


@router.get("/host-requests", response_model=list[CommunityHostRequestResponse])
async def list_host_requests(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(50, ge=1, le=100, description="Number of items to return"),
    status_filter: Optional[str] = Query(None, description="Filter by status (pending, reviewed, approved, rejected)"),
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[CommunityHostRequestResponse]:
    """List community host requests (authenticated users only, typically admin)."""

    stmt = select(CommunityHostRequest)

    # Apply status filter if provided
    if status_filter:
        stmt = stmt.where(CommunityHostRequest.status == status_filter)

    stmt = (
        stmt
        .offset(skip)
        .limit(limit)
        .order_by(CommunityHostRequest.created_at.desc())
    )

    result = await session.execute(stmt)
    requests = result.scalars().all()

    return [CommunityHostRequestResponse.model_validate(req) for req in requests]
