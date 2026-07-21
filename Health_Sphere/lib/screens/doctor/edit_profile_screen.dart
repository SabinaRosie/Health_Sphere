import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/widgets/loading_overlay.dart';

class EditDoctorProfileScreen extends StatefulWidget {
  const EditDoctorProfileScreen({super.key});

  @override
  State<EditDoctorProfileScreen> createState() => _EditDoctorProfileScreenState();
}

class _EditDoctorProfileScreenState extends State<EditDoctorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarUrlController = TextEditingController();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://192.168.101.5:8000';
    return 'http://127.0.0.1:8000';
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');
    if (email == null) return;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/doctor-profile/?email=$email'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _specialtyController.text = data['specialty'] ?? '';
          _experienceController.text = data['experience'] ?? '';
          _bioController.text = data['bio'] ?? '';
          _locationController.text = data['location'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _avatarUrlController.text = data['avatar_url'] ?? '';
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users/doctor-profile/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'specialty': _specialtyController.text,
          'experience': _experienceController.text,
          'bio': _bioController.text,
          'location': _locationController.text,
          'phone': _phoneController.text,
          'avatar_url': _avatarUrlController.text,
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Edit Doctor Profile', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textMain),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildField('Specialty', _specialtyController, 'e.g. Cardiologist', Icons.medical_services_outlined),
                const SizedBox(height: 20),
                _buildField('Experience', _experienceController, 'e.g. 10 years', Icons.history_edu),
                const SizedBox(height: 20),
                _buildField('Phone Number', _phoneController, 'e.g. +1 234 567 890', Icons.phone_outlined, keyboardType: TextInputType.phone),
                const SizedBox(height: 20),
                _buildField('Location', _locationController, 'e.g. City Medical Center', Icons.location_on_outlined),
                const SizedBox(height: 20),
                _buildField('Avatar URL', _avatarUrlController, 'Link to your profile picture', Icons.image_outlined),
                const SizedBox(height: 20),
                _buildField('Biography', _bioController, 'Tell patients about yourself...', Icons.description_outlined, maxLines: 4),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Save Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, IconData icon, {int maxLines = 1, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'This field is required' : null,
        ),
      ],
    );
  }
}
