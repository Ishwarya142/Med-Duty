import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Widget button(
    BuildContext context,
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor, width: 1.2),
                  boxShadow: isDark ? null : AppColors.softShadow,
                ),
                child: Center(
                  child: Icon(icon, color: AppColors.accent, size: 26),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap',
                style: TextStyle(
                  fontSize: 10.5,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        button(context, Icons.search_rounded, "Find Duties", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Type in the search bar below to filter duties!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
        button(context, Icons.bookmark_border_rounded, "Saved", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("No saved duties found"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
        button(context, Icons.history_rounded, "History", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Duty history is currently empty"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
        button(context, Icons.contact_support_outlined, "Support", () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Connecting to MedDuty helpline..."),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }),
      ],
    );
  }
}
