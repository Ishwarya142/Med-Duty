import '../core/utils/geo_utils.dart';
import 'job_model.dart';

class JobWithDistance {
  final JobModel job;
  final double? distanceKm;

  const JobWithDistance({required this.job, this.distanceKm});

  String get formattedDistance => formatDistanceKm(distanceKm);

  bool get hasLocation => job.hasCoordinates;

  JobWithDistance copyWith({double? distanceKm}) {
    return JobWithDistance(
      job: job,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
