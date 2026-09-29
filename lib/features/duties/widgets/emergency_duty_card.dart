// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../models/duty_with_distance.dart';
import '../discovery_helpers.dart';
import 'emergency_flash_card.dart';

class EmergencyDutyCard extends StatelessWidget {
  final DutyWithDistance item;
  final bool isApplied;
  final bool isSaved;
  final bool compact;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;

  const EmergencyDutyCard({
    super.key,
    required this.item,
    this.isApplied = false,
    this.isSaved = false,
    this.compact = false,
    this.onTap,
    this.onApply,
    this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return EmergencyFlashCard(
      item: item,
      compact: compact,
      isApplied: isApplied,
      isSaved: isSaved,
      onTap: onTap ?? () => openDiscoveryDutyDetails(context, item),
      onApply: onApply ?? () => applyDiscoveryDuty(context, item, isEmergency: true),
      onSave: onSave ?? () => toggleDiscoverySave(context, item),
    );
  }
}
