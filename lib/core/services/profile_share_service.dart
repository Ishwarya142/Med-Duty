import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/profile_share_data.dart';
import 'profile_link_service.dart';

class ProfileShareService {
  ProfileShareService._();

  static Future<void> shareNative(ProfileShareData data) async {
    await Share.share(
      ProfileLinkService.shareText(data),
      subject: 'MedDuty Profile — ${data.name}',
    );
  }

  static Future<void> copyProfileLink(ProfileShareData data) async {
    await copyUrl(ProfileLinkService.publicUrl(data));
  }

  static Future<void> copyUrl(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
  }

  static Future<void> shareImageBytes(Uint8List bytes, ProfileShareData data) async {
    final file = XFile.fromData(
      bytes,
      mimeType: 'image/png',
      name: 'medduty_${ProfileLinkService.slugFromName(data.name)}.png',
    );
    await Share.shareXFiles(
      [file],
      text: 'MedDuty Profile — ${data.name}\n${ProfileLinkService.publicUrl(data)}',
      subject: 'MedDuty Profile Card',
    );
  }

  /// Captures a widget behind a [GlobalKey] on a [RepaintBoundary].
  /// Waits for layout/paint — required because off-screen hosts may not paint immediately.
  static Future<Uint8List?> captureWidget(
    GlobalKey key, {
    double pixelRatio = 3,
    int maxAttempts = 6,
  }) async {
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      await Future<void>.delayed(Duration(milliseconds: 40 * (attempt + 1)));
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) continue;
      if (boundary.debugNeedsPaint) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      try {
        final image = await boundary.toImage(pixelRatio: pixelRatio);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        final bytes = byteData?.buffer.asUint8List();
        if (bytes != null && bytes.isNotEmpty) return bytes;
      } catch (e) {
        debugPrint('ProfileShareService capture attempt $attempt failed: $e');
      }
    }
    return null;
  }
}
