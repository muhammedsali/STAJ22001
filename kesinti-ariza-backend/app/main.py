from fastapi import FastAPI
from app.api.routes import faults, auth, notifications

# --- VERİTABANI VE MODELLER ---
from app.core.database import engine, Base 
# Modellerin Base.metadata tarafından tanınması için import ediyoruz (notification eklendi)
from app.models import user, fault, notification 

# --- TABLOLARI OLUŞTURMA ---
# Bu komut veritabanına bağlanır ve eksik olan 'users', 'faults', 'notifications' gibi tabloları oluşturur
Base.metadata.create_all(bind=engine)

app = FastAPI(
    title="Kesinti ve Arıza Takip API",
    description="Staj Projesi Backend Sistemi",
    version="1.0.0"
)

# Rotaları uygulamamıza dahil ediyoruz
# prefix: URL'in başına /api/faults ekler
# tags: Swagger UI ekranında kategorize eder
app.include_router(faults.router, prefix="/api/faults", tags=["Arızalar"])

# Yeni yazdığımız auth rotasını sisteme tanıtıyoruz.
# Not: auth.py içerisinde APIRouter'a zaten prefix="/auth" ve tags=["Authentication"] 
# verdiğimiz için burada tekrar yazmamıza gerek yok. 
app.include_router(auth.router)

# --- YENİ EKLENEN KOD: Bildirimler ---
# Bildirimler API uçlarını uygulamaya dahil ediyoruz.
app.include_router(notifications.router, prefix="/api")

@app.get("/")
def read_root():
    return {"message": "Kesinti ve Arıza Takip Sistemi API'sine Hoş Geldiniz!"}