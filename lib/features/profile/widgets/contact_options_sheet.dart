// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/supabase_adapters.dart';

import '../../../core/services/chat_navigation_helper.dart';
import '../../chat/voice_call_screen.dart';
import '../../chat/video_call_screen.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);

/// Contact options for public profiles (Voice Call, Video Call, Phone, Message, Email).
class ContactOptionsSheet extends StatelessWidget {
  const ContactOptionsSheet({
    super.key,
    required this.displayName,
    this.userId,
    this.phone,
    this.email,
    this.website,
    this.role,
    this.showMessage = true,
  });

  final String displayName;
  final String? userId;
  final String? phone;
  final String? email;
  final String? website;
  final String? role;
  final bool showMessage;

  static Future<void> show(
    BuildContext context, {
    required String displayName,
    String? userId,
    String? phone,
    String? email,
    String? website,
    String? role,
    bool showMessage = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ContactOptionsSheet(
        displayName: displayName,
        userId: userId,
        phone: phone,
        email: email,
        website: website,
        role: role,
        showMessage: showMessage,
      ),
    );
  }

  /// Loads contact fields from Firestore when not provided.
  static Future<void> showForUser(
    BuildContext context, {
    required String userId,
    required String displayName,
    String? role,
    bool showMessage = true,
  }) async {
    String? phone;
    String? email;
    String? website;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        phone = _clean(data['phone']);
        email = _clean(data['email'] ?? data['publicEmail']);
        website = _clean(data['websiteUrl'] ?? data['website']);
      }
    } catch (_) {
      // Use empty contact fields — sheet will show fallback options.
    }

    if (!context.mounted) return;
    await show(
      context,
      displayName: displayName,
      userId: userId,
      phone: phone,
      email: email,
      website: website,
      role: role,
      showMessage: showMessage,
    );
  }

  static Future<void> showForHospital(
    BuildContext context, {
    required String hospitalId,
    required String hospitalName,
    String? role,
  }) async {
    String? phone;
    String? email;
    String? website;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('hospitals')
          .doc(hospitalId)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        phone = _clean(data['phone'] ?? data['contactPhone']);
        email = _clean(data['email'] ?? data['contactEmail']);
        website = _clean(data['website'] ?? data['websiteUrl']);
      }
    } catch (_) {}

    if (!context.mounted) return;
    await show(
      context,
      displayName: hospitalName,
      phone: phone,
      email: email,
      website: website,
      role: role ?? 'Hospital',
      showMessage: true,
    );
  }

  static String? _clean(dynamic value) {
    final s = value?.toString().trim();
    if (s == null || s.isEmpty) return null;
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final hasPhone = phone != null && phone!.isNotEmpty;
    final hasEmail = email != null && email!.isNotEmpty;
    final hasWebsite = website != null && website!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sub.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Contact $displayName',
            style: TextStyle(
              color: tx,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how you would like to connect.',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 16),

          // 1. In-App HD Audio Call
          _actionTile(
            context,
            icon: Icons.phone_in_talk_rounded,
            iconColor: _cTeal,
            title: 'MedDuty Audio Call',
            subtitle: 'Secure 1-to-1 HD voice call',
            badge: 'HD Voice',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoiceCallScreen(
                    receiverName: displayName,
                    receiverRole: role ?? 'Healthcare Specialist',
                    isOnline: true,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // 2. In-App HD Video Call
          _actionTile(
            context,
            icon: Icons.videocam_rounded,
            iconColor: _cBlue,
            title: 'MedDuty Video Call',
            subtitle: '1-to-1 clinical consultation',
            badge: 'HD Video',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoCallScreen(
                    receiverName: displayName,
                    receiverRole: role ?? 'Healthcare Specialist',
                    isOnline: true,
                  ),
                  fullscreenDialog: true,
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // 3. Direct Phone Call (if available)
          if (hasPhone) ...[
            _actionTile(
              context,
              icon: Icons.phone_android_rounded,
              iconColor: _cGreen,
              title: 'Cellular Phone Call',
              subtitle: phone!,
              onTap: () => _launchTel(context, phone!),
              trailing: IconButton(
                icon: Icon(Icons.copy_rounded, color: sub, size: 20),
                onPressed: () => _copy(context, phone!, 'Phone number copied'),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 4. In-App Message
          if (showMessage) ...[
            _actionTile(
              context,
              icon: Icons.chat_bubble_outline_rounded,
              iconColor: _cTeal,
              title: 'Message',
              subtitle: 'Open MedDuty chat conversation',
              onTap: () {
                Navigator.pop(context);
                ChatNavigationHelper.openChat(
                  context,
                  receiverName: displayName,
                  receiverRole: role ?? 'Healthcare Specialist',
                );
              },
            ),
            const SizedBox(height: 8),
          ],

          // 5. Email (if available)
          if (hasEmail) ...[
            _actionTile(
              context,
              icon: Icons.email_outlined,
              iconColor: _cBlue,
              title: 'Email',
              subtitle: email!,
              onTap: () => _launchEmail(context, email!),
              trailing: IconButton(
                icon: Icon(Icons.copy_rounded, color: sub, size: 20),
                onPressed: () => _copy(context, email!, 'Email copied'),
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 6. Website (if available)
          if (hasWebsite) ...[
            _actionTile(
              context,
              icon: Icons.language_rounded,
              iconColor: _cTeal,
              title: 'Website',
              subtitle: website!,
              onTap: () => _launchUrl(context, website!),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? badge,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: card,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: tx,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: iconColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(color: sub, fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else
                Icon(Icons.chevron_right_rounded, color: sub, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchTel(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:${phone.replaceAll(' ', '')}');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _copy(context, phone, 'Phone copied (unable to open dialer)');
      }
    } catch (_) {
      if (!context.mounted) return;
      _copy(context, phone, 'Phone copied');
    }
  }

  Future<void> _launchEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (!context.mounted) return;
        _copy(context, email, 'Email copied');
      }
    } catch (_) {
      if (!context.mounted) return;
      _copy(context, email, 'Email copied');
    }
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    var raw = url.trim();
    if (!raw.startsWith('http://') && !raw.startsWith('https://')) {
      raw = 'https://$raw';
    }
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _copy(BuildContext context, String value, String message) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _cTeal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
