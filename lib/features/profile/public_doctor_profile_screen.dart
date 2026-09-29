// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../chat/chat_screen.dart';
import '../../models/profile_share_data.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../providers/profile_provider.dart';
import 'widgets/professional_post_card.dart';
import 'profile_share_helper.dart';
import 'certificates_screen.dart';
import 'medical_license_screen.dart';
import 'awards_screen.dart';
import 'research_screen.dart';
import 'profile_gallery_screen.dart';
import 'public_hospital_profile_screen.dart';
import 'experience_screen.dart';
import '../../core/services/profile_link_service.dart';
import '../../core/services/profile_share_service.dart';
import 'widgets/contact_options_sheet.dart';
import '../../shared/widgets/report_bottom_sheet.dart';
import '../../providers/settings_preferences_provider.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cRed    = Color(0xFFEF4444);
const _cPurple = Color(0xFF7C3AED);

class PublicDoctorProfileScreen extends StatefulWidget {
  final String? doctorId;
  final String doctorName;
  final String qualification;
  final String specialization;
  final String hospital;
  final String location;
  final String? avatarInitials;
  final Color? avatarColor;

  const PublicDoctorProfileScreen({
    super.key,
    this.doctorId,
    required this.doctorName,
    required this.qualification,
    required this.specialization,
    required this.hospital,
    required this.location,
    this.avatarInitials,
    this.avatarColor,
  });

  @override
  State<PublicDoctorProfileScreen> createState() =>
      _PublicDoctorProfileScreenState();
}

class _PublicDoctorProfileScreenState extends State<PublicDoctorProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final community = context.read<CommunityProvider>();
    final auth = context.read<AuthProvider>();
    final profile = context.read<ProfileProvider>();
    final doctorId = widget.doctorId;

    if (doctorId != null) {
      final isFollowing = profile.isFollowingUser(doctorId);
      final isOwner = auth.user?.uid == doctorId;
      await community.loadAuthorPosts(
        authorId: doctorId,
        viewerId: auth.user?.uid,
        isFollowingAuthor: isFollowing,
        isOwner: isOwner,
      );
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

  ProfileShareData get _shareData => ProfileShareHelper.doctor(
        doctorId: widget.doctorId,
        doctorName: widget.doctorName,
        specialization: widget.specialization,
        hospital: widget.hospital,
        location: widget.location,
        avatarInitials: widget.avatarInitials,
      );

  Future<void> _copyProfileLink() async {
    try {
      await ProfileShareService.copyProfileLink(_shareData);
      if (!mounted) return;
      _showSnackBar('Profile link copied');
    } catch (_) {
      if (mounted) _showSnackBar('Unable to copy link. Please try again.');
    }
  }

  void _openReport() {
    showContentReportSheet(
      context,
      subjectLabel: 'Doctor Profile (${widget.doctorName})',
      targetId: widget.doctorId ?? widget.doctorName,
      targetName: widget.doctorName,
      reportType: 'profile',
    );
  }

  Future<void> _handleMenuAction(String action) async {
    final settings = context.read<SettingsPreferencesProvider>();
    final doctorBlockId = widget.doctorId ?? widget.doctorName;
    final isBlocked = settings.isUserBlocked(doctorBlockId);

    switch (action) {
      case 'report':
        _openReport();
        break;
      case 'block':
        if (isBlocked) {
          await settings.unblockUser(doctorBlockId);
          if (mounted) _showSnackBar('${widget.doctorName} unblocked');
        } else {
          await settings.blockUser(
            id: doctorBlockId,
            name: widget.doctorName,
            role: '${widget.qualification} • ${widget.specialization}',
          );
          if (widget.doctorId != null && mounted) {
            await context.read<ProfileProvider>().unfollowUser(widget.doctorId!);
          }
          if (mounted) _showSnackBar('${widget.doctorName} blocked');
        }
        break;
      case 'mute':
        _showSnackBar('${widget.doctorName} notifications muted');
        break;
      case 'copy_link':
        _copyProfileLink();
        break;
    }
  }

  void _openHighlight(BuildContext context, String label) {
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
      case 'Experience':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExperienceScreen()),
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
        final hospitalId = ProfileLinkService.slugFromName(widget.hospital);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PublicHospitalProfileScreen(
              hospitalId: hospitalId,
              hospitalName: widget.hospital,
              hospitalType: 'Multi-speciality Hospital',
              location: widget.location,
              speciality: widget.specialization,
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

    final profile = context.watch<ProfileProvider>();
    final community = context.watch<CommunityProvider>();
    final settings = context.watch<SettingsPreferencesProvider>();

    final isFollowing = widget.doctorId != null
        ? profile.isFollowingUser(widget.doctorId!)
        : false;
    final isBlocked = settings.isUserBlocked(widget.doctorId ?? widget.doctorName);

    return Scaffold(
      backgroundColor: bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _cTeal))
          : NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                // ── Sliver App Bar with Hospital Cover ────────────────────────
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  elevation: 0,
                  scrolledUnderElevation: 2,
                  backgroundColor: bg,
                  leading: Padding(
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
                  ),
                  actions: [
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
                        ProfileShareHelper.showShareSheet(context, _shareData);
                      },
                    ),
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
                      onSelected: _handleMenuAction,
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'report',
                          child: Text('Report Profile'),
                        ),
                        PopupMenuItem(
                          value: 'block',
                          child: Text(
                            isBlocked ? 'Unblock' : 'Block',
                            style: TextStyle(color: isBlocked ? _cGreen : _cRed),
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'mute',
                          child: Text('Mute Notifications'),
                        ),
                        const PopupMenuItem(
                          value: 'copy_link',
                          child: Text('Copy Profile Link'),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.parallax,
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          'https://images.unsplash.com/photo-1586773860418-d37222d8fce3?auto=format&fit=crop&w=1200&q=80',
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF1E293B)],
                              ),
                            ),
                          ),
                        ),
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

                // ── Profile Hero Section (Avatar, Name, Rating, Chips, Stats, Actions, Highlights) ──
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
                          // ── Doctor Avatar & Identity Row ───────────────────
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
                                    child: const CircleAvatar(
                                      radius: 44,
                                      backgroundColor: _cTeal,
                                      backgroundImage: NetworkImage(
                                        'https://images.unsplash.com/photo-1594824813686-e0bcffea5e97?auto=format&fit=crop&w=400&q=80',
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      width: 15,
                                      height: 15,
                                      decoration: BoxDecoration(
                                        color: _cGreen,
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
                                            'Verified',
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
                                            widget.doctorName,
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
                                      '${widget.qualification} • ${widget.specialization}',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: tx.withValues(alpha: 0.85),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 3),

                                    // Hospital with Plus Badge
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
                                            widget.hospital,
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
                                          widget.location,
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
                                    const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.star_rounded, color: _cAmber, size: 16),
                                        SizedBox(width: 3),
                                        Text(
                                          '4.8',
                                          style: TextStyle(
                                            fontSize: 14.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '(128 reviews)',
                                      style: TextStyle(fontSize: 10, color: sub),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // ── Status Chips Row ────────────────────────────────
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _statusChip(
                                icon: Icons.circle,
                                iconColor: _cGreen,
                                iconSize: 8,
                                label: 'Available for Duty',
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
                                label: '8+ Years Experience',
                                bgColor: card,
                                borderColor: border,
                                textColor: tx,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ── Statistics Card (6 columns) ─────────────────────
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
                                  '${community.authorPosts.length}',
                                  'Posts',
                                  tx,
                                  sub,
                                  isSelected: _tabController.index == 0,
                                  onTap: () => _tabController.animateTo(0),
                                ),
                                _statDivider(border),
                                _buildStatCell(
                                  '2.4K',
                                  'Followers',
                                  tx,
                                  sub,
                                ),
                                _statDivider(border),
                                _buildStatCell(
                                  '356',
                                  'Following',
                                  tx,
                                  sub,
                                ),
                                _statDivider(border),
                                _buildStatCell(
                                  '124',
                                  'Duties',
                                  tx,
                                  sub,
                                  onTap: () => _tabController.animateTo(2),
                                ),
                                _statDivider(border),
                                _buildStatCell(
                                  '8 Yrs',
                                  'Experience',
                                  tx,
                                  sub,
                                  onTap: () => _tabController.animateTo(1),
                                ),
                                _statDivider(border),
                                _buildStatCell(
                                  '4.8',
                                  'Rating',
                                  tx,
                                  sub,
                                  onTap: () => _tabController.animateTo(3),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Action Buttons Row (Follow, Message, Call, QR) ──
                          Row(
                            children: [
                              // Follow button
                              Expanded(
                                flex: 3,
                                child: ElevatedButton.icon(
                                  onPressed: widget.doctorId != null
                                      ? () async {
                                          if (isFollowing) {
                                            await profile.unfollowUser(widget.doctorId!);
                                            _showSnackBar('Unfollowed ${widget.doctorName}');
                                          } else {
                                            await profile.followUser(
                                              targetUserId: widget.doctorId!,
                                              targetName: widget.doctorName,
                                              targetSpecialization: widget.specialization,
                                            );
                                            _showSnackBar('Following ${widget.doctorName}');
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
                                    isFollowing ? Icons.check_rounded : Icons.person_add_alt_1_rounded,
                                    size: 17,
                                  ),
                                  label: Text(
                                    isFollowing ? 'Following' : 'Follow',
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
                                          receiverName: widget.doctorName,
                                          receiverRole: widget.specialization,
                                          receiverHospital: widget.hospital,
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
                                      displayName: widget.doctorName,
                                      userId: widget.doctorId,
                                      role: '${widget.qualification} • ${widget.specialization}',
                                      phone: '+91 98765 43210',
                                      email: '${widget.doctorName.toLowerCase().replaceAll(' ', '.')}@medduty.in',
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
                                      _shareData,
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
                          const SizedBox(height: 18),

                          // ── Highlights Section ─────────────────────────────
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
                                  () => _openHighlight(context, 'Certificates'),
                                ),
                                _buildCircularHighlight(
                                  Icons.badge_outlined,
                                  'Medical\nLicense',
                                  '1',
                                  _cBlue,
                                  card,
                                  border,
                                  tx,
                                  () => _openHighlight(context, 'Medical License'),
                                ),
                                _buildCircularHighlight(
                                  Icons.emoji_events_outlined,
                                  'Awards',
                                  '8',
                                  _cAmber,
                                  card,
                                  border,
                                  tx,
                                  () => _openHighlight(context, 'Awards'),
                                ),
                                _buildCircularHighlight(
                                  Icons.science_outlined,
                                  'Research',
                                  '9',
                                  _cPurple,
                                  card,
                                  border,
                                  tx,
                                  () => _openHighlight(context, 'Research'),
                                ),
                                _buildCircularHighlight(
                                  Icons.local_hospital_outlined,
                                  'Hospital',
                                  '2',
                                  _cTeal,
                                  card,
                                  border,
                                  tx,
                                  () => _openHighlight(context, 'Hospital'),
                                ),
                                _buildCircularHighlight(
                                  Icons.photo_library_outlined,
                                  'Gallery',
                                  '24',
                                  _cGreen,
                                  card,
                                  border,
                                  tx,
                                  () => _openHighlight(context, 'Gallery'),
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

                // ── Sticky Tab Bar Navigation ────────────────────────────────
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
                  _buildPostsTab(community, card, border, tx, sub),
                  _buildExperienceTab(card, border, tx, sub),
                  _buildDutiesTab(card, border, tx, sub),
                  _buildReviewsTab(card, border, tx, sub),
                  _buildAboutTab(card, border, tx, sub),
                ],
              ),
            ),
    );
  }

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
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    final posts = community.authorPosts;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      children: [
        if (posts.isNotEmpty)
          ...posts.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProfessionalPostCard(
                post: p,
                isOwner: false,
              ),
            ),
          )
        else ...[
          _mockPostCard(card, border, tx, sub),
        ],
      ],
    );
  }

  Widget _mockPostCard(Color card, Color border, Color tx, Color sub) {
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
                          widget.doctorName,
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
                      '${widget.specialization} • ${widget.hospital}',
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
  Widget _buildExperienceTab(Color card, Color border, Color tx, Color sub) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        _sectionHeader('Work Experience', Icons.work_outline_rounded, tx),
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
                role: widget.specialization,
                hospital: widget.hospital,
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
  Widget _buildDutiesTab(Color card, Color border, Color tx, Color sub) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
      children: [
        _dutyItemCard(
          'ICU Night Shift Duty',
          widget.hospital,
          'Available, 08:00 PM – 08:00 AM',
          '₹ 8,500',
          'Open',
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
          'Weekends, 09:00 AM – 05:00 PM',
          '₹ 6,000',
          'On-Call',
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
  Widget _buildReviewsTab(Color card, Color border, Color tx, Color sub) {
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
  Widget _buildAboutTab(Color card, Color border, Color tx, Color sub) {
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
              Text(
                'Professional Summary',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: tx,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Board-certified ${widget.specialization.toLowerCase()} with extensive clinical experience at ${widget.hospital}. Active member of medical associations and dedicated to evidence-based healthcare delivery.',
                style: TextStyle(fontSize: 13.5, color: tx, height: 1.5),
              ),
              const Divider(height: 24),
              _aboutRow(Icons.badge_outlined, 'Registration Council', 'Delhi Medical Council (DMC)', tx, sub),
              const SizedBox(height: 10),
              _aboutRow(Icons.location_on_outlined, 'Primary Location', widget.location, tx, sub),
              const SizedBox(height: 10),
              _aboutRow(Icons.local_hospital_outlined, 'Current Affiliation', widget.hospital, tx, sub),
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
