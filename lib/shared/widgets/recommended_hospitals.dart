import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class RecommendedHospitals extends StatelessWidget {
  const RecommendedHospitals({super.key});

  Widget hospitalCard(BuildContext context, String name, String city, String rating) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3), width: 1.5),
        boxShadow: AppColors.softShadow,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.local_hospital_rounded,
            color: AppColors.white,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 5),
            const Icon(Icons.verified, color: AppColors.accent, size: 14),
          ],
        ),
        subtitle: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 12, color: AppColors.grey),
            const SizedBox(width: 2),
            Text(
              city,
              style: const TextStyle(
                color: AppColors.grey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 14),
              const SizedBox(width: 4),
              Text(
                rating,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Welcome to $name portal!"),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        hospitalCard(context, "Apollo Hospital", "Chennai", "4.8"),
        hospitalCard(context, "Fortis Hospital", "Bangalore", "4.7"),
        hospitalCard(context, "MIOT Hospital", "Chennai", "4.6"),
      ],
    );
  }
}
