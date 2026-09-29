import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/account_status_utils.dart';
import '../public_doctor_profile_screen.dart';

class FollowersFollowingScreen extends StatefulWidget {
  const FollowersFollowingScreen({super.key});

  @override
  State<FollowersFollowingScreen> createState() => _FollowersFollowingScreenState();
}

class _FollowersFollowingScreenState extends State<FollowersFollowingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _loading = true;
  List<Map<String, String>> _followers = [];
  List<Map<String, String>> _following = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final supabase = Supabase.instance.client;
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final followersData = await supabase.from(SupabaseConstants.followers).select().eq('userId', uid);
      final followingData = await supabase.from(SupabaseConstants.following).select().eq('userId', uid);
      _followers = await _resolveUsers(List<Map<String, dynamic>>.from(followersData));
      _following = await _resolveUsers(List<Map<String, dynamic>>.from(followingData));
    } catch (_) {
      _followers = [];
      _following = [];
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<List<Map<String, String>>> _resolveUsers(List<Map<String, dynamic>> relationDocs) async {
    final supabase = Supabase.instance.client;
    final results = <Map<String, String>>[];
    for (final relation in relationDocs) {
      final id = (relation['targetId'] ?? relation['id'] ?? '').toString();
      if (id.isEmpty) continue;
      try {
        final doc = await supabase.from(SupabaseConstants.users).select().eq('uid', id).maybeSingle();
        final data = doc ?? {};
        if (!AccountStatusUtils.isDiscoverable(data)) continue;
        results.add({
          'id': id,
          'name': (data['name'] ?? relation['name'] ?? 'Doctor').toString(),
          'role': (data['specialization'] ?? relation['specialization'] ?? 'Healthcare Professional').toString(),
        });
      } catch (_) {
        results.add({
          'id': id,
          'name': relation['name']?.toString() ?? 'Doctor',
          'role': relation['specialization']?.toString() ?? 'Healthcare Professional',
        });
      }
    }
    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final text = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Followers & Following', style: TextStyle(color: text, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.accent,
          unselectedLabelColor: sub,
          indicatorColor: AppColors.accent,
          tabs: const [Tab(text: 'Followers'), Tab(text: 'Following')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
          : TabBarView(
              controller: _tabController,
              children: [
                _list(_followers, 'No followers yet', text, sub),
                _list(_following, 'Not following anyone yet', text, sub),
              ],
            ),
    );
  }

  Widget _list(List<Map<String, String>> items, String empty, Color text, Color sub) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          empty,
          style: TextStyle(color: sub, fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final item = items[i];
        final id = item['id'] ?? '';
        final name = item['name'] ?? 'Doctor';
        final role = item['role'] ?? 'Healthcare Professional';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'D',
              style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(name, style: TextStyle(color: text, fontWeight: FontWeight.w700)),
          subtitle: Text(role, style: TextStyle(color: sub, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: id.isEmpty
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicDoctorProfileScreen(
                        doctorId: id,
                        doctorName: name,
                        qualification: item['qualification'] ?? '',
                        specialization: item['specialization'] ?? '',
                        hospital: item['hospital'] ?? '',
                        location: item['location'] ?? '',
                      ),
                    ),
                  ),
        );
      },
    );
  }
}
