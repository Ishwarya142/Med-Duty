import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CategoryChip extends StatelessWidget {
  final String title;
  final bool selected;

  const CategoryChip({
    super.key,
    required this.title,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.accent
            : AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.divider.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: selected
              ? AppColors.white
              : AppColors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
