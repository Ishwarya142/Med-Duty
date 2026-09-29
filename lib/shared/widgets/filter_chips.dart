import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class FilterChips extends StatelessWidget {
  const FilterChips({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = [
      "All",
      "Nearby",
      "Today",
      "Emergency",
      "ICU",
      "Night",
    ];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final selected = index == 0;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.accent
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppColors.divider.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                filters[index],
                style: TextStyle(
                  color: selected ? AppColors.white : AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
