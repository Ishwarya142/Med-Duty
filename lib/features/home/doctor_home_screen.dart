import 'package:flutter/material.dart';

import '../../shared/widgets/home_header.dart';
import '../../shared/widgets/stats_card.dart';
import '../../shared/widgets/search_bar_widget.dart';
import '../../shared/widgets/category_tabs.dart';
import '../../shared/widgets/quick_actions.dart';
import '../../shared/widgets/section_title.dart';
import '../../shared/widgets/featured_duty_card.dart';
import '../../shared/widgets/top_categories.dart';
import '../../shared/widgets/recommended_hospitals.dart';
import '../../shared/widgets/recent_activity.dart';

class DoctorHomeScreen extends StatelessWidget {
  const DoctorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [

              HomeHeader(),

              SizedBox(height: 20),

              StatsCard(),

              SizedBox(height: 25),

              QuickActions(),

              SizedBox(height: 25),

              SearchBarWidget(),

              SizedBox(height: 25),

              CategoryTabs(),

              SizedBox(height: 25),

              SectionTitle(title: "Featured Duty"),

              SizedBox(height: 15),

              FeaturedDutyCard(),

              SizedBox(height: 30),

              SectionTitle(title: "Top Categories"),

              SizedBox(height: 15),

              TopCategories(),

              SizedBox(height: 30),

              SectionTitle(title: "Recommended Hospitals"),

              SizedBox(height: 15),

              RecommendedHospitals(),

              SizedBox(height: 30),

              SectionTitle(title: "Recent Activity"),

              SizedBox(height: 15),

              RecentActivity(),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}