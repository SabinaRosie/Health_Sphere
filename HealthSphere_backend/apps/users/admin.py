from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from .models import User, Doctor, Appointment, Notification

class CustomUserAdmin(UserAdmin):
    model = User
    list_display = ('email', 'full_name', 'is_staff', 'is_active')
    list_filter = ('is_staff', 'is_active')
    fieldsets = (
        (None, {'fields': ('email', 'password')}),
        ('Personal Info', {'fields': ('full_name',)}),
        ('Permissions', {'fields': ('is_active', 'is_staff', 'is_superuser', 'groups', 'user_permissions')}),
        ('Important dates', {'fields': ('last_login', 'date_joined')}),
    )
    search_fields = ('email', 'full_name')
    ordering = ('email',)

admin.site.register(User, CustomUserAdmin)

@admin.register(Doctor)
class DoctorAdmin(admin.ModelAdmin):
    list_display = ('name', 'specialty', 'rating', 'experience')
    search_fields = ('name', 'specialty')
    list_filter = ('specialty',)

@admin.register(Appointment)
class AppointmentAdmin(admin.ModelAdmin):
    list_display = ('patient_name', 'user', 'doctor', 'date', 'time', 'type', 'is_rescheduled', 'created_at')
    search_fields = ('patient_name', 'user__email', 'doctor__name')
    list_filter = ('is_rescheduled', 'type', 'date')
    date_hierarchy = 'created_at'

@admin.register(Notification)
class NotificationAdmin(admin.ModelAdmin):
    list_display = ('title', 'user', 'is_read', 'created_at')
    search_fields = ('title', 'message', 'user__email')
    list_filter = ('is_read',)
    date_hierarchy = 'created_at'
