from rest_framework import serializers
from .models import Device, DeviceToken, AccessEvent

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
