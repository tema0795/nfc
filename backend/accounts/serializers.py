from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework import serializers
from .models import UserProfile


class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
  username_field = "email"

class UserProfileSerializer(serializers.ModelSerializer):
    email = serializers.EmailField(source="user.email", read_only=True)
    first_name = serializers.CharField(source="user.first_name", read_only=True)
    last_name  = serializers.CharField(source="user.last_name", read_only=True)
    access_level_label = serializers.CharField(source="get_access_level_display", read_only=True)

    class Meta:
        model = UserProfile
        fields = (
            "email",
            "last_name",
            "first_name",
            "middle_name",
            "position",
            "organization",
            "access_level",
            "access_level_label",
        )