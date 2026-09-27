from pydantic import BaseModel, ConfigDict
from datetime import datetime
from typing import Optional  # Bu satırı yeni ekledik

# Flutter'dan (Mobil) Backend'e gelecek arıza bildirim formatı
class FaultCreate(BaseModel):
    title: str
    description: str
    latitude: float
    longitude: float
    # user_id ve status'u Flutter'dan almayacağız, backend kendisi atayacak

# Backend'den Flutter'a (Mobil) dönecek arıza detayı formatı
class FaultResponse(BaseModel):
    id: int
    title: str
    description: str
    latitude: float
    longitude: float
    status: str
    user_id: int
    created_at: datetime
    
    # SQLAlchemy modelleri ile Pydantic'in sorunsuz konuşması için gerekli ayar
    model_config = ConfigDict(from_attributes=True)

# Güncelleme işlemi için kullanılacak format (Tüm alanlar opsiyonel)
class FaultUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    status: Optional[str] = None