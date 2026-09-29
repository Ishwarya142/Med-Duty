import '../core/utils/geo_utils.dart';
import 'duty_model.dart';

class DutyWithDistance {
  final DutyModel duty;
  final double? distanceKm;

  const DutyWithDistance({required this.duty, this.distanceKm});

  String get formattedDistance => formatDistanceKm(distanceKm);

  bool get hasLocation => duty.hasCoordinates;

  DutyWithDistance copyWith({double? distanceKm}) {
    return DutyWithDistance(
      duty: duty,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}
