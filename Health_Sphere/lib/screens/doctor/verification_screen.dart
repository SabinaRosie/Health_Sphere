import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:health_sphere/core/theme/app_colors.dart';
import 'package:health_sphere/widgets/loading_overlay.dart';

class DoctorVerificationScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const DoctorVerificationScreen({super.key, required this.onComplete});

  @override
  State<DoctorVerificationScreen> createState() => _DoctorVerificationScreenState();
}

class _DoctorVerificationScreenState extends State<DoctorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  final _qualificationController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _experienceController = TextEditingController();
  final _bioController = TextEditingController();

  File? _citizenshipImage;
  File? _licenseImage;
  File? _recommendationImage;

  final ImagePicker _picker = ImagePicker();

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://192.168.101.5:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<void> _pickImage(String type) async {
    final status = await Permission.photos.request();
    if (status.isGranted || Platform.isAndroid) { // Android usually handles this via picker
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (type == 'citizenship') _citizenshipImage = File(image.path);
          if (type == 'license') _licenseImage = File(image.path);
          if (type == 'recommendation') _recommendationImage = File(image.path);
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) return;
    if (_citizenshipImage == null || _licenseImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload required documents')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('user_email');

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/users/doctor-profile/'),
      );

      request.fields['email'] = email ?? '';
      request.fields['qualification'] = _qualificationController.text;
      request.fields['specialty'] = _specialtyController.text;
      request.fields['experience'] = _experienceController.text;
      request.fields['bio'] = _bioController.text;

      request.files.add(await http.MultipartFile.fromPath('citizenship_card', _citizenshipImage!.path));
      request.files.add(await http.MultipartFile.fromPath('medical_license', _licenseImage!.path));
      if (_recommendationImage != null) {
        request.files.add(await http.MultipartFile.fromPath('recommendation_letter', _recommendationImage!.path));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        widget.onComplete();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit application')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Complete Your Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(height: 8),
                  const Text('Please provide your professional details and upload documents for verification.', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 32),
                  
                  _buildField('Qualification', _qualificationController, 'e.g. MBBS, MD', Icons.school_outlined),
                  const SizedBox(height: 20),
                  _buildField('Specialty', _specialtyController, 'e.g. Cardiologist', Icons.medical_services_outlined),
                  const SizedBox(height: 20),
                  _buildField('Experience', _experienceController, 'e.g. 8 years', Icons.history_edu),
                  const SizedBox(height: 20),
                  _buildField('Biography', _bioController, 'Brief about your practice...', Icons.description_outlined, maxLines: 3),
                  
                  const SizedBox(height: 32),
                  const Text('Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  
                  _buildUploadTile('Citizenship Card (Required)', _citizenshipImage, () => _pickImage('citizenship')),
                  const SizedBox(height: 12),
                  _buildUploadTile('Medical License (Required)', _licenseImage, () => _pickImage('license')),
                  const SizedBox(height: 12),
                  _buildUploadTile('Recommendation Letter', _recommendationImage, () => _pickImage('recommendation')),
                  
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitApplication,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Apply for Certification', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            filled: true,
            fillColor: AppColors.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v == null || v.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _buildUploadTile(String label, File? image, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(12),
          color: image != null ? AppColors.primary.withOpacity(0.05) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(image != null ? Icons.check_circle : Icons.upload_file, color: image != null ? Colors.green : AppColors.primary),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: image != null ? Colors.green : AppColors.textMain))),
            if (image != null) const Icon(Icons.edit, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
