import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../features/profile/profile_share_helper.dart';
import '../../shared/widgets/report_bottom_sheet.dart';

class ContactInfoScreen extends StatefulWidget {
  final String name;
  final String role;
  final String? avatarColor;
  final String? contactUserId;
  final String? hospital;
  final String? location;
  final bool isOnline;
  final int photoCount;
  final int videoCount;
  final int docCount;
  final int linkCount;
  final int starredCount;
  final bool isBlocked;
  final ValueChanged<bool> onToggleBlock;
  final VoidCallback onMessage;
  final void Function({int initialTab, String? title})? onOpenSharedMedia;

  const ContactInfoScreen({
    super.key,
    required this.name,
    required this.role,
    this.avatarColor,
    this.contactUserId,
    this.hospital,
    this.location,
    this.isOnline = true,
    this.photoCount = 0,
    this.videoCount = 0,
    this.docCount = 0,
    this.linkCount = 0,
    this.starredCount = 0,
    this.isBlocked = false,
    required this.onToggleBlock,
    required this.onMessage,
    this.onOpenSharedMedia,
  });

  @override
  State<ContactInfoScreen> createState() => _ContactInfoScreenState();
}

class _ContactInfoScreenState extends State<ContactInfoScreen> {
  late bool _following = false;
  late bool _isBlocked = widget.isBlocked;

  String _initials(String name) {
    final p = name.trim().split(' ');
    return p.length >= 2
        ? '${p[0][0]}${p[1][0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : '?');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    const teal = Color(0xFF0F766E);
    const green = Color(0xFF10B981);
    const red = Color(0xFFEF4444);
    const amber = Color(0xFFF59E0B);
    const blue = Color(0xFF2563EB);
    const purple = Color(0xFF7C3AED);

    final avatarD = MediaQuery.of(context).size.shortestSide * 0.3;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: bg,
              foregroundColor: tx,
              elevation: 0,
              scrolledUnderElevation: 0,
              pinned: true,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_rounded, color: tx),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.share_rounded, color: tx),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    final initials = widget.name
                        .split(' ')
                        .where((w) => w.isNotEmpty)
                        .take(2)
                        .map((w) => w[0])
                        .join()
                        .toUpperCase();
                    ProfileShareHelper.showShareSheet(
                      context,
                      ProfileShareHelper.doctor(
                        doctorId: widget.contactUserId,
                        doctorName: widget.name,
                        specialization: widget.role,
                        hospital: widget.hospital ?? '',
                        location: widget.location ?? '',
                        avatarInitials: initials.isEmpty ? 'MD' : initials,
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.more_vert_rounded, color: tx),
                  onPressed: () => _showTopSheet(tx, sub, card, teal),
                ),
                const SizedBox(width: 4),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: avatarD + 20,
                          height: avatarD + 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: green.withValues(alpha: 0.35), width: 2),
                          ),
                        ),
                        Container(
                          width: avatarD,
                          height: avatarD,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: widget.avatarColor != null
                                ? Color(int.parse(widget.avatarColor!))
                                : teal,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _initials(widget.name),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: avatarD * 0.32,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: bg,
                              shape: BoxShape.circle,
                            ),
                            child: Container(
                              width: avatarD * 0.14,
                              height: avatarD * 0.14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.isOnline ? green : sub,
                                border: Border.all(color: bg, width: 2),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            widget.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: tx,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: teal,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: teal.withValues(alpha: 0.4),
                                  blurRadius: 8),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.role,
                      style: TextStyle(
                        color: teal,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isOnline ? 'Online • Available now' : 'Offline',
                      style: TextStyle(
                        color: widget.isOnline ? green : sub,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (!_isBlocked) _buildActions(teal, green, red, card, border, tx),
                    if (_isBlocked) _buildBlockedBanner(tx, sub, red),
                    const SizedBox(height: 20),
                    _countsRow(tx, sub, card, border),
                    const SizedBox(height: 22),
                    _section(
                      title: 'Professional Info',
                      icon: Icons.workspace_premium_rounded,
                      iconColor: teal,
                      tx: tx,
                      sub: sub,
                      card: card,
                      border: border,
                      children: [
                        _infoRow(
                            Icons.medical_services_rounded,
                            'Specialization',
                            'Cardiology • Interventional Cardiologist',
                            teal,
                            tx,
                            sub),
                        _infoRow(
                            Icons.local_hospital_rounded,
                            'Primary Hospital',
                            'Max Super Speciality Hospital, New Delhi',
                            blue,
                            tx,
                            sub),
                        _infoRow(
                            Icons.school_rounded,
                            'Qualification',
                            'MD • DM (Cardiology) • AIIMS Delhi',
                            purple,
                            tx,
                            sub),
                        _infoRow(
                            Icons.verified_user_rounded,
                            'Medical Reg. #',
                            'MCI Reg. 45678 / Delhi Medical Council',
                            green,
                            tx,
                            sub),
                        _infoRow(
                            Icons.location_on_rounded,
                            'Location',
                            'New Delhi, Delhi, India',
                            red,
                            tx,
                            sub),
                        _infoRow(
                            Icons.language_rounded,
                            'Languages',
                            'English, Hindi, Punjabi',
                            teal,
                            tx,
                            sub),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _section(
                      title: 'Shared with you',
                      icon: Icons.inventory_2_rounded,
                      iconColor: teal,
                      tx: tx,
                      sub: sub,
                      card: card,
                      border: border,
                      children: [
                        _mediaMini(
                            Icons.photo_library_rounded,
                            'Photos',
                            '${widget.photoCount} shared',
                            teal,
                            tx,
                            sub,
                            widget.photoCount > 0
                                ? () => widget.onOpenSharedMedia?.call(initialTab: 0)
                                : null),
                        _mediaMini(
                            Icons.videocam_rounded,
                            'Videos',
                            '${widget.videoCount} shared',
                            red,
                            tx,
                            sub,
                            widget.videoCount > 0
                                ? () => widget.onOpenSharedMedia?.call(initialTab: 1)
                                : null),
                        _mediaMini(
                            Icons.picture_as_pdf_rounded,
                            'Documents',
                            '${widget.docCount} shared',
                            amber,
                            tx,
                            sub,
                            widget.docCount > 0
                                ? () => widget.onOpenSharedMedia?.call(
                                      initialTab: 2,
                                      title: 'Shared files',
                                    )
                                : null),
                        _mediaMini(
                            Icons.link_rounded,
                            'Links',
                            '${widget.linkCount} shared',
                            blue,
                            tx,
                            sub,
                            widget.linkCount > 0
                                ? () => widget.onOpenSharedMedia?.call(initialTab: 3)
                                : null),
                        _mediaMini(
                            Icons.star_rounded,
                            'Starred / Saved',
                            '${widget.starredCount} messages',
                            amber,
                            tx,
                            sub,
                            widget.starredCount > 0 ? () {} : null),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _section(
                      title: 'Community',
                      icon: Icons.groups_2_rounded,
                      iconColor: teal,
                      tx: tx,
                      sub: sub,
                      card: card,
                      border: border,
                      children: [
                        _communityTile('Indian Medical Association (IMA)',
                            'Member since 2018', teal, tx, sub),
                        _communityTile('Cardiology Society of India',
                            'Fellow (FCSI)', blue, tx, sub),
                        _communityTile('Delhi Doctor Network',
                            '128 mutual connections', green, tx, sub),
                      ],
                    ),
                    const SizedBox(height: 18),
                    if (!_isBlocked)
                      _section(
                        title: 'Privacy & Safety',
                        icon: Icons.shield_rounded,
                        iconColor: green,
                        tx: tx,
                        sub: sub,
                        card: card,
                        border: border,
                        children: [
                          _infoRow(
                              Icons.enhanced_encryption_rounded,
                              'Messages',
                              'End-to-end encrypted chat',
                              teal,
                              tx,
                              sub),
                          _dangerRow(
                              Icons.report_gmailerrorred_rounded,
                              'Report this user',
                              red,
                              tx,
                              sub, () {
                            Navigator.pop(context);
                            showContentReportSheet(
                              context,
                              subjectLabel: 'this account',
                              targetId: widget.contactUserId ?? widget.name,
                              targetName: widget.name,
                              reportType: 'chat_user_report',
                            );
                          }),
                          _dangerRow(
                            Icons.block_rounded,
                            _isBlocked ? 'Unblock user' : 'Block user',
                            red,
                            tx,
                            sub, () {
                              setState(() {
                                _isBlocked = !_isBlocked;
                              });
                              widget.onToggleBlock(_isBlocked);
                              HapticFeedback.mediumImpact();
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(_isBlocked
                                    ? '${widget.name} blocked'
                                    : '${widget.name} unblocked'),
                                backgroundColor: _isBlocked ? red : teal,
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ));
                            },
                            isAction: true),
                        ],
                      ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Color teal, Color green, Color red, Color card,
      Color border, Color tx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _actionBtn(
            Icons.message_rounded, 'Message', teal, card, border, () {
          widget.onMessage();
          Navigator.pop(context);
        }),
        _actionBtn(Icons.call_rounded, 'Call', teal, card, border, () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Starting voice call…'),
            backgroundColor: teal,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }),
        _actionBtn(Icons.videocam_rounded, 'Video', teal, card, border, () {
          HapticFeedback.lightImpact();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Starting video call…'),
            backgroundColor: teal,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ));
        }),
        _followBtn(teal, card, border, tx),
      ],
    );
  }

  Widget _actionBtn(IconData icon, String label, Color color, Color card,
      Color border, VoidCallback onTap) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: onTap,
                child: Ink(
                  height: 52,
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Center(
                    child: Icon(icon, color: color, size: 24),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _followBtn(Color teal, Color card, Color border, Color tx) {
    final active = _following;
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _following = !_following);
                },
                child: Ink(
                  height: 52,
                  decoration: BoxDecoration(
                    color: active ? teal : card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: active ? teal : border),
                  ),
                  child: Center(
                    child: Icon(
                      active ? Icons.person_2_rounded : Icons.person_add_rounded,
                      color: active ? Colors.white : teal,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              active ? 'Following' : 'Follow',
              style: TextStyle(
                color: active ? teal : teal,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedBanner(Color tx, Color sub, Color red) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: red.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.block_rounded, color: red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You have blocked ${widget.name}',
                  style: TextStyle(
                      color: tx, fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  'They can\'t message or call you.',
                  style: TextStyle(
                      color: sub, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _isBlocked = false);
              widget.onToggleBlock(false);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: red,
              side: BorderSide(color: red.withValues(alpha: 0.4)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Unblock',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _countsRow(Color tx, Color sub, Color card, Color border) {
    const teal = Color(0xFF0F766E);
    const green = Color(0xFF10B981);
    const purple = Color(0xFF7C3AED);
    const blue = Color(0xFF2563EB);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _countChip(widget.photoCount.toString(), 'Photos', teal, tx, sub),
          _countChip(widget.videoCount.toString(), 'Videos', green, tx, sub),
          _countChip(widget.docCount.toString(), 'Docs', purple, tx, sub),
          _countChip(widget.linkCount.toString(), 'Links', blue, tx, sub),
        ],
      ),
    );
  }

  Widget _countChip(String n, String label, Color accent, Color tx, Color sub) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          n,
          style: TextStyle(
            color: accent,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: sub,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _section({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color tx,
    required Color sub,
    required Color card,
    required Color border,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                    color: tx, fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Divider(
                        height: 1,
                        thickness: 1,
                        color: border.withValues(alpha: 0.7)),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color iconColor,
      Color tx, Color sub) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withValues(alpha: 0.1),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: sub, fontSize: 11.5, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                      color: tx,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dangerRow(IconData icon, String label, Color iconColor, Color tx,
      Color sub, VoidCallback onTap, {bool isAction = false}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconColor.withValues(alpha: 0.1),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                        color: isAction ? iconColor : tx,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                if (isAction)
                  Icon(Icons.chevron_right_rounded,
                      color: iconColor.withValues(alpha: 0.8), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _mediaMini(IconData icon, String label, String subText, Color color,
      Color tx, Color sub, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap ??
              () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Opening $label…'),
                  backgroundColor: color,
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ));
              },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                            color: tx,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subText,
                        style: TextStyle(
                            color: sub,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: sub.withValues(alpha: 0.85), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _communityTile(
      String title, String sub, Color color, Color tx, Color sb) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Opening $title…'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.12),
                  ),
                  child:
                      Icon(Icons.apartment_rounded, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                            color: tx,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        sub,
                        style: TextStyle(
                            color: sb,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    color: sb.withValues(alpha: 0.85), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTopSheet(Color tx, Color sub, Color card, Color teal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 14),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: sub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 6),
            _miniTile(Icons.share_rounded, 'Share profile', teal, tx, sub, () {
              Navigator.pop(context);
              ProfileShareHelper.showShareSheet(
                context,
                ProfileShareHelper.doctor(
                  doctorId: widget.contactUserId,
                  doctorName: widget.name,
                  specialization: widget.role,
                  hospital: widget.hospital ?? '',
                  location: widget.location ?? 'India',
                  avatarInitials: _initials(widget.name),
                ),
              );
            }),
            _miniTile(Icons.qr_code_2_rounded, 'View QR code', teal, tx, sub, () {
              Navigator.pop(context);
              ProfileShareHelper.openQrScreen(
                context,
                ProfileShareHelper.doctor(
                  doctorId: widget.contactUserId,
                  doctorName: widget.name,
                  specialization: widget.role,
                  hospital: widget.hospital ?? '',
                  location: widget.location ?? 'India',
                  avatarInitials: _initials(widget.name),
                ),
              );
            }),
            _miniTile(Icons.notifications_rounded, 'Notifications',
                const Color(0xFFF59E0B), tx, sub),
            _miniTile(Icons.block_rounded, 'Block / Unblock',
                const Color(0xFFEF4444), tx, sub),
          ],
        ),
      ),
    );
  }

  Widget _miniTile(
      IconData icon, String label, Color color, Color tx, Color sub, [VoidCallback? onTap]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap ??
              () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('$label selected'),
              backgroundColor: color,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.12)),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: TextStyle(
                          color: tx,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
