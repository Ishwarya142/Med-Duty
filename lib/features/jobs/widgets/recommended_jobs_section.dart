import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/job_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/profile_provider.dart';
import '../job_helpers.dart';
import 'job_card.dart';

/// Compact recommended jobs section for Home and discovery surfaces.
class RecommendedJobsSection extends StatelessWidget {
  const RecommendedJobsSection({
    super.key,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.limit = 3,
    this.title = 'Recommended Jobs',
    this.subtitle = 'Career opportunities matched to your profile',
    this.onViewAll,
  });

  final EdgeInsetsGeometry padding;
  final int limit;
  final String title;
  final String subtitle;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final jobs = context.watch<JobProvider>();
    final location = context.watch<LocationProvider>();
    final profile = context.watch<ProfileProvider>();
    final items =
        jobs.recommendedNearby(location, profile).take(limit).toList();

    if (items.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  color: tx,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View all'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: JobCard(
                item: item,
                compact: true,
                actionLabel: 'View Job',
                isApplied: jobs.isJobApplied(item.job.id),
                isSaved: jobs.isJobSaved(item.job.id),
                onTap: () => openJobDetails(context, item),
                onApply: () => openJobDetails(context, item),
                onSave: () => toggleJobSave(context, item),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
