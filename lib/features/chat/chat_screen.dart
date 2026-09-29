// ignore_for_file: deprecated_member_use
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/services/profile_link_service.dart';
import '../../providers/settings_preferences_provider.dart';
import 'media_preview_screen.dart';
import 'voice_call_screen.dart';
import 'video_call_screen.dart';
import 'contact_info_screen.dart';
import 'shared_media_screen.dart';
import 'voice_message_service.dart';
import 'chat_platform_file.dart';
import '../../shared/widgets/schedule_call_bottom_sheet.dart';

const _cGreen = Color(0xFF16A34A);
const _cBlue = Color(0xFF2563EB);
const _cAmber = Color(0xFFF59E0B);
const _cRed = Color(0xFFEF4444);
const _cTeal = Color(0xFF0F766E);
const _cPurple = Color(0xFF7C3AED);
const _cOrange = Color(0xFFF97316);
const _cMintBg = Color(0xFFE6F4F1);

class _Msg {
  final String id;
  String text;
  final bool isMe;
  final String time;
  final String
  type; // text | pdf | image | video | audio | location | duty | hospital | contact | event | call | chart
  String status; // sent | delivered | read
  String? replyTo;
  List<String> reactions;
  bool isStarred;

  final String? filePath;
  final String? fileName;
  final String? fileSize;
  final String? fileExt;
  final double? audioDuration;
  final List<double>? waveform;
  final String? imageCaption;
  final String? thumbnailPath;
  final double? latitude;
  final double? longitude;
  final Map<String, dynamic>? extraData;

  _Msg({
    required this.id,
    required this.text,
    required this.isMe,
    required this.time,
    this.type = 'text',
    this.status = 'sent',
    this.replyTo,
    List<String>? reactions,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.fileExt,
    this.audioDuration,
    this.waveform,
    this.imageCaption,
    this.thumbnailPath,
    this.latitude,
    this.longitude,
    this.extraData,
  }) : reactions = reactions ?? [],
       isStarred = false;
}

class ChatScreen extends StatefulWidget {
  final String receiverName;
  final String receiverRole;
  final String receiverHospital;
  final String? avatarColor;
  final bool isOnline;
  final String? initialDraft;
  final bool sendDraftImmediately;

  const ChatScreen({
    super.key,
    required this.receiverName,
    this.receiverRole = 'Cardiologist',
    this.receiverHospital = 'Apollo Hospital',
    this.avatarColor,
    this.isOnline = true,
    this.initialDraft,
    this.sendDraftImmediately = false,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _picker = ImagePicker();
  final _searchCtrl = TextEditingController();

  bool _isTyping = false;
  bool _showEmoji = false;
  bool _showAttachTray = false;
  _Msg? _replyingTo;
  String? _playingMsgId;
  final _voiceService = VoiceMessageService();

  bool _recording = false;
  final bool _recLocked = false;
  int _recSeconds = 0;
  Timer? _recTimer;
  late final AnimationController _recPulse;

  DateTime? _muteNotifUntil;
  DateTime? _muteCallsUntil;
  bool _isBlocked = false;
  bool _searchOpen = false;
  String _searchQuery = '';
  bool _isAtBottom = true;
  bool _showPinnedBanner = true;

  _Msg? _pinnedDocument;

  late final List<_Msg> _messages = [
    _Msg(
      id: '1',
      text: 'Good morning, Dr. Doctor 👋',
      isMe: false,
      time: '9:30 AM',
      status: 'read',
    ),
    _Msg(
      id: '2',
      text: 'Can you share the latest ECG report of the patient?',
      isMe: false,
      time: '9:30 AM',
      status: 'read',
    ),
    _Msg(
      id: '3',
      text: 'Good morning, Dr. Rohan\nSure, attaching the report.',
      isMe: true,
      time: '9:31 AM',
      status: 'read',
    ),
    _Msg(
      id: '4',
      text: 'ECG_Report_patient_1245.pdf',
      isMe: true,
      time: '9:31 AM',
      type: 'pdf',
      fileName: 'ECG_Report_patient_1245.pdf',
      fileExt: 'PDF',
      fileSize: '200 KB',
      status: 'read',
    ),
    _Msg(
      id: '5',
      text: "Thanks! Also, the patient's BP trend for the past 3 days?",
      isMe: false,
      time: '9:32 AM',
      status: 'read',
    ),
    _Msg(
      id: '6',
      text: 'Here you go.',
      isMe: true,
      time: '9:33 AM',
      status: 'read',
    ),
    _Msg(
      id: '7',
      text: 'BP Trend (mmHg)',
      isMe: true,
      time: '9:33 AM',
      type: 'chart',
      fileName: 'BP_Trend_3Days.png',
      fileExt: 'PNG',
      fileSize: '180 KB',
      status: 'read',
      extraData: const <String, dynamic>{
        'isChart': true,
        'chartTitle': 'BP Trend (mmHg)',
      },
    ),
    _Msg(
      id: '8',
      text: "Perfect. Let's review in rounds.",
      isMe: false,
      time: '9:34 AM',
      status: 'read',
      reactions: ['❤️'],
    ),
    _Msg(
      id: '9',
      text: 'Sure, see you there.',
      isMe: true,
      time: '9:34 AM',
      status: 'read',
    ),
  ];

  static List<double> _sampleWave() {
    final rng = math.Random(42);
    return List.generate(24, (_) => 0.25 + rng.nextDouble() * 0.75);
  }

  @override
  void initState() {
    super.initState();
    _pinnedDocument = _messages.firstWhere(
      (m) => m.type == 'pdf',
      orElse: () => _Msg(
        id: 'pin_default',
        text: 'ECG_Report_patient_1245.pdf',
        isMe: false,
        time: '9:31 AM',
        type: 'pdf',
        fileName: 'ECG_Report_patient_1245.pdf',
        fileSize: '200 KB',
        fileExt: 'PDF',
      ),
    );

    _recPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _scrollCtrl.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncBlockedFromSettings();
      final draft = widget.initialDraft?.trim();
      if (draft != null && draft.isNotEmpty) {
        if (widget.sendDraftImmediately) {
          _send(text: draft);
        } else {
          _msgCtrl.text = draft;
          setState(() => _isTyping = true);
        }
      }
      _scrollToBottom();
    });
  }

  String get _receiverBlockId =>
      ProfileLinkService.slugFromName(widget.receiverName);

  void _syncBlockedFromSettings() {
    final settings = context.read<SettingsPreferencesProvider>();
    final blocked = settings.blockedUsers.any(
      (u) => u.id == _receiverBlockId || u.name == widget.receiverName,
    );
    if (blocked != _isBlocked && mounted) {
      setState(() => _isBlocked = blocked);
    }
  }

  Future<void> _setBlocked(bool blocked) async {
    if (_isBlocked == blocked) return;
    setState(() => _isBlocked = blocked);
    final settings = context.read<SettingsPreferencesProvider>();
    if (blocked) {
      await settings.addBlockedUser(
        BlockedUserEntry(
          id: _receiverBlockId,
          name: widget.receiverName,
          role: widget.receiverRole,
        ),
      );
    } else {
      await settings.unblockUser(_receiverBlockId);
    }
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;
    final atBottom =
        _scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 80;
    if (atBottom) {
      if (!_isAtBottom) setState(() => _isAtBottom = true);
      _markUnreadAsRead();
    } else if (_isAtBottom) {
      setState(() => _isAtBottom = false);
    }
  }

  void _markUnreadAsRead() {
    var changed = false;
    for (final m in _messages) {
      if (!m.isMe && m.status == 'delivered') {
        m.status = 'read';
        changed = true;
      }
    }
    if (changed && mounted) setState(() {});
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    _recPulse.dispose();
    _recTimer?.cancel();
    _voiceService.dispose();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m ${dt.hour >= 12 ? "PM" : "AM"}';
  }

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
  }

  void _snack(String msg, {Color bg = _cTeal}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _send({
    String type = 'text',
    String text = '',
    String? fileName,
    String? fileSize,
    String? fileExt,
    String? filePath,
    String? imageCaption,
    double? audioDuration,
    List<double>? waveform,
    String? thumbnailPath,
    double? latitude,
    double? longitude,
    Map<String, dynamic>? extraData,
  }) {
    final content = text.isNotEmpty ? text : _msgCtrl.text.trim();
    if (type == 'text' && content.isEmpty) return;

    final newMsg = _Msg(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: content,
      isMe: true,
      time: _formatTime(DateTime.now()),
      type: type,
      status: 'sent',
      replyTo: _replyingTo?.id,
      fileName: fileName,
      fileSize: fileSize,
      fileExt: fileExt,
      filePath: filePath,
      imageCaption: imageCaption,
      audioDuration: audioDuration,
      waveform: waveform,
      thumbnailPath: thumbnailPath,
      latitude: latitude,
      longitude: longitude,
      extraData: extraData,
    );

    setState(() {
      _messages.add(newMsg);
      if (type == 'text') {
        _msgCtrl.clear();
        _isTyping = false;
      }
      _replyingTo = null;
      _showAttachTray = false;
      _showEmoji = false;
    });

    // Update status to delivered/read
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() => newMsg.status = 'delivered');
      }
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) {
        setState(() => newMsg.status = 'read');
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  // ── Voice Recording ─────────────────────────────────────────────────────────
  Future<void> _startRecording() async {
    if (_isBlocked) {
      _snack('Cannot record: user is blocked', bg: _cRed);
      return;
    }
    HapticFeedback.mediumImpact();
    final started = await _voiceService.startRecording();
    if (!started || !mounted) return;
    setState(() {
      _recording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _recSeconds++);
    });
  }

  Future<void> _cancelRecording() async {
    HapticFeedback.lightImpact();
    _recTimer?.cancel();
    await _voiceService.cancelRecording();
    setState(() {
      _recording = false;
      _recSeconds = 0;
    });
    _snack('Voice message cancelled');
  }

  Future<void> _sendRecording() async {
    HapticFeedback.mediumImpact();
    _recTimer?.cancel();
    final result = await _voiceService.stopRecording();
    setState(() {
      _recording = false;
      _recSeconds = 0;
    });
    if (result == null) {
      _snack('Recording too short');
      return;
    }
    _send(
      type: 'audio',
      text: 'Voice message',
      filePath: result.path,
      audioDuration: result.durationSeconds,
      waveform: result.waveform,
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '';
    final kb = bytes / 1024;
    if (kb > 1024) return '${(kb / 1024).toStringAsFixed(1)} MB';
    return '${kb.toStringAsFixed(1)} KB';
  }

  Future<void> _pickAndPreviewMedia({
    required bool isVideo,
    required ImageSource source,
  }) async {
    final f = isVideo
        ? await _picker.pickVideo(source: source)
        : await _picker.pickImage(source: source);
    if (f == null || !mounted) return;

    final caption = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => MediaPreviewScreen(
          filePath: f.path,
          fileName: f.name,
          fileType: isVideo ? 'video' : 'image',
          canSend: true,
        ),
      ),
    );
    if (!mounted || caption == null) return;

    final size = chatLocalFileSize(f.path);
    _send(
      type: isVideo ? 'video' : 'image',
      text: isVideo ? 'Video: ${f.name}' : f.name,
      fileName: f.name,
      filePath: f.path,
      fileSize: _formatFileSize(size),
      fileExt: isVideo ? 'MP4' : f.name.split('.').last.toUpperCase(),
      imageCaption: caption.isNotEmpty ? caption : null,
    );
  }

  Future<void> _pickDocument({
    FileType type = FileType.any,
    String? label,
    List<String>? allowedExtensions,
  }) async {
    final r = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );
    if (r == null || r.files.isEmpty || !mounted) return;
    final pf = r.files.first;
    _send(
      type: pf.extension?.toLowerCase() == 'pdf'
          ? 'pdf'
          : (pf.extension ?? 'file'),
      text: pf.name,
      fileName: pf.name,
      fileExt: (pf.extension ?? 'FILE').toUpperCase(),
      fileSize: pf.size > 0 ? _formatFileSize(pf.size) : '',
      filePath: pf.path,
    );
    if (label != null) _snack('$label attached');
  }

  String _recDuration() {
    final m = (_recSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_recSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get _notificationsMuted =>
      _muteNotifUntil != null && _muteNotifUntil!.isAfter(DateTime.now());
  bool get _callsMuted =>
      _muteCallsUntil != null && _muteCallsUntil!.isAfter(DateTime.now());

  String _muteLabel(DateTime? until) {
    if (until == null || !until.isAfter(DateTime.now())) return '';
    final diff = until.difference(DateTime.now());
    if (diff.inDays >= 7) return 'Always';
    if (diff.inHours >= 24) return '${diff.inDays}d left';
    if (diff.inHours >= 1) return '${diff.inHours}h left';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m left';
    return 'Muted';
  }

  Widget _highlight(String text, Color baseColor) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) {
      return Text(text, style: TextStyle(color: baseColor));
    }
    final spans = <TextSpan>[];
    final lower = text.toLowerCase();
    int idx = 0;
    while (idx < text.length) {
      final pos = lower.indexOf(q, idx);
      if (pos == -1) {
        spans.add(
          TextSpan(
            text: text.substring(idx),
            style: TextStyle(color: baseColor),
          ),
        );
        break;
      }
      if (pos > idx) {
        spans.add(
          TextSpan(
            text: text.substring(idx, pos),
            style: TextStyle(color: baseColor),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: text.substring(pos, pos + q.length),
          style: TextStyle(
            color: baseColor,
            backgroundColor: _cAmber.withValues(alpha: 0.35),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
      idx = pos + q.length;
    }
    return RichText(
      text: TextSpan(children: spans, style: const TextStyle(fontSize: 13.5)),
    );
  }

  bool _msgMatches(_Msg m) {
    final q = _searchQuery.trim().toLowerCase();
    if (q.isEmpty) return true;
    if (m.text.toLowerCase().contains(q)) return true;
    if ((m.fileName ?? '').toLowerCase().contains(q)) return true;
    if ((m.imageCaption ?? '').toLowerCase().contains(q)) return true;
    return false;
  }

  List<SharedMediaItem> _sharedMediaItems() {
    return _messages
        .map(
          (m) => SharedMediaItem(
            id: m.id,
            type: m.type,
            text: m.text,
            time: m.time,
            isMe: m.isMe,
            fileName: m.fileName,
            fileSize: m.fileSize,
            fileExt: m.fileExt,
            filePath: m.filePath,
            imageCaption: m.imageCaption,
            extraData: m.extraData,
          ),
        )
        .toList();
  }

  void _openSharedMedia({int initialTab = 0, String? title}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SharedMediaScreen(
          items: _sharedMediaItems(),
          initialTab: initialTab,
          title: title ?? 'Media, links & documents',
        ),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final initials = _initials(widget.receiverName);

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      appBar: _searchOpen
          ? _buildSearchAppBar(bg, tx, sub)
          : _buildAppBar(isDark, bg, tx, sub, initials),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (_pinnedDocument != null && _showPinnedBanner && !_searchOpen)
              _buildPinnedBanner(card, border, tx, sub),
            if (!_searchOpen && !_showPinnedBanner) _encryptionBanner(),
            if (_isBlocked) _buildBlockedBanner(tx, sub),
            Expanded(child: _buildMessageList(tx, sub, card, border)),
            if (_isBlocked)
              _buildBlockedComposer(bg, tx, sub)
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingTo != null) _buildReplyBanner(tx, sub, border),
                  if (_recording)
                    _buildVoiceBar(tx, sub)
                  else ...[
                    _buildComposer(card, border, tx, sub),
                    if (_showAttachTray)
                      _buildQuickActionTray(card, border, tx, sub),
                    if (_showEmoji) _buildEmojiPicker(),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Header AppBar ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    bool isDark,
    Color bg,
    Color tx,
    Color sub,
    String initials,
  ) {
    final notifMuted = _notificationsMuted;
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: tx),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ContactInfoScreen(
                name: widget.receiverName,
                role: widget.receiverRole,
                avatarColor: widget.avatarColor,
                isOnline: widget.isOnline,
                photoCount: _messages.where((m) => m.type == 'image').length,
                videoCount: _messages.where((m) => m.type == 'video').length,
                docCount: _messages
                    .where(
                      (m) =>
                          m.type == 'pdf' ||
                          m.fileExt != null && m.fileExt!.isNotEmpty,
                    )
                    .length,
                linkCount: _messages.where((m) => m.type == 'link').length,
                starredCount: _messages.where((m) => m.isStarred).length,
                isBlocked: _isBlocked,
                onToggleBlock: (v) => _setBlocked(v),
                onMessage: () => Navigator.pop(context),
                onOpenSharedMedia: _openSharedMedia,
              ),
            ),
          );
        },
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: widget.avatarColor != null
                      ? Color(int.parse(widget.avatarColor!))
                      : _cTeal,
                  child: Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10.5,
                    height: 10.5,
                    decoration: BoxDecoration(
                      color: widget.isOnline ? _cGreen : Colors.grey,
                      shape: BoxShape.circle,
                      border: Border.all(color: bg, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.receiverName,
                          style: TextStyle(
                            color: tx,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.verified_rounded,
                        color: _cBlue,
                        size: 14,
                      ),
                      if (notifMuted) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.notifications_off_rounded,
                          color: _cAmber,
                          size: 13,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    '${widget.receiverRole} • ${widget.receiverHospital}',
                    style: TextStyle(
                      color: sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    widget.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      color: widget.isOnline ? _cGreen : sub,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Voice Call',
          icon: Icon(
            Icons.call_rounded,
            color: _isBlocked ? sub.withValues(alpha: 0.45) : _cTeal,
            size: 21,
          ),
          onPressed: _isBlocked || _callsMuted
              ? () => _snack(
                  _callsMuted
                      ? 'Calls are muted (${_muteLabel(_muteCallsUntil)})'
                      : 'You have blocked this user',
                  bg: _cAmber,
                )
              : () async {
                  HapticFeedback.lightImpact();
                  final r = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => VoiceCallScreen(
                            receiverName: widget.receiverName,
                            receiverRole: widget.receiverRole,
                            avatarColor: widget.avatarColor,
                            isOnline: widget.isOnline,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                  if (r != null && r['label'] != null && mounted) {
                    final noAnswer = r['noAnswer'] == true;
                    _send(
                      type: noAnswer ? 'call_missed' : 'call',
                      text: r['label'].toString(),
                      extraData: <String, dynamic>{
                        'duration': r['duration'] ?? 0,
                        'noAnswer': noAnswer,
                      },
                    );
                  }
                },
        ),
        IconButton(
          tooltip: 'Video Call',
          icon: Icon(
            Icons.videocam_rounded,
            color: _isBlocked ? sub.withValues(alpha: 0.45) : _cTeal,
            size: 23,
          ),
          onPressed: _isBlocked || _callsMuted
              ? () => _snack(
                  _callsMuted
                      ? 'Calls are muted (${_muteLabel(_muteCallsUntil)})'
                      : 'You have blocked this user',
                  bg: _cAmber,
                )
              : () async {
                  HapticFeedback.lightImpact();
                  final r = await Navigator.of(context)
                      .push<Map<String, dynamic>>(
                        MaterialPageRoute(
                          builder: (_) => VideoCallScreen(
                            receiverName: widget.receiverName,
                            receiverRole: widget.receiverRole,
                            avatarColor: widget.avatarColor,
                            isOnline: widget.isOnline,
                          ),
                          fullscreenDialog: true,
                        ),
                      );
                  if (r != null && r['label'] != null && mounted) {
                    final noAnswer = r['noAnswer'] == true;
                    _send(
                      type: noAnswer ? 'video_call_missed' : 'video_call',
                      text: r['label'].toString(),
                      extraData: <String, dynamic>{
                        'duration': r['duration'] ?? 0,
                        'noAnswer': noAnswer,
                      },
                    );
                  }
                },
        ),
        IconButton(
          tooltip: 'Options',
          icon: Icon(Icons.more_vert_rounded, color: tx, size: 21),
          onPressed: _showChatMenu,
        ),
        IconButton(
          tooltip: 'Schedule Call',
          icon: Icon(
            Icons.event_available_rounded,
            color: _isBlocked ? sub.withValues(alpha: 0.45) : _cTeal,
            size: 22,
          ),
          onPressed: _isBlocked || _callsMuted
              ? () => _snack(
                  _callsMuted
                      ? 'Calls are muted (${_muteLabel(_muteCallsUntil)})'
                      : 'You have blocked this user',
                  bg: _cAmber,
                )
              : () {
                  HapticFeedback.selectionClick();
                  _showSchedulePicker();
                },
        ),
        const SizedBox(width: 2),
      ],
    );
  }

  // ── Search AppBar ───────────────────────────────────────────────────────────
  PreferredSizeWidget _buildSearchAppBar(Color bg, Color tx, Color sub) {
    final matches = _searchQuery.trim().isEmpty
        ? 0
        : _messages.where(_msgMatches).length;
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        tooltip: 'Close search',
        icon: Icon(Icons.arrow_back_rounded, color: tx),
        onPressed: () {
          setState(() {
            _searchOpen = false;
            _searchQuery = '';
            _searchCtrl.clear();
          });
        },
      ),
      titleSpacing: 0,
      title: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: (v) => setState(() => _searchQuery = v),
        style: TextStyle(color: tx, fontSize: 14.5),
        decoration: InputDecoration(
          hintText: 'Search in conversation…',
          hintStyle: TextStyle(color: sub, fontSize: 14),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
      actions: [
        if (_searchQuery.isNotEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Text(
                '$matches match${matches == 1 ? '' : 'es'}',
                style: const TextStyle(
                  color: _cTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: tx),
          onPressed: () {
            _searchCtrl.clear();
            setState(() => _searchQuery = '');
          },
        ),
      ],
    );
  }

  // ── Pinned Document Banner ──────────────────────────────────────────────────
  Widget _buildPinnedBanner(Color card, Color border, Color tx, Color sub) {
    if (_pinnedDocument == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () =>
              _snack('Opening pinned file: ${_pinnedDocument!.fileName}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.push_pin_rounded, color: _cTeal, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pinned: ${_pinnedDocument!.fileName}',
                        style: TextStyle(
                          color: tx,
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '${_pinnedDocument!.fileSize} • ${_pinnedDocument!.fileExt}',
                        style: TextStyle(color: sub, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: sub, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _encryptionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _cTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cTeal.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_rounded, color: _cTeal, size: 14),
          SizedBox(width: 6),
          Text(
            'Messages are end-to-end encrypted',
            style: TextStyle(
              color: _cTeal,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedBanner(Color tx, Color sub) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _cRed.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _cRed.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Icon(Icons.block_rounded, color: _cRed, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have blocked ${widget.receiverName}',
                  style: TextStyle(
                    color: tx,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "They can't message or call you.",
                  style: TextStyle(color: sub, fontSize: 11.5),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _setBlocked(false);
              _snack('User unblocked');
            },
            child: const Text(
              'Unblock',
              style: TextStyle(
                color: _cTeal,
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedComposer(Color bg, Color tx, Color sub) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        14,
        10,
        14,
        10 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border(top: BorderSide(color: sub.withValues(alpha: 0.2))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Messages and calls are disabled because you blocked this user.',
                style: TextStyle(
                  color: sub,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () {
                _setBlocked(false);
                _snack('User unblocked');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: _cRed,
                side: BorderSide(color: _cRed.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.lock_open_rounded, size: 16),
              label: const Text(
                'Unblock',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Message List View ───────────────────────────────────────────────────────
  Widget _buildMessageList(Color tx, Color sub, Color card, Color border) {
    final searching = _searchOpen && _searchQuery.trim().isNotEmpty;
    final visible = searching
        ? _messages.asMap().entries.where((e) => _msgMatches(e.value)).map((e) {
            return MapEntry(e.key, e.value);
          }).toList()
        : _messages
              .asMap()
              .entries
              .map((e) => MapEntry(e.key, e.value))
              .toList();

    final totalItems = visible.length + 1;
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
      itemCount: totalItems,
      itemBuilder: (ctx, i) {
        if (i == 0) {
          return _dateDivider(searching ? 'Search results' : 'Today', sub);
        }
        final idx = i - 1;
        if (idx < 0 || idx >= visible.length) {
          return const SizedBox.shrink();
        }
        final msgIdx = visible[idx].key;
        final msg = visible[idx].value;

        return _buildBubble(
          msg,
          msgIdx,
          tx,
          sub,
          card,
          border,
          highlight: searching,
        );
      },
    );
  }

  // ── Date Divider ────────────────────────────────────────────────────────────
  Widget _dateDivider(String label, Color sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: sub.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: sub,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Message Bubble Dispatcher ───────────────────────────────────────────────
  Widget _buildBubble(
    _Msg msg,
    int idx,
    Color tx,
    Color sub,
    Color card,
    Color border, {
    bool highlight = false,
  }) {
    final isMe = msg.isMe;
    final rad = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    _Msg? replyMsg;
    if (msg.replyTo != null) {
      try {
        replyMsg = _messages.firstWhere((m) => m.id == msg.replyTo);
      } catch (_) {}
    }

    Widget bubble;
    switch (msg.type) {
      case 'audio':
        bubble = _audioBubble(msg, idx, isMe, rad, tx, sub, card, border);
        break;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'xls':
      case 'xlsx':
      case 'file':
        bubble = _docBubble(msg, isMe, rad, tx, sub, card, border);
        break;
      case 'chart':
        bubble = _chartBubble(msg, isMe, rad, tx, sub, card, border);
        break;
      case 'image':
        bubble = _imageBubble(msg, isMe, rad, tx, sub);
        break;
      case 'video':
        bubble = _videoBubble(msg, isMe, rad, tx, sub);
        break;
      case 'location':
        bubble = _locationBubble(msg, isMe, rad, tx, sub, card, border);
        break;
      case 'call':
      case 'call_missed':
      case 'video_call':
      case 'video_call_missed':
        bubble = _callBubble(msg, isMe, rad, tx, sub, card, border);
        break;
      case 'event':
        bubble = _eventBubble(msg, isMe, rad, tx, sub, card, border);
        break;
      default:
        bubble = _textBubble(
          msg,
          isMe,
          rad,
          tx,
          sub,
          card,
          border,
          highlight: highlight,
          replyMsg: replyMsg,
        );
    }

    final child = Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: bubble,
          ),
          if (msg.reactions.isNotEmpty) _reactionRow(msg, isMe),
        ],
      ),
    );

    return GestureDetector(
      onLongPress: () {
        HapticFeedback.mediumImpact();
        _showMsgMenu(msg, idx);
      },
      child: child,
    );
  }

  // ── Text Bubble ─────────────────────────────────────────────────────────────
  Widget _textBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border, {
    bool highlight = false,
    _Msg? replyMsg,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isMe
        ? (isDark ? _cTeal : _cMintBg)
        : (isDark ? card : Colors.white);
    final textColor = isMe
        ? (isDark ? Colors.white : const Color(0xFF0F766E))
        : tx;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.76,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: rad,
          border: isMe ? null : Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (replyMsg != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _inlineReplyQuote(replyMsg, isMe, isDark),
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: highlight
                  ? _highlight(msg.text, textColor)
                  : Text(
                      msg.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14.5,
                        height: 1.4,
                        fontWeight: isMe ? FontWeight.w500 : FontWeight.normal,
                      ),
                    ),
            ),
            const SizedBox(height: 3),
            _statusRow(msg, isMe, sub),
          ],
        ),
      ),
    );
  }

  Widget _inlineReplyQuote(_Msg replied, bool isMe, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _cTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(left: BorderSide(color: _cTeal, width: 3)),
      ),
      child: Text(
        replied.text,
        style: const TextStyle(
          color: _cTeal,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  // ── Document / PDF Bubble ───────────────────────────────────────────────────
  Widget _docBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isMe
        ? (isDark ? _cTeal : _cMintBg)
        : (isDark ? card : Colors.white);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: rad,
          border: isMe ? null : Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: _cRed,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        msg.fileName ?? msg.text,
                        style: TextStyle(
                          color: tx,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${msg.fileSize ?? '200 KB'} • ${msg.fileExt ?? 'PDF'}',
                        style: TextStyle(color: sub, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: _statusRow(msg, isMe, sub),
            ),
          ],
        ),
      ),
    );
  }

  // ── BP Trend / Clinical Chart Bubble ────────────────────────────────────────
  Widget _chartBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isDark ? card : Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.78,
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: rad,
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'BP Trend (mmHg)',
                style: TextStyle(
                  color: tx,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Mock clinical chart lines
            SizedBox(
              height: 110,
              child: CustomPaint(
                size: const Size(double.infinity, 110),
                painter: _BpChartPainter(isDark: isDark),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _cTeal,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('Systolic', style: TextStyle(color: sub, fontSize: 10)),
                const SizedBox(width: 14),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: _cBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text('Diastolic', style: TextStyle(color: sub, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: _statusRow(msg, isMe, sub),
            ),
          ],
        ),
      ),
    );
  }

  // ── Image Bubble ────────────────────────────────────────────────────────────
  Widget _imageBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MediaPreviewScreen(
                filePath: msg.filePath,
                fileName: msg.fileName ?? 'Image',
                fileType: 'image',
                canSend: false,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: rad,
          child: Stack(
            children: [
              chatBuildLocalImage(
                msg.filePath,
                height: 180,
                placeholder: Container(
                  height: 180,
                  color: _cTeal.withValues(alpha: 0.12),
                  child: Center(
                    child: Icon(
                      Icons.image_rounded,
                      color: _cTeal.withValues(alpha: 0.4),
                      size: 54,
                    ),
                  ),
                ),
              ),
              if (msg.imageCaption != null && msg.imageCaption!.isNotEmpty)
                Positioned(
                  bottom: 26,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      msg.imageCaption!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _tickIcon(msg.status, Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Video Bubble ────────────────────────────────────────────────────────────
  Widget _videoBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MediaPreviewScreen(
                filePath: msg.filePath,
                fileName: msg.fileName ?? 'Video',
                fileType: 'video',
                canSend: false,
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: rad,
          child: Stack(
            children: [
              Container(
                height: 180,
                color: Colors.black87,
                child: Center(
                  child: Icon(
                    Icons.video_library_rounded,
                    color: Colors.white.withValues(alpha: 0.5),
                    size: 54,
                  ),
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.time,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 4),
                        _tickIcon(msg.status, Colors.white),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Audio / Voice Bubble ────────────────────────────────────────────────────
  Widget _audioBubble(
    _Msg msg,
    int idx,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final isPlaying = _playingMsgId == msg.id;
    final dur = msg.audioDuration ?? 0;
    final wave = msg.waveform ?? _sampleWave();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bubbleColor = isMe
        ? (isDark ? _cTeal : _cMintBg)
        : (isDark ? card : Colors.white);

    return Container(
      width: MediaQuery.of(context).size.width * 0.68,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: rad,
        border: isMe ? null : Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  if (chatLocalFileExists(msg.filePath)) {
                    await _voiceService.togglePlayback(
                      messageId: msg.id,
                      path: msg.filePath!,
                      onStateChanged: (playing) {
                        if (mounted) {
                          setState(
                            () => _playingMsgId = playing ? msg.id : null,
                          );
                        }
                      },
                    );
                  } else {
                    setState(() => _playingMsgId = isPlaying ? null : msg.id);
                  }
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _cTeal.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _cTeal,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _waveform(wave, isPlaying)),
              const SizedBox(width: 8),
              Text(
                dur > 0 ? '${dur.toInt()}s' : '0:14',
                style: TextStyle(color: sub, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerRight,
            child: _statusRow(msg, isMe, sub),
          ),
        ],
      ),
    );
  }

  Widget _waveform(List<double> bars, bool playing) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: bars.asMap().entries.map((e) {
          return Container(
            width: 2.5,
            height: 4 + e.value * 18,
            decoration: BoxDecoration(
              color: playing ? _cTeal : _cTeal.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Location Bubble ─────────────────────────────────────────────────────────
  Widget _locationBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      child: GestureDetector(
        onTap: () => _snack('Opening map for: ${msg.text}'),
        child: Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: rad,
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _cGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.vertical(top: rad.topLeft),
                ),
                child: const Center(
                  child: Icon(
                    Icons.location_on_rounded,
                    color: _cOrange,
                    size: 42,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Location',
                      style: TextStyle(
                        color: tx,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      msg.text,
                      style: TextStyle(color: sub, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _statusRow(msg, isMe, sub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Call Log Bubble ─────────────────────────────────────────────────────────
  Widget _callBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final isVideo = msg.type == 'video_call' || msg.type == 'video_call_missed';
    final missed = msg.type == 'call_missed' || msg.type == 'video_call_missed';
    final accent = missed ? _cRed : _cTeal;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: accent.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                missed
                    ? (isVideo
                          ? Icons.videocam_off_rounded
                          : Icons.phone_missed_rounded)
                    : (isVideo
                          ? Icons.videocam_rounded
                          : Icons.phone_in_talk_rounded),
                color: accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                '${msg.text}  •  ${msg.time}',
                style: TextStyle(
                  color: tx,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _eventBubble(
    _Msg msg,
    bool isMe,
    BorderRadius rad,
    Color tx,
    Color sub,
    Color card,
    Color border,
  ) {
    final accent = isMe ? Colors.white : _cTeal;
    final accentText = isMe ? Colors.white : _cTeal;
    final ex = msg.extraData ?? <String, dynamic>{};
    final scheduleType = ex['scheduleType'] as String? ?? 'videoCall';
    final dateLabel = ex['dateLabel'] as String? ?? '';
    final timeLabel = ex['timeLabel'] as String? ?? '';
    final eventTitle = ex['title'] as String? ?? 'Scheduled event';

    IconData eventIcon = Icons.event_available_rounded;
    if (scheduleType == 'voiceCall') eventIcon = Icons.call_rounded;
    if (scheduleType == 'videoCall') eventIcon = Icons.videocam_rounded;
    if (scheduleType == 'consultation')
      eventIcon = Icons.medical_services_rounded;
    if (scheduleType == 'interview') eventIcon = Icons.work_outline_rounded;

    return Container(
      width: 280,
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        color: isMe ? _cTeal : card,
        borderRadius: rad,
        border: Border.all(color: isMe ? _cTeal : border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.18)
                        : _cTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(eventIcon, color: accent, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        eventTitle,
                        style: TextStyle(
                          color: isMe ? Colors.white : tx,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Scheduled event',
                        style: TextStyle(
                          color: isMe
                              ? Colors.white.withValues(alpha: 0.75)
                              : sub,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: isMe ? Colors.white.withValues(alpha: 0.14) : _cMintBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time_rounded, color: accent, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$dateLabel  ·  $timeLabel',
                      style: TextStyle(
                        color: isMe ? Colors.white : accentText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _statusRow(
              msg,
              isMe,
              isMe ? Colors.white.withValues(alpha: 0.7) : sub,
            ),
          ],
        ),
      ),
    );
  }

  // ── Reactions Row ───────────────────────────────────────────────────────────
  Widget _reactionRow(_Msg msg, bool isMe) {
    return Container(
      margin: EdgeInsets.only(top: 2, left: isMe ? 0 : 8, right: isMe ? 8 : 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: msg.reactions.toSet().map((e) {
          final count = msg.reactions.where((r) => r == e).length;
          return Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(e, style: const TextStyle(fontSize: 12)),
                if (count > 1) ...[
                  const SizedBox(width: 2),
                  Text(
                    '$count',
                    style: const TextStyle(
                      color: _cTeal,
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Timestamp & Tick Row ────────────────────────────────────────────────────
  Widget _statusRow(_Msg msg, bool isMe, Color sub) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          msg.time,
          style: TextStyle(
            color: sub,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (msg.isStarred) ...[
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: _cAmber, size: 12),
        ],
        if (isMe) ...[const SizedBox(width: 4), _tickIcon(msg.status, sub)],
      ],
    );
  }

  Widget _tickIcon(String status, Color fallback) {
    if (status == 'read') {
      return const Icon(Icons.done_all_rounded, color: _cBlue, size: 14);
    }
    if (status == 'delivered') {
      return Icon(Icons.done_all_rounded, color: fallback, size: 14);
    }
    return Icon(Icons.done_rounded, color: fallback, size: 14);
  }

  // ── Modern Message Composer ─────────────────────────────────────────────────
  Widget _buildComposer(Color card, Color border, Color tx, Color sub) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: card,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // [+] Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _showAttachTray = !_showAttachTray;
                if (_showAttachTray) _showEmoji = false;
              });
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _showAttachTray ? _cTeal : sub.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _showAttachTray ? Icons.close_rounded : Icons.add_rounded,
                color: _showAttachTray ? Colors.white : tx,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Text Field Container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: sub.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(width: 14),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      style: TextStyle(color: tx, fontSize: 14.5),
                      maxLines: 4,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: sub, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _isTyping = v.trim().isNotEmpty;
                          if (_isTyping) {
                            _showEmoji = false;
                            _showAttachTray = false;
                          }
                        });
                      },
                      onSubmitted: (_) {
                        if (_isTyping) _send();
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _showEmoji
                          ? Icons.keyboard_rounded
                          : Icons.sentiment_satisfied_alt_rounded,
                      color: sub,
                      size: 21,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        _showEmoji = !_showEmoji;
                        if (_showEmoji) _showAttachTray = false;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined, color: sub, size: 21),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () => _pickAndPreviewMedia(
                      isVideo: false,
                      source: ImageSource.camera,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Send / Voice Button
          GestureDetector(
            onTap: _isTyping ? _send : null,
            onLongPressStart: _isTyping ? null : (_) => _startRecording(),
            onLongPressEnd: _isTyping
                ? null
                : (_) {
                    if (_recording && !_recLocked) _sendRecording();
                  },
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _cTeal,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isTyping ? Icons.send_rounded : Icons.mic_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Quick Action Tray (Attachment Tray) ─────────────────────────────────────
  Widget _buildQuickActionTray(Color card, Color border, Color tx, Color sub) {
    final actions = [
      (
        Icons.attach_file_rounded,
        'Attachment',
        _cTeal,
        () {
          setState(() => _showAttachTray = false);
          _pickDocument();
        },
      ),
      (
        Icons.camera_alt_rounded,
        'Camera',
        _cBlue,
        () {
          setState(() => _showAttachTray = false);
          _pickAndPreviewMedia(isVideo: false, source: ImageSource.camera);
        },
      ),
      (
        Icons.photo_library_rounded,
        'Gallery',
        _cPurple,
        () {
          setState(() => _showAttachTray = false);
          _pickAndPreviewMedia(isVideo: false, source: ImageSource.gallery);
        },
      ),
      (
        Icons.description_rounded,
        'Document',
        _cAmber,
        () {
          setState(() => _showAttachTray = false);
          _pickDocument(
            type: FileType.custom,
            allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
          );
        },
      ),
      (
        Icons.location_on_rounded,
        'Location',
        _cGreen,
        () {
          setState(() => _showAttachTray = false);
          _showLocationPicker();
        },
      ),
      (
        Icons.mic_rounded,
        'Voice',
        _cRed,
        () {
          setState(() => _showAttachTray = false);
          _startRecording();
        },
      ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((act) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              act.$4();
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: act.$3.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(act.$1, color: act.$3, size: 22),
                ),
                const SizedBox(height: 6),
                Text(
                  act.$2,
                  style: TextStyle(
                    color: tx,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Voice Bar Recording UI ──────────────────────────────────────────────────
  Widget _buildVoiceBar(Color tx, Color sub) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _cTeal.withValues(alpha: 0.08),
        border: Border(top: BorderSide(color: _cTeal.withValues(alpha: 0.2))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _cRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: _cRed,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          AnimatedBuilder(
            animation: _recPulse,
            builder: (_, _) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _cRed.withValues(alpha: 0.5 + _recPulse.value * 0.5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _recDuration(),
            style: const TextStyle(
              color: _cRed,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Recording voice note...',
              style: TextStyle(color: _cTeal, fontSize: 12),
            ),
          ),
          GestureDetector(
            onTap: _sendRecording,
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: _cTeal,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reply Banner ────────────────────────────────────────────────────────────
  Widget _buildReplyBanner(Color tx, Color sub, Color border) {
    final r = _replyingTo!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _cTeal.withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(
          top: BorderSide(color: _cTeal.withValues(alpha: 0.3)),
          left: const BorderSide(color: _cTeal, width: 3),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.reply_rounded, color: _cTeal, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  r.isMe
                      ? 'Replying to yourself'
                      : 'Replying to ${widget.receiverName}',
                  style: const TextStyle(
                    color: _cTeal,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  r.text,
                  style: TextStyle(color: sub, fontSize: 11.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: sub, size: 18),
            onPressed: () => setState(() => _replyingTo = null),
          ),
        ],
      ),
    );
  }

  // ── Emoji Picker ────────────────────────────────────────────────────────────
  Widget _buildEmojiPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : const Color(0xFFF2F2F2);
    final ios = foundation.defaultTargetPlatform == TargetPlatform.iOS;
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        textEditingController: _msgCtrl,
        onEmojiSelected: (c, e) {
          setState(() => _isTyping = _msgCtrl.text.trim().isNotEmpty);
        },
        onBackspacePressed: () {
          setState(() => _isTyping = _msgCtrl.text.trim().isNotEmpty);
        },
        config: Config(
          height: 250,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 * (ios ? 1.20 : 1.0),
            columns: 7,
            verticalSpacing: 0,
            horizontalSpacing: 0,
            gridPadding: EdgeInsets.zero,
            recentsLimit: 28,
            noRecents: const Text(
              'No Recents',
              style: TextStyle(fontSize: 20, color: Colors.black26),
              textAlign: TextAlign.center,
            ),
          ),
          skinToneConfig: const SkinToneConfig(
            enabled: true,
            dialogBackgroundColor: Colors.white,
            indicatorColor: Colors.grey,
          ),
          categoryViewConfig: const CategoryViewConfig(
            indicatorColor: _cTeal,
            iconColor: Colors.grey,
            iconColorSelected: _cTeal,
            backspaceColor: _cTeal,
            tabIndicatorAnimDuration: kTabScrollDuration,
            categoryIcons: CategoryIcons(),
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            enabled: true,
            backgroundColor: bg,
            buttonColor: _cTeal,
            buttonIconColor: Colors.white,
            showBackspaceButton: true,
          ),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }

  // ── Location Picker Dialog ──────────────────────────────────────────────────
  Future<void> _showLocationPicker() async {
    var lat = 28.6139;
    var lng = 77.2090;

    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude;
        lng = pos.longitude;
      }
    } catch (_) {}

    _send(
      type: 'location',
      text:
          'Apollo Hospital, Main Block (${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)})',
      latitude: lat,
      longitude: lng,
    );
    _snack('Location shared');
  }

  // ── Long-press message menu ─────────────────────────────────────────────────
  void _showMsgMenu(_Msg msg, int idx) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const emojis = ['❤️', '👍', '🙏', '👏', '😂', '😮'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: emojis.map((e) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (msg.reactions.contains(e)) {
                          msg.reactions.remove(e);
                        } else {
                          msg.reactions.add(e);
                        }
                      });
                      Navigator.pop(context);
                      _snack('Reacted with $e');
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: msg.reactions.contains(e)
                            ? _cTeal.withValues(alpha: 0.15)
                            : sub.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(e, style: const TextStyle(fontSize: 20)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.reply_rounded, color: _cTeal),
              title: Text('Reply', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _replyingTo = msg);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_rounded, color: _cBlue),
              title: Text('Copy', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: msg.text));
                _snack('Copied to clipboard');
              },
            ),
            ListTile(
              leading: Icon(
                msg.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                color: _cAmber,
              ),
              title: Text(
                msg.isStarred ? 'Unstar message' : 'Star message',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                setState(() => msg.isStarred = !msg.isStarred);
                Navigator.pop(context);
                _snack(msg.isStarred ? '⭐ Starred' : 'Unstarred');
              },
            ),
            if (msg.type == 'pdf' || msg.type == 'doc')
              ListTile(
                leading: const Icon(Icons.push_pin_rounded, color: _cTeal),
                title: Text(
                  'Pin document to chat',
                  style: TextStyle(color: tx),
                ),
                onTap: () {
                  setState(() {
                    _pinnedDocument = msg;
                    _showPinnedBanner = true;
                  });
                  Navigator.pop(context);
                  _snack('Document pinned to header');
                },
              ),
            if (msg.isMe)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: _cRed),
                title: const Text(
                  'Delete message',
                  style: TextStyle(color: _cRed),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() => _messages.removeAt(idx));
                  _snack('Message deleted', bg: _cRed);
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Overflow Chat Menu ──────────────────────────────────────────────────────
  void _showChatMenu() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.search_rounded, color: _cTeal),
              title: Text(
                'Search in conversation',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _searchOpen = true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.perm_media_rounded, color: _cBlue),
              title: Text(
                'Shared media & reports',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                _openSharedMedia();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_rounded, color: _cTeal),
              title: Text('Schedule voice call', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _showSchedulePicker(type: ScheduleCallType.voiceCall);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_rounded, color: _cGreen),
              title: Text('Schedule video call', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _showSchedulePicker(type: ScheduleCallType.videoCall);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.medical_services_outlined,
                color: _cPurple,
              ),
              title: Text('Schedule consultation', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _showSchedulePicker(type: ScheduleCallType.consultation);
              },
            ),
            ListTile(
              leading: Icon(
                _showPinnedBanner
                    ? Icons.visibility_off_rounded
                    : Icons.push_pin_rounded,
                color: _cAmber,
              ),
              title: Text(
                _showPinnedBanner ? 'Hide pinned banner' : 'Show pinned banner',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _showPinnedBanner = !_showPinnedBanner);
              },
            ),
            ListTile(
              leading: Icon(
                _notificationsMuted
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_off_rounded,
                color: _cPurple,
              ),
              title: Text(
                _notificationsMuted
                    ? 'Unmute notifications'
                    : 'Mute notifications',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _muteNotifUntil = _notificationsMuted
                      ? null
                      : DateTime.now().add(const Duration(days: 7));
                });
                _snack(
                  _notificationsMuted
                      ? 'Notifications muted'
                      : 'Notifications unmuted',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded, color: _cRed),
              title: Text(
                _isBlocked
                    ? 'Unblock ${widget.receiverName}'
                    : 'Block ${widget.receiverName}',
                style: const TextStyle(color: _cRed),
              ),
              onTap: () {
                Navigator.pop(context);
                _setBlocked(!_isBlocked);
                _snack(
                  _isBlocked ? 'User blocked' : 'User unblocked',
                  bg: _cRed,
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showSchedulePicker({
    ScheduleCallType type = ScheduleCallType.videoCall,
  }) {
    ScheduleCallBottomSheet.show(
      context: context,
      callType: type,
      contactName: widget.receiverName,
      contactImage: null,
      onSchedule: (scheduledTime, callType, title) async {
        if (!mounted) return;
        final now = DateTime.now();
        final diffDays = scheduledTime.difference(now).inDays;
        final diffHours = scheduledTime.difference(now).inHours;
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        final dateStr =
            '${weekdays[scheduledTime.weekday % 7]}, ${months[scheduledTime.month - 1]} ${scheduledTime.day}';
        final hh = (scheduledTime.hour % 12) == 0
            ? 12
            : (scheduledTime.hour % 12);
        final ampm = scheduledTime.hour >= 12 ? 'PM' : 'AM';
        final timeStr =
            '$hh:${scheduledTime.minute.toString().padLeft(2, '0')} $ampm';
        final when = diffDays < 1
            ? (diffHours < 1 ? 'in less than 1 hour' : 'in $diffHours hours')
            : 'in $diffDays days';

        final eventTitle = title.isEmpty
            ? switch (callType) {
                ScheduleCallType.videoCall => 'Video call',
                ScheduleCallType.voiceCall => 'Voice call',
                ScheduleCallType.interview => 'Interview',
                ScheduleCallType.consultation => 'Consultation',
              }
            : title;

        _send(
          type: 'event',
          text: '$eventTitle scheduled for $dateStr · $timeStr',
          extraData: <String, dynamic>{
            'title': eventTitle,
            'scheduleType': callType.name,
            'scheduledAt': scheduledTime.toIso8601String(),
            'dateLabel': dateStr,
            'timeLabel': timeStr,
            'scheduledBy': 'me',
          },
        );
        _snack('📅 $eventTitle scheduled $when ✨');
      },
    );
  }
}

// ── Custom Painter for BP Trend Chart ─────────────────────────────────────────
class _BpChartPainter extends CustomPainter {
  final bool isDark;
  _BpChartPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : const Color(0xFF0F172A)).withValues(
        alpha: 0.1,
      )
      ..strokeWidth = 0.8;

    final systolicPaint = Paint()
      ..color = _cTeal
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final diastolicPaint = Paint()
      ..color = _cBlue
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final dotPaintTeal = Paint()..color = _cTeal;
    final dotPaintBlue = Paint()..color = _cBlue;

    // Horizontal grid lines & Y labels (160, 120, 80, 40, 0)
    final yLabels = ['160', '120', '80', '40', '0'];
    final textStyle = TextStyle(
      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
      fontSize: 8.5,
      fontWeight: FontWeight.w500,
    );

    const leftPad = 26.0;
    const rightPad = 12.0;
    const topPad = 8.0;
    const bottomPad = 20.0;

    final plotWidth = size.width - leftPad - rightPad;
    final plotHeight = size.height - topPad - bottomPad;

    for (int i = 0; i < 5; i++) {
      final y = topPad + (plotHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        gridPaint,
      );

      final tp = TextPainter(
        text: TextSpan(text: yLabels[i], style: textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(0, y - tp.height / 2));
    }

    // Points for 5 intervals (12 Aug, 13 Aug, 14 Aug, etc.)
    final systolicVals = [94.0, 126.0, 105.0, 138.0, 110.0];
    final diastolicVals = [60.0, 75.0, 60.0, 80.0, 65.0];
    final dates = ['12 Aug', '', '13 Aug', '', '14 Aug'];

    final sysPath = Path();
    final diaPath = Path();

    for (int i = 0; i < 5; i++) {
      final x = leftPad + (plotWidth / 4) * i;
      final ySys = topPad + plotHeight - (systolicVals[i] / 160.0) * plotHeight;
      final yDia =
          topPad + plotHeight - (diastolicVals[i] / 160.0) * plotHeight;

      if (i == 0) {
        sysPath.moveTo(x, ySys);
        diaPath.moveTo(x, yDia);
      } else {
        sysPath.lineTo(x, ySys);
        diaPath.lineTo(x, yDia);
      }

      canvas.drawCircle(Offset(x, ySys), 3.5, dotPaintTeal);
      canvas.drawCircle(Offset(x, yDia), 3.5, dotPaintBlue);

      if (dates[i].isNotEmpty) {
        final tp = TextPainter(
          text: TextSpan(text: dates[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, size.height - bottomPad + 4));
      }
    }

    canvas.drawPath(sysPath, systolicPaint);
    canvas.drawPath(diaPath, diastolicPaint);
  }

  @override
  bool shouldRepaint(covariant _BpChartPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
