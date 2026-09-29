import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'app_shell.dart';
import '../../features/community/community_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/duties/nearby_duties_screen.dart';
import '../../features/home/doctor_home_screen.dart';
import '../../features/home/nurse_home_screen.dart';
import '../../features/profile/profile_screen.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key, this.userRole});

  final String? userRole;

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int currentIndex = 0;

  // Per-tab identity colors
  static const _tabColors = [
    Color(0xFF0F766E),  // Home - teal
    Color(0xFF2563EB),  // Duties - blue
    Color(0xFF7C3AED),  // Community - purple
    Color(0xFFF97316),  // Messages - orange
    Color(0xFF10B981),  // Profile - emerald
  ];

  static const _tabIconsOutlined = [
    Icons.home_outlined,
    Icons.medical_services_outlined,
    Icons.groups_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];

  static const _tabIconsFilled = [
    Icons.home_rounded,
    Icons.medical_services_rounded,
    Icons.groups_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  List<String> _tabLabels(BuildContext context) {
    final l10n = context.l10n;
    return [l10n.navHome, l10n.navDuties, l10n.navCommunity, l10n.navMessages, l10n.navProfile];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final String role = widget.userRole ??
        (ModalRoute.of(context)?.settings.arguments as String?) ??
        'doctor';

    final List<Widget> pages = [
      role == 'nurse' ? const NurseHomeScreen() : const DoctorHomeScreen(),
      const NearbyDutiesScreen(),
      const CommunityScreen(),
      const ChatListScreen(),
      const ProfileScreen(),
    ];

    final tabLabels = _tabLabels(context);

    return AppShell(
      switchTab: (index) {
        if (mounted) setState(() => currentIndex = index);
      },
      child: Scaffold(
        extendBody: true,
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: _buildCustomNavBar(
          isDark: isDark,
          navBgColor: navBgColor,
          borderColor: borderColor,
          tabLabels: tabLabels,
        ),
      ),
    );
  }

  Widget _buildCustomNavBar({
    required bool isDark,
    required Color navBgColor,
    required Color borderColor,
    required List<String> tabLabels,
  }) {
    return Container(
      height: 68 + MediaQuery.of(context).padding.bottom,
      decoration: BoxDecoration(
        color: navBgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: borderColor.withValues(alpha: 0.5),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(5, (i) {
            final selected = currentIndex == i;
            final color = _tabColors[i];
            const inactiveColor = Color(0xFF94A3B8);
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => currentIndex = i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: selected
                          ? const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4)
                          : const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: selected
                            ? color.withValues(alpha: isDark ? 0.2 : 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        selected
                            ? _tabIconsFilled[i]
                            : _tabIconsOutlined[i],
                        color: selected ? color : inactiveColor,
                        size: selected ? 26 : 24,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tabLabels[i],
                      style: TextStyle(
                        color: selected ? color : inactiveColor,
                        fontSize: 10.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
