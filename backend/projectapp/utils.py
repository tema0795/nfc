# projectapp/utils.py
import uuid
from django.utils import timezone
from datetime import timedelta
from .models import Device, DeviceToken

def rotate_tokens():
    """
    Генерирует новые токены для всех устройств, срок жизни — 1 час.
    """
    for device in Device.objects.all():
        token = str(uuid.uuid4())
        DeviceToken.objects.create(
            device=device,
            token=token,
            expires_at=timezone.now() + timedelta(hours=1)
        )
        print(f"✅ Token updated for {device.device_id}: {token}")
