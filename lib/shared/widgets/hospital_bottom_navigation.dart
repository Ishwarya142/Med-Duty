import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../features/hospital/analytics_screen.dart';
import '../../features/hospital/manage_duties_screen.dart';
import '../../features/hospital/applicants_screen.dart';
import '../../features/hospital/hospital_profile_screen.dart';
import '../../features/chat/chat_list_screen.dart';

class HospitalBottomNavigation extends StatefulWidget {
  const HospitalBottomNavigation({super.key});

  @override
  State<HospitalBottomNavigation> createState() =>
      _HospitalBottomNavigationState();
}

class _HospitalBottomNavigationState extends State<HospitalBottomNavigation> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    AnalyticsScreen(),
    ManageDutiesScreen(),
    ApplicantsScreen(),
    ChatListScreen(),
    HospitalProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: (Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder)
                  .withValues(alpha: 0.6),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: NavigationBar(
              height: 62,
              backgroundColor: Colors.transparent,
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.accent.withValues(alpha: 0.12),
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined, size: 26),
                  selectedIcon: Icon(Icons.dashboard_rounded,
                      size: 28, color: AppColors.accent),
                  label: "Analytics",
                  tooltip: "Analytics",
                ),
                NavigationDestination(
                  icon: Icon(Icons.work_outline_rounded, size: 26),
                  selectedIcon: Icon(Icons.work_rounded,
                      size: 28, color: AppColors.accent),
                  label: "Duties",
                  tooltip: "Manage Duties",
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded, size: 26),
                  selectedIcon: Icon(Icons.people_rounded,
                      size: 28, color: AppColors.accent),
                  label: "Applicants",
                  tooltip: "Applicants",
                ),
                NavigationDestination(
                  icon:
                      Icon(Icons.chat_bubble_outline_rounded, size: 26),
                  selectedIcon: Icon(Icons.chat_bubble_rounded,
                      size: 28, color: AppColors.accent),
                  label: "Chat",
                  tooltip: "Messages",
                ),
                NavigationDestination(
                  icon: Icon(Icons.business_outlined, size: 26),
                  selectedIcon: Icon(Icons.business_rounded,
                      size: 28, color: AppColors.accent),
                  label: "Profile",
                  tooltip: "Hospital Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
