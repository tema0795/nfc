from django.db import models
from django.contrib.auth.models import AbstractUser


class CustomUser(AbstractUser):
    def __str__(self):
        return self.username

class Device(models.Model):
    uid = models.CharField(max_length=64, unique=True)  # UID NFC
    STATUS_CHOICES = [
        ('WHITE', 'White List'),
        ('BLACK', 'Black List'),
    ]
    status = models.CharField(max_length=5, choices=STATUS_CHOICES, default='WHITE')
    owner = models.CharField(max_length=128, blank=True, null=True)  # владелец 
    created_at = models.DateTimeField(auto_now_add=True) 
    updated_at = models.DateTimeField(auto_now=True)      

    def __str__(self):
        return f"{self.uid} ({self.status})"
