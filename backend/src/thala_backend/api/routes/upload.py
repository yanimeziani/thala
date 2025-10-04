"""Media upload endpoints for the Thala backend."""
import uuid
from datetime import datetime, timedelta
from typing import Literal

from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status

from ...api.deps import get_current_user
from ...core.config import settings
from ...models.user import User

router = APIRouter(prefix="/upload", tags=["upload"])


def generate_s3_url(file_key: str) -> str:
    """Generate a mock S3 URL for uploaded files."""
    if settings.aws_s3_bucket and settings.aws_region:
        return f"https://{settings.aws_s3_bucket}.s3.{settings.aws_region}.amazonaws.com/{file_key}"
    return f"https://storage.example.com/{file_key}"


def generate_presigned_url(file_key: str, expiration: int = 3600) -> str:
    """Generate a presigned URL for direct S3 uploads."""
    # In a real implementation, this would use boto3 to generate actual presigned URLs
    # For now, return a mock URL
    if settings.aws_s3_bucket and settings.aws_region:
        expires = datetime.utcnow() + timedelta(seconds=expiration)
        return f"https://{settings.aws_s3_bucket}.s3.{settings.aws_region}.amazonaws.com/{file_key}?X-Amz-Expires={expiration}"
    return f"https://storage.example.com/presigned/{file_key}?expires={expiration}"


@router.post("/video", response_model=dict[str, str])
async def upload_video(
    file: UploadFile = File(..., description="Video file to upload"),
    user: User = Depends(get_current_user),
) -> dict[str, str]:
    """Upload a video file (authenticated users only)."""

    # Validate file type
    if not file.content_type or not file.content_type.startswith("video/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be a video"
        )

    # Generate unique file key
    file_extension = file.filename.split(".")[-1] if file.filename and "." in file.filename else "mp4"
    file_key = f"videos/{user.id}/{uuid.uuid4()}.{file_extension}"

    # In a real implementation, you would:
    # 1. Read the file contents: contents = await file.read()
    # 2. Upload to S3 using boto3
    # 3. Generate thumbnail
    # 4. Return actual S3 URL

    # For now, return a mock URL
    video_url = generate_s3_url(file_key)

    return {
        "video_url": video_url,
        "file_key": file_key,
        "content_type": file.content_type,
        "message": "Video uploaded successfully (mock)"
    }


@router.post("/image", response_model=dict[str, str])
async def upload_image(
    file: UploadFile = File(..., description="Image file to upload"),
    user: User = Depends(get_current_user),
) -> dict[str, str]:
    """Upload an image file (authenticated users only)."""

    # Validate file type
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an image"
        )

    # Generate unique file key
    file_extension = file.filename.split(".")[-1] if file.filename and "." in file.filename else "jpg"
    file_key = f"images/{user.id}/{uuid.uuid4()}.{file_extension}"

    # In a real implementation, you would:
    # 1. Read the file contents
    # 2. Optionally resize/optimize the image
    # 3. Upload to S3
    # 4. Return actual S3 URL

    image_url = generate_s3_url(file_key)

    return {
        "image_url": image_url,
        "file_key": file_key,
        "content_type": file.content_type,
        "message": "Image uploaded successfully (mock)"
    }


@router.post("/audio", response_model=dict[str, str])
async def upload_audio(
    file: UploadFile = File(..., description="Audio file to upload"),
    user: User = Depends(get_current_user),
) -> dict[str, str]:
    """Upload an audio file (authenticated users only)."""

    # Validate file type
    if not file.content_type or not file.content_type.startswith("audio/"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="File must be an audio file"
        )

    # Generate unique file key
    file_extension = file.filename.split(".")[-1] if file.filename and "." in file.filename else "mp3"
    file_key = f"audio/{user.id}/{uuid.uuid4()}.{file_extension}"

    # In a real implementation, you would:
    # 1. Read the file contents
    # 2. Optionally transcode/optimize the audio
    # 3. Upload to S3
    # 4. Return actual S3 URL

    audio_url = generate_s3_url(file_key)

    return {
        "audio_url": audio_url,
        "file_key": file_key,
        "content_type": file.content_type,
        "message": "Audio uploaded successfully (mock)"
    }


@router.get("/presigned-url", response_model=dict[str, str])
async def get_presigned_upload_url(
    file_type: Literal["video", "image", "audio"] = Query(..., description="Type of file to upload"),
    file_extension: str = Query(..., description="File extension (e.g., 'mp4', 'jpg', 'mp3')"),
    user: User = Depends(get_current_user),
) -> dict[str, str]:
    """
    Get a presigned URL for direct client-side upload to S3.

    This allows clients to upload files directly to S3 without going through the API server,
    which is more efficient for large files.
    """

    # Generate unique file key based on file type
    file_key = f"{file_type}s/{user.id}/{uuid.uuid4()}.{file_extension}"

    # In a real implementation, you would:
    # 1. Use boto3.client('s3').generate_presigned_post() or generate_presigned_url()
    # 2. Set appropriate permissions and expiration
    # 3. Return the actual presigned URL and required fields

    presigned_url = generate_presigned_url(file_key, expiration=3600)
    final_url = generate_s3_url(file_key)

    return {
        "presigned_url": presigned_url,
        "file_key": file_key,
        "final_url": final_url,
        "expiration_seconds": 3600,
        "message": "Presigned URL generated successfully (mock)"
    }
