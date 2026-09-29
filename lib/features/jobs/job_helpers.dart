import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/job_with_distance.dart';
import '../../../providers/job_provider.dart';
import '../../../providers/location_provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../core/utils/duties_navigation.dart';
import 'job_details_screen.dart';
import '../../../shared/widgets/app_shell.dart';
import '../duties/nearby_duties_screen.dart';

const jobTeal = Color(0xFF0F766E);
const jobBlue = Color(0xFF2563EB);

void openJobDetails(BuildContext context, JobWithDistance item) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => JobDetailsScreen(item: item),
    ),
  );
}

void openJobDetailsById(BuildContext context, String jobId) {
  final loc = context.read<LocationProvider>();
  final jobs = context.read<JobProvider>();
  final item = jobs.jobWithDistanceForId(jobId, loc);
  if (item != null) {
    openJobDetails(context, item);
  }
}

Future<void> applyForJob(
  BuildContext context,
  JobWithDistance item,
) async {
  final jobs = context.read<JobProvider>();
  final profile = context.read<ProfileProvider>();

  if (jobs.isJobApplied(item.job.id)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('You have already applied for this job.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return;
  }

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _JobApplySheet(item: item, profile: profile),
  );

  if (confirmed != true || !context.mounted) return;

  final resumeUrl = profile.resume?.url;
  final ok = await jobs.applyForJob(item, resumeUrl: resumeUrl);
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        ok
            ? 'Application submitted successfully.'
            : 'Unable to submit application. Please try again.',
      ),
      backgroundColor: ok ? jobTeal : null,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

Future<void> toggleJobSave(BuildContext context, JobWithDistance item) async {
  final jobs = context.read<JobProvider>();
  final wasSaved = jobs.isJobSaved(item.job.id);
  await jobs.toggleSaveJob(item.job);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(wasSaved ? 'Removed from saved jobs' : 'Job saved'),
      backgroundColor: jobTeal,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

void openJobsScreen(BuildContext context) {
  DutiesNavigation.instance.openJobsTab();
  final shell = AppShell.maybeOf(context);
  if (shell != null) {
    shell.switchTab(1);
    return;
  }
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const NearbyDutiesScreen(),
    ),
  ).then((_) {
    // Embedded jobs mode is default on NearbyDutiesScreen when navigated with pending mode.
  });
}

class _JobApplySheet extends StatelessWidget {
  final JobWithDistance item;
  final ProfileProvider profile;

  const _JobApplySheet({required this.item, required this.profile});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final job = item.job;
    final resume = profile.resume;

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sub.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Apply for this position',
            style: TextStyle(
              color: tx,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            job.title,
            style: TextStyle(color: jobBlue, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _row('Name', profile.name.isNotEmpty ? profile.name : '—', tx, sub),
          _row('Qualification',
              profile.qualification.isNotEmpty ? profile.qualification : '—',
              tx, sub),
          _row(
            'Specialization',
            profile.specialization.isNotEmpty
                ? profile.specialization
                : '—',
            tx,
            sub,
          ),
          _row(
            'Experience',
            profile.experience > 0 ? '${profile.experience} years' : '—',
            tx,
            sub,
          ),
          _row(
            'Resume/CV',
            resume != null && resume.url.isNotEmpty
                ? 'Using profile resume'
                : 'No resume on profile',
            tx,
            sub,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: jobTeal,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Submit Application'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, Color tx, Color sub) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(color: sub, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: tx,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
