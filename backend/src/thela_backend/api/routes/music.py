"""Music library endpoints for the Thela backend."""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.media import MusicTrack
from ...models.user import User
from ...schemas.music import MusicTrackCreate, MusicTrackResponse

router = APIRouter(prefix="/music", tags=["music"])


@router.get("", response_model=list[MusicTrackResponse])
async def list_music_tracks(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(50, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
) -> list[MusicTrackResponse]:
    """List all music tracks with pagination."""

    stmt = (
        select(MusicTrack)
        .offset(skip)
        .limit(limit)
        .order_by(MusicTrack.created_at.desc())
    )

    result = await session.execute(stmt)
    tracks = result.scalars().all()

    return [MusicTrackResponse.model_validate(track) for track in tracks]


@router.get("/{track_id}", response_model=MusicTrackResponse)
async def get_music_track(
    track_id: str,
    session: AsyncSession = Depends(get_db),
) -> MusicTrackResponse:
    """Get a single music track by ID."""

    stmt = select(MusicTrack).where(MusicTrack.id == track_id)
    result = await session.execute(stmt)
    track = result.scalar_one_or_none()

    if track is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Music track with id '{track_id}' not found"
        )

    return MusicTrackResponse.model_validate(track)


@router.post("", response_model=MusicTrackResponse, status_code=status.HTTP_201_CREATED)
async def create_music_track(
    track_data: MusicTrackCreate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> MusicTrackResponse:
    """Create a new music track (authenticated users only, admin recommended)."""

    # Check if track with this ID already exists
    existing_stmt = select(MusicTrack).where(MusicTrack.id == track_data.id)
    existing_result = await session.execute(existing_stmt)
    if existing_result.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Music track with id '{track_data.id}' already exists"
        )

    # Create new music track
    track = MusicTrack(
        id=track_data.id,
        title=track_data.title,
        artist=track_data.artist,
        artwork_url=track_data.artwork_url,
        duration_seconds=track_data.duration_seconds,
        preview_url=track_data.preview_url,
    )

    session.add(track)
    await session.commit()
    await session.refresh(track)

    return MusicTrackResponse.model_validate(track)


@router.put("/{track_id}", response_model=MusicTrackResponse)
async def update_music_track(
    track_id: str,
    track_data: MusicTrackCreate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> MusicTrackResponse:
    """Update an existing music track (authenticated users only, admin recommended)."""

    stmt = select(MusicTrack).where(MusicTrack.id == track_id)
    result = await session.execute(stmt)
    track = result.scalar_one_or_none()

    if track is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Music track with id '{track_id}' not found"
        )

    # Update track fields
    track.title = track_data.title
    track.artist = track_data.artist
    track.artwork_url = track_data.artwork_url
    track.duration_seconds = track_data.duration_seconds
    track.preview_url = track_data.preview_url

    await session.commit()
    await session.refresh(track)

    return MusicTrackResponse.model_validate(track)


@router.delete("/{track_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_music_track(
    track_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> None:
    """Delete a music track (authenticated users only, admin recommended)."""

    stmt = select(MusicTrack).where(MusicTrack.id == track_id)
    result = await session.execute(stmt)
    track = result.scalar_one_or_none()

    if track is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Music track with id '{track_id}' not found"
        )

    await session.delete(track)
    await session.commit()
