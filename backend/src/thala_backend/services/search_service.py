"""MeiliSearch integration service for Thala backend."""
from typing import Any, Dict, List, Optional

import meilisearch_python_sdk
from fastapi import HTTPException, status
from meilisearch_python_sdk import AsyncClient
from meilisearch_python_sdk.models.settings import MeilisearchSettings
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from ..core.config import settings
from ..models.community import CommunityProfile
from ..models.event import CulturalEvent
from ..models.media import MusicTrack, Video


class SearchService:
    """Service for MeiliSearch operations."""

    # Index names
    INDEX_VIDEOS = "videos"
    INDEX_MUSIC = "music"
    INDEX_EVENTS = "events"
    INDEX_COMMUNITIES = "communities"

    def __init__(self, db: AsyncSession):
        """
        Initialize the search service.

        Args:
            db: Database session for syncing data
        """
        self.db = db
        self._validate_configuration()
        self.client = AsyncClient(
            url=settings.meilisearch_host,
            api_key=settings.meilisearch_api_key,
        )

    def _validate_configuration(self) -> None:
        """
        Validate that MeiliSearch configuration is properly set.

        Raises:
            HTTPException: If MeiliSearch is not configured
        """
        if not settings.meilisearch_host:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="MeiliSearch is not configured",
            )

    def _get_index_name(self, index_type: str) -> str:
        """
        Get prefixed index name.

        Args:
            index_type: Index type (videos, music, events, communities)

        Returns:
            Prefixed index name
        """
        return f"{settings.meilisearch_index_prefix}_{index_type}"

    async def initialize_indexes(self) -> None:
        """
        Initialize all MeiliSearch indexes with proper settings.

        This should be called during application startup to ensure indexes exist
        with correct configuration.
        """
        # Video index settings
        await self._create_index_with_settings(
            index_name=self._get_index_name(self.INDEX_VIDEOS),
            searchable_attributes=[
                "title_en",
                "title_fr",
                "description_en",
                "description_fr",
                "location_en",
                "location_fr",
                "creator_name_en",
                "creator_name_fr",
                "creator_handle",
                "tags",
            ],
            filterable_attributes=["creator_handle", "tags", "media_kind", "created_at"],
            sortable_attributes=["likes", "comments", "shares", "created_at"],
        )

        # Music index settings
        await self._create_index_with_settings(
            index_name=self._get_index_name(self.INDEX_MUSIC),
            searchable_attributes=["title", "artist"],
            filterable_attributes=["artist", "created_at"],
            sortable_attributes=["title", "artist", "created_at"],
        )

        # Events index settings
        await self._create_index_with_settings(
            index_name=self._get_index_name(self.INDEX_EVENTS),
            searchable_attributes=[
                "title.en",
                "title.fr",
                "description.en",
                "description.fr",
                "location.en",
                "location.fr",
            ],
            filterable_attributes=["mode", "start_at", "end_at", "created_at"],
            sortable_attributes=["start_at", "created_at"],
        )

        # Communities index settings
        await self._create_index_with_settings(
            index_name=self._get_index_name(self.INDEX_COMMUNITIES),
            searchable_attributes=[
                "space.en",
                "space.fr",
                "region",
                "languages",
            ],
            filterable_attributes=["region", "languages", "created_at"],
            sortable_attributes=["priority", "created_at"],
        )

    async def _create_index_with_settings(
        self,
        index_name: str,
        searchable_attributes: List[str],
        filterable_attributes: List[str],
        sortable_attributes: List[str],
    ) -> None:
        """
        Create or update index with specified settings.

        Args:
            index_name: Name of the index
            searchable_attributes: Attributes to search in
            filterable_attributes: Attributes that can be filtered
            sortable_attributes: Attributes that can be sorted
        """
        try:
            # Create index if it doesn't exist
            index = self.client.index(index_name)

            # Update settings
            await index.update_settings(
                MeilisearchSettings(
                    searchable_attributes=searchable_attributes,
                    filterable_attributes=filterable_attributes,
                    sortable_attributes=sortable_attributes,
                )
            )
        except Exception as exc:
            # Log error but don't fail - index might already exist
            print(f"Warning: Failed to create/update index {index_name}: {exc}")

    async def search_videos(
        self,
        query: str,
        filters: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
        sort: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """
        Search for videos.

        Args:
            query: Search query string
            filters: MeiliSearch filter expression
            limit: Maximum number of results
            offset: Pagination offset
            sort: List of sort expressions (e.g., ["likes:desc"])

        Returns:
            Search results dict with hits, total, and metadata
        """
        index = self.client.index(self._get_index_name(self.INDEX_VIDEOS))
        return await index.search(
            query=query,
            filter=filters,
            limit=limit,
            offset=offset,
            sort=sort,
        )

    async def search_music(
        self,
        query: str,
        filters: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> Dict[str, Any]:
        """
        Search for music tracks.

        Args:
            query: Search query string
            filters: MeiliSearch filter expression
            limit: Maximum number of results
            offset: Pagination offset

        Returns:
            Search results dict
        """
        index = self.client.index(self._get_index_name(self.INDEX_MUSIC))
        return await index.search(
            query=query,
            filter=filters,
            limit=limit,
            offset=offset,
        )

    async def search_events(
        self,
        query: str,
        filters: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
        sort: Optional[List[str]] = None,
    ) -> Dict[str, Any]:
        """
        Search for cultural events.

        Args:
            query: Search query string
            filters: MeiliSearch filter expression
            limit: Maximum number of results
            offset: Pagination offset
            sort: List of sort expressions

        Returns:
            Search results dict
        """
        index = self.client.index(self._get_index_name(self.INDEX_EVENTS))
        return await index.search(
            query=query,
            filter=filters,
            limit=limit,
            offset=offset,
            sort=sort,
        )

    async def search_communities(
        self,
        query: str,
        filters: Optional[str] = None,
        limit: int = 20,
        offset: int = 0,
    ) -> Dict[str, Any]:
        """
        Search for community profiles.

        Args:
            query: Search query string
            filters: MeiliSearch filter expression
            limit: Maximum number of results
            offset: Pagination offset

        Returns:
            Search results dict
        """
        index = self.client.index(self._get_index_name(self.INDEX_COMMUNITIES))
        return await index.search(
            query=query,
            filter=filters,
            limit=limit,
            offset=offset,
        )

    async def sync_videos(self, batch_size: int = 100) -> int:
        """
        Sync all videos from database to search index.

        Args:
            batch_size: Number of documents to index per batch

        Returns:
            Number of videos synced
        """
        index = self.client.index(self._get_index_name(self.INDEX_VIDEOS))

        # Fetch all videos from database
        stmt = select(Video)
        result = await self.db.execute(stmt)
        videos = result.scalars().all()

        # Convert to search documents
        documents = [self._video_to_search_doc(video) for video in videos]

        # Add to index in batches
        total_synced = 0
        for i in range(0, len(documents), batch_size):
            batch = documents[i : i + batch_size]
            await index.add_documents(batch)
            total_synced += len(batch)

        return total_synced

    async def sync_music(self, batch_size: int = 100) -> int:
        """
        Sync all music tracks from database to search index.

        Args:
            batch_size: Number of documents to index per batch

        Returns:
            Number of tracks synced
        """
        index = self.client.index(self._get_index_name(self.INDEX_MUSIC))

        stmt = select(MusicTrack)
        result = await self.db.execute(stmt)
        tracks = result.scalars().all()

        documents = [self._music_to_search_doc(track) for track in tracks]

        total_synced = 0
        for i in range(0, len(documents), batch_size):
            batch = documents[i : i + batch_size]
            await index.add_documents(batch)
            total_synced += len(batch)

        return total_synced

    async def sync_events(self, batch_size: int = 100) -> int:
        """
        Sync all cultural events from database to search index.

        Args:
            batch_size: Number of documents to index per batch

        Returns:
            Number of events synced
        """
        index = self.client.index(self._get_index_name(self.INDEX_EVENTS))

        stmt = select(CulturalEvent)
        result = await self.db.execute(stmt)
        events = result.scalars().all()

        documents = [self._event_to_search_doc(event) for event in events]

        total_synced = 0
        for i in range(0, len(documents), batch_size):
            batch = documents[i : i + batch_size]
            await index.add_documents(batch)
            total_synced += len(batch)

        return total_synced

    async def sync_communities(self, batch_size: int = 100) -> int:
        """
        Sync all community profiles from database to search index.

        Args:
            batch_size: Number of documents to index per batch

        Returns:
            Number of communities synced
        """
        index = self.client.index(self._get_index_name(self.INDEX_COMMUNITIES))

        stmt = select(CommunityProfile)
        result = await self.db.execute(stmt)
        communities = result.scalars().all()

        documents = [self._community_to_search_doc(community) for community in communities]

        total_synced = 0
        for i in range(0, len(documents), batch_size):
            batch = documents[i : i + batch_size]
            await index.add_documents(batch)
            total_synced += len(batch)

        return total_synced

    async def index_video(self, video: Video) -> None:
        """
        Index a single video document.

        Args:
            video: Video instance to index
        """
        index = self.client.index(self._get_index_name(self.INDEX_VIDEOS))
        doc = self._video_to_search_doc(video)
        await index.add_documents([doc])

    async def delete_video(self, video_id: str) -> None:
        """
        Delete a video from search index.

        Args:
            video_id: Video ID to delete
        """
        index = self.client.index(self._get_index_name(self.INDEX_VIDEOS))
        await index.delete_document(video_id)

    def _video_to_search_doc(self, video: Video) -> Dict[str, Any]:
        """
        Convert Video model to search document.

        Args:
            video: Video instance

        Returns:
            Search document dict
        """
        return {
            "id": video.id,
            "creator_id": str(video.creator_id) if video.creator_id else None,
            "creator_handle": video.creator_handle,
            "creator_name_en": video.creator_name_en,
            "creator_name_fr": video.creator_name_fr,
            "title_en": video.title_en,
            "title_fr": video.title_fr,
            "description_en": video.description_en,
            "description_fr": video.description_fr,
            "location_en": video.location_en,
            "location_fr": video.location_fr,
            "tags": video.tags,
            "media_kind": video.media_kind,
            "likes": video.likes,
            "comments": video.comments,
            "shares": video.shares,
            "created_at": video.created_at.timestamp() if video.created_at else None,
        }

    def _music_to_search_doc(self, track: MusicTrack) -> Dict[str, Any]:
        """
        Convert MusicTrack model to search document.

        Args:
            track: MusicTrack instance

        Returns:
            Search document dict
        """
        return {
            "id": track.id,
            "title": track.title,
            "artist": track.artist,
            "artwork_url": track.artwork_url,
            "duration_seconds": track.duration_seconds,
            "preview_url": track.preview_url,
            "created_at": track.created_at.timestamp() if track.created_at else None,
        }

    def _event_to_search_doc(self, event: CulturalEvent) -> Dict[str, Any]:
        """
        Convert CulturalEvent model to search document.

        Args:
            event: CulturalEvent instance

        Returns:
            Search document dict
        """
        return {
            "id": event.id,
            "title": event.title,  # JSONB with en/fr keys
            "date_label": event.date_label,
            "location": event.location,  # JSONB with en/fr keys
            "description": event.description,  # JSONB with en/fr keys
            "mode": event.mode,
            "start_at": event.start_at.timestamp() if event.start_at else None,
            "end_at": event.end_at.timestamp() if event.end_at else None,
            "tags": event.tags,
            "hero_image_url": event.hero_image_url,
            "created_at": event.created_at.timestamp() if event.created_at else None,
        }

    def _community_to_search_doc(self, community: CommunityProfile) -> Dict[str, Any]:
        """
        Convert CommunityProfile model to search document.

        Args:
            community: CommunityProfile instance

        Returns:
            Search document dict
        """
        return {
            "id": community.id,
            "space": community.space,  # JSONB with en/fr keys
            "region": community.region,
            "languages": community.languages,
            "priority": float(community.priority),
            "created_at": community.created_at.timestamp() if community.created_at else None,
        }


def get_search_service(db: AsyncSession) -> SearchService:
    """
    Dependency to get a SearchService instance.

    Args:
        db: Database session

    Returns:
        SearchService instance

    Raises:
        HTTPException: If MeiliSearch is not configured
    """
    return SearchService(db)
