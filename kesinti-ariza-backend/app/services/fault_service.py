from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from app.repositories.fault_repository_interface import IFaultRepository
from app.schemas.fault import FaultCreate, FaultUpdate
from app.models.fault import Fault
from app.models.notification import Notification # BİLDİRİM MODELİNİ İÇERİ ALDIK

class FaultService:
    def __init__(self, fault_repo: IFaultRepository):
        self.fault_repo = fault_repo

    def create_fault(self, db: Session, fault_in: FaultCreate, user_id: int) -> Fault:
        fault_data = fault_in.model_dump()
        fault_data["user_id"] = user_id
        fault_data["status"] = "bekliyor"
        
        new_fault = self.fault_repo.create(db, obj_in=fault_data)
        
        notification = Notification(
            user_id=user_id,
            title="Yeni Arıza Kaydı",
            message=f"'{new_fault.title}' başlıklı arıza kaydınız alınmış olup, ekiplerimiz tarafından incelenmesi beklenmektedir."
        )
        db.add(notification)
        db.commit()
        
        return new_fault

    def get_all_faults(self, db: Session, skip: int = 0, limit: int = 100) -> List[Fault]:
        return self.fault_repo.get_all(db, skip=skip, limit=limit)

    def get_fault(self, db: Session, fault_id: int) -> Optional[Fault]:
        return self.fault_repo.get_by_id(db, id=fault_id)

    def update_fault(self, db: Session, fault_id: int, fault_in: FaultUpdate) -> Optional[Fault]:
        updated_fault = self.fault_repo.update_fault(db, fault_id=fault_id, fault_update=fault_in)
        
        if updated_fault:
            status_text = updated_fault.status.upper()
            notification = Notification(
                user_id=updated_fault.user_id,
                title="Arıza Durumu Güncellendi",
                message=f"'{updated_fault.title}' başlıklı bildiriminizin güncel durumu: {status_text}."
            )
            db.add(notification)
            db.commit()
            
        return updated_fault

    def delete_fault(self, db: Session, fault_id: int):
        # 1. Repository'den silme işlemini yap
        success = self.fault_repo.delete_fault(db, fault_id)
        
        # 2. Eğer False döndüyse, kayıt bulunamadığı için 404 hatası döndür
        if not success:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail=f"Fault with ID {fault_id} not found"
            )
        
        return {"message": "Fault deleted successfully"}