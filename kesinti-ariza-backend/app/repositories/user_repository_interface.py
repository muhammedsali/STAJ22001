from abc import ABC, abstractmethod
from typing import Optional
from sqlalchemy.orm import Session
from app.models.user import User

class IUserRepository(ABC):
    @abstractmethod
    def get_by_email(self, db: Session, email: str) -> Optional[User]:
        pass

    @abstractmethod
    def create(self, db: Session, obj_in: dict) -> User:
        pass