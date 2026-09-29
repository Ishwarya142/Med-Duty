// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/settings_preferences_provider.dart';
import '../../providers/theme_provider.dart';
import '../../app/app_routes.dart';
import 'change_password_screen.dart';
import 'privacy_screen.dart';
import 'theme_screen.dart';
import 'edit_profile_screen.dart';
import 'medical_license_screen.dart';
import 'certificates_screen.dart';
import 'professional_documents_screen.dart';
import 'duty_information_screen.dart';
import 'saved_screen.dart';
import 'applications_screen.dart';
import 'activity_screen.dart';
import 'ratings_screen.dart';
import 'wallet_screen.dart';
import 'settings/account_info_screen.dart';
import 'settings/email_phone_screen.dart';
import 'settings/notification_settings_screens.dart';
import 'settings/online_status_screen.dart';
import 'settings/followers_following_screen.dart';
import 'settings/blocked_users_screen.dart';
import 'settings/security_screens.dart';
import 'settings/permissions_screen.dart';
import 'settings/support_screens.dart';
import 'settings/account_control_screens.dart';
import 'settings/two_factor_setup_screen.dart';
import 'settings/settings_search_catalog.dart';
import 'settings/settings_search_screen.dart';
import 'settings/duty_preferences_screen.dart';
import 'settings/job_preferences_screen.dart';
import 'settings/connected_accounts_screen.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cRed    = Color(0xFFEF4444);
const _cPurple = Color(0xFF7C3AED);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _appVersion = '';
  String _textSize = 'Medium';
  bool _dataSaver = false;

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _appVersion = 'v${info.version}');
    } catch (_) {
      if (mounted) setState(() => _appVersion = 'v1.0.0');
    }
  }

  void _push(Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _cTeal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _showLanguageSheet(
    BuildContext context, {
    required Color surfaceColor,
    required Color textColor,
    required Color subTextColor,
  }) async {
    final prefs = context.read<SettingsPreferencesProvider>();
    final l10n = context.l10n;
    final languages = [
      {'code': 'en', 'name': 'English', 'native': 'English'},
      {'code': 'hi', 'name': 'Hindi', 'native': 'हिन्दी'},
      {'code': 'ta', 'name': 'Tamil', 'native': 'தமிழ்'},
      {'code': 'te', 'name': 'Telugu', 'native': 'తెలుగు'},
      {'code': 'kn', 'name': 'Kannada', 'native': 'ಕನ್ನಡ'},
      {'code': 'ml', 'name': 'Malayalam', 'native': 'മലയാളം'},
    ];
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.65,
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subTextColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.language,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: languages.map((item) {
                      final name = item['name']!;
                      final native = item['native']!;
                      final isSelected = prefs.language == name || prefs.language == native || (prefs.language == 'English' && name == 'English');
                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? _cTeal.withValues(alpha: 0.08) : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: isSelected ? Border.all(color: _cTeal.withValues(alpha: 0.3)) : null,
                        ),
                        child: RadioListTile<String>(
                          title: Row(
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14.5,
                                ),
                              ),
                              if (name != native) ...[
                                const SizedBox(width: 8),
                                Text(
                                  '($native)',
                                  style: TextStyle(
                                    color: subTextColor,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          value: name,
                          groupValue: isSelected ? name : '',
                          activeColor: _cTeal,
                          onChanged: (v) async {
                            if (v == null) return;
                            await prefs.setLanguage(v);
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (context.mounted) {
                              setState(() {});
                              _showSnackBar('Language updated to $v');
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showTextSizeSheet(BuildContext context, Color card, Color tx) async {
    final options = ['Small', 'Medium', 'Large'];
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Text Size',
                style: TextStyle(
                  color: tx,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...options.map(
                (size) => RadioListTile<String>(
                  title: Text(size, style: TextStyle(color: tx)),
                  value: size,
                  groupValue: _textSize,
                  activeColor: _cTeal,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _textSize = v);
                    Navigator.pop(ctx);
                    _showSnackBar('Text size updated to $v');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showAvailabilitySheet(
    BuildContext context,
    ProfileProvider profile,
    Color card,
    Color tx,
    Color sub,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Duty & Job Availability',
                style: TextStyle(
                  color: tx,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Control whether hospitals can assign or invite you to duties.',
                style: TextStyle(color: sub, fontSize: 13),
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _cGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: _cGreen),
                ),
                title: Text('Available for Duties', style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
                subtitle: Text('Visible to hospitals for immediate and scheduled shifts', style: TextStyle(color: sub, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () async {
                  await profile.updateProfile(emergencyAvailable: true);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) _showSnackBar('Availability set to Available');
                },
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _cRed.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.remove_circle_outline, color: _cRed),
                ),
                title: Text('Emergency Only', style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
                subtitle: Text('Only receive critical ICU / ER emergency duty requests', style: TextStyle(color: sub, fontSize: 12)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                onTap: () async {
                  await profile.updateProfile(emergencyAvailable: true);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) _showSnackBar('Availability set to Emergency Only');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openSettingsSearch() {
    final l10n = context.l10n;
    final actions = SettingsSearchActions(
      openAccountInfo: () => _push(const AccountInfoScreen()),
      openChangePassword: () => _push(const ChangePasswordScreen()),
      openEmailPhone: () => _push(const EmailPhoneScreen()),
      openDeactivateAccount: () => _push(const DeactivateAccountScreen()),
      openDeleteAccount: () => _push(const DeleteAccountWarningScreen()),
      openPushNotifications: () => _push(const PushNotificationsScreen()),
      openDutyAlerts: () => _push(const DutyAlertsScreen()),
      openCommunityNotifications: () => _push(const CommunityNotificationsScreen()),
      openMessageNotifications: () => _push(const MessageNotificationsScreen()),
      openProfileVisibility: () => _push(const PrivacyScreen()),
      openOnlineStatus: () => _push(const OnlineStatusScreen()),
      openFollowersFollowing: () => _push(const FollowersFollowingScreen()),
      openBlockedUsers: () => _push(const BlockedUsersScreen()),
      openBiometric: () {},
      openTwoFactor: () => _push(const TwoFactorSetupScreen()),
      openLoginActivity: () => _push(const LoginActivityScreen()),
      openTrustedDevices: () => _push(const TrustedDevicesScreen()),
      openAppearance: () => _push(const ThemeScreen()),
      openLanguage: () {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        _showLanguageSheet(
          context,
          surfaceColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          textColor: isDark ? Colors.white : const Color(0xFF0F172A),
          subTextColor: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        );
      },
      openPermissions: () => _push(const PermissionsScreen()),
      openHelpCenter: () => _push(const HelpCenterScreen()),
      openFaq: () => _push(const FaqScreen()),
      openReportIssue: () => _push(const ReportIssueScreen()),
      openContactSupport: () => _push(const ContactSupportScreen()),
      openTerms: () => _push(const TermsScreen()),
      openPrivacyPolicy: () => _push(const PrivacyScreen()),
      openAppVersion: () {},
      openDutyPreferences: () => _push(const DutyPreferencesScreen()),
      openJobPreferences: () => _push(const JobPreferencesScreen()),
      openConnectedAccounts: () => _push(const ConnectedAccountsScreen()),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsSearchScreen(
          items: buildSettingsSearchCatalog(l10n: l10n, actions: actions),
        ),
      ),
    );
  }

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    Color surfaceColor,
    Color textColor,
    Color subTextColor,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: surfaceColor,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Log out of MedDuty?',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'You can sign back in anytime using your account credentials.',
          style: TextStyle(color: subTextColor, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: _cRed),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await authProvider.logout();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final profile = Provider.of<ProfileProvider>(context);
    final settingsPrefs = Provider.of<SettingsPreferencesProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final doctorName = profile.name.isNotEmpty
        ? profile.name
        : (authProvider.userData?['name'] ?? 'Dr. Neha Verma');
    final specialty = profile.specialization.isNotEmpty
        ? profile.specialization
        : (profile.qualification.isNotEmpty
            ? profile.qualification
            : 'General Physician');
    final hospital = profile.currentHospital.isNotEmpty
        ? profile.currentHospital
        : 'Max Hospital, Delhi';

    String getThemeLabel() {
      switch (themeProvider.themeModeOption) {
        case ThemeModeOption.light:
          return 'Light';
        case ThemeModeOption.dark:
          return 'Dark';
        case ThemeModeOption.system:
          return 'System';
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                color: tx,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage your account, preferences & app settings',
              style: TextStyle(color: sub, fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: tx, size: 24),
            onPressed: _openSettingsSearch,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 50),
        children: [
          // ── Compact Profile Summary Card ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: _cTeal,
                          backgroundImage: (profile.localProfilePicPath != null &&
                                  !kIsWeb)
                              ? FileImage(File(profile.localProfilePicPath!))
                                  as ImageProvider
                              : (profile.profilePic.isNotEmpty
                                  ? NetworkImage(profile.profilePic)
                                  : null),
                          child: (profile.localProfilePicPath == null || kIsWeb) &&
                                  profile.profilePic.isEmpty
                              ? const Icon(
                                  Icons.person_rounded,
                                  size: 28,
                                  color: Colors.white,
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: _cGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: card, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Name, Role & Hospital
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  doctorName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: tx,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: _cTeal,
                                size: 16,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            specialty,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: tx.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            hospital,
                            style: TextStyle(fontSize: 11.5, color: sub),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // View Profile Action Pill
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _cTeal,
                        side: const BorderSide(color: _cTeal, width: 1.2),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Profile Completion Progress Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile completion',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: sub,
                      ),
                    ),
                    const Text(
                      '85%',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _cTeal,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.85,
                    backgroundColor: _cTeal.withValues(alpha: 0.12),
                    valueColor: const AlwaysStoppedAnimation(_cTeal),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── 1. Account & Security ──────────────────────────────────────────
          _buildSectionHeader('Account & Security', Icons.shield_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.person_outline_rounded,
              'Account Information',
              'Personal details, profile info',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const AccountInfoScreen()),
            ),
            _buildTile(
              Icons.devices_rounded,
              'Login & Devices',
              'Manage your active sessions',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const LoginActivityScreen()),
            ),
            _buildTile(
              Icons.lock_outline_rounded,
              'Change Password',
              'Update your password regularly',
              _cAmber,
              tx,
              sub,
              onTap: () => _push(const ChangePasswordScreen()),
            ),
            _buildTile(
              Icons.email_outlined,
              'Email & Phone',
              'Manage your contact details',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const EmailPhoneScreen()),
            ),
            _buildTile(
              Icons.security_rounded,
              'Two-Factor Authentication',
              'Add extra security to your account',
              _cGreen,
              tx,
              sub,
              badge: settingsPrefs.twoFactorEnabled
                  ? _buildBadge('Enabled', _cGreen)
                  : _buildBadge('Not Set', sub),
              onTap: () => _push(const TwoFactorSetupScreen()),
            ),
            _buildTile(
              Icons.link_rounded,
              'Connected Accounts',
              'Google and other connected accounts',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const ConnectedAccountsScreen()),
            ),
            _buildTile(
              Icons.pause_circle_outline_rounded,
              'Deactivate Account',
              'Temporarily deactivate your account',
              _cAmber,
              tx,
              sub,
              onTap: () => _push(const DeactivateAccountScreen()),
            ),
            _buildTile(
              Icons.delete_outline_rounded,
              'Delete Account',
              'Permanently delete your account and data',
              _cRed,
              _cRed,
              sub,
              onTap: () => _push(const DeleteAccountWarningScreen()),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 2. Professional ────────────────────────────────────────────────
          _buildSectionHeader('Professional', Icons.medical_services_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.badge_outlined,
              'Professional Information',
              'Specialty, experience, registration',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const EditProfileScreen()),
            ),
            _buildTile(
              Icons.verified_outlined,
              'Verification',
              'Verify your identity & documents',
              _cBlue,
              tx,
              sub,
              badge: _buildBadge('✓ Verified', _cTeal),
              onTap: () => _push(const MedicalLicenseScreen()),
            ),
            _buildTile(
              Icons.description_outlined,
              'Documents',
              'Upload and manage your documents',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const ProfessionalDocumentsScreen()),
            ),
            _buildTile(
              Icons.event_available_rounded,
              'Availability',
              'Set your availability for duties & jobs',
              _cGreen,
              tx,
              sub,
              badge: _buildBadge('● Available', _cGreen),
              onTap: () => _showAvailabilitySheet(context, profile, card, tx, sub),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 3. Duties & Jobs ───────────────────────────────────────────────
          _buildSectionHeader('Duties & Jobs', Icons.assignment_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.tune_rounded,
              'Duty Preferences',
              'Set your duty search preferences',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const DutyPreferencesScreen()),
            ),
            _buildTile(
              Icons.work_outline_rounded,
              'Job Preferences',
              'Set your job search preferences',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const JobPreferencesScreen()),
            ),
            _buildTile(
              Icons.location_on_outlined,
              'Location & Search Radius',
              'Manage location & search radius',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const DutyPreferencesScreen()),
            ),
            _buildTile(
              Icons.notifications_active_outlined,
              'Job Alerts',
              'Get notified about matching jobs',
              _cAmber,
              tx,
              sub,
              onTap: () => _push(const DutyAlertsScreen()),
            ),
            _buildTile(
              Icons.emergency_outlined,
              'Duty Alerts',
              'Get notified about nearby duties',
              _cRed,
              tx,
              sub,
              onTap: () => _push(const DutyAlertsScreen()),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 4. Privacy & Safety ────────────────────────────────────────────
          _buildSectionHeader('Privacy & Safety', Icons.privacy_tip_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.lock_outline_rounded,
              'Privacy',
              'Manage who can see your information',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const PrivacyScreen()),
            ),
            _buildTile(
              Icons.circle,
              'Activity Status',
              'Control your online status',
              _cGreen,
              tx,
              sub,
              onTap: () => _push(const OnlineStatusScreen()),
            ),
            _buildTile(
              Icons.block_rounded,
              'Blocked Accounts',
              'Manage blocked users & hospitals',
              _cRed,
              tx,
              sub,
              onTap: () => _push(const BlockedUsersScreen()),
            ),
            _buildTile(
              Icons.shield_moon_outlined,
              'Safety & Trust',
              'Reports, guidelines & safety tools',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const ReportIssueScreen()),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 5. Notifications ───────────────────────────────────────────────
          _buildSectionHeader('Notifications', Icons.notifications_none_rounded, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.notifications_outlined,
              'Push Notifications',
              'Manage push notification preferences',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const PushNotificationsScreen()),
            ),
            _buildTile(
              Icons.chat_bubble_outline_rounded,
              'Messages',
              'Manage message notifications',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const MessageNotificationsScreen()),
            ),
            _buildTile(
              Icons.calendar_today_rounded,
              'Duty Alerts',
              'Manage duty related alerts',
              _cAmber,
              tx,
              sub,
              onTap: () => _push(const DutyAlertsScreen()),
            ),
            _buildTile(
              Icons.work_outline_rounded,
              'Job Alerts',
              'Manage job related alerts',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const DutyAlertsScreen()),
            ),
            _buildTile(
              Icons.groups_outlined,
              'Community',
              'Manage community notifications',
              _cGreen,
              tx,
              sub,
              onTap: () => _push(const CommunityNotificationsScreen()),
            ),
            _buildTile(
              Icons.email_outlined,
              'Email Notifications',
              'Manage email notification preferences',
              _cBlue,
              tx,
              sub,
              onTap: () => _showSnackBar('Email notifications enabled'),
            ),
            _buildTile(
              Icons.volume_up_outlined,
              'Sound & Vibration',
              'Customize sounds and vibration',
              _cTeal,
              tx,
              sub,
              onTap: () => _showSnackBar('Sound and vibration set to default'),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 6. Appearance & Accessibility ──────────────────────────────────
          _buildSectionHeader('Appearance & Accessibility', Icons.palette_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.language_rounded,
              'Language',
              'Choose your preferred language',
              _cTeal,
              tx,
              sub,
              trailingText: settingsPrefs.language,
              onTap: () => _showLanguageSheet(
                context,
                surfaceColor: card,
                textColor: tx,
                subTextColor: sub,
              ),
            ),
            _buildTile(
              Icons.brightness_6_rounded,
              'Theme',
              'Choose light, dark or system theme',
              _cBlue,
              tx,
              sub,
              trailingText: getThemeLabel(),
              onTap: () => _push(const ThemeScreen()),
            ),
            _buildTile(
              Icons.text_fields_rounded,
              'Text Size',
              'Adjust the text size',
              _cAmber,
              tx,
              sub,
              trailingText: _textSize,
              onTap: () => _showTextSizeSheet(context, card, tx),
            ),
            _buildTile(
              Icons.accessibility_new_rounded,
              'Accessibility',
              'Accessibility & display options',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const PermissionsScreen()),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _cGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.data_saver_on_outlined, color: _cGreen, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Saver',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: tx,
                          ),
                        ),
                        Text(
                          'Reduce mobile data usage',
                          style: TextStyle(fontSize: 11.5, color: sub),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _dataSaver,
                    activeColor: _cTeal,
                    onChanged: (v) {
                      setState(() => _dataSaver = v);
                      _showSnackBar(v ? 'Data saver enabled' : 'Data saver disabled');
                    },
                  ),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 7. Activity ────────────────────────────────────────────────────
          _buildSectionHeader('Activity', Icons.history_rounded, _cTeal, tx),
          const SizedBox(height: 8),
          _buildSectionCard(card, border, [
            _buildTile(
              Icons.bookmark_border_rounded,
              'Saved',
              'View your saved duties & jobs',
              _cPurple,
              tx,
              sub,
              onTap: () => _push(const SavedScreen()),
            ),
            _buildTile(
              Icons.assignment_turned_in_outlined,
              'Applications',
              'View your applied duties & jobs',
              _cTeal,
              tx,
              sub,
              onTap: () => _push(const ApplicationsScreen()),
            ),
            _buildTile(
              Icons.check_circle_outline_rounded,
              'Completed Duties',
              'View your completed duties',
              _cGreen,
              tx,
              sub,
              onTap: () => _push(const DutyInformationScreen()),
            ),
            _buildTile(
              Icons.edit_note_rounded,
              'My Posts',
              'View your community posts',
              _cBlue,
              tx,
              sub,
              onTap: () => _push(const ActivityScreen()),
            ),
            _buildTile(
              Icons.star_outline_rounded,
              'Reviews & Reputation',
              'View your reviews and ratings',
              _cAmber,
              tx,
              sub,
              onTap: () => _push(const RatingsScreen()),
            ),
          ]),
          const SizedBox(height: 20),

          // ── 8. Payments & Earnings (2x2 Grid) ──────────────────────────────
          _buildSectionHeader('Payments & Earnings', Icons.payments_outlined, _cTeal, tx),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _paymentGridCell(
                        Icons.credit_card_rounded,
                        'Payment Methods',
                        'Manage your preferred methods',
                        _cTeal,
                        () => _push(const WalletScreen()),
                        tx,
                        sub,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _paymentGridCell(
                        Icons.receipt_long_rounded,
                        'Payment History',
                        'Past transactions',
                        _cBlue,
                        () => _push(const WalletScreen()),
                        tx,
                        sub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _paymentGridCell(
                        Icons.account_balance_wallet_outlined,
                        'Earnings',
                        'View your earnings summary',
                        _cGreen,
                        () => _push(const WalletScreen()),
                        tx,
                        sub,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _paymentGridCell(
                        Icons.description_outlined,
                        'Invoices',
                        'View and download invoices',
                        _cPurple,
                        () => _push(const WalletScreen()),
                        tx,
                        sub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── 9. Log Out Button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(
                context,
                authProvider,
                card,
                tx,
                sub,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _cRed,
                side: const BorderSide(color: _cRed, width: 1.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Version Footer
          Center(
            child: Text(
              'MedDuty $_appVersion • Made for Healthcare Professionals',
              style: TextStyle(fontSize: 11.5, color: sub),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Header Helper ──────────────────────────────────────────────────
  Widget _buildSectionHeader(
    String title,
    IconData icon,
    Color iconColor,
    Color tx,
  ) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: tx,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Card Container Helper ───────────────────────────────────────────────────
  Widget _buildSectionCard(Color card, Color border, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              Divider(
                height: 1,
                thickness: 1,
                color: border.withValues(alpha: 0.6),
                indent: 60,
              ),
          ],
        ],
      ),
    );
  }

  // ── Setting List Tile ───────────────────────────────────────────────────────
  Widget _buildTile(
    IconData icon,
    String title,
    String subtitle,
    Color iconColor,
    Color tx,
    Color sub, {
    Widget? badge,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: tx,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 11.5, color: sub),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null) badge,
          if (trailingText != null) ...[
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: sub,
              ),
            ),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_right_rounded, color: sub, size: 20),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _paymentGridCell(
    IconData icon,
    String title,
    String desc,
    Color color,
    VoidCallback onTap,
    Color tx,
    Color sub,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: tx,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              style: TextStyle(fontSize: 10.5, color: sub),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
