"""Messaging endpoints for the Thala backend."""
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.message import Message, MessageThread
from ...models.user import User
from ...schemas.message import (
    ContactHandleResponse,
    MessageCreate,
    MessageResponse,
    MessageThreadResponse,
)

router = APIRouter(prefix="/messages", tags=["messages"])


@router.get("/threads", response_model=list[MessageThreadResponse])
async def list_message_threads(
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(50, ge=1, le=100, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[MessageThreadResponse]:
    """List message threads for the authenticated user."""

    # In a full implementation, you'd filter threads where the user is a participant
    # For now, we'll return all threads ordered by most recent activity
    stmt = (
        select(MessageThread)
        .offset(skip)
        .limit(limit)
        .order_by(MessageThread.updated_at.desc())
    )

    result = await session.execute(stmt)
    threads = result.scalars().all()

    return [MessageThreadResponse.model_validate(thread) for thread in threads]


@router.get("/threads/{thread_id}", response_model=MessageThreadResponse)
async def get_message_thread(
    thread_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> MessageThreadResponse:
    """Get a message thread with its details."""

    stmt = select(MessageThread).where(MessageThread.id == thread_id)
    result = await session.execute(stmt)
    thread = result.scalar_one_or_none()

    if thread is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Thread with id '{thread_id}' not found"
        )

    # In a full implementation, verify user is a participant

    return MessageThreadResponse.model_validate(thread)


@router.get("/threads/{thread_id}/messages", response_model=list[MessageResponse])
async def list_thread_messages(
    thread_id: str,
    skip: int = Query(0, ge=0, description="Number of items to skip"),
    limit: int = Query(100, ge=1, le=200, description="Number of items to return"),
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[MessageResponse]:
    """Get messages in a thread."""

    # Verify thread exists
    thread_stmt = select(MessageThread).where(MessageThread.id == thread_id)
    thread_result = await session.execute(thread_stmt)
    if thread_result.scalar_one_or_none() is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Thread with id '{thread_id}' not found"
        )

    # Get messages
    stmt = (
        select(Message)
        .where(Message.thread_id == thread_id)
        .offset(skip)
        .limit(limit)
        .order_by(Message.created_at.asc())
    )

    result = await session.execute(stmt)
    messages = result.scalars().all()

    return [MessageResponse.model_validate(msg) for msg in messages]


@router.post("/threads", response_model=MessageThreadResponse, status_code=status.HTTP_201_CREATED)
async def create_message_thread(
    thread_data: MessageThreadResponse,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> MessageThreadResponse:
    """Create a new message thread."""

    # Check if thread with this ID already exists
    existing_stmt = select(MessageThread).where(MessageThread.id == thread_data.id)
    existing_result = await session.execute(existing_stmt)
    if existing_result.scalar_one_or_none() is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"Thread with id '{thread_data.id}' already exists"
        )

    # Create new thread
    thread = MessageThread(
        id=thread_data.id,
        title_en=thread_data.title_en,
        title_fr=thread_data.title_fr,
        last_message_en=thread_data.last_message_en,
        last_message_fr=thread_data.last_message_fr,
        unread_count=thread_data.unread_count,
        participants=thread_data.participants,
        avatar_url=thread_data.avatar_url,
    )

    session.add(thread)
    await session.commit()
    await session.refresh(thread)

    return MessageThreadResponse.model_validate(thread)


@router.post("/threads/{thread_id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    thread_id: str,
    message_data: MessageCreate,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> MessageResponse:
    """Send a message in a thread."""

    # Verify thread exists
    thread_stmt = select(MessageThread).where(MessageThread.id == thread_id)
    thread_result = await session.execute(thread_stmt)
    thread = thread_result.scalar_one_or_none()

    if thread is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Thread with id '{thread_id}' not found"
        )

    # Ensure thread_id matches
    if message_data.thread_id != thread_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Thread ID in URL and message data must match"
        )

    # Create message
    message = Message(
        thread_id=thread_id,
        author_handle=message_data.author_handle,
        author_display_name=message_data.author_display_name,
        body=message_data.body,
        delivery_status=message_data.delivery_status,
    )

    session.add(message)

    # Update thread's last message preview (simplified - just use body for both languages)
    thread.last_message_en = message_data.body[:100]
    thread.last_message_fr = message_data.body[:100]

    await session.commit()
    await session.refresh(message)

    return MessageResponse.model_validate(message)


@router.put("/threads/{thread_id}/read", status_code=status.HTTP_200_OK)
async def mark_thread_as_read(
    thread_id: str,
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> dict[str, str]:
    """Mark a message thread as read (reset unread count)."""

    stmt = select(MessageThread).where(MessageThread.id == thread_id)
    result = await session.execute(stmt)
    thread = result.scalar_one_or_none()

    if thread is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Thread with id '{thread_id}' not found"
        )

    # Reset unread count
    thread.unread_count = 0

    await session.commit()

    return {"status": "success", "message": f"Thread '{thread_id}' marked as read"}


@router.get("/contacts/search", response_model=list[ContactHandleResponse])
async def search_contacts(
    query: str = Query(..., min_length=1, description="Search query for contacts"),
    limit: int = Query(20, ge=1, le=50, description="Number of results to return"),
    session: AsyncSession = Depends(get_db),
    user: User = Depends(get_current_user),
) -> list[ContactHandleResponse]:
    """Search for contacts by handle or display name."""

    # In a full implementation, this would search across users or a contacts table
    # For now, return an empty list as placeholder
    # You could integrate with the User model to search by full_name or handle

    # Example implementation would be:
    # stmt = select(User).where(
    #     or_(
    #         User.full_name.ilike(f"%{query}%"),
    #         User.handle.ilike(f"%{query}%")
    #     )
    # ).limit(limit)

    return []
