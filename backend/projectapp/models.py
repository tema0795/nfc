from django.db import models
from django.contrib.auth.models import AbstractUser

# модель юзера
class CustomUser(AbstractUser):
    def __str__(self):
        return self.username
 