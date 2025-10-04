"""Feedback API routes for bug reports and feature requests."""
from typing import Optional
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.feedback import Feedback, FeedbackStatus, FeedbackType
from ...models.user import User
from ...schemas.feedback import FeedbackCreate, FeedbackResponse, FeedbackUpdate

router = APIRouter(prefix="/feedback", tags=["feedback"])


@router.post("", response_model=FeedbackResponse, status_code=status.HTTP_201_CREATED)
async def create_feedback(
    feedback_data: FeedbackCreate,
    session: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user),
) -> FeedbackResponse:
    """Submit new feedback (bug report, feature request, or general feedback)."""

    # Create feedback entry
    feedback = Feedback(
        user_id=current_user.id if current_user else None,
        user_email=feedback_data.user_email or (current_user.email if current_user else None),
        user_name=feedback_data.user_name or (current_user.full_name if current_user else None),
        feedback_type=feedback_data.feedback_type,
        title=feedback_data.title,
        description=feedback_data.description,
        platform=feedback_data.platform,
        app_version=feedback_data.app_version,
        device_info=feedback_data.device_info,
        has_screenshot=feedback_data.screenshot_url is not None,
        screenshot_url=feedback_data.screenshot_url,
    )

    session.add(feedback)
    await session.commit()
    await session.refresh(feedback)

    return FeedbackResponse.model_validate(feedback)


@router.get("", response_model=list[FeedbackResponse])
async def list_feedback(
    feedback_type: Optional[FeedbackType] = Query(None, description="Filter by feedback type"),
    status_filter: Optional[FeedbackStatus] = Query(None, description="Filter by status"),
    platform: Optional[str] = Query(None, description="Filter by platform"),
    is_public: Optional[bool] = Query(None, description="Filter by public visibility"),
    limit: int = Query(50, ge=1, le=200, description="Maximum number of results"),
    offset: int = Query(0, ge=0, description="Offset for pagination"),
    session: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user),
) -> list[FeedbackResponse]:
    """
    List feedback entries.

    - Non-authenticated users: can only see public feedback
    - Authenticated users: can see their own feedback + public feedback
    - Admins: can see all feedback
    """

    query = select(Feedback)

    # Apply filters
    if feedback_type:
        query = query.where(Feedback.feedback_type == feedback_type)
    if status_filter:
        query = query.where(Feedback.status == status_filter)
    if platform:
        query = query.where(Feedback.platform == platform)

    # Apply visibility filter based on user
    if not current_user:
        # Non-authenticated: only public feedback
        query = query.where(Feedback.is_public == True)
    elif not current_user.is_superuser:
        # Authenticated non-admin: own feedback or public
        query = query.where(
            (Feedback.user_id == current_user.id) | (Feedback.is_public == True)
        )
    # Admins see everything, no additional filter

    if is_public is not None:
        query = query.where(Feedback.is_public == is_public)

    # Order by most recent first
    query = query.order_by(desc(Feedback.created_at))

    # Apply pagination
    query = query.limit(limit).offset(offset)

    result = await session.execute(query)
    feedback_list = result.scalars().all()

    return [FeedbackResponse.model_validate(f) for f in feedback_list]


@router.get("/{feedback_id}", response_model=FeedbackResponse)
async def get_feedback(
    feedback_id: UUID,
    session: AsyncSession = Depends(get_db),
    current_user: Optional[User] = Depends(get_current_user),
) -> FeedbackResponse:
    """Get a specific feedback entry by ID."""

    result = await session.execute(select(Feedback).where(Feedback.id == feedback_id))
    feedback = result.scalar_one_or_none()

    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Feedback with id '{feedback_id}' not found",
        )

    # Check visibility permissions
    if not feedback.is_public:
        if not current_user:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="This feedback is not public",
            )
        if feedback.user_id != current_user.id and not current_user.is_superuser:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You do not have permission to view this feedback",
            )

    return FeedbackResponse.model_validate(feedback)


@router.patch("/{feedback_id}", response_model=FeedbackResponse)
async def update_feedback(
    feedback_id: UUID,
    update_data: FeedbackUpdate,
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> FeedbackResponse:
    """Update feedback (admin only)."""

    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only admins can update feedback",
        )

    result = await session.execute(select(Feedback).where(Feedback.id == feedback_id))
    feedback = result.scalar_one_or_none()

    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Feedback with id '{feedback_id}' not found",
        )

    # Update fields
    if update_data.status is not None:
        feedback.status = update_data.status
        # Set resolved_at if status is completed or wont_fix
        if update_data.status in [FeedbackStatus.COMPLETED, FeedbackStatus.WONT_FIX]:
            from datetime import datetime, timezone
            feedback.resolved_at = datetime.now(timezone.utc)

    if update_data.priority is not None:
        feedback.priority = update_data.priority
    if update_data.admin_notes is not None:
        feedback.admin_notes = update_data.admin_notes
    if update_data.is_public is not None:
        feedback.is_public = update_data.is_public

    await session.commit()
    await session.refresh(feedback)

    return FeedbackResponse.model_validate(feedback)


@router.delete("/{feedback_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_feedback(
    feedback_id: UUID,
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> None:
    """Delete feedback (admin only or own feedback)."""

    result = await session.execute(select(Feedback).where(Feedback.id == feedback_id))
    feedback = result.scalar_one_or_none()

    if not feedback:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Feedback with id '{feedback_id}' not found",
        )

    # Check permissions: admin or own feedback
    if feedback.user_id != current_user.id and not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to delete this feedback",
        )

    await session.delete(feedback)
    await session.commit()
