import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';

class BlogScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const BlogScreen({super.key, this.onBack});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final List<String> _tabs = ['All Tips', 'Nutrition', 'Mental Health', 'Fitness', 'Sleep'];

  final List<Map<String, dynamic>> _articles = [
    {
      'title': 'The Power of Staying Hydrated',
      'category': 'Nutrition',
      'readTime': '3 min read',
      'icon': Icons.water_drop_rounded,
      'color': Color(0xFF25B4AE),
      'image': 'https://images.unsplash.com/photo-1548839130-3fd96157f5f6?w=400&auto=format&fit=crop',
      'intro': 'Water is essential for every single cell in your body. Discover how proper hydration transforms your health.',
      'content': 'Drinking enough water daily is crucial for many reasons: to regulate body temperature, keep joints lubricated, prevent infections, deliver nutrients to cells, and keep organs functioning properly. Being well-hydrated also improves sleep quality, cognition, and mood.\n\nNutritionists recommend drinking at least 8-10 glasses of water daily. You can also stay hydrated by eating foods with high water content, such as cucumbers, watermelon, and tomatoes.',
      'tips': ['Drink a glass of water right after waking up.', 'Carry a reusable water bottle everywhere.', 'Set hourly reminders on your phone.']
    },
    {
      'title': 'Mindfulness & Stress Reduction',
      'category': 'Mental Health',
      'readTime': '5 min read',
      'icon': Icons.psychology_rounded,
      'color': Color(0xFF7C83FD),
      'image': 'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&auto=format&fit=crop',
      'intro': 'Learn simple techniques to calm your mind, reduce daily anxiety, and improve focus.',
      'content': 'Mindfulness is the practice of purposely focusing your attention on the present moment—and accepting it without judgment. It is now being examined scientifically and has been found to be a key element in stress reduction and overall happiness.\n\nPracticing mindfulness can help improve physical health in down-to-earth ways: alleviate stress, treat heart disease, lower blood pressure, reduce chronic pain, and improve sleep.',
      'tips': ['Start with 5 minutes of quiet breathing.', 'Practice mindful eating by chewing slowly.', 'Take a screen-free walk in nature.']
    },
    {
      'title': '10-Minute Morning Cardio Boost',
      'category': 'Fitness',
      'readTime': '4 min read',
      'icon': Icons.directions_run_rounded,
      'color': Color(0xFFFF7B54),
      'image': 'https://images.unsplash.com/photo-1476480862126-209bfaa8edc8?w=400&auto=format&fit=crop',
      'intro': 'No time for the gym? This quick morning workout will kickstart your metabolism and boost energy.',
      'content': 'Physical activity doesn’t have to take hours to be effective. A short, high-intensity cardio blast in the morning increases blood flow, releases endorphins, and sets a positive tone for the rest of your day.\n\nThis routine requires zero equipment and can be done right in your living room. It combines jumping jacks, high knees, squats, and lunges to target all major muscle groups.',
      'tips': ['Do each exercise for 45 seconds, then rest 15 seconds.', 'Warm up for 1 minute before starting.', 'Stay consistent: do it 3 times a week.']
    },
    {
      'title': 'Building a Perfect Sleep Routine',
      'category': 'Sleep',
      'readTime': '6 min read',
      'icon': Icons.bedtime_rounded,
      'color': Color(0xFFF5A623),
      'image': 'https://images.unsplash.com/photo-1511295742364-92767fa62d9f?w=400&auto=format&fit=crop',
      'intro': 'Struggling to fall asleep? Learn how to optimize your bedroom and mind for deep, restorative rest.',
      'content': 'Quality sleep is just as important as diet and exercise. Poor sleep has immediate negative effects on your hormones, exercise performance, and brain function.\n\nTo build a perfect sleep hygiene, try to regulate your circadian rhythm by going to bed and waking up at the same time every day. Minimize bright blue light exposure from screens at least 1 hour before sleep.',
      'tips': ['Keep your room cool, dark, and quiet.', 'Avoid caffeine after 2 PM.', 'Read a physical book or write in a journal before bed.']
    },
    {
      'title': 'The Importance of Micronutrients',
      'category': 'Nutrition',
      'readTime': '4 min read',
      'icon': Icons.restaurant_menu_rounded,
      'color': Color(0xFF4CAF50),
      'image': 'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&auto=format&fit=crop',
      'intro': 'Vitamins and minerals play a vital role in disease prevention and overall wellbeing.',
      'content': 'Micronutrients, which include vitamins and minerals, are required in small amounts but are essential for health. They play a crucial role in energy production, immune function, blood clotting, and bone health.\n\nA balanced diet rich in vegetables, fruits, whole grains, and lean proteins is the best way to obtain these essential nutrients naturally.',
      'tips': ['Eat a colorful plate with varied veggies.', 'Consider vitamin D supplements in winter.', 'Limit highly processed foods.']
    }
  ];

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {});
    }
  }

  List<Map<String, dynamic>> _getArticlesForCategory(String category) {
    if (category == 'All Tips') return _articles;
    return _articles.where((a) => a['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 62,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    widget.onBack?.call();
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
          title: const Text(
            'Health Blog & Tips',
            style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold, fontSize: 20),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary.withValues(alpha: 0.7),
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          ),
        ),
        body: TabBarView(
          children: _tabs.map((tab) => _buildTabContent(tab)).toList(),
        ),
      ),
    );
  }

  Widget _buildTabContent(String category) {
    final filtered = _getArticlesForCategory(category);
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: filtered.isEmpty
          ? const Center(child: Text('No articles in this category.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final article = filtered[index];
                return _buildArticleCard(context, article);
              },
            ),
    );
  }

  Widget _buildArticleCard(BuildContext context, Map<String, dynamic> article) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlogDetailScreen(article: article),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.network(
                      article['image'] as String,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 150,
                        color: (article['color'] as Color).withValues(alpha: 0.1),
                        child: Icon(article['icon'] as IconData, size: 50, color: article['color'] as Color),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: (article['color'] as Color),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article['category'] as String,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                          const SizedBox(width: 4),
                          Text(
                            article['readTime'] as String,
                            style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article['title'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article['intro'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class BlogDetailScreen extends StatelessWidget {
  final Map<String, dynamic> article;
  const BlogDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final themeColor = article['color'] as Color;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: themeColor,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMain),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    article['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(color: themeColor.withValues(alpha: 0.2)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & read time
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: themeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          article['category'] as String,
                          style: TextStyle(color: themeColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time_rounded, size: 14, color: AppColors.textSecondary.withValues(alpha: 0.7)),
                      const SizedBox(width: 4),
                      Text(
                        article['readTime'] as String,
                        style: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.7), fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Title
                  Text(
                    article['title'] as String,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Clipart/Illustration card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [themeColor.withValues(alpha: 0.15), themeColor.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: themeColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(article['icon'] as IconData, size: 36, color: themeColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Health Sphere Advice',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: themeColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Daily wellness guidance verified by certified experts.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Content
                  Text(
                    article['content'] as String,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMain,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Actionable tips
                  const Text(
                    'Key Actionable Tips:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    (article['tips'] as List<String>).length,
                    (i) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: themeColor,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              (article['tips'] as List<String>)[i],
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textMain,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
