// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../voice_call_screen.dart';
import '../video_call_screen.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cRed    = Color(0xFFEF4444);
const _cBlue   = Color(0xFF2563EB);

class IncomingCallSheet extends StatefulWidget {
  final String callerName;
  final String callerRole;
  final String callerHospital;
  final String? callerAvatar;
  final bool isVideo;

  const IncomingCallSheet({
    super.key,
    required this.callerName,
    this.callerRole = 'Healthcare Specialist',
    this.callerHospital = 'MedDuty Network',
    this.callerAvatar,
    this.isVideo = false,
  });

  static Future<void> show(
    BuildContext context, {
    required String callerName,
    String callerRole = 'Healthcare Specialist',
    String callerHospital = 'MedDuty Network',
    String? callerAvatar,
    bool isVideo = false,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => IncomingCallSheet(
        callerName: callerName,
        callerRole: callerRole,
        callerHospital: callerHospital,
        callerAvatar: callerAvatar,
        isVideo: isVideo,
      ),
    );
  }

  @override
  State<IncomingCallSheet> createState() => _IncomingCallSheetState();
}

class _IncomingCallSheetState extends State<IncomingCallSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _accept() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
    if (widget.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoCallScreen(
            receiverName: widget.callerName,
            receiverRole: widget.callerRole,
            isOnline: true,
          ),
          fullscreenDialog: true,
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceCallScreen(
            receiverName: widget.callerName,
            receiverRole: widget.callerRole,
            isOnline: true,
          ),
          fullscreenDialog: true,
        ),
      );
    }
  }

  void _decline() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.callerName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .where((e) => e.isNotEmpty)
        .take(2)
        .join();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Pulsing Avatar
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, child) {
              final v = _pulse.value;
              return Container(
                padding: EdgeInsets.all(12 + v * 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _cTeal.withValues(alpha: 0.15 + v * 0.15),
                ),
                child: child,
              );
            },
            child: CircleAvatar(
              radius: 46,
              backgroundColor: _cTeal,
              backgroundImage: widget.callerAvatar != null
                  ? NetworkImage(widget.callerAvatar!)
                  : null,
              child: widget.callerAvatar == null
                  ? Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 18),

          // Caller Name & Role
          Text(
            widget.callerName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.callerRole} • ${widget.callerHospital}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Call Type Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: widget.isVideo
                  ? _cBlue.withValues(alpha: 0.2)
                  : _cTeal.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isVideo
                    ? _cBlue.withValues(alpha: 0.4)
                    : _cTeal.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  widget.isVideo
                      ? Icons.videocam_rounded
                      : Icons.phone_in_talk_rounded,
                  color: widget.isVideo ? _cBlue : _cTeal,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.isVideo ? 'Incoming Video Call…' : 'Incoming Audio Call…',
                  style: TextStyle(
                    color: widget.isVideo ? const Color(0xFF93C5FD) : const Color(0xFF5EEAD4),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          // Action Buttons: Decline (Red) and Accept (Green)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Decline Button
              Column(
                children: [
                  GestureDetector(
                    onTap: _decline,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: _cRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x66EF4444),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.call_end_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Decline',
                    style: TextStyle(color: Colors.white70, fontSize: 12.5),
                  ),
                ],
              ),

              // Accept Button
              Column(
                children: [
                  GestureDetector(
                    onTap: _accept,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        color: _cGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x6616A34A),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isVideo
                            ? Icons.videocam_rounded
                            : Icons.call_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Accept',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
