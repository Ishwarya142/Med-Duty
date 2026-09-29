import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/services/supabase_adapters.dart';

import '../../../core/services/contact_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/contact_utils.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/profile_provider.dart';
import 'settings_ui_helpers.dart';

class EmailPhoneScreen extends StatefulWidget {
  const EmailPhoneScreen({super.key});

  @override
  State<EmailPhoneScreen> createState() => _EmailPhoneScreenState();
}

class _EmailPhoneScreenState extends State<EmailPhoneScreen> {
  final _contact = ContactService.instance;
  bool _revealed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await context.read<ProfileProvider>().syncContactFromAuth();
      if (!mounted) return;
      await context.read<AuthProvider>().reloadUser();
      if (mounted) setState(() {});
    });
  }

  String _primaryEmail(ProfileProvider profile, AuthProvider auth) {
    return _contact.primaryEmail ??
        (profile.email.isNotEmpty ? profile.email : '');
  }

  bool _primaryVerified(AuthProvider auth) {
    return _contact.isPrimaryEmailVerified;
  }

  String _displayPhone(ProfileProvider profile) {
    final authPhone = _contact.authPhoneNumber;
    final phone = (authPhone != null && authPhone.isNotEmpty)
        ? authPhone
        : profile.phone;
    if (phone.isEmpty) return '';
    return ContactUtils.formatPhoneDisplay(phone);
  }

  bool _hasVerifiedPhone(ProfileProvider profile) {
    if (_contact.authPhoneNumber != null &&
        _contact.authPhoneNumber!.isNotEmpty) {
      return true;
    }
    return profile.phone.isNotEmpty && profile.phoneVerified;
  }

  Future<void> _reauthIfNeeded({VoidCallback? onSuccess}) async {
    if (_contact.isGoogleUser) {
      try {
        await _contact.reauthenticate();
        onSuccess?.call();
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
      }
      return;
    }

    final password = await _showPasswordReauthDialog();
    if (password == null) return;
    try {
      await _contact.reauthenticate(password: password);
      onSuccess?.call();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
    }
  }

  Future<String?> _showPasswordReauthDialog() async {
    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Security verification required',
            style: TextStyle(color: text, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please verify your identity before changing your account contact information.',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _addOrChangePhone({required bool isChange}) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhoneFlowSheet(
        isChange: isChange,
        currentPhone: _displayPhone(context.read<ProfileProvider>()),
        onVerified: (phone) async {
          await context.read<ProfileProvider>().saveVerifiedPhone(phone);
          if (!mounted) return;
          SettingsUi.snack(context, 'Phone number added successfully.');
          setState(() {});
        },
      ),
    );
  }

  Future<void> _removePhone() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove phone number?'),
        content: const Text(
          'Your phone number will no longer be available as a recovery/contact method.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await _reauthIfNeeded(onSuccess: () async {
      try {
        await _contact.removePhone();
        if (!mounted) return;
        await context.read<ProfileProvider>().removeVerifiedPhone();
        if (!mounted) return;
        SettingsUi.snack(context, 'Phone number removed.');
        setState(() {});
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
      }
    });
  }

  Future<void> _addOrChangeRecoveryEmail({required bool isChange}) async {
    final profile = context.read<ProfileProvider>();
    final primary = _primaryEmail(profile, context.read<AuthProvider>());

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RecoveryEmailFlowSheet(
        isChange: isChange,
        currentEmail: profile.recoveryEmail,
        primaryEmail: primary,
        onSent: () => setState(() {}),
      ),
    );
  }

  Future<void> _changePrimaryEmail() async {
    if (_contact.isGoogleUser && !_contact.isPasswordUser) {
      SettingsUi.snack(
        context,
        'Your primary email is managed by your Google account.',
      );
      return;
    }

    final ctrl = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = isDark ? AppColors.darkText : AppColors.lightText;

    final newEmail = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Change Email', style: TextStyle(color: text)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'New email address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (newEmail == null || newEmail.isEmpty || !mounted) return;

    if (!ContactUtils.isValidEmail(newEmail)) {
      SettingsUi.snack(context, 'Enter a valid email address.');
      return;
    }

    await _reauthIfNeeded(onSuccess: () async {
      try {
        await _contact.changePrimaryEmail(newEmail: newEmail);
        if (!mounted) return;
        SettingsUi.snack(
          context,
          'Verification email sent. Please check your inbox to confirm the change.',
        );
        await context.read<AuthProvider>().reloadUser();
        setState(() {});
      } on FirebaseAuthException catch (e) {
        if (!mounted) return;
        if (e.code == 'google-managed-email') {
          SettingsUi.snack(
            context,
            'Your primary email is managed by your Google account.',
          );
        } else {
          SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final profile = context.watch<ProfileProvider>();
    final auth = context.watch<AuthProvider>();

    final primaryEmail = _primaryEmail(profile, auth);
    final hasPrimary = primaryEmail.isNotEmpty;
    final recoveryEmail = profile.recoveryEmail;
    final hasRecovery = recoveryEmail.isNotEmpty;
    final phoneDisplay = _displayPhone(profile);
    final hasPhone = _hasVerifiedPhone(profile);

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, 'Email & Phone', text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionCard(
            title: 'Primary Email',
            value: hasPrimary
                ? (_revealed
                    ? primaryEmail
                    : ContactUtils.maskEmail(primaryEmail))
                : 'Not set',
            verified: hasPrimary && _primaryVerified(auth),
            verifiedLabel: hasPrimary && !_primaryVerified(auth)
                ? 'Unverified'
                : 'Verified',
            verifiedColor: hasPrimary && !_primaryVerified(auth)
                ? AppColors.warning
                : AppColors.success,
            actionLabel: 'Change Email',
            onAction: _changePrimaryEmail,
            onReveal: hasPrimary
                ? () => setState(() => _revealed = !_revealed)
                : null,
            text: text,
            sub: sub,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Recovery Email',
            value: hasRecovery
                ? (_revealed
                    ? recoveryEmail
                    : ContactUtils.maskEmail(recoveryEmail))
                : 'Not added',
            verified: hasRecovery && profile.recoveryEmailVerified,
            verifiedLabel: hasRecovery && !profile.recoveryEmailVerified
                ? 'Pending verification'
                : 'Verified',
            verifiedColor: hasRecovery && !profile.recoveryEmailVerified
                ? AppColors.warning
                : AppColors.success,
            actionLabel: hasRecovery ? 'Change' : 'Add Recovery Email',
            onAction: () => _addOrChangeRecoveryEmail(isChange: hasRecovery),
            text: text,
            sub: sub,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 12),
          _sectionCard(
            title: 'Phone Number',
            value: hasPhone
                ? (_revealed ? phoneDisplay : ContactUtils.maskPhone(phoneDisplay))
                : 'Not added',
            verified: hasPhone,
            actionLabel: hasPhone ? 'Change' : 'Add Phone Number',
            onAction: () => _addOrChangePhone(isChange: hasPhone),
            secondaryActionLabel: hasPhone ? 'Remove Phone Number' : null,
            onSecondaryAction: hasPhone ? _removePhone : null,
            text: text,
            sub: sub,
            surface: surface,
            border: border,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Text(
              'Your recovery email and phone number can help you secure and recover your MedDuty account.',
              style: TextStyle(color: sub, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required String value,
    required bool verified,
    String verifiedLabel = 'Verified',
    Color verifiedColor = AppColors.success,
    required String actionLabel,
    required VoidCallback onAction,
    String? secondaryActionLabel,
    VoidCallback? onSecondaryAction,
    VoidCallback? onReveal,
    required Color text,
    required Color sub,
    required Color surface,
    required Color border,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: TextStyle(color: sub, fontWeight: FontWeight.w600)),
              ),
              if (onReveal != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onReveal,
                  icon: Icon(
                    _revealed ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    size: 18,
                    color: sub,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: text,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (value != 'Not set' && value != 'Not added') ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: verifiedColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (verified)
                    Icon(Icons.check_circle_rounded,
                        size: 14, color: verifiedColor),
                  if (verified) const SizedBox(width: 4),
                  Text(
                    verifiedLabel,
                    style: TextStyle(
                      color: verifiedColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(actionLabel),
            ),
          ),
          if (secondaryActionLabel != null && onSecondaryAction != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onSecondaryAction,
                child: Text(
                  secondaryActionLabel,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Phone verification flow ───────────────────────────────────────────────

class _PhoneFlowSheet extends StatefulWidget {
  final bool isChange;
  final String currentPhone;
  final Future<void> Function(String phoneE164) onVerified;

  const _PhoneFlowSheet({
    required this.isChange,
    required this.currentPhone,
    required this.onVerified,
  });

  @override
  State<_PhoneFlowSheet> createState() => _PhoneFlowSheetState();
}

class _PhoneFlowSheetState extends State<_PhoneFlowSheet> {
  final _contact = ContactService.instance;
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final String _dialCode = '+91';
  String? _verificationId;
  int? _resendToken;
  bool _codeSent = false;
  bool _loading = false;
  int _resendCooldown = 0;
  Timer? _cooldownTimer;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    _resendCooldown = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _resendCooldown--;
        if (_resendCooldown <= 0) t.cancel();
      });
    });
  }

  Future<void> _sendCode() async {
    final digits = _phoneCtrl.text.trim();
    if (!ContactUtils.isValidPhoneDigits(digits)) {
      SettingsUi.snack(context, 'Enter a valid phone number.');
      return;
    }

    setState(() => _loading = true);
    final phoneE164 = ContactUtils.formatPhoneE164(_dialCode, digits);

    try {
      await _contact.sendPhoneVerificationCode(
        phoneE164: phoneE164,
        forceResendToken: _resendToken,
        onCodeSent: (verificationId, resendToken) {
          if (!mounted) return;
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _codeSent = true;
            _loading = false;
          });
          _startCooldown();
        },
        onFailed: (e) {
          if (!mounted) return;
          setState(() => _loading = false);
          SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
    }
  }

  Future<void> _verifyOtp() async {
    if (_verificationId == null) return;
    final code = _otpCtrl.text.trim();
    if (code.length != 6) {
      SettingsUi.snack(context, 'Enter the 6-digit verification code.');
      return;
    }

    setState(() => _loading = true);
    try {
      final phone = await _contact.verifyPhoneOtp(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await widget.onVerified(phone);
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _codeSent
                  ? 'Verify Phone Number'
                  : widget.isChange
                      ? 'Change Phone Number'
                      : 'Add Phone Number',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.isChange && !_codeSent) ...[
              Text('Current:', style: TextStyle(color: sub, fontSize: 12)),
              Text(widget.currentPhone,
                  style: TextStyle(
                      color: text, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
            ],
            if (!_codeSent) ...[
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('🇮🇳 $_dialCode',
                        style: TextStyle(color: text, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Phone number',
                        hintText: 'Enter phone number',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _sendCode,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Send Verification Code'),
                ),
              ),
            ] else ...[
              Text(
                'Enter the 6-digit verification code sent to ${ContactUtils.formatPhoneE164(_dialCode, _phoneCtrl.text.trim())}.',
                style: TextStyle(color: sub, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, letterSpacing: 8),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '_ _ _ _ _ _',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _verifyOtp,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Verify'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: (_resendCooldown > 0 || _loading) ? null : _sendCode,
                  child: Text(
                    _resendCooldown > 0
                        ? 'Resend code in ${_resendCooldown}s'
                        : 'Resend code',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Recovery email flow ───────────────────────────────────────────────────

class _RecoveryEmailFlowSheet extends StatefulWidget {
  final bool isChange;
  final String currentEmail;
  final String primaryEmail;
  final VoidCallback onSent;

  const _RecoveryEmailFlowSheet({
    required this.isChange,
    required this.currentEmail,
    required this.primaryEmail,
    required this.onSent,
  });

  @override
  State<_RecoveryEmailFlowSheet> createState() =>
      _RecoveryEmailFlowSheetState();
}

class _RecoveryEmailFlowSheetState extends State<_RecoveryEmailFlowSheet> {
  final _contact = ContactService.instance;
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;
  String _pendingEmail = '';

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendVerification() async {
    final email = ContactUtils.normalizeEmail(_emailCtrl.text);
    if (!ContactUtils.isValidEmail(email)) {
      SettingsUi.snack(context, 'Enter a valid email address.');
      return;
    }
    if (email == ContactUtils.normalizeEmail(widget.primaryEmail)) {
      SettingsUi.snack(
        context,
        'Recovery email must be different from your primary email.',
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _contact.sendRecoveryEmailVerification(email);
      if (!mounted) return;
      await context.read<ProfileProvider>().saveRecoveryEmail(
            email: email,
            verified: false,
          );
      if (!mounted) return;
      setState(() {
        _sent = true;
        _pendingEmail = email;
        _loading = false;
      });
      widget.onSent();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
    }
  }

  Future<void> _checkVerification() async {
    setState(() => _loading = true);
    try {
      final link = Uri.base.toString();
      if (FirebaseAuth.instance.isSignInWithEmailLink(link)) {
        final verified = await _contact.completeRecoveryEmailLink(link);
        if (!mounted) return;
        await context.read<ProfileProvider>().saveRecoveryEmail(
              email: verified,
              verified: true,
            );
        if (!mounted) return;
        SettingsUi.snack(context, 'Recovery email verified.');
        Navigator.pop(context);
        return;
      }

      if (!mounted) return;
      await context.read<AuthProvider>().reloadUser();
      if (!mounted) return;
      final profile = context.read<ProfileProvider>();
      if (profile.recoveryEmailVerified) {
        if (!mounted) return;
        SettingsUi.snack(context, 'Recovery email verified.');
        Navigator.pop(context);
      } else {
        if (!mounted) return;
        SettingsUi.snack(
          context,
          'Verification not completed yet. Please check your inbox.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      SettingsUi.snack(context, ContactUtils.contactErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: sub.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _sent
                  ? 'Verify Recovery Email'
                  : widget.isChange
                      ? 'Change Recovery Email'
                      : 'Add Recovery Email',
              style: TextStyle(
                color: text,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (widget.isChange && !_sent) ...[
              Text('Current:', style: TextStyle(color: sub, fontSize: 12)),
              Text(widget.currentEmail,
                  style: TextStyle(
                      color: text, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
            ],
            if (!_sent) ...[
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Recovery email',
                  hintText: 'Enter email',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _sendVerification,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Continue'),
                ),
              ),
            ] else ...[
              Text(
                "We've sent a verification link to $_pendingEmail.",
                style: TextStyle(color: sub, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _loading ? null : _checkVerification,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Check Verification'),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _sendVerification,
                  child: const Text('Resend Verification Email'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
