import 'package:flutter/material.dart';

class DoctorModel {
  final String name;
  final String specialty;
  final String avatarUrl;
  final double rating;
  final String experience;
  // Set of (dateIndex, timeSlotIndex) pairs that are unavailable
  final Set<String> unavailableSlots;

  const DoctorModel({
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    this.rating = 4.8,
    this.experience = '8+ Yrs',
    this.unavailableSlots = const {},
  });

  bool isSlotUnavailable(int dateIndex, int timeIndex) {
    return unavailableSlots.contains('$dateIndex-$timeIndex');
  }
}

/// Centralized mapping: symptom subtitle keyword → DoctorModel
/// ONE single source of truth used by every screen.
class DoctorRegistry {
  static const DoctorModel _priya = DoctorModel(
    name: 'Dr. Priya Rao',
    specialty: 'Pediatrician',
    avatarUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop',
    rating: 4.9,
    experience: '12+ Yrs',
    unavailableSlots: {'0-0', '0-1', '1-3', '2-5'},
  );

  static const DoctorModel _sarah = DoctorModel(
    name: 'Dr. Sarah Mills',
    specialty: 'Gynecologist',
    avatarUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&auto=format&fit=crop',
    rating: 4.9,
    experience: '10+ Yrs',
    unavailableSlots: {'0-2', '1-0', '3-4', '4-1'},
  );

  static const DoctorModel _james = DoctorModel(
    name: 'Dr. James Chen',
    specialty: 'Urologist',
    avatarUrl: 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&auto=format&fit=crop',
    rating: 4.8,
    experience: '9+ Yrs',
    unavailableSlots: {'0-3', '2-1', '3-0', '4-5'},
  );

  static const DoctorModel _alan = DoctorModel(
    name: 'Dr. Alan Ford',
    specialty: 'Psychiatrist',
    avatarUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150&auto=format&fit=crop',
    rating: 4.7,
    experience: '15+ Yrs',
    unavailableSlots: {'0-4', '1-2', '2-3', '3-5'},
  );

  static const DoctorModel _meena = DoctorModel(
    name: 'Dr. Meena Gurung',
    specialty: 'Dermatologist',
    avatarUrl: 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=150&auto=format&fit=crop',
    rating: 4.8,
    experience: '7+ Yrs',
    unavailableSlots: {'1-1', '2-4', '3-2', '4-0'},
  );

  static const DoctorModel _alanOrtho = DoctorModel(
    name: 'Dr. Alan Ford',
    specialty: 'Orthopedist',
    avatarUrl: 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150&auto=format&fit=crop',
    rating: 4.7,
    experience: '15+ Yrs',
    unavailableSlots: {'0-5', '1-4', '2-0', '4-3'},
  );

  static const DoctorModel _sarahCardio = DoctorModel(
    name: 'Dr. Sarah Mills',
    specialty: 'Cardiologist',
    avatarUrl: 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&auto=format&fit=crop',
    rating: 4.9,
    experience: '10+ Yrs',
    unavailableSlots: {'1-5', '2-2', '3-1', '4-4'},
  );

  static const DoctorModel _general = DoctorModel(
    name: 'Dr. Kevin Patel',
    specialty: 'General Physician',
    avatarUrl: 'https://images.unsplash.com/photo-1612531385446-f7e6d131e1d0?w=150&auto=format&fit=crop',
    rating: 4.5,
    experience: '6+ Yrs',
    unavailableSlots: {'0-1', '1-3', '3-3', '4-2'},
  );

  /// Resolve the doctor for a given symptom subtitle.
  static DoctorModel forSymptom(String subtitle) {
    if (subtitle.contains('Child')) return _priya;
    if (subtitle.contains('Female')) return _sarah;
    if (subtitle.contains('Sexual')) return _james;
    if (subtitle.contains('Mental')) return _alan;
    if (subtitle.contains('Skin')) return _meena;
    if (subtitle.contains('Orthopedic')) return _alanOrtho;
    if (subtitle.contains('Cardiology')) return _sarahCardio;
    return _general;
  }

  /// Resolve doctor for a given symptom index (0-based, matching wizard symptom list)
  static DoctorModel forSymptomIndex(int index, List<Map<String, dynamic>> symptoms) {
    if (index < 0 || index >= symptoms.length) return _general;
    final subtitle = symptoms[index]['subtitle'] as String;
    return forSymptom(subtitle);
  }
}

/// Consultation mode
enum ConsultationType { videoCall, audioCall, clinicVisit }

extension ConsultationTypeExtension on ConsultationType {
  String get label {
    switch (this) {
      case ConsultationType.videoCall: return 'Video Call';
      case ConsultationType.audioCall: return 'Audio Call';
      case ConsultationType.clinicVisit: return 'Clinic Visit';
    }
  }

  IconData get icon {
    switch (this) {
      case ConsultationType.videoCall: return Icons.videocam_rounded;
      case ConsultationType.audioCall: return Icons.phone_rounded;
      case ConsultationType.clinicVisit: return Icons.local_hospital_rounded;
    }
  }

  String get shortLabel {
    switch (this) {
      case ConsultationType.videoCall: return 'Video Consult';
      case ConsultationType.audioCall: return 'Audio Call';
      case ConsultationType.clinicVisit: return 'Clinic Visit';
    }
  }
}
