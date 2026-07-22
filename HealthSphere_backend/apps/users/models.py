from django.contrib.auth.models import AbstractUser, BaseUserManager
from django.db import models

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('The Email field must be set')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        
        if extra_fields.get('is_staff') is not True:
            raise ValueError('Superuser must have is_staff=True.')
        if extra_fields.get('is_superuser') is not True:
            raise ValueError('Superuser must have is_superuser=True.')
            
        return self.create_user(email, password, **extra_fields)

class User(AbstractUser):
    ROLE_CHOICES = [
        ('patient', 'Patient'),
        ('doctor', 'Doctor/Nurse'),
        ('admin', 'Admin'),
    ]

    username = None
    email = models.EmailField(unique=True)
    full_name = models.CharField(max_length=255, blank=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='patient')

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    def __str__(self):
        return self.email

class Doctor(models.Model):
    VERIFICATION_STATUS = [
        ('unverified', 'Unverified'),
        ('pending', 'Pending Review'),
        ('verified', 'Verified'),
        ('rejected', 'Rejected'),
    ]

    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='doctor_profile', null=True, blank=True)
    name = models.CharField(max_length=255)
    specialty = models.CharField(max_length=255, blank=True)
    qualification = models.CharField(max_length=255, blank=True)
    experience = models.CharField(max_length=50, blank=True)
    bio = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)
    phone = models.CharField(max_length=20, blank=True)
    avatar_url = models.URLField(max_length=500, blank=True)

    # Verification Documents
    citizenship_card = models.FileField(upload_to='doctor_docs/citizenship/', null=True, blank=True)
    medical_license = models.FileField(upload_to='doctor_docs/licenses/', null=True, blank=True)
    recommendation_letter = models.FileField(upload_to='doctor_docs/recommendations/', null=True, blank=True)

    verification_status = models.CharField(max_length=20, choices=VERIFICATION_STATUS, default='unverified')

    rating = models.DecimalField(max_digits=3, decimal_places=1, default=4.5)
    available = models.BooleanField(default=True)
    reviews_count = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.name} - {self.specialty} ({self.verification_status})"

class Appointment(models.Model):
    CONSULTATION_TYPES = [
        ('Video Consult', 'Video Consult'),
        ('Audio Consult', 'Audio Consult'),
        ('Clinic Visit', 'Clinic Visit'),
    ]

    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='appointments', null=True, blank=True)
    doctor = models.ForeignKey(Doctor, on_delete=models.CASCADE, related_name='appointments')
    patient_name = models.CharField(max_length=255)
    date = models.CharField(max_length=100) # e.g., 'Mon, Aug 25'
    time = models.CharField(max_length=100) # e.g., '09:00 AM - 09:30 AM'
    type = models.CharField(max_length=50, choices=CONSULTATION_TYPES, default='Video Consult')
    is_rescheduled = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Appointment: {self.patient_name} with {self.doctor.name} on {self.date} at {self.time}"

class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='notifications', null=True, blank=True)
    title = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        user_display = self.user.email if self.user else "System"
        return f"Notification: {self.title} for {user_display}"
