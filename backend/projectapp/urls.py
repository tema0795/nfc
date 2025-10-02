from django.urls import path
from . import views
from .views import RegisterView, setPIN

urlpatterns = [
    path('request-token/', views.request_token, name='request_token'),
    path('validate-token/', views.validate_token, name='validate_token'),
    path('register/', RegisterView.as_view(), name='register'),
    path('setPIN/', setPIN, name='setPIN'),
]
