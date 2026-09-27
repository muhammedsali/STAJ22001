from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db  # Veritabanı bağlantımız buradan geliyor

from app.repositories.user_repository import user_repo
from app.repositories.fault_repository import fault_repo
from app.services.fault_service import FaultService

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Kimlik doğrulama bilgileri geçersiz veya süresi dolmuş",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        
        user_id: str = payload.get("sub")
        if user_id is None:
            raise credentials_exception
            
    except JWTError:
        raise credentials_exception
        
    user = user_repo.get_by_id(db, id=int(user_id))
    
    if user is None:
        raise credentials_exception
        
    return user


def get_fault_service() -> FaultService:
    return FaultService(fault_repo=fault_repo)
