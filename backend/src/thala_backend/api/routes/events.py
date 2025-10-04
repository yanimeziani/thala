"""Cultural events endpoints for the Thala backend."""
from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.event import CulturalEvent, EventInterest
from ...models.user import User
from ...schemas.event import CulturalEventResponse
from ...schemas.user import UserProfile

router = APIRouter(prefix="/events", tags=["events"])


@router.get("", response_model=list[CulturalEventResponse])
async def list_events(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of items to return"),
    upcoming_only: bool = Query(True, description="Only show upcoming events"),
    session: AsyncSession = Depends(get_db),
) -> list[CulturalEventResponse]:
    """List cultural events with pagination."""

    stmt = select(CulturalEvent)

    # Filter for upcoming events if requested
    if upcoming_only:
        now = datetime.utcnow()
        stmt = stmt.where(CulturalEvent.start_at >= now)

    stmt = (
        stmt
        .offset(skip)
        .limit(limit)
        .order_by(CulturalEvent.start_at.asc())
    )

    result = await session.execute(stmt)
    events = result.scalars().all()

    return [CulturalEventResponse.model_validate(event) for event in events]


@router.get("/{event_id}", response_model=CulturalEventResponse)
async def get_event(
    event_id: str,
    session: AsyncSession = Depends(get_db),
) -> CulturalEventResponse:
    """Get a single cultural event by ID."""

    stmt = select(CulturalEvent).where(CulturalEvent.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with id '{event_id}' not found"
        )

    return CulturalEventResponse.model_validate(event)


@router.post("", response_model=CulturalEventResponse, status_code=status.HTTP_201_CREATED)
async def create_event(
    event_data: CulturalEventResponse,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> CulturalEventResponse:
    """Create a new cultural event (authenticated users only)."""

    # Check if event with this ID already exists
    existing_stmt = select(CulturalEvent).where(CulturalEvent.id == event_data.id)
    existing_result = await session.execute(existing_stmt)
    if existing_result.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Event with id '{event_data.id}' already exists"
        )

    # Create new event
    event = CulturalEvent(
        id=event_data.id,
        title=event_data.title,
        date_label=event_data.date_label,
        location=event_data.location,
        description=event_data.description,
        additional_detail=event_data.additional_detail,
        mode=event_data.mode,
        start_at=event_data.start_at,
        end_at=event_data.end_at,
        tags=event_data.tags,
        cta_label=event_data.cta_label,
        cta_note=event_data.cta_note,
        background_colors=event_data.background_colors,
        hero_image_url=event_data.hero_image_url,
    )

    session.add(event)
    await session.commit()
    await session.refresh(event)

    return CulturalEventResponse.model_validate(event)


@router.put("/{event_id}", response_model=CulturalEventResponse)
async def update_event(
    event_id: str,
    event_data: CulturalEventResponse,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> CulturalEventResponse:
    """Update an existing cultural event (authenticated users only)."""

    stmt = select(CulturalEvent).where(CulturalEvent.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with id '{event_id}' not found"
        )

    # Update event fields
    event.title = event_data.title
    event.date_label = event_data.date_label
    event.location = event_data.location
    event.description = event_data.description
    event.additional_detail = event_data.additional_detail
    event.mode = event_data.mode
    event.start_at = event_data.start_at
    event.end_at = event_data.end_at
    event.tags = event_data.tags
    event.cta_label = event_data.cta_label
    event.cta_note = event_data.cta_note
    event.background_colors = event_data.background_colors
    event.hero_image_url = event_data.hero_image_url

    await session.commit()
    await session.refresh(event)

    return CulturalEventResponse.model_validate(event)


@router.delete("/{event_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_event(
    event_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    """Delete a cultural event (authenticated users only)."""

    stmt = select(CulturalEvent).where(CulturalEvent.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with id '{event_id}' not found"
        )

    await session.delete(event)
    await session.commit()


@router.post("/{event_id}/interested", status_code=status.HTTP_200_OK)
async def toggle_event_interest(
    event_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> dict:
    """Toggle user interest in an event (authenticated users only)."""

    # Check if event exists
    stmt = select(CulturalEvent).where(CulturalEvent.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with id '{event_id}' not found"
        )

    # Check if user is already interested
    interest_stmt = select(EventInterest).where(
        EventInterest.event_id == event_id,
        EventInterest.user_id == user.id
    )
    interest_result = await session.execute(interest_stmt)
    existing_interest = interest_result.scalar_one_or_none()

    if existing_interest is not None:
        # Remove interest
        await session.delete(existing_interest)
        event.interested_count = max(0, event.interested_count - 1)
        is_interested = False
    else:
        # Add interest
        new_interest = EventInterest(event_id=event_id, user_id=user.id)
        session.add(new_interest)
        event.interested_count += 1
        is_interested = True

    await session.commit()
    await session.refresh(event)

    return {
        "event_id": event_id,
        "is_interested": is_interested,
        "interested_count": event.interested_count
    }


@router.get("/{event_id}/interested", response_model=list[UserProfile])
async def get_interested_users(
    event_id: str,
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(50, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
) -> list[UserProfile]:
    """Get list of users interested in an event."""

    # Check if event exists
    stmt = select(CulturalEvent).where(CulturalEvent.id == event_id)
    result = await session.execute(stmt)
    event = result.scalar_one_or_none()

    if event is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Event with id '{event_id}' not found"
        )

    # Get interested users
    from sqlalchemy import join

    stmt = (
        select(User)
        .select_from(join(EventInterest, User, EventInterest.user_id == User.id))
        .where(EventInterest.event_id == event_id)
        .order_by(EventInterest.created_at.desc())
        .offset(skip)
        .limit(limit)
    )

    result = await session.execute(stmt)
    users = result.scalars().all()

    return [UserProfile.model_validate(user) for user in users]
