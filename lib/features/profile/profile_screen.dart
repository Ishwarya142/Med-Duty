// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/duty_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../providers/saved_provider.dart';
import '../../providers/activity_provider.dart';
import '../../providers/settings_preferences_provider.dart';
import '../chat/chat_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'public_hospital_profile_screen.dart';
import 'public_doctor_profile_screen.dart';
import 'certificates_screen.dart';
import 'medical_license_screen.dart';
import 'awards_screen.dart';
import 'research_screen.dart';
import 'profile_gallery_screen.dart';
import 'experience_screen.dart';
import 'suggested_doctors_screen.dart';
import 'profile_share_helper.dart';
import 'widgets/contact_options_sheet.dart';
import '../../core/services/profile_link_service.dart';
import 'widgets/create_professional_post_flow.dart';
import 'widgets/professional_post_card.dart';
import '../../shared/widgets/report_bottom_sheet.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cRed    = Color(0xFFEF4444);
const _cPurple = Color(0xFF7C3AED);

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final targetUid = widget.userId ?? authProvider.user?.uid;
      if (targetUid != null) {
        Provider.of<ProfileProvider>(context, listen: false).loadProfile(targetUid);
        Provider.of<DutyProvider>(context, listen: false).loadDutyData(targetUid);
        Provider.of<CommunityProvider>(context, listen: false).loadCommunityData(targetUid);
        Provider.of<WalletProvider>(context, listen: false).loadWalletData(targetUid);
        Provider.of<SavedProvider>(context, listen: false).loadSavedData(targetUid);
        Provider.of<ActivityProvider>(context, listen: false).loadActivityData(targetUid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool _checkIsOwnProfile(AuthProvider auth) {
    final currentUid = auth.user?.uid;
    if (widget.userId == null) return true;
    if (currentUid == null) return false;
    return widget.userId == currentUid;
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: _cTeal,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  void _openHighlight(BuildContext context, String label, ProfileProvider profile) {
    switch (label) {
      case 'Certificates':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CertificatesScreen()),
        );
        break;
      case 'Medical License':
      case 'License':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MedicalLicenseScreen()),
        );
        break;
      case 'Awards':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AwardsScreen()),
        );
        break;
      case 'Research':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ResearchScreen()),
        );
        break;
      case 'Hospital':
        final hospital = profile.currentHospital.isNotEmpty
            ? profile.currentHospital
            : 'Max Hospital Delhi';
        final hospitalId = ProfileLinkService.slugFromName(hospital);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicHospitalProfileScreen(
              hospitalId: hospitalId,
              hospitalName: hospital,
              hospitalType: 'Multi-speciality Hospital',
              location: profile.currentCity.isNotEmpty
                  ? '${profile.currentCity}, ${profile.country.isNotEmpty ? profile.country : 'India'}'
                  : 'Delhi, India',
              speciality: profile.specialization.isNotEmpty ? profile.specialization : 'Dermatology',
            ),
          ),
        );
        break;
      case 'Gallery':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileGalleryScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final authProvider = context.watch<AuthProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final dutyProvider = context.watch<DutyProvider>();
    final communityProvider = context.watch<CommunityProvider>();
    final settingsProvider = context.watch<SettingsPreferencesProvider>();

    final isOwnProfile = _checkIsOwnProfile(authProvider);

    // ── Dynamic Profile Identity ──────────────────────────────────────────────
    final rawName = profileProvider.name.trim();
    final doctorName = rawName.isNotEmpty
        ? (rawName.startsWith('Dr.') ? rawName : 'Dr. $rawName')
        : (authProvider.user?.displayName?.isNotEmpty == true
            ? 'Dr. ${authProvider.user!.displayName}'
            : 'Dr. Rohan Mehta');

    final qualification = profileProvider.degree.isNotEmpty
        ? profileProvider.degree
        : (profileProvider.qualification.isNotEmpty
            ? profileProvider.qualification
            : 'MBBS, MD');

    final specialty = profileProvider.specialization.isNotEmpty
        ? profileProvider.specialization
        : 'Dermatologist';

    final hospital = profileProvider.currentHospital.isNotEmpty
        ? profileProvider.currentHospital
        : 'Max Hospital Delhi';

    final displayLocation = profileProvider.currentCity.isNotEmpty
        ? '${profileProvider.currentCity}, ${profileProvider.country.isNotEmpty ? profileProvider.country : 'India'}'
        : 'Delhi, India';

    final expYears = profileProvider.experience > 0 ? profileProvider.experience : 8;

    // Real Statistics counts
    final postsCount = communityProvider.myPostsCount > 0
        ? communityProvider.myPostsCount
        : communityProvider.myPosts.length;
    final followersCount = profileProvider.followersCount;
    final followingCount = profileProvider.followingCount;
    final dutiesCount = dutyProvider.completedDutiesCount;
    final ratingScore = profileProvider.reviews.isNotEmpty
        ? profileProvider.averageRating.toStringAsFixed(1)
        : '4.8';
    final reviewsCount = profileProvider.reviews.isNotEmpty
        ? profileProvider.reviews.length
        : 128;

    final isFollowingOther = widget.userId != null
        ? profileProvider.isFollowingUser(widget.userId!)
        : false;

    return Scaffold(
      backgroundColor: bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // ── Sliver App Bar with Hospital Cover ──────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 2,
            backgroundColor: bg,
            leading: Navigator.canPop(context) || !isOwnProfile
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  )
                : null,
            title: isOwnProfile && innerBoxIsScrolled
                ? Text(
                    doctorName,
                    style: TextStyle(
                      color: tx,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
            actions: [
              // Share Profile Icon Button
              IconButton(
                tooltip: 'Share Profile',
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.share_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  ProfileShareHelper.showShareSheet(
                    context,
                    ProfileShareHelper.ownProfile(context),
                  );
                },
              ),

              // QR Code Icon Button
              IconButton(
                tooltip: 'Profile QR Code',
                icon: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                onPressed: () {
                  ProfileShareHelper.openQrScreen(
                    context,
                    ProfileShareHelper.ownProfile(context),
                  );
                },
              ),

              // If My Profile: Settings Button; If Other Profile: Overflow Menu
              if (isOwnProfile)
                IconButton(
                  tooltip: 'Settings',
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                )
              else
                PopupMenuButton<String>(
                  icon: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.more_vert_rounded,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                  onSelected: (val) {
                    if (val == 'report') {
                      showContentReportSheet(
                        context,
                        subjectLabel: 'Doctor Profile ($doctorName)',
                        targetId: widget.userId ?? doctorName,
                        targetName: doctorName,
                        reportType: 'profile',
                      );
                    } else if (val == 'block') {
                      settingsProvider.blockUser(
                        id: widget.userId ?? doctorName,
                        name: doctorName,
                        role: '$qualification • $specialty',
                      );
                      _showSnackBar('$doctorName blocked');
                    }
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'report', child: Text('Report Profile')),
                    const PopupMenuItem(value: 'block', child: Text('Block User', style: TextStyle(color: _cRed))),
                  ],
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildCoverImage(profileProvider),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Profile Hero Section (Avatar, Info, Rating, Chips, Stats, Actions, Highlights) ──
          SliverToBoxAdapter(
            child: Container(
              transform: Matrix4.translationValues(0, -24, 0),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Doctor Avatar & Identity Row ─────────────────────────
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar with Online Dot
                        Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3.5),
                              decoration: BoxDecoration(
                                color: card,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: _buildAvatarCircle(profileProvider, doctorName),
                            ),
                            Positioned(
                              right: 4,
                              bottom: 4,
                              child: Container(
                                width: 15,
                                height: 15,
                                decoration: BoxDecoration(
                                  color: profileProvider.emergencyAvailable ? _cGreen : _cGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: card, width: 2.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 14),

                        // Doctor Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Verified Badge Pill
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: _cTeal.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, color: _cTeal, size: 12),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified Professional',
                                      style: TextStyle(
                                        color: _cTeal,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Doctor Name + Checkmark
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      doctorName,
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: tx,
                                        letterSpacing: -0.3,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded, color: _cBlue, size: 18),
                                ],
                              ),
                              const SizedBox(height: 2),

                              // Qualification • Specialization
                              Text(
                                '$qualification • $specialty',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: tx.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),

                              // Hospital with Medical Plus Icon
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: _cBlue.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Icon(Icons.add_box_rounded, color: _cBlue, size: 13),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      hospital,
                                      style: TextStyle(fontSize: 12.5, color: sub, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),

                              // Location
                              Row(
                                children: [
                                  Icon(Icons.location_on_outlined, color: sub, size: 13),
                                  const SizedBox(width: 3),
                                  Text(
                                    displayLocation,
                                    style: TextStyle(fontSize: 12, color: sub),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Compact Rating Card on Right
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star_rounded, color: _cAmber, size: 16),
                                  const SizedBox(width: 3),
                                  Text(
                                    ratingScore,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '($reviewsCount reviews)',
                                style: TextStyle(fontSize: 10, color: sub),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Status Chips Row ──────────────────────────────────────
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _statusChip(
                          icon: Icons.circle,
                          iconColor: _cGreen,
                          iconSize: 8,
                          label: profileProvider.emergencyAvailable
                              ? 'Available for Duty'
                              : 'Available for Duty',
                          bgColor: _cGreen.withValues(alpha: 0.08),
                          borderColor: _cGreen.withValues(alpha: 0.3),
                          textColor: _cGreen,
                        ),
                        _statusChip(
                          icon: Icons.verified_user_outlined,
                          iconColor: _cTeal,
                          iconSize: 13,
                          label: 'Reg. Verified',
                          bgColor: card,
                          borderColor: border,
                          textColor: tx,
                        ),
                        _statusChip(
                          icon: Icons.person_outline_rounded,
                          iconColor: sub,
                          iconSize: 13,
                          label: '$expYears+ Years Experience',
                          bgColor: card,
                          borderColor: border,
                          textColor: tx,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ── Statistics Card (6 columns with real data) ────────────
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: border),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCell(
                            _formatCount(postsCount),
                            'Posts',
                            tx,
                            sub,
                            isSelected: _tabController.index == 0,
                            onTap: () => _tabController.animateTo(0),
                          ),
                          _statDivider(border),
                          _buildStatCell(
                            _formatCount(followersCount),
                            'Followers',
                            tx,
                            sub,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SuggestedDoctorsScreen()),
                            ),
                          ),
                          _statDivider(border),
                          _buildStatCell(
                            _formatCount(followingCount),
                            'Following',
                            tx,
                            sub,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SuggestedDoctorsScreen()),
                            ),
                          ),
                          _statDivider(border),
                          _buildStatCell(
                            _formatCount(dutiesCount),
                            'Duties',
                            tx,
                            sub,
                            onTap: () => _tabController.animateTo(2),
                          ),
                          _statDivider(border),
                          _buildStatCell(
                            '$expYears Yrs',
                            'Experience',
                            tx,
                            sub,
                            onTap: () => _tabController.animateTo(1),
                          ),
                          _statDivider(border),
                          _buildStatCell(
                            ratingScore,
                            'Rating',
                            tx,
                            sub,
                            onTap: () => _tabController.animateTo(3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── PRIMARY ACTIONS: My Profile vs Other Profile ──────────
                    if (isOwnProfile) ...[
                      // ── MY PROFILE ACTIONS: Edit Profile | Share | QR | Preview ──
                      Row(
                        children: [
                          // Primary Edit Profile Button
                          Expanded(
                            flex: 4,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _cTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.edit_outlined, size: 17),
                              label: const Text(
                                'Edit Profile',
                                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Share Button
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ProfileShareHelper.showShareSheet(
                                  context,
                                  ProfileShareHelper.ownProfile(context),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tx,
                                side: const BorderSide(color: _cTeal, width: 1.2),
                                backgroundColor: card,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.share_outlined, color: _cTeal, size: 16),
                              label: const Text(
                                'Share',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // QR Code Button
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ProfileShareHelper.openQrScreen(
                                  context,
                                  ProfileShareHelper.ownProfile(context),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tx,
                                side: const BorderSide(color: _cTeal, width: 1.2),
                                backgroundColor: card,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded, color: _cTeal, size: 16),
                              label: const Text(
                                'QR Code',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Preview Public Profile Button
                          IconButton(
                            tooltip: 'Preview Public Profile',
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PublicDoctorProfileScreen(
                                    doctorId: authProvider.user?.uid,
                                    doctorName: doctorName,
                                    qualification: qualification,
                                    specialization: specialty,
                                    hospital: hospital,
                                    location: displayLocation,
                                  ),
                                ),
                              );
                            },
                            style: IconButton.styleFrom(
                              backgroundColor: card,
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.visibility_outlined, color: _cTeal, size: 19),
                          ),
                        ],
                      ),
                    ] else ...[
                      // ── OTHER USER ACTIONS: Follow | Message | Call | QR ──
                      Row(
                        children: [
                          // Follow button
                          Expanded(
                            flex: 3,
                            child: ElevatedButton.icon(
                              onPressed: widget.userId != null
                                  ? () async {
                                      if (isFollowingOther) {
                                        await profileProvider.unfollowUser(widget.userId!);
                                        _showSnackBar('Unfollowed $doctorName');
                                      } else {
                                        await profileProvider.followUser(
                                          targetUserId: widget.userId!,
                                          targetName: doctorName,
                                          targetSpecialization: specialty,
                                        );
                                        _showSnackBar('Following $doctorName');
                                      }
                                      setState(() {});
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _cTeal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                isFollowingOther ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
                                size: 17,
                              ),
                              label: Text(
                                isFollowingOther ? 'Following' : 'Follow',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Message Button
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      receiverName: doctorName,
                                      receiverRole: specialty,
                                      receiverHospital: hospital,
                                      isOnline: true,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tx,
                                side: const BorderSide(color: _cTeal, width: 1.2),
                                backgroundColor: card,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.chat_bubble_outline_rounded, color: _cTeal, size: 16),
                              label: const Text(
                                'Message',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Call Button
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ContactOptionsSheet.show(
                                  context,
                                  displayName: doctorName,
                                  role: '$qualification • $specialty',
                                  phone: '+91 98765 43210',
                                  email: '${doctorName.toLowerCase().replaceAll(' ', '.')}@medduty.in',
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tx,
                                side: const BorderSide(color: _cTeal, width: 1.2),
                                backgroundColor: card,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.phone_outlined, color: _cTeal, size: 16),
                              label: const Text(
                                'Call',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // QR Code Button
                          Expanded(
                            flex: 3,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                ProfileShareHelper.openQrScreen(
                                  context,
                                  ProfileShareHelper.doctor(
                                    doctorId: widget.userId,
                                    doctorName: doctorName,
                                    specialization: specialty,
                                    hospital: hospital,
                                    location: displayLocation,
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: tx,
                                side: const BorderSide(color: _cTeal, width: 1.2),
                                backgroundColor: card,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded, color: _cTeal, size: 16),
                              label: const Text(
                                'QR Code',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 18),

                    // ── Highlights Section ─────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Highlights',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: tx,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CertificatesScreen()),
                          ),
                          child: const Row(
                            children: [
                              Text(
                                'View all',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: _cTeal,
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded, color: _cTeal, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 84,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildCircularHighlight(
                            Icons.verified_outlined,
                            'Certificates',
                            '12',
                            _cTeal,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Certificates', profileProvider),
                          ),
                          _buildCircularHighlight(
                            Icons.badge_outlined,
                            'Medical\nLicense',
                            '1',
                            _cBlue,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Medical License', profileProvider),
                          ),
                          _buildCircularHighlight(
                            Icons.emoji_events_outlined,
                            'Awards',
                            '8',
                            _cAmber,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Awards', profileProvider),
                          ),
                          _buildCircularHighlight(
                            Icons.science_outlined,
                            'Research',
                            '9',
                            _cPurple,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Research', profileProvider),
                          ),
                          _buildCircularHighlight(
                            Icons.local_hospital_outlined,
                            'Hospital',
                            '2',
                            _cTeal,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Hospital', profileProvider),
                          ),
                          _buildCircularHighlight(
                            Icons.photo_library_outlined,
                            'Gallery',
                            '24',
                            _cGreen,
                            card,
                            border,
                            tx,
                            () => _openHighlight(context, 'Gallery', profileProvider),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── Sticky Tab Bar Navigation ────────────────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabHeaderDelegate(
              TabBar(
                controller: _tabController,
                labelColor: _cTeal,
                unselectedLabelColor: sub,
                indicatorColor: _cTeal,
                indicatorWeight: 2.8,
                indicatorSize: TabBarIndicatorSize.label,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                tabs: const [
                  Tab(icon: Icon(Icons.grid_view_rounded, size: 18), text: 'Posts'),
                  Tab(icon: Icon(Icons.star_border_rounded, size: 18), text: 'Experience'),
                  Tab(icon: Icon(Icons.business_center_outlined, size: 18), text: 'Duties'),
                  Tab(icon: Icon(Icons.star_outline_rounded, size: 18), text: 'Reviews'),
                  Tab(icon: Icon(Icons.info_outline_rounded, size: 18), text: 'About'),
                ],
              ),
              card,
              border,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(communityProvider, doctorName, specialty, hospital, isOwnProfile, card, border, tx, sub),
            _buildExperienceTab(profileProvider, isOwnProfile, card, border, tx, sub, specialty, hospital),
            _buildDutiesTab(dutyProvider, isOwnProfile, card, border, tx, sub),
            _buildReviewsTab(profileProvider, doctorName, card, border, tx, sub),
            _buildAboutTab(profileProvider, isOwnProfile, card, border, tx, sub, specialty, hospital, displayLocation),
          ],
        ),
      ),
    );
  }

  // ── Cover Image Helper ──────────────────────────────────────────────────────
  Widget _buildCoverImage(ProfileProvider profile) {
    if (profile.coverPic.isNotEmpty) {
      if (profile.coverPic.startsWith('http')) {
        return Image.network(
          profile.coverPic,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultCoverImage(),
        );
      } else {
        return Image.file(
          File(profile.coverPic),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultCoverImage(),
        );
      }
    }
    return _defaultCoverImage();
  }

  Widget _defaultCoverImage() {
    return Image.network(
      'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=1200&q=80',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F766E), Color(0xFF1E293B)],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarCircle(ProfileProvider profile, String doctorName) {
    if (profile.profilePic.isNotEmpty) {
      if (profile.profilePic.startsWith('http')) {
        return CircleAvatar(
          radius: 44,
          backgroundColor: _cTeal,
          backgroundImage: NetworkImage(profile.profilePic),
        );
      } else {
        return CircleAvatar(
          radius: 44,
          backgroundColor: _cTeal,
          backgroundImage: FileImage(File(profile.profilePic)),
        );
      }
    }

    final initials = doctorName
        .replaceFirst('Dr.', '')
        .trim()
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .where((e) => e.isNotEmpty)
        .take(2)
        .join();

    return CircleAvatar(
      radius: 44,
      backgroundColor: _cTeal,
      backgroundImage: const NetworkImage(
        'https://images.unsplash.com/photo-1594824813686-e0bcffea5e97?auto=format&fit=crop&w=400&q=80',
      ),
      child: initials.isNotEmpty
          ? null
          : const Icon(Icons.person, color: Colors.white, size: 40),
    );
  }

  // ── Status Chip Helper ──────────────────────────────────────────────────────
  Widget _statusChip({
    required IconData icon,
    required Color iconColor,
    required double iconSize,
    required String label,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: iconSize),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat Item & Divider ─────────────────────────────────────────────────────
  Widget _buildStatCell(
    String value,
    String label,
    Color tx,
    Color sub, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.bold,
              color: isSelected ? _cTeal : tx,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isSelected ? _cTeal : sub,
            ),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 3),
              width: 16,
              height: 2,
              decoration: BoxDecoration(
                color: _cTeal,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statDivider(Color border) =>
      Container(width: 1, height: 24, color: border);

  Widget _buildCircularHighlight(
    IconData icon,
    String title,
    String count,
    Color accentColor,
    Color card,
    Color border,
    Color tx,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 68,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: tx,
                height: 1.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              count,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: tx.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. POSTS TAB ────────────────────────────────────────────────────────────
  Widget _buildPostsTab(
    CommunityProvider community,
    String doctorName,
    String specialty,
    String hospital,
    bool isOwner,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    final posts = community.myPosts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (isOwner) ...[
          // Create Post Action Prompt for Owner
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: _cTeal,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1594824813686-e0bcffea5e97?auto=format&fit=crop&w=200&q=80',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => showCreateProfessionalPostFlow(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: sub.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: border),
                      ),
                      child: Text(
                        'Share a clinical milestone or update…',
                        style: TextStyle(color: sub, fontSize: 12.5),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Create Post',
                  icon: const Icon(Icons.add_photo_alternate_outlined, color: _cTeal, size: 22),
                  onPressed: () => showCreateProfessionalPostFlow(context),
                ),
              ],
            ),
          ),
        ],

        if (posts.isNotEmpty)
          ...posts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProfessionalPostCard(
                post: p,
                isOwner: isOwner,
              ),
            ),
          )
        else ...[
          _clinicalPostCard(doctorName, specialty, hospital, card, border, tx, sub),
        ],
      ],
    );
  }

  Widget _clinicalPostCard(
    String doctorName,
    String specialty,
    String hospital,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: _cTeal,
                backgroundImage: NetworkImage(
                  'https://images.unsplash.com/photo-1594824813686-e0bcffea5e97?auto=format&fit=crop&w=200&q=80',
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
                          doctorName,
                          style: TextStyle(
                            color: tx,
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded, color: _cBlue, size: 14),
                      ],
                    ),
                    Text(
                      '$specialty • $hospital',
                      style: TextStyle(color: sub, fontSize: 11.5),
                    ),
                    Row(
                      children: [
                        Text('2h ago', style: TextStyle(color: sub, fontSize: 10.5)),
                        const SizedBox(width: 4),
                        Icon(Icons.public_rounded, color: sub, size: 11),
                        const SizedBox(width: 2),
                        Text('Public', style: TextStyle(color: sub, fontSize: 10.5)),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border_rounded, color: sub, size: 20),
              const SizedBox(width: 6),
              Icon(Icons.more_horiz_rounded, color: sub, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(color: tx, fontSize: 13.5, height: 1.45),
              children: const [
                TextSpan(
                  text:
                      'Just wrapped up an advanced clinical dermatology workshop focusing on laser therapies and skin rejuvenation techniques. Exciting advancements for better patient outcomes!\n',
                ),
                TextSpan(
                  text: '#Dermatology #LaserTherapy #MedDutyCommunity',
                  style: TextStyle(
                    color: _cTeal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1576091160550-2173dba999ef?auto=format&fit=crop&w=400&q=80',
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1629909613654-28e377c37b09?auto=format&fit=crop&w=400&q=80',
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1582750433449-648ed127bb54?auto=format&fit=crop&w=400&q=80',
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.thumb_up_alt_rounded, color: _cBlue, size: 16),
                  const SizedBox(width: 2),
                  const Icon(Icons.favorite_rounded, color: _cRed, size: 16),
                  const SizedBox(width: 4),
                  Text('128', style: TextStyle(color: sub, fontSize: 12)),
                  const SizedBox(width: 14),
                  Icon(Icons.chat_bubble_outline_rounded, color: sub, size: 15),
                  const SizedBox(width: 4),
                  Text('24', style: TextStyle(color: sub, fontSize: 12)),
                  const SizedBox(width: 14),
                  Icon(Icons.share_outlined, color: sub, size: 15),
                  const SizedBox(width: 4),
                  Text('16', style: TextStyle(color: sub, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Text(
                    'View all comments',
                    style: TextStyle(
                      color: sub,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: sub, size: 15),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 2. EXPERIENCE TAB ───────────────────────────────────────────────────────
  Widget _buildExperienceTab(
    ProfileProvider profile,
    bool isOwner,
    Color card,
    Color border,
    Color tx,
    Color sub,
    String specialty,
    String hospital,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sectionHeader('Work Experience', Icons.work_outline_rounded, tx),
            if (isOwner)
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExperienceScreen()),
                ),
                child: const Text(
                  '+ Add',
                  style: TextStyle(color: _cTeal, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _experienceTimelineItem(
                logo: 'MAX',
                logoColor: _cBlue,
                role: specialty,
                hospital: hospital,
                duration: 'Jan 2020 – Present • 4.5 yrs',
                description:
                    'Specializing in clinical dermatology, laser treatments, and cosmetic procedures.',
                isFirst: true,
                isLast: false,
                tx: tx,
                sub: sub,
                border: border,
              ),
              _experienceTimelineItem(
                logo: 'AIIMS',
                logoColor: _cPurple,
                role: 'Senior Resident',
                hospital: 'AIIMS, New Delhi',
                duration: 'May 2016 – Dec 2019 • 3.5 yrs',
                description:
                    'Worked in dermatology department handling OPD, IPD and emergency cases.',
                isFirst: false,
                isLast: false,
                tx: tx,
                sub: sub,
                border: border,
              ),
              _experienceTimelineItem(
                logo: 'SJ',
                logoColor: _cGreen,
                role: 'Junior Resident',
                hospital: 'Safdarjung Hospital, Delhi',
                duration: 'Jun 2014 – Apr 2016 • 1.10 yrs',
                description:
                    'Managed dermatology patients and assisted in surgical procedures.',
                isFirst: false,
                isLast: true,
                tx: tx,
                sub: sub,
                border: border,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Education Section
        _sectionHeader('Education & Qualifications', Icons.school_outlined, tx),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            children: [
              _educationTile('MD in Dermatology', 'AIIMS, New Delhi', '2016', _cTeal, tx, sub),
              const Divider(height: 20),
              _educationTile('MBBS (Bachelor of Medicine)', 'Maulana Azad Medical College (MAMC)', '2013', _cBlue, tx, sub),
            ],
          ),
        ),
      ],
    );
  }

  Widget _educationTile(String degree, String college, String year, Color color, Color tx, Color sub) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.school_rounded, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                degree,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: tx),
              ),
              Text(
                college,
                style: TextStyle(fontSize: 12.5, color: sub),
              ),
            ],
          ),
        ),
        Text(
          year,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: sub),
        ),
      ],
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color tx) {
    return Row(
      children: [
        Icon(icon, size: 18, color: _cTeal),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: tx),
        ),
      ],
    );
  }

  Widget _experienceTimelineItem({
    required String logo,
    required Color logoColor,
    required String role,
    required String hospital,
    required String duration,
    required String description,
    required bool isFirst,
    required bool isLast,
    required Color tx,
    required Color sub,
    required Color border,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: logoColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: logoColor.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  logo,
                  style: TextStyle(
                    color: logoColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 54,
                color: border,
                margin: const EdgeInsets.symmetric(vertical: 4),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: tx,
                ),
              ),
              Text(
                hospital,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: sub,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                duration,
                style: TextStyle(
                  fontSize: 11.5,
                  color: sub.withValues(alpha: 0.8),
                ),
              ),
              if (description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: tx.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              ],
              const SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  // ── 3. DUTIES TAB ───────────────────────────────────────────────────────────
  Widget _buildDutiesTab(
    DutyProvider duty,
    bool isOwner,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        _dutyItemCard(
          'ICU Night Shift Duty',
          'Max Hospital, Delhi',
          'Completed • 08:00 PM – 08:00 AM',
          '₹ 8,500',
          'Completed',
          _cGreen,
          card,
          border,
          tx,
          sub,
        ),
        const SizedBox(height: 10),
        _dutyItemCard(
          'Emergency Room Coverage',
          'Max Hospital, Saket',
          'Weekends • 09:00 AM – 05:00 PM',
          '₹ 6,000',
          'Confirmed',
          _cTeal,
          card,
          border,
          tx,
          sub,
        ),
      ],
    );
  }

  Widget _dutyItemCard(
    String title,
    String hospital,
    String timing,
    String stipend,
    String status,
    Color statusColor,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: tx,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(hospital, style: TextStyle(fontSize: 12.5, color: sub)),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.access_time_rounded, size: 13, color: sub),
                  const SizedBox(width: 4),
                  Text(timing, style: TextStyle(fontSize: 11.5, color: sub)),
                ],
              ),
              Text(
                stipend,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: _cTeal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4. REVIEWS TAB ──────────────────────────────────────────────────────────
  Widget _buildReviewsTab(
    ProfileProvider profile,
    String doctorName,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Column(
                children: [
                  const Text(
                    '4.8',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _cTeal,
                    ),
                  ),
                  Row(
                    children: List.generate(
                      5,
                      (_) => const Icon(Icons.star_rounded, color: _cAmber, size: 16),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text('128 reviews', style: TextStyle(fontSize: 11.5, color: sub)),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    _ratingBar('5 ★', 0.82, _cTeal, tx, sub),
                    _ratingBar('4 ★', 0.14, _cTeal, tx, sub),
                    _ratingBar('3 ★', 0.04, _cTeal, tx, sub),
                    _ratingBar('2 ★', 0.00, _cTeal, tx, sub),
                    _ratingBar('1 ★', 0.00, _cTeal, tx, sub),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ratingBar(String label, double progress, Color color, Color tx, Color sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 10.5, color: sub)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: sub.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 5. ABOUT TAB ────────────────────────────────────────────────────────────
  Widget _buildAboutTab(
    ProfileProvider profile,
    bool isOwner,
    Color card,
    Color border,
    Color tx,
    Color sub,
    String specialty,
    String hospital,
    String location,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Professional Summary',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: tx,
                    ),
                  ),
                  if (isOwner)
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                      ),
                      child: const Text(
                        'Edit',
                        style: TextStyle(color: _cTeal, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                profile.bio.isNotEmpty
                    ? profile.bio
                    : 'Board-certified $specialty with clinical experience at $hospital. Active member of national medical associations and dedicated to patient-centered evidence-based healthcare.',
                style: TextStyle(fontSize: 13.5, color: tx, height: 1.5),
              ),
              const Divider(height: 24),
              _aboutRow(
                Icons.badge_outlined,
                'Registration Council',
                profile.medicalRegistration.council.isNotEmpty
                    ? profile.medicalRegistration.council
                    : 'Delhi Medical Council (DMC)',
                tx,
                sub,
              ),
              const SizedBox(height: 10),
              _aboutRow(
                Icons.confirmation_number_outlined,
                'Registration Number',
                profile.medicalRegistrationNumber.isNotEmpty
                    ? profile.medicalRegistrationNumber
                    : 'DMC-2016-8842',
                tx,
                sub,
              ),
              const SizedBox(height: 10),
              _aboutRow(Icons.location_on_outlined, 'Primary Location', location, tx, sub),
              const SizedBox(height: 10),
              _aboutRow(Icons.local_hospital_outlined, 'Current Affiliation', hospital, tx, sub),
              const SizedBox(height: 10),
              _aboutRow(Icons.payments_outlined, 'Consultation Fee', '₹ 800 - In-clinic, Online', tx, sub),
            ],
          ),
        ),
      ],
    );
  }

  Widget _aboutRow(IconData icon, String title, String value, Color tx, Color sub) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _cTeal),
        const SizedBox(width: 8),
        Text('$title: ', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: sub)),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tx),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

// ── Persistent Header Delegate for Sticky Tabs ────────────────────────────────
class _SliverTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final Color _bg;
  final Color _border;

  _SliverTabHeaderDelegate(this._tabBar, this._bg, this._border);

  @override
  double get minExtent => _tabBar.preferredSize.height + 1;
  @override
  double get maxExtent => _tabBar.preferredSize.height + 1;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: _bg,
        border: Border(bottom: BorderSide(color: _border)),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabHeaderDelegate oldDelegate) => true;
}
