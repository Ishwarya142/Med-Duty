import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/app_routes.dart';
import '../../../core/services/account_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import 'settings_ui_helpers.dart';

class DeactivateAccountScreen extends StatelessWidget {
  const DeactivateAccountScreen({super.key});

  static const _bullets = [
    'Your profile becomes hidden',
    'Other users cannot discover your profile',
    'Your posts and community activity are hidden',
    'You will not appear in doctor recommendations',
    'Your active availability status is disabled',
    'Your account data is preserved',
    'You can reactivate by signing in again',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Deactivate Account', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
              boxShadow: isDark ? null : AppColors.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Deactivate your account?',
                  style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your profile, posts, followers, saved duties, applications and community activity will be hidden while your account is deactivated.',
                  style: TextStyle(color: sub, height: 1.45, fontSize: 14.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What happens when you deactivate?',
                  style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                ..._bullets.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(item, style: TextStyle(color: sub, height: 1.35)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: text,
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmDeactivate(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Deactivate Account', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeactivate(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    try {
      await auth.deactivateAccount();
      if (!context.mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const AccountDeactivatedScreen()),
      );
    } catch (e) {
      if (context.mounted) {
        SettingsUi.snack(context, 'Could not deactivate account. Please try again.');
      }
    }
  }
}

class AccountDeactivatedScreen extends StatelessWidget {
  const AccountDeactivatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pause_circle_outline, color: AppColors.warning, size: 48),
              ),
              const SizedBox(height: 24),
              Text('Account deactivated', style: TextStyle(color: text, fontSize: 24, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Text(
                'Your MedDuty account has been temporarily deactivated.',
                textAlign: TextAlign.center,
                style: TextStyle(color: sub, height: 1.45, fontSize: 15),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Go to Login', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DeleteAccountWarningScreen extends StatelessWidget {
  const DeleteAccountWarningScreen({super.key});

  static const _deletedItems = [
    'Profile information',
    'Profile visibility',
    'Community posts',
    'Followers/following relationships',
    'Saved duties',
    'Duty applications where legally/operationally appropriate',
    'Personal preferences',
    'Account settings',
    'Other user-generated account data',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Delete Account', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Delete your account?', style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Text(
                  'This will permanently remove your MedDuty account and cannot be undone.',
                  style: TextStyle(color: sub, height: 1.45),
                ),
                const SizedBox(height: 14),
                Text(
                  'This action is permanent.',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('What will be deleted?', style: TextStyle(color: text, fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                ..._deletedItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.close_rounded, color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(item, style: TextStyle(color: sub, height: 1.35))),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Some records may be retained where required for legal, financial, audit, or healthcare compliance. '
                  'Where content is referenced by other users, personal identity may be anonymized instead of physically removed.',
                  style: TextStyle(color: sub, fontSize: 12.5, height: 1.4, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DeleteAccountReauthScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: text,
                side: BorderSide(color: border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class DeleteAccountReauthScreen extends StatefulWidget {
  const DeleteAccountReauthScreen({super.key});

  @override
  State<DeleteAccountReauthScreen> createState() => _DeleteAccountReauthScreenState();
}

class _DeleteAccountReauthScreenState extends State<DeleteAccountReauthScreen> {
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _continueWithPassword() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      await auth.reauthenticateForDeletion(password: _passwordCtrl.text.trim());
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DeleteAccountFinalConfirmScreen()),
      );
    } on AccountDeletionAuthException catch (e) {
      if (mounted) SettingsUi.snack(context, e.message);
    } catch (e) {
      if (mounted) SettingsUi.snack(context, 'Authentication failed. Account was not deleted.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continueWithGoogle() async {
    final auth = context.read<AuthProvider>();
    setState(() => _loading = true);
    try {
      await auth.reauthenticateForDeletionWithGoogle();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DeleteAccountFinalConfirmScreen()),
      );
    } on AccountDeletionAuthException catch (e) {
      if (mounted) SettingsUi.snack(context, e.message);
    } catch (e) {
      if (mounted) SettingsUi.snack(context, 'Authentication failed. Account was not deleted.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Confirm Identity', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Before we permanently delete your account, please confirm your identity.',
            style: TextStyle(color: sub, height: 1.45),
          ),
          const SizedBox(height: 20),
          if (auth.isGoogleAuthUser) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _loading ? null : _continueWithGoogle,
                icon: const Icon(Icons.g_mobiledata_rounded, color: AppColors.accent, size: 28),
                label: Text(
                  _loading ? 'Please wait...' : 'Continue with Google to confirm deletion',
                  style: TextStyle(color: text, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  side: BorderSide(color: border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
          if (auth.isPasswordAuthUser) ...[
            if (auth.isGoogleAuthUser) const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Enter your password to continue',
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _continueWithPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_loading ? 'Verifying...' : 'Continue', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DeleteAccountFinalConfirmScreen extends StatefulWidget {
  const DeleteAccountFinalConfirmScreen({super.key});

  @override
  State<DeleteAccountFinalConfirmScreen> createState() => _DeleteAccountFinalConfirmScreenState();
}

class _DeleteAccountFinalConfirmScreenState extends State<DeleteAccountFinalConfirmScreen> {
  final _confirmCtrl = TextEditingController();
  bool _deleting = false;

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _canDelete => _confirmCtrl.text.trim() == 'DELETE';

  Future<void> _deletePermanently() async {
    if (!_canDelete) return;
    final auth = context.read<AuthProvider>();
    setState(() => _deleting = true);
    try {
      await auth.permanentlyDeleteAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      SettingsUi.snack(context, 'Your MedDuty account has been permanently deleted.');
    } on RequiresRecentLoginException {
      if (!mounted) return;
      SettingsUi.snack(context, 'Please sign in again to confirm deletion.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DeleteAccountReauthScreen()),
      );
    } on AccountDeletionAuthException catch (e) {
      if (mounted) SettingsUi.snack(context, e.message);
    } catch (e) {
      if (mounted) SettingsUi.snack(context, 'Could not delete account. Please try again.');
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Final Confirmation', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Permanently delete account?',
            style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            'Once your account is deleted, you cannot recover it.',
            style: TextStyle(color: sub, height: 1.45),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _confirmCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'Type DELETE to confirm',
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _deleting ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: text,
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: (!_canDelete || _deleting) ? null : _deletePermanently,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.error.withValues(alpha: 0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _deleting ? 'Deleting...' : 'Delete Account Permanently',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum ReactivationChoice { reactivate, keepDeactivated, cancelled }

Future<ReactivationChoice> showAccountReactivationDialog(BuildContext context) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
  final text = isDark ? AppColors.darkText : AppColors.lightText;
  final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  final result = await showDialog<ReactivationChoice>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Welcome back', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
      content: Text(
        'Your MedDuty account is currently deactivated.',
        style: TextStyle(color: sub, height: 1.45),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, ReactivationChoice.keepDeactivated),
          child: Text('Keep Deactivated', style: TextStyle(color: sub, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, ReactivationChoice.reactivate),
          child: const Text('Reactivate Account', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return result ?? ReactivationChoice.cancelled;
}
