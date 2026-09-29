import 'package:flutter/material.dart';
import '../../../core/services/profile_link_service.dart';
import '../../../core/services/profile_share_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/profile_share_data.dart';
import '../profile_qr_screen.dart';
import 'profile_share_card_widget.dart';

class ProfileShareSheet extends StatefulWidget {
  final ProfileShareData data;

  const ProfileShareSheet({super.key, required this.data});

  @override
  State<ProfileShareSheet> createState() => _ProfileShareSheetState();
}

class _ProfileShareSheetState extends State<ProfileShareSheet> {
  final _cardKey = GlobalKey();

  void _snack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareProfile() async {
    _snack('Opening share options...');
    await ProfileShareService.shareNative(widget.data);
  }

  Future<void> _copyLink() async {
    try {
      await ProfileShareService.copyProfileLink(widget.data);
      if (!mounted) return;
      _snack('Profile link copied');
    } catch (e) {
      if (!mounted) return;
      _snack('Unable to copy link. Please try again.');
    }
  }

  Future<void> _shareAsImage() async {
    try {
      final bytes = await ProfileShareService.captureWidget(_cardKey);
      if (bytes == null) {
        if (mounted) {
          _snack('Unable to share profile card. Please try again.');
        }
        return;
      }
      await ProfileShareService.shareImageBytes(bytes, widget.data);
      if (!mounted) return;
      _snack('Profile card ready to share');
    } catch (e) {
      debugPrint('Share as image error: $e');
      if (mounted) {
        _snack('Unable to share profile card. Please try again.');
      }
    }
  }

  void _openQr() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProfileQrScreen(data: widget.data)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final data = widget.data;

    return Stack(
      children: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.softShadow,
                border: Border.all(color: border.withValues(alpha: 0.4)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sub.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        Text(
                          'Share Profile',
                          style: TextStyle(color: text, fontSize: 18, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, color: sub),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _HeaderPreview(data: data, text: text, sub: sub),
                  ),
                  const SizedBox(height: 12),
                  _option(Icons.ios_share_rounded, 'Share Profile', 'Use your device share sheet', _shareProfile, text, sub),
                  _option(Icons.link_rounded, 'Copy Profile Link', ProfileLinkService.publicUrl(data), _copyLink, text, sub),
                  _option(Icons.qr_code_2_rounded, 'QR Code', 'Open scannable profile QR', _openQr, text, sub),
                  _option(Icons.image_rounded, 'Share as Image', 'Professional MedDuty profile card', _shareAsImage, text, sub),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
        ProfileShareCaptureHost(cardKey: _cardKey, data: data),
      ],
    );
  }

  Widget _option(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
    Color text,
    Color sub,
  ) {
    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.accent),
      ),
      title: Text(title, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: sub, fontSize: 12),
      ),
      onTap: onTap,
    );
  }
}

class _HeaderPreview extends StatelessWidget {
  final ProfileShareData data;
  final Color text;
  final Color sub;

  const _HeaderPreview({required this.data, required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.accent,
            backgroundImage: data.avatarUrl != null ? NetworkImage(data.avatarUrl!) : null,
            child: data.avatarUrl == null
                ? Text(
                    data.avatarInitials ?? 'MD',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  )
                : null,
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
                        data.name,
                        style: TextStyle(color: text, fontWeight: FontWeight.w800, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (data.isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified_rounded, color: AppColors.info, size: 16),
                    ],
                  ],
                ),
                if (data.title != null && data.title!.isNotEmpty)
                  Text(data.title!, style: TextStyle(color: sub, fontSize: 13)),
                if (data.organization != null && data.organization!.isNotEmpty)
                  Text(data.organization!, style: TextStyle(color: sub, fontSize: 12)),
                if (data.location != null && data.location!.isNotEmpty)
                  Text(data.location!, style: TextStyle(color: sub, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileShareCaptureHost extends StatelessWidget {
  final GlobalKey cardKey;
  final ProfileShareData data;

  const ProfileShareCaptureHost({super.key, required this.cardKey, required this.data});

  @override
  Widget build(BuildContext context) {
    // Painted off-screen so RepaintBoundary capture works (Offstage skips paint).
    return Positioned(
      left: -20000,
      top: 0,
      child: Material(
        type: MaterialType.transparency,
        child: SizedBox(
          width: 360,
          child: RepaintBoundary(
            key: cardKey,
            child: ProfileShareCardWidget(data: data, qrSize: 120),
          ),
        ),
      ),
    );
  }
}
