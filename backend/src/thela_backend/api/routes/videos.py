"""Video feed and interaction endpoints for the Thela backend."""
from typing import Any
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.media import (
    CreatorFollower,
    MusicTrack,
    Video,
    VideoComment,
    VideoEffect,
    VideoShare,
)
from ...models.user import User
from ...schemas.video import (
    CreatorFollowerResponse,
    VideoCommentCreate,
    VideoCommentResponse,
    VideoCreate,
    VideoEffectResponse,
    VideoResponse,
    VideoUpdate,
)

router = APIRouter(prefix="/videos", tags=["videos"])


@router.get("", response_model=list[VideoResponse])
async def list_videos(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
) -> list[VideoResponse]:
    """List videos for the feed with pagination."""

    stmt = (
        select(Video)
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
        .offset(skip)
        .limit(limit)
        .order_by(Video.created_at.desc())
    )

    result = await session.execute(stmt)
    videos = result.scalars().all()

    return [VideoResponse.model_validate(video) for video in videos]


@router.get("/{video_id}", response_model=VideoResponse)
async def get_video(
    video_id: str,
    session: AsyncSession = Depends(get_db),
) -> VideoResponse:
    """Get a single video by ID."""

    stmt = (
        select(Video)
        .where(Video.id == video_id)
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
    )

    result = await session.execute(stmt)
    video = result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    return VideoResponse.model_validate(video)


@router.post("", response_model=VideoResponse, status_code=status.HTTP_201_CREATED)
async def create_video(
    video_data: VideoCreate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> VideoResponse:
    """Create a new video (authenticated users only)."""

    # Check if video with this ID already exists
    existing_stmt = select(Video).where(Video.id == video_data.id)
    existing_result = await session.execute(existing_stmt)
    if existing_result.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Video with id '{video_data.id}' already exists"
        )

    # Validate music track if provided
    if video_data.music_track_id:
        music_stmt = select(MusicTrack).where(MusicTrack.id == video_data.music_track_id)
        music_result = await session.execute(music_stmt)
        if music_result.scalar_one_or_none() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Music track with id '{video_data.music_track_id}' not found"
            )

    # Validate effect if provided
    if video_data.effect_id:
        effect_stmt = select(VideoEffect).where(VideoEffect.id == video_data.effect_id)
        effect_result = await session.execute(effect_stmt)
        if effect_result.scalar_one_or_none() is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Video effect with id '{video_data.effect_id}' not found"
            )

    # Create video with authenticated user as creator
    video = Video(
        id=video_data.id,
        creator_id=user.id,
        creator_handle=video_data.creator_handle,
        creator_name_en=video_data.creator_name_en,
        creator_name_fr=video_data.creator_name_fr,
        video_url=video_data.video_url,
        video_source=video_data.video_source,
        media_kind=video_data.media_kind,
        image_url=video_data.image_url,
        gallery_urls=video_data.gallery_urls,
        text_slides=video_data.text_slides,
        aspect_ratio=video_data.aspect_ratio,
        thumbnail_url=video_data.thumbnail_url,
        music_track_id=video_data.music_track_id,
        effect_id=video_data.effect_id,
        title_en=video_data.title_en,
        title_fr=video_data.title_fr,
        description_en=video_data.description_en,
        description_fr=video_data.description_fr,
        location_en=video_data.location_en,
        location_fr=video_data.location_fr,
        tags=video_data.tags,
    )

    session.add(video)
    await session.commit()
    await session.refresh(video)

    # Load relationships
    stmt = (
        select(Video)
        .where(Video.id == video.id)
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
    )
    result = await session.execute(stmt)
    video = result.scalar_one()

    return VideoResponse.model_validate(video)


@router.put("/{video_id}", response_model=VideoResponse)
async def update_video(
    video_id: str,
    video_data: VideoUpdate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> VideoResponse:
    """Update an existing video (must be the creator)."""

    stmt = select(Video).where(Video.id == video_id)
    result = await session.execute(stmt)
    video = result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Check if user is the creator
    if video.creator_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to update this video"
        )

    # Update fields if provided
    update_data = video_data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(video, field, value)

    await session.commit()
    await session.refresh(video)

    # Load relationships
    stmt = (
        select(Video)
        .where(Video.id == video.id)
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
    )
    result = await session.execute(stmt)
    video = result.scalar_one()

    return VideoResponse.model_validate(video)


@router.delete("/{video_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_video(
    video_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    """Delete a video (must be the creator)."""

    stmt = select(Video).where(Video.id == video_id)
    result = await session.execute(stmt)
    video = result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Check if user is the creator
    if video.creator_id != user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You do not have permission to delete this video"
        )

    await session.delete(video)
    await session.commit()


@router.get("/{video_id}/comments", response_model=list[VideoCommentResponse])
async def list_video_comments(
    video_id: str,
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(50, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
) -> list[VideoCommentResponse]:
    """List comments for a video."""

    # Verify video exists
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    if video_result.scalar_one_or_none() is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    stmt = (
        select(VideoComment)
        .where(VideoComment.video_id == video_id)
        .offset(skip)
        .limit(limit)
        .order_by(VideoComment.created_at.desc())
    )

    result = await session.execute(stmt)
    comments = result.scalars().all()

    return [VideoCommentResponse.model_validate(comment) for comment in comments]


@router.post("/{video_id}/comments", response_model=VideoCommentResponse, status_code=status.HTTP_201_CREATED)
async def create_video_comment(
    video_id: str,
    comment_data: VideoCommentCreate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> VideoCommentResponse:
    """Add a comment to a video."""

    # Verify video exists
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    video = video_result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Create comment
    comment = VideoComment(
        video_id=video_id,
        user_id=user.id,
        content=comment_data.content,
    )

    session.add(comment)

    # Increment comment count on video
    video.comments += 1

    await session.commit()
    await session.refresh(comment)

    return VideoCommentResponse.model_validate(comment)


@router.post("/{video_id}/like", response_model=dict[str, Any])
async def toggle_video_like(
    video_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> dict[str, Any]:
    """Toggle like on a video (like if not liked, unlike if already liked)."""

    # Verify video exists
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    video = video_result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # For now, just increment/decrement the like count
    # In a full implementation, you'd track individual user likes in a separate table
    # This is a simplified version
    video.likes += 1

    await session.commit()

    return {
        "video_id": video_id,
        "liked": True,
        "likes": video.likes
    }


@router.post("/{video_id}/share", response_model=dict[str, Any], status_code=status.HTTP_201_CREATED)
async def record_video_share(
    video_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> dict[str, Any]:
    """Record a video share."""

    # Verify video exists
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    video = video_result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Create share record
    share = VideoShare(
        video_id=video_id,
        user_id=user.id,
    )

    session.add(share)

    # Increment share count on video
    video.shares += 1

    await session.commit()

    return {
        "video_id": video_id,
        "shares": video.shares
    }


@router.post("/{video_id}/follow", response_model=CreatorFollowerResponse, status_code=status.HTTP_201_CREATED)
async def follow_creator(
    video_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> CreatorFollowerResponse:
    """Follow the creator of a video."""

    # Get video to find creator
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    video = video_result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Check if already following
    existing_stmt = select(CreatorFollower).where(
        CreatorFollower.creator_handle == video.creator_handle,
        CreatorFollower.user_id == user.id
    )
    existing_result = await session.execute(existing_stmt)
    existing_follow = existing_result.scalar_one_or_none()

    if existing_follow:
        # Already following, return existing
        return CreatorFollowerResponse.model_validate(existing_follow)

    # Create follow relationship
    follower = CreatorFollower(
        creator_handle=video.creator_handle,
        user_id=user.id,
    )

    session.add(follower)
    await session.commit()
    await session.refresh(follower)

    return CreatorFollowerResponse.model_validate(follower)


@router.delete("/{video_id}/follow", status_code=status.HTTP_204_NO_CONTENT)
async def unfollow_creator(
    video_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    """Unfollow the creator of a video."""

    # Get video to find creator
    video_stmt = select(Video).where(Video.id == video_id)
    video_result = await session.execute(video_stmt)
    video = video_result.scalar_one_or_none()

    if video is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Video with id '{video_id}' not found"
        )

    # Find and delete follow relationship
    stmt = select(CreatorFollower).where(
        CreatorFollower.creator_handle == video.creator_handle,
        CreatorFollower.user_id == user.id
    )
    result = await session.execute(stmt)
    follower = result.scalar_one_or_none()

    if follower is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="You are not following this creator"
        )

    await session.delete(follower)
    await session.commit()


@router.get("/effects", response_model=list[VideoEffectResponse])
async def list_video_effects(
    session: AsyncSession = Depends(get_db),
) -> list[VideoEffectResponse]:
    """List all available video effects."""

    stmt = select(VideoEffect).order_by(VideoEffect.name)
    result = await session.execute(stmt)
    effects = result.scalars().all()

    return [VideoEffectResponse.model_validate(effect) for effect in effects]
