import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/home_screen.dart';
import 'package:health_sphere/screens/appointments_screen.dart';
import 'package:health_sphere/screens/profile_screen.dart';

import 'package:health_sphere/screens/doctors_screen.dart';
import 'package:health_sphere/screens/blog_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with TickerProviderStateMixin {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(icon: Icons.home_outlined,        activeIcon: Icons.home_rounded,             label: 'Home'),
    _NavItem(icon: Icons.medical_services_outlined, activeIcon: Icons.medical_services_rounded, label: 'Doctors'),
    _NavItem(icon: Icons.article_outlined,     activeIcon: Icons.article_rounded,          label: 'Blog'),
    _NavItem(icon: Icons.chat_bubble_outline_rounded, activeIcon: Icons.chat_bubble_rounded, label: 'Chat'),
    _NavItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_today_rounded, label: 'Schedule'),
    _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded,         label: 'Profile'),
  ];

  late final List<AnimationController> _controllers;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_navItems.length, (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 220)));
    _controllers[0].forward();

    _screens = [
      HomeScreen(
        onProfileTap: () {
          _onTap(5); // Switch to Profile tab
        },
        onBlogTap: () {
          _onTap(2); // Switch to Blog tab
        },
      ),
      DoctorsScreen(
        onBack: () => _onTap(0),
      ),
      BlogScreen(
        onBack: () => _onTap(0),
      ),
      _PlaceholderScreen(
        icon: Icons.chat_bubble_rounded,
        label: 'Chat',
        desc: 'Message your doctor anytime',
        onBack: () => _onTap(0),
      ),
      AppointmentsScreen(
        onBack: () => _onTap(0),
      ),
      ProfileScreen(
        onBack: () => _onTap(0),
      ),
    ];
  }

  @override
  void dispose() {
    for (final c in _controllers) { c.dispose(); }
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
