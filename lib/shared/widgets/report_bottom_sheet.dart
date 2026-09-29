import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/settings_preferences_provider.dart';

const List<String> healthcareReportReasons = [
  'Spam',
  'Harassment',
  'Impersonation',
  'Fake professional',
  'Fraud',
  'Inappropriate content',
  'Privacy violation',
  'Other',
];

/// Unified healthcare report flow for Profiles, Posts, Comments, Messages, Jobs, and Duties.
Future<void> showContentReportSheet(
  BuildContext context, {
  required String subjectLabel,
  String? targetId,
  String? targetName,
  String reportType = 'content', // profile, post, comment, message, job, duty
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? AppColors.darkSurface : Colors.white;
  final text = isDark ? AppColors.darkText : AppColors.lightText;
  final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (_, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: text, size: 22),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                      Expanded(
                        child: Text(
                          'Report $subjectLabel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: text,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    children: [
                      Text(
                        'Why are you reporting this $subjectLabel?',
                        style: TextStyle(
                          color: text,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your report is kept strictly confidential. Our medical moderation team reviews reported violations promptly.',
                        style: TextStyle(
                          color: sub,
                          height: 1.45,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...healthcareReportReasons.map(
                        (reason) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () async {
                                Navigator.pop(ctx);
                                String finalReason = reason;

                                if (reason == 'Other' && context.mounted) {
                                  final customReason = await _showOtherReasonDialog(context);
                                  if (customReason != null && customReason.isNotEmpty) {
                                    finalReason = 'Other: $customReason';
                                  }
                                }

                                final reportData = <String, String>{
                                  'type': reportType,
                                  'reason': finalReason,
                                  'targetLabel': subjectLabel,
                                  'createdAt': DateTime.now().toIso8601String(),
                                };
                                if (targetId != null) reportData['targetId'] = targetId;
                                if (targetName != null) reportData['targetName'] = targetName;

                                try {
                                  if (context.mounted) {
                                    await context
                                        .read<SettingsPreferencesProvider>()
                                        .saveIssueReport(reportData);
                                  }
                                } catch (_) {}

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              'Report submitted ($finalReason). Thank you for helping keep MedDuty safe.',
                                              style: const TextStyle(fontSize: 13),
                                            ),
                                          ),
                                        ],
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      backgroundColor: const Color(0xFF0F766E),
                                      duration: const Duration(seconds: 4),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        reason,
                                        style: TextStyle(
                                          color: text,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: sub,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Future<String?> _showOtherReasonDialog(BuildContext context) async {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Provide details'),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Please describe the safety or privacy issue...',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, null),
          child: const Text('Skip'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, controller.text.trim()),
          child: const Text('Submit Report'),
        ),
      ],
    ),
  );
}
