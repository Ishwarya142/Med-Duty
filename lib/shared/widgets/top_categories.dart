import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/duties/specialist_duties_screen.dart';

class TopCategories extends StatelessWidget {
  const TopCategories({super.key});

  Widget categoryChip(BuildContext context, String label, IconData icon) {
    return ActionChip(
      avatar: Icon(icon, color: AppColors.white, size: 16),
      backgroundColor: AppColors.surface,
      side: const BorderSide(color: AppColors.divider, width: 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SpecialistDutiesScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        categoryChip(context, "Cardiology", Icons.favorite_rounded),
        categoryChip(context, "Neurology", Icons.psychology_rounded),
        categoryChip(context, "Orthopedics", Icons.healing_rounded),
        categoryChip(context, "Pediatrics", Icons.child_care_rounded),
        categoryChip(context, "Emergency", Icons.emergency_rounded),
      ],
    );
  }
}
