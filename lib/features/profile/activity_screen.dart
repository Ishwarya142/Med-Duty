import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/activity_provider.dart';
import '../../models/activity_item_model.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityProvider>().loadActivity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activityProvider = context.watch<ActivityProvider>();

    final tabs = ['All', 'Notifications', 'Views', 'Logins', 'Searches'];

    List<ActivityItemModel> filteredItems = [];
    switch (_selectedIndex) {
      case 0:
        filteredItems = activityProvider.activity;
        break;
      case 1:
        filteredItems = activityProvider.activity
            .where((item) => item.type == ActivityType.notification)
            .toList();
        break;
      case 2:
        filteredItems = activityProvider.activity
            .where((item) => item.type == ActivityType.view)
            .toList();
        break;
      case 3:
        filteredItems = activityProvider.activity
            .where((item) => item.type == ActivityType.login)
            .toList();
        break;
      case 4:
        filteredItems = activityProvider.activity
            .where((item) => item.type == ActivityType.search)
            .toList();
        break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tabs[index]),
                    selected: _selectedIndex == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: _selectedIndex == index
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(child: _buildContent(filteredItems)),
        ],
      ),
    );
  }

  Widget _buildContent(List<ActivityItemModel> items) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history, size: 64, color: AppColors.textSecondary),
              const SizedBox(height: 16),
              Text(
                'No activity yet',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildActivityItemCard(item);
      },
    );
  }

  Widget _buildActivityItemCard(ActivityItemModel item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getItemIcon(item.type),
              color: _getItemColor(item.type),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.description != null)
                  Text(
                    item.description!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(item.createdAt),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getItemIcon(ActivityType type) {
    switch (type) {
      case ActivityType.notification:
        return Icons.notifications;
      case ActivityType.view:
        return Icons.remove_red_eye;
      case ActivityType.login:
        return Icons.login;
      case ActivityType.search:
        return Icons.search;
      case ActivityType.profileVisit:
        return Icons.person;
    }
  }

  Color _getItemColor(ActivityType type) {
    switch (type) {
      case ActivityType.notification:
        return AppColors.accent;
      case ActivityType.view:
        return AppColors.info;
      case ActivityType.login:
        return AppColors.success;
      case ActivityType.search:
        return AppColors.primary;
      case ActivityType.profileVisit:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
