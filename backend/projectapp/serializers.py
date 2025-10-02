from rest_framework import serializers
from .models import Device, DeviceToken, AccessEvent
from django.contrib.auth import get_user_model, password_validation
from django.core import exceptions
User = get_user_model()

# ручная работа с паролями
from  django.contrib.auth.hashers import make_password

class DeviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = Device
        fields = ('id','device_id','owner','status')

class DeviceTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeviceToken
        fields = ('device','valid_from','valid_to','active')

class AccessEventSerializer(serializers.ModelSerializer):
    class Meta:
        model = AccessEvent
        fields = '__all__'

# назначение класса заполнить hashPIN пользователя в хешированном виде
class SetPINSerializer(serializers.ModelSerializer):
    # идентификатор телефона, например номер телефона
    deviceID = serializers.CharField(required=True)
    # пинкод выбранный пользователем
    PIN = serializers.CharField(required=True)

    class Meta:
        model = User
        # необходимо включить все поля сериалайзера (поля модели и собственные)
        fields = ['PINhash', 'deviceID', 'PIN']

    def validate_PIN(self, value):
        if len(str(value)) != 5 and str(value).isdigit():
            raise serializers.ValidationError("Пин код не длинны 5 или состоит не из цифр")
        return value
    
    # занести хеш суммы пинкода и deviceID в поле
    def update(self, instance, validated_data):
        instance.PINhash = make_password(self.PIN + self.deviceID, hasher='pbkdf2_sha256')
        instance.save()
        

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, required=True, validators=[password_validation.validate_password])
    password2 = serializers.CharField(write_only=True, required=True)

    class Meta:
        model = User
        fields = ('username', 'password', 'password2', 'email', 'first_name', 'last_name')
        extra_kwargs = {
            'first_name': {'required': False},
            'last_name': {'required': False}
        }

    def validate(self, attrs):
        if attrs['password'] != attrs['password2']:
            raise serializers.ValidationError({"password": "Пароли не совпадают."})
        return attrs

    def create(self, validated_data):
        user = User.objects.create(
            username=validated_data['username'],
            email=validated_data.get('email', ''), # Если email не обязателен
            first_name=validated_data.get('first_name', ''), # Если first_name не обязателен
            last_name=validated_data.get('last_name', '') # Если last_name не обязателен
        )

        user.set_password(validated_data['password'])
        user.save()

        return user