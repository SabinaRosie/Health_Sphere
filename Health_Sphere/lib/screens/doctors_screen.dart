import 'package:flutter/material.dart';
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

  final List<String> _categories = [
    'All',
    'Child Healthcare',
    'Female Healthcare',
    'Sexologist',
    'Mental Healthcare',
    'Mental Health Therapy',
    'ENT Care',
    'O.P.D',
    'Skin Healthcare',
    'Pulmonary Healthcare',
    'Cardiology',
    'Neurologist',
    'Geriatrician',
    'Oncology',
    'General Physician',
    'Urology',
    'Endocrinology',
    'Orthopedic',
    'Pediatrics',
    'Dermatology',
  ];

  final List<Map<String, dynamic>> _allDoctors = [
    {'name': 'Dr. Sarah Mills', 'specialty': 'Cardiologist', 'category': 'Cardiology', 'rating': 4.9, 'reviews': 128, 'image': 'https://images.unsplash.com/photo-1594824476967-48c8b964273f?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. James Chen', 'specialty': 'Neurologist', 'category': 'Neurologist', 'rating': 4.8, 'reviews': 96, 'image': 'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Priya Rao', 'specialty': 'Pediatrician', 'category': 'Pediatrics', 'rating': 4.9, 'reviews': 214, 'image': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&auto=format&fit=crop', 'available': false},
    {'name': 'Dr. Alan Ford', 'specialty': 'Orthopedic Surgeon', 'category': 'Orthopedic', 'rating': 4.7, 'reviews': 87, 'image': 'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Maria Lopez', 'specialty': 'Dermatologist', 'category': 'Dermatology', 'rating': 4.8, 'reviews': 153, 'image': 'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Rajan Shrestha', 'specialty': 'ENT Specialist', 'category': 'ENT Care', 'rating': 4.6, 'reviews': 62, 'image': 'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Anita Karki', 'specialty': 'Gynecologist', 'category': 'Female Healthcare', 'rating': 4.9, 'reviews': 178, 'image': 'https://images.unsplash.com/photo-1651008376811-b90baee60c1f?w=200&auto=format&fit=crop', 'available': false},
    {'name': 'Dr. Kevin Patel', 'specialty': 'General Physician', 'category': 'General Physician', 'rating': 4.5, 'reviews': 201, 'image': 'https://images.unsplash.com/photo-1612531385446-f7e6d131e1d0?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Sita Thapa', 'specialty': 'Psychiatrist', 'category': 'Mental Healthcare', 'rating': 4.7, 'reviews': 110, 'image': 'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Bikash Adhikari', 'specialty': 'Pulmonologist', 'category': 'Pulmonary Healthcare', 'rating': 4.6, 'reviews': 74, 'image': 'https://images.unsplash.com/photo-1559757148-5c350d0d3c56?w=200&auto=format&fit=crop', 'available': false},
    {'name': 'Dr. Meena Gurung', 'specialty': 'Pediatrician', 'category': 'Child Healthcare', 'rating': 4.9, 'reviews': 192, 'image': 'https://images.unsplash.com/photo-1527613426441-4da17471b66d?w=200&auto=format&fit=crop', 'available': true},
    {'name': 'Dr. Rohan Joshi', 'specialty': 'Oncologist', 'category': 'Oncology', 'rating': 4.8, 'reviews': 89, 'image': 'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=200&auto=format&fit=crop', 'available': true},
  ];

  List<Map<String, dynamic>> get _filteredDoctors {
    final category = _categories[_selectedCategory];
    return _allDoctors.where((doc) {
      final matchCat = category == 'All' || doc['category'] == category;
      final matchSearch = _searchQuery.isEmpty ||
          (doc['name'] as String).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (doc['specialty'] as String).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
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
                      child: Image.network(
                        doc['image'] as String,
                        width: 60, height: 60, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60, height: 60,
                          decoration: const BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                          child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                        ),
                      ),
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
}
