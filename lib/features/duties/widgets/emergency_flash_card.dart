// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/duty_with_distance.dart';

const _cRed = Color(0xFFEF4444);
const _cRedDark = Color(0xFFDC2626);

/// A highly noticeable, animated "emerging flash card" for active emergency duties.
class EmergencyFlashCard extends StatefulWidget {
  final DutyWithDistance item;
  final VoidCallback onTap;
  final VoidCallback? onApply;
  final VoidCallback? onSave;
  final bool isSaved;
  final bool isApplied;
  final bool compact;

  const EmergencyFlashCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onApply,
    this.onSave,
    this.isSaved = false,
    this.isApplied = false,
    this.compact = false,
  });

  @override
  State<EmergencyFlashCard> createState() => _EmergencyFlashCardState();
}

class _EmergencyFlashCardState extends State<EmergencyFlashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.08, end: 0.28).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _calculateStartTimeCountdown() {
    final now = DateTime.now();
    final start = widget.item.duty.startTime;
    final diff = start.difference(now);
    if (diff.isNegative) {
      return 'Urgent: Shift underway';
    }
    if (diff.inHours > 0) {
      return 'Starts in ${diff.inHours}h ${diff.inMinutes % 60}m';
    }
    if (diff.inMinutes > 0) {
      return 'Starts in ${diff.inMinutes}m';
    }
    return 'Starts immediately';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final duty = widget.item.duty;
    final timeFmt = DateFormat('h:mm a');
    final dateFmt = DateFormat('d MMM');

    final distanceStr = widget.item.distanceKm != null
        ? '${widget.item.distanceKm!.toStringAsFixed(1)} km away'
        : 'Nearby';

    final countdownStr = _calculateStartTimeCountdown();

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF2E1212)
                : const Color(0xFFFFF5F5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _cRed.withValues(alpha: 0.4 + (_glowAnimation.value * 0.6)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: _cRed.withValues(alpha: _glowAnimation.value),
                blurRadius: 16,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Flash Header: Beacon + Urgent Pill + Bookmark
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Pulsing Beacon Siren Icon
                        Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: _cRed.withValues(alpha: 0.16),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _cRed.withValues(alpha: 0.35),
                                width: 1.2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.notifications_active_rounded,
                                color: _cRedDark,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Urgent Headline & Countdown
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _cRed,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'EMERGENCY DUTY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Immediate coverage needed',
                                      style: TextStyle(
                                        color: isDark ? const Color(0xFFFCA5A5) : _cRedDark,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(
                                    Icons.timer_rounded,
                                    size: 12.5,
                                    color: isDark ? const Color(0xFFFCA5A5) : _cRedDark,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    countdownStr,
                                    style: TextStyle(
                                      color: isDark ? const Color(0xFFFCA5A5) : _cRedDark,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Bookmark Save Icon
                        if (widget.onSave != null)
                          GestureDetector(
                            onTap: widget.onSave,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                widget.isSaved
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_outline_rounded,
                                size: 20,
                                color: widget.isSaved ? const Color(0xFFF59E0B) : _cRedDark,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Hospital & Role Info
                    Text(
                      duty.hospitalName,
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      duty.displaySpecialization.isNotEmpty
                          ? duty.displaySpecialization
                          : duty.role,
                      style: TextStyle(
                        color: isDark ? const Color(0xFFFCA5A5) : _cRedDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Location & Shift Time Row
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 12,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          dateFmt.format(duty.dutyDate),
                          style: TextStyle(
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '${duty.location} • $distanceStr',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                              fontSize: 11.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.schedule_rounded,
                          size: 13,
                          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${timeFmt.format(duty.startTime)} – ${timeFmt.format(duty.endTime)}',
                          style: TextStyle(
                            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bottom Action Row: Payout Rate on Left + View Now / Apply on Right
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMERGENCY PAYOUT',
                              style: TextStyle(
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                            Text(
                              '₹${duty.salary.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),

                        ElevatedButton.icon(
                          onPressed: widget.onApply ?? widget.onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cRed,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Text(
                            'View Duty',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                          ),
                          label: const Icon(Icons.arrow_forward_rounded, size: 16),
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
}
