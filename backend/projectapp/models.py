from django.db import models
from django.contrib.auth.models import AbstractUser
from django.utils import timezone
import uuid



class CustomUser(AbstractUser):
   
    id = models.AutoField(primary_key=True, verbose_name="ID")
    password = models.CharField(max_length=128, verbose_name="Пароль")
    last_login = models.DateTimeField(blank=True, null=True, verbose_name="Последний вход")
    is_superuser = models.BooleanField(default=False, verbose_name="Суперпользователь")
    username = models.CharField(
        max_length=150,
        unique=True,
        verbose_name="Имя пользователя",
        help_text="Обязательное. 150 символов или меньше. Буквы, цифры и @/./+/-/_.",
    )
    first_name = models.CharField(
        max_length=150, blank=True, verbose_name="Имя"
    )
    last_name = models.CharField(
        max_length=150, blank=True, verbose_name="Фамилия"
    )
    email = models.EmailField(
        blank=True, verbose_name="Адрес электронной почты"
    )
    is_staff = models.BooleanField(
        default=False, verbose_name="Статус персонала"
    )
    is_active = models.BooleanField(
        default=True, verbose_name="Активный"
    )
    date_joined = models.DateTimeField(
        default=timezone.now, verbose_name="Дата присоединения"
    )


    class Meta:
        db_table = 'projectapp_customuser'  # Указываем имя существующей таблицы
        managed = False  # Django не управляет этой таблицей

    def __str__(self):
        return self.username # Отображаем username в админке

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

