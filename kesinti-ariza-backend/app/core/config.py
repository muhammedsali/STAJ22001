import os
from dotenv import load_dotenv

# .env dosyasındaki değişkenleri sisteme yükler
load_dotenv()

class Settings:
    PROJECT_NAME: str = "TEDAŞ Kesinti & Arıza Takip API"
    
    # .env dosyasından okunan veritabanı adresi
    DATABASE_URL: str = os.getenv("DATABASE_URL")
    
    # Güvenlik ve Token Ayarları
    SECRET_KEY: str = os.getenv("SECRET_KEY", "gizli_anahtar_yoksa_bunu_kullan")
    ALGORITHM: str = os.getenv("ALGORITHM", "HS256")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = int(os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", 1440))

# Ayarları projenin her yerinde kullanabilmek için tek bir obje (singleton) üretiyoruz
settings = Settings()