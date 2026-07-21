import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildAdminActions(),
              const SizedBox(height: 24),
              _buildSectionTitle('Recent Activity'),
              const SizedBox(height: 16),
              _buildActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'System Admin',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        Text(
          'Platform Overview',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textMain),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildSimpleStat('Users', '5.2k', Icons.people, Colors.teal)),
        const SizedBox(width: 16),
        Expanded(child: _buildSimpleStat('Revenue', '\$12k', Icons.attach_money, Colors.green)),
        const SizedBox(width: 16),
        Expanded(child: _buildSimpleStat('Alerts', '3', Icons.notifications_active, Colors.red)),
      ],
    );
  }

  Widget _buildSimpleStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildAdminActions() {
    return Column(
      children: [
        _buildActionTile('Manage Doctors', 'Verify and update doctor profiles', Icons.medical_services, Colors.blue),
        const SizedBox(height: 12),
        _buildActionTile('User Permissions', 'Configure access control levels', Icons.security, Colors.orange),
        const SizedBox(height: 12),
        _buildActionTile('System Logs', 'Review application event logs', Icons.list_alt, Colors.grey),
      ],
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain),
    );
  }

  Widget _buildActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(radius: 4, backgroundColor: AppColors.primary),
          title: Text('System Update #$index', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: const Text('2 hours ago', style: TextStyle(fontSize: 12)),
          trailing: const Icon(Icons.more_vert, size: 18),
        );
      },
    );
  }
}
