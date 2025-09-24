from django.urls import path
from . import views
from .views import RegisterView  # Импортируем RegisterView

urlpatterns = [
    path('request-token/', views.request_token, name='request_token'),
    path('validate-token/', views.validate_token, name='validate_token'),
    path('register/', RegisterView.as_view(), name='register'),
]
