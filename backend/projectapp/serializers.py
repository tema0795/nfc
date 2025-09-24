from rest_framework import serializers
from .models import Device, DeviceToken, AccessEvent
from django.contrib.auth import get_user_model, password_validation
from django.core import exceptions
User = get_user_model()

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