import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:health_sphere/core/theme/app_colors.dart';

class DoctorsScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const DoctorsScreen({super.key, this.onBack});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  int _selectedCategory = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _showDropdown = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allDoctors = [];

  final List<String> _categories = [
    'All',
    'Cardiologist',
    'Neurologist',
    'Pediatrician',
    'Dermatologist',
    'General Physician',
  ];

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
  }

  String get _baseUrl {
    if (kIsWeb) return 'http://localhost:8000';
    if (Platform.isAndroid) return 'http://192.168.101.5:8000';
    return 'http://127.0.0.1:8000';
  }

  Future<void> _fetchDoctors() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/doctors/'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _allDoctors = data.map((e) => e as Map<String, dynamic>).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Fallback to mock data if server fails
        _allDoctors = [
          {'name': 'Dr. Sarah Mitchell', 'specialty': 'Cardiologist', 'rating': 4.9, 'reviews': 120, 'available': true},
          {'name': 'Dr. James Wilson', 'specialty': 'Neurologist', 'rating': 4.8, 'reviews': 85, 'available': true},
        ];
      }
    }
  }

  List<Map<String, dynamic>> get _filteredDoctors {
    final category = _categories[_selectedCategory];
    return _allDoctors.where((doc) {
      final matchCat = category == 'All' || doc['specialty'] == category;
      final matchSearch = _searchQuery.isEmpty ||
          (doc['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (doc['specialty'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await _fetchDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_showDropdown) setState(() => _showDropdown = false);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // ── Header ─────────────────────────────────────────────────
                  _buildHeader(context),

                  // ── Search ─────────────────────────────────────────────────
                  _buildSearch(),

                  // ── Doctor List (Full Width) ──────────────────────────────
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      child: _buildDoctorList(),
                    ),
                  ),
                ],
              ),

              // ── Dropdown Specialities Menu ────────────────────────────────
              if (_showDropdown) _buildDropdownMenu(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      color: Colors.white,
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (canPop) {
                Navigator.of(context).pop();
              } else {
                widget.onBack?.call();
              }
            },
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMain),
            ),
          ),
          const SizedBox(width: 12),
          const Text('Doctors', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const Spacer(),
          // Selected Category Badge Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(12)),
            child: Text(
              _categories[_selectedCategory],
              style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search ─────────────────────────────────────────────────────────────────
  Widget _buildSearch() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 14, color: AppColors.textMain),
                decoration: InputDecoration(
                  hintText: 'Search Doctors…',
                  hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() => _showDropdown = !_showDropdown);
              },
              child: Container(
                margin: const EdgeInsets.all(6),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _showDropdown ? AppColors.primaryDark : AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _showDropdown ? Icons.close_rounded : Icons.tune_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Doctor List ─────────────────────────────────────────────────────────────
  Widget _buildDoctorList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final docs = _filteredDoctors;
    if (docs.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.25),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.search_off_rounded, size: 48, color: AppColors.textSecondary),
                const SizedBox(height: 10),
                Text('No doctors found', style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 14)),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _DoctorCard(doc: docs[i]),
    );
  }

  // ── Dropdown Specialities Menu ──────────────────────────────────────────────
  Widget _buildDropdownMenu() {
    return Positioned(
      top: 114, // Fits directly below the search bar container
      right: 16,
      child: Material(
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 240,
          height: 380,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border(
              right: BorderSide(color: AppColors.primary, width: 4), // Blue indicator line like screenshot
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFF2F4F7))),
                ),
                child: const Text(
                  'Select Speciality',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final selected = _selectedCategory == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategory = index;
                          _showDropdown = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        color: selected ? AppColors.primarySoft.withValues(alpha: 0.5) : Colors.transparent,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _categories[index],
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                                color: selected ? AppColors.primary : AppColors.textMain,
                              ),
                            ),
                            if (selected)
                              const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Doctor Card ───────────────────────────────────────────────────────────────
class _DoctorCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  const _DoctorCard({required this.doc});

  @override
  Widget build(BuildContext context) {
    final bool available = doc['available'] as bool;
    final double rating = (doc['rating'] as num).toDouble();
    final int reviews = doc['reviews'] as int;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Avatar
                Stack(
                  children: [
                    ClipOval(
                      child: (doc['avatar_url'] != null && (doc['avatar_url'] as String).isNotEmpty)
                          ? Image.network(
                              doc['avatar_url'] as String,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildAvatarFallback(),
                            )
                          : _buildAvatarFallback(),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: available ? AppColors.success : Colors.grey,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textMain),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(doc['specialty'] as String, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < rating.floor()
                                  ? Icons.star_rounded
                                  : (i < rating ? Icons.star_half_rounded : Icons.star_outline_rounded),
                              color: Colors.amber,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text('$reviews reviews', style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),
                // Book button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.primaryLight, AppColors.primary]),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Book', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarFallback() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
      child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
    );
  }
}
