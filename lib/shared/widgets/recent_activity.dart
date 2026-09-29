import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  Widget timelineItem(String title, String subtitle, String time, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              // Dummy timeline line if needed
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          timelineItem(
            "Shift Approved",
            "Fortis Hospital ER Duty",
            "Just now",
            AppColors.success,
            Icons.verified_user_rounded,
          ),
          timelineItem(
            "Shift Completed",
            "Apollo ICU Duty (₹7000/day payout cleared)",
            "2 hours ago",
            AppColors.accent,
            Icons.task_alt_rounded,
          ),
          timelineItem(
            "Application Submitted",
            "MIOT Hospital Ward Shift",
            "Yesterday",
            AppColors.primary,
            Icons.assignment_turned_in_rounded,
          ),
        ],
      ),
    );
  }
}
