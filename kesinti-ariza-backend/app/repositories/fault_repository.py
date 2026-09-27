from sqlalchemy.orm import Session
from typing import List, Optional
from app.repositories.base import BaseRepository
from app.repositories.fault_repository_interface import IFaultRepository
from app.models.fault import Fault
from app.schemas.fault import FaultUpdate  # Güncelleme şemamızı ekledik

# Hem BaseRepository yeteneklerini alıyoruz hem de IFaultRepository sözleşmesini imzalıyoruz
class FaultRepository(BaseRepository[Fault], IFaultRepository):
    def __init__(self):
        super().__init__(Fault)

    # Sözleşmedeki özel metodların içini dolduruyoruz (Gerçek SQL sorguları)
    def get_all(self, db: Session, skip: int = 0, limit: int = 100) -> List[Fault]:
        return db.query(self.model).offset(skip).limit(limit).all()

    def get_by_status(self, db: Session, status: str) -> List[Fault]:
        return db.query(self.model).filter(self.model.status == status).all()

    # --- YENİ EKLENEN GÜNCELLEME METODU ---
    def update_fault(self, db: Session, fault_id: int, fault_update: FaultUpdate) -> Optional[Fault]:
        # 1. Kaydı bul
        db_fault = db.query(self.model).filter(self.model.id == fault_id).first()
        
        if not db_fault:
            return None
        
        # 2. Sadece gönderilen verileri al (exclude_unset=True)
        update_data = fault_update.model_dump(exclude_unset=True)
        
        # 3. Modele yeni verileri işle
        for key, value in update_data.items():
            setattr(db_fault, key, value)
            
        # 4. Veritabanına kaydet
        db.commit()
        db.refresh(db_fault)
        
        return db_fault

    # --- YENİ EKLENEN SİLME METODU ---
    def delete_fault(self, db: Session, fault_id: int) -> bool:
        # 1. Silinecek kaydı bul
        db_fault = db.query(self.model).filter(self.model.id == fault_id).first()
        
        # 2. Eğer kayıt yoksa False döndür (Servis katmanı bunu 404'e çevirecek)
        if not db_fault:
            return False
            
        # 3. Kayıt varsa sil ve veritabanına kaydet
        db.delete(db_fault)
        db.commit()
        return True

# Bu sınıfı API rotalarında kullanmak için hazır bir obje üretiyoruz
fault_repo = FaultRepository()