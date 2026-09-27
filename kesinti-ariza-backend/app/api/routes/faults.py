from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

# --- GÜNCELLENEN IMPORTS ---
from app.core.database import get_db
from app.api.dependencies import get_fault_service, get_current_user 
from app.schemas.fault import FaultCreate, FaultResponse, FaultUpdate
from app.services.fault_service import FaultService
from app.models.fault import Fault # Arama yapabilmek için modeli dahil ettik

router = APIRouter()

# Yeni Arıza Ekleme Endpoint'i (POST)
@router.post("/", response_model=FaultResponse, status_code=status.HTTP_201_CREATED)
def create_fault(
    fault_in: FaultCreate,
    db: Session = Depends(get_db),
    fault_service: FaultService = Depends(get_fault_service),
    current_user = Depends(get_current_user) # KAPI KİLİDİ 🔒 (Token zorunlu)
):
    # Arızayı oluşturan kişinin ID'sini sisteme işliyoruz
    return fault_service.create_fault(db=db, fault_in=fault_in, user_id=current_user.id)

# Tüm Arızaları Getirme Endpoint'i (GET)
@router.get("/", response_model=List[FaultResponse])
def read_faults(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    fault_service: FaultService = Depends(get_fault_service),
    current_user = Depends(get_current_user) 
):
    return fault_service.get_all_faults(db=db, skip=skip, limit=limit)


@router.put("/{fault_id}", response_model=FaultResponse)
def update_fault_endpoint(
    fault_id: int, 
    fault_in: FaultUpdate, 
    db: Session = Depends(get_db),
    fault_service: FaultService = Depends(get_fault_service),
    current_user = Depends(get_current_user) 
):
    fault = db.query(Fault).filter(Fault.id == fault_id).first()
    
    if not fault:
        raise HTTPException(status_code=404, detail="Arıza bulunamadı")
        
    if fault.user_id != current_user.id and current_user.role not in ["saha_ekibi", "yonetici", "admin"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Bu arızayı güncelleme yetkiniz yok! Sadece yetkili personeller diğer arızalara müdahale edebilir."
        )
        
    return fault_service.update_fault(db=db, fault_id=fault_id, fault_in=fault_in)


@router.delete("/{fault_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_fault_endpoint(
    fault_id: int,
    db: Session = Depends(get_db),
    fault_service: FaultService = Depends(get_fault_service),
    current_user = Depends(get_current_user) 
):
    fault = db.query(Fault).filter(Fault.id == fault_id).first()
    
    if not fault:
        raise HTTPException(status_code=404, detail="Arıza bulunamadı")
        
    if fault.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, 
            detail="Bu arızayı silme yetkiniz yok! (Sadece kendi arızalarınızı silebilirsiniz)"
        )

    return fault_service.delete_fault(db=db, fault_id=fault_id)