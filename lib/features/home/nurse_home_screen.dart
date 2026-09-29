// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/recommended_duties_service.dart';
import '../../models/duty_model.dart';
import '../../models/duty_with_distance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/duty_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/location_provider.dart';
import '../../shared/widgets/app_shell.dart';
import '../notifications/notification_screen.dart';
import '../duties/duty_details_screen.dart';
import '../jobs/jobs_bootstrap.dart';
import '../jobs/job_helpers.dart';
import '../duties/discovery_bootstrap.dart';
import '../profile/saved_screen.dart';
import '../duties/nearby_duties_map_screen.dart';
import '../duties/widgets/location_selector_sheet.dart';
import '../duties/widgets/emergency_flash_card.dart';

const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cPurple = Color(0xFF7C3AED);
const _cAmber  = Color(0xFFF59E0B);
const _cRed    = Color(0xFFEF4444);
const _cTeal   = Color(0xFF0F766E);
const _cOrange = Color(0xFFF97316);

class NurseHomeScreen extends StatefulWidget {
  const NurseHomeScreen({super.key});

  @override
  State<NurseHomeScreen> createState() => _NurseHomeScreenState();
}

class _NurseHomeScreenState extends State<NurseHomeScreen> {
  final PageController _nearbyPageController = PageController();
  int _nearbyCurrentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.user?.uid != null) {
        final uid = auth.user!.uid;
        Provider.of<ProfileProvider>(context, listen: false).loadProfile(uid);
        Provider.of<DutyProvider>(context, listen: false).loadDutyData(uid);
        Provider.of<CommunityProvider>(context, listen: false).loadCommunityData(uid);
      }
      await bootstrapDutyDiscovery(context);
      if (!mounted) return;
      await bootstrapJobDiscovery(context);
      if (!mounted) return;
      final profile = context.read<ProfileProvider>();
      final auth2 = context.read<AuthProvider>();
      context.read<CommunityProvider>().loadNetworkProfessionalPosts(
            followingIds: profile.followingUserIds,
            viewerId: auth2.user?.uid,
          );
    });
  }

  @override
  void dispose() {
    _nearbyPageController.dispose();
    super.dispose();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  ImageProvider? _getProfileImage(ProfileProvider p) {
    if (!kIsWeb && p.localProfilePicPath != null) {
      return FileImage(File(p.localProfilePicPath!));
    }
    if (p.profilePic.isNotEmpty) {
      return NetworkImage(p.profilePic);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final tx     = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub    = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ];

    final profile  = Provider.of<ProfileProvider>(context);
    final duties   = Provider.of<DutyProvider>(context);
    final location = Provider.of<LocationProvider>(context);
    final jobs     = Provider.of<JobProvider>(context);

    final emergencyDuties = duties.emergencyNearby(location);
    final hasEmergency = emergencyDuties.isNotEmpty;

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(bg, tx, sub, profile),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Nurse Greeting Card
            _buildProfileGreetingCard(
              card, border, tx, sub, shadow, isDark, profile, location,
            ),

            // 2. Noticeable Emerging Flash Card
            if (hasEmergency) ...[
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildEmergencyAlertCard(
                  emergencyDuties.first,
                  duties,
                  isDark,
                  tx,
                  sub,
                ),
              ),
            ],

            // 3. Nearby Duties Carousel
            _buildNearbyDutiesSection(
              card, border, tx, sub, shadow, isDark, location, duties,
            ),

            // 4. Recommendations Side-by-Side (Recommended Duties & Jobs)
            _buildRecommendationsSection(
              card, border, tx, sub, shadow, isDark, location, duties, jobs, profile,
            ),

            // 5. Community Activity Section
            _buildCommunityActivitySection(
              card, border, tx, sub, shadow, isDark,
            ),

            // 6. Quick Actions Grid
            _buildQuickActionsSection(
              card, tx, sub, isDark,
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─── 1. FIXED TOP APP BAR ──────────────────────────────────────────────────
  AppBar _buildAppBar(Color bg, Color tx, Color sub, ProfileProvider profile) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _cTeal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.favorite_rounded, color: _cTeal, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MedDuty',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _cTeal,
                  letterSpacing: -0.4,
                ),
              ),
              Text(
                'Care • Connect • Serve',
                style: TextStyle(fontSize: 11, color: sub, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_none_rounded, color: tx, size: 25),
                Positioned(
                  right: -1,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: _cRed,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 4),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline_rounded, color: tx, size: 23),
          onPressed: () => AppShell.maybeOf(context)?.switchTab(3),
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => AppShell.maybeOf(context)?.switchTab(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: _cTeal,
                backgroundImage: _getProfileImage(profile),
                child: _getProfileImage(profile) == null
                    ? Text(
                        profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'N',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: _cGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: bg, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  // ─── 2. NURSE GREETING CARD WITH ILLUSTRATION ─────────────────────────────
  Widget _buildProfileGreetingCard(
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
    bool isDark,
    ProfileProvider profile,
    LocationProvider location,
  ) {
    final name     = profile.name.isNotEmpty ? profile.name : 'Nurse';
    final qual     = profile.qualification.isNotEmpty ? profile.qualification : 'B.Sc Nursing';
    final spec     = profile.specialization.isNotEmpty ? profile.specialization : 'Staff Nurse (ICU)';
    final locLabel = location.isInitialized && location.locationLabel.isNotEmpty
        ? location.locationLabel
        : (profile.currentCity.isNotEmpty ? profile.currentCity : 'Avadi, Chennai');

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: shadow,
        border: Border.all(color: border, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              bottom: 0,
              top: 0,
              width: 145,
              child: CustomPaint(
                painter: _HospitalHeaderPainter(isDark: isDark),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _cTeal,
                    backgroundImage: _getProfileImage(profile),
                    child: _getProfileImage(profile) == null
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : 'N',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(),
                          style: TextStyle(fontSize: 12.5, color: sub, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: tx,
                                  letterSpacing: -0.3,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.verified_rounded, color: _cBlue, size: 16),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$qual • $spec',
                          style: TextStyle(fontSize: 12, color: sub, fontWeight: FontWeight.w500),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => showLocationSelectorSheet(context),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: _cTeal),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  locLabel,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _cTeal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (location.isInitialized)
                                Text(
                                  ' • ${location.radiusLabel}',
                                  style: TextStyle(fontSize: 11, color: sub),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 3. NOTICEABLE EMERGING FLASH CARD ────────────────────────────────────
  Widget _buildEmergencyAlertCard(
    DutyWithDistance emergency,
    DutyProvider duties,
    bool isDark,
    Color tx,
    Color sub,
  ) {
    final isSaved = duties.isDutySaved(emergency.duty.id);
    final isApplied = duties.isDutyApplied(emergency.duty.id);

    return EmergencyFlashCard(
      item: emergency,
      isSaved: isSaved,
      isApplied: isApplied,
      onTap: () => _openDiscoveryDutyDetails(context, emergency, duties),
      onApply: () => _openDiscoveryDutyDetails(context, emergency, duties),
      onSave: () {
        duties.toggleSaveDuty(
          emergency.duty.id,
          emergency.duty.role,
          emergency.duty.location,
          emergency.duty.salary,
        );
        setState(() {});
      },
    );
  }

  // ─── 4. NEARBY DUTIES CAROUSEL ─────────────────────────────────────────────
  Widget _buildNearbyDutiesSection(
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
    bool isDark,
    LocationProvider location,
    DutyProvider duties,
  ) {
    final nearby = duties.regularNearby(location);
    final count = nearby.length;
    final items = nearby.isNotEmpty ? nearby : _getMockNearbyFallback();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Duties',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: tx,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => AppShell.maybeOf(context)?.switchTab(1),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _cTeal,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => showLocationSelectorSheet(context),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: _cTeal, size: 16),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location.locationLabel.isNotEmpty
                                  ? location.locationLabel
                                  : 'Avadi, Chennai',
                              style: TextStyle(
                                color: tx,
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: _cTeal, size: 18),
                        ],
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Text(
                          'Within ${location.radiusKm.toStringAsFixed(0)} km',
                          style: TextStyle(color: sub, fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• $count available now',
                          style: const TextStyle(
                            color: _cGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  duties.computeNearbyDuties(location);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NearbyDutiesMapScreen()),
                  );
                },
                icon: const Icon(Icons.map_rounded, size: 16, color: _cTeal),
                label: const Text('View Map', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _cTeal,
                  side: BorderSide(color: _cTeal.withValues(alpha: 0.3)),
                  backgroundColor: _cTeal.withValues(alpha: 0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 128,
          child: PageView.builder(
            controller: _nearbyPageController,
            itemCount: items.length.clamp(1, 6),
            onPageChanged: (i) => setState(() => _nearbyCurrentPage = i),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final item = items[index];
              final isSaved = duties.isDutySaved(item.duty.id);
              final salaryVal = item.duty.salary;
              final distanceDisplay = item.distanceKm != null
                  ? '${item.distanceKm!.toStringAsFixed(1)} km away'
                  : 'Nearby';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: shadow,
                    border: Border.all(color: border),
                  ),
                  child: InkWell(
                    onTap: () => _openDiscoveryDutyDetails(context, item, duties),
                    borderRadius: BorderRadius.circular(20),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _cTeal.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Icon(Icons.add_box_rounded, color: _cTeal, size: 28),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item.duty.hospitalName,
                                style: TextStyle(
                                  color: tx,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.duty.displaySpecialization,
                                style: const TextStyle(
                                  color: _cTeal,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, size: 12, color: sub),
                                  const SizedBox(width: 2),
                                  Flexible(
                                    child: Text(
                                      distanceDisplay,
                                      style: TextStyle(color: sub, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 52,
                          width: 1,
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          color: border,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.calendar_today_rounded, size: 12, color: sub),
                                const SizedBox(width: 4),
                                Text(
                                  '15 Aug',
                                  style: TextStyle(color: sub, fontSize: 11.5, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () {
                                    duties.toggleSaveDuty(
                                      item.duty.id,
                                      item.duty.role,
                                      item.duty.location,
                                      item.duty.salary,
                                    );
                                    setState(() {});
                                  },
                                  child: Icon(
                                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_outline_rounded,
                                    size: 16,
                                    color: isSaved ? _cAmber : sub,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.schedule_rounded, size: 12, color: sub),
                                const SizedBox(width: 4),
                                Text(
                                  '8:00 AM – 8:00 PM ☀️',
                                  style: TextStyle(color: sub, fontSize: 11),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${salaryVal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: _cTeal,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length.clamp(1, 6),
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _nearbyCurrentPage == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _nearbyCurrentPage == i ? _cTeal : sub.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── 5. RECOMMENDATIONS SIDE-BY-SIDE ──────────────────────────────────────
  Widget _buildRecommendationsSection(
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
    bool isDark,
    LocationProvider location,
    DutyProvider duties,
    JobProvider jobs,
    ProfileProvider profile,
  ) {
    final center = location.searchLocation;
    final exclude = <String>{
      ...duties.emergencyNearby(location).map((e) => e.duty.id),
      ...duties.regularNearby(location).take(5).map((e) => e.duty.id),
    };

    final recommendedDuties = center != null
        ? RecommendedDutiesService.build(
            centerLat: center.latitude,
            centerLng: center.longitude,
            currentRadiusKm: location.radiusKm,
            specialization: profile.specialization.isNotEmpty
                ? profile.specialization
                : profile.qualification,
            locationLabel: location.locationLabel,
            excludeDutyIds: exclude,
          )
        : <DutyWithDistance>[];

    final dutyCount = recommendedDuties.isNotEmpty ? recommendedDuties.length : 8;
    final recommendedJobs = jobs.recommendedNearby(location, profile);
    final jobCount = recommendedJobs.isNotEmpty ? recommendedJobs.length : 12;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: shadow,
                border: Border.all(color: border),
              ),
              child: InkWell(
                onTap: () => AppShell.maybeOf(context)?.switchTab(1),
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended Duties',
                          style: TextStyle(
                            color: tx,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'View all',
                          style: TextStyle(
                            color: _cTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _cGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.medical_services_rounded, color: _cGreen, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$dutyCount',
                              style: TextStyle(
                                color: tx,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Duties for you',
                              style: TextStyle(color: sub, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildAvatarStack([
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
                          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
                          'https://images.unsplash.com/photo-1594824813629-9233f2a89098?w=150',
                          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150',
                        ], '+5', _cTeal),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
                boxShadow: shadow,
                border: Border.all(color: border),
              ),
              child: InkWell(
                onTap: () => openJobsScreen(context),
                borderRadius: BorderRadius.circular(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recommended Jobs',
                          style: TextStyle(
                            color: tx,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          'View all',
                          style: TextStyle(
                            color: _cTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _cBlue.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Center(
                            child: Icon(Icons.work_rounded, color: _cBlue, size: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$jobCount',
                              style: TextStyle(
                                color: tx,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              'Jobs for you',
                              style: TextStyle(color: sub, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildAvatarStack([
                          'https://images.unsplash.com/photo-1594824813629-9233f2a89098?w=150',
                          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=150',
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
                          'https://images.unsplash.com/photo-1537368910025-700350fe46c7?w=150',
                        ], '+7', _cBlue),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarStack(List<String> imageUrls, String badgeText, Color badgeColor) {
    return SizedBox(
      height: 24,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 72,
            child: Stack(
              children: List.generate(imageUrls.length, (i) {
                return Positioned(
                  left: i * 16.0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      image: DecorationImage(
                        image: NetworkImage(imageUrls[i]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badgeText,
              style: TextStyle(
                color: badgeColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 6. COMMUNITY ACTIVITY SECTION ─────────────────────────────────────────
  Widget _buildCommunityActivitySection(
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Community Activity',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: tx,
                  letterSpacing: -0.3,
                ),
              ),
              GestureDetector(
                onTap: () => AppShell.maybeOf(context)?.switchTab(2),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _cTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              boxShadow: shadow,
              border: Border.all(color: border),
            ),
            child: InkWell(
              onTap: () => AppShell.maybeOf(context)?.switchTab(2),
              borderRadius: BorderRadius.circular(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(
                          'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=150',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dr. Neha Verma',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: tx,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.verified_rounded, color: _cBlue, size: 14),
                              ],
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Dermatologist • Max Hospital Delhi',
                              style: TextStyle(color: sub, fontSize: 11),
                            ),
                            const SizedBox(height: 1),
                            Row(
                              children: [
                                Text(
                                  '2h ago • ',
                                  style: TextStyle(color: sub, fontSize: 10.5),
                                ),
                                Icon(Icons.public_rounded, size: 11, color: sub),
                                Text(
                                  ' Public',
                                  style: TextStyle(color: sub, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 80,
                          height: 52,
                          color: const Color(0xFF1E293B),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Image.network(
                                'https://images.unsplash.com/photo-1587825140708-dfaf72ae4b04?w=200',
                                fit: BoxFit.cover,
                                width: 80,
                                height: 52,
                                errorBuilder: (_, _, _) => const Icon(Icons.image, color: Colors.white54),
                              ),
                              Container(color: Colors.black26),
                              const Icon(Icons.play_circle_fill_rounded, color: Colors.white, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Just wrapped up an advanced clinical nursing workshop on pediatric ICU care...',
                    style: TextStyle(
                      color: tx,
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.thumb_up_alt_outlined, size: 15, color: sub),
                      const SizedBox(width: 4),
                      Text('128', style: TextStyle(fontSize: 11.5, color: sub, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Icon(Icons.chat_bubble_outline_rounded, size: 15, color: sub),
                      const SizedBox(width: 4),
                      Text('24', style: TextStyle(fontSize: 11.5, color: sub, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 16),
                      Icon(Icons.repeat_rounded, size: 16, color: sub),
                      const SizedBox(width: 4),
                      Text('16', style: TextStyle(fontSize: 11.5, color: sub, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 7. QUICK ACTIONS SECTION ──────────────────────────────────────────────
  Widget _buildQuickActionsSection(
    Color card,
    Color tx,
    Color sub,
    bool isDark,
  ) {
    final actions = [
      {
        'icon': Icons.medical_services_rounded,
        'title': 'Find Duties',
        'sub': 'Nearby shifts',
        'color': _cGreen,
        'onTap': () => AppShell.maybeOf(context)?.switchTab(1),
      },
      {
        'icon': Icons.work_rounded,
        'title': 'Find Jobs',
        'sub': 'Career roles',
        'color': _cBlue,
        'onTap': () => openJobsScreen(context),
      },
      {
        'icon': Icons.groups_rounded,
        'title': 'Community',
        'sub': 'Network',
        'color': _cPurple,
        'onTap': () => AppShell.maybeOf(context)?.switchTab(2),
      },
      {
        'icon': Icons.chat_bubble_rounded,
        'title': 'Messages',
        'sub': 'Inbox',
        'color': _cOrange,
        'onTap': () => AppShell.maybeOf(context)?.switchTab(3),
      },
      {
        'icon': Icons.bookmark_rounded,
        'title': 'Saved',
        'sub': 'Bookmarks',
        'color': _cAmber,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SavedScreen()),
        ),
      },
      {
        'icon': Icons.person_rounded,
        'title': 'Profile',
        'sub': 'My account',
        'color': _cTeal,
        'onTap': () => AppShell.maybeOf(context)?.switchTab(4),
      },
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: tx,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: actions.map((item) {
                final color = item['color'] as Color;
                final icon = item['icon'] as IconData;
                final title = item['title'] as String;
                final subText = item['sub'] as String;
                final onTap = item['onTap'] as VoidCallback;

                return Container(
                  width: 82,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    color: isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: color.withValues(alpha: isDark ? 0.25 : 0.15),
                      width: 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(icon, size: 20, color: color),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: tx,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          subText,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: sub,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HELPERS & FALLBACKS ──────────────────────────────────────────────────
  List<DutyWithDistance> _getMockNearbyFallback() {
    return [
      DutyWithDistance(
        duty: DutyModel(
          id: 'mock_duty_1',
          hospitalId: 'hosp_apollo',
          hospitalName: 'Apollo Clinic Avadi',
          role: 'Staff Nurse (Day Shift)',
          salary: 2200,
          location: 'Avadi, Chennai',
          dutyDate: DateTime.now().add(const Duration(days: 1)),
          startTime: DateTime(2026, 8, 15, 8, 0),
          endTime: DateTime(2026, 8, 15, 20, 0),
          status: DutyStatus.upcoming,
          shiftType: 'Day Shift',
          specialization: 'Staff Nurse',
          verified: true,
          createdAt: DateTime.now(),
        ),
        distanceKm: 0.4,
      ),
    ];
  }

  void _openDiscoveryDutyDetails(
    BuildContext context,
    DutyWithDistance item,
    DutyProvider duties,
  ) {
    final duty = item.duty;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DutyDetailsScreen(
          hospital: duty.hospitalName,
          role: duty.role,
          salary: '₹${duty.salary.toStringAsFixed(0)}',
          location: duty.location,
          date: duty.dutyDate.toString().split(' ').first,
          shift: duty.displayShift,
          time:
              '${duty.startTime.hour}:${duty.startTime.minute.toString().padLeft(2, '0')} – ${duty.endTime.hour}:${duty.endTime.minute.toString().padLeft(2, '0')}',
          spec: duty.displaySpecialization,
          dutyId: duty.id,
          distanceKm: item.distanceKm,
          dutyLatitude: duty.latitude,
          dutyLongitude: duty.longitude,
        ),
      ),
    );
  }
}

// ─── VECTOR HOSPITAL BACKGROUND PAINTER ─────────────────────────────────────
class _HospitalHeaderPainter extends CustomPainter {
  final bool isDark;
  _HospitalHeaderPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBuilding = Paint()
      ..color = isDark ? const Color(0xFF1E3A37) : const Color(0xFFE2F4F2);
    final paintCross = Paint()
      ..color = isDark ? const Color(0xFF0F766E) : const Color(0xFF2DD4BF);
    final paintTree = Paint()
      ..color = isDark ? const Color(0xFF134E48) : const Color(0xFFA7F3D0);
    final paintCloud = Paint()
      ..color = isDark ? const Color(0xFF1B2A32) : const Color(0xFFF1F5F9);

    // Clouds
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, 12, 44, 12),
        const Radius.circular(6),
      ),
      paintCloud,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.55, 6, 36, 10),
        const Radius.circular(5),
      ),
      paintCloud,
    );

    // Main Hospital Building
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.35, 24, 64, size.height - 24),
        const Radius.circular(10),
      ),
      paintBuilding,
    );

    // Left Annex
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.18, 42, 30, size.height - 42),
        const Radius.circular(6),
      ),
      paintBuilding,
    );

    // Medical Cross Badge on Hospital
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.52, 28, 20, 20),
        const Radius.circular(4),
      ),
      paintCross,
    );
    final paintWhite = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(size.width * 0.52 + 7.5, 31, 5, 14), paintWhite);
    canvas.drawRect(Rect.fromLTWH(size.width * 0.52 + 3, 35.5, 14, 5), paintWhite);

    // Trees
    canvas.drawCircle(Offset(size.width * 0.22, size.height - 12), 12, paintTree);
    canvas.drawCircle(Offset(size.width * 0.35, size.height - 10), 10, paintTree);
    canvas.drawCircle(Offset(size.width * 0.95, size.height - 12), 12, paintTree);
  }

  @override
  bool shouldRepaint(covariant _HospitalHeaderPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
