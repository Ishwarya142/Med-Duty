import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_preferences_provider.dart';
import '../profile/settings/two_factor_setup_screen.dart';
import '../profile/settings/account_control_screens.dart';

/// Navigates after a successful authentication using existing app routes.
Future<void> navigateAfterAuthentication(BuildContext context, AuthProvider auth) async {
  if (auth.needsRoleSelection) {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.roleSelection,
      arguments: {'googleComplete': true},
    );
    return;
  }

  if (auth.isAccountDeactivated) {
    final choice = await showAccountReactivationDialog(context);
    if (!context.mounted) return;
    if (choice == ReactivationChoice.keepDeactivated || choice == ReactivationChoice.cancelled) {
      await auth.logout();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
    if (choice == ReactivationChoice.reactivate) {
      await auth.reactivateAccount();
      if (!context.mounted) return;
    }
  }

  final prefs = context.read<SettingsPreferencesProvider>();
  if (prefs.twoFactorEnabled) {
    final verified = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const TwoFactorVerifyScreen()),
    );
    if (!context.mounted) return;
    if (verified != true) {
      await auth.logout();
      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }
  }

  if (auth.userRole == UserRole.hospital) {
    Navigator.pushReplacementNamed(context, AppRoutes.hospitalHome);
  } else {
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}
