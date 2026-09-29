import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/share_payload.dart';
import '../data/share_chat_contacts.dart';
import 'chat_navigation_helper.dart';
import 'profile_share_service.dart';
import '../../shared/widgets/med_duty_share_sheet.dart';

class MedDutyShareService {
  MedDutyShareService._();

  static void show(BuildContext context, SharePayload payload) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MedDutyShareSheet(payload: payload),
    );
  }

  static Future<void> shareToChat(
    BuildContext context, {
    required ShareChatContact contact,
    required SharePayload payload,
  }) async {
    if (!context.mounted) return;
    ChatNavigationHelper.openChat(
      context,
      receiverName: contact.name,
      receiverRole: contact.role,
      isOnline: contact.online,
      avatarColor: contact.avatarColor.toARGB32().toString(),
      initialDraft: payload.shareText,
      sendDraftImmediately: true,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Shared with ${contact.name}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> copyLink(BuildContext context, SharePayload payload) async {
    await ProfileShareService.copyUrl(payload.copyLink);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(payload.profileData != null ? 'Profile link copied' : 'Link copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static Future<void> shareViaSystem(SharePayload payload) async {
    await Share.share(payload.shareText, subject: payload.subject);
  }

  static Future<void> shareWhatsApp(SharePayload payload) async {
    final uri = Uri.parse('https://wa.me/?text=${Uri.encodeComponent(payload.shareText)}');
    await _launchExternal(uri);
  }

  static Future<void> shareSms(SharePayload payload) async {
    final uri = Uri(scheme: 'sms', queryParameters: {'body': payload.shareText});
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return;
    }
    await Share.share(payload.shareText, subject: payload.subject);
  }

  static Future<void> shareFacebook(SharePayload payload) async {
    final link = payload.copyLink;
    final uri = Uri.parse(
      'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}',
    );
    await _launchExternal(uri);
  }

  static Future<void> shareMessenger(SharePayload payload) async {
    final link = payload.copyLink;
    final messenger = Uri.parse('fb-messenger://share?link=${Uri.encodeComponent(link)}');
    if (await canLaunchUrl(messenger)) {
      await launchUrl(messenger, mode: LaunchMode.externalApplication);
      return;
    }
    await shareViaSystem(payload);
  }

  static Future<void> _launchExternal(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    await Clipboard.setData(ClipboardData(text: uri.toString()));
  }
}
