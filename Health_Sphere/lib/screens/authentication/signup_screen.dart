import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/screens/authentication/login_screen.dart';
import 'package:health_sphere/screens/main_wrapper.dart';
import 'package:health_sphere/utils/validators.dart';
import 'package:health_sphere/widgets/google_icon.dart';
import 'package:health_sphere/widgets/loading_overlay.dart';
import 'package:health_sphere/widgets/validation_helper.dart';


class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Validation checking states
  bool _emailTouched = false;
  bool _passwordTouched = false;
  bool _isEmailValid = false;
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasDigits = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    // Setup validation listeners
    _emailFocus.addListener(() {
      setState(() {
        if (!_emailFocus.hasFocus) {
          _emailTouched = true;
        }
      });
    });
    _passwordFocus.addListener(() {
      setState(() {
        if (!_passwordFocus.hasFocus) {
          _passwordTouched = true;
        }
      });
    });
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
  }

  void _validateEmail() {
    final text = _emailController.text.trim();
    setState(() {
      _isEmailValid = RegExp(
        r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(text);
    });
  }

  void _validatePassword() {
    final text = _passwordController.text;
    setState(() {
      _hasMinLength = text.length >= 8;
      _hasUppercase = text.contains(RegExp(r'[A-Z]'));
      _hasLowercase = text.contains(RegExp(r'[a-z]'));
      _hasDigits = text.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = text.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]'));
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else if (Platform.isAndroid) {
      // Use your PC's LAN IP for physical device testing
      return 'http://192.168.101.5:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  Future<void> _signup() async {
    setState(() {
      _emailTouched = true;
      _passwordTouched = true;
    });
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to Terms & Privacy Policy');
      return;
    }
    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/register/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text.trim(),
          'password': _passwordController.text,
          'full_name': _nameController.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201) {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainWrapper()),
            (_) => false,
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['email']?[0] ??
            errorData['password']?[0] ??
            errorData['full_name']?[0] ??
            errorData['message'] ??
            'Failed to create account.';
        if (mounted) {
          setState(() => _isLoading = false);
          _showErrorSnackBar(errorMessage);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        if (e.toString().contains('TimeoutException')) {
          _showErrorSnackBar('Request timed out. Check your connection.');
        } else {
          _showErrorSnackBar('Cannot reach server. Is it running?');
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top teal arc decoration
          Positioned(
            top: -80,
            left: -60,
            right: -60,
            child: Container(
              height: 240,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF86E3CE), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(120),
                  bottomRight: Radius.circular(120),
                ),
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // App Icon — oversized image inside clipped container
                        // to crop out the built-in whitespace and text in the asset
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 0),
                              child: FittedBox(
                                fit: BoxFit.cover,
                                clipBehavior: Clip.hardEdge,
                                child: SizedBox(
                                  width: 200,
                                  height: 180,
                                  child: Image.asset(
                                    'assets/icon.png',
                                    fit: BoxFit.contain,
                                    alignment: const Alignment(0, -0.3),
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.health_and_safety_rounded,
                                      size: 55,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        const Text(
                          'Health Sphere',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 36),

                        // Card
                        Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Create Account ✨',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textMain,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Join us and take control of your health',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 26),

                                // Full Name
                                _buildLabel('Full Name'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _nameController,
                                  hint: 'John Doe',
                                  prefixIcon: Icons.person_outline_rounded,
                                  validator: AppValidators.name,
                                ),
                                const SizedBox(height: 18),

                                // Email
                                _buildLabel('Email Address'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _emailController,
                                  focusNode: _emailFocus,
                                  hint: 'you@example.com',
                                  prefixIcon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: AppValidators.email,
                                ),
                                if ((_emailTouched || _emailFocus.hasFocus) &&
                                    _emailController.text.isNotEmpty &&
                                    !_isEmailValid)
                                  ValidationHelper(
                                    title: 'Email Requirements:',
                                    requirements: [
                                      ValidationRequirementItem(
                                        text: 'Must be a valid email format',
                                        isMet: _isEmailValid,
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 18),

                                // Password
                                _buildLabel('Password'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _passwordController,
                                  focusNode: _passwordFocus,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscurePassword,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                  ),
                                  validator: AppValidators.password,
                                ),
                                if ((_passwordTouched || _passwordFocus.hasFocus) &&
                                    _passwordController.text.isNotEmpty &&
                                    !(_hasMinLength && _hasUppercase && _hasLowercase && _hasDigits && _hasSpecialChar))
                                  ValidationHelper(
                                    title: 'Password Requirements:',
                                    requirements: [
                                      ValidationRequirementItem(
                                        text: 'At least 8 characters',
                                        isMet: _hasMinLength,
                                      ),
                                      ValidationRequirementItem(
                                        text: 'At least one uppercase letter (A-Z)',
                                        isMet: _hasUppercase,
                                      ),
                                      ValidationRequirementItem(
                                        text: 'At least one lowercase letter (a-z)',
                                        isMet: _hasLowercase,
                                      ),
                                      ValidationRequirementItem(
                                        text: 'At least one number (0-9)',
                                        isMet: _hasDigits,
                                      ),
                                      ValidationRequirementItem(
                                        text: 'At least one special character (!@#\$ etc.)',
                                        isMet: _hasSpecialChar,
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 18),

                                // Confirm Password
                                _buildLabel('Confirm Password'),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  hint: '••••••••',
                                  prefixIcon: Icons.lock_outline_rounded,
                                  obscureText: _obscureConfirm,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscureConfirm
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onPressed: () => setState(
                                        () => _obscureConfirm = !_obscureConfirm),
                                  ),
                                  validator: AppValidators.confirmPassword(
                                    _passwordController.text,
                                  ),

                                ),
                                const SizedBox(height: 18),

                                // Terms Checkbox
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _agreeToTerms,
                                        onChanged: (v) => setState(
                                            () => _agreeToTerms = v ?? false),
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        side: BorderSide(
                                            color: Colors.grey.shade300,
                                            width: 1.5),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: RichText(
                                        text: TextSpan(
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: AppColors.textSecondary,
                                          ),
                                          children: [
                                            const TextSpan(text: 'I agree to the '),
                                            TextSpan(
                                              text: 'Terms of Service',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const TextSpan(text: ' and '),
                                            TextSpan(
                                              text: 'Privacy Policy',
                                              style: const TextStyle(
                                                color: AppColors.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 26),

                                // Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signup,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey.shade200,
                                            thickness: 1)),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Divider(
                                            color: Colors.grey.shade200,
                                            thickness: 1)),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Google Sign Up
                                SizedBox(
                                  width: double.infinity,
                                  height: 54,
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                          color: Colors.grey.shade200,
                                          width: 1.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    icon: const GoogleIcon(size: 22),
                                    label: const Text(
                                      'Sign up with Google',
                                      style: TextStyle(
                                        color: AppColors.textMain,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData prefixIcon,
    FocusNode? focusNode,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: autovalidateMode,
      style: const TextStyle(fontSize: 15, color: AppColors.textMain),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            TextStyle(color: AppColors.textSecondary.withOpacity(0.5), fontSize: 14),
        prefixIcon:
            Icon(prefixIcon, color: AppColors.textSecondary, size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade300, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
        ),
      ),
    );
  }
}
