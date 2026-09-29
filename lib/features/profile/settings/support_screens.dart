import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/support_config.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  static const _sections = {
    'Duties': [
      'How do I apply for a duty?',
      'Open a duty from Home or Duties, review details, then tap Apply.',
      'How do I find nearby duties?',
      'Use Nearby Duties or the map to discover duties based on your selected location and radius.',
      'How do I save a duty?',
      'Tap the save/bookmark action on a duty card or duty details screen.',
    ],
    'Community': [
      'How do I create a post?',
      'Go to Community and use the create post option to share updates or images.',
      'How do I follow other doctors?',
      'Open a public profile and tap Follow.',
    ],
    'Chat & Calls': [
      'How do I send a voice message?',
      'Press and hold the microphone button in chat.',
      'How do I start a call?',
      'Use the call icons in the chat header.',
    ],
    'Profile': [
      'How do I edit my profile?',
      'Open Profile → Edit Profile to update your professional details.',
      'How do I share my profile?',
      'Use the Share option on your profile or public profile screens.',
    ],
    'Account & Security': [
      'How do I change my password?',
      'Go to Settings → Change Password.',
      'How do I manage privacy?',
      'Use Settings → Profile Visibility / Privacy options.',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, context.l10n.helpCenter, text, bg),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _sections.entries.map((section) {
          final tiles = <Widget>[];
          for (var i = 0; i < section.value.length; i += 2) {
            tiles.add(
              ExpansionTile(
                title: Text(section.value[i], style: TextStyle(color: text, fontWeight: FontWeight.w600, fontSize: 14)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(section.value[i + 1], style: TextStyle(color: sub, height: 1.4)),
                    ),
                  ),
                ],
              ),
            );
          }
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              initiallyExpanded: section.key == 'Duties',
              title: Text(section.key, style: TextStyle(color: text, fontWeight: FontWeight.w800)),
              children: tiles,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    ('How does MedDuty work?', 'MedDuty connects healthcare professionals with duty opportunities, community networking, messaging, and professional profiles.'),
    ('How can I find nearby duties?', 'Use location-based discovery on Home or the Duties map. Adjust your location and radius to see relevant openings.'),
    ('How do I apply for a duty?', 'Open a duty, review hospital details and timing, then tap Apply from the duty details screen.'),
    ('How can I contact a hospital?', 'Use duty details, hospital public profiles, or messaging where available.'),
    ('How do I change my profile?', 'Go to Profile and tap Edit Profile.'),
    ('How does location-based duty discovery work?', 'MedDuty uses your selected location and radius to show nearby duties on the map and list views.'),
    ('How do I block a user?', 'Open the user\'s chat or contact info and use the block option. Manage blocked users in Settings → Blocked Users.'),
    ('How do I report a problem?', 'Use Settings → Report Issue to record a support request locally.'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, context.l10n.faq, text, bg),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _faqs.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = _faqs[index];
          return Card(
            child: ExpansionTile(
              title: Text(item.$1, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.$2, style: TextStyle(color: sub, height: 1.45)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ReportIssueScreen extends StatefulWidget {
  const ReportIssueScreen({super.key});

  @override
  State<ReportIssueScreen> createState() => _ReportIssueScreenState();
}

class _ReportIssueScreenState extends State<ReportIssueScreen> {
  final _descriptionCtrl = TextEditingController();
  final _picker = ImagePicker();
  String? _issueType;
  XFile? _image;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file != null && mounted) setState(() => _image = file);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final types = l10n.issueTypes;
    _issueType ??= types.first;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, l10n.reportIssue, text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _issueType,
            decoration: InputDecoration(
              labelText: l10n.issueType,
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _issueType = v ?? _issueType),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionCtrl,
            maxLines: 6,
            decoration: InputDecoration(
              labelText: l10n.description,
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image_outlined, color: AppColors.accent),
            label: Text(l10n.addScreenshot, style: TextStyle(color: text)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              side: const BorderSide(color: AppColors.accent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          if (_image != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FutureBuilder<Uint8List>(
                future: _image!.readAsBytes(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
                  }
                  return Image.memory(
                    snapshot.data!,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _image = null),
              child: Text(l10n.removeImage, style: const TextStyle(color: AppColors.error)),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitting
                  ? null
                  : () async {
                      final prefs = context.read<SettingsPreferencesProvider>();
                      final l10nMsg = l10n.reportRecorded;
                      final navigator = Navigator.of(context);
                      final messenger = ScaffoldMessenger.of(context);

                      setState(() => _submitting = true);
                      String? imageData;
                      String? imageName;
                      if (_image != null) {
                        imageName = _image!.name;
                        if (kIsWeb) {
                          final bytes = await _image!.readAsBytes();
                          imageData = base64Encode(bytes);
                        } else {
                          imageData = _image!.path;
                        }
                      }

                      final reportData = <String, String>{
                        'type': _issueType!,
                        'description': _descriptionCtrl.text.trim(),
                        'createdAt': DateTime.now().toIso8601String(),
                      };
                      if (imageName != null) {
                        reportData['imageName'] = imageName;
                      }
                      if (imageData != null) {
                        reportData['imageData'] = imageData;
                      }

                      await prefs.saveIssueReport(reportData);
                      if (!mounted) return;
                      setState(() => _submitting = false);
                      messenger.showSnackBar(
                        SnackBar(
                          content: Text(l10nMsg),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.accent,
                        ),
                      );
                      navigator.pop();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(_submitting ? l10n.submitting : l10n.submitReport),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  Future<void> _openEmail(BuildContext context) async {
    final l10n = context.l10n;
    final uri = Uri(
      scheme: 'mailto',
      path: SupportConfig.supportEmail,
      queryParameters: {'subject': 'MedDuty Support Request'},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) SettingsUi.snack(context, l10n.couldNotOpenEmail);
    }
  }

  Future<void> _openPhone(BuildContext context) async {
    final l10n = context.l10n;
    final uri = Uri(scheme: 'tel', path: SupportConfig.supportPhoneE164);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) SettingsUi.snack(context, l10n.couldNotOpenPhone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, l10n.contactSupport, text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.howCanWeHelp, style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          ListTile(
            tileColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.email_outlined, color: AppColors.accent),
            title: Text(l10n.emailSupport, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
            subtitle: Text(SupportConfig.supportEmail, style: TextStyle(color: sub, fontSize: 12)),
            onTap: () => _openEmail(context),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.call_outlined, color: AppColors.accent),
            title: Text(l10n.callSupport, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
            subtitle: Text(SupportConfig.supportPhoneDisplay, style: TextStyle(color: sub, fontSize: 12)),
            onTap: () => _openPhone(context),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            leading: const Icon(Icons.quiz_outlined, color: AppColors.accent),
            title: Text(l10n.faq, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
          ),
        ],
      ),
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  static const _termsBody = '''
Last updated: August 2026

Welcome to MedDuty. These Terms & Conditions govern your use of the MedDuty mobile and web application. By creating an account or using MedDuty, you agree to follow these terms and use the platform responsibly.

1. Professional Use Only
MedDuty is designed exclusively for licensed healthcare professionals, hospitals, and authorized medical staff. You must provide accurate credentials and professional information. Misrepresentation of qualifications is strictly prohibited.

2. Acceptable Conduct
You agree to maintain professional discipline at all times. You must not:
• Use MedDuty for any irregular, unlawful, or fraudulent activity
• Harass, threaten, or abuse other users
• Share false medical information or misleading duty listings
• Attempt to bypass security, scrape data, or disrupt platform services
• Use the app for personal purposes unrelated to legitimate healthcare duties

3. Duties & Applications
Duty postings must be genuine and comply with applicable employment and healthcare regulations. Applicants must respond honestly and honor accepted commitments unless properly cancelled through approved channels.

4. Messaging & Community
Communications must remain professional. Do not share patient-identifiable information unless you are authorized and compliant with applicable privacy laws. Spam, hate speech, and inappropriate content are not permitted.

5. Account Security
You are responsible for safeguarding your login credentials. Enable two-factor authentication where available. Notify MedDuty support immediately if you suspect unauthorized access.

6. Privacy
Your use of MedDuty is also governed by our Privacy Policy. We collect and process data to provide duty discovery, messaging, and profile services. Do not misuse another user's personal information.

7. Content Ownership
You retain ownership of content you submit, but grant MedDuty a limited license to display it within the platform. MedDuty may remove content that violates these terms.

8. Suspension & Termination
We may suspend or terminate accounts that violate these terms, engage in irregular activity, or pose risk to users or the platform. You may delete your account at any time through Settings.

9. Disclaimers
MedDuty facilitates connections between professionals and facilities but does not guarantee employment outcomes, duty availability, or third-party conduct. Use independent judgment in all professional decisions.

10. Contact
For questions about these terms, contact support at ishwaryak.cse1024@citchennai.net.

By continuing to use MedDuty, you confirm that you have read, understood, and agree to these Terms & Conditions and will use the platform only for lawful, professional healthcare purposes.
''';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, l10n.termsAndConditions, text, bg),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          _termsBody,
          style: TextStyle(color: sub, height: 1.55, fontSize: 15),
        ),
      ),
    );
  }
}
