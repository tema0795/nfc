from django.utils import timezone
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework import status

from .models import Device, DeviceToken, AccessEvent
import hashlib

from rest_framework import generics, permissions
from .models import CustomUser
from .serializers import RegisterSerializer  # Импортируем RegisterSerializer

# ---------------------------------------------------
# 1) Эндпоинт: телефон запрашивает текущий токен (AUTH)
#    Возвращает сам токен (plaintext) — телефон должен хранить его безопасно.
#    Этот эндпоинт доступен только авторизованным пользователям (телефонам).
# ---------------------------------------------------
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def request_token(request):
    """
    Тело запроса: { "device_id": "..." }
    Ответ: { "token": "<plaintext token>", "valid_from": "...", "valid_to": "..." }
    """
    device_id = request.data.get('device_id')
    if not device_id:
        return Response({"detail":"device_id required"}, status=status.HTTP_400_BAD_REQUEST)

    try:
        device = Device.objects.get(device_id=device_id)
    except Device.DoesNotExist:
        return Response({"detail":"device not found"}, status=status.HTTP_404_NOT_FOUND)

    # Найдём активный токен (в рамках window)
    now = timezone.now()
    token_obj = DeviceToken.objects.filter(device=device, active=True, valid_from__lte=now, valid_to__gte=now).first()

    if token_obj:
        # Мы не храним открытый токен в базе, поэтому сервер не может вернуть оригинал,
        # если он не был сохранён где-то при генерации. Решение: при генерации сохраняем
        # открытый токен временно в поле "transient" или — лучше — генерируем токен on-demand
        # и возвращаем его. Для безопасности ниже — мы предполагаем, что при генерации
        # открытая версия была записана в DeviceToken.open_token_temp и мы удаляем её при выдаче.
        if hasattr(token_obj, 'open_token_temp') and token_obj.open_token_temp:
            return Response({
                "token": token_obj.open_token_temp,
                "valid_from": token_obj.valid_from,
                "valid_to": token_obj.valid_to
            })
        else:
            # Если нет открытой версии (например, токены генерировались автоматически
            # без хранения открытого варианта), то требуем генерацию нового токена.
            return Response({"detail":"No plaintext token available; request new token later"}, status=status.HTTP_409_CONFLICT)

    return Response({"detail":"no active token for device"}, status=status.HTTP_404_NOT_FOUND)


# ---------------------------------------------------
# 2) Эндпоинт: замок присылает token для валидации (OPEN)
#    Доступ: AllowAny (замок может не иметь JWT), но можно добавить shared secret.
# ---------------------------------------------------
@api_view(['POST'])
@permission_classes([AllowAny])
def validate_token(request):
    """
    Тело запроса: { "device_id": "...", "token": "..." }
    Ответ: { "result": "ALLOW"/"DENY", "reason": "..." }
    """
    device_id = request.data.get('device_id')
    token = request.data.get('token')

    if not device_id or not token:
        return Response({"detail":"device_id and token required"}, status=status.HTTP_400_BAD_REQUEST)

    # Найдём устройство
    try:
        device = Device.objects.get(device_id=device_id)
    except Device.DoesNotExist:
        # Логируем попытку
        AccessEvent.objects.create(device=None, token_hash=hashlib.sha256(token.encode()).hexdigest(),
                                   result="DENY", reason="device_not_registered", raw_payload=request.data)
        return Response({"result":"DENY", "reason":"device_not_registered"}, status=status.HTTP_404_NOT_FOUND)

    # Сначала проверяем статус white/black
    if device.status == "BLACK":
        AccessEvent.objects.create(device=device, token_hash=hashlib.sha256(token.encode()).hexdigest(),
                                   result="DENY", reason="device_blacklisted", raw_payload=request.data)
        return Response({"result":"DENY", "reason":"device_blacklisted"}, status=status.HTTP_403_FORBIDDEN)

    # Сверяем хеш токена
    token_hash = hashlib.sha256(token.encode()).hexdigest()
    now = timezone.now()
    token_obj = DeviceToken.objects.filter(device=device, token_hash=token_hash, active=True,
                                           valid_from__lte=now, valid_to__gte=now).first()
    if token_obj:
        # Успех
        AccessEvent.objects.create(device=device, token_hash=token_hash, result="ALLOW", reason="valid_token", raw_payload=request.data)
        return Response({"result":"ALLOW"}, status=status.HTTP_200_OK)
    else:
        AccessEvent.objects.create(device=device, token_hash=token_hash, result="DENY", reason="invalid_or_expired", raw_payload=request.data)
        return Response({"result":"DENY", "reason":"invalid_or_expired"}, status=status.HTTP_401_UNAUTHORIZED)



class RegisterView(generics.CreateAPIView):
    queryset = CustomUser.objects.all()
    permission_classes = (permissions.AllowAny,)
    serializer_class = RegisterSerializer

    def post(self, request, *args, **kwargs):
      serializer = self.get_serializer(data=request.data)
      serializer.is_valid(raise_exception=True)
      user = serializer.save()
      return Response({
          "user": RegisterSerializer(user, context=self.get_serializer_context()).data,
          "message": "Пользователь успешно зарегистрирован",
      }, status=status.HTTP_201_CREATED)