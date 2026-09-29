import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/recommended_duties_service.dart';
import '../../../models/duty_with_distance.dart';
import '../../../providers/duty_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/profile_provider.dart';
import '../discovery_helpers.dart';
import 'duty_discovery_card.dart';

const _cTeal = Color(0xFF0F766E);

/// Recommended duties shown below nearby results or empty state.
class RecommendedDutiesSection extends StatelessWidget {
  const RecommendedDutiesSection({
    super.key,
    required this.excludeDutyIds,
  });

  final Set<String> excludeDutyIds;

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final duties = context.watch<DutyProvider>();
    final profile = context.watch<ProfileProvider>();
    final center = location.searchLocation;
    if (center == null) return const SizedBox.shrink();

    final items = RecommendedDutiesService.build(
      centerLat: center.latitude,
      centerLng: center.longitude,
      currentRadiusKm: location.radiusKm,
      specialization: profile.specialization.isNotEmpty
          ? profile.specialization
          : profile.qualification,
      locationLabel: location.locationLabel,
      excludeDutyIds: excludeDutyIds,
    );

    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recommended for You',
                style: TextStyle(
                  color: tx,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'These duties may match your profile',
                style: TextStyle(color: sub, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Suggested opportunities — availability may vary',
                style: TextStyle(
                  color: sub.withValues(alpha: 0.85),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _RecommendationCard(
              item: item,
              duties: duties,
              isDemo: RecommendedDutiesService.isDemoRecommendation(
                item.duty.id,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.item,
    required this.duties,
    required this.isDemo,
  });

  final DutyWithDistance item;
  final DutyProvider duties;
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isDemo)
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _cTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Suggested',
                style: TextStyle(
                  color: _cTeal,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        DutyDiscoveryCard(
          item: item,
          isApplied: duties.isDutyApplied(item.duty.id),
          isSaved: duties.isDutySaved(item.duty.id),
          onTap: () => openDiscoveryDutyDetails(context, item),
          onApply: () => applyDiscoveryDuty(context, item),
          onSave: () => toggleDiscoverySave(context, item),
        ),
      ],
    );
  }
}
