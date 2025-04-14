from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import CustomUser

# Register your models here.

# класс предназначенный для регистрации пользователей админкой
class CustomUserAdmin(UserAdmin):
    # Отображать следующе поля в админ панели
    list_display = ("username", "email", "first_name", "last_name")

# добавить функционал регистрации пользователей CustomUser админкой
admin.site.register(CustomUser, CustomUserAdmin)