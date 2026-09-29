import '../../models/job_model.dart';
import '../../models/job_with_distance.dart';
import '../utils/geo_utils.dart';
import 'job_discovery_service.dart';

class RecommendedJobsService {
  RecommendedJobsService._();

  static final _discovery = JobDiscoveryService();

  static List<JobWithDistance> build({
    required double centerLat,
    required double centerLng,
    required double currentRadiusKm,
    String specialization = '',
    String qualification = '',
    String experience = '',
    String locationLabel = '',
    Set<String> excludeJobIds = const {},
    int limit = 4,
  }) {
    final spec = specialization.trim().toLowerCase();
    final qual = qualification.trim().toLowerCase();
    final exp = experience.trim().toLowerCase();
    final area = locationLabel.toLowerCase();

    final candidates = <_ScoredJob>[];

    for (final job in _discovery.fetchOpenJobsSync()) {
      if (excludeJobIds.contains(job.id)) continue;
      if (job.status != JobStatus.open) continue;

      double? dist;
      if (job.hasCoordinates) {
        dist = distanceKm(
          centerLat,
          centerLng,
          job.latitude!,
          job.longitude!,
        );
      }

      var score = 0.0;
      final hay =
          '${job.title} ${job.specialization} ${job.qualification}'.toLowerCase();

      if (spec.isNotEmpty) {
        if (hay.contains(spec)) score += 100;
        if (spec.contains('general') && hay.contains('general')) score += 50;
        if (spec.contains('physician') && hay.contains('physician')) score += 40;
        if (spec.contains('medicine') && hay.contains('medicine')) score += 30;
      }
      if (qual.isNotEmpty && hay.contains(qual)) score += 40;
      if (exp.isNotEmpty && job.experienceRequired.toLowerCase().contains('0')) {
        score += 10;
      }
      if (area.isNotEmpty &&
          job.location.toLowerCase().contains(area.split(',').first.trim())) {
        score += 60;
      }
      for (final keyword in ['avadi', 'ambattur', 'chennai', 'poonamallee']) {
        if (job.location.toLowerCase().contains(keyword)) score += 10;
      }
      if (dist != null) {
        if (dist <= currentRadiusKm) score += 80;
        score += (40 - dist.clamp(0, 40));
      }
      if (job.verified) score += 8;
      score += (job.salaryMax / 10000);

      candidates.add(_ScoredJob(JobWithDistance(job: job, distanceKm: dist), score));
    }

    candidates.sort((a, b) => b.score.compareTo(a.score));

    final seen = <String>{};
    final results = <JobWithDistance>[];
    for (final c in candidates) {
      if (seen.add(c.item.job.id)) results.add(c.item);
      if (results.length >= limit) break;
    }
    return results;
  }
}

class _ScoredJob {
  final JobWithDistance item;
  final double score;
  const _ScoredJob(this.item, this.score);
}
