import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/duty_with_distance.dart';
import '../../../providers/duty_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/profile_provider.dart';
import '../discovery_helpers.dart';
import 'emergency_duty_card.dart';

/// Emergency duties section — hidden when no active emergency duties exist.
class EmergencyDutiesSection extends StatelessWidget {
  const EmergencyDutiesSection({
    super.key,
    this.compact = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final duties = context.watch<DutyProvider>();
    final location = context.watch<LocationProvider>();
    final profile = context.watch<ProfileProvider>();
    final specialization = profile.specialization.isNotEmpty
        ? profile.specialization
        : profile.qualification;
    final items = duties.emergencyNearby(location, specialization: specialization);

    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(
            'Emergency Duties',
            style: TextStyle(color: tx, fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(
            'Posted as emergency • within your radius • last 24 hours',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...items.map((item) => _buildCard(context, item, duties)),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    DutyWithDistance item,
    DutyProvider duties,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: EmergencyDutyCard(
        item: item,
        compact: compact,
        isApplied: duties.isDutyApplied(item.duty.id),
        isSaved: duties.isDutySaved(item.duty.id),
        onTap: () => openDiscoveryDutyDetails(context, item),
        onApply: () => applyDiscoveryDuty(context, item, isEmergency: true),
        onSave: () => toggleDiscoverySave(context, item),
      ),
    );
  }
}
