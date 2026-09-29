// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../core/services/profile_link_service.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../models/share_payload.dart';
import '../../shared/widgets/report_bottom_sheet.dart';
import '../../shared/widgets/app_shell.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/community_provider.dart';
import '../profile/profile_screen.dart';
import '../notifications/notification_screen.dart';
import '../profile/public_doctor_profile_screen.dart';
import 'community_search_screen.dart';
import 'trending_topics_screen.dart';
import 'create_post_screen.dart';
import 'post_comments_screen.dart';

const _cTeal = Color(0xFF0F766E);
const _cTealLight = Color(0xFF14B8A6);
const _cTealBg = Color(0xFFECFDF5);
const _cBlue = Color(0xFF2563EB);
const _cBlueLight = Color(0xFF3B82F6);
const _cGreen = Color(0xFF16A34A);
const _cPurple = Color(0xFF7C3AED);
const _cAmber = Color(0xFFF59E0B);
const _cRed = Color(0xFFEF4444);
const _cOrange = Color(0xFFF97316);

String _communityPostId(Map<String, dynamic> post, int index) {
  final raw = post['id']?.toString();
  if (raw != null && raw.isNotEmpty) return raw;
  return ProfileLinkService.slugFromName('${post['name'] ?? 'post'}_$index');
}

void _reportCommunityPost(BuildContext context, Map<String, dynamic> post, int index) {
  showContentReportSheet(
    context,
    subjectLabel: 'this post',
    targetId: _communityPostId(post, index),
    targetName: post['name']?.toString(),
    reportType: 'community_post_report',
  );
}

const _specialtyCategories = [
  'All',
  'Cardiology',
  'Neurology',
  'Pediatrics',
  'Anesthesia',
  'Radiology',
  'General Medicine',
  'Emergency',
  'Surgery',
  'Dermatology',
  'Research',
  'Nursing',
  'Other',
];

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with TickerProviderStateMixin {
  String _selectedFilter = 'For You';
  String _selectedSpecialty = 'All';
  int _feedTabIndex = 0; // 0: All Posts, 1: Followed Posts
  String _sortBy = 'Most Recent';

  final ScrollController _scrollController = ScrollController();
  final List<bool> _likedPosts = List.filled(30, false);
  final List<bool> _savedPosts = List.filled(30, false);
  final List<int> _likeCounts = [
    128, 67, 245, 89, 42, 31, 78, 95, 12, 54, 88, 21, 43, 67, 11, 39, 102, 57, 23, 84,
    15, 29, 63, 44, 91, 110, 35, 72, 80, 50,
  ];
  final Map<int, int> _pollVotes = {};
  final Map<int, bool> _followingMap = {};
  final Set<int> _repostedPosts = {};
  final List<Map<String, dynamic>> _localPosts = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfessionalFeed());
  }

  void _loadProfessionalFeed() {
    final profile = context.read<ProfileProvider>();
    final auth = context.read<AuthProvider>();
    context.read<CommunityProvider>().loadNetworkProfessionalPosts(
          followingIds: profile.followingUserIds,
          viewerId: auth.user?.uid,
        );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty && parts[0].isNotEmpty) return parts[0][0].toUpperCase();
    return 'MD';
  }

  void _snack(String msg, {Color bg = _cTeal}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _onRefresh() async {
    _loadProfessionalFeed();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ];

    final auth = context.watch<AuthProvider>();
    final profile = context.watch<ProfileProvider>();
    final profileName = profile.name.isNotEmpty
        ? profile.name
        : (auth.userData?['name'] ?? 'Doctor');

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(isDark, bg, tx, sub, profileName, profile),
      body: LayoutBuilder(builder: (ctx, constraints) {
        if (constraints.maxWidth > 768) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFeed(isDark, bg, card, border, tx, sub, shadow, profileName),
              ),
              SizedBox(
                width: 330,
                child: _buildSidebar(isDark, card, border, tx, sub, shadow),
              ),
            ],
          );
        }
        return _buildFeed(isDark, bg, card, border, tx, sub, shadow, profileName);
      }),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 50),
        child: FloatingActionButton(
          heroTag: 'community_fab_btn',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            );
          },
          backgroundColor: _cTeal,
          elevation: 4,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ─── 1. COMPACT APP BAR ───────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(
    bool isDark,
    Color bg,
    Color tx,
    Color sub,
    String profileName,
    ProfileProvider profile,
  ) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Community',
            style: TextStyle(
              color: tx,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            'Connect, share & grow with healthcare professionals',
            style: TextStyle(
              color: sub,
              fontSize: 11.5,
              fontWeight: FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: tx, size: 22),
          tooltip: 'Search Community',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CommunitySearchScreen()),
          ),
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: Icon(Icons.tune_rounded, color: tx, size: 21),
          tooltip: 'Filter Options',
          onPressed: _showFilterSheet,
          visualDensity: VisualDensity.compact,
        ),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications_outlined, color: tx, size: 23),
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 3.5, vertical: 1),
                    decoration: BoxDecoration(
                      color: _cRed,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: bg, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
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
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: _cTeal,
                  backgroundImage: profile.profilePic.isNotEmpty
                      ? NetworkImage(profile.profilePic) as ImageProvider
                      : (!kIsWeb && profile.localProfilePicPath != null
                          ? FileImage(File(profile.localProfilePicPath!)) as ImageProvider
                          : null),
                  child: (profile.profilePic.isEmpty &&
                          (kIsWeb || profile.localProfilePicPath == null))
                      ? Text(
                          _initials(profileName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
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
        ),
      ],
    );
  }

  // ─── 2. MAIN FEED & COMPONENT COMPOSITION ─────────────────────────────────
  Widget _buildFeed(
    bool isDark,
    Color bg,
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
    String profileName,
  ) {
    final community = context.watch<CommunityProvider>();
    final networkLivePosts = community.networkProfessionalPosts;

    // Rich sample clinical posts inspired directly by LinkedIn/Instagram medical posts
    final sampleMedicalPosts = [
      {
        'id': 'post_neha_verma_1',
        'name': 'Dr. Neha Verma',
        'verified': true,
        'role': 'Dermatologist',
        'hospital': 'Max Hospital Delhi',
        'time': '2h ago',
        'visibility': 'Public',
        'type': 'workshop_multi_image',
        'specialty': 'Dermatology',
        'content':
            'Just wrapped up an advanced clinical dermatology workshop on targeted laser therapies and skin rejuvenation protocols. Exciting advances for patient care!\n#Dermatology #ClinicalLearning #MedDutyCommunity',
        'images': [
          'https://images.unsplash.com/photo-1576091160550-2173dba999ef?w=600&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1512290900672-1f41d087b3cf?w=600&auto=format&fit=crop&q=80',
          'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=600&auto=format&fit=crop&q=80',
        ],
        'likes': _likeCounts[0],
        'comments': 24,
        'reposts': 16,
      },
      {
        'id': 'post_arjun_sharma_1',
        'name': 'Dr. Arjun Sharma',
        'verified': true,
        'role': 'Diabetologist',
        'hospital': 'Apollo Hospital Delhi',
        'time': '5h ago',
        'visibility': 'Public',
        'type': 'poll',
        'specialty': 'General Medicine',
        'content':
            'How do you effectively manage cognitive fatigue during extended night duty hours?',
        'pollOptions': [
          'Scheduled Hydration',
          'Nutrient-Dense Snacks',
          '10-Min Micro-Breaks',
          'Caffeine Timing',
        ],
        'pollPercents': [45, 30, 15, 10],
        'pollColors': [_cTeal, _cGreen, _cBlue, _cAmber],
        'votes': 245,
        'likes': _likeCounts[1],
        'comments': 32,
        'reposts': 8,
      },
      {
        'id': 'post_priya_nair_1',
        'name': 'Dr. Priya Nair',
        'verified': true,
        'role': 'Pediatrician',
        'hospital': 'Fortis Hospital Bangalore',
        'time': '1d ago',
        'visibility': 'Public',
        'type': 'achievement',
        'specialty': 'Pediatrics',
        'content':
            'Honoured to receive the Young Pediatrician Excellence Award 2024! Grateful to our entire clinical team for their dedication to newborn and child healthcare. 🏆\n#Pediatrics #ExcellenceInCare',
        'award': 'Young Pediatrician Excellence Award 2024',
        'likes': _likeCounts[2],
        'comments': 67,
        'reposts': 34,
      },
      {
        'id': 'post_ramesh_iyer_1',
        'name': 'Dr. Ramesh Iyer',
        'verified': true,
        'role': 'Cardiologist',
        'hospital': 'Apollo Heart Institute',
        'time': '3h ago',
        'visibility': 'Public',
        'type': 'experience',
        'specialty': 'Cardiology',
        'content':
            'Key clinical takeaways from the recent National Cardiology Symposium: Early lipid lowering post-ACS and new ambulatory monitoring protocols. Significant reduction in 30-day readmissions observed in our tertiary unit.\n#Cardiology #ClinicalCardiology',
        'experienceTitle': 'Lead Faculty — ACS & Lipid Management Protocol',
        'experiencePlace': 'Apollo Heart Institute',
        'experienceDuration': 'Aug 2026 — Present',
        'likes': _likeCounts[3],
        'comments': 18,
        'reposts': 11,
      },
      {
        'id': 'post_sita_krishnan_1',
        'name': 'Dr. Sita Krishnan',
        'verified': true,
        'role': 'Neurologist',
        'hospital': 'NIMHANS',
        'time': '6h ago',
        'visibility': 'Public',
        'type': 'text_image',
        'specialty': 'Neurology',
        'content':
            'Recent updates in acute stroke pathways — mechanical thrombectomy within the extended time window is showing significantly improved functional recovery in our center.\n#Neurology #StrokeManagement',
        'images': [
          'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=600&auto=format&fit=crop&q=80',
        ],
        'likes': _likeCounts[4],
        'comments': 9,
        'reposts': 5,
      },
    ];

    // Combine local created posts with sample feed
    final combinedMock = [..._localPosts, ...sampleMedicalPosts];

    // Filter by Specialty and segmented filter
    List<Map<String, dynamic>> filteredList = combinedMock.where((p) {
      if (_selectedFilter == 'Saved') {
        final index = combinedMock.indexOf(p);
        return index < _savedPosts.length && _savedPosts[index];
      }
      if (_selectedFilter == 'Following') {
        final index = combinedMock.indexOf(p);
        return _followingMap[index] == true;
      }
      if (_selectedSpecialty != 'All') {
        final s = p['specialty'] as String? ?? '';
        return s.toLowerCase().contains(_selectedSpecialty.toLowerCase());
      }
      return true;
    }).toList();

    return RefreshIndicator(
      color: _cTeal,
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            // 1. Horizontal Content Filter Row
            _buildContentFilterRow(isDark, card, border, tx, sub),
            const SizedBox(height: 12),
            // 2. Professional Post Composer
            _buildProfessionalComposer(card, border, shadow, tx, sub, profileName, isDark),
            const SizedBox(height: 12),
            // 3. Community Quick Actions
            _buildQuickActionsRow(card, border, shadow, tx, sub, profileName),
            const SizedBox(height: 12),
            // 4. Trending in Healthcare & Community Guidelines Row
            _buildTrendingAndGuidelinesSection(card, border, shadow, tx, sub),
            const SizedBox(height: 14),
            // 5. Feed Header Tabs & Sorting Row
            _buildFeedHeaderTabs(isDark, card, border, tx, sub),
            // 6. Active Filter Badge if custom specialty active
            if (_selectedSpecialty != 'All')
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _cTeal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _cTeal.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.filter_alt_rounded, color: _cTeal, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Filtered by: $_selectedSpecialty',
                        style: const TextStyle(
                          color: _cTeal,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() => _selectedSpecialty = 'All'),
                        child: const Icon(Icons.close_rounded, color: _cTeal, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
            // 7. Live Firebase Posts (if available)
            if (networkLivePosts.isNotEmpty && _feedTabIndex == 0)
              ...networkLivePosts.map(
                (post) => _buildFirebaseLivePostCard(
                  post,
                  tx,
                  sub,
                  card,
                  border,
                  shadow,
                  isDark,
                ),
              ),
            // 8. Feed Cards
            if (filteredList.isEmpty && networkLivePosts.isEmpty)
              _buildEmptyFeedState(tx, sub, card, border)
            else
              ...List.generate(
                filteredList.length,
                (i) => _buildPostCard(
                  filteredList[i],
                  i,
                  tx,
                  sub,
                  card,
                  border,
                  shadow,
                  isDark,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 2. HORIZONTAL CONTENT FILTERS (Segmented + Specialties) ──────────────
  Widget _buildContentFilterRow(
    bool isDark,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    final primaryFilters = ['For You', 'Following', 'My Specialty', 'Saved'];
    final specialtiesList = [
      'Cardiology',
      'Neurology',
      'Pediatrics',
      'Anesthesia',
      'Radiology',
      'Surgery',
      'Dermatology',
      'Emergency',
      'General Medicine',
    ];

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          // Primary segmented filter pills
          ...primaryFilters.map((f) {
            final isSelected = _selectedFilter == f && _selectedSpecialty == 'All';
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedFilter = f;
                    _selectedSpecialty = 'All';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _cTeal : (isDark ? card : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _cTeal : border,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      f,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : sub,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // Vertical Separator Divider
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            width: 1,
            color: border,
          ),
          const SizedBox(width: 4),
          // Specialty chips
          ...specialtiesList.map((spec) {
            final isSelected = _selectedSpecialty == spec;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedSpecialty = isSelected ? 'All' : spec;
                    if (isSelected) _selectedFilter = 'For You';
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? _cTeal : (isDark ? card : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? _cTeal : border,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      spec,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : sub,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          // Trailing category grid icon
          GestureDetector(
            onTap: _showSpecialtyCategorySheet,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? card : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Icon(Icons.grid_view_rounded, size: 16, color: sub),
            ),
          ),
        ],
      ),
    );
  }

  // ─── 3. PROFESSIONAL COMPOSER (LinkedIn-Style) ────────────────────────────
  Widget _buildProfessionalComposer(
    Color card,
    Color border,
    List<BoxShadow> shadow,
    Color tx,
    Color sub,
    String profileName,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor: _cTeal,
                child: Text(
                  _initials(profileName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: border.withValues(alpha: 0.8)),
                    ),
                    child: Text(
                      'Share a clinical insight, experience, or update...',
                      style: TextStyle(color: sub, fontSize: 12.5),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: border, height: 1),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _composerPill(
                  Icons.edit_note_rounded,
                  'Post',
                  _cTeal,
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreatePostScreen()),
                  ),
                  isDark,
                ),
                const SizedBox(width: 8),
                _composerPill(
                  Icons.work_outline_rounded,
                  'Experience',
                  _cBlue,
                  () => _showProfessionalExperienceSheet(profileName),
                  isDark,
                ),
                const SizedBox(width: 8),
                _composerPill(
                  Icons.article_outlined,
                  'Article',
                  _cOrange,
                  () => _showArticleSheet(profileName),
                  isDark,
                ),
                const SizedBox(width: 8),
                _composerPill(
                  Icons.emoji_events_outlined,
                  'Achievement',
                  _cPurple,
                  () => _showProfessionalExperienceSheet(profileName),
                  isDark,
                ),
                const SizedBox(width: 8),
                _composerPill(
                  Icons.photo_library_outlined,
                  'Media',
                  _cGreen,
                  () => _showPhotoPostSheet(profileName),
                  isDark,
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => _showMoreComposerOptionsSheet(profileName),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: border),
                    ),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: sub,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _composerPill(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 4. COMMUNITY QUICK ACTIONS ROW ───────────────────────────────────────
  Widget _buildQuickActionsRow(
    Color card,
    Color border,
    List<BoxShadow> shadow,
    Color tx,
    Color sub,
    String profileName,
  ) {
    final actions = [
      {
        'icon': Icons.help_outline_rounded,
        'label': 'Ask a Question',
        'color': _cGreen,
        'onTap': () => _showAskQuestionSheet(profileName),
      },
      {
        'icon': Icons.medical_information_outlined,
        'label': 'Case Discussion',
        'color': _cBlue,
        'onTap': () => _showCaseDiscussionSheet(profileName),
      },
      {
        'icon': Icons.poll_outlined,
        'label': 'Poll',
        'color': _cOrange,
        'onTap': () => _showPollSheet(profileName),
      },
      {
        'icon': Icons.event_note_rounded,
        'label': 'Events',
        'color': _cPurple,
        'onTap': _showEventsSheet,
      },
      {
        'icon': Icons.work_outline_rounded,
        'label': 'Job Board',
        'color': _cBlue,
        'onTap': () {
          AppShell.of(context).switchTab(1);
          _snack('Navigated to Duties & Jobs Board');
        },
      },
      {
        'icon': Icons.groups_outlined,
        'label': 'Mentorship',
        'color': _cGreen,
        'onTap': _showMentorshipSheet,
      },
      {
        'icon': Icons.more_horiz_rounded,
        'label': 'More',
        'color': sub,
        'onTap': _showMoreQuickActionsSheet,
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: actions.map((item) {
            final icon = item['icon'] as IconData;
            final label = item['label'] as String;
            final color = item['color'] as Color;
            final onTap = item['onTap'] as VoidCallback;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onTap();
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(icon, color: color, size: 21),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 76,
                      child: Text(
                        label,
                        style: TextStyle(
                          color: tx,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ─── 5. TRENDING & GUIDELINES DUAL CARDS ───────────────────────────────────
  Widget _buildTrendingAndGuidelinesSection(
    Color card,
    Color border,
    List<BoxShadow> shadow,
    Color tx,
    Color sub,
  ) {
    final trends = [
      {'title': '#CardiologyUpdates', 'posts': '2.4K discussions'},
      {'title': '#EmergencyMedicine', 'posts': '1.8K discussions'},
      {'title': '#ClinicalCaseStudies', 'posts': '3.1K discussions'},
      {'title': '#MedicalResearch', 'posts': '2.7K discussions'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (ctx, constraints) {
          final isCompact = constraints.maxWidth < 600;

          final trendingCard = Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadow,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.trending_up_rounded, color: _cTeal, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Trending in Healthcare',
                      style: TextStyle(
                        color: tx,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TrendingTopicsScreen()),
                      ),
                      child: const Text(
                        'View all',
                        style: TextStyle(
                          color: _cTeal,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 2.7,
                  children: trends.map((t) {
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _HashtagFeedScreen(category: t['title']!),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _cTeal.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _cTeal.withValues(alpha: 0.15)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_up_rounded, color: _cGreen, size: 13),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    t['title']!,
                                    style: const TextStyle(
                                      color: _cTeal,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    t['posts']!,
                                    style: TextStyle(color: sub, fontSize: 9.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          );

          final guidelinesCard = Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadow,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_user_outlined, color: _cTeal, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Community Guidelines',
                      style: TextStyle(
                        color: tx,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's keep our community professional, respectful & trustworthy.",
                  style: TextStyle(color: sub, fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showGuidelinesSheet,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _cTeal.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _cTeal.withValues(alpha: 0.2)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Guidelines',
                          style: TextStyle(
                            color: _cTeal,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded, color: _cTeal, size: 13),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );

          if (isCompact) {
            return Column(
              children: [
                trendingCard,
                const SizedBox(height: 10),
                guidelinesCard,
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: trendingCard),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: guidelinesCard),
            ],
          );
        },
      ),
    );
  }

  // ─── 6. FEED HEADER TABS & SORTING ────────────────────────────────────────
  Widget _buildFeedHeaderTabs(
    bool isDark,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _feedTabIndex = 0);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'All Posts',
                  style: TextStyle(
                    color: _feedTabIndex == 0 ? _cTeal : sub,
                    fontSize: 13.5,
                    fontWeight: _feedTabIndex == 0 ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2.5,
                  width: 32,
                  decoration: BoxDecoration(
                    color: _feedTabIndex == 0 ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _feedTabIndex = 1);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Followed Posts',
                  style: TextStyle(
                    color: _feedTabIndex == 1 ? _cTeal : sub,
                    fontSize: 13.5,
                    fontWeight: _feedTabIndex == 1 ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  height: 2.5,
                  width: 38,
                  decoration: BoxDecoration(
                    color: _feedTabIndex == 1 ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Sort Dropdown
          PopupMenuButton<String>(
            initialValue: _sortBy,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            onSelected: (val) {
              setState(() => _sortBy = val);
              _snack('Sorted by $val');
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'Most Recent', child: Text('Most Recent')),
              const PopupMenuItem(value: 'Most Discussed', child: Text('Most Discussed')),
              const PopupMenuItem(value: 'Trending', child: Text('Trending')),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _sortBy,
                  style: TextStyle(
                    color: sub,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.keyboard_arrow_down_rounded, color: sub, size: 17),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── 7. PROFESSIONAL POST CARD (LinkedIn/Instagram Quality) ───────────────
  Widget _buildPostCard(
    Map<String, dynamic> post,
    int index,
    Color tx,
    Color sub,
    Color card,
    Color border,
    List<BoxShadow> shadow,
    bool isDark,
  ) {
    final name = post['name'] as String;
    final verified = post['verified'] as bool? ?? false;
    final role = post['role'] as String;
    final hospital = post['hospital'] as String? ?? '';
    final time = post['time'] as String;
    final visibility = post['visibility'] as String? ?? 'Public';
    final type = post['type'] as String;
    final content = post['content'] as String;
    final likes = post['likes'] as int;
    final comments = post['comments'] as int? ?? 0;
    final reposts = post['reposts'] as int? ?? 0;
    final isSaved = index < _savedPosts.length && _savedPosts[index];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author Header
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicDoctorProfileScreen(
                        doctorName: name,
                        qualification: 'MBBS, MD',
                        specialization: role,
                        hospital: hospital,
                        location: 'Delhi, India',
                        avatarInitials: _initials(name),
                        avatarColor: _cTeal,
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _cTeal,
                    child: Text(
                      _initials(name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PublicDoctorProfileScreen(
                                    doctorName: name,
                                    qualification: 'MBBS, MD',
                                    specialization: role,
                                    hospital: hospital,
                                    location: 'Delhi, India',
                                    avatarInitials: _initials(name),
                                    avatarColor: _cTeal,
                                  ),
                                ),
                              ),
                              child: Text(
                                name,
                                style: TextStyle(
                                  color: tx,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          if (verified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: _cBlue,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      if (hospital.isNotEmpty)
                        Text(
                          '$role • $hospital',
                          style: TextStyle(color: sub, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Row(
                        children: [
                          Text(time, style: TextStyle(color: sub, fontSize: 10.5)),
                          const SizedBox(width: 4),
                          Icon(
                            visibility == 'Public'
                                ? Icons.public_rounded
                                : (visibility == 'Followers'
                                    ? Icons.people_rounded
                                    : Icons.lock_rounded),
                            color: sub,
                            size: 11,
                          ),
                          const SizedBox(width: 3),
                          Text(visibility, style: TextStyle(color: sub, fontSize: 10.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? _cTeal : sub,
                    size: 20,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    if (index < _savedPosts.length) {
                      setState(() => _savedPosts[index] = !isSaved);
                      _snack(isSaved ? 'Removed from saved' : 'Post saved');
                    }
                  },
                  visualDensity: VisualDensity.compact,
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: sub, size: 19),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'save',
                      child: Row(
                        children: [
                          Icon(Icons.bookmark_outline_rounded, size: 18, color: sub),
                          const SizedBox(width: 8),
                          Text(isSaved ? 'Remove from Saved' : 'Save Post'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'share',
                      child: Row(
                        children: [
                          Icon(Icons.share_rounded, size: 18, color: sub),
                          const SizedBox(width: 8),
                          const Text('Share Post'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'hide',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_off_outlined, size: 18, color: sub),
                          const SizedBox(width: 8),
                          const Text('Hide Post'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, size: 18, color: _cRed),
                          const SizedBox(width: 8),
                          const Text('Report'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'unfollow',
                      child: Row(
                        children: [
                          Icon(Icons.person_remove_outlined, size: 18, color: sub),
                          const SizedBox(width: 8),
                          const Text('Unfollow'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 18, color: _cRed),
                          const SizedBox(width: 8),
                          const Text('Delete Post', style: TextStyle(color: _cRed)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'save') {
                      if (index < _savedPosts.length) {
                        setState(() => _savedPosts[index] = !_savedPosts[index]);
                      }
                      _snack(_savedPosts[index] ? 'Post saved' : 'Removed from saved');
                    } else if (v == 'share') {
                      _openShareSheet(post, index);
                    } else if (v == 'report') {
                      _reportPost(post, index);
                    } else if (v == 'hide') {
                      _snack('Post hidden from your feed');
                    } else if (v == 'unfollow') {
                      _snack('Unfollowed successfully');
                    } else if (v == 'delete') {
                      _showDeleteConfirmDialog(post, index);
                    }
                  },
                ),
              ],
            ),
          ),
          // Post Content with Highlighted Hashtags
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: _buildRichHashtagText(content, tx),
          ),
          // Specialized Media / Experience / Poll / Award layouts
          if (type == 'workshop_multi_image' || (post['images'] is List && (post['images'] as List).length >= 3))
            _buildThreeImageCollage(
              (post['images'] as List).map((e) => e.toString()).toList(),
              isDark,
            )
          else if (type == 'text_image' && post['images'] is List)
            _buildSingleOrDoubleImage(
              (post['images'] as List).map((e) => e.toString()).toList(),
              isDark,
            )
          else if (type == 'poll')
            _buildPollContent(post, tx, sub, index)
          else if (type == 'achievement')
            _buildAchievement(post, tx, border)
          else if (type == 'experience')
            _buildExperienceCard(post, tx, sub, border),
          if (post['imagePath'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildPostImage(post['imagePath'] as String),
              ),
            ),
          // Interaction Action Bar
          _buildActionBar(index, likes, comments, reposts, tx, sub, border, post),
        ],
      ),
    );
  }

  // ─── 8. LIVE FIREBASE POST CARD ───────────────────────────────────────────
  Widget _buildFirebaseLivePostCard(
    dynamic post,
    Color tx,
    Color sub,
    Color card,
    Color border,
    List<BoxShadow> shadow,
    bool isDark,
  ) {
    final community = context.watch<CommunityProvider>();
    final isLiked = community.isPostLiked(post.id);
    final isSaved = community.isPostSaved(post.id);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicDoctorProfileScreen(
                        doctorName: post.authorName,
                        qualification: 'MBBS, MD',
                        specialization: post.authorSpecialty ?? 'Specialist',
                        hospital: post.authorHospital ?? '',
                        location: 'Delhi, India',
                        avatarInitials: _initials(post.authorName),
                        avatarColor: _cTeal,
                      ),
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: _cTeal,
                    backgroundImage: (post.authorAvatar != null && post.authorAvatar!.isNotEmpty)
                        ? NetworkImage(post.authorAvatar!) as ImageProvider
                        : null,
                    child: (post.authorAvatar == null || post.authorAvatar!.isEmpty)
                        ? Text(
                            _initials(post.authorName),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              post.authorName,
                              style: TextStyle(
                                color: tx,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.authorVerified) ...[
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.verified_rounded,
                              color: _cBlue,
                              size: 14,
                            ),
                          ],
                        ],
                      ),
                      if (post.authorHospital != null && post.authorHospital!.isNotEmpty)
                        Text(
                          '${post.authorSpecialty ?? "Doctor"} • ${post.authorHospital}',
                          style: TextStyle(color: sub, fontSize: 11.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      Row(
                        children: [
                          Text('Recent', style: TextStyle(color: sub, fontSize: 10.5)),
                          const SizedBox(width: 4),
                          Icon(Icons.public_rounded, color: sub, size: 11),
                          const SizedBox(width: 3),
                          Text('Public', style: TextStyle(color: sub, fontSize: 10.5)),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                    color: isSaved ? _cTeal : sub,
                    size: 20,
                  ),
                  onPressed: () => community.toggleSavePost(post.id, 'Post', post.content),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          if (post.content.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: _buildRichHashtagText(post.content, tx),
            ),
          if (post.imageUrls.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.imageUrls.length == 1
                    ? Image.network(
                        post.imageUrls.first,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _mediaPlaceholder(sub),
                      )
                    : SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post.imageUrls[i],
                              width: 140,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          // Action Bar for live Firebase post
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
            child: Column(
              children: [
                Divider(color: border, height: 1),
                const SizedBox(height: 6),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        community.toggleLikePost(post.id);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isLiked ? _cRed : sub,
                            size: 19,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likedBy.length}',
                            style: TextStyle(
                              color: isLiked ? _cRed : sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PostCommentsScreen(post: post),
                        ),
                      ),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.chat_bubble_outline_rounded, color: sub, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${post.commentsCount}',
                            style: TextStyle(
                              color: sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        community.incrementRepostCount(post.id);
                        _snack('Reposted to your network', bg: _cGreen);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.repeat_rounded, color: sub, size: 19),
                          const SizedBox(width: 4),
                          Text(
                            '${post.repostCount}',
                            style: TextStyle(
                              color: sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        MedDutyShareService.show(
                          context,
                          SharePayload.communityPost(
                            postId: post.id,
                            authorName: post.authorName,
                            snippet: post.content.length > 120
                                ? '${post.content.substring(0, 120)}...'
                                : post.content,
                          ),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(Icons.share_rounded, color: sub, size: 17),
                          const SizedBox(width: 4),
                          Text(
                            'Share',
                            style: TextStyle(
                              color: sub,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
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

  // ─── 9. MEDIA & LAYOUT HELPERS ─────────────────────────────────────────────
  Widget _buildThreeImageCollage(List<String> images, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: SizedBox(
        height: 150,
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  images[0],
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (_, _, _) => _mediaPlaceholder(Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  images.length > 1 ? images[1] : images[0],
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (_, _, _) => _mediaPlaceholder(Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              flex: 4,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  images.length > 2 ? images[2] : images[0],
                  fit: BoxFit.cover,
                  height: 150,
                  errorBuilder: (_, _, _) => _mediaPlaceholder(Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleOrDoubleImage(List<String> images, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          images[0],
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _mediaPlaceholder(Colors.grey),
        ),
      ),
    );
  }

  Widget _mediaPlaceholder(Color color) {
    return Container(
      height: 140,
      color: color.withValues(alpha: 0.1),
      child: Center(
        child: Icon(Icons.image_outlined, color: color, size: 32),
      ),
    );
  }

  Widget _buildRichHashtagText(String text, Color tx) {
    final spans = <TextSpan>[];
    final words = text.split(RegExp(r'(?<=\s)|(?=\s)'));

    for (final word in words) {
      if (word.startsWith('#')) {
        spans.add(
          TextSpan(
            text: word,
            style: const TextStyle(
              color: _cTeal,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: word,
            style: TextStyle(
              color: tx,
              fontSize: 13.5,
              height: 1.45,
            ),
          ),
        );
      }
    }

    return RichText(text: TextSpan(children: spans));
  }

  // ─── 10. POLL POST CONTENT ────────────────────────────────────────────────
  Widget _buildPollContent(
    Map<String, dynamic> post,
    Color tx,
    Color sub,
    int postIndex,
  ) {
    final options = post['pollOptions'] as List<String>;
    final percents = post['pollPercents'] as List<int>;
    final colors = post['pollColors'] as List<Color>;
    final votes = post['votes'] as int;
    final voted = _pollVotes[postIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(
            options.length,
            (i) => GestureDetector(
              onTap: () {
                if (voted == null) {
                  HapticFeedback.lightImpact();
                  setState(() => _pollVotes[postIndex] = i);
                  _snack('Voted for "${options[i]}"');
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: voted == i
                      ? colors[i].withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: voted == i
                        ? colors[i].withValues(alpha: 0.4)
                        : colors[i].withValues(alpha: 0.18),
                    width: voted == i ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            if (voted == i)
                              Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: colors[i],
                                  size: 15,
                                ),
                              ),
                            Text(
                              options[i],
                              style: TextStyle(
                                color: voted == i ? colors[i] : tx,
                                fontSize: 12.5,
                                fontWeight: voted == i ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${percents[i]}%',
                          style: TextStyle(
                            color: colors[i],
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percents[i] / 100,
                        color: colors[i],
                        backgroundColor: colors[i].withValues(alpha: 0.12),
                        minHeight: 5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Text(
            '$votes votes • ${voted == null ? "Tap an option to vote" : "Poll submitted"}',
            style: TextStyle(color: sub, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ─── 11. ACHIEVEMENT & EXPERIENCE BANNER ──────────────────────────────────
  Widget _buildAchievement(Map<String, dynamic> post, Color tx, Color border) {
    final award = post['award'] as String;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cAmber.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cAmber.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cAmber.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.emoji_events_rounded, color: _cAmber, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Special Recognition',
                    style: TextStyle(
                      color: _cAmber,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    award,
                    style: TextStyle(
                      color: tx,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
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

  Widget _buildExperienceCard(
    Map<String, dynamic> post,
    Color tx,
    Color sub,
    Color border,
  ) {
    final title = post['experienceTitle'] as String? ?? 'Clinical Duty';
    final place = post['experiencePlace'] as String? ?? 'Hospital Department';
    final duration = post['experienceDuration'] as String? ?? '2026';

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _cBlue.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _cBlue.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _cBlue.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.business_center_rounded, color: _cBlue, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: tx,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$place • $duration',
                    style: TextStyle(color: sub, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 12. ACTION BAR ───────────────────────────────────────────────────────
  Widget _buildActionBar(
    int index,
    int likes,
    int comments,
    int reposts,
    Color tx,
    Color sub,
    Color border,
    Map<String, dynamic> post,
  ) {
    final isLiked = index < _likedPosts.length && _likedPosts[index];
    final curCount = index < _likeCounts.length ? _likeCounts[index] : likes;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
      child: Column(
        children: [
          Divider(color: border, height: 1),
          const SizedBox(height: 6),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  if (index < _likedPosts.length) {
                    setState(() {
                      _likedPosts[index] = !isLiked;
                      if (index < _likeCounts.length) {
                        _likeCounts[index] = isLiked ? curCount - 1 : curCount + 1;
                      }
                    });
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      child: Icon(
                        isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isLiked ? _cRed : sub,
                        size: 19,
                        key: ValueKey(isLiked),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$curCount',
                      style: TextStyle(
                        color: isLiked ? _cRed : sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showCommentsSheet(post, index),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded, color: sub, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$comments',
                      style: TextStyle(
                        color: sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _showRepostSheet(post, index),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.repeat_rounded, color: sub, size: 19),
                    const SizedBox(width: 4),
                    Text(
                      '$reposts',
                      style: TextStyle(
                        color: sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _openShareSheet(post, index),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Icon(Icons.share_rounded, color: sub, size: 17),
                    const SizedBox(width: 4),
                    Text(
                      'Share',
                      style: TextStyle(
                        color: sub,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 13. EMPTY STATE ──────────────────────────────────────────────────────
  Widget _buildEmptyFeedState(Color tx, Color sub, Color card, Color border) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _cTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.people_outline_rounded, color: _cTeal, size: 32),
            ),
            const SizedBox(height: 14),
            Text(
              'Your community is just getting started',
              style: TextStyle(
                color: tx,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Follow healthcare professionals and specialties to see relevant updates here.',
              style: TextStyle(color: sub, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CommunitySearchScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _cTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                elevation: 0,
              ),
              child: const Text('Discover Professionals', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 14. SIDEBAR FOR TABLET/DESKTOP VIEWPORTS ──────────────────────────────
  Widget _buildSidebar(
    bool isDark,
    Color card,
    Color border,
    Color tx,
    Color sub,
    List<BoxShadow> shadow,
  ) =>
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSidebarTrending(card, border, shadow, tx, sub),
            const SizedBox(height: 16),
            _buildSuggestedConnections(card, border, shadow, tx, sub),
            const SizedBox(height: 24),
          ],
        ),
      );

  Widget _buildSidebarTrending(
    Color card,
    Color border,
    List<BoxShadow> shadow,
    Color tx,
    Color sub,
  ) {
    final items = [
      {'title': '#PostCOVID Complications', 'posts': '2.4K discussions'},
      {'title': 'Burnout in Healthcare', 'posts': '1.8K discussions'},
      {'title': 'AI in Diagnostics', 'posts': '3.1K discussions'},
      {'title': 'Clinical Guidelines 2024', 'posts': '1.2K discussions'},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Trending Discussions',
                style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TrendingTopicsScreen()),
                ),
                child: const Text(
                  'See all',
                  style: TextStyle(color: _cTeal, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(
            items.length,
            (i) => GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => _HashtagFeedScreen(category: items[i]['title']!),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _cTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: _cTeal,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items[i]['title']!,
                            style: TextStyle(
                              color: tx,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            items[i]['posts']!,
                            style: TextStyle(color: sub, fontSize: 10.5),
                          ),
                        ],
                      ),
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

  Widget _buildSuggestedConnections(
    Color card,
    Color border,
    List<BoxShadow> shadow,
    Color tx,
    Color sub,
  ) {
    final doctors = [
      {'name': 'Dr. Rohan Mehta', 'role': 'Cardiologist', 'hospital': 'Max Hospital'},
      {'name': 'Dr. Ayesha Khan', 'role': 'Anesthesiologist', 'hospital': 'AIIMS'},
      {'name': 'Dr. Karan Patel', 'role': 'Orthopaedic', 'hospital': 'Fortis Mumbai'},
    ];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: shadow,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Suggested Connections',
                style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _snack('Showing suggested connections'),
                child: const Text(
                  'See all',
                  style: TextStyle(color: _cTeal, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...doctors.asMap().entries.map((entry) {
            final i = entry.key;
            final d = entry.value;
            final isFollowing = _followingMap[i] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: _cTeal.withValues(alpha: 0.15),
                    child: Text(
                      _initials(d['name']!),
                      style: const TextStyle(
                        color: _cTeal,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          d['name']!,
                          style: TextStyle(
                            color: tx,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${d["role"]} • ${d["hospital"]}',
                          style: TextStyle(color: sub, fontSize: 10.5),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton(
                    onPressed: () {
                      setState(() => _followingMap[i] = !isFollowing);
                      _snack(isFollowing ? 'Unfollowed ${d["name"]}' : 'Following ${d["name"]}');
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isFollowing ? sub : _cTeal,
                      side: BorderSide(color: isFollowing ? sub : _cTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      visualDensity: VisualDensity.compact,
                    ),
                    child: Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─── 15. MODAL SHEETS & WORKFLOW DIALOGS ───────────────────────────────────
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        String sortBy = _sortBy;
        final List<String> specs = [];
        return StatefulBuilder(builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
          return DraggableScrollableSheet(
            initialChildSize: 0.65,
            maxChildSize: 0.9,
            minChildSize: 0.4,
            builder: (_, sc) => Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 4),
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sub.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          'Filter Community',
                          style: TextStyle(
                            color: tx,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: sub),
                          onPressed: () => Navigator.pop(ctx2),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: border, height: 1),
                  Expanded(
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.all(20),
                      children: [
                        Text(
                          'Specialization',
                          style: TextStyle(
                            color: tx,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _specialtyCategories.where((s) => s != 'All').map((s) {
                            final sel = specs.contains(s);
                            return FilterChip(
                              label: Text(s),
                              selected: sel,
                              selectedColor: _cTeal.withValues(alpha: 0.15),
                              checkmarkColor: _cTeal,
                              labelStyle: TextStyle(
                                color: sel ? _cTeal : sub,
                                fontSize: 12,
                              ),
                              side: BorderSide(color: sel ? _cTeal : border),
                              onSelected: (v) => ss(() {
                                v ? specs.add(s) : specs.remove(s);
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Sort By',
                          style: TextStyle(
                            color: tx,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ['Most Recent', 'Most Discussed', 'Trending'].map((s) {
                            final sel = sortBy == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: sel,
                              selectedColor: _cTeal.withValues(alpha: 0.15),
                              labelStyle: TextStyle(
                                color: sel ? _cTeal : sub,
                                fontSize: 12,
                              ),
                              side: BorderSide(color: sel ? _cTeal : border),
                              onSelected: (_) => ss(() => sortBy = s),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => ss(() {
                              specs.clear();
                              sortBy = 'Most Recent';
                            }),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: sub,
                              side: BorderSide(color: border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Reset'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx2);
                              setState(() {
                                _sortBy = sortBy;
                                if (specs.isNotEmpty) {
                                  _selectedSpecialty = specs.first;
                                }
                              });
                              _snack('Filters applied');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _cTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              elevation: 0,
                            ),
                            child: const Text('Apply Filters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _showSpecialtyCategorySheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Medical Specialties',
                style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _specialtyCategories.map((s) {
                  final isSelected = _selectedSpecialty == s;
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _selectedSpecialty = s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? _cTeal : _cTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: isSelected ? Colors.white : _cTeal,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showGuidelinesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.verified_user_rounded, color: _cTeal, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'MedDuty Community Guidelines',
                    style: TextStyle(color: tx, fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _guidelineRow(
                Icons.privacy_tip_outlined,
                'Patient Privacy & Confidentiality',
                'Never post patient names, record numbers, contact details, or identifiable face photographs without documented institutional consent.',
                tx,
                sub,
              ),
              _guidelineRow(
                Icons.handshake_outlined,
                'Professional & Respectful Peer Discourse',
                'Engage in constructive clinical debates. Respect differing medical viewpoints and maintain high professional decorum.',
                tx,
                sub,
              ),
              _guidelineRow(
                Icons.verified_outlined,
                'Evidence-Based Medical Information',
                'Cite reputable clinical trials, guidelines, or peer-reviewed literature whenever sharing diagnostic or therapeutic advice.',
                tx,
                sub,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _cTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('I Understand & Agree', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _guidelineRow(
    IconData icon,
    String title,
    String body,
    Color tx,
    Color sub,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _cTeal, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(color: sub, fontSize: 11.5, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreComposerOptionsSheet(String profileName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.poll_rounded, color: _cPurple),
                title: Text('Create Poll', style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
                subtitle: Text('Gather clinical opinions from peers', style: TextStyle(color: sub, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showPollSheet(profileName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.medical_information_rounded, color: _cBlue),
                title: Text('Clinical Case Study', style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
                subtitle: Text('Share and discuss anonymized diagnostic cases', style: TextStyle(color: sub, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCaseDiscussionSheet(profileName);
                },
              ),
              ListTile(
                leading: const Icon(Icons.article_rounded, color: _cOrange),
                title: Text('Medical Article', style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
                subtitle: Text('Publish a detailed clinical commentary or review', style: TextStyle(color: sub, fontSize: 12)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showArticleSheet(profileName);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAskQuestionSheet(String profileName) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.help_outline_rounded, color: _cGreen, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Ask a Clinical Question',
                        style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: sub),
                        onPressed: () => Navigator.pop(ctx2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: ctrl,
                    maxLines: 4,
                    style: TextStyle(color: tx, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'What clinical question or diagnosis challenge would you like peer input on?',
                      hintStyle: TextStyle(color: sub, fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (ctrl.text.trim().isEmpty) return;
                        final newPost = {
                          'name': profileName,
                          'verified': true,
                          'role': 'Doctor',
                          'hospital': '',
                          'time': 'Just now',
                          'visibility': 'Public',
                          'type': 'text',
                          'specialty': 'General Medicine',
                          'content': '❓ Question: ${ctrl.text.trim()}\n#ClinicalQuestion #PeerReview',
                          'likes': 0,
                          'comments': 0,
                          'reposts': 0,
                        };
                        Navigator.pop(ctx2);
                        setState(() => _localPosts.insert(0, newPost));
                        _snack('Question posted to community!', bg: _cGreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Post Question', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCaseDiscussionSheet(String profileName) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.medical_information_rounded, color: _cBlue, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Start Clinical Case Discussion',
                        style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(Icons.close_rounded, color: sub),
                        onPressed: () => Navigator.pop(ctx2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    style: TextStyle(color: tx, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Case Title / Clinical Presentation',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bodyCtrl,
                    maxLines: 4,
                    style: TextStyle(color: tx, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Anonymized Clinical Findings & Investigations',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isEmpty || bodyCtrl.text.trim().isEmpty) return;
                        final newPost = {
                          'name': profileName,
                          'verified': true,
                          'role': 'Doctor',
                          'hospital': '',
                          'time': 'Just now',
                          'visibility': 'Public',
                          'type': 'text',
                          'specialty': 'General Medicine',
                          'content': '🩺 Case: ${titleCtrl.text.trim()}\n\n${bodyCtrl.text.trim()}\n#ClinicalCaseStudies #MedicalDiscussion',
                          'likes': 0,
                          'comments': 0,
                          'reposts': 0,
                        };
                        Navigator.pop(ctx2);
                        setState(() => _localPosts.insert(0, newPost));
                        _snack('Case discussion published!', bg: _cBlue);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _cBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Start Discussion', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEventsSheet() {
    final events = [
      {'title': 'National Emergency Medicine Summit 2026', 'date': '24 Aug 2026', 'mode': 'Virtual & Delhi'},
      {'title': 'Clinical Cardiology & AI Symposium', 'date': '02 Sep 2026', 'mode': 'Webinar'},
      {'title': 'Pediatric Advanced Life Support Workshop', 'date': '15 Sep 2026', 'mode': 'Bangalore'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.event_note_rounded, color: _cPurple, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Upcoming Medical Events',
                    style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...events.map((e) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _cPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: _cPurple, size: 20),
                    ),
                    title: Text(e['title']!, style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text('${e["date"]} • ${e["mode"]}', style: TextStyle(color: sub, fontSize: 11)),
                    trailing: TextButton(
                      onPressed: () => _snack('Registered for ${e["title"]}'),
                      child: const Text('Register', style: TextStyle(color: _cPurple, fontWeight: FontWeight.bold)),
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }

  void _showMentorshipSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.groups_rounded, color: _cGreen, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Clinical Mentorship Circle',
                    style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Connect with senior consultants and surgical leads for residency guidance, case reviews, and career counseling.',
                style: TextStyle(color: sub, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _snack('Applied to be a Mentor');
                      },
                      child: const Text('Be a Mentor'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _snack('Searching for available Mentors in your specialty');
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _cGreen, foregroundColor: Colors.white),
                      child: const Text('Find a Mentor'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreQuickActionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;

        return Container(
          decoration: BoxDecoration(
            color: card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.menu_book_rounded, color: _cTeal),
                title: Text('Clinical Guidelines Library', style: TextStyle(color: tx)),
                onTap: () {
                  Navigator.pop(ctx);
                  _showGuidelinesSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_added_rounded, color: _cBlue),
                title: Text('Saved Clinical Insights', style: TextStyle(color: tx)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _selectedFilter = 'Saved');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoPostSheet(String profileName, {XFile? prefillImage}) {
    XFile? selectedImage = prefillImage;
    bool isPicking = false;
    final ctrl = TextEditingController();

    Future<void> pickFromSource(
      BuildContext sheetContext,
      void Function(void Function()) setSheetState,
      ImageSource source,
    ) async {
      setSheetState(() => isPicking = true);
      try {
        final file = await _picker.pickImage(source: source, imageQuality: 85, maxWidth: 1080);
        if (file != null) setSheetState(() => selectedImage = file);
      } catch (_) {}
      setSheetState(() => isPicking = false);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.photo_camera_rounded, color: _cGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Photo Post',
                            style: TextStyle(
                              color: tx,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: sub),
                            onPressed: () => Navigator.pop(ctx2),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: sc,
                        padding: const EdgeInsets.all(16),
                        children: [
                          GestureDetector(
                            onTap: isPicking
                                ? null
                                : () => pickFromSource(ctx2, ss, ImageSource.gallery),
                            child: Container(
                              height: 180,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: _cGreen.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _cGreen.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: isPicking
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: _cGreen,
                                      ),
                                    )
                                  : (selectedImage != null
                                      ? Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(14),
                                              child: kIsWeb
                                                  ? FutureBuilder<Uint8List>(
                                                      future: selectedImage!.readAsBytes(),
                                                      builder: (context, snapshot) {
                                                        if (!snapshot.hasData) {
                                                          return const Center(
                                                            child: CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                          );
                                                        }
                                                        return Image.memory(
                                                          snapshot.data!,
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height: 180,
                                                        );
                                                      },
                                                    )
                                                  : Image.file(
                                                      File(selectedImage!.path),
                                                      fit: BoxFit.cover,
                                                      width: double.infinity,
                                                      height: 180,
                                                    ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: GestureDetector(
                                                onTap: () => ss(() => selectedImage = null),
                                                child: Container(
                                                  width: 30,
                                                  height: 30,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black.withValues(alpha: 0.6),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: const Icon(
                                                    Icons.close_rounded,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: _cGreen.withValues(alpha: 0.12),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                Icons.add_photo_alternate_rounded,
                                                color: _cGreen,
                                                size: 28,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            const Text(
                                              'Choose Clinical Photo',
                                              style: TextStyle(
                                                color: _cGreen,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                TextButton.icon(
                                                  onPressed: () => pickFromSource(
                                                    ctx2,
                                                    ss,
                                                    ImageSource.camera,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.camera_alt_rounded,
                                                    size: 16,
                                                    color: _cTeal,
                                                  ),
                                                  label: const Text(
                                                    'Camera',
                                                    style: TextStyle(color: _cTeal),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                TextButton.icon(
                                                  onPressed: () => pickFromSource(
                                                    ctx2,
                                                    ss,
                                                    ImageSource.gallery,
                                                  ),
                                                  icon: const Icon(
                                                    Icons.photo_library_rounded,
                                                    size: 16,
                                                    color: _cGreen,
                                                  ),
                                                  label: const Text(
                                                    'Gallery',
                                                    style: TextStyle(color: _cGreen),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: ctrl,
                            maxLines: 3,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Add clinical context or description...',
                              hintStyle: TextStyle(color: sub, fontSize: 13),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (selectedImage == null && ctrl.text.trim().isEmpty) {
                              _snack('Please select a photo or add a caption', bg: _cRed);
                              return;
                            }
                            final newPost = {
                              'name': profileName,
                              'verified': true,
                              'role': 'Doctor',
                              'hospital': '',
                              'time': 'Just now',
                              'visibility': 'Public',
                              'type': 'text',
                              'specialty': 'General Medicine',
                              'content': ctrl.text.trim().isNotEmpty
                                  ? ctrl.text.trim()
                                  : 'Shared clinical media',
                              'likes': 0,
                              'comments': 0,
                              'reposts': 0,
                              if (selectedImage != null) 'imagePath': selectedImage!.path,
                            };
                            Navigator.pop(ctx2);
                            setState(() => _localPosts.insert(0, newPost));
                            _snack('Photo post published!', bg: _cGreen);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Publish Photo Post',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPollSheet(String profileName) {
    final questionCtrl = TextEditingController();
    final List<TextEditingController> optionCtrls = [
      TextEditingController(text: 'Option 1'),
      TextEditingController(text: 'Option 2'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.poll_rounded, color: _cPurple, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Create Poll',
                            style: TextStyle(
                              color: tx,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: sub),
                            onPressed: () => Navigator.pop(ctx2),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: sc,
                        padding: const EdgeInsets.all(16),
                        children: [
                          TextField(
                            controller: questionCtrl,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Clinical question',
                              labelStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Options',
                            style: TextStyle(
                              color: tx,
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...optionCtrls.asMap().entries.map(
                                (e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: e.value,
                                          style: TextStyle(color: tx, fontSize: 13.5),
                                          decoration: InputDecoration(
                                            labelText: 'Option ${e.key + 1}',
                                            labelStyle: TextStyle(color: sub),
                                            filled: true,
                                            fillColor: border.withValues(alpha: 0.2),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding: const EdgeInsets.all(10),
                                          ),
                                        ),
                                      ),
                                      if (optionCtrls.length > 2)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.remove_circle_outline_rounded,
                                            color: _cRed,
                                            size: 20,
                                          ),
                                          onPressed: () => ss(() => optionCtrls.removeAt(e.key)),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          if (optionCtrls.length < 5)
                            TextButton.icon(
                              onPressed: () => ss(
                                () => optionCtrls.add(
                                  TextEditingController(text: 'Option ${optionCtrls.length + 1}'),
                                ),
                              ),
                              icon: const Icon(Icons.add_rounded, color: _cPurple, size: 18),
                              label: const Text(
                                'Add Option',
                                style: TextStyle(color: _cPurple),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (questionCtrl.text.trim().isEmpty) {
                              _snack('Please enter a question', bg: _cRed);
                              return;
                            }
                            final opts = optionCtrls
                                .map((c) => c.text.trim())
                                .where((s) => s.isNotEmpty)
                                .toList();
                            if (opts.length < 2) {
                              _snack('Please provide at least 2 options', bg: _cRed);
                              return;
                            }
                            final pcts = List.generate(
                              opts.length,
                              (i) => (100 ~/ opts.length) + (i == 0 ? 100 % opts.length : 0),
                            );
                            final cols = [_cTeal, _cGreen, _cBlue, _cAmber, _cPurple];
                            final newPost = {
                              'name': profileName,
                              'verified': true,
                              'role': 'Doctor',
                              'hospital': '',
                              'time': 'Just now',
                              'visibility': 'Public',
                              'type': 'poll',
                              'specialty': 'General Medicine',
                              'content': questionCtrl.text.trim(),
                              'pollOptions': opts,
                              'pollPercents': pcts,
                              'pollColors': cols.sublist(0, opts.length),
                              'votes': 0,
                              'likes': 0,
                              'comments': 0,
                              'reposts': 0,
                            };
                            Navigator.pop(ctx2);
                            setState(() => _localPosts.insert(0, newPost));
                            _snack('Poll published!', bg: _cPurple);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cPurple,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Publish Poll',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showProfessionalExperienceSheet(String profileName) {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    final hospitalCtrl = TextEditingController();
    final specialtyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.work_rounded, color: _cBlue, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Professional Experience',
                            style: TextStyle(
                              color: tx,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: sub),
                            onPressed: () => Navigator.pop(ctx2),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: sc,
                        padding: const EdgeInsets.all(16),
                        children: [
                          TextField(
                            controller: titleCtrl,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Title / Clinical Role',
                              labelStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: hospitalCtrl,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Hospital / Clinic / Institute',
                              labelStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: specialtyCtrl,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Specialty',
                              labelStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: contentCtrl,
                            maxLines: 4,
                            style: TextStyle(color: tx, fontSize: 14),
                            decoration: InputDecoration(
                              labelText: 'Experience description & milestones',
                              labelStyle: TextStyle(color: sub),
                              filled: true,
                              fillColor: border.withValues(alpha: 0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) {
                              _snack('Please enter a title', bg: _cRed);
                              return;
                            }
                            final newPost = {
                              'name': profileName,
                              'verified': true,
                              'role': specialtyCtrl.text.trim().isNotEmpty
                                  ? specialtyCtrl.text.trim()
                                  : 'Doctor',
                              'hospital': hospitalCtrl.text.trim().isNotEmpty
                                  ? hospitalCtrl.text.trim()
                                  : '',
                              'time': 'Just now',
                              'visibility': 'Public',
                              'type': 'experience',
                              'specialty': specialtyCtrl.text.trim().isNotEmpty
                                  ? specialtyCtrl.text.trim()
                                  : 'General',
                              'content': contentCtrl.text.trim().isNotEmpty
                                  ? contentCtrl.text.trim()
                                  : '${titleCtrl.text.trim()} at ${hospitalCtrl.text.trim()}',
                              'experienceTitle': titleCtrl.text.trim(),
                              'experiencePlace': hospitalCtrl.text.trim().isNotEmpty
                                  ? hospitalCtrl.text.trim()
                                  : 'Medical Center',
                              'experienceDuration': '2026 — Present',
                              'likes': 0,
                              'comments': 0,
                              'reposts': 0,
                            };
                            Navigator.pop(ctx2);
                            setState(() => _localPosts.insert(0, newPost));
                            _snack('Experience published!', bg: _cBlue);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Publish Experience',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showArticleSheet(String profileName) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.90,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.article_rounded, color: _cOrange, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Write Medical Article',
                            style: TextStyle(
                              color: tx,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: sub),
                            onPressed: () => Navigator.pop(ctx2),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: sc,
                        padding: const EdgeInsets.all(16),
                        children: [
                          TextField(
                            controller: titleCtrl,
                            style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: 'Article title...',
                              hintStyle: TextStyle(color: sub, fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                          Divider(color: border),
                          TextField(
                            controller: bodyCtrl,
                            maxLines: null,
                            minLines: 8,
                            style: TextStyle(color: tx, fontSize: 14, height: 1.55),
                            decoration: InputDecoration(
                              hintText: 'Write your clinical case study, review, or article body here...',
                              hintStyle: TextStyle(color: sub, fontSize: 14),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleCtrl.text.trim().isEmpty) {
                              _snack('Please add an article title', bg: _cRed);
                              return;
                            }
                            if (bodyCtrl.text.trim().isEmpty) {
                              _snack('Please write the article body', bg: _cRed);
                              return;
                            }
                            final newPost = {
                              'name': profileName,
                              'verified': true,
                              'role': 'Doctor',
                              'hospital': '',
                              'time': 'Just now',
                              'visibility': 'Public',
                              'type': 'text',
                              'specialty': 'General Medicine',
                              'content': '📝 ${titleCtrl.text.trim()}\n\n${bodyCtrl.text.trim()}',
                              'likes': 0,
                              'comments': 0,
                              'reposts': 0,
                            };
                            Navigator.pop(ctx2);
                            setState(() => _localPosts.insert(0, newPost));
                            _snack('Article published!', bg: _cOrange);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _cOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Publish Article',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _postId(Map<String, dynamic> post, int index) => _communityPostId(post, index);

  void _reportPost(Map<String, dynamic> post, int index) =>
      _reportCommunityPost(context, post, index);

  void _showCommentsSheet(Map<String, dynamic> post, int postIndex) {
    final ctrl = TextEditingController();
    final sampleComments = [
      {
        'name': 'Dr. Rakesh Gupta',
        'time': '1h ago',
        'text': 'Insightful perspective. Very relevant for clinical management.'
      },
      {
        'name': 'Dr. Meera Pillai',
        'time': '30m ago',
        'text': 'Thanks for sharing these clinical takeaways with the network!'
      },
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, ss) {
          final localComments = [...sampleComments];
          final isDark = Theme.of(ctx2).brightness == Brightness.dark;
          final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
          final tx = isDark ? AppColors.darkText : AppColors.lightText;
          final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
          final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx2).viewInsets.bottom),
            child: DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              builder: (_, sc) => Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 4),
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: sub.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Text(
                            'Comments (${localComments.length})',
                            style: TextStyle(
                              color: tx,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.close_rounded, color: sub),
                            onPressed: () => Navigator.pop(ctx2),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: border, height: 1),
                    Expanded(
                      child: ListView(
                        controller: sc,
                        padding: const EdgeInsets.all(16),
                        children: localComments
                            .map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 15,
                                      backgroundColor: _cTeal.withValues(alpha: 0.15),
                                      child: Text(
                                        _initials(c['name']!),
                                        style: const TextStyle(
                                          color: _cTeal,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
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
                                                c['name']!,
                                                style: TextStyle(
                                                  color: tx,
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                c['time']!,
                                                style: TextStyle(color: sub, fontSize: 10.5),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            c['text']!,
                                            style: TextStyle(
                                              color: tx,
                                              fontSize: 12.5,
                                              height: 1.35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: ctrl,
                              style: TextStyle(color: tx, fontSize: 13),
                              decoration: InputDecoration(
                                hintText: 'Add a clinical comment...',
                                hintStyle: TextStyle(color: sub),
                                filled: true,
                                fillColor: border.withValues(alpha: 0.25),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              if (ctrl.text.trim().isNotEmpty) {
                                final text = ctrl.text.trim();
                                ctrl.clear();
                                ss(() => localComments.add({
                                      'name': 'You',
                                      'time': 'Just now',
                                      'text': text,
                                    }));
                              }
                            },
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: const BoxDecoration(
                                color: _cTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _openShareSheet(Map<String, dynamic> post, int postIndex) {
    final snippet = (post['content'] as String?)?.trim() ?? 'Shared on MedDuty Community';
    MedDutyShareService.show(
      context,
      SharePayload.communityPost(
        postId: _postId(post, postIndex),
        authorName: post['name']?.toString() ?? 'MedDuty User',
        snippet: snippet.length > 120 ? '${snippet.substring(0, 120)}...' : snippet,
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> post, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) {
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
          title: Text(
            'Delete Post',
            style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete this post? This action cannot be undone.',
            style: TextStyle(color: sub, fontSize: 13.5, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(color: sub, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (_localPosts.contains(post)) {
                  setState(() => _localPosts.remove(post));
                }
                _snack('Post deleted', bg: _cRed);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _cRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  void _showRepostSheet(Map<String, dynamic> post, int postIndex) {
    final alreadyReposted = _repostedPosts.contains(postIndex);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
        final tx = isDark ? AppColors.darkText : AppColors.lightText;
        final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: card, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  alreadyReposted ? 'Already reposted' : 'Repost to Professional Network',
                  style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              if (!alreadyReposted) ...[
                ListTile(
                  leading: const Icon(Icons.repeat_rounded, color: _cGreen),
                  title: Text(
                    'Repost',
                    style: TextStyle(color: tx, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'Share directly to your community network',
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    HapticFeedback.lightImpact();
                    setState(() {
                      _repostedPosts.add(postIndex);
                      post['reposts'] = (post['reposts'] as int? ?? 0) + 1;
                    });
                    _snack('Reposted to your network', bg: _cGreen);
                  },
                ),
              ],
              ListTile(
                leading: Icon(Icons.close_rounded, color: sub),
                title: Text('Cancel', style: TextStyle(color: sub)),
                onTap: () => Navigator.pop(ctx),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostImage(String imagePath, {double height = 200}) {
    final isNetwork = kIsWeb || imagePath.startsWith('http') || imagePath.startsWith('blob:');
    if (isNetwork) {
      return Image.network(
        imagePath,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          height: height,
          color: _cGreen.withValues(alpha: 0.08),
          child: const Icon(Icons.broken_image_outlined, color: _cGreen),
        ),
      );
    }
    return Image.file(
      File(imagePath),
      width: double.infinity,
      height: height,
      fit: BoxFit.cover,
    );
  }
}

// ─── 16. HASHTAG FEED SCREEN ────────────────────────────────────────────────
class _HashtagFeedScreen extends StatefulWidget {
  final String category;
  const _HashtagFeedScreen({required this.category});

  @override
  State<_HashtagFeedScreen> createState() => _HashtagFeedScreenState();
}

class _HashtagFeedScreenState extends State<_HashtagFeedScreen> {
  final Map<int, bool> _liked = {};
  final Map<int, bool> _saved = {};
  final Map<int, int> _counts = {};

  String _initials(String n) {
    final p = n.trim().split(' ');
    if (p.length >= 2) return '${p[0][0]}${p[1][0]}'.toUpperCase();
    return p.isNotEmpty ? p[0][0].toUpperCase() : 'MD';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF111827) : Colors.white;
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ];

    final posts = [
      {
        'name': 'Dr. Anil Kumar',
        'role': 'Cardiologist',
        'hospital': 'Apollo Heart',
        'time': '1h ago',
        'content':
            'Great discussion on ${widget.category}! This clinical focus is essential for modern evidence-based patient management.'
      },
      {
        'name': 'Dr. Preethi Iyer',
        'role': 'Internist',
        'hospital': 'Max Hospital',
        'time': '3h ago',
        'content':
            'Sharing insights from our hospital department regarding ${widget.category}. Notable improvements in clinical outcomes.'
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.category,
              style: TextStyle(color: tx, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('${posts.length * 312} discussions', style: TextStyle(color: sub, fontSize: 11)),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: posts.length,
        itemBuilder: (ctx, i) {
          final p = posts[i];
          final isLiked = _liked[i] ?? false;
          final isSaved = _saved[i] ?? false;
          final count = _counts[i] ?? (12 + i * 7);
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: shadow,
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 8, 0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _cTeal.withValues(alpha: 0.15),
                        child: Text(
                          _initials(p['name']!),
                          style: const TextStyle(
                            color: _cTeal,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    p['name']!,
                                    style: TextStyle(
                                      color: tx,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified_rounded,
                                  color: _cBlue,
                                  size: 12,
                                ),
                              ],
                            ),
                            Text(
                              '${p["role"]} • ${p["hospital"]}',
                              style: TextStyle(color: sub, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                  child: Text(
                    p['content']!,
                    style: TextStyle(color: tx, fontSize: 13, height: 1.45),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _liked[i] = !isLiked;
                            _counts[i] = isLiked ? count - 1 : count + 1;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: isLiked ? _cRed : sub,
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$count',
                              style: TextStyle(color: isLiked ? _cRed : sub, fontSize: 12),
                            ),
                            const SizedBox(width: 14),
                          ],
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _saved[i] = !isSaved);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isSaved ? 'Removed from saved' : 'Post saved'),
                              backgroundColor: _cTeal,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        child: Icon(
                          isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: isSaved ? _cTeal : sub,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
