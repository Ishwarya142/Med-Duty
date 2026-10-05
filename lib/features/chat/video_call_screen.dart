// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../profile/public_doctor_profile_screen.dart';
import '../../providers/settings_preferences_provider.dart';
import '../../shared/widgets/report_bottom_sheet.dart';
import 'call_media_controller.dart';
import 'chat_screen.dart';

const _vtTeal       = Color(0xFF0F766E);
// ignore: unused_element
const _vtTealDark   = Color(0xFF06211E);
const _vtBgDeep     = Color(0xFF041715);
const _vtGreen      = Color(0xFF10B981);
const _vtCyan       = Color(0xFF2DD4BF);
const _vtRed        = Color(0xFFEF4444);
const _vtOrange     = Color(0xFFF97316);
const _vtBlue       = Color(0xFF2563EB);
// ignore: unused_element
const _vtBtnBg      = Color(0xFF163834);
// ignore: unused_element
const _vtBorder     = Color(0xFF1E4540);
// ignore: unused_element
const _vtText       = Color(0xFFFFFFFF);
// ignore: unused_element
const _vtSub        = Color(0xFF94A3B8);

enum _VideoCallState { idle, calling, ringing, connected, onHold, reconnecting, ended }
// ignore: unused_field
enum _AudioOutput { speaker, earpiece, bluetooth }

class VideoCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverRole;
  final String receiverHospital;
  final String? avatarColor;
  final bool isOnline;

  const VideoCallScreen({
    super.key,
    required this.receiverName,
    this.receiverRole = 'Cardiologist',
    this.receiverHospital = 'Max Hospital Delhi',
    this.avatarColor,
    this.isOnline = true,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen>
    with TickerProviderStateMixin {
  final CallMediaController _media = CallMediaController();
  _VideoCallState _state = _VideoCallState.calling;
  int _seconds = 0;
  Timer? _timer;
  Timer? _stateTimer;

  bool _cameraOn = true;
  bool _muted = false;
  bool _speaker = true;
  bool _isFrontCamera = true;
  bool _sharingScreen = false;
  bool _bgBlur = false;
  bool _swappedViews = false;
  // ignore: unused_field
  _AudioOutput _selectedOutput = _AudioOutput.speaker;

  late double _pipTop;
  late double _pipLeft;
  double _pipWidth = 112;
  double _pipHeight = 152;

  late final AnimationController _pulse;
  late final AnimationController _ring;
  late final AnimationController _avatarFloat;

  void _onMediaChanged() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _media.addListener(_onMediaChanged);
    _media.initialize(withCamera: true, withAudio: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      final safe = MediaQuery.of(context).padding;
      setState(() {
        _pipWidth = (size.shortestSide * 0.29).clamp(100.0, 135.0);
        _pipHeight = _pipWidth * 1.36;
        _pipLeft = size.width - _pipWidth - 16;
        _pipTop = safe.top + 52;
      });
    });
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _ring = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _avatarFloat = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _advanceState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stateTimer?.cancel();
    _pulse.dispose();
    _ring.dispose();
    _avatarFloat.dispose();
    _media.removeListener(_onMediaChanged);
    _media.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _advanceState() {
    _stateTimer?.cancel();
    final otherOnline = widget.isOnline;
    _stateTimer = Timer(Duration(milliseconds: otherOnline ? 1400 : 1800), () {
      if (!mounted) return;
      setState(() => _state = _VideoCallState.ringing);
      if (otherOnline) {
        _ring.repeat(reverse: true);
      }
      _stateTimer = Timer(const Duration(milliseconds: 2400), () {
        if (!mounted) return;
        final answered = otherOnline && _state == _VideoCallState.ringing;
        if (answered) {
          setState(() => _state = _VideoCallState.connected);
          _ring.stop();
          _startTimer();
        } else {
          _endCall(noAnswer: true);
        }
      });
    });
  }

  void _startTimer() {
    _seconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _seconds++);
    });
  }

  String _formatDuration(int total) {
    final m = (total ~/ 60).toString().padLeft(2, '0');
    final s = (total % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  String _statusLabel() {
    switch (_state) {
      case _VideoCallState.idle:
        return '';
      case _VideoCallState.calling:
        return 'Calling…';
      case _VideoCallState.ringing:
        return 'Ringing…';
      case _VideoCallState.connected:
        return 'Connected • Excellent';
      case _VideoCallState.onHold:
        return 'Call on Hold';
      case _VideoCallState.reconnecting:
        return 'Reconnecting…';
      case _VideoCallState.ended:
        return 'Call ended';
    }
  }

  void _toggleCamera() {
    HapticFeedback.lightImpact();
    setState(() => _cameraOn = !_cameraOn);
    _media.toggleCamera(_cameraOn);
    _snack(_cameraOn ? 'Camera turned on' : 'Camera paused');
  }

  void _toggleMute() {
    HapticFeedback.lightImpact();
    setState(() => _muted = !_muted);
    _media.setMuted(_muted);
    _snack(_muted ? 'Microphone muted' : 'Microphone unmuted');
  }

  void _toggleSpeaker() {
    HapticFeedback.lightImpact();
    setState(() {
      _speaker = !_speaker;
      _selectedOutput = _speaker ? _AudioOutput.speaker : _AudioOutput.earpiece;
    });
    _snack(_speaker ? 'Speakerphone on' : 'Earpiece mode');
  }

  void _flipCamera() async {
    HapticFeedback.lightImpact();
    await _media.switchCamera();
    if (mounted) {
      setState(() => _isFrontCamera = _media.isFrontCamera);
      _snack(_isFrontCamera ? 'Switched to front camera' : 'Switched to rear camera');
    }
  }

  void _toggleScreenShare() {
    HapticFeedback.lightImpact();
    setState(() => _sharingScreen = !_sharingScreen);
    _snack(_sharingScreen
        ? 'Screen sharing started (Patient Report)'
        : 'Screen sharing stopped');
  }

  void _toggleBgBlur() {
    HapticFeedback.lightImpact();
    setState(() => _bgBlur = !_bgBlur);
    _snack(_bgBlur ? 'Background blur enabled' : 'Background blur disabled');
  }

  void _toggleHold() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_state == _VideoCallState.onHold) {
        _state = _VideoCallState.connected;
      } else if (_state == _VideoCallState.connected) {
        _state = _VideoCallState.onHold;
      }
    });
    _snack(_state == _VideoCallState.onHold ? 'Call placed on hold' : 'Call resumed');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _vtTeal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _endCall({bool noAnswer = false}) {
    HapticFeedback.mediumImpact();
    _timer?.cancel();
    _stateTimer?.cancel();
    if (mounted) {
      setState(() => _state = _VideoCallState.ended);
    }
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final duration = _seconds;
      final label = noAnswer
          ? 'Video call • No answer'
          : 'Outgoing video call • ${_formatDuration(duration)}';
      Navigator.of(context).pop(<String, dynamic>{
        'type': noAnswer ? 'video_call_missed' : 'video_call',
        'label': label,
        'duration': duration,
        'noAnswer': noAnswer,
      });
    });
  }

  void _minimize() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(null);
  }

  // ── More Options Modal Bottom Sheet (1:1 mockup match) ──────────────────────
  void _showMoreOptionsSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF0C2421),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(
            top: BorderSide(color: Color(0xFF1E4540), width: 1.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Header Row: Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'More Options',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 1 (4 items): Hold Call, Share Screen, Background Blur, Switch Camera
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _moreGridItem(
                  icon: _state == _VideoCallState.onHold
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  label: _state == _VideoCallState.onHold ? 'Resume Call' : 'Hold Call',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleHold();
                  },
                ),
                _moreGridItem(
                  icon: Icons.desktop_windows_outlined,
                  label: 'Share Screen',
                  active: _sharingScreen,
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleScreenShare();
                  },
                ),
                _moreGridItem(
                  icon: Icons.wb_sunny_outlined,
                  label: 'Background Blur',
                  active: _bgBlur,
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleBgBlur();
                  },
                ),
                _moreGridItem(
                  icon: Icons.sync_rounded,
                  label: 'Switch Camera',
                  onTap: () {
                    Navigator.pop(ctx);
                    _flipCamera();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Row 2 (4 items): View Profile, Block User (red), Report User (orange), Call Settings
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _moreGridItem(
                  icon: Icons.person_outline_rounded,
                  label: 'View Profile',
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PublicDoctorProfileScreen(
                          doctorName: widget.receiverName,
                          qualification: 'MBBS, MD',
                          specialization: widget.receiverRole,
                          hospital: widget.receiverHospital,
                          location: 'Delhi, India',
                        ),
                      ),
                    );
                  },
                ),
                _moreGridItem(
                  icon: Icons.block_rounded,
                  label: 'Block User',
                  iconColor: _vtRed,
                  borderColor: _vtRed.withValues(alpha: 0.5),
                  bgColor: _vtRed.withValues(alpha: 0.12),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmBlockUser();
                  },
                ),
                _moreGridItem(
                  icon: Icons.flag_outlined,
                  label: 'Report User',
                  iconColor: _vtOrange,
                  borderColor: _vtOrange.withValues(alpha: 0.5),
                  bgColor: _vtOrange.withValues(alpha: 0.12),
                  onTap: () {
                    Navigator.pop(ctx);
                    showContentReportSheet(
                      context,
                      subjectLabel: 'Video Call (${widget.receiverName})',
                      targetId: widget.receiverName,
                      targetName: widget.receiverName,
                      reportType: 'call',
                    );
                  },
                ),
                _moreGridItem(
                  icon: Icons.settings_outlined,
                  label: 'Call Settings',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showCallSettingsDialog();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _moreGridItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    bool active = false,
    Color? borderColor,
    Color? bgColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: active
                    ? _vtGreen.withValues(alpha: 0.25)
                    : (bgColor ?? const Color(0xFF163834)),
                shape: BoxShape.circle,
                border: Border.all(
                  color: active
                      ? _vtGreen
                      : (borderColor ?? const Color(0xFF22524C)),
                  width: 1.2,
                ),
              ),
              child: Icon(
                icon,
                color: active ? _vtGreen : iconColor,
                size: 22,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.15,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ── Document Sharing Sheet ──────────────────────────────────────────────────
  void _showDocumentSharingSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF0C2421),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF1E4540), width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Share Clinical Document',
              style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _docTile(
              title: 'ECG Report_2026_Aug.pdf',
              subtitle: 'PDF Document • 2.4 MB',
              icon: Icons.picture_as_pdf_rounded,
              color: _vtRed,
              onTap: () {
                Navigator.pop(ctx);
                _snack('ECG Report shared with ${widget.receiverName}');
              },
            ),
            const SizedBox(height: 8),
            _docTile(
              title: 'Blood_Panel_Lab_Results.pdf',
              subtitle: 'PDF Document • 1.1 MB',
              icon: Icons.picture_as_pdf_rounded,
              color: _vtTeal,
              onTap: () {
                Navigator.pop(ctx);
                _snack('Blood Panel results shared');
              },
            ),
            const SizedBox(height: 8),
            _docTile(
              title: 'Chest_XRay_Digital.dcm',
              subtitle: 'DICOM Clinical Imaging • 8.6 MB',
              icon: Icons.image_rounded,
              color: _vtBlue,
              onTap: () {
                Navigator.pop(ctx);
                _snack('X-Ray imaging shared');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _docTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF163834),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF22524C)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                    Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                  ],
                ),
              ),
              const Icon(Icons.send_rounded, color: _vtCyan, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  // ── Call Settings Dialog ───────────────────────────────────────────────────
  void _showCallSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2421),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Video Call Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('HD Video Mode (1080p)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Optimized bitrate for consultations', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: true,
              activeColor: _vtGreen,
              onChanged: (_) {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Low Light Enhancement', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Automatically brighten camera in dim rooms', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: true,
              activeColor: _vtGreen,
              onChanged: (_) {},
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Background Blur', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Blur clinic surroundings', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: _bgBlur,
              activeColor: _vtGreen,
              onChanged: (v) {
                setState(() => _bgBlur = v);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: _vtCyan, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmBlockUser() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2421),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Block ${widget.receiverName}?', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'Blocked users cannot video call or message you on MedDuty.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _vtRed),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<SettingsPreferencesProvider>().blockUser(
        id: widget.receiverName,
        name: widget.receiverName,
        role: widget.receiverRole,
      );
      _endCall(noAnswer: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final safe = MediaQuery.of(context).padding;
    final isConnected = _state == _VideoCallState.connected;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _endCall(noAnswer: !isConnected && _seconds == 0);
      },
      child: Scaffold(
        backgroundColor: _vtBgDeep,
        body: Stack(
          children: [
            // ── 1. Full-Screen Remote Video Canvas / Screen Share ───────────
            _buildRemoteCanvas(size, isConnected),

            // ── 2. Top Navigation Bar Overlay ───────────────────────────────
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back / minimize button <
                    IconButton(
                      tooltip: 'Minimize call',
                      onPressed: _minimize,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),

                    // End-to-end Encrypted badge
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.shield_outlined,
                          color: _vtGreen,
                          size: 15,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'End-to-end Encrypted',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),

                    // 3-dot More menu
                    IconButton(
                      tooltip: 'More options',
                      onPressed: _showMoreOptionsSheet,
                      icon: const Icon(
                        Icons.more_vert_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── 3. Doctor Info Overlay (Top-Left) ───────────────────────────
            Positioned(
              top: safe.top + 50,
              left: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.receiverName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 10),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.verified_rounded,
                        color: _vtCyan,
                        size: 17,
                      ),
                      const SizedBox(width: 6),
                      // 3 Green Cellular / Network Bars
                      const Icon(
                        Icons.signal_cellular_alt_rounded,
                        color: _vtGreen,
                        size: 18,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.receiverRole,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(color: Colors.black87, blurRadius: 8),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _statusLabel(),
                    style: TextStyle(
                      color: _state == _VideoCallState.onHold
                          ? _vtOrange
                          : (isConnected ? _vtGreen : Colors.white70),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(color: Colors.black87, blurRadius: 8),
                      ],
                    ),
                  ),
                  if (isConnected || _state == _VideoCallState.onHold) ...[
                    const SizedBox(height: 2),
                    Text(
                      _formatDuration(_seconds),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                        shadows: [
                          Shadow(color: Colors.black87, blurRadius: 8),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── 4. Floating Draggable Self-View PiP (Top-Right) ──────────────
            _buildDraggablePip(size, safe),

            // ── 5. Center-Bottom "Swipe up for more options" ────────────────
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _showMoreOptionsSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Swipe up for more options',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 6. Bottom Controls & Action Tray ────────────────────────────
            _buildBottomControlsAndTray(safe, isConnected),
          ],
        ),
      ),
    );
  }

  // ── Full-Screen Video Canvas ────────────────────────────────────────────────
  Widget _buildRemoteCanvas(Size size, bool isConnected) {
    if (_sharingScreen) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF0F172A),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _vtGreen.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: _vtGreen.withValues(alpha: 0.4)),
                ),
                child: const Icon(
                  Icons.desktop_windows_outlined,
                  color: _vtGreen,
                  size: 54,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Clinical Screen Sharing Active',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Sharing: ECG_Diagnostic_Lead_II.pdf',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF061A18),
      child: _swappedViews
          ? _buildLiveCameraWidget(isPip: false)
          : _buildDoctorFeedWidget(isPip: false),
    );
  }

  // ── Live Camera Stream Widget ───────────────────────────────────────────────
  Widget _buildLiveCameraWidget({required bool isPip}) {
    if (!_cameraOn || !_media.cameraActive) {
      return Container(
        color: const Color(0xFF0D2421),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.videocam_off_rounded,
                color: Colors.white54,
                size: isPip ? 28 : 56,
              ),
              if (!isPip) ...[
                const SizedBox(height: 12),
                const Text(
                  'Your Camera is Off',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (_media.isCameraLoading) {
      return Container(
        color: const Color(0xFF061A18),
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: _vtCyan),
          ),
        ),
      );
    }

    if (_media.isCameraInitialized && _media.cameraController != null) {
      final controller = _media.cameraController!;
      final previewSize = controller.value.previewSize;
      final isMobile = defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS;
      final double width = previewSize != null
          ? (isMobile ? previewSize.height : previewSize.width)
          : 480;
      final double height = previewSize != null
          ? (isMobile ? previewSize.width : previewSize.height)
          : 640;

      return ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: width,
              height: height,
              child: CameraPreview(controller),
            ),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF08201D),
      padding: const EdgeInsets.all(8),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videocam_rounded, color: Colors.white38, size: isPip ? 24 : 44),
            const SizedBox(height: 4),
            Text(
              _media.cameraError ?? 'Connecting camera…',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white54, fontSize: isPip ? 9.5 : 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ── Remote Doctor Feed Widget ──────────────────────────────────────────────
  Widget _buildDoctorFeedWidget({required bool isPip}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?auto=format&fit=crop&w=1200&q=80',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Image.network(
            'https://images.unsplash.com/photo-1537368910025-700350fe46c7?auto=format&fit=crop&w=1200&q=80',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A2E2B), Color(0xFF041715)],
                ),
              ),
              child: Center(
                child: Icon(Icons.person, size: isPip ? 36 : 90, color: Colors.white24),
              ),
            ),
          ),
        ),
        if (!isPip)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.55),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.75),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
      ],
    );
  }

  // ── Floating Draggable PiP (Tap to Swap, Drag to Reposition) ────────────────
  Widget _buildDraggablePip(Size size, EdgeInsets safe) {
    return Positioned(
      top: _pipTop,
      left: _pipLeft,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _swappedViews = !_swappedViews);
        },
        onPanUpdate: (details) {
          setState(() {
            _pipLeft = (_pipLeft + details.delta.dx)
                .clamp(8.0, size.width - _pipWidth - 8.0);
            _pipTop = (_pipTop + details.delta.dy)
                .clamp(safe.top + 8.0, size.height - _pipHeight - 160.0);
          });
        },
        child: Container(
          width: _pipWidth,
          height: _pipHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Display either live camera stream or doctor feed
              if (!_swappedViews)
                _buildLiveCameraWidget(isPip: true)
              else
                _buildDoctorFeedWidget(isPip: true),

              // Top Right: Swap icon
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),

              // Bottom Left: Tag Pill ("You" + live audio indicator or "Dr. Name")
              Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _swappedViews ? 'Dr. ${widget.receiverName}' : 'You',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!_swappedViews) ...[
                        const SizedBox(width: 4),
                        if (_muted)
                          const Icon(Icons.mic_off, size: 10, color: _vtRed)
                        else
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 100),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _media.currentAmplitude > 0.18
                                  ? _vtGreen
                                  : Colors.white38,
                              shape: BoxShape.circle,
                              boxShadow: _media.currentAmplitude > 0.18
                                  ? [
                                      BoxShadow(
                                        color: _vtGreen.withValues(alpha: 0.8),
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),

              // Bottom Right: Flip Camera 🔄 Icon (when showing local camera)
              if (!_swappedViews)
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: _flipCamera,
                    child: Container(
                      padding: const EdgeInsets.all(4.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sync_rounded,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Controls & Expandable Action Tray (1:1 mockup match) ─────────────
  Widget _buildBottomControlsAndTray(EdgeInsets safe, bool isConnected) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Primary 5 Controls (Camera, Mute, End Call, Speaker, Switch) ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _videoCircleButton(
                  icon: _cameraOn ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                  label: 'Camera',
                  active: _cameraOn,
                  onTap: _toggleCamera,
                ),
                _videoCircleButton(
                  icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                  label: 'Mute',
                  active: _muted,
                  onTap: _toggleMute,
                ),
                // Prominent Red End Call Button
                _videoEndCallButton(
                  onTap: () => _endCall(noAnswer: !isConnected && _seconds == 0),
                ),
                _videoCircleButton(
                  icon: _speaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                  label: 'Speaker',
                  active: _speaker,
                  onTap: _toggleSpeaker,
                ),
                _videoCircleButton(
                  icon: Icons.sync_rounded,
                  label: 'Switch',
                  active: false,
                  onTap: _flipCamera,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Expandable Bottom Action Tray ─────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + safe.bottom),
            decoration: const BoxDecoration(
              color: Color(0xFF0A221F),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: Color(0xFF1B423D), width: 1.2),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top expand chevron ^
                GestureDetector(
                  onTap: _showMoreOptionsSheet,
                  child: const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white54,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),

                // 4 Action Icons: Share Screen, Document, Chat, More
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _trayItem(
                      icon: Icons.desktop_windows_outlined,
                      label: 'Share Screen',
                      active: _sharingScreen,
                      onTap: _toggleScreenShare,
                    ),
                    _trayItem(
                      icon: Icons.attach_file_rounded,
                      label: 'Document',
                      active: false,
                      onTap: _showDocumentSharingSheet,
                    ),
                    _trayItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Chat',
                      active: false,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              receiverName: widget.receiverName,
                              receiverRole: widget.receiverRole,
                              receiverHospital: widget.receiverHospital,
                              isOnline: widget.isOnline,
                            ),
                          ),
                        );
                      },
                    ),
                    _trayItem(
                      icon: Icons.more_horiz_rounded,
                      label: 'More',
                      active: false,
                      onTap: _showMoreOptionsSheet,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoCircleButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: active ? _vtGreen : const Color(0xFF163834),
              shape: BoxShape.circle,
              border: Border.all(
                color: active ? _vtGreen : const Color(0xFF22524C),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoEndCallButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: _vtRed,
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
          const SizedBox(height: 5),
          const Text(
            'End Call',
            style: TextStyle(
              color: _vtRed,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trayItem({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? _vtGreen : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? _vtGreen : Colors.white70,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
