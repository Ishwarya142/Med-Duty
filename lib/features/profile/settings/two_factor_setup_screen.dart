import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/settings_preferences_provider.dart';
import 'settings_ui_helpers.dart';

class TwoFactorSetupScreen extends StatefulWidget {
  const TwoFactorSetupScreen({super.key});

  @override
  State<TwoFactorSetupScreen> createState() => _TwoFactorSetupScreenState();
}

class _TwoFactorSetupScreenState extends State<TwoFactorSetupScreen> {
  final _codeCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _enable() async {
    final l10n = context.l10n;
    final code = _codeCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();
    if (code.length != 6 || confirm.length != 6) return;
    if (code != confirm) {
      SettingsUi.snack(context, l10n.codesDoNotMatch);
      return;
    }
    setState(() => _saving = true);
    await context.read<SettingsPreferencesProvider>().enableTwoFactor(code);
    if (!mounted) return;
    setState(() => _saving = false);
    SettingsUi.snack(context, l10n.twoFactorSetupSuccess);
    Navigator.pop(context, true);
  }

  Future<void> _disable() async {
    final l10n = context.l10n;
    final code = _codeCtrl.text.trim();
    if (code.length != 6) return;
    final prefs = context.read<SettingsPreferencesProvider>();
    if (!prefs.verifyTwoFactorCode(code)) {
      SettingsUi.snack(context, l10n.incorrectCode);
      return;
    }
    setState(() => _saving = true);
    await prefs.disableTwoFactor();
    if (!mounted) return;
    setState(() => _saving = false);
    SettingsUi.snack(context, l10n.twoFactorDisabledMsg);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final enabled = context.watch<SettingsPreferencesProvider>().twoFactorEnabled;

    return Scaffold(
      backgroundColor: bg,
      appBar: SettingsUi.appBar(context, l10n.twoFactorTitle, text, bg),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.twoFactorDesc, style: TextStyle(color: sub, height: 1.45)),
          const SizedBox(height: 20),
          if (!enabled) ...[
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.createSecurityCode,
                counterText: '',
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _confirmCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.confirmSecurityCode,
                counterText: '',
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _enable,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_saving ? l10n.submitting : l10n.enable2fa),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.success),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      l10n.twoFactorEnabled,
                      style: TextStyle(color: text, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(l10n.enterSecurityCode, style: TextStyle(color: sub)),
            const SizedBox(height: 8),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _saving ? null : _disable,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_saving ? l10n.submitting : l10n.disable2fa),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class TwoFactorVerifyScreen extends StatefulWidget {
  const TwoFactorVerifyScreen({super.key});

  @override
  State<TwoFactorVerifyScreen> createState() => _TwoFactorVerifyScreenState();
}

class _TwoFactorVerifyScreenState extends State<TwoFactorVerifyScreen> {
  final _codeCtrl = TextEditingController();

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  void _verify() {
    final l10n = context.l10n;
    final code = _codeCtrl.text.trim();
    if (code.length != 6) return;
    final ok = context.read<SettingsPreferencesProvider>().verifyTwoFactorCode(code);
    if (ok) {
      Navigator.pop(context, true);
    } else {
      SettingsUi.snack(context, l10n.incorrectCode);
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
      appBar: SettingsUi.appBar(context, l10n.verifyToContinue, text, bg),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.enterSecurityCode, style: TextStyle(color: sub, height: 1.4)),
            const SizedBox(height: 16),
            TextField(
              controller: _codeCtrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              obscureText: true,
              textAlign: TextAlign.center,
              style: TextStyle(color: text, fontSize: 24, letterSpacing: 8),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onSubmitted: (_) => _verify(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.verify),
            ),
          ],
        ),
      ),
    );
  }
}
