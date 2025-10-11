from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from .serializers import EmailTokenObtainPairSerializer, UserProfileSerializer
from .models import UserPin, Device, UserProfile,  NfcToken, NfcEvent
from datetime import timedelta
from django.utils import timezone

class EmailTokenObtainPairView(TokenObtainPairView):
    permission_classes = (AllowAny,)
    serializer_class = EmailTokenObtainPairSerializer

class EmailTokenRefreshView(TokenRefreshView):
    permission_classes = (AllowAny,)

def _issue_tokens_for_user(user):
    refresh = RefreshToken.for_user(user)
    return {"refresh": str(refresh), "access": str(refresh.access_token)}

def _validate_pin(pin: str) -> bool:
    # 4 цифры
    return isinstance(pin, str) and len(pin) == 4 and pin.isdigit()

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def pin_set(request):
    """
    JSON:
    {
      "pin": "1234",
      "device_id": "optional-string"  # желательно передавать и тут, чтобы привязать устройство сразу
    }
    """
    pin = request.data.get("pin")
    device_id = request.data.get("device_id") or request.headers.get("X-Device-Id")

    if not _validate_pin(pin):
        return Response({"detail": "PIN должен состоять из 4 цифр."},
                        status=status.HTTP_400_BAD_REQUEST)

    # создать/обновить запись PIN
    upin, _created = UserPin.objects.get_or_create(user=request.user)
    upin.set_pin(pin)
    upin.save()

    # опционально привязываем устройство к пользователю
    if device_id:
        Device.objects.update_or_create(
            device_id=device_id,
            defaults={"user": request.user}
        )

    return Response({"detail": "PIN сохранён."}, status=status.HTTP_200_OK)

@api_view(["POST"])
@permission_classes([AllowAny])
def pin_verify(request):
    """
    JSON:
    {
      "device_id": "string",
      "pin": "1234"
    }
    """
    device_id = request.data.get("device_id") or request.headers.get("X-Device-Id")
    pin = request.data.get("pin")

    if not device_id:
        return Response({"detail": "device_id обязателен."},
                        status=status.HTTP_400_BAD_REQUEST)
    if not _validate_pin(pin):
        return Response({"detail": "PIN должен состоять из 4 цифр."},
                        status=status.HTTP_400_BAD_REQUEST)

    try:
        device = Device.objects.select_related("user").get(device_id=device_id)
    except Device.DoesNotExist:
        return Response({"detail": "Устройство не зарегистрировано для входа по PIN."},
                        status=status.HTTP_404_NOT_FOUND)

    # проверяем, что у пользователя есть PIN
    try:
        upin = device.user.pin_record
    except UserPin.DoesNotExist:
        return Response({"detail": "Для пользователя не задан PIN."},
                        status=status.HTTP_400_BAD_REQUEST)

    if not upin.check_pin(pin):
        return Response({"detail": "Неверный PIN."},
                        status=status.HTTP_400_BAD_REQUEST)

    # всё ок — выдаём токены JWT
    tokens = _issue_tokens_for_user(device.user)
    return Response(tokens, status=status.HTTP_200_OK)

@api_view(["GET"])
@permission_classes([IsAuthenticated])
def me_profile(request):
    profile, _ = UserProfile.objects.get_or_create(user=request.user)
    data = UserProfileSerializer(profile).data
    return Response(data, status=status.HTTP_200_OK)


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def device_nfc_token(request):
    """
    Вернёт одноразовый NFC-токен для устройства.
    GET /api/device/nfc-token/?device_id=...
    """
    device_id = request.query_params.get("device_id") or request.headers.get("X-Device-Id")
    if not device_id:
        return Response({"detail": "device_id обязателен."}, status=status.HTTP_400_BAD_REQUEST)

    try:
        device = Device.objects.get(device_id=device_id, user=request.user)
    except Device.DoesNotExist:
        return Response({"detail": "Устройство не найдено или не привязано к пользователю."},
                        status=status.HTTP_404_NOT_FOUND)

    ttl_seconds = 60
    token = NfcToken.objects.create(
        user=request.user,
        device=device,
        expires_at=timezone.now() + timedelta(seconds=ttl_seconds),
    )
    return Response({"token": token.token, "expires_in": ttl_seconds}, status=status.HTTP_200_OK)


@api_view(["POST"])
@permission_classes([AllowAny])
def nfc_verify(request):
    """
    Проверяет факт прикладывания к метке.
    JSON:
    {
      "device_id": "string",
      "token": "hex",
      "tag_uid": "hex-uid"   # UID метки (как прочитал клиент)
    }
    """
    device_id = request.data.get("device_id") or request.headers.get("X-Device-Id")
    token_str = request.data.get("token")
    tag_uid   = request.data.get("tag_uid")

    if not device_id or not token_str or not tag_uid:
        return Response({"detail": "device_id, token и tag_uid обязательны."},
                        status=status.HTTP_400_BAD_REQUEST)

    try:
        nt = NfcToken.objects.select_related("user", "device").get(
            token=token_str,
            device__device_id=device_id,
        )
    except NfcToken.DoesNotExist:
        return Response({"detail": "Токен не найден для устройства."},
                        status=status.HTTP_404_NOT_FOUND)

    if nt.is_used:
        return Response({"detail": "Токен уже использован."}, status=status.HTTP_400_BAD_REQUEST)
    if nt.is_expired:
        return Response({"detail": "Токен истёк."}, status=status.HTTP_400_BAD_REQUEST)

    # помечаем использованным и пишем событие
    nt.used_at = timezone.now()
    nt.save(update_fields=["used_at"])
    NfcEvent.objects.create(user=nt.user, device=nt.device, tag_uid=tag_uid)

    # можно вернуть минимальные данные
    user = nt.user
    return Response({
        "ok": True,
        "user": {
            "email": user.email,
            "first_name": user.first_name,
            "last_name": user.last_name,
        },
        "verified_at": nt.used_at.isoformat(),
    }, status=status.HTTP_200_OK)