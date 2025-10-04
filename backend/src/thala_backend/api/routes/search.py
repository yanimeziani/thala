"""Search endpoints for the Thala backend."""
from typing import Any

from fastapi import APIRouter, Depends, Query
from sqlalchemy import or_, select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from ...db.session import get_db
from ...models.archive import ArchiveEntry
from ...models.community import CommunityProfile
from ...models.event import CulturalEvent
from ...models.media import MusicTrack, Video
from ...schemas.archive import ArchiveEntryResponse
from ...schemas.community import CommunityProfileResponse
from ...schemas.event import CulturalEventResponse
from ...schemas.music import MusicTrackResponse
from ...schemas.video import VideoResponse

router = APIRouter(prefix="/search", tags=["search"])


@router.get("", response_model=dict[str, Any])
async def universal_search(
    q: str = Query(..., min_length=1, description="Search query"),
    limit: int = Query(10, ge=1, le=50, description="Max results per category"),
    session: AsyncSession = Depends(get_db),
) -> dict[str, Any]:
    """Universal search across all content types."""

    search_term = f"%{q}%"

    # Search videos
    video_stmt = (
        select(Video)
        .where(
            or_(
                Video.title_en.ilike(search_term),
                Video.title_fr.ilike(search_term),
                Video.description_en.ilike(search_term),
                Video.description_fr.ilike(search_term),
                Video.creator_handle.ilike(search_term),
            )
        )
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
        .limit(limit)
    )
    video_result = await session.execute(video_stmt)
    videos = [VideoResponse.model_validate(v) for v in video_result.scalars().all()]

    # Search music
    music_stmt = (
        select(MusicTrack)
        .where(
            or_(
                MusicTrack.title.ilike(search_term),
                MusicTrack.artist.ilike(search_term),
            )
        )
        .limit(limit)
    )
    music_result = await session.execute(music_stmt)
    music = [MusicTrackResponse.model_validate(m) for m in music_result.scalars().all()]

    # Search events
    # Note: JSONB fields need special handling, simplified here
    event_stmt = select(CulturalEvent).limit(limit)
    event_result = await session.execute(event_stmt)
    events = [CulturalEventResponse.model_validate(e) for e in event_result.scalars().all()]

    # Search communities
    community_stmt = select(CommunityProfile).limit(limit)
    community_result = await session.execute(community_stmt)
    communities = [CommunityProfileResponse.model_validate(c) for c in community_result.scalars().all()]

    # Search archive
    archive_stmt = select(ArchiveEntry).limit(limit)
    archive_result = await session.execute(archive_stmt)
    archive = [ArchiveEntryResponse.model_validate(a) for a in archive_result.scalars().all()]

    return {
        "query": q,
        "results": {
            "videos": videos,
            "music": music,
            "events": events,
            "communities": communities,
            "archive": archive,
        },
        "total_results": len(videos) + len(music) + len(events) + len(communities) + len(archive)
    }


@router.get("/videos", response_model=list[VideoResponse])
async def search_videos(
    q: str = Query(..., min_length=1, description="Search query"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    session: AsyncSession = Depends(get_db),
) -> list[VideoResponse]:
    """Search videos by title, description, creator, or tags."""

    search_term = f"%{q}%"

    stmt = (
        select(Video)
        .where(
            or_(
                Video.title_en.ilike(search_term),
                Video.title_fr.ilike(search_term),
                Video.description_en.ilike(search_term),
                Video.description_fr.ilike(search_term),
                Video.creator_handle.ilike(search_term),
                Video.creator_name_en.ilike(search_term),
                Video.creator_name_fr.ilike(search_term),
            )
        )
        .options(
            selectinload(Video.music_track),
            selectinload(Video.effect),
        )
        .limit(limit)
        .order_by(Video.created_at.desc())
    )

    result = await session.execute(stmt)
    videos = result.scalars().all()

    return [VideoResponse.model_validate(video) for video in videos]


@router.get("/music", response_model=list[MusicTrackResponse])
async def search_music(
    q: str = Query(..., min_length=1, description="Search query"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    session: AsyncSession = Depends(get_db),
) -> list[MusicTrackResponse]:
    """Search music tracks by title or artist."""

    search_term = f"%{q}%"

    stmt = (
        select(MusicTrack)
        .where(
            or_(
                MusicTrack.title.ilike(search_term),
                MusicTrack.artist.ilike(search_term),
            )
        )
        .limit(limit)
        .order_by(MusicTrack.created_at.desc())
    )

    result = await session.execute(stmt)
    tracks = result.scalars().all()

    return [MusicTrackResponse.model_validate(track) for track in tracks]


@router.get("/events", response_model=list[CulturalEventResponse])
async def search_events(
    q: str = Query(..., min_length=1, description="Search query"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    session: AsyncSession = Depends(get_db),
) -> list[CulturalEventResponse]:
    """Search cultural events."""

    # Note: Searching JSONB fields requires special PostgreSQL syntax
    # This is a simplified version that returns all events
    # In production, you'd use JSONB operators like @>, ?, etc.

    stmt = (
        select(CulturalEvent)
        .limit(limit)
        .order_by(CulturalEvent.start_at.asc())
    )

    result = await session.execute(stmt)
    events = result.scalars().all()

    # Filter in Python for simplicity (not optimal for large datasets)
    search_term_lower = q.lower()
    filtered_events = []

    for event in events:
        # Check if search term appears in any localized field
        if (
            search_term_lower in str(event.title).lower() or
            search_term_lower in str(event.description).lower() or
            search_term_lower in str(event.location).lower()
        ):
            filtered_events.append(event)

    return [CulturalEventResponse.model_validate(event) for event in filtered_events[:limit]]


@router.get("/communities", response_model=list[CommunityProfileResponse])
async def search_communities(
    q: str = Query(..., min_length=1, description="Search query"),
    limit: int = Query(20, ge=1, le=100, description="Number of results to return"),
    session: AsyncSession = Depends(get_db),
) -> list[CommunityProfileResponse]:
    """Search community profiles."""

    # Note: Searching JSONB fields requires special PostgreSQL syntax
    # This is a simplified version that returns all communities
    # In production, you'd use JSONB operators

    stmt = (
        select(CommunityProfile)
        .limit(limit)
        .order_by(CommunityProfile.priority.desc())
    )

    result = await session.execute(stmt)
    profiles = result.scalars().all()

    # Filter in Python for simplicity
    search_term_lower = q.lower()
    filtered_profiles = []

    for profile in profiles:
        # Check if search term appears in any field
        if (
            search_term_lower in str(profile.space).lower() or
            search_term_lower in profile.region.lower() or
            any(search_term_lower in lang.lower() for lang in profile.languages)
        ):
            filtered_profiles.append(profile)

    return [CommunityProfileResponse.model_validate(profile) for profile in filtered_profiles[:limit]]
