import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/theme_provider.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final dividerColor = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardShadow = isDark ? <BoxShadow>[] : AppColors.cardShadow;

    final isLight = themeProvider.themeModeOption == ThemeModeOption.light;
    final isDarkOpt = themeProvider.themeModeOption == ThemeModeOption.dark;
    final isSystem = themeProvider.themeModeOption == ThemeModeOption.system;

    Future<void> toggleOption(ThemeModeOption option) async {
      await themeProvider.setThemeModeOption(option);
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Theme',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: textColor,
        backgroundColor: bgColor,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSecondary,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: AppColors.accent,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appearance',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: textColor,
                              fontSize: 16,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Switch between Light, Dark or System. Only one mode is active at a time.',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Divider(height: 1, thickness: 1, color: dividerColor),
                _buildToggleRow(
                  context: context,
                  icon: Icons.sunny,
                  title: 'Light',
                  subtitle: 'Clean white theme with soft accents',
                  isOn: isLight,
                  onToggle: () => toggleOption(ThemeModeOption.light),
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                  indent: 68,
                ),
                _buildToggleRow(
                  context: context,
                  icon: Icons.bedtime_rounded,
                  title: 'Dark',
                  subtitle: 'Easy on the eyes for low light',
                  isOn: isDarkOpt,
                  onToggle: () => toggleOption(ThemeModeOption.dark),
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: dividerColor,
                  indent: 68,
                ),
                _buildToggleRow(
                  context: context,
                  icon: Icons.auto_awesome_rounded,
                  title: 'System default',
                  subtitle: 'Matches your device appearance',
                  isOn: isSystem,
                  onToggle: () => toggleOption(ThemeModeOption.system),
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDark: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Preview',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        AppColors.darkSurface,
                        AppColors.darkSurfaceVariant,
                      ]
                    : [
                        Colors.white,
                        AppColors.lightSecondary,
                      ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.15),
                      radius: 18,
                      child: const Icon(
                        Icons.person,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Dr. Priya',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This is how the app looks now',
                            style: TextStyle(
                              color: subTextColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSearchBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(
                        Icons.search_rounded,
                        color: subTextColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Search duties, clinics, hospitals...',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            'Primary Action',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isOn,
    required VoidCallback onToggle,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isOn
                      ? AppColors.accent.withValues(alpha: 0.12)
                      : (isDark
                            ? AppColors.darkSurfaceVariant
                            : AppColors.lightSecondary),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: isOn ? AppColors.accent : subTextColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        fontSize: 15.5,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: isOn,
                onChanged: (_) => onToggle(),
                activeTrackColor: AppColors.accent.withValues(alpha: 0.45),
                inactiveTrackColor:
                    (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                        .withValues(alpha: 1),
                activeThumbColor: AppColors.accent,
                inactiveThumbColor:
                    isDark ? AppColors.darkTextMuted : AppColors.lightGreyLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
