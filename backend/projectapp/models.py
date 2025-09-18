from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
import uuid



class CustomUser(AbstractUser):
    def __str__(self):
        return self.username

class Device(models.Model):
    """
    Физическое устройство/ридер/электронный замок.
    """
    device_id = models.CharField(max_length=128, unique=True)
    owner = models.CharField(max_length=128, blank=True, null=True)

    STATUS_CHOICES = (('WHITE', 'WHITE'), ('BLACK', 'BLACK'))
    status = models.CharField(max_length=5, choices=STATUS_CHOICES, default='WHITE')

    def __str__(self):
        return f"{self.device_id} ({self.status})"


class DeviceToken(models.Model):
    """
    Токен для доступа, который живет 1 час
    """
    device = models.ForeignKey(Device, on_delete=models.CASCADE, related_name="tokens")
    token = models.CharField(max_length=64, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()

    def is_valid(self):
        return self.expires_at > timezone.now()

    def __str__(self):
        return f"{self.device.device_id} -> {self.token}"


class AccessEvent(models.Model):
    """
    Лог событий от замка: кто и когда пытался пройти.
    """
    device = models.ForeignKey(Device, on_delete=models.SET_NULL, null=True)
    token_hash = models.CharField(max_length=64, blank=True, null=True)
    timestamp = models.DateTimeField(default=timezone.now)
    result = models.CharField(max_length=16)  # "ALLOW" / "DENY"
    reason = models.CharField(max_length=256, blank=True, null=True)
    raw_payload = models.JSONField(blank=True, null=True)

    def __str__(self):
        return f"{self.timestamp.isoformat()} {self.device} -> {self.result}"

