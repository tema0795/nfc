from django.shortcuts import render
from .serializers import UserRegistrationSerializer
from rest_framework.response import Response
from rest_framework import status
from rest_framework.decorators import api_view

# Create your views here.
@api_view(["POST"]) #обрабатывает только POST запросы
def register_user(request):
    serializer = UserRegistrationSerializer(data = request.data)
    # В случаее валидности данных отправить 200 OK
    if serializer.is_valid():
        serializer.save()
        return Response(serializer.data)
    # В случаее невалидности - 400 BAD REQUESTS
    return Response(serializer.errors, status = status.HTTP_400_BAD_REQUEST)