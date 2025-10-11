from django.db import models
from django.utils import timezone
from django.utils.translation import gettext_lazy as _
from django.contrib.auth.models import PermissionsMixin
from django.contrib.auth.base_user import BaseUserManager, AbstractBaseUser
from django.conf import settings
from django.contrib.auth.hashers import make_password, check_password
from django.dispatch import receiver
from django.db.models.signals import post_save
import uuid

class UserManager(BaseUserManager):
    use_in_migrations = True

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError("Требуется e-mail")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        if password:
            user.set_password(password)
        else:
            user.set_unusable_password()
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault("is_staff", True)
        extra_fields.setdefault("is_superuser", True)
        extra_fields.setdefault("is_active", True)
        if password is None:
            raise ValueError("Для суперпользователя нужен пароль")
        return self.create_user(email, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    email = models.EmailField(_("e-mail"), unique=True)
    first_name = models.CharField(_("имя"), max_length=150, blank=True)
    last_name  = models.CharField(_("фамилия"), max_length=150, blank=True)
    is_staff   = models.BooleanField(_("статус персонала"), default=False)
    is_active  = models.BooleanField(_("активен"), default=True)
    date_joined = models.DateTimeField(_("дата регистрации"), default=timezone.now)

    USERNAME_FIELD = "email"
    REQUIRED_FIELDS: list[str] = []

    objects = UserManager()

    def __str__(self) -> str:
        return self.email


class UserPin(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="pin_record"
    )
    pin_hash = models.CharField(max_length=128)
    updated_at = models.DateTimeField(auto_now=True)

    def set_pin(self, raw_pin: str):
        self.pin_hash = make_password(raw_pin)

    def check_pin(self, raw_pin: str) -> bool:
        return check_password(raw_pin, self.pin_hash)

    def __str__(self):
        return f"PIN for {self.user.email}"

class Device(models.Model):
    device_id = models.CharField(max_length=64, unique=True)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="devices"
    )
    created_at = models.DateTimeField(default=timezone.now)
    last_seen_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.device_id} -> {self.user.email}"



class AccessLevel(models.IntegerChoices):
    GUEST     = 0, "Гость"
    EMPLOYEE  = 1, "Сотрудник"
    MANAGER   = 2, "Менеджер"
    ADMIN     = 3, "Администратор"

class UserProfile(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="profile",
    )
    middle_name  = models.CharField("отчество", max_length=150, blank=True)
    position     = models.CharField("должность", max_length=150, blank=True)
    organization = models.CharField("организация", max_length=255, blank=True)
    access_level = models.IntegerField(
        choices=AccessLevel.choices,
        default=AccessLevel.EMPLOYEE,
    )

    def __str__(self):
        return f"Профиль {self.user.email}"

@receiver(post_save, sender=settings.AUTH_USER_MODEL)
def create_profile_for_user(sender, instance, created, **kwargs):
    if created:
        UserProfile.objects.get_or_create(user=instance)


def nfc_token_default() -> str:
    return uuid.uuid4().hex

class NfcToken(models.Model):
    token = models.CharField(max_length=64, unique=True, default=nfc_token_default)
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="nfc_tokens")
    device = models.ForeignKey('accounts.Device', on_delete=models.CASCADE, related_name="nfc_tokens")
    created_at = models.DateTimeField(default=timezone.now)
    expires_at = models.DateTimeField()
    used_at = models.DateTimeField(null=True, blank=True)

    @property
    def is_expired(self) -> bool:
        return timezone.now() >= self.expires_at

    @property
    def is_used(self) -> bool:
        return self.used_at is not None

    def __str__(self):
        return f"NfcToken({self.token[:8]}...) for {self.user.email}"

class NfcEvent(models.Model):
    user   = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name="nfc_events")
    device = models.ForeignKey('accounts.Device', on_delete=models.CASCADE, related_name="nfc_events")
    tag_uid = models.CharField(max_length=64)  # hex UID метки
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"NFC event {self.tag_uid} by {self.user.email} @ {self.created_at:%Y-%m-%d %H:%M:%S}"
