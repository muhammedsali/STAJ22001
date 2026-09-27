from datetime import timedelta
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.models.user import User

# Projendeki diğer dosyalardan içe aktarmalar
from app.core.config import settings
from app.schemas.user import UserCreate, UserResponse
from app.repositories.user_repository import user_repo
from app.services.auth_service import AuthService

# --- GÜNCELLENEN IMPORT (deps silindiği için doğrudan core'dan alıyoruz) ---
from app.core.database import get_db

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_in: UserCreate, db: Session = Depends(get_db)):
    """
    Flutter veya web üzerinden yeni bir kullanıcı kaydeder.
    """
    # 1. E-posta adresi sistemde zaten var mı kontrol et
    user = user_repo.get_by_email(db, email=user_in.email)
    if user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Bu e-posta adresiyle zaten bir kayıt mevcut.",
        )
    
    # 2. Kullanıcıyı oluştur (Şifre, repository katmanında otomatik hash'lenir)
    new_user = user_repo.create(db, obj_in=user_in.model_dump())
    
    # 3. UserResponse şemasında belirttiğin gibi şifresiz veriyi Flutter'a döndürür
    return new_user


@router.post("/login")
def login(db: Session = Depends(get_db), form_data: OAuth2PasswordRequestForm = Depends()):
    """
    Kullanıcı girişi yapar (E-posta veya GSM ile) ve JWT Access Token döndürür.
    """
    identifier = form_data.username.strip()
    
    # Gelen değerde '@' işareti varsa e-posta olarak, yoksa GSM olarak ara
    if "@" in identifier:
        user = user_repo.get_by_email(db, email=identifier)
    else:
        # User repository içinde gsm ile arama yapan bir fonksiyonunuz olmalı (aşağıda ekleyeceğiz)
        user = db.query(User).filter(User.gsm == identifier).first()
    
    if not user or not AuthService.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="E-posta/GSM veya şifre hatalı",
            headers={"WWW-Authenticate": "Bearer"},
        )
        
    access_token = AuthService.create_access_token(
        data={
            "sub": str(user.id),
            "role": user.role,
            "first_name": user.first_name,
            "last_name": user.last_name,
            "gsm": user.gsm or ""
        }
    )
    
    return {"access_token": access_token, "token_type": "bearer"}