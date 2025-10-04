"""Cultural archive endpoints for the Thala backend."""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.archive import ArchiveEntry
from ...models.user import User
from ...schemas.archive import ArchiveEntryResponse

router = APIRouter(prefix="/archive", tags=["archive"])


@router.get("", response_model=list[ArchiveEntryResponse])
async def list_archive_entries(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(20, ge=1, le=100, description="Number of items to return"),
    category: str | None = Query(None, description="Filter by category"),
    session: AsyncSession = Depends(get_db),
) -> list[ArchiveEntryResponse]:
    """List archive entries with pagination and optional category filter."""

    stmt = select(ArchiveEntry)

    # Apply category filter if provided
    if category:
        stmt = stmt.where(ArchiveEntry.category == category)

    stmt = (
        stmt
        .offset(skip)
        .limit(limit)
        .order_by(ArchiveEntry.community_upvotes.desc(), ArchiveEntry.created_at.desc())
    )

    result = await session.execute(stmt)
    entries = result.scalars().all()

    return [ArchiveEntryResponse.model_validate(entry) for entry in entries]


@router.get("/{entry_id}", response_model=ArchiveEntryResponse)
async def get_archive_entry(
    entry_id: str,
    session: AsyncSession = Depends(get_db),
) -> ArchiveEntryResponse:
    """Get a single archive entry by ID."""

    stmt = select(ArchiveEntry).where(ArchiveEntry.id == entry_id)
    result = await session.execute(stmt)
    entry = result.scalar_one_or_none()

    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Archive entry with id '{entry_id}' not found"
        )

    return ArchiveEntryResponse.model_validate(entry)


@router.post("", response_model=ArchiveEntryResponse, status_code=status.HTTP_201_CREATED)
async def create_archive_entry(
    entry_data: ArchiveEntryResponse,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> ArchiveEntryResponse:
    """Create a new archive entry (authenticated users only)."""

    # Check if entry with this ID already exists
    existing_stmt = select(ArchiveEntry).where(ArchiveEntry.id == entry_data.id)
    existing_result = await session.execute(existing_stmt)
    if existing_result.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Archive entry with id '{entry_data.id}' already exists"
        )

    # Create new archive entry
    entry = ArchiveEntry(
        id=entry_data.id,
        title=entry_data.title,
        summary=entry_data.summary,
        era=entry_data.era,
        category=entry_data.category,
        thumbnail_url=entry_data.thumbnail_url,
        community_upvotes=entry_data.community_upvotes,
        registered_users=entry_data.registered_users,
        required_approval_percent=entry_data.required_approval_percent,
    )

    session.add(entry)
    await session.commit()
    await session.refresh(entry)

    return ArchiveEntryResponse.model_validate(entry)


@router.post("/{entry_id}/upvote", response_model=dict[str, int])
async def upvote_archive_entry(
    entry_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> dict[str, int]:
    """Upvote an archive entry (authenticated users only)."""

    stmt = select(ArchiveEntry).where(ArchiveEntry.id == entry_id)
    result = await session.execute(stmt)
    entry = result.scalar_one_or_none()

    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Archive entry with id '{entry_id}' not found"
        )

    # Increment upvote counts
    # In a full implementation, you'd track individual user upvotes in a separate table
    # to prevent duplicate upvotes. This is a simplified version.
    entry.community_upvotes += 1
    entry.registered_users += 1

    await session.commit()

    return {
        "community_upvotes": entry.community_upvotes,
        "registered_users": entry.registered_users
    }
