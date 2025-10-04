"""Admin API routes for database management and analytics."""
from typing import Any, Dict, List
import re

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession

from ...api.deps import get_current_user
from ...db.session import get_db
from ...models.user import User

router = APIRouter(prefix="/admin", tags=["admin"])


class SQLQueryRequest(BaseModel):
    """Schema for SQL query execution request."""

    query: str = Field(..., min_length=1, description="SQL query to execute")


class SQLQueryResponse(BaseModel):
    """Schema for SQL query execution response."""

    columns: List[str] = Field(..., description="Column names")
    rows: List[Dict[str, Any]] = Field(..., description="Query results as list of dicts")
    row_count: int = Field(..., description="Number of rows returned")


@router.post("/sql", response_model=SQLQueryResponse)
async def execute_sql_query(
    query_request: SQLQueryRequest,
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> SQLQueryResponse:
    """
    Execute a SQL query against the database (SELECT only, admin-only).

    Security restrictions:
    - Only SELECT queries are allowed
    - User must be a superuser/admin
    - Query timeout is enforced
    """

    # Check if user is admin
    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only administrators can execute SQL queries",
        )

    query = query_request.query.strip()

    # Security: Only allow SELECT queries
    if not re.match(r"^\s*SELECT\s+", query, re.IGNORECASE):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only SELECT queries are allowed for security reasons",
        )

    # Security: Block dangerous keywords
    dangerous_keywords = [
        "DROP",
        "DELETE",
        "INSERT",
        "UPDATE",
        "ALTER",
        "CREATE",
        "TRUNCATE",
        "GRANT",
        "REVOKE",
    ]
    query_upper = query.upper()
    for keyword in dangerous_keywords:
        if keyword in query_upper:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Query contains forbidden keyword: {keyword}",
            )

    try:
        # Execute query with timeout
        result = await session.execute(
            text(query).execution_options(timeout=30)
        )

        # Fetch results
        rows = result.fetchall()
        columns = list(result.keys()) if rows else []

        # Convert rows to list of dicts
        rows_as_dicts = [
            {col: value for col, value in zip(columns, row)}
            for row in rows
        ]

        return SQLQueryResponse(
            columns=columns,
            rows=rows_as_dicts,
            row_count=len(rows),
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Query execution error: {str(e)}",
        )


class DashboardStats(BaseModel):
    """Schema for dashboard statistics."""

    total_users: int
    total_events: int
    total_videos: int
    total_archive_entries: int
    total_messages: int
    total_communities: int
    total_likes: int
    total_comments: int
    total_shares: int


@router.get("/stats", response_model=DashboardStats)
async def get_dashboard_stats(
    session: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> DashboardStats:
    """Get dashboard statistics (admin only)."""

    if not current_user.is_superuser:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only administrators can access statistics",
        )

    try:
        # Count users
        result = await session.execute(text("SELECT COUNT(*) FROM users"))
        total_users = result.scalar() or 0

        # Count events
        result = await session.execute(text("SELECT COUNT(*) FROM cultural_events"))
        total_events = result.scalar() or 0

        # Count videos
        result = await session.execute(text("SELECT COUNT(*) FROM videos"))
        total_videos = result.scalar() or 0

        # Count archive entries
        result = await session.execute(text("SELECT COUNT(*) FROM archive_entries"))
        total_archive_entries = result.scalar() or 0

        # Count messages
        result = await session.execute(text("SELECT COUNT(*) FROM messages"))
        total_messages = result.scalar() or 0

        # Count communities
        result = await session.execute(text("SELECT COUNT(*) FROM community_profiles"))
        total_communities = result.scalar() or 0

        # Count video likes (appreciations)
        result = await session.execute(
            text("SELECT COUNT(*) FROM videos WHERE appreciations_count > 0")
        )
        total_likes = result.scalar() or 0

        # Count comments
        result = await session.execute(text("SELECT COUNT(*) FROM video_comments"))
        total_comments = result.scalar() or 0

        # Count shares
        result = await session.execute(text("SELECT COUNT(*) FROM video_shares"))
        total_shares = result.scalar() or 0

        return DashboardStats(
            total_users=total_users,
            total_events=total_events,
            total_videos=total_videos,
            total_archive_entries=total_archive_entries,
            total_messages=total_messages,
            total_communities=total_communities,
            total_likes=total_likes,
            total_comments=total_comments,
            total_shares=total_shares,
        )

    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to fetch statistics: {str(e)}",
        )
