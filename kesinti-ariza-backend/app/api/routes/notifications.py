from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List

from app.core.database import get_db
from app.models.notification import Notification
from app.schemas.notification import NotificationResponse
# Kendi projendeki auth bağımlılığını (dependency) buraya göre ayarla. Genelde get_current_user şeklindedir.
from app.api.dependencies import get_current_user 
from app.models.user import User

router = APIRouter(prefix="/notifications", tags=["Notifications"])

@router.get("/", response_model=List[NotificationResponse])
def get_my_notifications(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Giriş yapmış kullanıcının bildirimlerini en yeniden eskiye doğru listeler.
    """
    notifications = db.query(Notification).filter(
        Notification.user_id == current_user.id
    ).order_by(Notification.created_at.desc()).all()
    
    return notifications

@router.put("/{notification_id}/read")
def mark_as_read(notification_id: int, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Belirli bir bildirimi okundu (is_read=True) olarak işaretler.
    """
    notification = db.query(Notification).filter(
        Notification.id == notification_id, 
        Notification.user_id == current_user.id
    ).first()
    
    if not notification:
        raise HTTPException(status_code=404, detail="Bildirim bulunamadı")
    
    notification.is_read = True
    db.commit()
    
    return {"message": "Bildirim okundu olarak işaretlendi"}