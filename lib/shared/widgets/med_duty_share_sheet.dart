import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/data/share_chat_contacts.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../core/services/profile_share_service.dart';
import '../../core/theme/app_colors.dart';
import '../../features/profile/profile_qr_screen.dart';
import '../../features/profile/widgets/profile_share_sheet.dart';
import '../../models/share_payload.dart';

class MedDutyShareSheet extends StatefulWidget {
  final SharePayload payload;

  const MedDutyShareSheet({super.key, required this.payload});

  @override
  State<MedDutyShareSheet> createState() => _MedDutyShareSheetState();
}

class _MedDutyShareSheetState extends State<MedDutyShareSheet> {
  final _searchCtrl = TextEditingController();
  final _cardKey = GlobalKey();
  String _query = '';

  SharePayload get payload => widget.payload;

  List<ShareChatContact> get _filtered {
    if (_query.trim().isEmpty) return ShareChatContacts.all;
    final q = _query.trim().toLowerCase();
    return ShareChatContacts.all
        .where((c) => c.name.toLowerCase().contains(q) || c.role.toLowerCase().contains(q))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareAsImage() async {
    final data = payload.profileData;
    if (data == null) return;
    try {
      final bytes = await ProfileShareService.captureWidget(_cardKey);
      if (bytes == null) {
        _snack('Unable to share profile card. Please try again.');
        return;
      }
      await ProfileShareService.shareImageBytes(bytes, data);
    } catch (_) {
      _snack('Unable to share profile card. Please try again.');
    }
  }

  void _openQr() {
    final data = payload.profileData;
    if (data == null) return;
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileQrScreen(data: data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A1A1A) : Colors.white;
    final surface = isDark ? const Color(0xFF262626) : const Color(0xFFF3F4F6);
    final text = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFFA8A8A8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF363636) : const Color(0xFFE5E7EB);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            builder: (_, scrollCtrl) => Container(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sub.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: text, size: 26),
                        ),
                        Expanded(
                          child: Text(
                            payload.sheetTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(color: text, fontSize: 17, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border.withValues(alpha: 0.6)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search_rounded, color: sub, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchCtrl,
                              style: TextStyle(color: text, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search',
                                hintStyle: TextStyle(color: sub, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (v) => setState(() => _query = v),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            IconButton(
                              icon: Icon(Icons.close_rounded, color: sub, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _query = '');
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Text('No contacts found', style: TextStyle(color: sub, fontSize: 14)),
                          )
                        : ListView.separated(
                            controller: scrollCtrl,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                            itemCount: _filtered.length,
                            separatorBuilder: (_, _) => Divider(height: 1, color: border.withValues(alpha: 0.5)),
                            itemBuilder: (context, index) {
                              final contact = _filtered[index];
                              return _ContactRow(
                                contact: contact,
                                text: text,
                                sub: sub,
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  Navigator.pop(context);
                                  MedDutyShareService.shareToChat(context, contact: contact, payload: payload);
                                },
                              );
                            },
                          ),
                  ),
                  Divider(height: 1, color: border),
                  _ExternalShareRow(
                    payload: payload,
                    text: text,
                    sub: sub,
                    surface: surface,
                    onCopyLink: () async {
                      HapticFeedback.lightImpact();
                      await MedDutyShareService.copyLink(context, payload);
                    },
                    onWhatsApp: () {
                      HapticFeedback.lightImpact();
                      MedDutyShareService.shareWhatsApp(payload);
                    },
                    onMessenger: () {
                      HapticFeedback.lightImpact();
                      MedDutyShareService.shareMessenger(payload);
                    },
                    onFacebook: () {
                      HapticFeedback.lightImpact();
                      MedDutyShareService.shareFacebook(payload);
                    },
                    onSms: () {
                      HapticFeedback.lightImpact();
                      MedDutyShareService.shareSms(payload);
                    },
                    onMore: () {
                      HapticFeedback.lightImpact();
                      MedDutyShareService.shareViaSystem(payload);
                    },
                    onQr: payload.profileData != null ? _openQr : null,
                    onShareImage: payload.profileData != null ? _shareAsImage : null,
                  ),
                  SizedBox(height: MediaQuery.paddingOf(context).bottom + 8),
                ],
              ),
            ),
          ),
        ),
        if (payload.profileData != null)
          ProfileShareCaptureHost(cardKey: _cardKey, data: payload.profileData!),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  final ShareChatContact contact;
  final Color text;
  final Color sub;
  final VoidCallback onTap;

  const _ContactRow({
    required this.contact,
    required this.text,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: contact.avatarColor,
                  child: Text(
                    contact.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (contact.online)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: TextStyle(color: text, fontSize: 15, fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    contact.role,
                    style: TextStyle(color: sub, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (contact.isGroup)
              Icon(Icons.people_rounded, color: sub.withValues(alpha: 0.7), size: 18),
          ],
        ),
      ),
    );
  }
}

class _ExternalShareRow extends StatelessWidget {
  final SharePayload payload;
  final Color text;
  final Color sub;
  final Color surface;
  final VoidCallback onCopyLink;
  final VoidCallback onWhatsApp;
  final VoidCallback onMessenger;
  final VoidCallback onFacebook;
  final VoidCallback onSms;
  final VoidCallback onMore;
  final VoidCallback? onQr;
  final VoidCallback? onShareImage;

  const _ExternalShareRow({
    required this.payload,
    required this.text,
    required this.sub,
    required this.surface,
    required this.onCopyLink,
    required this.onWhatsApp,
    required this.onMessenger,
    required this.onFacebook,
    required this.onSms,
    required this.onMore,
    this.onQr,
    this.onShareImage,
  });

  @override
  Widget build(BuildContext context) {
    final items = <_ExternalItem>[
      _ExternalItem('Copy link', Icons.link_rounded, onCopyLink),
      _ExternalItem('WhatsApp', Icons.chat_rounded, onWhatsApp, const Color(0xFF25D366)),
      _ExternalItem('Messenger', Icons.send_rounded, onMessenger, const Color(0xFF0084FF)),
      _ExternalItem('Facebook', Icons.facebook_rounded, onFacebook, const Color(0xFF1877F2)),
      _ExternalItem('SMS', Icons.sms_rounded, onSms, AppColors.accent),
      if (onQr != null) _ExternalItem('QR Code', Icons.qr_code_2_rounded, onQr!),
      if (onShareImage != null) _ExternalItem('As image', Icons.image_rounded, onShareImage!),
      _ExternalItem('More', Icons.more_horiz_rounded, onMore),
    ];

    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: item.onTap,
            child: SizedBox(
              width: 72,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: sub.withValues(alpha: 0.15)),
                    ),
                    child: Icon(item.icon, color: item.color ?? text, size: 26),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: text, fontSize: 11, height: 1.2),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ExternalItem {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  _ExternalItem(this.label, this.icon, this.onTap, [this.color]);
}
