import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  Widget item(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    bool showDivider,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final dividerColor = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  right: BorderSide(
                    color: dividerColor.withValues(alpha: 0.5),
                    width: 1,
                  ),
                )
              : null,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.accent, size: 22),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                color: subTextColor,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: isDark ? null : AppColors.cardShadow,
        border: Border.all(
          color: borderColor.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 8),
        child: Row(
          children: [
            item(
              context,
              "Applied",
              "24",
              Icons.assignment_turned_in_outlined,
              true,
            ),
            item(
              context,
              "Completed",
              "18",
              Icons.check_circle_outline_rounded,
              true,
            ),
            // Avoid border on last item
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star_outline_rounded,
                      color: AppColors.accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "4.9",
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                      letterSpacing: -0.5,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Rating",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: subTextColor,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
