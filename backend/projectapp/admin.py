from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser, Device, AccessEvent, DeviceToken
from .models import Device, DeviceToken

@admin.register(CustomUser)
class CustomUserAdmin(UserAdmin):
    list_display = ('username', 'email', 'first_name', 'last_name', 'is_staff')
    ordering = ('username',)  
    fieldsets = (
        (None, {'fields': ('username', 'password')}),
        ('Personal info', {'fields': ('first_name', 'last_name', 'email')}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )



@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ("device_id", "owner", "status")
    list_filter = ("status",)
    search_fields = ("device_id", "owner")


@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ("device", "token", "created_at", "expires_at")
    list_filter = ("created_at", "expires_at")
    search_fields = ("device__device_id", "token")