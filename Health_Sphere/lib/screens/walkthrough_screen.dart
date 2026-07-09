import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/authentication/login_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      image: 'assets/onboarding_1.png',
      title: 'Book Appointments\nEasily',
      subtitle:
          'Schedule visits with top doctors in seconds. Choose your preferred date, time, and clinic — all in one tap.',
      bgColor: const Color(0xFFE8F9F7),
      accentColor: AppColors.primary,
    ),
    _OnboardingData(
      image: 'assets/onboarding_2.png',
      title: 'Consult Doctors\nOnline',
      subtitle:
          'Connect with experienced specialists via video call from the comfort of your home, anytime you need.',
      bgColor: const Color(0xFFE8F6FF),
      accentColor: const Color(0xFF3B82F6),
    ),
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/free-vector/online-doctor-concept-illustration_114360-1029.jpg',
      title: 'Find Top\nSpecialists',
      subtitle:
          'Browse verified doctors by specialty, read real patient reviews, and choose the best match for your needs.',
      bgColor: const Color(0xFFF3EEFF),
      accentColor: const Color(0xFF8B5CF6),
    ),
    _OnboardingData(
      imageUrl:
          'https://img.freepik.com/free-vector/medical-care-concept-illustration_114360-1073.jpg',
      title: 'Your Health,\nManaged',
      subtitle:
          'Track your medical history, lab results, and prescriptions in one secure place. Stay on top of your wellness.',
      bgColor: const Color(0xFFFFF3E8),
      accentColor: const Color(0xFFF97316),
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      backgroundColor: page.bgColor,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: page.bgColor,
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: TextButton(
                    onPressed: _navigateToLogin,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: page.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),

              // Pages
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _OnboardingPage(data: _pages[index]);
                  },
                ),
              ),

              // Bottom Section: Dots + Button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
                child: Column(
                  children: [
                    // Page Dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? page.accentColor
                                : page.accentColor.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Next / Get Started Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: page.accentColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final _OnboardingData data;

  const _OnboardingPage({required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Illustration
          Expanded(
            flex: 3,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                ),
                clipBehavior: Clip.antiAlias,
                child: data.image != null
                    ? Image.asset(
                        data.image!,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => _networkFallback(data),
                      )
                    : _networkFallback(data),
              ),
            ),
          ),

          // Text Content
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                Text(
                  data.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }

  Widget _networkFallback(_OnboardingData data) {
    return Image.network(
      data.imageUrl ?? '',
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            color: data.accentColor,
            strokeWidth: 2,
          ),
        );
      },
      errorBuilder: (_, __, ___) => Icon(
        Icons.medical_services_outlined,
        size: 120,
        color: data.accentColor,
      ),
    );
  }
}

class _OnboardingData {
  final String? image;
  final String? imageUrl;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color accentColor;

  _OnboardingData({
    this.image,
    this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.accentColor,
  });
}
