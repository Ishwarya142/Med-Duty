// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../profile/public_doctor_profile_screen.dart';
import '../../providers/settings_preferences_provider.dart';
import '../../shared/widgets/report_bottom_sheet.dart';
import 'chat_screen.dart';
import 'search_doctor_screen.dart';

const _vcTeal       = Color(0xFF0F766E);
const _vcTealDark   = Color(0xFF06211E);
const _vcBgDeep     = Color(0xFF041715);
const _vcGreen      = Color(0xFF10B981);
const _vcCyan       = Color(0xFF2DD4BF);
const _vcRed        = Color(0xFFEF4444);
const _vcOrange     = Color(0xFFF97316);
const _vcBlue       = Color(0xFF2563EB);
const _vcBtnBg      = Color(0xFF163834);
const _vcBorder     = Color(0xFF1E4540);
const _vcText       = Color(0xFFFFFFFF);
const _vcSub        = Color(0xFF94A3B8);

enum _CallState { idle, calling, ringing, connected, onHold, reconnecting, ended }
enum _AudioOutput { speaker, earpiece, bluetooth }

class VoiceCallScreen extends StatefulWidget {
  final String receiverName;
  final String receiverRole;
  final String receiverHospital;
  final String? avatarColor;
  final bool isOnline;

  const VoiceCallScreen({
    super.key,
    required this.receiverName,
    this.receiverRole = 'Cardiologist',
    this.receiverHospital = 'Max Hospital Delhi',
    this.avatarColor,
    this.isOnline = true,
  });

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen>
    with TickerProviderStateMixin {
  _CallState _state = _CallState.calling;
  int _seconds = 0;
  Timer? _timer;
  Timer? _stateTimer;

  bool _muted = false;
  bool _speaker = false;
  bool _keypadOpen = false;
  bool _isRecording = false;
  bool _aiNoiseCancellation = true;
  String _notes = '';
  _AudioOutput _selectedOutput = _AudioOutput.earpiece;

  late final AnimationController _pulse;
  late final AnimationController _ring;
  late final AnimationController _avatarFloat;
  late final AnimationController _waveformAnim;

  @override
  void initState() {
    super.initState();
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
    _waveformAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
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
    _waveformAnim.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _advanceState() {
    _stateTimer?.cancel();
    final otherOnline = widget.isOnline;
    _stateTimer = Timer(Duration(milliseconds: otherOnline ? 1400 : 1800), () {
      if (!mounted) return;
      setState(() => _state = _CallState.ringing);
      if (otherOnline) {
        _ring.repeat(reverse: true);
      }
      _stateTimer = Timer(const Duration(milliseconds: 2400), () {
        if (!mounted) return;
        final answered = otherOnline && _state == _CallState.ringing;
        if (answered) {
          setState(() => _state = _CallState.connected);
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
      case _CallState.idle:
        return '';
      case _CallState.calling:
        return 'Calling…';
      case _CallState.ringing:
        return 'Ringing…';
      case _CallState.connected:
        return 'Connected • Excellent';
      case _CallState.onHold:
        return 'Call on Hold';
      case _CallState.reconnecting:
        return 'Reconnecting…';
      case _CallState.ended:
        return 'Call ended';
    }
  }

  void _toggleMute() {
    HapticFeedback.lightImpact();
    setState(() => _muted = !_muted);
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

  void _toggleKeypad() {
    HapticFeedback.lightImpact();
    setState(() => _keypadOpen = !_keypadOpen);
  }

  void _toggleRecord() {
    HapticFeedback.mediumImpact();
    setState(() => _isRecording = !_isRecording);
    _snack(_isRecording
        ? 'Call recording started (consent logged)'
        : 'Call recording saved');
  }

  void _toggleHold() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_state == _CallState.onHold) {
        _state = _CallState.connected;
      } else if (_state == _CallState.connected) {
        _state = _CallState.onHold;
      }
    });
    _snack(_state == _CallState.onHold ? 'Call placed on hold' : 'Call resumed');
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _vcTeal,
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
      setState(() => _state = _CallState.ended);
    }
    Future.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      final duration = _seconds;
      final label = noAnswer
          ? 'Voice call • No answer'
          : 'Outgoing voice call • ${_formatDuration(duration)}';
      Navigator.of(context).pop(<String, dynamic>{
        'type': noAnswer ? 'call_missed' : 'call',
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

            // Row 1 (4 items): Hold Call, Transfer Call, Share Contact, Schedule Call
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _moreGridItem(
                  icon: _state == _CallState.onHold
                      ? Icons.play_arrow_rounded
                      : Icons.pause_rounded,
                  label: _state == _CallState.onHold ? 'Resume Call' : 'Hold Call',
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleHold();
                  },
                ),
                _moreGridItem(
                  icon: Icons.phone_forwarded_rounded,
                  label: 'Transfer Call',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showTransferCallDialog();
                  },
                ),
                _moreGridItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Share Contact',
                  onTap: () {
                    Navigator.pop(ctx);
                    _snack('${widget.receiverName}\'s contact link copied');
                  },
                ),
                _moreGridItem(
                  icon: Icons.calendar_month_outlined,
                  label: 'Schedule Call',
                  onTap: () {
                    Navigator.pop(ctx);
                    _showScheduleDialog();
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
                  iconColor: _vcRed,
                  borderColor: _vcRed.withValues(alpha: 0.5),
                  bgColor: _vcRed.withValues(alpha: 0.12),
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmBlockUser();
                  },
                ),
                _moreGridItem(
                  icon: Icons.flag_outlined,
                  label: 'Report User',
                  iconColor: _vcOrange,
                  borderColor: _vcOrange.withValues(alpha: 0.5),
                  bgColor: _vcOrange.withValues(alpha: 0.12),
                  onTap: () {
                    Navigator.pop(ctx);
                    showContentReportSheet(
                      context,
                      subjectLabel: 'Voice Call (${widget.receiverName})',
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
                color: bgColor ?? const Color(0xFF163834),
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor ?? const Color(0xFF22524C),
                  width: 1.2,
                ),
              ),
              child: Icon(icon, color: iconColor, size: 22),
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

  // ── Audio Output Device Selector Modal ──────────────────────────────────────
  void _showAudioOutputSelector() {
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
              'Select Audio Output Device',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.5,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            RadioListTile<_AudioOutput>(
              title: const Text('Speakerphone', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              secondary: const Icon(Icons.volume_up_rounded, color: _vcGreen),
              value: _AudioOutput.speaker,
              groupValue: _selectedOutput,
              activeColor: _vcGreen,
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selectedOutput = v;
                  _speaker = true;
                });
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<_AudioOutput>(
              title: const Text('Phone Earpiece', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              secondary: const Icon(Icons.phone_in_talk_rounded, color: _vcGreen),
              value: _AudioOutput.earpiece,
              groupValue: _selectedOutput,
              activeColor: _vcGreen,
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selectedOutput = v;
                  _speaker = false;
                });
                Navigator.pop(ctx);
              },
            ),
            RadioListTile<_AudioOutput>(
              title: const Text('Bluetooth Headset', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              secondary: const Icon(Icons.bluetooth_audio_rounded, color: _vcBlue),
              value: _AudioOutput.bluetooth,
              groupValue: _selectedOutput,
              activeColor: _vcGreen,
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _selectedOutput = v;
                  _speaker = false;
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Notes Sheet ─────────────────────────────────────────────────────────────
  void _showNotesSheet() {
    final noteCtrl = TextEditingController(text: _notes);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.of(ctx).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: Color(0xFF0C2421),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          border: Border(top: BorderSide(color: Color(0xFF1E4540), width: 1.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clinical Call Notes',
                  style: TextStyle(color: Colors.white, fontSize: 16.5, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _notes = noteCtrl.text);
                    Navigator.pop(ctx);
                    _snack('Consultation notes saved');
                  },
                  child: const Text('Save', style: TextStyle(color: _vcCyan, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 5,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Record patient symptoms, diagnoses, or prescriptions…',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
                filled: true,
                fillColor: const Color(0xFF163834),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF22524C)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: _vcCyan),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Transfer Call Dialog ───────────────────────────────────────────────────
  void _showTransferCallDialog() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchDoctorScreen()),
    );
  }

  // ── Schedule Dialog ────────────────────────────────────────────────────────
  void _showScheduleDialog() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    ).then((date) {
      if (date != null && mounted) {
        _snack('Follow-up scheduled for ${date.day}/${date.month}/${date.year}');
      }
    });
  }

  // ── Call Settings Dialog ───────────────────────────────────────────────────
  void _showCallSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C2421),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Call Audio Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AI Noise Cancellation', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Suppress clinical background sounds', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: _aiNoiseCancellation,
              activeColor: _vcGreen,
              onChanged: (v) {
                setState(() => _aiNoiseCancellation = v);
                Navigator.pop(ctx);
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('HD Audio Mode (Opus)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('High-definition speech clarity', style: TextStyle(color: Colors.white60, fontSize: 12)),
              value: true,
              activeColor: _vcGreen,
              onChanged: (_) {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Done', style: TextStyle(color: _vcCyan, fontWeight: FontWeight.bold)),
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
          'Blocked users cannot call or message you on MedDuty.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: _vcRed),
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
    final isConnected = _state == _CallState.connected;
    final isCalling = _state == _CallState.calling || _state == _CallState.ringing;

    final initials = widget.receiverName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .where((e) => e.isNotEmpty)
        .take(2)
        .join();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _endCall(noAnswer: _state != _CallState.connected && _seconds == 0);
      },
      child: Scaffold(
        backgroundColor: _vcBgDeep,
        body: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.35),
              radius: 1.1,
              colors: [
                Color(0xFF0C3833),
                Color(0xFF06221F),
                Color(0xFF031412),
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // ── Top Navigation Bar ─────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Minimize icon
                      IconButton(
                        tooltip: 'Minimize call',
                        onPressed: _minimize,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 28,
                        ),
                      ),

                      // End-to-end encrypted Badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.shield_outlined,
                            color: _vcGreen,
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
                          color: Colors.white70,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Recording Banner (if active) ──────────────────────────────
                if (_isRecording)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: _vcRed.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _vcRed.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: _vcRed,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'REC • In-progress',
                          style: TextStyle(
                            color: _vcRed,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Center Content: Avatar + Waveform + Info ───────────────────
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),

                        // Avatar with Waveform Brackets
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Left Waveform Bars
                            _buildWaveformBars(isLeft: true),
                            const SizedBox(width: 14),

                            // Circular Avatar with Concentric Glow Rings
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer Concentric Glow Ring
                                AnimatedBuilder(
                                  animation: _pulse,
                                  builder: (_, _) {
                                    final v = _pulse.value;
                                    return Container(
                                      width: 148 + v * 12,
                                      height: 148 + v * 12,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: _vcGreen.withValues(alpha: isCalling ? 0.45 : 0.18),
                                          width: 1.2,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                // Main Avatar Circle
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFF135A53),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.4),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      initials,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ),

                                // Online Dot on Bottom Right
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _vcGreen,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF06221F),
                                        width: 3.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 14),
                            // Right Waveform Bars
                            _buildWaveformBars(isLeft: false),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Doctor Name + Cyan Verified Checkmark
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.receiverName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: _vcCyan,
                              size: 19,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Specialty / Role
                        Text(
                          widget.receiverRole,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Status: Connected • Excellent (in Green)
                        Text(
                          _statusLabel(),
                          style: TextStyle(
                            color: _state == _CallState.onHold
                                ? _vcOrange
                                : (isConnected ? _vcGreen : Colors.white70),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Call Duration (e.g. 02:48)
                        if (isConnected || _state == _CallState.onHold)
                          Text(
                            _formatDuration(_seconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),

                        const SizedBox(height: 12),

                        // AI Noise Cancellation Pill Chip
                        if (_aiNoiseCancellation)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3A35),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _vcGreen.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.graphic_eq_rounded,
                                  color: _vcGreen,
                                  size: 15,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'AI Noise Cancellation',
                                  style: TextStyle(
                                    color: _vcGreen,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Keypad Overlay (if open)
                if (_keypadOpen) _buildKeypad(),

                // ── Primary Controls (2 Rows x 3 Columns) ──────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      // Row 1: Mute, End Call (large red), Speaker
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _controlCircleButton(
                            icon: _muted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            label: 'Mute',
                            active: _muted,
                            onTap: _toggleMute,
                          ),
                          // Prominent Red End Call Button
                          _endCallButton(
                            onTap: () => _endCall(noAnswer: !isConnected && _seconds == 0),
                          ),
                          _controlCircleButton(
                            icon: _speaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            label: 'Speaker',
                            active: _speaker,
                            onTap: _toggleSpeaker,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Row 2: Keypad, Add Call, Record
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _controlCircleButton(
                            icon: Icons.dialpad_rounded,
                            label: 'Keypad',
                            active: _keypadOpen,
                            onTap: _toggleKeypad,
                          ),
                          _controlCircleButton(
                            icon: Icons.person_add_alt_1_rounded,
                            label: 'Add Call',
                            active: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchDoctorScreen(),
                                ),
                              );
                            },
                          ),
                          _controlCircleButton(
                            icon: Icons.fiber_manual_record_rounded,
                            label: 'Record',
                            active: _isRecording,
                            activeColor: _vcRed,
                            onTap: _toggleRecord,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ── Expandable Bottom Action Tray (1:1 mockup match) ───────────
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(20, 8, 20, 16 + MediaQuery.of(context).padding.bottom),
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

                      // 4 Bottom Action Icons: Audio, Notes, Contacts, More
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _trayItem(
                            icon: Icons.headphones_rounded,
                            label: 'Audio',
                            active: true,
                            onTap: _showAudioOutputSelector,
                          ),
                          _trayItem(
                            icon: Icons.article_outlined,
                            label: 'Notes',
                            active: _notes.isNotEmpty,
                            onTap: _showNotesSheet,
                          ),
                          _trayItem(
                            icon: Icons.person_outline_rounded,
                            label: 'Contacts',
                            active: false,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SearchDoctorScreen(),
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
          ),
        ),
      ),
    );
  }

  // ── Animated Waveform Bars ──────────────────────────────────────────────────
  Widget _buildWaveformBars({required bool isLeft}) {
    final heights = [14.0, 24.0, 36.0, 48.0, 32.0, 20.0, 12.0];
    final list = isLeft ? heights : heights.reversed.toList();
    return AnimatedBuilder(
      animation: _waveformAnim,
      builder: (_, _) {
        final v = _waveformAnim.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: list.map((h) {
            final barH = (h * (0.55 + v * 0.45)).clamp(6.0, 52.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.2),
              width: 3.5,
              height: barH,
              decoration: BoxDecoration(
                color: _vcGreen.withValues(alpha: 0.7 + v * 0.3),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _controlCircleButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: active
                  ? (activeColor ?? _vcGreen).withValues(alpha: 0.22)
                  : const Color(0xFF163834),
              shape: BoxShape.circle,
              border: Border.all(
                color: active
                    ? (activeColor ?? _vcGreen)
                    : const Color(0xFF22524C),
                width: 1.2,
              ),
            ),
            child: Icon(
              icon,
              color: active ? (activeColor ?? _vcGreen) : Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _endCallButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: const BoxDecoration(
              color: _vcRed,
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
              size: 32,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'End Call',
            style: TextStyle(
              color: _vcRed,
              fontSize: 12,
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
            color: active ? _vcGreen : Colors.white70,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: active ? _vcGreen : Colors.white70,
              fontSize: 11.5,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final digits = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '0', '#'];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0C2421),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF1E4540)),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 12,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 8,
        ),
        itemBuilder: (ctx, i) {
          final d = digits[i];
          return InkWell(
            onTap: () => HapticFeedback.lightImpact(),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  d,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
