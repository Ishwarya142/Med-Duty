// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/emergency_duty_utils.dart';
import '../../../models/duty_model.dart';
import '../../../models/duty_with_distance.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cRed    = Color(0xFFEF4444);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cPurple = Color(0xFF7C3AED);

class DutyDiscoveryCard extends StatelessWidget {
  final DutyWithDistance item;
  final bool isSelected;
  final bool isApplied;
  final bool isSaved;
  final VoidCallback? onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;
  final bool compact;

  const DutyDiscoveryCard({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isApplied = false,
    this.isSaved = false,
    this.onTap,
    this.onApply,
    this.onSave,
    this.compact = false,
  });

  Color _getIconThemeColor(DutyModel duty) {
    if (EmergencyDutyUtils.isActiveEmergency(duty)) {
      return _cTeal;
    }
    if (duty.hospitalName.toLowerCase().contains('hospital') ||
        duty.hospitalName.toLowerCase().contains('institute')) {
      return _cBlue;
    }
    return _cAmber;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final duty = item.duty;
    final isEmergency = EmergencyDutyUtils.isActiveEmergency(duty);
    final isNight = duty.shiftType?.toLowerCase().contains('night') == true ||
        duty.startTime.hour >= 18 ||
        duty.endTime.hour <= 7;

    final iconColor = _getIconThemeColor(duty);
    final dateFmt = DateFormat('d MMM');
    final timeFmt = DateFormat('h:mm a');

    final distanceStr = item.distanceKm != null
        ? '${item.distanceKm!.toStringAsFixed(1)} km away'
        : 'Nearby';

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 340;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? _cTeal
                  : (isEmergency ? _cRed.withValues(alpha: 0.35) : border),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Emergency Badge (if applicable)
                    if (isEmergency) ...[
                      Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: _cRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _cRed.withValues(alpha: 0.25)),
                        ),
                        child: const Text(
                          'EMERGENCY',
                          style: TextStyle(
                            color: _cRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],

                    // Top Row: Icon + Hospital & Specialty + (Bookmark / Pay)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Medical Cross Icon
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add_box_rounded,
                              color: iconColor,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Center: Hospital Name & Specialty
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                duty.hospitalName,
                                style: TextStyle(
                                  color: tx,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                duty.displaySpecialization.isNotEmpty
                                    ? duty.displaySpecialization
                                    : duty.role,
                                style: const TextStyle(
                                  color: _cTeal,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Top Right: Bookmark & Pay (if compact) or Date
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isWide) ...[
                              Icon(Icons.calendar_today_rounded, size: 12, color: sub),
                              const SizedBox(width: 4),
                              Text(
                                dateFmt.format(duty.dutyDate),
                                style: TextStyle(
                                  color: sub,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                            ],
                            if (onSave != null)
                              GestureDetector(
                                onTap: onSave,
                                child: Icon(
                                  isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                  size: 18,
                                  color: isSaved ? _cAmber : sub,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Location Row
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 13, color: sub),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${duty.location} • $distanceStr',
                            style: TextStyle(color: sub, fontSize: 11.5),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Timing & Date Chips Row
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (!isWide)
                          _chip(dateFmt.format(duty.dutyDate), sub),
                        _chip(
                          '${timeFmt.format(duty.startTime)} – ${timeFmt.format(duty.endTime)} ${isNight ? '🌙' : '☀️'}',
                          sub,
                        ),
                        _chip(duty.displayShift, isNight ? _cPurple : _cBlue),
                        if (isEmergency)
                          _chip('Emergency', _cRed, filled: true)
                        else
                          _chip('General Duty', _cGreen),
                        if (duty.verified)
                          _chip('Verified', _cTeal, filled: true),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Bottom Action Row: Salary on Left + Apply on Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '₹${duty.salary.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: _cTeal,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (onApply != null)
                          ElevatedButton(
                            onPressed: isApplied ? null : onApply,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApplied ? sub.withValues(alpha: 0.2) : _cTeal,
                              foregroundColor: isApplied ? sub : Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                            child: Text(
                              isApplied ? 'Applied ✓' : 'Apply',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                                color: isApplied ? sub : Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String label, Color color, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: filled ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: filled ? 0.3 : 0.2),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
