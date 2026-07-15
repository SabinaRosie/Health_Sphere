import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/doctors_screen.dart';
import 'package:health_sphere/screens/consultation_wizard_screen.dart';
import 'package:health_sphere/screens/notification_screen.dart';
import 'package:health_sphere/screens/appointments_screen.dart';
import 'package:health_sphere/widgets/loading_overlay.dart';

class HomeScreen extends StatefulWidget {
  /// Called when user taps the profile avatar → MainWrapper switches to Profile tab.
  final VoidCallback? onProfileTap;

  /// Called when user taps "More" on Health Tips → MainWrapper switches to Blog tab.
  final VoidCallback? onBlogTap;

  /// Called when user taps "Next Appt" chip → MainWrapper switches to Schedule tab.
  final VoidCallback? onScheduleTap;

  const HomeScreen({super.key, this.onProfileTap, this.onBlogTap, this.onScheduleTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  String _userName = '';
  bool _isLoading = false;

  // Controllers for horizontal carousels
  final ScrollController _doctorsScrollController = ScrollController();
  final ScrollController _tipsScrollController = ScrollController();

  final List<Map<String, dynamic>> _doctors = [
    {'name': 'Dr. Sarah Mills',  'specialty': 'Cardiologist',  'rating': '4.9', 'image': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=150&auto=format&fit=crop',  'available': true},
    {'name': 'Dr. James Chen',   'specialty': 'Neurologist',   'rating': '4.8', 'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=150&auto=format&fit=crop',  'available': true},
    {'name': 'Dr. Priya Rao',    'specialty': 'Pediatrician',  'rating': '4.9', 'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150&auto=format&fit=crop',  'available': false},
    {'name': 'Dr. Alan Ford',    'specialty': 'Orthopedic',    'rating': '4.7', 'image': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150&auto=format&fit=crop',  'available': true},
    {'name': 'Dr. Meena Gurung', 'specialty': 'Pediatrician',  'rating': '4.9', 'image': 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=150&auto=format&fit=crop',  'available': true},
  ];

  final List<Map<String, dynamic>> _specialities = [
    {'icon': Icons.favorite_rounded,      'label': 'Cardiology',  'color': Color(0xFFFF7B54), 'bg': Color(0xFFFFF0EB)},
    {'icon': Icons.child_care_rounded,    'label': 'Pediatrics',  'color': Color(0xFF7C83FD), 'bg': Color(0xFFF0F1FF)},
    {'icon': Icons.psychology_rounded,    'label': 'Neurology',   'color': Color(0xFF25B4AE), 'bg': Color(0xFFE6F7F6)},
    {'icon': Icons.remove_red_eye_rounded,'label': 'Eye Care',    'color': Color(0xFF4CAF50), 'bg': Color(0xFFEDF7EE)},
    {'icon': Icons.healing_rounded,       'label': 'Orthopedic',  'color': Color(0xFFF5A623), 'bg': Color(0xFFFFF8ED)},
    {'icon': Icons.more_horiz_rounded,    'label': 'More',        'color': Color(0xFF7A868C), 'bg': Color(0xFFF4F7F8)},
  ];

  final List<Map<String, dynamic>> _healthTips = [
    {'title': 'Stay Hydrated',  'desc': 'Drink at least 8 glasses of water daily for optimal health.',    'icon': Icons.water_drop_rounded,     'gradient': [Color(0xFF25B4AE), Color(0xFF149C94)]},
    {'title': 'Daily Exercise', 'desc': '30 minutes of activity can boost your mood significantly.',       'icon': Icons.directions_run_rounded, 'gradient': [Color(0xFF7C83FD), Color(0xFF5C64D4)]},
    {'title': 'Sleep Well',     'desc': '7–9 hours of quality sleep is the key to recovery.',             'icon': Icons.bedtime_rounded,        'gradient': [Color(0xFFFF7B54), Color(0xFFE05C37)]},
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? '';
    if (mounted) setState(() => _userName = name);
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    await _loadUserName();
  }

  @override
  void dispose() {
    _animController.dispose();
    _doctorsScrollController.dispose();
    _tipsScrollController.dispose();
    super.dispose();
  }

  String get _greetingLine {
    final h = DateTime.now().hour;
    final emoji = h < 12 ? '🌤️' : h < 17 ? '☀️' : '🌙';
    final time  = h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
    final name  = _userName.isNotEmpty ? ', $_userName' : '';
    return '$time$name $emoji';
  }

  void _openDoctors() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const DoctorsScreen()));
  }

  void _scrollDoctorsRight() {
    if (_doctorsScrollController.hasClients) {
      double target = _doctorsScrollController.offset + 144.0;
      if (target > _doctorsScrollController.position.maxScrollExtent) {
        target = 0.0; // Wrap back to start
      }
      _doctorsScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollTipsRight() {
    if (_tipsScrollController.hasClients) {
      double target = _tipsScrollController.offset + 224.0;
      if (target > _tipsScrollController.position.maxScrollExtent) {
        target = 0.0; // Wrap back to start
      }
      _tipsScrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: Colors.white,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeader()),
                SliverToBoxAdapter(child: _buildSearchBar()),
                SliverToBoxAdapter(child: _buildQuickActions()),
                SliverToBoxAdapter(child: _buildSectionHeader('Top Doctors', 'See All', onAction: _openDoctors)),
                SliverToBoxAdapter(child: _buildDoctorsList()),
                SliverToBoxAdapter(child: _buildRecentConsultBanner()),
                SliverToBoxAdapter(child: _buildSectionHeader('Specialities', 'See All')),
                SliverToBoxAdapter(child: _buildSpecialities()),
                SliverToBoxAdapter(child: _buildSectionHeader('Health Tips', 'More', topPadding: 10, onAction: widget.onBlogTap)),
                SliverToBoxAdapter(child: _buildHealthTips()),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primaryLight, AppColors.primary], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greetingLine,
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'How are you feeling today?',
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const NotificationScreen()),
                          ).then((_) {
                            if (mounted) setState(() {});
                          });
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                          child: Stack(alignment: Alignment.center, children: [
                            const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                            if (NotificationScreen.hasUnread)
                              Positioned(top: 8, right: 8, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))),
                          ]),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Profile avatar — tappable
                      GestureDetector(
                        onTap: widget.onProfileTap,
                        child: Container(
                          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                          child: CircleAvatar(radius: 20, backgroundColor: Colors.white.withValues(alpha: 0.3), child: const Icon(Icons.person_rounded, color: Colors.white, size: 22)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(children: [
                _statChip(
                  icon: Icons.calendar_today_rounded, 
                  label: 'Next Appt', 
                  value: AppointmentsScreen.upcomingAppointments.isNotEmpty 
                      ? AppointmentsScreen.upcomingAppointments.first.date 
                      : 'None',
                  onTap: widget.onScheduleTap,
                ),
                const SizedBox(width: 12),
                _statChip(icon: Icons.medication_outlined, label: 'Medicines', value: '2 Due'),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statChip({required IconData icon, required String label, required String value, VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
          child: Row(children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 10, fontWeight: FontWeight.w500)),
              Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── Search Bar (No circled filter button, clean look) ─────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: GestureDetector(
        onTap: _openDoctors,
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 12),
              Text(
                'Search doctors, specialities…',
                style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _QuickActionItem(
            icon: Icons.phone_in_talk_rounded,
            label: 'Call Doctor',
            iconColor: AppColors.primary,
            bgColor: AppColors.primarySoft,
            onTap: () {
              setState(() => _isLoading = true);
              Future.delayed(const Duration(milliseconds: 1500), () {
                if (mounted) {
                  setState(() => _isLoading = false);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ConsultationWizardScreen()),
                  );
                }
              });
            },
          ),
          _QuickActionItem(
            icon: Icons.video_call_rounded,
            label: 'Video Consult',
            iconColor: const Color(0xFF7C83FD),
            bgColor: const Color(0xFFF0F1FF),
            onTap: () {},
          ),
          _QuickActionItem(
            icon: Icons.local_hospital_rounded,
            label: 'Emergency',
            iconColor: AppColors.accent,
            bgColor: AppColors.accentSoft,
            onTap: () {},
          ),
          _QuickActionItem(
            icon: Icons.science_rounded,
            label: 'Lab Tests',
            iconColor: const Color(0xFF4CAF50),
            bgColor: const Color(0xFFEDF7EE),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, String action, {double topPadding = 20, VoidCallback? onAction}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, topPadding, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          GestureDetector(
            onTap: onAction,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(20)),
              child: Text(action, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  // ── Doctors List with clickable right-arrow ──────────────────────────────────
  Widget _buildDoctorsList() {
    return Stack(
      children: [
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _doctorsScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 60),
            itemCount: _doctors.length,
            itemBuilder: (_, i) => _buildDoctorCard(_doctors[i]),
          ),
        ),
        // Clickable right arrow
        Positioned(
          right: 0, top: 0, bottom: 4,
          child: Container(
            width: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
              ),
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _scrollDoctorsRight,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doc) {
    final bool available = doc['available'] as bool;
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 14, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(doc['image'] as String, width: double.infinity, height: 90, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(height: 90, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 36))),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(color: available ? AppColors.success : AppColors.textSecondary, borderRadius: BorderRadius.circular(8)),
                      child: Text(available ? 'Free' : 'Busy', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Text(doc['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textMain), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(doc['specialty'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 5),
                Row(children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 12),
                  const SizedBox(width: 3),
                  Text(doc['rating'] as String, style: const TextStyle(color: AppColors.textMain, fontSize: 11, fontWeight: FontWeight.w600)),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Recent Consult Banner ─────────────────────────────────────────────────────
  Widget _buildRecentConsultBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.history_rounded, color: AppColors.primary, size: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('A user from Kathmandu successfully consulted with Dr. Sarah Mills', style: TextStyle(fontSize: 12, color: AppColors.textMain, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 3),
              Row(children: [
                const Icon(Icons.access_time_rounded, size: 11, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text('2 hours ago', style: TextStyle(fontSize: 11, color: AppColors.textSecondary.withValues(alpha: 0.8))),
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]), borderRadius: BorderRadius.circular(12)),
            child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
      ),
    );
  }

  // ── Specialities Grid ─────────────────────────────────────────────────────────
  Widget _buildSpecialities() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.05,
        padding: EdgeInsets.zero,
        children: _specialities.map((s) => _SpecialityItem(
          icon: s['icon'] as IconData, label: s['label'] as String,
          iconColor: s['color'] as Color, bgColor: s['bg'] as Color,
        )).toList(),
      ),
    );
  }

  // ── Health Tips with clickable right-arrow ───────────────────────────────────
  Widget _buildHealthTips() {
    return Stack(
      children: [
        SizedBox(
          height: 130,
          child: ListView.builder(
            controller: _tipsScrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(left: 20, right: 60),
            itemCount: _healthTips.length,
            itemBuilder: (_, i) {
              final tip = _healthTips[i];
              return Container(
                width: 210,
                margin: const EdgeInsets.only(right: 14, bottom: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: tip['gradient'] as List<Color>, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [BoxShadow(color: (tip['gradient'] as List<Color>)[0].withValues(alpha: 0.28), blurRadius: 12, offset: const Offset(0, 5))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(tip['title'] as String, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(tip['desc'] as String, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ])),
                    const SizedBox(width: 8),
                    Icon(tip['icon'] as IconData, color: Colors.white.withValues(alpha: 0.55), size: 40),
                  ]),
                ),
              );
            },
          ),
        ),
        // Clickable right arrow for health tips
        Positioned(
          right: 0, top: 0, bottom: 4,
          child: Container(
            width: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [AppColors.background.withValues(alpha: 0), AppColors.background],
              ),
            ),
            alignment: Alignment.center,
            child: GestureDetector(
              onTap: _scrollTipsRight,
              child: Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Quick Action Item ──────────────────────────────────────────────────────────
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;
  const _QuickActionItem({required this.icon, required this.label, required this.iconColor, required this.bgColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(borderRadius: BorderRadius.circular(16), onTap: onTap,
            child: SizedBox(width: 60, height: 60, child: Center(child: Icon(icon, color: iconColor, size: 27)))),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMain), textAlign: TextAlign.center),
    ]);
  }
}

// ── Speciality Item ────────────────────────────────────────────────────────────
class _SpecialityItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final Color bgColor;
  const _SpecialityItem({required this.icon, required this.label, required this.iconColor, required this.bgColor});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))]),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 20)),
            const SizedBox(height: 7),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMain), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
