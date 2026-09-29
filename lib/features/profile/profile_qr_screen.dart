import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/services/profile_link_service.dart';
import '../../core/services/profile_share_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/profile_share_data.dart';
import 'profile_qr_scanner_screen.dart';
import 'widgets/profile_share_card_widget.dart';

class ProfileQrScreen extends StatefulWidget {
  final ProfileShareData data;

  const ProfileQrScreen({super.key, required this.data});

  @override
  State<ProfileQrScreen> createState() => _ProfileQrScreenState();
}

class _ProfileQrScreenState extends State<ProfileQrScreen> {
  final _cardKey = GlobalKey();

  void _snack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? AppColors.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _shareQr() async {
    _snack('QR code ready');
    final bytes = await ProfileShareService.captureWidget(_cardKey);
    if (bytes == null) return;
    await ProfileShareService.shareImageBytes(bytes, widget.data);
  }

  Future<void> _saveQr() async {
    final bytes = await ProfileShareService.captureWidget(_cardKey);
    if (bytes == null) {
      _snack('Could not save QR code', color: AppColors.error);
      return;
    }
    if (kIsWeb) {
      await ProfileShareService.shareImageBytes(bytes, widget.data);
      _snack('QR download started');
      return;
    }
    try {
      await Gal.putImageBytes(
        bytes,
        name: 'medduty_qr_${ProfileLinkService.slugFromName(widget.data.name)}',
      );
      _snack('QR code saved');
    } catch (_) {
      await ProfileShareService.shareImageBytes(bytes, widget.data);
      _snack('QR code ready to save via share sheet');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final card = isDark ? AppColors.darkSurface : Colors.white;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final data = widget.data;
    final payload = ProfileLinkService.qrPayload(data);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        title: Text('Profile QR Code', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
        actions: [
          if (!kIsWeb)
            IconButton(
              tooltip: 'Scan QR',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileQrScannerScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: RepaintBoundary(
                  key: _cardKey,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2121),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1505506874110-6a7a69069a08?q=80&w=1287&auto=format&fit=crop',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 36,
                                      backgroundColor: AppColors.accent,
                                      backgroundImage: data.avatarUrl != null ? NetworkImage(data.avatarUrl!) : null,
                                      child: data.avatarUrl == null
                                          ? Text(
                                              data.avatarInitials ?? 'MD',
                                              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            data.name,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                                          ),
                                        ),
                                        if (data.isVerified) ...[
                                          const SizedBox(width: 4),
                                          const Icon(Icons.verified_rounded, color: Colors.blueAccent, size: 18),
                                        ],
                                      ],
                                    ),
                                    if (data.title != null && data.title!.isNotEmpty)
                                      Text(data.title!, style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14)),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.95),
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: QrImageView(
                                        data: payload,
                                        version: QrVersions.auto,
                                        size: 170,
                                        backgroundColor: Colors.transparent,
                                        eyeStyle: const QrEyeStyle(color: Colors.black, eyeShape: QrEyeShape.square),
                                        dataModuleStyle: const QrDataModuleStyle(color: Colors.black, dataModuleShape: QrDataModuleShape.square),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 16, 12, 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'MedDuty Invitation',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '#${data.profileHandle.toUpperCase()}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 360;
                final children = [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareQr,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Share QR'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  SizedBox(width: stacked ? 0 : 12, height: stacked ? 12 : 0),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveQr,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save QR'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.accent,
                        side: const BorderSide(color: AppColors.accent),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ];
                if (stacked) {
                  return Column(children: children);
                }
                return Row(children: children);
              },
            ),
            const SizedBox(height: 24),
            Offstage(
              child: ProfileShareCardWidget(data: data),
            ),
          ],
        ),
      ),
    );
  }
}
