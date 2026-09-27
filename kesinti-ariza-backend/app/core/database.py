from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker
from app.core.config import settings

# PostgreSQL ile iletişim kuracak ana motoru (engine) oluşturuyoruz
engine = create_engine(settings.DATABASE_URL)

# Veritabanı işlemlerini yürütecek oturum (session) fabrikası
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Tüm modellerimizin (tablolarımızın) miras alacağı temel iskelet sınıf
Base = declarative_base()

# Her API isteğinde veritabanı bağlantısı açıp, işlem bitince güvenlice kapatacak bağımlılık (Dependency)
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()