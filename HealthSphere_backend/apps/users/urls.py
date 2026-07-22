from django.urls import path
from .views import RegisterView, LoginView, DoctorListView, DoctorProfileView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('doctors/', DoctorListView.as_view(), name='doctor-list'),
    path('doctor-profile/', DoctorProfileView.as_view(), name='doctor-profile'),
]
