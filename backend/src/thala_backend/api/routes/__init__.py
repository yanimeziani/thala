from fastapi import APIRouter

from . import (
    admin,
    archive,
    auth,
    community,
    events,
    feedback,
    messages,
    music,
    search,
    upload,
    users,
    videos,
)

api_router = APIRouter()

# Include all route modules
api_router.include_router(auth.router)
api_router.include_router(admin.router)
api_router.include_router(videos.router)
api_router.include_router(music.router)
api_router.include_router(events.router)
api_router.include_router(community.router)
api_router.include_router(archive.router)
api_router.include_router(messages.router)
api_router.include_router(users.router)
api_router.include_router(search.router)
api_router.include_router(upload.router)
api_router.include_router(feedback.router)

__all__ = ["api_router"]
