/// Known search locations for manual selection (Chennai metro area).
class SearchLocationSuggestion {
  final String label;
  final String subtitle;
  final double latitude;
  final double longitude;

  const SearchLocationSuggestion({
    required this.label,
    required this.subtitle,
    required this.latitude,
    required this.longitude,
  });
}

const kChennaiSearchLocations = kPopularSearchLocations;

/// Quick-pick locations across India (any place also searchable via geocoding).
const kPopularSearchLocations = <SearchLocationSuggestion>[
  SearchLocationSuggestion(
    label: 'Avadi',
    subtitle: 'Avadi, Chennai, Tamil Nadu, India',
    latitude: 13.1147,
    longitude: 80.0997,
  ),
  SearchLocationSuggestion(
    label: 'Anna Nagar',
    subtitle: 'Anna Nagar, Chennai, Tamil Nadu, India',
    latitude: 13.0876,
    longitude: 80.2201,
  ),
  SearchLocationSuggestion(
    label: 'Ambattur',
    subtitle: 'Ambattur, Chennai, Tamil Nadu, India',
    latitude: 13.0982,
    longitude: 80.1612,
  ),
  SearchLocationSuggestion(
    label: 'Tambaram',
    subtitle: 'Tambaram, Chennai, Tamil Nadu, India',
    latitude: 12.9249,
    longitude: 80.1000,
  ),
  SearchLocationSuggestion(
    label: 'Porur',
    subtitle: 'Porur, Chennai, Tamil Nadu, India',
    latitude: 13.0358,
    longitude: 80.1568,
  ),
  SearchLocationSuggestion(
    label: 'Velachery',
    subtitle: 'Velachery, Chennai, Tamil Nadu, India',
    latitude: 12.9750,
    longitude: 80.2207,
  ),
  SearchLocationSuggestion(
    label: 'Chennai Central',
    subtitle: 'Chennai, Tamil Nadu, India',
    latitude: 13.0827,
    longitude: 80.2707,
  ),
  SearchLocationSuggestion(
    label: 'Mumbai',
    subtitle: 'Mumbai, Maharashtra, India',
    latitude: 19.0760,
    longitude: 72.8777,
  ),
  SearchLocationSuggestion(
    label: 'Delhi',
    subtitle: 'New Delhi, India',
    latitude: 28.6139,
    longitude: 77.2090,
  ),
  SearchLocationSuggestion(
    label: 'Bangalore',
    subtitle: 'Bengaluru, Karnataka, India',
    latitude: 12.9716,
    longitude: 77.5946,
  ),
  SearchLocationSuggestion(
    label: 'Hyderabad',
    subtitle: 'Hyderabad, Telangana, India',
    latitude: 17.3850,
    longitude: 78.4867,
  ),
  SearchLocationSuggestion(
    label: 'Kolkata',
    subtitle: 'Kolkata, West Bengal, India',
    latitude: 22.5726,
    longitude: 88.3639,
  ),
  SearchLocationSuggestion(
    label: 'Avadi Railway Station',
    subtitle: 'Avadi Railway Station, Chennai, Tamil Nadu',
    latitude: 13.1155,
    longitude: 80.1012,
  ),
];

const kRadiusOptionsKm = [2.0, 5.0, 10.0, 15.0, 25.0, 50.0];

const kDefaultRadiusKm = 10.0;

enum DutySortOption {
  nearest,
  highestPayout,
  earliestDate,
  latestPosted,
  recommended,
}

extension DutySortOptionLabel on DutySortOption {
  String get label => switch (this) {
        DutySortOption.nearest => 'Nearest',
        DutySortOption.highestPayout => 'Highest Payout',
        DutySortOption.earliestDate => 'Earliest Date',
        DutySortOption.latestPosted => 'Latest Posted',
        DutySortOption.recommended => 'Recommended',
      };
}

class DutyDiscoveryFilters {
  final Set<String> specializations;
  final Set<String> shifts;
  final Set<String> dutyTypes;
  final DateTime? dateFilter;
  final String? datePreset; // today, tomorrow, week
  final double? minPayout;
  final double? maxPayout;
  final bool verifiedHospitalsOnly;

  const DutyDiscoveryFilters({
    this.specializations = const {},
    this.shifts = const {},
    this.dutyTypes = const {},
    this.dateFilter,
    this.datePreset,
    this.minPayout,
    this.maxPayout,
    this.verifiedHospitalsOnly = false,
  });

  bool get isEmpty =>
      specializations.isEmpty &&
      shifts.isEmpty &&
      dutyTypes.isEmpty &&
      dateFilter == null &&
      datePreset == null &&
      minPayout == null &&
      maxPayout == null &&
      !verifiedHospitalsOnly;

  int get activeCount {
    var n = 0;
    if (specializations.isNotEmpty) n++;
    if (shifts.isNotEmpty) n++;
    if (dutyTypes.isNotEmpty) n++;
    if (dateFilter != null || datePreset != null) n++;
    if (minPayout != null || maxPayout != null) n++;
    if (verifiedHospitalsOnly) n++;
    return n;
  }

  DutyDiscoveryFilters copyWith({
    Set<String>? specializations,
    Set<String>? shifts,
    Set<String>? dutyTypes,
    DateTime? dateFilter,
    String? datePreset,
    double? minPayout,
    double? maxPayout,
    bool? verifiedHospitalsOnly,
    bool clearDate = false,
    bool clearPayout = false,
  }) {
    return DutyDiscoveryFilters(
      specializations: specializations ?? this.specializations,
      shifts: shifts ?? this.shifts,
      dutyTypes: dutyTypes ?? this.dutyTypes,
      dateFilter: clearDate ? null : (dateFilter ?? this.dateFilter),
      datePreset: clearDate ? null : (datePreset ?? this.datePreset),
      minPayout: clearPayout ? null : (minPayout ?? this.minPayout),
      maxPayout: clearPayout ? null : (maxPayout ?? this.maxPayout),
      verifiedHospitalsOnly:
          verifiedHospitalsOnly ?? this.verifiedHospitalsOnly,
    );
  }
}

const kSpecializationFilters = [
  'General Physician',
  'Emergency Medicine',
  'ICU',
  'Pediatrics',
  'Cardiology',
  'Anesthesiology',
  'Orthopedics',
  'Dermatology',
  'Radiology',
  'Other',
];

const kShiftFilters = ['Day', 'Night', 'Evening', 'Flexible'];

const kDutyTypeFilters = [
  'General Duty',
  'Emergency',
  'ICU',
  'OPD',
  'Night Duty',
  'Weekend Duty',
];
