import 'package:flutter/material.dart';
import '../../core/services/emergency_duty_notification_service.dart';
import '../../core/theme/app_colors.dart';
import '../duties/discovery_helpers.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  final List<Map<String, dynamic>> _allNotifications = [
    {
      'id': '1',
      'category': 'duties',
      'icon': Icons.medical_services_rounded,
      'iconColor': AppColors.accent,
      'title': 'Duty Approved',
      'description':
          'Apollo Hospital approved your application for ICU Specialist duty.',
      'time': '2 min ago',
      'isRead': false,
      'navigationType': 'duty_details',
      'dutyId': 'duty_123',
    },
    {
      'id': '2',
      'category': 'duties',
      'icon': Icons.work_history_rounded,
      'iconColor': AppColors.success,
      'title': 'New Duty Posted',
      'description': 'Fortis Hospital posted a new Emergency duty. ₹6500/day.',
      'time': '15 min ago',
      'isRead': false,
      'navigationType': 'duty_details',
      'dutyId': 'duty_456',
    },
    {
      'id': '3',
      'category': 'jobs',
      'icon': Icons.work_rounded,
      'iconColor': AppColors.info,
      'title': 'New Job Recommendation',
      'description':
          'Senior Cardiologist position available at AIIMS Delhi. ₹25L/year.',
      'time': '30 min ago',
      'isRead': false,
      'navigationType': 'job_details',
      'jobId': 'job_789',
    },
    {
      'id': '4',
      'category': 'jobs',
      'icon': Icons.send_rounded,
      'iconColor': AppColors.success,
      'title': 'Job Application Submitted',
      'description':
          'Your application for Resident Medical Officer at Max Hospital has been submitted.',
      'time': '1 hr ago',
      'isRead': true,
      'navigationType': 'job_details',
      'jobId': 'job_101',
    },
    {
      'id': '5',
      'category': 'messages',
      'icon': Icons.chat_bubble_rounded,
      'iconColor': AppColors.info,
      'title': 'New Message',
      'description':
          'Dr. Priya Sharma sent you a message regarding your application.',
      'time': '1 hr ago',
      'isRead': true,
      'navigationType': 'chat',
      'userId': 'user_456',
    },
    {
      'id': '6',
      'category': 'messages',
      'icon': Icons.phone_rounded,
      'iconColor': AppColors.warning,
      'title': 'Missed Call',
      'description':
          'Dr. Rajesh Kumar tried to call you. Call back to discuss the duty opportunity.',
      'time': '2 hr ago',
      'isRead': true,
      'navigationType': 'chat',
      'userId': 'user_789',
    },
    {
      'id': '7',
      'category': 'community',
      'icon': Icons.groups_rounded,
      'iconColor': AppColors.warning,
      'title': 'Post Liked',
      'description':
          '128 doctors liked your recent post about Advanced Dermatosurgery.',
      'time': '2 hr ago',
      'isRead': true,
      'navigationType': 'community_post',
      'postId': 'post_123',
    },
    {
      'id': '8',
      'category': 'community',
      'icon': Icons.person_add_rounded,
      'iconColor': AppColors.accent,
      'title': 'New Follower',
      'description':
          'Dr. Ankit Mehta started following you. View their profile.',
      'time': '3 hr ago',
      'isRead': true,
      'navigationType': 'profile',
      'userId': 'user_321',
    },
    {
      'id': '9',
      'category': 'system',
      'icon': Icons.verified_rounded,
      'iconColor': AppColors.accent,
      'title': 'Profile Verified',
      'description':
          'Your medical registration has been verified successfully.',
      'time': '1 day ago',
      'isRead': true,
    },
    {
      'id': '10',
      'category': 'duties',
      'icon': Icons.schedule_rounded,
      'iconColor': AppColors.warning,
      'title': 'Duty Reminder',
      'description': 'Your duty at Max Hospital starts tomorrow at 9:00 AM.',
      'time': '3 hr ago',
      'isRead': false,
      'navigationType': 'duty_details',
      'dutyId': 'duty_789',
    },
    {
      'id': '11',
      'category': 'duties',
      'icon': Icons.cancel_rounded,
      'iconColor': AppColors.error,
      'title': 'Application Rejected',
      'description':
          'Your application for Night Duty at Apollo Hospital was not selected.',
      'time': '5 hr ago',
      'isRead': true,
      'navigationType': 'duty_details',
      'dutyId': 'duty_234',
    },
    {
      'id': '12',
      'category': 'system',
      'icon': Icons.payment_rounded,
      'iconColor': AppColors.success,
      'title': 'Payment Received',
      'description':
          '₹7,000 has been credited to your account for completed duty.',
      'time': '2 days ago',
      'isRead': true,
    },
    {
      'id': '13',
      'category': 'community',
      'icon': Icons.comment_rounded,
      'iconColor': AppColors.info,
      'title': 'New Comment',
      'description':
          'Dr. Sunita Reddy commented on your post: "Great insights!"',
      'time': '3 days ago',
      'isRead': true,
      'navigationType': 'community_post',
      'postId': 'post_456',
    },
  ];

  late List<Map<String, dynamic>> _items;

  final List<String> _tabCategories = [
    'all',
    'duties',
    'messages',
    'community',
    'applications',
  ];
  final List<String> _tabLabels = [
    'All',
    'Duties',
    'Messages',
    'Community',
    'Applications',
  ];

  @override
  void initState() {
    super.initState();
    _items = List.from(_allNotifications);
    for (final n in EmergencyDutyNotificationService.instance.notifications) {
      _items.insert(0, {
        'id': n.id,
        'category': 'duties',
        'icon': Icons.emergency_rounded,
        'iconColor': const Color(0xFFDC2626),
        'title': n.title,
        'description': n.body,
        'time': 'Just now',
        'isRead': false,
        'dutyId': n.dutyId,
        'isEmergency': true,
      });
    }
    _tabController = TabController(length: _tabCategories.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _tabIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredItems() {
    final cat = _tabCategories[_tabIndex];
    if (cat == 'all') return _items;
    if (cat == 'applications') {
      return _items.where((n) {
        final c = n['category'] as String? ?? '';
        return c == 'jobs' || c == 'applications';
      }).toList();
    }
    return _items.where((n) => n['category'] == cat).toList();
  }

  int _unreadCountFor(String category) {
    final List<Map<String, dynamic>> source;
    if (category == 'all') {
      source = _items;
    } else if (category == 'applications') {
      source = _items.where((n) {
        final c = n['category'] as String? ?? '';
        return c == 'jobs' || c == 'applications';
      }).toList();
    } else {
      source = _items.where((n) => n['category'] == category).toList();
    }
    return source.where((n) => n['isRead'] == false).length;
  }

  void _markAllRead() {
    setState(() {
      for (final item in _items) {
        item['isRead'] = true;
      }
    });
  }

  void _markAsRead(String id) {
    setState(() {
      final idx = _items.indexWhere((n) => n['id'] == id);
      if (idx != -1) {
        _items[idx] = Map.from(_items[idx])..['isRead'] = true;
      }
    });
  }

  void _deleteItem(String id) {
    setState(() {
      _items.removeWhere((n) => n['id'] == id);
    });
  }

  void _handleNotificationTap(Map<String, dynamic> item) {
    final navigationType = item['navigationType'] as String?;

    if (navigationType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item['title']} marked as read'),
          duration: const Duration(seconds: 1),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    switch (navigationType) {
      case 'duty_details':
        final dutyId = item['dutyId'] as String?;
        if (dutyId != null) {
          openDutyDetailsById(context, dutyId);
        }
        break;
      case 'job_details':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Job details navigation coming soon'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'chat':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Opening chat...'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'community_post':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Opening post...'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'profile':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Opening profile...'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item['title']} marked as read'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final filtered = _filteredItems();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.arrow_back_rounded,
                              color: textColor,
                              size: 26,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _markAllRead,
                            icon: Icon(
                              Icons.settings_outlined,
                              color: textColor,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 44,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _tabLabels.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, i) {
                          final selected = _tabIndex == i;
                          final unread = _unreadCountFor(_tabCategories[i]);
                          return GestureDetector(
                            onTap: () {
                              _tabController.animateTo(i);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? (isDark
                                          ? AppColors.darkText
                                          : AppColors.lightText)
                                    : (isDark
                                          ? const Color(0xFF1E293B)
                                          : const Color(0xFFEEF2F7)),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _tabLabels[i],
                                    style: TextStyle(
                                      color: selected
                                          ? (isDark
                                                ? AppColors.darkBackground
                                                : Colors.white)
                                          : textColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (unread > 0) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 18,
                                      height: 18,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: selected
                                            ? (isDark
                                                  ? const Color(0xFF10B981)
                                                  : AppColors.accent)
                                            : AppColors.error,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        unread > 99 ? '99+' : '$unread',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ];
          },
          body: filtered.isEmpty
              ? _buildEmptyState(subTextColor)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: filtered.length,
                  separatorBuilder: (a, b) => Divider(
                    height: 0,
                    thickness: 0.5,
                    color: borderColor,
                    indent: 72,
                  ),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildNotificationTile(
                      context,
                      item,
                      isDark,
                      textColor,
                      subTextColor,
                      surfaceColor,
                      borderColor,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color subTextColor) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 56,
            color: subTextColor.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications',
            style: TextStyle(
              color: subTextColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(
    BuildContext context,
    Map<String, dynamic> item,
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    final bool isRead = item['isRead'] as bool;
    final Color iconColor = item['iconColor'] as Color;

    return Dismissible(
      key: ValueKey(item['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_rounded, color: Colors.white, size: 24),
            SizedBox(height: 2),
            Text(
              'Delete',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (_) {
        _deleteItem(item['id'] as String);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.accent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          _markAsRead(item['id'] as String);
          _handleNotificationTap(item);
        },
        child: Container(
          color: isRead
              ? Colors.transparent
              : AppColors.accent.withValues(alpha: isDark ? 0.06 : 0.04),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Unread left accent bar
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 3,
                  color: isRead ? Colors.transparent : AppColors.accent,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon circle
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['title'] as String,
                                      style: TextStyle(
                                        color: textColor,
                                        fontSize: 13.5,
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    item['time'] as String,
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 10.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['description'] as String,
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12.5,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Unread dot + delete
                        Column(
                          children: [
                            if (!isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              )
                            else
                              const SizedBox(width: 8, height: 8),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => _deleteItem(item['id'] as String),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
