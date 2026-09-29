import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../features/authentication/login_screen.dart';
import '../features/authentication/register_screen.dart';
import '../features/authentication/role_selection_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/theme_screen.dart';
import '../features/splash/splash_screen.dart';
import '../shared/widgets/bottom_navigation.dart';
import '../shared/widgets/hospital_bottom_navigation.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_preferences_provider.dart';
import 'app_routes.dart';

class MedDutyApp extends StatelessWidget {
  const MedDutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsPrefs = Provider.of<SettingsPreferencesProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MedDuty',
      locale: settingsPrefs.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.roleSelection: (_) => const RoleSelectionScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.home: (_) => const BottomNavigation(),
        AppRoutes.hospitalHome: (_) => const HospitalBottomNavigation(),
        AppRoutes.theme: (_) => const ThemeScreen(),
      },
    );
  }
}
