import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/models/doctor_model.dart';
import 'package:health_sphere/widgets/loading_overlay.dart';
import 'package:health_sphere/screens/appointments_screen.dart';
import 'package:health_sphere/screens/notification_screen.dart';

class ConsultationWizardScreen extends StatefulWidget {
  final AppointmentModel? rescheduleAppointment;
  const ConsultationWizardScreen({super.key, this.rescheduleAppointment});

  @override
  State<ConsultationWizardScreen> createState() => _ConsultationWizardScreenState();
}

class _ConsultationWizardScreenState extends State<ConsultationWizardScreen> {
  int _currentStep = 0; // 0: Symptoms, 1: Patient, 2: Payment, 3: Call Simulator

  // Step 1 State
  int? _selectedSymptomIndex;
  final List<Map<String, dynamic>> _symptoms = [
    {
      'title': 'बाल स्वास्थ्य उपचार',
      'subtitle': 'Child Healthcare',
      'desc': 'बालबालिकाको पोषण, बालबालिकाको हेरचाह, बालबालिकाको सिकाइ, बालबालिकाको व्यवहार, बालबालिकाको स्वास्थ्य समस्या, बालबालिकाको खोप...',
      'icon': Icons.child_care_rounded,
      'color': Color(0xFFF98E8E),
      'bg': Color(0xFFFFECEC),
    },
    {
      'title': 'महिला स्वास्थ्य उपचार',
      'subtitle': 'Female Healthcare',
      'desc': 'महिनावारी, गर्भावस्था, अनियमित महिनावारी, तल्लोपेट दुख्ने समस्या, सन्तान नभएमा, परिवार नियोजन सम्बन्धी परामर्श...',
      'icon': Icons.female_rounded,
      'color': Color(0xFFE88EE8),
      'bg': Color(0xFFFDF0FD),
    },
    {
      'title': 'यौन र पारिवारिक स्वास्थ्य',
      'subtitle': 'Sexual & Family Health',
      'desc': 'यौन सम्बन्धी समस्या, परिवार नियोजन, इरेक्टाइल डिसफङ्क्सन, निःसन्तान, यौन-सन्तुष्टि, शीघ्रस्खलन, यौन जीवनको व्यवस्थापन सम्बन्धी परामर्श...',
      'icon': Icons.people_rounded,
      'color': Color(0xFF8E8EF9),
      'bg': Color(0xFFF0F0FF),
    },
    {
      'title': 'मानसिक स्वास्थ्य उपचार',
      'subtitle': 'Mental Healthcare',
      'desc': 'अनिद्रा, डर, खाना खान मन नलाग्ने, भिडमा डर लाग्ने, शंका लाग्ने, सबैले मेरै कुरा काटेका छन् कि जस्तो लाग्ने, कुनै पनि कुराले मनमा तनाव हुने...',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF8EC4F9),
      'bg': Color(0xFFECF5FF),
    },
    {
      'title': 'छाला स्वास्थ्य उपचार',
      'subtitle': 'Skin Healthcare',
      'desc': 'छालामा दाग, मुहासे, एग्जिमा, सोरियासिस, फंगल इन्फेक्सन, छालाको रुखोपन, एलर्जी, छाला सम्बन्धी विभिन्न समस्याहरूको परामर्श...',
      'icon': Icons.healing_rounded,
      'color': Color(0xFFFF9A6C),
      'bg': Color(0xFFFFF3EC),
    },
    {
      'title': 'हड्डी तथा जोर्नी उपचार',
      'subtitle': 'Orthopedic Care',
      'desc': 'जोर्नीको दुखाइ, घुँडाको समस्या, ढाडको दुखाइ, हड्डी भाँचिएमा, मांसपेशीको समस्या, खेलकुद चोटपटक, आर्थराइटिस...',
      'icon': Icons.accessibility_new_rounded,
      'color': Color(0xFF4DB6AC),
      'bg': Color(0xFFE0F7F5),
    },
    {
      'title': 'मुटु रोग उपचार',
      'subtitle': 'Cardiology',
      'desc': 'छाती दुख्नु, मुटुको ढुकढुकी अनियमित हुनु, उच्च रक्तचाप, कोलेस्टेरोल, मुटु सम्बन्धी जाँच र परामर्श...',
      'icon': Icons.favorite_rounded,
      'color': Color(0xFFEF5350),
      'bg': Color(0xFFFFEBEE),
    },
    {
      'title': 'सामान्य चिकित्सा',
      'subtitle': 'General Physician',
      'desc': 'ज्वरो, रुघाखोकी, पेट दुखाइ, उल्टी, पखाला, शरीर कमजोर लाग्नु, सामान्य स्वास्थ्य जाँच, स्वास्थ्य प्रमाणपत्र...',
      'icon': Icons.medical_services_rounded,
      'color': Color(0xFF66BB6A),
      'bg': Color(0xFFE8F5E9),
    },
  ];

  // Step 2 State
  String _selectedPatient = 'new'; // 'Sabina' or 'new'
  final TextEditingController _nameController = TextEditingController();
  String? _selectedGender;
  String? _selectedAge;
  final List<String> _genders = ['Female', 'Male', 'Other'];
  final List<String> _ages = ['Under 18', '18-25 years', '26-35 years', '36-45 years', '46-60 years', 'Above 60 years'];

  // Step 3 State
  String _selectedPaymentMethod = 'eSewa'; // 'eSewa', 'Khalti', 'Card', 'Hamro Pay'
  final TextEditingController _emailController = TextEditingController(text: 'sabinaniraula56@gmail.com');
  final TextEditingController _phoneController = TextEditingController(text: '9841234567');
  bool _couponApplied = false;

  // Step 4 State (Appointment Booking)
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 0;
  ConsultationType _selectedConsultationType = ConsultationType.videoCall;
  final TextEditingController _notesController = TextEditingController();
  bool _bookingConfirmed = false;
  bool _isBookingLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.rescheduleAppointment != null) {
      _currentStep = 3;
      _nameController.text = widget.rescheduleAppointment!.patientName;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _selectedSymptomIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया कुनै एक परामर्श विकल्प चयन गर्नुहोस् (Please select one option)')),
      );
      return;
    }
    if (_currentStep == 1 && _nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('कृपया बिरामीको नाम लेख्नुहोस् (Please enter patient name)')),
      );
      return;
    }
    if (_currentStep == 2) {
      if (_phoneController.text.trim().isEmpty || _emailController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('सम्पर्क विवरण आवश्यक छ (Contact information is required)')),
        );
        return;
      }
    }
    if (_currentStep == 3) {
      _confirmBooking();
      return;
    }
    setState(() {
      _currentStep++;
    });
  }

  void _confirmBooking() {
    setState(() {
      _isBookingLoading = true;
    });

    // Resolve doctor from centralized registry — single source of truth
    late final DoctorModel doctor;
    if (widget.rescheduleAppointment != null) {
      // For reschedule, reconstruct from existing appointment data
      doctor = DoctorModel(
        name: widget.rescheduleAppointment!.doctorName,
        specialty: widget.rescheduleAppointment!.doctorSpecialty,
        avatarUrl: widget.rescheduleAppointment!.doctorAvatar,
      );
    } else {
      final selectedSymptom = _symptoms[_selectedSymptomIndex ?? 0];
      doctor = DoctorRegistry.forSymptom(selectedSymptom['subtitle'] as String);
    }

    final dates = List<DateTime>.generate(5, (index) => DateTime.now().add(Duration(days: index)));
    final bookingDate = dates[_selectedDateIndex];
    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${weekdays[bookingDate.weekday - 1]}, ${months[bookingDate.month - 1]} ${bookingDate.day}';

    final List<String> timeSlots = [
      '09:00 AM - 09:30 AM',
      '10:30 AM - 11:00 AM',
      '11:30 AM - 12:00 PM',
      '02:00 PM - 02:30 PM',
      '03:30 PM - 04:00 PM',
      '05:00 PM - 05:30 PM',
    ];
    final timeStr = timeSlots[_selectedTimeIndex];
    final consultType = _selectedConsultationType.shortLabel;

    final patientName = _nameController.text.trim().isEmpty
        ? (widget.rescheduleAppointment?.patientName ?? 'Guest')
        : _nameController.text.trim();

    if (widget.rescheduleAppointment != null) {
      final idx = AppointmentsScreen.upcomingAppointments.indexWhere((app) => app == widget.rescheduleAppointment);
      final newAppt = AppointmentModel.fromDoctor(
        doctor: doctor,
        patientName: patientName,
        time: timeStr,
        date: dateStr,
        type: consultType,
      );
      if (idx != -1) {
        AppointmentsScreen.upcomingAppointments[idx] = newAppt;
      } else {
        AppointmentsScreen.upcomingAppointments.add(newAppt);
      }
    } else {
      AppointmentsScreen.upcomingAppointments.add(
        AppointmentModel.fromDoctor(
          doctor: doctor,
          patientName: patientName,
          time: timeStr,
          date: dateStr,
          type: consultType,
        ),
      );
    }

    // Add notification
    final String notifTitle = widget.rescheduleAppointment != null ? 'Appointment Rescheduled' : 'Appointment Confirmed';
    final String notifMessage = widget.rescheduleAppointment != null
        ? 'Your appointment with ${doctor.name} has been rescheduled to $dateStr at $timeStr.'
        : 'Your appointment with ${doctor.name} is successfully booked for $dateStr at $timeStr.';

    NotificationScreen.notifications.insert(
      0,
      NotificationModel(
        title: notifTitle,
        message: notifMessage,
        time: 'Just now',
        icon: widget.rescheduleAppointment != null ? Icons.update_rounded : Icons.check_circle_outline_rounded,
        iconColor: AppColors.primary,
        iconBgColor: AppColors.primarySoft,
      ),
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isBookingLoading = false;
          _bookingConfirmed = true;
        });
      }
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isConfirmed = _bookingConfirmed;

    return LoadingOverlay(
      isLoading: _isBookingLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: isConfirmed
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                leadingWidth: 62,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        if (widget.rescheduleAppointment != null) {
                          Navigator.of(context).pop();
                        } else if (_currentStep > 0) {
                          _prevStep();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMain),
                      ),
                    ),
                  ),
                ),
                title: Text(
                  widget.rescheduleAppointment != null
                      ? 'Reschedule Appointment'
                      : (_currentStep == 2 ? 'Buy Tickets' : 'Instant Consult'),
                  style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        body: Column(
          children: [
            if (!isConfirmed && widget.rescheduleAppointment == null) ...[
              _buildProgressBar(),
              const Divider(height: 1, thickness: 1, color: Color(0xFFF2F4F7)),
            ],
            Expanded(
              child: _buildStepContent(),
            ),
            if (!isConfirmed) _buildBottomNavbar(),
          ],
        ),
      ),
    );
  }

  // ── Step Progress Indicator ──────────────────────────────────────────────────
  Widget _buildProgressBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
      child: Row(
        children: List.generate(4, (index) {
          final isCompleted = _currentStep > index;
          final isActive = _currentStep == index;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.primary
                        : (isActive ? AppColors.primary : Colors.grey.shade300),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isActive || isCompleted ? Colors.white : Colors.grey.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isCompleted ? AppColors.primary : Colors.grey.shade200,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step Contents ────────────────────────────────────────────────────────────
  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildSymptomSelection();
      case 1:
        return _buildPatientDetails();
      case 2:
        return _buildPaymentView();
      case 3:
        return _bookingConfirmed ? _buildSuccessView() : _buildAppointmentBooking();
      default:
        return Container();
    }
  }

  // ── Step 1: Select Symptoms ──────────────────────────────────────────────────
  Widget _buildSymptomSelection() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16, left: 4),
          child: Text(
            'Select your symptoms for consultation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
          ),
        ),
        ...List.generate(_symptoms.length, (index) {
          final symptom = _symptoms[index];
          final isSelected = _selectedSymptomIndex == index;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () {
                setState(() {
                  _selectedSymptomIndex = index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: symptom['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        symptom['icon'] as IconData,
                        color: symptom['color'] as Color,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            symptom['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            symptom['subtitle'] as String,
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            symptom['desc'] as String,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary.withValues(alpha: 0.8), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Step 2: Patient Details ──────────────────────────────────────────────────
  Widget _buildPatientDetails() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Select Patient detail',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        const SizedBox(height: 16),

        // Quick patient selectors
        Row(
          children: [
            // Add new patient button
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPatient = 'new';
                  _nameController.clear();
                  _selectedGender = null;
                  _selectedAge = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedPatient == 'new' ? AppColors.primarySoft : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPatient == 'new' ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: _selectedPatient == 'new' ? AppColors.primary : Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      'Add new patient',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedPatient == 'new' ? AppColors.primary : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Pre-existing Sabina patient
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPatient = 'Sabina';
                  _nameController.text = 'Sabina';
                  _selectedGender = 'Female';
                  _selectedAge = '18-25 years';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedPatient == 'Sabina' ? AppColors.primarySoft : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _selectedPatient == 'Sabina' ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  children: [
                    if (_selectedPatient == 'Sabina')
                      const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                    if (_selectedPatient == 'Sabina') const SizedBox(width: 6),
                    Text(
                      'Sabina',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _selectedPatient == 'Sabina' ? AppColors.primary : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text('Profile', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
            ),
            Expanded(child: Container(height: 1, color: Colors.grey.shade200)),
          ],
        ),
        const SizedBox(height: 20),

        // Patient Form
        const Text('Name *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter patient full name',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 18),

        const Text('Gender *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedGender,
          items: _genders.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedGender = val);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 18),

        const Text('Please select age *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedAge,
          items: _ages.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedAge = val);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ── Step 3: Buy Ticket (Payment) ─────────────────────────────────────────────
  Widget _buildPaymentView() {
    final selectedSymptom = _symptoms[_selectedSymptomIndex ?? 0];
    final double baseAmount = 750.0;
    final double discount = _couponApplied ? 150.0 : 0.0;
    final double finalAmount = baseAmount - discount;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Instant Call detail card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Instant Call', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(
                '${selectedSymptom['subtitle']} (${selectedSymptom['title']})',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
              ),
              const SizedBox(height: 10),
              Text(
                'NPR Rs. ${finalAmount.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(height: 8),
              const Text(
                "Ticket purchased to consult with this Speciality can't be used to call other Speciality",
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Coupon button
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton(
            onPressed: () {
              setState(() {
                _couponApplied = !_couponApplied;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(_couponApplied ? 'COUPON APPLIED (-Rs. 150)' : 'APPLY A COUPON'),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Choose your payment method', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain)),
        const SizedBox(height: 12),

        // Payment Method Selector
        SizedBox(
          height: 90,
          width: double.infinity,
          child: _buildPaymentCard('eSewa', 'assets/esewa_logo.png', Colors.green.shade50),
        ),
        const SizedBox(height: 24),

        const Text('Contact information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain)),
        const SizedBox(height: 16),

        const Text('Email Address *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
        const SizedBox(height: 16),

        const Text('Phone Number *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          '*Phone number and email is required to receive updates in SMS and email.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildPaymentCard(String name, String assetPath, Color bg, {bool isComingSoon = false, bool isGeneric = false, IconData? icon}) {
    final isSelected = _selectedPaymentMethod == name;
    return GestureDetector(
      onTap: isComingSoon ? null : () => setState(() => _selectedPaymentMethod = name),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey.shade200,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isGeneric)
                    Icon(icon ?? Icons.payment, size: 28, color: AppColors.primary)
                  else
                    // Fallback to stylized logo name if assets are missing
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: name == 'eSewa' ? Colors.green.shade700 : name == 'Khalti' ? Colors.purple.shade700 : Colors.orange.shade700,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isComingSoon ? Colors.grey : AppColors.textMain)),
                ],
              ),
            ),
          ),
          if (isComingSoon)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(16), bottomLeft: Radius.circular(8)),
                ),
                child: const Text('Coming soon', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
        ],
      ),
    );
  }

  // ── Step 4: Appointment Booking ──────────────────────────────────────────────
  Widget _buildAppointmentBooking() {
    // Resolve doctor from centralized registry
    late final DoctorModel doctor;
    if (widget.rescheduleAppointment != null) {
      doctor = DoctorModel(
        name: widget.rescheduleAppointment!.doctorName,
        specialty: widget.rescheduleAppointment!.doctorSpecialty,
        avatarUrl: widget.rescheduleAppointment!.doctorAvatar,
      );
    } else {
      final selectedSymptom = _symptoms[_selectedSymptomIndex ?? 0];
      doctor = DoctorRegistry.forSymptom(selectedSymptom['subtitle'] as String);
    }

    // Dynamic dates (Next 5 days)
    final List<DateTime> dates = List.generate(5, (index) => DateTime.now().add(Duration(days: index)));
    final List<String> timeSlots = [
      '09:00 AM - 09:30 AM',
      '10:30 AM - 11:00 AM',
      '11:30 AM - 12:00 PM',
      '02:00 PM - 02:30 PM',
      '03:30 PM - 04:00 PM',
      '05:00 PM - 05:30 PM',
    ];

    final List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Book Appointment Slot',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
        const SizedBox(height: 16),

        // Specialist Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primarySoft,
                backgroundImage: NetworkImage(doctor.avatarUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${doctor.specialty} Specialist',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMain),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.work_rounded, color: Colors.grey.shade400, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.experience} Exp',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'AVAILABLE',
                  style: TextStyle(color: Colors.green.shade700, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── Consultation Type Selector ──────────────────────────────────────
        const Text(
          'Method of Consultation',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
        ),
        const SizedBox(height: 12),
        Row(
          children: ConsultationType.values.map((type) {
            final isSelected = _selectedConsultationType == type;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedConsultationType = type),
                child: Container(
                  margin: EdgeInsets.only(right: type != ConsultationType.clinicVisit ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primarySoft : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        type.icon,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textMain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Select Date
        const Text(
          'Select Consultation Date',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 76,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final isSelected = _selectedDateIndex == index;
              // Check if ALL time slots are unavailable for this date
              final allSlotsUnavailable = List.generate(timeSlots.length, (t) => t).every((t) => doctor.isSlotUnavailable(index, t));
              final dayNum = date.day.toString();
              final dayName = weekdays[date.weekday - 1];
              final monthName = months[date.month - 1];

              return GestureDetector(
                onTap: allSlotsUnavailable ? null : () {
                  setState(() {
                    _selectedDateIndex = index;
                    // Auto-select first available time slot for this date
                    for (int t = 0; t < timeSlots.length; t++) {
                      if (!doctor.isSlotUnavailable(index, t)) {
                        _selectedTimeIndex = t;
                        break;
                      }
                    }
                  });
                },
                child: Container(
                  width: 68,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: allSlotsUnavailable
                        ? Colors.red.withValues(alpha: 0.06)
                        : (isSelected ? AppColors.primary : Colors.white),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: allSlotsUnavailable
                          ? Colors.red.withValues(alpha: 0.25)
                          : (isSelected ? AppColors.primary : Colors.grey.shade200),
                    ),
                    boxShadow: isSelected && !allSlotsUnavailable
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: allSlotsUnavailable
                              ? Colors.red.withValues(alpha: 0.4)
                              : (isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dayNum,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: allSlotsUnavailable
                              ? Colors.red.withValues(alpha: 0.4)
                              : (isSelected ? Colors.white : AppColors.textMain),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        monthName,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: allSlotsUnavailable
                              ? Colors.red.withValues(alpha: 0.4)
                              : (isSelected ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Select Time
        const Text(
          'Select Consultation Time Slot',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: timeSlots.length,
          itemBuilder: (context, index) {
            final slot = timeSlots[index];
            final isSelected = _selectedTimeIndex == index;
            final isUnavailable = doctor.isSlotUnavailable(_selectedDateIndex, index);

            return GestureDetector(
              onTap: isUnavailable ? null : () {
                setState(() {
                  _selectedTimeIndex = index;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isUnavailable
                      ? Colors.red.withValues(alpha: 0.06)
                      : (isSelected ? AppColors.primarySoft : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnavailable
                        ? Colors.red.withValues(alpha: 0.25)
                        : (isSelected ? AppColors.primary : Colors.grey.shade200),
                    width: isSelected && !isUnavailable ? 1.5 : 1.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isUnavailable) ...[
                      Icon(Icons.block_rounded, size: 13, color: Colors.red.withValues(alpha: 0.4)),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      slot,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected && !isUnavailable ? FontWeight.bold : FontWeight.w500,
                        color: isUnavailable
                            ? Colors.red.withValues(alpha: 0.4)
                            : (isSelected ? AppColors.primary : AppColors.textMain),
                        decoration: isUnavailable ? TextDecoration.lineThrough : null,
                        decorationColor: Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),

        // Additional notes
        const Text(
          'Notes for Doctor (Optional)',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(fontSize: 14, color: AppColors.textMain),
          decoration: InputDecoration(
            hintText: 'Enter symptoms detail, past history or special requests…',
            hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5), fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Step 5: Appointment Booking Success View ─────────────────────────────────
  Widget _buildSuccessView() {
    String doctorName = 'Dr. James Chen';
    String doctorSpecialty = 'General Physician';
    
    if (widget.rescheduleAppointment != null) {
      doctorName = widget.rescheduleAppointment!.doctorName;
      doctorSpecialty = widget.rescheduleAppointment!.doctorSpecialty;
    } else {
      final selectedSymptom = _symptoms[_selectedSymptomIndex ?? 0];
      final String subtitle = selectedSymptom['subtitle'] as String;
      if (subtitle.contains('Child')) {
        doctorName = 'Dr. Priya Rao';
        doctorSpecialty = 'Pediatrician';
      } else if (subtitle.contains('Female')) {
        doctorName = 'Dr. Sarah Mills';
        doctorSpecialty = 'Gynecologist';
      } else if (subtitle.contains('Sexual')) {
        doctorName = 'Dr. James Chen';
        doctorSpecialty = 'Urologist';
      } else if (subtitle.contains('Mental')) {
        doctorName = 'Dr. Alan Ford';
        doctorSpecialty = 'Psychiatrist';
      } else if (subtitle.contains('Skin')) {
        doctorName = 'Dr. Meena Gurung';
        doctorSpecialty = 'Dermatologist';
      } else if (subtitle.contains('Orthopedic')) {
        doctorName = 'Dr. Alan Ford';
        doctorSpecialty = 'Orthopedist';
      } else if (subtitle.contains('Cardiology')) {
        doctorName = 'Dr. Sarah Mills';
        doctorSpecialty = 'Cardiologist';
      }
    }

    final dates = List<DateTime>.generate(5, (index) => DateTime.now().add(Duration(days: index)));
    final bookingDate = dates[_selectedDateIndex];
    final List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    final dateStr = '${weekdays[bookingDate.weekday - 1]}, ${months[bookingDate.month - 1]} ${bookingDate.day}';
    
    final List<String> timeSlots = [
      '09:00 AM - 09:30 AM',
      '10:30 AM - 11:00 AM',
      '11:30 AM - 12:00 PM',
      '02:00 PM - 02:30 PM',
      '03:30 PM - 04:00 PM',
      '05:00 PM - 05:30 PM',
    ];
    final timeStr = timeSlots[_selectedTimeIndex];
    final String ticketId = 'HS-TKT-${bookingDate.millisecondsSinceEpoch.toString().substring(6)}';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),

          // Centered glowing animated success checkmark
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 30,
                  spreadRadius: 4,
                )
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 64,
              ),
            ),
          ),
          const SizedBox(height: 28),

          Text(
            widget.rescheduleAppointment != null ? 'Appointment Rescheduled! 🎉' : 'Appointment Confirmed! 🎉',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textMain,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.rescheduleAppointment != null
                ? 'Your appointment date and time have been updated successfully.'
                : 'Your token number and consultation detail have been generated.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 32),

          // Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              children: [
                _buildConfirmRow('Ticket ID', ticketId, isPrimary: true),
                const Divider(height: 24, thickness: 1, color: Color(0xFFE4E7EC)),
                _buildConfirmRow('Doctor Name', doctorName),
                const SizedBox(height: 12),
                _buildConfirmRow('Speciality', doctorSpecialty),
                const SizedBox(height: 12),
                _buildConfirmRow('Patient Name', widget.rescheduleAppointment != null ? widget.rescheduleAppointment!.patientName : (_nameController.text.trim().isEmpty ? 'Guest' : _nameController.text.trim())),
                const SizedBox(height: 12),
                _buildConfirmRow('Appointment Date', dateStr),
                const SizedBox(height: 12),
                _buildConfirmRow('Time Slot', timeStr),
              ],
            ),
          ),

          const Spacer(),

          // Back to home button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Back to Dashboard',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildConfirmRow(String label, String value, {bool isPrimary = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isPrimary ? FontWeight.w800 : FontWeight.bold,
            color: isPrimary ? AppColors.primary : AppColors.textMain,
          ),
        ),
      ],
    );
  }

  // ── Step Navigation Bottom Bar ───────────────────────────────────────────────
  Widget _buildBottomNavbar() {
    final double amount = _couponApplied ? 600.0 : 750.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF2F4F7))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          TextButton.icon(
            onPressed: _currentStep > 0 ? _prevStep : null,
            icon: Icon(Icons.chevron_left_rounded, color: _currentStep > 0 ? AppColors.primary : Colors.grey.shade400),
            label: Text(
              'PREVIOUS',
              style: TextStyle(
                color: _currentStep > 0 ? AppColors.primary : Colors.grey.shade400,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          // Next dot indicators
          Row(
            children: List.generate(4, (index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentStep == index ? AppColors.primary : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),

          // Next / Continue button
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Row(
              children: [
                Text(
                  _currentStep == 2
                      ? 'PAY Rs. ${amount.toStringAsFixed(0)}'
                      : (_currentStep == 3 ? 'CONFIRM BOOKING' : 'NEXT'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
