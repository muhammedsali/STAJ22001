from sqlalchemy import Column, Integer, String
from sqlalchemy.orm import relationship
from app.core.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    first_name = Column(String(50), nullable=False)  # Ad
    last_name = Column(String(50), nullable=False)   # Soyad
    gsm = Column(String(20), nullable=True)          # GSM / Telefon
    email = Column(String(100), unique=True, index=True, nullable=False)
    hashed_password = Column(String(255), nullable=False)
    role = Column(String(50), default="vatandas") # Roller: vatandas, saha_ekibi, yonetici

    # Bir kullanıcının birden fazla arıza bildirimi olabilir
    faults = relationship("Fault", back_populates="user")