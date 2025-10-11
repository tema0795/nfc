from django.urls import path
from .views import (
    EmailTokenObtainPairView, EmailTokenRefreshView,
    pin_set, pin_verify, device_nfc_token, nfc_verify, me_profile
)

urlpatterns = [
    path("login/",   EmailTokenObtainPairView.as_view(), name="token_obtain_pair"),
    path("refresh/", EmailTokenRefreshView.as_view(),    name="token_refresh"),

    path("pin/set/",     pin_set),
    path("pin/verify/",  pin_verify),
    path("nfc-token/",   device_nfc_token),
    path("nfc-verify/",  nfc_verify),

    path("profile/", me_profile, name="me_profile"),
]
