import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== Premium MILD TEAL Accent (matches Onboarding "Get Started" button) =====
  // This is the EXACT mild teal the user requested - not bold/green/bright
  static const Color accent = Color(0xFF0F766E);
  static const Color accentLight = Color(0xFF115E59);
  static const Color accentEmerald = Color(0xFF10B981);
  static const Color accentMint = Color(0xFFD1FAE5);

  // Common Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  // ===== Premium Light Theme Colors (mild, not bold) =====
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightPrimary = Color(0xFF0F766E);
  static const Color lightPrimaryDark = Color(0xFF115E59);
  static const Color lightSecondary = Color(0xFFECFDF5);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF64748B);
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightGrey = Color(0xFF64748B);
  static const Color lightGreyLight = Color(0xFF94A3B8);
  static const Color lightNavSelected = accent;
  static const Color lightNavUnselected = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightChatBackground = Color(0xFFF8FAFC);
  static const Color lightSearchBg = Color(0xFFF1F5F9);
  static const Color lightCardBg = Colors.white;

  static const LinearGradient lightPrimaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F766E), Color(0xFF115E59)],
  );
  static const LinearGradient lightPremiumGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF0F766E), Color(0xFF10B981)],
  );
  static const LinearGradient lightSplashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFF8FAFC), Colors.white],
  );

  // ===== Premium Dark Theme Colors =====
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF10B981);
  static const Color darkPrimaryDark = Color(0xFF0F766E);
  static const Color darkSecondary = Color(0xFF1E293B);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);
  static const Color darkGrey = Color(0xFF94A3B8);
  static const Color darkGreyLight = Color(0xFFCBD5E1);
  static const Color darkNavSelected = Color(0xFF10B981);
  static const Color darkNavUnselected = Color(0xFF64748B);
  static const Color darkDivider = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkChatBackground = Color(0xFF0B1120);
  static const Color darkSearchBg = Color(0xFF1E293B);
  static const Color darkCardBg = Color(0xFF111827);

  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1120), Color(0xFF111827)],
  );
  static const LinearGradient darkPremiumGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFF10B981), Color(0xFF0F766E)],
  );
  static const LinearGradient darkSplashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0B1120), Color(0xFF111827)],
  );

  // ===== Legacy aliases (kept for backward compatibility with existing code) =====
  static const Color primary = lightPrimary;
  static const Color primaryDark = lightPrimaryDark;
  static const Color secondary = lightSecondary;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color surfaceVariant = lightSurfaceVariant;
  static const Color chatBackground = lightChatBackground;
  static const Color blueTint = lightPrimary;
  static const Color grey = lightGrey;
  static const Color greyLight = lightGreyLight;
  static const Color navSelected = lightNavSelected;
  static const Color navUnselected = lightNavUnselected;
  static const Color divider = lightDivider;
  static const Color textSecondary = lightTextSecondary;
  static const Color darkTextSecondaryAlias = darkTextSecondary;

  static const LinearGradient primaryGradient = lightPrimaryGradient;
  static const LinearGradient premiumGradient = lightPremiumGradient;
  static const LinearGradient splashGradient = lightSplashGradient;

  static const Color darkPrimaryAlias = darkPrimary;
  static const Color darkPrimaryDarkAlias = darkPrimaryDark;
  static const Color darkSecondaryAlias = darkSecondary;
  static const Color darkBackgroundAlias = darkBackground;
  static const Color darkSurfaceAlias = darkSurface;
  static const Color darkSurfaceVariantAlias = darkSurfaceVariant;
  static const Color darkChatBackgroundAlias = darkChatBackground;
  static const Color darkGreyAlias = darkGrey;
  static const Color darkGreyLightAlias = darkGreyLight;
  static const Color darkNavSelectedAlias = darkNavSelected;
  static const Color darkNavUnselectedAlias = darkNavUnselected;
  static const Color darkDividerAlias = darkDivider;
  static const LinearGradient darkPrimaryGradientAlias = darkPrimaryGradient;

  // ===== Drop Shadows =====
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  static List<BoxShadow> intenseShadow = [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
  static List<BoxShadow> accentShadow = [
    BoxShadow(
      color: accent.withValues(alpha: 0.3),
      blurRadius: 14,
      offset: const Offset(0, 6),
    ),
  ];
}
