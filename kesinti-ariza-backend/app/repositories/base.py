from sqlalchemy.orm import Session
from typing import Generic, TypeVar, Type, Any

# Hangi tabloyla (Model) çalışacağımızı belirten jenerik tip
ModelType = TypeVar("ModelType")

class BaseRepository(Generic[ModelType]):
    def __init__(self, model: Type[ModelType]):
        self.model = model

    # Veritabanından ID'ye göre kayıt getirir
    def get_by_id(self, db: Session, id: Any):
        return db.query(self.model).filter(self.model.id == id).first()

    # Veritabanına yeni bir kayıt ekler
    def create(self, db: Session, obj_in: dict):
        db_obj = self.model(**obj_in)
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj