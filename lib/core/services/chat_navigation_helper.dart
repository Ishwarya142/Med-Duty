import 'package:flutter/material.dart';

import '../../features/chat/chat_screen.dart';

/// Opens an existing MedDuty chat thread.
class ChatNavigationHelper {
  ChatNavigationHelper._();

  static void openChat(
    BuildContext context, {
    required String receiverName,
    required String receiverRole,
    bool isOnline = true,
    String? avatarColor,
    String? initialDraft,
    bool sendDraftImmediately = false,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          receiverName: receiverName,
          receiverRole: receiverRole,
          isOnline: isOnline,
          avatarColor: avatarColor,
          initialDraft: initialDraft,
          sendDraftImmediately: sendDraftImmediately,
        ),
      ),
    );
  }
}
