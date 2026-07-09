/// App-wide constants for Health Sphere
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Health Sphere';
  static const String appVersion = '1.0.0';

  // Animation Durations (in milliseconds)
  static const int splashDuration = 2500;
  static const int animationFast = 300;
  static const int animationNormal = 600;
  static const int animationSlow = 900;

  // API & Network
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Shared Preferences Keys
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';
  static const String keyUserName = 'user_name';

  // Pagination
  static const int defaultPageSize = 10;

  // Doctor Consultation Types
  static const String consultationInClinic = 'In-Clinic';
  static const String consultationOnline = 'Online';
  static const String consultationHomeVisit = 'Home Visit';

  // Appointment Status
  static const String appointmentUpcoming = 'upcoming';
  static const String appointmentCompleted = 'completed';
  static const String appointmentCancelled = 'cancelled';
}
