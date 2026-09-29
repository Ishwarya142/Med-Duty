import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/constants/supabase_constants.dart';
import '../core/services/job_discovery_service.dart';
import '../core/services/recommended_jobs_service.dart';
import '../core/utils/geo_utils.dart';
import '../core/utils/job_search_utils.dart';
import '../models/job_application_model.dart';
import '../models/job_discovery_models.dart';
import '../models/job_model.dart';
import '../models/job_with_distance.dart';
import '../providers/location_provider.dart';
import '../providers/profile_provider.dart';

class JobProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  final JobDiscoveryService _discoveryService = JobDiscoveryService();

  StreamSubscription? _openJobsSubscription;
  StreamSubscription? _applicationsSubscription;
  StreamSubscription? _savedJobsSubscription;

  List<JobModel> _openJobs = [];
  List<JobWithDistance> _nearbyJobs = [];
  List<JobApplicationModel> _applications = [];
  List<String> _savedJobIds = [];
  JobDiscoveryFilters _filters = const JobDiscoveryFilters();
  JobSortOption _sortOption = JobSortOption.recommended;
  String _searchQuery = '';
  bool _loading = false;
  final Set<String> _localAppliedJobIds = {};
  LocationProvider? _lastLocation;

  List<JobModel> get openJobs => _openJobs;
  List<JobWithDistance> get nearbyJobs => _nearbyJobs;
  List<JobApplicationModel> get applications => _applications;
  List<String> get savedJobIds => _savedJobIds;
  JobDiscoveryFilters get filters => _filters;
  JobSortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;
  bool get loading => _loading;

  int get appliedJobsCount => _applications
      .where((a) => a.status != JobApplicationStatus.withdrawn)
      .length;
  int get savedJobsCount => _savedJobIds.length;

  JobModel? findJobById(String jobId) {
    for (final j in _openJobs) {
      if (j.id == jobId) return j;
    }
    return null;
  }

  JobWithDistance? jobWithDistanceForId(
    String jobId,
    LocationProvider location,
  ) {
    for (final item in _nearbyJobs) {
      if (item.job.id == jobId) return item;
    }
    final job = findJobById(jobId);
    if (job == null) return null;
    final center = location.searchLocation;
    double? dist;
    if (center != null && job.hasCoordinates) {
      dist = distanceKm(
        center.latitude,
        center.longitude,
        job.latitude!,
        job.longitude!,
      );
    }
    return JobWithDistance(job: job, distanceKm: dist);
  }

  bool isJobApplied(String jobId) {
    if (_localAppliedJobIds.contains(jobId)) return true;
    return _applications.any(
      (a) =>
          a.jobId == jobId &&
          a.status != JobApplicationStatus.withdrawn &&
          a.status != JobApplicationStatus.rejected,
    );
  }

  bool isJobSaved(String jobId) => _savedJobIds.contains(jobId);

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setFilters(JobDiscoveryFilters filters) {
    _filters = filters;
    notifyListeners();
  }

  void setSortOption(JobSortOption option) {
    _sortOption = option;
    notifyListeners();
  }

  Future<void> loadJobData(String userId) async {
    await _applicationsSubscription?.cancel();
    await _savedJobsSubscription?.cancel();

    _applicationsSubscription = _supabase
        .from(SupabaseConstants.jobApplications)
        .stream(primaryKey: ['id'])
        .eq('userId', userId)
        .listen((rows) {
      _applications = rows
          .map((d) => JobApplicationModel.fromMap(d, (d['id'] ?? '').toString()))
          .toList();
      notifyListeners();
    });

    _savedJobsSubscription = _supabase
        .from(SupabaseConstants.savedItems)
        .stream(primaryKey: ['id'])
        .eq('userId', userId)
        .listen((rows) {
      _savedJobIds = rows
          .where((d) => d['type'] == 'job')
          .map((d) => (d['itemId'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toList();
      notifyListeners();
    });
  }

  Future<void> startDiscovery({LocationProvider? location}) async {
    _loading = true;
    notifyListeners();

    await _openJobsSubscription?.cancel();

    _lastLocation = location;

    _openJobsSubscription = _discoveryService.watchOpenJobs().listen(
      (jobs) {
        _openJobs = jobs;
        _loading = false;
        if (_lastLocation != null) {
          computeNearbyJobs(_lastLocation!);
        } else {
          notifyListeners();
        }
      },
      onError: (e) async {
        debugPrint('Job discovery stream error: $e');
        _openJobs = await _discoveryService.fetchOpenJobs();
        _loading = false;
        notifyListeners();
      },
    );

    try {
      _openJobs = await _discoveryService.fetchOpenJobs();
    } catch (e) {
      debugPrint('Job discovery fetch error: $e');
    } finally {
      _loading = false;
      if (_lastLocation != null) {
        computeNearbyJobs(_lastLocation!);
      } else {
        notifyListeners();
      }
    }
  }

  Future<void> refreshForLocation(LocationProvider location) async {
    _lastLocation = location;
    await startDiscovery(location: location);
    computeNearbyJobs(location);
  }

  bool _isJobExpired(JobModel job) {
    if (job.status != JobStatus.open) return true;
    final deadline = job.applicationDeadline;
    if (deadline != null && deadline.isBefore(DateTime.now())) return true;
    return false;
  }

  List<JobWithDistance> computeNearbyJobs(LocationProvider location) {
    _lastLocation = location;
    final center = location.searchLocation;
    if (center == null) return [];

    final radius = location.radiusKm;
    final q = _searchQuery.trim();
    final results = <JobWithDistance>[];

    for (final job in _openJobs) {
      if (_isJobExpired(job)) continue;
      if (!_passesFilters(job)) continue;

      double? dist;
      if (job.hasCoordinates) {
        dist = distanceKm(
          center.latitude,
          center.longitude,
          job.latitude!,
          job.longitude!,
        );
        if (dist > radius) continue;
      }

      if (q.isNotEmpty &&
          !JobSearchUtils.matchesJobSearch(
            query: q,
            title: job.title,
            hospitalName: job.hospitalName,
            location: job.location,
            specialization: job.specialization,
            skills: job.skills,
          )) {
        continue;
      }

      results.add(JobWithDistance(job: job, distanceKm: dist));
    }

    _sortResults(results);
    _nearbyJobs = results;
    notifyListeners();
    return results;
  }

  List<JobWithDistance> recommendedNearby(
    LocationProvider location,
    ProfileProvider profile,
  ) {
    final center = location.searchLocation;
    if (center == null) return [];

    return RecommendedJobsService.build(
      centerLat: center.latitude,
      centerLng: center.longitude,
      currentRadiusKm: location.radiusKm,
      specialization: profile.specialization.isNotEmpty
          ? profile.specialization
          : profile.qualification,
      qualification: profile.qualification,
      experience: '${profile.experience}',
      locationLabel: location.locationLabel,
      excludeJobIds: _savedJobIds.toSet(),
      limit: 4,
    );
  }

  List<JobWithDistance> savedJobsNearby(LocationProvider location) {
    final center = location.searchLocation;
    return _openJobs.where((j) => _savedJobIds.contains(j.id)).map((job) {
      double? dist;
      if (center != null && job.hasCoordinates) {
        dist = distanceKm(
          center.latitude,
          center.longitude,
          job.latitude!,
          job.longitude!,
        );
      }
      return JobWithDistance(job: job, distanceKm: dist);
    }).toList();
  }

  List<JobWithDistance> appliedJobsNearby(LocationProvider location) {
    final appliedIds = _applications
        .where((a) => a.status != JobApplicationStatus.withdrawn)
        .map((a) => a.jobId)
        .toSet();
    final center = location.searchLocation;
    return _openJobs.where((j) => appliedIds.contains(j.id)).map((job) {
      double? dist;
      if (center != null && job.hasCoordinates) {
        dist = distanceKm(
          center.latitude,
          center.longitude,
          job.latitude!,
          job.longitude!,
        );
      }
      return JobWithDistance(job: job, distanceKm: dist);
    }).toList();
  }

  Future<bool> applyForJob(
    JobWithDistance item, {
    String? resumeUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;
    if (isJobApplied(item.job.id)) return false;

    final job = item.job;
    _localAppliedJobIds.add(job.id);
    notifyListeners();

    try {
      await _supabase.from(SupabaseConstants.jobApplications).insert({
        'userId': user.id,
        'jobId': job.id,
        'hospitalId': job.hospitalId,
        'hospitalName': job.hospitalName,
        'title': job.title,
        'location': job.location,
        'status': JobApplicationStatus.applied.name,
        'appliedAt': DateTime.now().toIso8601String(),
        'resumeUrl': resumeUrl,
        'salaryMin': job.salaryMin,
        'salaryMax': job.salaryMax,
        'applicationType': 'job',
      });
      return true;
    } catch (e) {
      debugPrint('applyForJob error: $e');
      _localAppliedJobIds.remove(job.id);
      notifyListeners();
      return false;
    }
  }

  Future<void> toggleSaveJob(JobModel job) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    if (_savedJobIds.contains(job.id)) {
      try {
        await _supabase
            .from(SupabaseConstants.savedItems)
            .delete()
            .eq('userId', user.id)
            .eq('itemId', job.id);
        _savedJobIds.remove(job.id);
      } catch (e) {
        debugPrint('toggleSaveJob error: $e');
      }
    } else {
      try {
        await _supabase.from(SupabaseConstants.savedItems).insert({
          'userId': user.id,
          'type': 'job',
          'itemId': job.id,
          'title': job.title,
          'subtitle': '${job.hospitalName} • ${job.employmentLabel}',
          'savedAt': DateTime.now().toIso8601String(),
        });
        _savedJobIds.add(job.id);
      } catch (e) {
        debugPrint('toggleSaveJob error: $e');
      }
    }
    notifyListeners();
  }

  bool _passesFilters(JobModel job) {
    final f = _filters;
    if (f.verifiedHospitalsOnly && !job.verified) return false;
    if (f.specializations.isNotEmpty &&
        !f.specializations.contains(job.specialization)) {
      return false;
    }
    if (f.employmentTypes.isNotEmpty &&
        !f.employmentTypes.contains(job.employmentType)) {
      return false;
    }
    if (f.workMode != null && job.workMode != f.workMode) return false;
    if (f.salaryMin != null && job.salaryMax < f.salaryMin!) return false;
    if (f.salaryMax != null && job.salaryMin > f.salaryMax!) return false;
    if (f.postedWithinDays != null) {
      final age = DateTime.now().difference(job.postedAt).inDays;
      if (age > f.postedWithinDays!) return false;
    }
    return true;
  }

  void _sortResults(List<JobWithDistance> list) {
    switch (_sortOption) {
      case JobSortOption.nearest:
        list.sort((a, b) =>
            (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
      case JobSortOption.newest:
        list.sort((a, b) => b.job.postedAt.compareTo(a.job.postedAt));
      case JobSortOption.salaryHigh:
        list.sort((a, b) => b.job.salaryMax.compareTo(a.job.salaryMax));
      case JobSortOption.recommended:
        list.sort((a, b) {
          final aScore = a.job.verified ? 1 : 0;
          final bScore = b.job.verified ? 1 : 0;
          if (aScore != bScore) return bScore.compareTo(aScore);
          return (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999);
        });
    }
  }

  @override
  void dispose() {
    _openJobsSubscription?.cancel();
    _applicationsSubscription?.cancel();
    _savedJobsSubscription?.cancel();
    super.dispose();
  }
}
