# accounts/admin.py
from django.contrib import admin
from django import forms
from django.contrib.auth.forms import ReadOnlyPasswordHashField
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from .models import User, UserPin, Device, UserProfile, NfcEvent, NfcToken

class UserCreationForm(forms.ModelForm):
    password1 = forms.CharField(label="Пароль", widget=forms.PasswordInput)
    password2 = forms.CharField(label="Подтверждение пароля", widget=forms.PasswordInput)

    class Meta:
        model = User
        fields = ("email", "first_name", "last_name")

    def clean_password2(self):
        p1 = self.cleaned_data.get("password1")
        p2 = self.cleaned_data.get("password2")
        if p1 and p2 and p1 != p2:
            raise forms.ValidationError("Пароли не совпадают")
        return p2

    def save(self, commit=True):
        user = super().save(commit=False)
        user.set_password(self.cleaned_data["password1"])
        if commit:
            user.save()
        return user

class UserChangeForm(forms.ModelForm):
    password = ReadOnlyPasswordHashField(label="Пароль",
        help_text=("Хэш хранится только для проверки. Узнать текущий пароль нельзя, "
                   "но его можно сменить."))

    class Meta:
        model = User
        fields = ("email", "password", "first_name", "last_name",
                  "is_active", "is_staff", "is_superuser", "groups", "user_permissions")

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    add_form = UserCreationForm
    form = UserChangeForm
    model = User

    list_display = ("id", "email", "is_active", "is_staff")
    list_filter = ("is_active", "is_staff", "is_superuser")
    search_fields = ("email", "first_name", "last_name")
    ordering = ("email",)

    fieldsets = (
        (None, {"fields": ("email", "password")}),
        ("Личные данные", {"fields": ("first_name", "last_name")}),
        ("Права", {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")}),
        ("Даты", {"fields": ("last_login", "date_joined")}),
    )

    add_fieldsets = (
        (None, {
            "classes": ("wide",),
            "fields": ("email", "first_name", "last_name", "password1", "password2", "is_staff", "is_superuser"),
        }),
    )

@admin.register(UserPin)
class UserPinAdmin(admin.ModelAdmin):
    list_display = ("user", "updated_at")

@admin.register(Device)
class DeviceAdmin(admin.ModelAdmin):
    list_display = ("device_id", "user", "created_at", "last_seen_at")
    search_fields = ("device_id", "user__email")


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ("user", "position", "organization", "access_level")
    search_fields = ("user__email", "organization", "position")

@admin.register(NfcToken)
class NfcTokenAdmin(admin.ModelAdmin):
    list_display = ("token", "user", "device", "created_at", "expires_at", "used_at")
    search_fields = ("token", "user__email", "device__device_id")

@admin.register(NfcEvent)
class NfcEventAdmin(admin.ModelAdmin):
    list_display = ("user", "device", "tag_uid", "created_at")
    search_fields = ("tag_uid", "user__email", "device__device_id")