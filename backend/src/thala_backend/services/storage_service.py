"""S3 storage service for Thala backend."""
import mimetypes
import uuid
from datetime import timedelta
from typing import BinaryIO, Optional

import aioboto3
from fastapi import HTTPException, UploadFile, status

from ..core.config import settings


class StorageService:
    """Service for handling S3/compatible storage operations."""

    # Supported MIME types for different media types
    SUPPORTED_VIDEO_TYPES = {
        "video/mp4",
        "video/mpeg",
        "video/quicktime",
        "video/x-msvideo",
        "video/webm",
    }

    SUPPORTED_IMAGE_TYPES = {
        "image/jpeg",
        "image/png",
        "image/gif",
        "image/webp",
        "image/svg+xml",
    }

    SUPPORTED_AUDIO_TYPES = {
        "audio/mpeg",
        "audio/mp4",
        "audio/ogg",
        "audio/wav",
        "audio/webm",
        "audio/aac",
    }

    def __init__(self):
        """Initialize the storage service."""
        self._validate_configuration()
        self.session = aioboto3.Session(
            aws_access_key_id=settings.aws_access_key_id,
            aws_secret_access_key=settings.aws_secret_access_key,
            region_name=settings.aws_region,
        )

    def _validate_configuration(self) -> None:
        """
        Validate that S3 configuration is properly set.

        Raises:
            HTTPException: If S3 is not configured
        """
        if not all(
            [
                settings.aws_region,
                settings.aws_s3_bucket,
                settings.aws_access_key_id,
                settings.aws_secret_access_key,
            ]
        ):
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="S3 storage is not configured",
            )

    async def upload_file(
        self,
        file: UploadFile,
        folder: str,
        allowed_types: set[str] | None = None,
        max_size_mb: int | None = None,
    ) -> str:
        """
        Upload a file to S3 storage.

        Args:
            file: FastAPI UploadFile instance
            folder: Folder path in S3 bucket (e.g., "videos", "images/avatars")
            allowed_types: Set of allowed MIME types (None allows all)
            max_size_mb: Maximum file size in MB (None for no limit)

        Returns:
            S3 object key (path) of the uploaded file

        Raises:
            HTTPException: If file validation fails or upload fails
        """
        # Validate content type
        if allowed_types and file.content_type not in allowed_types:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"Unsupported file type: {file.content_type}. Allowed types: {allowed_types}",
            )

        # Read file content
        content = await file.read()

        # Validate file size
        if max_size_mb:
            max_size_bytes = max_size_mb * 1024 * 1024
            if len(content) > max_size_bytes:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail=f"File size exceeds maximum of {max_size_mb}MB",
                )

        # Generate unique filename
        file_extension = self._get_file_extension(file.filename, file.content_type)
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        object_key = f"{folder.strip('/')}/{unique_filename}"

        # Upload to S3
        try:
            async with self.session.client(
                "s3", endpoint_url=settings.s3_endpoint_url
            ) as s3_client:
                await s3_client.put_object(
                    Bucket=settings.aws_s3_bucket,
                    Key=object_key,
                    Body=content,
                    ContentType=file.content_type or "application/octet-stream",
                    Metadata={
                        "original-filename": file.filename or "unknown",
                    },
                )
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to upload file: {str(exc)}",
            ) from exc

        return object_key

    async def upload_video(self, file: UploadFile, max_size_mb: int = 500) -> str:
        """
        Upload a video file to S3.

        Args:
            file: Video file to upload
            max_size_mb: Maximum file size in MB (default: 500MB)

        Returns:
            S3 object key of the uploaded video

        Raises:
            HTTPException: If validation or upload fails
        """
        return await self.upload_file(
            file=file,
            folder="videos",
            allowed_types=self.SUPPORTED_VIDEO_TYPES,
            max_size_mb=max_size_mb,
        )

    async def upload_image(self, file: UploadFile, max_size_mb: int = 10) -> str:
        """
        Upload an image file to S3.

        Args:
            file: Image file to upload
            max_size_mb: Maximum file size in MB (default: 10MB)

        Returns:
            S3 object key of the uploaded image

        Raises:
            HTTPException: If validation or upload fails
        """
        return await self.upload_file(
            file=file,
            folder="images",
            allowed_types=self.SUPPORTED_IMAGE_TYPES,
            max_size_mb=max_size_mb,
        )

    async def upload_audio(self, file: UploadFile, max_size_mb: int = 50) -> str:
        """
        Upload an audio file to S3.

        Args:
            file: Audio file to upload
            max_size_mb: Maximum file size in MB (default: 50MB)

        Returns:
            S3 object key of the uploaded audio

        Raises:
            HTTPException: If validation or upload fails
        """
        return await self.upload_file(
            file=file,
            folder="audio",
            allowed_types=self.SUPPORTED_AUDIO_TYPES,
            max_size_mb=max_size_mb,
        )

    async def generate_presigned_url(
        self, object_key: str, expiration_minutes: int = 60
    ) -> str:
        """
        Generate a presigned URL for downloading a file from S3.

        Args:
            object_key: S3 object key (path)
            expiration_minutes: URL expiration time in minutes (default: 60)

        Returns:
            Presigned URL string

        Raises:
            HTTPException: If URL generation fails
        """
        try:
            async with self.session.client(
                "s3", endpoint_url=settings.s3_endpoint_url
            ) as s3_client:
                url = await s3_client.generate_presigned_url(
                    "get_object",
                    Params={
                        "Bucket": settings.aws_s3_bucket,
                        "Key": object_key,
                    },
                    ExpiresIn=expiration_minutes * 60,
                )
                return url
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to generate presigned URL: {str(exc)}",
            ) from exc

    async def delete_file(self, object_key: str) -> None:
        """
        Delete a file from S3 storage.

        Args:
            object_key: S3 object key (path) to delete

        Raises:
            HTTPException: If deletion fails
        """
        try:
            async with self.session.client(
                "s3", endpoint_url=settings.s3_endpoint_url
            ) as s3_client:
                await s3_client.delete_object(
                    Bucket=settings.aws_s3_bucket,
                    Key=object_key,
                )
        except Exception as exc:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail=f"Failed to delete file: {str(exc)}",
            ) from exc

    async def check_file_exists(self, object_key: str) -> bool:
        """
        Check if a file exists in S3 storage.

        Args:
            object_key: S3 object key (path) to check

        Returns:
            True if file exists, False otherwise
        """
        try:
            async with self.session.client(
                "s3", endpoint_url=settings.s3_endpoint_url
            ) as s3_client:
                await s3_client.head_object(
                    Bucket=settings.aws_s3_bucket,
                    Key=object_key,
                )
                return True
        except Exception:
            return False

    def _get_file_extension(self, filename: str | None, content_type: str | None) -> str:
        """
        Determine file extension from filename or content type.

        Args:
            filename: Original filename
            content_type: MIME type

        Returns:
            File extension with leading dot (e.g., ".mp4")
        """
        # Try to get extension from filename
        if filename and "." in filename:
            return "." + filename.rsplit(".", 1)[1].lower()

        # Try to guess from content type
        if content_type:
            ext = mimetypes.guess_extension(content_type)
            if ext:
                return ext.lower()

        # Default to .bin if unable to determine
        return ".bin"

    def get_public_url(self, object_key: str) -> str:
        """
        Get the public URL for an S3 object (if bucket is public).

        Args:
            object_key: S3 object key (path)

        Returns:
            Public URL string
        """
        if settings.s3_endpoint_url:
            # Custom S3-compatible endpoint
            return f"{settings.s3_endpoint_url}/{settings.aws_s3_bucket}/{object_key}"
        else:
            # Standard AWS S3 URL
            return f"https://{settings.aws_s3_bucket}.s3.{settings.aws_region}.amazonaws.com/{object_key}"


def get_storage_service() -> StorageService:
    """
    Dependency to get a StorageService instance.

    Returns:
        StorageService instance

    Raises:
        HTTPException: If S3 is not configured
    """
    return StorageService()
