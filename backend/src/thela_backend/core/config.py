from functools import lru_cache
from typing import List, Optional, Union

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Application configuration loaded from environment variables."""

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="allow")

    app_name: str = Field(default="Thela Backend")
    api_v1_prefix: str = Field(default="/api/v1")
    log_level: str = Field(default="INFO")

    database_url: str = Field(alias="DATABASE_URL")

    google_client_id: str = Field(alias="GOOGLE_OAUTH_CLIENT_ID")

    jwt_secret: str = Field(alias="JWT_SECRET")
    jwt_algorithm: str = Field(default="HS256")
    access_token_expiration_minutes: int = Field(default=60)
    refresh_token_expiration_minutes: int = Field(default=60 * 24 * 14)

    aws_region: Optional[str] = Field(default=None, alias="AWS_REGION")
    aws_s3_bucket: Optional[str] = Field(default=None, alias="AWS_S3_BUCKET")
    aws_access_key_id: Optional[str] = Field(default=None, alias="AWS_ACCESS_KEY_ID")
    aws_secret_access_key: Optional[str] = Field(default=None, alias="AWS_SECRET_ACCESS_KEY")
    s3_endpoint_url: Optional[str] = Field(default=None, alias="S3_ENDPOINT_URL")

    cors_allowed_origins: List[str] = Field(
        default_factory=list,
        alias="CORS_ALLOWED_ORIGINS",
        description="Origins permitted to access the API."
    )

    @field_validator("cors_allowed_origins", mode="before")
    @classmethod
    def parse_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        """Parse CORS origins from comma-separated string or JSON array."""
        if isinstance(v, str):
            # Handle empty string
            if not v or v.strip() == "":
                return []
            # Handle comma-separated values
            return [origin.strip() for origin in v.split(",") if origin.strip()]
        return v if v else []

    # MeiliSearch settings
    meilisearch_host: Optional[str] = Field(default=None, alias="MEILISEARCH_HOST")
    meilisearch_api_key: Optional[str] = Field(default=None, alias="MEILISEARCH_API_KEY")
    meilisearch_index_prefix: str = Field(default="thela", alias="MEILISEARCH_INDEX_PREFIX")

    # Rate limiting settings
    rate_limit_enabled: bool = Field(default=True, alias="RATE_LIMIT_ENABLED")
    rate_limit_requests_per_minute: int = Field(default=60, alias="RATE_LIMIT_REQUESTS_PER_MINUTE")
    rate_limit_burst: int = Field(default=10, alias="RATE_LIMIT_BURST")


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    """Return a cached Settings instance."""

    return Settings()


settings = get_settings()
