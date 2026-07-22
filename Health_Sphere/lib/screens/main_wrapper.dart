import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/home_screen.dart';
import 'package:health_sphere/screens/appointments_screen.dart';
import 'package:health_sphere/screens/profile_screen.dart';

import 'package:health_sphere/screens/doctors_screen.dart';
import 'package:health_sphere/screens/blog_screen.dart';
import 'package:health_sphere/screens/chat_screen.dart';
import 'package:health_sphere/screens/doctor/doctor_dashboard_screen.dart';
import 'package:health_sphere/screens/admin/admin_dashboard_screen.dart';
import 'package:health_sphere/screens/doctor/verification_screen.dart';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _userRole = 'patient';
  String _verificationStatus = 'unverified';
  bool _isLoading = true;

  List<_NavItem> _navItems = [];
  List<AnimationController> _controllers = [];
  List<Widget> _screens = [];

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://192.168.101.5:8000';
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('user_role') ?? 'patient';
    final email = prefs.getString('user_email');

    if (_userRole == 'doctor' && email != null) {
      await _checkVerificationStatus(email);
    } else {
      _setupNavigation();
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkVerificationStatus(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/doctor-profile/?email=$email'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _verificationStatus = data['verification_status'] ?? 'unverified';
      }
    } catch (e) {
      debugPrint('Error checking status: $e');
    }
    _setupNavigation();
    setState(() => _isLoading = false);
  }

  void _setupNavigation() {
    if (_userRole == 'admin') {
      _navItems = [
        const _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Stats'),
        const _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Users'),
        const _NavItem(icon: Icons.assessment_outlined, activeIcon: Icons.assessment_rounded, label: 'Reports'),
        const _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings'),
        const _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
      ];
      _screens = [
        const AdminDashboardScreen(),
        _PlaceholderScreen(icon: Icons.people_rounded, label: 'User Management', desc: 'Manage patients, doctors and staff', onBack: () => _onTap(0)),
        _PlaceholderScreen(icon: Icons.assessment_rounded, label: 'System Reports', desc: 'View and export system data', onBack: () => _onTap(0)),
        _PlaceholderScreen(icon: Icons.settings_rounded, label: 'Admin Settings', desc: 'Configure system parameters', onBack: () => _onTap(0)),
        ProfileScreen(onBack: () => _onTap(0)),
      ];
    } else if (_userRole == 'doctor') {
      if (_verificationStatus == 'unverified') {
        _navItems = [const _NavItem(icon: Icons.verified_user_outlined, activeIcon: Icons.verified_user, label: 'Verification')];
        _screens = [DoctorVerificationScreen(onComplete: () => _loadUserRole())];
      } else if (_verificationStatus == 'pending') {
        _navItems = [const _NavItem(icon: Icons.hourglass_empty, activeIcon: Icons.hourglass_full, label: 'Status')];
        _screens = [
          _PlaceholderScreen(
            icon: Icons.hourglass_top_rounded,
            label: 'Verification Pending',
            desc: 'Your application is being reviewed by the admin.\nWe will notify you once it is approved.',
            onBack: () => _onTap(0),
          )
        ];
      } else if (_verificationStatus == 'rejected') {
        _navItems = [const _NavItem(icon: Icons.error_outline, activeIcon: Icons.error, label: 'Rejected')];
        _screens = [
          _PlaceholderScreen(
            icon: Icons.cancel_outlined,
            label: 'Application Rejected',
            desc: 'Unfortunately, your application was not approved.\nPlease contact support or re-apply.',
            onBack: () => _onTap(0),
          )
        ];
      } else {
        // Verified Doctor
        _navItems = [
          const _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Dashboard'),
          const _NavItem(icon: Icons.calendar_month_outlined, activeIcon: Icons.calendar_month_rounded, label: 'Appointments'),
          const _NavItem(icon: Icons.groups_outlined, activeIcon: Icons.groups_rounded, label: 'Patients'),
          const _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat'),
          const _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
        ];
        _screens = [
          const DoctorDashboardScreen(),
          AppointmentsScreen(onBack: () => _onTap(0)),
          _PlaceholderScreen(icon: Icons.groups_rounded, label: 'My Patients', desc: 'Manage your patient records', onBack: () => _onTap(0)),
          ChatScreen(onBack: () => _onTap(0)),
          ProfileScreen(onBack: () => _onTap(0)),
        ];
      }
    } else {
      // Default: Patient
      _navItems = [
        const _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
        const _NavItem(icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services_rounded, label: 'Doctors'),
        const _NavItem(icon: Icons.article_outlined, activeIcon: Icons.article_rounded, label: 'Blog'),
        const _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat'),
        const _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Schedule'),
        const _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profile'),
      ];
      _screens = [
        HomeScreen(
          onProfileTap: () => _onTap(5),
          onBlogTap: () => _onTap(2),
          onScheduleTap: () => _onTap(4),
        ),
        DoctorsScreen(onBack: () => _onTap(0)),
        BlogScreen(onBack: () => _onTap(0)),
        ChatScreen(onBack: () => _onTap(0)),
        AppointmentsScreen(onBack: () => _onTap(0)),
        ProfileScreen(onBack: () => _onTap(0)),
      ];
    }

    _controllers = List.generate(
      _navItems.length,
      (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 220)),
    );
    _controllers[0].forward();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onTap(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    _controllers[_currentIndex].reverse();
    _controllers[index].forward();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    }
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _buildNav(),
    );
  }

  Widget _buildNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -3)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, _buildTab),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index) {
    final item = _navItems[index];
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controllers[index],
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(isActive ? 9 : 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isActive ? item.activeIcon : item.icon,
                size: 20,
                color: isActive ? Colors.white : AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textSecondary.withValues(alpha: 0.6),
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data ───────────────────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}

// ── Placeholder screens ────────────────────────────────────────────────────────

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final VoidCallback? onBack;
  const _PlaceholderScreen({required this.icon, required this.label, required this.desc, this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        onBack?.call();
                      }
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMain),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 76, height: 76, decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle), child: Icon(icon, color: AppColors.primary, size: 36)),
                  const SizedBox(height: 14),
                  Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 6),
                  Text(desc, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]), borderRadius: BorderRadius.circular(12)),
                    child: const Text('Coming Soon', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
