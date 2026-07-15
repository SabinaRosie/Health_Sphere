import 'package:flutter/material.dart';
import 'package:health_sphere/core/theme/app_colors.dart';

class NotificationModel {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  bool isRead;

  NotificationModel({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.iconBgColor = AppColors.primarySoft,
    this.isRead = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  // Global static list of notifications
  static final List<NotificationModel> notifications = [
    NotificationModel(
      title: 'Appointment Scheduled Successfully',
      message: 'Your appointment with Dr. Michelle Carter is confirmed for Today at 9:30 am.',
      time: '1 hour ago',
      icon: Icons.check_circle_outline_rounded,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.primarySoft,
      isRead: false,
    ),
    NotificationModel(
      title: 'Welcome to HealthSphere!',
      message: 'Your health journey starts here. Explore our features and book consultations easily.',
      time: '2 hours ago',
      icon: Icons.favorite_rounded,
      iconColor: const Color(0xFFF98E8E),
      iconBgColor: const Color(0xFFFFECEC),
      isRead: false,
    ),
  ];

  /// Returns true if there are any unread notifications
  static bool get hasUnread => notifications.any((n) => !n.isRead);

  /// Mark all as read
  static void markAllRead() {
    for (final n in notifications) {
      n.isRead = true;
    }
  }

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    // Mark all notifications as read when screen opens
    NotificationScreen.markAllRead();
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: AppColors.textMain),
              ),
            ),
          ),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.textMain,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: AppColors.primary,
        backgroundColor: Colors.white,
        child: NotificationScreen.notifications.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: AppColors.primarySoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_off_outlined,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No Notifications Yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We will notify you when there is an update.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: NotificationScreen.notifications.length,
                itemBuilder: (context, index) {
                  final notif = NotificationScreen.notifications[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        notif.isRead = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : AppColors.primarySoft.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(16),
                        border: notif.isRead
                            ? null
                            : Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: notif.iconBgColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              notif.icon,
                              color: notif.iconColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.bold,
                                          color: AppColors.textMain,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(left: 8, top: 3),
                                        decoration: const BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: PopupMenuButton<String>(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textSecondary),
                                        onSelected: (value) {
                                          if (value == 'remove') {
                                            setState(() {
                                              NotificationScreen.notifications.removeAt(index);
                                            });
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: 'remove',
                                            height: 36,
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent),
                                                SizedBox(width: 8),
                                                Text('Remove', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notif.message,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  notif.time,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary.withValues(alpha: 0.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
