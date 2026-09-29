import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/supabase_constants.dart';
import '../models/duty_model.dart';
import '../models/application_model.dart';
import '../models/duty_with_distance.dart';
import '../models/duty_discovery_models.dart';
import '../core/services/duty_discovery_service.dart';
import '../core/utils/duty_lifecycle_utils.dart';
import '../core/utils/emergency_duty_utils.dart';
import '../core/utils/geo_utils.dart';
import '../providers/location_provider.dart';

class DutyProvider extends ChangeNotifier {
  static const _openDutiesCacheKey = 'duty_open_cache_v1';

  final SupabaseClient _supabase = Supabase.instance.client;
  final DutyDiscoveryService _discoveryService = DutyDiscoveryService();

  // Subscriptions
  StreamSubscription? _applicationsSubscription;
  StreamSubscription? _completedDutiesSubscription;
  StreamSubscription? _upcomingDutiesSubscription;
  StreamSubscription? _savedDutiesSubscription;
  StreamSubscription? _appliedDutiesSubscription;
  StreamSubscription? _openDutiesSubscription;

  // State
  List<ApplicationModel> _applications = [];
  final List<DutyModel> _completedDuties = [];
  final List<DutyModel> _upcomingDuties = [];
  List<String> _savedDutiesIds = [];
  List<DutyModel> _openDuties = [];
  List<DutyWithDistance> _nearbyDuties = [];
  DutyDiscoveryFilters _discoveryFilters = const DutyDiscoveryFilters();
  DutySortOption _sortOption = DutySortOption.nearest;
  String _discoverySearchQuery = '';
  String? _selectedDutyId;
  bool _discoveryLoading = false;
  int _newDutiesCount = 0;
  final Set<String> _localAppliedDutyIds = {};
  bool _isOffline = false;
  List<DutyModel> _cachedOpenDuties = [];
  List<DutyWithDistance> _cachedNearbyDuties = [];

  bool _isLoading = false;

  // Counts
  int _pendingApplicationsCount = 0;
  int _acceptedApplicationsCount = 0;
  int _rejectedApplicationsCount = 0;
  int _shortlistedApplicationsCount = 0;
  int _completedApplicationsCount = 0;
  int _withdrawnApplicationsCount = 0;

  int _completedDutiesCount = 0;
  int _upcomingDutiesCount = 0;
  int _savedDutiesCount = 0;

  // Getters
  List<ApplicationModel> get applications => _applications;
  List<DutyModel> get completedDuties => _completedDuties;
  List<DutyModel> get upcomingDuties => _upcomingDuties;
  List<String> get savedDutiesIds => _savedDutiesIds;
  List<DutyModel> get openDuties => _openDuties;
  List<DutyWithDistance> get nearbyDuties => _nearbyDuties;
  DutyDiscoveryFilters get discoveryFilters => _discoveryFilters;
  DutySortOption get sortOption => _sortOption;
  String get discoverySearchQuery => _discoverySearchQuery;
  String? get selectedDutyId => _selectedDutyId;
  bool get discoveryLoading => _discoveryLoading;
  int get newDutiesCount => _newDutiesCount;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  List<DutyWithDistance> get cachedNearbyDuties => _cachedNearbyDuties;

  DutyModel? findDutyById(String dutyId) {
    for (final d in _openDuties) {
      if (d.id == dutyId) return d;
    }
    for (final item in _nearbyDuties) {
      if (item.duty.id == dutyId) return item.duty;
    }
    return null;
  }

  DutyWithDistance? dutyWithDistanceForId(
    String dutyId,
    LocationProvider location,
  ) {
    for (final item in _nearbyDuties) {
      if (item.duty.id == dutyId) return item;
    }
    final duty = findDutyById(dutyId);
    if (duty == null) return null;
    final center = location.searchLocation;
    double? dist;
    if (center != null && duty.hasCoordinates) {
      dist = distanceKm(
        center.latitude,
        center.longitude,
        duty.latitude!,
        duty.longitude!,
      );
    }
    return DutyWithDistance(duty: duty, distanceKm: dist);
  }

  List<DutyWithDistance> savedDutiesNearby(LocationProvider location) {
    final center = location.searchLocation;
    return _openDuties
        .where((d) => _savedDutiesIds.contains(d.id))
        .map((duty) {
          double? dist;
          if (center != null && duty.hasCoordinates) {
            dist = distanceKm(
              center.latitude,
              center.longitude,
              duty.latitude!,
              duty.longitude!,
            );
          }
          return DutyWithDistance(duty: duty, distanceKm: dist);
        })
        .toList();
  }

  List<DutyWithDistance> appliedDutiesNearby(LocationProvider location) {
    final now = DateTime.now();
    final appliedIds = _applications
        .where((a) => DutyLifecycleUtils.isActiveApplication(a, now))
        .map((a) => a.dutyId)
        .toSet();
    final center = location.searchLocation;
    return _allKnownDuties()
        .where((d) => appliedIds.contains(d.id))
        .where((d) {
          ApplicationModel? app;
          for (final a in _applications) {
            if (a.dutyId == d.id) {
              app = a;
              break;
            }
          }
          if (app == null) return false;
          return !DutyLifecycleUtils.isCompletedApplication(app, d, now);
        })
        .map((duty) {
      double? dist;
      if (center != null && duty.hasCoordinates) {
        dist = distanceKm(
          center.latitude,
          center.longitude,
          duty.latitude!,
          duty.longitude!,
        );
      }
      return DutyWithDistance(duty: duty, distanceKm: dist);
    }).toList();
  }

  List<DutyWithDistance> recommendedNearby(LocationProvider location) {
    final prev = _sortOption;
    _sortOption = DutySortOption.recommended;
    final list = List<DutyWithDistance>.from(regularNearby(location));
    _sortNearbyResults(list);
    _sortOption = prev;
    return list;
  }

  /// Active emergency duties within the user's selected radius, relevance-sorted.
  List<DutyWithDistance> emergencyNearby(
    LocationProvider location, {
    String? specialization,
  }) {
    final center = location.searchLocation;
    if (center == null) return [];

    final radiusKm = location.radiusKm;
    final results = <DutyWithDistance>[];
    for (final duty in _openDuties) {
      if (!EmergencyDutyUtils.isActiveEmergency(duty)) continue;
      if (!duty.hasCoordinates) continue;

      final dist = distanceKm(
        center.latitude,
        center.longitude,
        duty.latitude!,
        duty.longitude!,
      );
      if (!EmergencyDutyUtils.isWithinEmergencyRadius(dist, radiusKm)) continue;

      results.add(DutyWithDistance(duty: duty, distanceKm: dist));
    }
    EmergencyDutyUtils.sortByRelevance(results, userSpecialization: specialization);
    return results;
  }

  /// Nearby duties excluding active emergency postings (shown in red section).
  List<DutyWithDistance> regularNearby(LocationProvider location) {
    if (_nearbyDuties.isEmpty && location.searchLocation != null) {
      computeNearbyDuties(location);
    }
    final radiusKm = location.radiusKm;
    return _nearbyDuties.where((e) {
      if (!EmergencyDutyUtils.isActiveEmergency(e.duty)) return true;
      return !EmergencyDutyUtils.isWithinEmergencyRadius(e.distanceKm, radiusKm);
    }).toList();
  }

  void setOfflineMode(bool offline) {
    _isOffline = offline;
    if (offline && _openDuties.isEmpty && _cachedOpenDuties.isNotEmpty) {
      _openDuties = List.from(_cachedOpenDuties);
    }
    notifyListeners();
  }

  Future<void> restoreCachedDutiesFromDisk() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_openDutiesCacheKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      final duties = list
          .map((e) => DutyModel.fromMap(
                Map<String, dynamic>.from(e as Map),
                (e['id'] ?? '').toString(),
              ))
          .toList();
      if (duties.isEmpty) return;
      _cachedOpenDuties = duties;
      if (_openDuties.isEmpty) {
        _openDuties = List.from(duties);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('restoreCachedDutiesFromDisk: $e');
    }
  }

  void _cacheResults() {
    _cachedOpenDuties = List.from(_openDuties);
    _cachedNearbyDuties = List.from(_nearbyDuties);
    _persistOpenDutiesCache();
  }

  Future<void> _persistOpenDutiesCache() async {
    if (_openDuties.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = _openDuties.map((d) {
        final m = Map<String, dynamic>.from(d.toMap());
        m['id'] = d.id;
        return m;
      }).toList();
      await prefs.setString(_openDutiesCacheKey, jsonEncode(payload));
    } catch (e) {
      debugPrint('persistOpenDutiesCache: $e');
    }
  }

  List<DutyModel> _allKnownDuties() {
    final map = <String, DutyModel>{};
    for (final d in _cachedOpenDuties) {
      map[d.id] = d;
    }
    for (final d in _openDuties) {
      map[d.id] = d;
    }
    for (final item in _nearbyDuties) {
      map[item.duty.id] = item.duty;
    }
    return map.values.toList();
  }

  DutyModel? _dutyForApplication(ApplicationModel app) {
    for (final d in _allKnownDuties()) {
      if (d.id == app.dutyId) return d;
    }
    return DutyModel(
      id: app.dutyId,
      hospitalId: app.hospitalId,
      hospitalName: app.hospitalName,
      role: app.role,
      salary: app.salary ?? 0,
      location: app.location,
      dutyDate: app.dutyDate,
      startTime: app.dutyDate,
      endTime: app.dutyDate.add(const Duration(hours: 12)),
      status: DutyStatus.upcoming,
      createdAt: app.appliedAt,
    );
  }

  void _reconcileLifecycleLists() {
    _completedDuties.clear();
    _upcomingDuties.clear();
    final now = DateTime.now();

    for (final app in _applications) {
      final duty = _dutyForApplication(app);
      if (duty == null) continue;

      if (DutyLifecycleUtils.isCompletedApplication(app, duty, now)) {
        if (!_completedDuties.any((d) => d.id == duty.id)) {
          _completedDuties.add(
            duty.copyWith(status: DutyStatus.completed),
          );
        }
      } else if (DutyLifecycleUtils.isUpcomingApplication(app, duty, now)) {
        if (!_upcomingDuties.any((d) => d.id == duty.id)) {
          _upcomingDuties.add(duty);
        }
      }
    }

    _completedDutiesCount = _completedDuties.length;
    _upcomingDutiesCount = _upcomingDuties.length;
  }

  int get pendingApplicationsCount => _pendingApplicationsCount;
  int get acceptedApplicationsCount => _acceptedApplicationsCount;
  int get rejectedApplicationsCount => _rejectedApplicationsCount;
  int get shortlistedApplicationsCount => _shortlistedApplicationsCount;
  int get completedApplicationsCount => _completedApplicationsCount;
  int get withdrawnApplicationsCount => _withdrawnApplicationsCount;
  int get completedDutiesCount => _completedDutiesCount;
  int get upcomingDutiesCount => _upcomingDutiesCount;
  int get savedDutiesCount => _savedDutiesCount;

  bool isDutyApplied(String dutyId) {
    if (_localAppliedDutyIds.contains(dutyId)) return true;
    return _applications.any(
      (a) =>
          a.dutyId == dutyId &&
          a.status != ApplicationStatus.withdrawn &&
          a.status != ApplicationStatus.rejected,
    );
  }

  bool isDutySaved(String dutyId) => _savedDutiesIds.contains(dutyId);

  void selectDuty(String? dutyId) {
    _selectedDutyId = dutyId;
    notifyListeners();
  }

  void setDiscoverySearchQuery(String query) {
    _discoverySearchQuery = query;
    notifyListeners();
  }

  void setSortOption(DutySortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  void setDiscoveryFilters(DutyDiscoveryFilters filters) {
    _discoveryFilters = filters;
    notifyListeners();
  }

  void clearNewDutiesBanner() {
    _newDutiesCount = 0;
    notifyListeners();
  }

  Future<void> startDiscovery({LocationProvider? location}) async {
    _discoveryLoading = true;
    notifyListeners();

    await _openDutiesSubscription?.cancel();

    final center = location?.searchLocation;
    if (center != null) {
      final radius = location!.radiusKm;
      _openDutiesSubscription = _discoveryService
          .watchNearbyDuties(
            centerLat: center.latitude,
            centerLng: center.longitude,
            radiusKm: radius,
          )
          .listen(
        (duties) {
          final prevCount = _openDuties.length;
          _openDuties = duties;
          if (prevCount > 0 && duties.length > prevCount) {
            _newDutiesCount += duties.length - prevCount;
          }
          _discoveryLoading = false;
          notifyListeners();
        },
        onError: (e) async {
          debugPrint('Geo discovery stream error: $e');
          _openDuties = await _discoveryService.fetchNearbyDuties(
            centerLat: center.latitude,
            centerLng: center.longitude,
            radiusKm: radius,
          );
          _discoveryLoading = false;
          notifyListeners();
        },
      );

      try {
        _openDuties = await _discoveryService.fetchNearbyDuties(
          centerLat: center.latitude,
          centerLng: center.longitude,
          radiusKm: radius,
        );
      } catch (e) {
        debugPrint('Geo discovery fetch error: $e');
      } finally {
        _discoveryLoading = false;
        notifyListeners();
      }
      return;
    }

    _openDutiesSubscription = _discoveryService.watchOpenDuties().listen(
      (duties) {
        final prevCount = _openDuties.length;
        _openDuties = duties;
        if (prevCount > 0 && duties.length > prevCount) {
          _newDutiesCount += duties.length - prevCount;
        }
        _discoveryLoading = false;
        notifyListeners();
      },
      onError: (e) async {
        debugPrint('Discovery stream error: $e');
        _openDuties = await _discoveryService.fetchOpenDuties();
        _discoveryLoading = false;
        notifyListeners();
      },
    );

    try {
      _openDuties = await _discoveryService.fetchOpenDuties();
    } catch (e) {
      debugPrint('Discovery fetch error: $e');
    } finally {
      _discoveryLoading = false;
      notifyListeners();
    }
  }

  /// Re-runs geo-spatial discovery when search location or radius changes.
  Future<void> refreshDiscoveryForLocation(LocationProvider location) async {
    await startDiscovery(location: location);
    computeNearbyDuties(location);
  }

  List<DutyWithDistance> computeNearbyDuties(LocationProvider location) {
    final center = location.searchLocation;
    if (center == null) return [];

    final radius = location.radiusKm;
    final box = boundingBox(center.latitude, center.longitude, radius);
    final q = _discoverySearchQuery.trim().toLowerCase();

    var results = <DutyWithDistance>[];

    for (final duty in _openDuties) {
      if (DutyLifecycleUtils.isExpiredForDiscovery(duty)) continue;

      if (!duty.hasCoordinates) {
        // Duties without coords stay in general list but not geo-filtered map
        if (_discoveryFilters.isEmpty && q.isEmpty) {
          results.add(DutyWithDistance(duty: duty));
        }
        continue;
      }

      final lat = duty.latitude!;
      final lng = duty.longitude!;

      if (!isWithinBoundingBox(lat, lng, box)) continue;

      final dist = distanceKm(
        center.latitude,
        center.longitude,
        lat,
        lng,
      );
      if (dist > radius) continue;

      if (!_passesFilters(duty)) continue;

      if (q.isNotEmpty) {
        final haystack =
            '${duty.role} ${duty.hospitalName} ${duty.location} ${duty.specialization ?? ''}'
                .toLowerCase();
        if (!haystack.contains(q)) continue;
      }

      results.add(DutyWithDistance(duty: duty, distanceKm: dist));
    }

    _sortNearbyResults(results);
    _nearbyDuties = results;
    _cacheResults();
    return results;
  }

  bool _passesFilters(DutyModel duty) {
    final f = _discoveryFilters;
    if (f.verifiedHospitalsOnly && !duty.verified) return false;
    if (f.specializations.isNotEmpty &&
        !f.specializations.contains(duty.displaySpecialization)) {
      return false;
    }
    if (f.shifts.isNotEmpty && !f.shifts.contains(duty.displayShift)) {
      return false;
    }
    if (f.dutyTypes.isNotEmpty &&
        duty.dutyType != null &&
        !f.dutyTypes.contains(duty.dutyType)) {
      return false;
    }
    if (f.minPayout != null && duty.salary < f.minPayout!) return false;
    if (f.maxPayout != null && duty.salary > f.maxPayout!) return false;

    if (f.datePreset != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dutyDay = DateTime(
        duty.dutyDate.year,
        duty.dutyDate.month,
        duty.dutyDate.day,
      );
      switch (f.datePreset) {
        case 'today':
          if (dutyDay != today) return false;
        case 'tomorrow':
          if (dutyDay != today.add(const Duration(days: 1))) return false;
        case 'week':
          if (dutyDay.isBefore(today) ||
              dutyDay.isAfter(today.add(const Duration(days: 7)))) {
            return false;
          }
      }
    } else if (f.dateFilter != null) {
      final df = DateTime(
        f.dateFilter!.year,
        f.dateFilter!.month,
        f.dateFilter!.day,
      );
      final dutyDay = DateTime(
        duty.dutyDate.year,
        duty.dutyDate.month,
        duty.dutyDate.day,
      );
      if (dutyDay != df) return false;
    }

    return true;
  }

  void _sortNearbyResults(List<DutyWithDistance> list) {
    switch (_sortOption) {
      case DutySortOption.nearest:
        list.sort((a, b) {
          final ad = a.distanceKm ?? double.infinity;
          final bd = b.distanceKm ?? double.infinity;
          return ad.compareTo(bd);
        });
      case DutySortOption.highestPayout:
        list.sort((a, b) => b.duty.salary.compareTo(a.duty.salary));
      case DutySortOption.earliestDate:
        list.sort(
          (a, b) => a.duty.dutyDate.compareTo(b.duty.dutyDate),
        );
      case DutySortOption.latestPosted:
        list.sort(
          (a, b) => b.duty.createdAt.compareTo(a.duty.createdAt),
        );
      case DutySortOption.recommended:
        list.sort((a, b) {
          final aScore = (a.duty.verified ? 0 : 1000) +
              (a.distanceKm ?? 50) * 10 -
              a.duty.salary / 100;
          final bScore = (b.duty.verified ? 0 : 1000) +
              (b.distanceKm ?? 50) * 10 -
              b.duty.salary / 100;
          return aScore.compareTo(bScore);
        });
    }
  }

  List<DutyWithDistance> previewNearby(
    LocationProvider location, {
    int limit = 3,
  }) {
    return computeNearbyDuties(location).take(limit).toList();
  }

  Future<bool> applyForDuty(DutyWithDistance item) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return false;
    if (isDutyApplied(item.duty.id)) return false;

    try {
      await _supabase.from(SupabaseConstants.dutyApplications).insert({
        'userId': userId,
        'dutyId': item.duty.id,
        'hospitalId': item.duty.hospitalId,
        'hospitalName': item.duty.hospitalName,
        'role': item.duty.role,
        'location': item.duty.location,
        'dutyDate': item.duty.dutyDate.toIso8601String(),
        'salary': item.duty.salary,
        'status': ApplicationStatus.pending.name,
        'appliedAt': DateTime.now().toIso8601String(),
      });
      _localAppliedDutyIds.add(item.duty.id);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Apply duty error: $e');
      return false;
    }
  }

  Future<void> loadDutyData(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _applicationsSubscription?.cancel();
      _applicationsSubscription = _supabase
          .from(SupabaseConstants.dutyApplications)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .order('appliedAt', ascending: false)
          .listen((rows) {
            _applications = rows
                .map((doc) => ApplicationModel.fromMap(doc, (doc['id'] ?? '').toString()))
                .toList();

            _pendingApplicationsCount = 0;
            _acceptedApplicationsCount = 0;
            _rejectedApplicationsCount = 0;
            _shortlistedApplicationsCount = 0;
            _completedApplicationsCount = 0;
            _withdrawnApplicationsCount = 0;

            for (var app in _applications) {
              switch (app.status) {
                case ApplicationStatus.pending:
                  _pendingApplicationsCount++;
                  break;
                case ApplicationStatus.accepted:
                  _acceptedApplicationsCount++;
                  break;
                case ApplicationStatus.rejected:
                  _rejectedApplicationsCount++;
                  break;
                case ApplicationStatus.shortlisted:
                  _shortlistedApplicationsCount++;
                  break;
                case ApplicationStatus.completed:
                  _completedApplicationsCount++;
                  break;
                case ApplicationStatus.withdrawn:
                  _withdrawnApplicationsCount++;
                  break;
              }
            }
            _reconcileLifecycleLists();
            notifyListeners();
          });

      await _savedDutiesSubscription?.cancel();
      _savedDutiesSubscription = _supabase
          .from(SupabaseConstants.savedItems)
          .stream(primaryKey: ['id'])
          .eq('userId', userId)
          .listen((rows) {
            _savedDutiesIds = rows
                .where((doc) => doc['type'] == 'duty')
                .map((doc) => (doc['itemId'] as String?) ?? '')
                .where((id) => id.isNotEmpty)
                .toList();
            _savedDutiesCount = _savedDutiesIds.length;
            notifyListeners();
          });
    } catch (e) {
      debugPrint('Error loading duty data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> withdrawApplication(String applicationId) async {
    try {
      await _supabase.from(SupabaseConstants.dutyApplications).update({
        'status': ApplicationStatus.withdrawn.name,
        'updatedAt': DateTime.now().toIso8601String(),
      }).eq('id', applicationId);
    } catch (e) {
      debugPrint('Error withdrawing application: $e');
    }
  }

  Future<void> toggleSaveDuty(
    String dutyId,
    String title,
    String? location,
    double? salary,
  ) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    try {
      if (_savedDutiesIds.contains(dutyId)) {
        await _supabase
            .from(SupabaseConstants.savedItems)
            .delete()
            .eq('userId', userId)
            .eq('itemId', dutyId);
        _savedDutiesIds.remove(dutyId);
      } else {
        await _supabase.from(SupabaseConstants.savedItems).insert({
          'userId': userId,
          'type': 'duty',
          'itemId': dutyId,
          'title': title,
          'subtitle': location,
          'salary': salary,
          'savedAt': DateTime.now().toIso8601String(),
        });
        _savedDutiesIds.add(dutyId);
      }
      _savedDutiesCount = _savedDutiesIds.length;
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling save duty: $e');
    }
  }

  @override
  void dispose() {
    _applicationsSubscription?.cancel();
    _completedDutiesSubscription?.cancel();
    _upcomingDutiesSubscription?.cancel();
    _savedDutiesSubscription?.cancel();
    _appliedDutiesSubscription?.cancel();
    _openDutiesSubscription?.cancel();
    super.dispose();
  }
}
