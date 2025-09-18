# projectapp/management/commands/rotate_tokens.py
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import timedelta
from projectapp.models import Device, DeviceToken
import secrets, hashlib

TOKEN_LEN = 32  # байт -> hex 64 chars

class Command(BaseCommand):
    help = "Rotate/generate tokens for each device (run hourly)"

    def handle(self, *args, **options):
        now = timezone.now()
        period = timedelta(hours=1)
        valid_from = now
        valid_to = now + period

        devices = Device.objects.all()
        created = 0
        deactivated = 0

        for d in devices:
            # Deactivate previous tokens that overlap this window
            old = DeviceToken.objects.filter(device=d, active=True)
            for o in old:
                o.active = False
                o.save()
                deactivated += 1

            # Generate secure random token (plaintext) and its hash
            raw_token = secrets.token_hex(TOKEN_LEN)  # 64 hex chars if TOKEN_LEN=32
            token_hash = hashlib.sha256(raw_token.encode()).hexdigest()

            # Save hashed token and temporarily store plaintext in a transient field
            t = DeviceToken.objects.create(
                device=d,
                token_hash=token_hash,
                valid_from=valid_from,
                valid_to=valid_to,
                active=True
            )

            # Для возможности выдать токен телефону: сохраним plain token в поле (временное).
            # Добавим атрибут для выдачи; не сохраняем в базе открытый текст.
            t.open_token_temp = raw_token  # transient attr, not saved
            created += 1

            self.stdout.write(f"Generated token for {d.device_id}: {raw_token[:8]}... valid {valid_from} -> {valid_to}")

        self.stdout.write(self.style.SUCCESS(f"Generated tokens: {created}; Deactivated old tokens: {deactivated}"))
