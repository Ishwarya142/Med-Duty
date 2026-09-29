import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/theme/app_theme.dart';

enum ThemeModeOption { system, light, dark }

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  ThemeModeOption _themeModeOption = ThemeModeOption.light;
  ThemeModeOption get themeModeOption => _themeModeOption;

  bool _isSystemDark = false;
  bool get isSystemDark => _isSystemDark;

  ThemeProvider() {
    WidgetsBinding.instance.addObserver(this);
    _loadTheme();
    _syncSystemBrightness();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _syncSystemBrightness();
    notifyListeners();
  }

  void _syncSystemBrightness() {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    _isSystemDark = brightness == Brightness.dark;
  }

  bool get isDarkMode {
    switch (_themeModeOption) {
      case ThemeModeOption.system:
        return _isSystemDark;
      case ThemeModeOption.light:
        return false;
      case ThemeModeOption.dark:
        return true;
    }
  }

  ThemeMode get themeMode {
    switch (_themeModeOption) {
      case ThemeModeOption.system:
        return ThemeMode.system;
      case ThemeModeOption.light:
        return ThemeMode.light;
      case ThemeModeOption.dark:
        return ThemeMode.dark;
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    const prefsKey = 'themeModeOption_v2';
    final savedIndex = prefs.getInt(prefsKey);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < ThemeModeOption.values.length) {
      _themeModeOption = ThemeModeOption.values[savedIndex];
    } else {
      _themeModeOption = ThemeModeOption.light;
      await prefs.setInt(prefsKey, ThemeModeOption.light.index);
    }
    notifyListeners();
  }

  Future<void> setThemeModeOption(ThemeModeOption option) async {
    _themeModeOption = option;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeModeOption_v2', option.index);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    switch (_themeModeOption) {
      case ThemeModeOption.system:
        await setThemeModeOption(ThemeModeOption.light);
        break;
      case ThemeModeOption.light:
        await setThemeModeOption(ThemeModeOption.dark);
        break;
      case ThemeModeOption.dark:
        await setThemeModeOption(ThemeModeOption.system);
        break;
    }
  }

  ThemeData get currentTheme =>
      isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme;
}
