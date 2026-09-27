from typing import Optional
from sqlalchemy.orm import Session
from app.repositories.base import BaseRepository
from app.repositories.user_repository_interface import IUserRepository
from app.models.user import User
from app.services.auth_service import AuthService

class UserRepository(BaseRepository[User], IUserRepository):
    def __init__(self):
        super().__init__(User)

    def get_by_email(self, db: Session, email: str) -> Optional[User]:
        return db.query(self.model).filter(self.model.email == email).first()

    def create(self, db: Session, obj_in: dict) -> User:
        # Şifreyi veritabanına kaydetmeden önce hashliyoruz
        if "password" in obj_in:
            raw_password = obj_in.pop("password")
            obj_in["hashed_password"] = AuthService.get_password_hash(raw_password)
            
        return super().create(db=db, obj_in=obj_in)

user_repo = UserRepository()