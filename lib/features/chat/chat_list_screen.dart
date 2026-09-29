// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../models/share_payload.dart';
import 'chat_screen.dart';
import 'search_doctor_screen.dart';
import '../profile/public_doctor_profile_screen.dart';

const _cGreen   = Color(0xFF16A34A);
const _cBlue    = Color(0xFF2563EB);
const _cPurple  = Color(0xFF7C3AED);
const _cAmber   = Color(0xFFF59E0B);
const _cRed     = Color(0xFFEF4444);
const _cTeal    = Color(0xFF0F766E);
const _cEmerald = Color(0xFF10B981);
const _cOrange  = Color(0xFFF97316);

class _Chat {
  final String avatar;
  final Color avatarColor;
  final String name;
  final String role;
  final String hospital;
  final String lastMsg;
  final String time;
  int unread;
  bool online;
  final bool isGroup;
  final int memberCount;
  bool isPinned;
  bool isMuted;
  bool isFavorite;
  final String msgType;
  bool isRead;

  _Chat({
    required this.avatar,
    required this.avatarColor,
    required this.name,
    required this.role,
    this.hospital = 'Apollo Hospital',
    required this.lastMsg,
    required this.time,
    this.unread = 0,
    this.online = false,
    this.isGroup = false,
    this.memberCount = 0,
    this.isPinned = false,
    this.isMuted = false,
    this.isFavorite = false,
    this.msgType = 'text',
    this.isRead = true,
  });
}

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});
  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  int _tab = 0; // 0: Messages, 1: Groups, 2: Channels, 3: Requests
  String _filter = 'All';
  String _activeStatus = 'Available';
  final _search = TextEditingController();
  bool _searching = false;

  late final List<_Chat> _chats = [
    _Chat(
      avatar: 'RM',
      avatarColor: _cBlue,
      name: 'Dr. Rohan Mehta',
      role: 'Cardiologist',
      hospital: 'Apollo Hospital',
      lastMsg: 'Can you share the ECG report?',
      time: '9:40 AM',
      unread: 2,
      online: true,
      isRead: false,
      isPinned: true,
    ),
    _Chat(
      avatar: 'NV',
      avatarColor: _cEmerald,
      name: 'Dr. Neha Verma',
      role: 'Dermatologist',
      hospital: 'Max Hospital',
      lastMsg: 'Thanks for the update!',
      time: '9:32 AM',
      unread: 0,
      online: true,
      isRead: true,
    ),
    _Chat(
      avatar: 'ICU',
      avatarColor: _cPurple,
      name: 'ICU Team Group',
      role: '8 members',
      hospital: 'Apollo Hospital',
      lastMsg: 'Dr. Arjun: New ICU protocol updated.',
      time: '9:15 AM',
      unread: 5,
      isGroup: true,
      memberCount: 8,
      isMuted: true,
      isRead: false,
    ),
    _Chat(
      avatar: 'PN',
      avatarColor: _cAmber,
      name: 'Dr. Priya Nair',
      role: 'Pediatrician',
      hospital: 'Cloudnine Hospital',
      lastMsg: 'Shared a document',
      time: '8:50 AM',
      unread: 0,
      msgType: 'doc',
      isRead: true,
    ),
    _Chat(
      avatar: 'KP',
      avatarColor: _cRed,
      name: 'Dr. Karan Patel',
      role: 'Orthopedic Surgeon',
      hospital: 'MGM Healthcare',
      lastMsg: "Let's discuss the case.",
      time: 'Yesterday',
      unread: 1,
      isRead: false,
    ),
    _Chat(
      avatar: 'SN',
      avatarColor: _cOrange,
      name: 'Staff Nurse Shalini',
      role: 'Staff Nurse',
      hospital: 'PIMS Hospital',
      lastMsg: 'Okay doctor, noted.',
      time: 'Yesterday',
      unread: 0,
      isRead: true,
    ),
    _Chat(
      avatar: 'LH',
      avatarColor: _cBlue,
      name: 'Lab Team',
      role: '5 members',
      hospital: 'Central Pathology',
      lastMsg: 'Report: Blood sample results uploaded.',
      time: 'Yesterday',
      unread: 3,
      isGroup: true,
      memberCount: 5,
      isMuted: true,
      isRead: false,
    ),
    _Chat(
      avatar: 'AS',
      avatarColor: _cTeal,
      name: 'Dr. Arjun Sharma',
      role: 'Diabetologist',
      hospital: 'Apollo Hospital',
      lastMsg: 'Please review the patient charts.',
      time: 'Tue',
      unread: 0,
      online: true,
      isFavorite: true,
      isRead: true,
    ),
    _Chat(
      avatar: 'AK',
      avatarColor: _cPurple,
      name: 'Dr. Ayesha Khan',
      role: 'Anesthesiologist',
      hospital: 'Fortis Hospital',
      lastMsg: 'Patient prep completed for OT 3.',
      time: '23 May',
      unread: 0,
      online: true,
      isRead: true,
    ),
    _Chat(
      avatar: 'ET',
      avatarColor: _cRed,
      name: 'Emergency Team',
      role: '6 members',
      hospital: 'Apollo Emergency',
      lastMsg: 'Dr. Rohan: Patient admitted in ER',
      time: '22 May',
      unread: 2,
      isGroup: true,
      memberCount: 6,
      isRead: false,
    ),
    _Chat(
      avatar: 'SK',
      avatarColor: _cBlue,
      name: 'Dr. Simran Kaur',
      role: 'Radiologist',
      hospital: 'Medanta Hospital',
      lastMsg: 'Image results look good.',
      time: '21 May',
      unread: 0,
      isRead: true,
    ),
    _Chat(
      avatar: 'BS',
      avatarColor: _cEmerald,
      name: 'Dr. Bharat Singh',
      role: 'General Physician',
      hospital: 'Apollo Clinic',
      lastMsg: 'Sure, will do.',
      time: '20 May',
      unread: 0,
      isRead: true,
    ),
  ];

  List<_Chat> get _visible {
    var list = [..._chats];

    // Tab filter
    if (_tab == 1) {
      list = list.where((c) => c.isGroup).toList();
    } else if (_tab == 2) {
      list = []; // Channels tab
    } else if (_tab == 3) {
      list = []; // Requests tab
    }

    // Search filter
    if (_searching && _search.text.isNotEmpty) {
      final q = _search.text.toLowerCase();
      list = list.where((c) =>
        c.name.toLowerCase().contains(q) ||
        c.role.toLowerCase().contains(q) ||
        c.hospital.toLowerCase().contains(q) ||
        c.lastMsg.toLowerCase().contains(q)
      ).toList();
    }

    // Chip filter
    if (_tab == 0) {
      switch (_filter) {
        case 'Unread':
          return list.where((c) => c.unread > 0).toList();
        case 'Favorites':
          return list.where((c) => c.isPinned || c.isFavorite).toList();
        case 'Online':
          return list.where((c) => c.online && !c.isGroup).toList();
        default:
          return list;
      }
    }

    return list;
  }

  int get _totalUnread => _chats.fold(0, (s, c) => s + c.unread);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _snack(String msg, {Color bg = _cTeal}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: _searching
            ? Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.search_rounded, color: sub, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        autofocus: true,
                        style: TextStyle(color: tx, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search doctors, specialties, groups...',
                          hintStyle: TextStyle(color: sub, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: sub, size: 20),
                      onPressed: () => setState(() {
                        _searching = false;
                        _search.clear();
                      }),
                    ),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Messages',
                        style: TextStyle(
                          color: tx,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (_totalUnread > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _cTeal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_totalUnread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Connect, discuss & collaborate',
                    style: TextStyle(
                      color: sub,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
        actions: [
          if (!_searching) ...[
            IconButton(
              tooltip: 'Search',
              icon: Icon(Icons.search_rounded, color: tx, size: 22),
              onPressed: () => setState(() => _searching = true),
            ),
            IconButton(
              tooltip: 'New Message',
              icon: Icon(Icons.edit_square, color: tx, size: 20),
              onPressed: _showNewChatSheet,
            ),
            IconButton(
              tooltip: 'Menu',
              icon: Icon(Icons.more_vert_rounded, color: tx, size: 22),
              onPressed: _showListMenu,
            ),
            const SizedBox(width: 4),
          ],
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(card, border, tx, sub),
          _buildTabs(tx, sub),
          if (_tab == 0) _buildFilterChips(card, border, tx, sub),
          const SizedBox(height: 4),
          Expanded(
            child: _tab == 0 || _tab == 1
                ? _buildList(tx, sub, card, border, shadow)
                : _buildEmptyTab(_tab, tx, sub),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewChatSheet,
        backgroundColor: _cTeal,
        elevation: 3,
        child: const Icon(Icons.edit_rounded, color: Colors.white, size: 22),
      ),
    );
  }

  // ── Availability / Status Bar ───────────────────────────────────────────────
  Widget _buildStatusBar(Color card, Color border, Color tx, Color sub) {
    final statuses = [
      (Icons.check_circle_rounded, 'Available', _cGreen),
      (Icons.lightbulb_rounded, 'On Duty', _cOrange),
      (Icons.medical_services_rounded, 'In Surgery', _cBlue),
      (Icons.remove_circle_outline_rounded, 'Busy', _cPurple),
      (Icons.emergency_rounded, 'Emergency', _cRed),
    ];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: statuses.length + 1,
        itemBuilder: (ctx, i) {
          if (i == statuses.length) {
            return GestureDetector(
              onTap: _showHealthcareSheet,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Icon(Icons.chevron_right_rounded, color: sub, size: 18),
              ),
            );
          }
          final item = statuses[i];
          final isSelected = _activeStatus == item.$2;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              if (item.$2 == 'Emergency') {
                _showEmergencySheet();
              } else {
                setState(() => _activeStatus = item.$2);
                _snack('Status updated: ${item.$2}', bg: item.$3);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? item.$3.withValues(alpha: 0.12) : card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? item.$3.withValues(alpha: 0.5)
                      : border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(item.$1, color: item.$3, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    item.$2,
                    style: TextStyle(
                      color: isSelected ? item.$3 : tx,
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Conversation Tabs ───────────────────────────────────────────────────────
  Widget _buildTabs(Color tx, Color sub) {
    const labels = ['Messages', 'Groups', 'Channels', 'Requests'];
    final badges = [null, null, null, '3'];

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (i) {
          final sel = _tab == i;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _tab = i);
            },
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      labels[i],
                      style: TextStyle(
                        color: sel ? _cTeal : sub,
                        fontWeight: sel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (badges[i] != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _cRed,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          badges[i]!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 2.5,
                  width: sel ? 42 : 0,
                  decoration: BoxDecoration(
                    color: _cTeal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Filter Chips ────────────────────────────────────────────────────────────
  Widget _buildFilterChips(Color card, Color border, Color tx, Color sub) {
    const chips = ['All', 'Unread', 'Favorites', 'Online'];
    return Container(
      height: 42,
      margin: const EdgeInsets.only(top: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: chips.length,
        itemBuilder: (ctx, i) {
          final act = _filter == chips[i];
          final badge = chips[i] == 'Unread'
              ? _chats.where((c) => c.unread > 0).length
              : 0;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _filter = chips[i]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: act ? _cTeal : card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: act ? _cTeal : border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chips[i],
                    style: TextStyle(
                      color: act ? Colors.white : sub,
                      fontSize: 12,
                      fontWeight: act ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (badge > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1.5,
                      ),
                      decoration: BoxDecoration(
                        color: act
                            ? Colors.white.withValues(alpha: 0.25)
                            : _cTeal,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$badge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Conversation List ───────────────────────────────────────────────────────
  Widget _buildList(
    Color tx,
    Color sub,
    Color card,
    Color border,
    List<BoxShadow> shadow,
  ) {
    final list = _visible;
    if (list.isEmpty) {
      final isSearching = _searching && _search.text.isNotEmpty;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSearching
                    ? Icons.search_off_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: sub.withValues(alpha: 0.4),
                size: 48,
              ),
              const SizedBox(height: 14),
              Text(
                isSearching
                    ? 'No conversations found'
                    : 'No conversations yet',
                style: TextStyle(
                  color: tx,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isSearching
                    ? 'Try another name, speciality or keyword.'
                    : 'Start connecting with verified healthcare professionals.',
                textAlign: TextAlign.center,
                style: TextStyle(color: sub, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 6, bottom: 80),
      itemCount: list.length,
      itemBuilder: (ctx, i) =>
          _buildTile(list[i], tx, sub, card, border, shadow),
    );
  }

  // ── Conversation Tile Card ──────────────────────────────────────────────────
  Widget _buildTile(
    _Chat c,
    Color tx,
    Color sub,
    Color card,
    Color border,
    List<BoxShadow> shadow,
  ) {
    return Dismissible(
      key: ValueKey(c.name + c.time),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _cBlue,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Icon(
              c.isRead
                  ? Icons.mark_chat_unread_rounded
                  : Icons.mark_chat_read_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              c.isRead ? 'Unread' : 'Read',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: _cOrange,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(Icons.archive_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Archive',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (dir) async {
        if (dir == DismissDirection.startToEnd) {
          setState(() {
            c.isRead = !c.isRead;
            if (c.isRead) c.unread = 0;
          });
          _snack(c.isRead ? 'Marked as read' : 'Marked as unread');
          return false;
        } else {
          setState(() => _chats.remove(c));
          _snack('Conversation archived', bg: _cAmber);
          return false;
        }
      },
      child: GestureDetector(
        onLongPress: () => _showTileMenu(c),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  c.unread = 0;
                  c.isRead = true;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatScreen(
                      receiverName: c.name,
                      receiverRole: c.role,
                      receiverHospital: c.hospital,
                      isOnline: c.online,
                    ),
                  ),
                );
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with online indicator
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundColor: c.avatarColor,
                          child: c.isGroup
                              ? const Icon(
                                  Icons.groups_rounded,
                                  color: Colors.white,
                                  size: 24,
                                )
                              : Text(
                                  c.avatar,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                        if (c.online && !c.isGroup)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _cGreen,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // Hierarchy: Name -> Role / Hospital -> Latest message
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: c.isGroup
                                      ? null
                                      : () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  PublicDoctorProfileScreen(
                                                doctorName: c.name,
                                                qualification: 'MBBS, MD',
                                                specialization: c.role,
                                                hospital: c.hospital,
                                                location: 'Delhi, India',
                                                avatarInitials: c.avatar,
                                                avatarColor: c.avatarColor,
                                              ),
                                            ),
                                          ),
                                  child: Text(
                                    c.name,
                                    style: TextStyle(
                                      color: tx,
                                      fontSize: 14.5,
                                      fontWeight: c.unread > 0
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              if (!c.isGroup) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: _cBlue,
                                  size: 14,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.isGroup
                                ? '${c.memberCount} members'
                                : '${c.role} • ${c.hospital}',
                            style: TextStyle(
                              color: sub,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (c.msgType == 'doc') ...[
                                Icon(Icons.attach_file, color: sub, size: 13),
                                const SizedBox(width: 2),
                              ],
                              if (c.msgType == 'image') ...[
                                Icon(
                                  Icons.image_outlined,
                                  color: sub,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                              ],
                              if (c.msgType == 'audio') ...[
                                Icon(
                                  Icons.mic_none_rounded,
                                  color: sub,
                                  size: 13,
                                ),
                                const SizedBox(width: 2),
                              ],
                              Flexible(
                                child: Text(
                                  c.lastMsg,
                                  style: TextStyle(
                                    color: c.unread > 0
                                        ? tx
                                        : sub.withValues(alpha: 0.9),
                                    fontSize: 12.5,
                                    fontWeight: c.unread > 0
                                        ? FontWeight.w500
                                        : FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Trailing: Timestamp & Badges
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.time,
                          style: TextStyle(
                            color: c.unread > 0 ? _cTeal : sub,
                            fontSize: 11,
                            fontWeight: c.unread > 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 5),
                        if (c.unread > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: _cTeal,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${c.unread}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (c.isPinned)
                          Icon(
                            Icons.push_pin_rounded,
                            color: sub.withValues(alpha: 0.6),
                            size: 14,
                          )
                        else if (c.isMuted)
                          Icon(
                            Icons.volume_off_rounded,
                            color: sub.withValues(alpha: 0.5),
                            size: 14,
                          )
                        else if (c.isFavorite)
                          const Icon(
                            Icons.star_rounded,
                            color: _cAmber,
                            size: 16,
                          )
                        else
                          Icon(
                            c.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            color: c.isRead
                                ? _cBlue
                                : sub.withValues(alpha: 0.45),
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyTab(int tab, Color tx, Color sub) {
    const icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.groups_rounded,
      Icons.campaign_rounded,
      Icons.person_add_rounded,
    ];
    const labels = ['Messages', 'Groups', 'Channels', 'Requests'];
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.35,
            child: Icon(icons[tab], color: sub, size: 48),
          ),
          const SizedBox(height: 12),
          Text(
            'No ${labels[tab]} yet',
            style: TextStyle(
              color: tx,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tab == 3
                ? 'Pending colleague connection requests will appear here'
                : 'Tap + to start a new conversation',
            style: TextStyle(color: sub, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  // ── Sheet: Long-press tile menu ─────────────────────────────────────────────
  void _showTileMenu(_Chat c) {
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: c.avatarColor,
                    child: Text(
                      c.avatar,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: TextStyle(
                            color: tx,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${c.role} • ${c.hospital}',
                          style: TextStyle(color: sub, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                c.isRead
                    ? Icons.mark_chat_unread_rounded
                    : Icons.mark_chat_read_rounded,
                color: _cBlue,
              ),
              title: Text(
                c.isRead ? 'Mark as unread' : 'Mark as read',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  c.isRead = !c.isRead;
                  if (c.isRead) c.unread = 0;
                });
                _snack(c.isRead ? 'Marked as read' : 'Marked as unread');
              },
            ),
            ListTile(
              leading: Icon(
                c.isPinned
                    ? Icons.push_pin_rounded
                    : Icons.push_pin_outlined,
                color: _cAmber,
              ),
              title: Text(
                c.isPinned ? 'Unpin conversation' : 'Pin conversation',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => c.isPinned = !c.isPinned);
                _snack(
                  c.isPinned
                      ? 'Conversation pinned'
                      : 'Conversation unpinned',
                );
              },
            ),
            ListTile(
              leading: Icon(
                c.isMuted
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                color: _cPurple,
              ),
              title: Text(
                c.isMuted
                    ? 'Unmute notifications'
                    : 'Mute notifications',
                style: TextStyle(color: tx),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => c.isMuted = !c.isMuted);
                _snack(c.isMuted ? 'Muted' : 'Unmuted');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded, color: _cOrange),
              title: Text('Archive conversation', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                setState(() => _chats.remove(c));
                _snack('Archived', bg: _cAmber);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: _cRed),
              title: Text(
                'Delete conversation',
                style: const TextStyle(color: _cRed),
              ),
              onTap: () {
                Navigator.pop(context);
                setState(() => _chats.remove(c));
                _snack('Deleted', bg: _cRed);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Sheet: New Chat ─────────────────────────────────────────────────────────
  void _showNewChatSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          top: false,
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
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Start Conversation',
                  style: TextStyle(
                    color: tx,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: _cTeal,
                    size: 22,
                  ),
                ),
                title: Text(
                  'New Direct Message',
                  style: TextStyle(
                    color: tx,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Search verified doctors & colleagues',
                  style: TextStyle(color: sub, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SearchDoctorScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: _cPurple,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Create Group',
                  style: TextStyle(
                    color: tx,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'ICU team, duty group, rounds...',
                  style: TextStyle(color: sub, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _snack('Creating clinical group...', bg: _cPurple);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.campaign_rounded,
                    color: _cBlue,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Create Channel',
                  style: TextStyle(
                    color: tx,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Department announcements & CME',
                  style: TextStyle(color: sub, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _snack('Creating clinical channel...', bg: _cBlue);
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _cRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.emergency_rounded,
                    color: _cRed,
                    size: 22,
                  ),
                ),
                title: Text(
                  'Emergency Broadcast',
                  style: TextStyle(
                    color: tx,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Urgent alert to on-duty staff',
                  style: TextStyle(color: sub, fontSize: 12),
                ),
                onTap: () {
                  Navigator.pop(sheetCtx);
                  _showEmergencySheet();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sheet: Healthcare Quick Actions ─────────────────────────────────────────
  void _showHealthcareSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
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
              padding: const EdgeInsets.all(16),
              child: Text(
                'Healthcare Quick Actions',
                style: TextStyle(
                  color: tx,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _hAction(
                  Icons.medical_services_rounded,
                  'Share Duty Info',
                  _cTeal,
                  () {
                    Navigator.pop(context);
                    MedDutyShareService.show(
                      context,
                      SharePayload.duty(
                        title: 'On-call Duty',
                        hospital: 'Apollo Hospital',
                        location: 'Chennai',
                      ),
                    );
                  },
                ),
                _hAction(
                  Icons.local_hospital_rounded,
                  'Share Hospital Info',
                  _cBlue,
                  () {
                    Navigator.pop(context);
                    MedDutyShareService.show(
                      context,
                      SharePayload.generic(
                        sheetTitle: 'Share Hospital',
                        shareText:
                            'Apollo Hospital — Chennai\nhttps://www.medduty.in/hospital/apollo_hospital',
                        link:
                            'https://www.medduty.in/hospital/apollo_hospital',
                      ),
                    );
                  },
                ),
                _hAction(
                  Icons.person_rounded,
                  'Share Doctor Profile',
                  _cPurple,
                  () {
                    Navigator.pop(context);
                    MedDutyShareService.show(
                      context,
                      SharePayload.generic(
                        sheetTitle: 'Share Profile',
                        shareText:
                            'View my MedDuty profile\nhttps://www.medduty.in/profile/user/me',
                        link: 'https://www.medduty.in/profile/user/me',
                      ),
                    );
                  },
                ),
                _hAction(
                  Icons.schedule_rounded,
                  'Share Schedule',
                  _cAmber,
                  () {
                    Navigator.pop(context);
                    _snack('Sharing duty schedule...', bg: _cAmber);
                  },
                ),
                _hAction(
                  Icons.description_rounded,
                  'Share Report',
                  _cRed,
                  () {
                    Navigator.pop(context);
                    _snack('Opening report selector...', bg: _cRed);
                  },
                ),
                _hAction(
                  Icons.location_on_rounded,
                  'Share Location',
                  _cOrange,
                  () {
                    Navigator.pop(context);
                    _snack('Sharing live hospital location...', bg: _cOrange);
                  },
                ),
                _hAction(
                  Icons.cases_rounded,
                  'Case Discussion',
                  _cBlue,
                  () {
                    Navigator.pop(context);
                    _snack('Opening case discussion...', bg: _cBlue);
                  },
                ),
                _hAction(
                  Icons.emergency_rounded,
                  'Emergency Alert',
                  _cRed,
                  () {
                    Navigator.pop(context);
                    _showEmergencySheet();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _hAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2,
        margin: const EdgeInsets.only(left: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: tx,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sheet: Emergency Broadcast ──────────────────────────────────────────────
  void _showEmergencySheet() {
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
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _cRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _cRed.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emergency_rounded, color: _cRed, size: 22),
                  SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'Emergency Mode: Alert on-duty hospital teams immediately',
                      style: TextStyle(
                        color: _cRed,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.broadcast_on_personal_rounded,
                  color: _cRed,
                  size: 22,
                ),
              ),
              title: Text(
                'Alert All Doctors',
                style: TextStyle(
                  color: tx,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Broadcast emergency notification to all available doctors',
                style: TextStyle(color: sub, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _snack('🚨 Emergency broadcast sent to all doctors!', bg: _cRed);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cAmber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: _cAmber,
                  size: 22,
                ),
              ),
              title: Text(
                'Alert ICU & OT Team',
                style: TextStyle(
                  color: tx,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Send high-priority alert to critical care specialists',
                style: TextStyle(color: sub, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _snack('🚨 ICU & OT Teams alerted!', bg: _cAmber);
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: _cBlue,
                  size: 22,
                ),
              ),
              title: Text(
                'Emergency Helpline',
                style: TextStyle(
                  color: tx,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                'Call hospital rapid response dispatch line',
                style: TextStyle(color: sub, fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _snack('Calling hospital emergency line...', bg: _cBlue);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  // ── Menu: List-level more options ───────────────────────────────────────────
  void _showListMenu() {
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
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.done_all_rounded, color: _cTeal),
              title: Text('Mark all as read', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  for (final c in _chats) {
                    c.isRead = true;
                    c.unread = 0;
                  }
                });
                _snack('All marked as read');
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive_rounded, color: _cAmber),
              title: Text('Archive all read', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                setState(() =>
                    _chats.removeWhere((c) => c.isRead && c.unread == 0));
                _snack('Read conversations archived', bg: _cAmber);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.medical_services_rounded, color: _cTeal),
              title: Text('Healthcare actions', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _showHealthcareSheet();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_rounded, color: _cBlue),
              title: Text('Chat settings', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _snack('Opening chat settings...', bg: _cBlue);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.privacy_tip_rounded, color: _cPurple),
              title:
                  Text('Privacy & HIPAA compliance', style: TextStyle(color: tx)),
              onTap: () {
                Navigator.pop(context);
                _snack('Opening privacy & HIPAA settings...', bg: _cPurple);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
