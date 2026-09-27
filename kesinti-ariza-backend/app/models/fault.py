from sqlalchemy import Column, Integer, String, Float, Text, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from datetime import datetime
from app.core.database import Base

class Fault(Base):
    __tablename__ = "faults"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(150), nullable=False)
    description = Column(Text, nullable=False)
    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    status = Column(String(50), default="bekliyor") # Durumlar: bekliyor, islemde, tamamlandi
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Bu arızayı hangi kullanıcı oluşturdu? (Yabancı Anahtar)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    # Kullanıcı tablosu ile çift yönlü bağlantı
    user = relationship("User", back_populates="faults")