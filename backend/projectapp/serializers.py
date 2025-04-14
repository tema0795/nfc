from rest_framework import serializers
from django.contrib.auth import get_user_model

# cереализовать данные регистрации
class UserRegistrationSerializer(serializers.ModelSerializer):
    # шаблон модели, проверка на валидность моделью
    class Meta:
        # вместо того чтобы напрямую использоать точное имя модели
        # лучшим вариантом будет, использовать этот метод
        model = get_user_model()
        # стандартные поля, унаследованные моей моделью от UserModel
        fields = ["id", "email", "username", "first_name", "last_name", "password"]
        # пароль становится невидимым
        extra_kwargs = {
            'password' : {'write_only' : True}
        }

    # создать пользователя, в случаее валидности данных
    def create(self, validated_data):
        email = validated_data["email"]
        username = validated_data["username"]
        first_name = validated_data["first_name"]
        last_name = validated_data["last_name"]
        password = validated_data["password"]

        user = get_user_model()
        new_user = user.objects.create(email = email, username = username,
                                        first_name = first_name, last_name = last_name)
        # хешировать пароль
        new_user.set_password(password)
        new_user.save()
        return new_user
