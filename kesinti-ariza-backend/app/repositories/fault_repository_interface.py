from abc import ABC, abstractmethod
from typing import List, Optional
from sqlalchemy.orm import Session
from app.models.fault import Fault
from app.schemas.fault import FaultUpdate  # Güncelleme şemasını import ettik

class IFaultRepository(ABC):
    
    @abstractmethod
    def get_by_id(self, db: Session, id: int) -> Optional[Fault]:
        pass

    @abstractmethod
    def create(self, db: Session, obj_in: dict) -> Fault:
        pass

    # BaseRepository'de olmayan, Arızalara ÖZEL sözleşmeler:
    @abstractmethod
    def get_all(self, db: Session, skip: int = 0, limit: int = 100) -> List[Fault]:
        pass

    @abstractmethod
    def get_by_status(self, db: Session, status: str) -> List[Fault]:
        pass
        
    # --- YENİ EKLENEN GÜNCELLEME SÖZLEŞMESİ ---
    @abstractmethod
    def update_fault(self, db: Session, fault_id: int, fault_update: FaultUpdate) -> Optional[Fault]:
        pass

    # --- YENİ EKLENEN SİLME SÖZLEŞMESİ ---
    @abstractmethod
    def delete_fault(self, db: Session, fault_id: int) -> bool:
        pass