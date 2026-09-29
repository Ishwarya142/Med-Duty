import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../models/job_with_distance.dart';
import '../../providers/job_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/profile_provider.dart';
import '../duties/widgets/location_selector_sheet.dart';
import 'job_helpers.dart';
import 'widgets/job_card.dart';
import 'widgets/job_filters_sheet.dart';

const _cBlue = Color(0xFF2563EB);
const _cTeal = Color(0xFF0F766E);

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final jobs = context.read<JobProvider>();
      final loc = context.read<LocationProvider>();
      if (jobs.nearbyJobs.isEmpty) {
        jobs.computeNearbyJobs(loc);
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final jobs = context.watch<JobProvider>();
    final location = context.watch<LocationProvider>();
    final profile = context.watch<ProfileProvider>();
    final l10n = context.l10n;

    final tabs = [
      (l10n.nearby, jobs.nearbyJobs.length),
      (l10n.recommended, jobs.recommendedNearby(location, profile).length),
      (l10n.applied, jobs.appliedJobsCount),
      (l10n.saved, jobs.savedJobsCount),
    ];

    List<JobWithDistance> items;
    switch (_selectedTab) {
      case 1:
        items = jobs.recommendedNearby(location, profile);
        break;
      case 2:
        items = jobs.appliedJobsNearby(location);
        break;
      case 3:
        items = jobs.savedJobsNearby(location);
        break;
      default:
        items = jobs.nearbyJobs;
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: bg,
              elevation: 0,
              title: Text(l10n.jobs,
                  style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
              iconTheme: IconThemeData(color: tx),
              actions: [
                IconButton(
                  icon: Icon(Icons.tune_rounded, color: tx),
                  onPressed: () async {
                    await showJobFiltersSheet(context);
                    if (!mounted) return;
                    jobs.computeNearbyJobs(location);
                    setState(() {});
                  },
                ),
              ],
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  Text(
                    'Search Jobs',
                    style: TextStyle(
                      color: tx,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.tune_rounded, color: tx),
                    onPressed: () async {
                      await showJobFiltersSheet(context);
                      if (!mounted) return;
                      jobs.computeNearbyJobs(location);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) {
                jobs.setSearchQuery(v);
                jobs.computeNearbyJobs(location);
              },
              style: TextStyle(color: tx),
              decoration: InputDecoration(
                hintText: l10n.searchJobs,
                hintStyle: TextStyle(color: sub),
                prefixIcon: Icon(Icons.search_rounded, color: sub),
                filled: true,
                fillColor: card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: border),
                ),
              ),
            ),
          ),
          _locationBar(card, border, tx, sub, location, jobs),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final selected = _selectedTab == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTab = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? _cTeal : card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? _cTeal : border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tabs[i].$1,
                          style: TextStyle(
                            color: selected ? Colors.white : sub,
                            fontWeight:
                                selected ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                        if (tabs[i].$2 > 0) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: selected
                                  ? Colors.white.withValues(alpha: 0.25)
                                  : _cTeal.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${tabs[i].$2}',
                              style: TextStyle(
                                color: selected ? Colors.white : _cTeal,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: jobs.loading
                ? const Center(child: CircularProgressIndicator(color: _cBlue))
                : items.isEmpty
                    ? _emptyState(tx, sub, location, jobs)
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 10),
                        itemBuilder: (_, i) {
                          final item = items[i];
                          return JobCard(
                            item: item,
                            isApplied: jobs.isJobApplied(item.job.id),
                            isSaved: jobs.isJobSaved(item.job.id),
                            onTap: () => openJobDetails(context, item),
                            onApply: () => applyForJob(context, item),
                            onSave: () => toggleJobSave(context, item),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _locationBar(
    Color card,
    Color border,
    Color tx,
    Color sub,
    LocationProvider location,
    JobProvider jobs,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: GestureDetector(
        onTap: () async {
          await showLocationSelectorSheet(context);
          if (!mounted) return;
          await jobs.refreshForLocation(context.read<LocationProvider>());
          setState(() {});
        },
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded, color: _cTeal, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.locationLabel,
                    style: TextStyle(
                      color: tx,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    location.radiusLabel,
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                ],
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: sub),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(
    Color tx,
    Color sub,
    LocationProvider location,
    JobProvider jobs,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline_rounded, size: 48, color: sub),
            const SizedBox(height: 12),
            Text(
              'No jobs found within ${location.radiusKm.toStringAsFixed(0)} km',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tx,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try expanding your radius or adjusting filters.',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                location.setRadiusKm(25);
                jobs.refreshForLocation(location);
                setState(() {});
              },
              style: FilledButton.styleFrom(backgroundColor: _cTeal),
              child: const Text('Expand to 25 km'),
            ),
          ],
        ),
      ),
    );
  }
}
