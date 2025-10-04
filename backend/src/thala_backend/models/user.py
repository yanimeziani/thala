import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, Column, DateTime, String, Text, UniqueConstraint, func
from sqlalchemy.dialects.postgresql import JSONB, UUID

from ..db.base import Base


class User(Base):
    __tablename__ = "users"
    __table_args__ = (
        UniqueConstraint("google_sub", name="uq_users_google_sub"),
        UniqueConstraint("email", name="uq_users_email"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    google_sub = Column(String(255), nullable=False)
    email = Column(String(320), nullable=False)
    full_name = Column(String(255), nullable=True)
    picture = Column(Text, nullable=True)
    locale = Column(String(16), nullable=True)
    is_active = Column(Boolean, nullable=False, default=True)
    profile = Column(JSONB, nullable=False, default=dict)

    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), nullable=False, server_default=func.now(), server_onupdate=func.now()
    )
    last_login_at = Column(DateTime(timezone=True), nullable=True)

    def touch_last_login(self) -> None:
        self.last_login_at = datetime.now(timezone.utc)
