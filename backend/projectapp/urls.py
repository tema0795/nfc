from django.urls import path
from . import views

urlpatterns = [
    path('request-token/', views.request_token, name='request_token'),
    path('validate-token/', views.validate_token, name='validate_token'),
]
