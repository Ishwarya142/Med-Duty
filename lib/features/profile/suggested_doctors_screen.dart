import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/suggested_doctors_service.dart';
import '../../core/theme/app_colors.dart';
import '../../models/suggested_doctor_model.dart';
import '../../providers/profile_provider.dart';
import 'mutual_connections_screen.dart';
import 'public_doctor_profile_screen.dart';

class SuggestedDoctorsScreen extends StatefulWidget {
  const SuggestedDoctorsScreen({super.key});

  @override
  State<SuggestedDoctorsScreen> createState() => _SuggestedDoctorsScreenState();
}

class _SuggestedDoctorsScreenState extends State<SuggestedDoctorsScreen> {
  final _service = SuggestedDoctorsService();
  final _searchCtrl = TextEditingController();
  List<SuggestedDoctorModel> _doctors = [];
  bool _loading = true;
  String? _specializationFilter;
  String? _locationFilter;
  SuggestedDoctorCategory _category = SuggestedDoctorCategory.recommended;

  static const _specializations = [
    'General Physician',
    'Cardiologist',
    'Dermatologist',
    'Paediatrician',
    'Orthopaedic Surgeon',
    'Neurologist',
    'Anesthesiologist',
    'Radiologist',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final profile = context.read<ProfileProvider>();
    final doctors = await _service.fetchSuggested(
      specialization: _specializationFilter ?? (_category == SuggestedDoctorCategory.sameSpecialty ? profile.specialization : null),
      hospital: _category == SuggestedDoctorCategory.sameHospital ? profile.currentHospital : null,
      city: _locationFilter,
      searchQuery: _searchCtrl.text,
      category: _category,
    );
    if (!mounted) return;
    setState(() {
      _doctors = doctors;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Suggested Doctors', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Based on your specialty, connections and activity',
              style: TextStyle(color: subText, fontSize: 13),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchCtrl,
              onSubmitted: (_) => _load(),
              decoration: InputDecoration(
                hintText: 'Search doctors, specialty, hospital...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.accent),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.tune_rounded),
                  onPressed: _showFilters,
                ),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: border)),
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: SuggestedDoctorCategory.values.map((cat) {
                final selected = _category == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat.label, style: TextStyle(fontSize: 11)),
                    selected: selected,
                    onSelected: (_) {
                      setState(() => _category = cat);
                      _load();
                    },
                    selectedColor: AppColors.accent.withValues(alpha: 0.15),
                    checkmarkColor: AppColors.accent,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
                : _doctors.isEmpty
                ? Center(child: Text('No recommendations available right now.', style: TextStyle(color: subText)))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: _doctors.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return SuggestedDoctorCard(
                        doctor: _doctors[index],
                        textColor: textColor,
                        subText: subText,
                        surface: surface,
                        border: border,
                        compact: false,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: _specializationFilter,
                  decoration: const InputDecoration(labelText: 'Specialization'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Any')),
                    ..._specializations.map((s) => DropdownMenuItem(value: s, child: Text(s))),
                  ],
                  onChanged: (v) => setState(() => _specializationFilter = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: 'City / Location'),
                  onChanged: (v) => _locationFilter = v.trim().isEmpty ? null : v.trim(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _load();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, foregroundColor: AppColors.white),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SuggestedDoctorCard extends StatefulWidget {
  final SuggestedDoctorModel doctor;
  final Color textColor;
  final Color subText;
  final Color surface;
  final Color border;
  final bool compact;

  const SuggestedDoctorCard({
    super.key,
    required this.doctor,
    required this.textColor,
    required this.subText,
    required this.surface,
    required this.border,
    this.compact = true,
  });

  @override
  State<SuggestedDoctorCard> createState() => _SuggestedDoctorCardState();
}

class _SuggestedDoctorCardState extends State<SuggestedDoctorCard> {
  int? _mutualCount;
  bool _mutualLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMutual();
  }

  Future<void> _loadMutual() async {
    final count = await context.read<ProfileProvider>().mutualConnectionsCount(widget.doctor.id);
    if (mounted) {
      setState(() {
        _mutualCount = count;
        _mutualLoading = false;
      });
    }
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicDoctorProfileScreen(
          doctorId: widget.doctor.id,
          doctorName: widget.doctor.name,
          qualification: widget.doctor.qualification,
          specialization: widget.doctor.specialization,
          hospital: widget.doctor.hospital,
          location: widget.doctor.location.isEmpty ? 'India' : widget.doctor.location,
          avatarInitials: widget.doctor.avatarInitials,
          avatarColor: AppColors.accent,
        ),
      ),
    );
  }

  Future<void> _toggleFollow() async {
    final profile = context.read<ProfileProvider>();
    final following = profile.isFollowingUser(widget.doctor.id);
    if (following) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Unfollow ${widget.doctor.name}?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Unfollow')),
          ],
        ),
      );
      if (confirm != true) return;
      final ok = await profile.unfollowUser(widget.doctor.id);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unfollowed ${widget.doctor.name}')),
        );
        setState(() {});
      }
    } else {
      final ok = await profile.followUser(
        targetUserId: widget.doctor.id,
        targetName: widget.doctor.name,
        targetSpecialization: widget.doctor.specialization,
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('You\'re now following ${widget.doctor.name}.')),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final following = profile.isFollowingUser(widget.doctor.id);
    final mutual = widget.doctor.mutualCount ?? _mutualCount ?? 0;

    if (widget.compact) {
      return SizedBox(
        width: 160,
        child: Material(
          color: widget.surface,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: _openProfile,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: widget.border.withValues(alpha: 0.5)),
                boxShadow: AppColors.softShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.accent,
                    child: Text(widget.doctor.avatarInitials, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.doctor.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: widget.textColor)),
                  const SizedBox(height: 2),
                  Text(widget.doctor.qualification, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: mutual > 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MutualConnectionsScreen(
                                  targetUserId: widget.doctor.id,
                                  targetName: widget.doctor.name,
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      _mutualLoading ? '...' : '$mutual Mutual',
                      style: TextStyle(fontSize: 10, color: widget.subText),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 32,
                    child: ElevatedButton(
                      onPressed: _toggleFollow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: following ? widget.surface : AppColors.accent,
                        foregroundColor: following ? AppColors.accent : AppColors.white,
                        side: following ? const BorderSide(color: AppColors.accent) : null,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(following ? 'Following' : 'Follow', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Material(
      color: widget.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _openProfile,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: widget.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 28, backgroundColor: AppColors.accent, child: Text(widget.doctor.avatarInitials, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w800))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${widget.doctor.name}${widget.doctor.isVerified ? ' ✓' : ''}', style: TextStyle(color: widget.textColor, fontWeight: FontWeight.w800)),
                    Text(widget.doctor.specialization, style: TextStyle(color: widget.subText, fontSize: 13)),
                    Text('${widget.doctor.hospital}, ${widget.doctor.location}', style: TextStyle(color: widget.subText, fontSize: 12)),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: mutual > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MutualConnectionsScreen(
                                    targetUserId: widget.doctor.id,
                                    targetName: widget.doctor.name,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text('${_mutualLoading ? '...' : mutual} mutual connections', style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: OutlinedButton(
                  onPressed: _toggleFollow,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: following ? widget.subText : AppColors.accent,
                    side: BorderSide(color: following ? widget.border : AppColors.accent),
                  ),
                  child: Text(following ? 'Following' : 'Follow'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
