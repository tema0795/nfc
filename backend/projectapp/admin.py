from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser
from .models import Device
class CustomUserAdmin(UserAdmin):
 
    list_display = ("username", "email", "first_name", "last_name")


admin.site.register(CustomUser, CustomUserAdmin)

from .models import Device

@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ('uid', 'status', 'owner', 'created_at')
    list_filter = ('status',)
    search_fields = ('uid', 'owner')
