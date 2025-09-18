from apscheduler.schedulers.background import BackgroundScheduler
from django.utils import timezone
from .models import Device, DeviceToken
import secrets


def rotate_tokens():
    """Функция обновления токенов каждый час"""
    now = timezone.now()
    for device in Device.objects.all():
        token_value = secrets.token_hex(16)
        DeviceToken.objects.create(
            device=device,
            token=token_value,
            expires_at=now + timezone.timedelta(hours=1)
        )
    print(f"[{now}] Tokens rotated!")


def start_scheduler():
    scheduler = BackgroundScheduler()
    scheduler.add_job(rotate_tokens, "interval", hours=1)
    scheduler.start()
