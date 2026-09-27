from pydantic import BaseModel, ConfigDict
from typing import Optional

# Flutter'dan (Mobil) Kayıt Olurken Gelecek Veri Formatı
class UserCreate(BaseModel):
    first_name: str
    last_name: str
    gsm: Optional[str] = None
    email: str
    password: str
    role: str = "vatandas"

# Backend'den Flutter'a Dönecek Veri Formatı (Şifre Yok!)
class UserResponse(BaseModel):
    id: int
    first_name: str
    last_name: str
    gsm: Optional[str] = None
    email: str
    role: str

    model_config = ConfigDict(from_attributes=True)