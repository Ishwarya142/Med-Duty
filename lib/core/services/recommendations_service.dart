import 'dart:math' as math;

import '../../models/community_post_model.dart';
import '../../models/duty_model.dart';
import '../../models/duty_with_distance.dart';
import '../../models/job_model.dart';
import '../../models/job_with_distance.dart';
import '../../models/suggested_doctor_model.dart';
import '../../providers/profile_provider.dart';
import '../utils/geo_utils.dart';
import 'duty_discovery_service.dart';
import 'job_discovery_service.dart';
import 'suggested_doctors_service.dart';

/// Generic explainable recommendation wrapper.
class ExplainedRecommendation<T> {
  final T item;
  final String reason;
  final String categoryTag; // 'Recommended for You', 'Because you follow...', 'Near you', 'Based on your specialty'
  final double score;

  const ExplainedRecommendation({
    required this.item,
    required this.reason,
    required this.categoryTag,
    required this.score,
  });
}

/// Hospital / Clinic recommendation item.
class RecommendedHospital {
  final String id;
  final String name;
  final String type; // Hospital / Clinic / Multi-speciality
  final String location;
  final double? distanceKm;
  final String reason;
  final String categoryTag;
  final bool isVerified;
  final double rating;
  final int openDutiesCount;

  const RecommendedHospital({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    this.distanceKm,
    required this.reason,
    required this.categoryTag,
    this.isVerified = true,
    this.rating = 4.8,
    this.openDutiesCount = 0,
  });
}

/// Intelligent, deterministic recommendation engine using existing profile and domain data.
class RecommendationsService {
  RecommendationsService._();

  static final _dutyDiscovery = DutyDiscoveryService();
  static final _jobDiscovery = JobDiscoveryService();
  static final _doctorService = SuggestedDoctorsService();

  // ─── 1. RECOMMENDED DUTIES ──────────────────────────────────────────────────

  static List<ExplainedRecommendation<DutyWithDistance>> recommendDuties({
    required ProfileProvider profile,
    required double centerLat,
    required double centerLng,
    double radiusKm = 25.0,
    Set<String> excludeDutyIds = const {},
    int limit = 6,
  }) {
    final spec = profile.specialization.trim().toLowerCase();
    final skills = profile.skills.map((s) => s.toLowerCase()).toSet();
    final prefHospitalType = profile.preferredHospitalType.toLowerCase();
    final prefShift = profile.preferredShift.toLowerCase();
    final city = profile.currentCity.trim().toLowerCase();

    final allDuties = _dutyDiscovery.fetchOpenDutiesSync();
    final list = <ExplainedRecommendation<DutyWithDistance>>[];

    for (final duty in allDuties) {
      if (excludeDutyIds.contains(duty.id)) continue;
      if (duty.priority == DutyPriority.emergency) continue;

      double? dist;
      if (duty.hasCoordinates) {
        dist = distanceKm(centerLat, centerLng, duty.latitude!, duty.longitude!);
      }

      var score = 0.0;
      String reason = 'Recommended based on your activity';
      String tag = 'Recommended for You';

      final dutyRole = duty.role.toLowerCase();
      final dutySpec = (duty.specialization ?? '').toLowerCase();
      final dutyLoc = duty.location.toLowerCase();

      // Specialty signal
      if (spec.isNotEmpty && (dutyRole.contains(spec) || dutySpec.contains(spec))) {
        score += 90;
        reason = 'Based on your specialty in ${profile.specialization}';
        tag = 'Based on your specialty';
      }

      // Proximity signal
      if (dist != null && dist <= radiusKm) {
        score += math.max(0, 70 - (dist * 2));
        if (score < 90) {
          reason = 'Near you (${formatDistanceKm(dist)})';
          tag = 'Near you';
        }
      } else if (city.isNotEmpty && dutyLoc.contains(city)) {
        score += 40;
        if (score < 90) {
          reason = 'In your practice city (${profile.currentCity})';
          tag = 'Near you';
        }
      }

      // Skills signal
      for (final skill in skills) {
        if (dutyRole.contains(skill) || dutySpec.contains(skill)) {
          score += 25;
          if (tag == 'Recommended for You') {
            reason = 'Matches your clinical skill: $skill';
          }
        }
      }

      // Shift & hospital type preference
      if (prefShift.isNotEmpty && prefShift != 'any' && duty.displayShift.toLowerCase().contains(prefShift)) {
        score += 15;
      }
      if (prefHospitalType.isNotEmpty && prefHospitalType != 'both') {
        score += 10;
      }

      // Verified duty boost
      if (duty.verified) score += 10;
      score += (duty.salary / 1000);

      list.add(ExplainedRecommendation(
        item: DutyWithDistance(duty: duty, distanceKm: dist),
        reason: reason,
        categoryTag: tag,
        score: score,
      ));
    }

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }

  // ─── 2. RECOMMENDED JOBS ────────────────────────────────────────────────────

  static List<ExplainedRecommendation<JobWithDistance>> recommendJobs({
    required ProfileProvider profile,
    required double centerLat,
    required double centerLng,
    double radiusKm = 30.0,
    Set<String> excludeJobIds = const {},
    int limit = 5,
  }) {
    final spec = profile.specialization.trim().toLowerCase();
    final qual = profile.qualification.trim().toLowerCase();
    final expYears = profile.experience;
    final city = profile.currentCity.trim().toLowerCase();

    final allJobs = _jobDiscovery.fetchOpenJobsSync();
    final list = <ExplainedRecommendation<JobWithDistance>>[];

    for (final job in allJobs) {
      if (excludeJobIds.contains(job.id)) continue;
      if (job.status != JobStatus.open) continue;

      double? dist;
      if (job.hasCoordinates) {
        dist = distanceKm(centerLat, centerLng, job.latitude!, job.longitude!);
      }

      var score = 0.0;
      String reason = 'Recommended career opportunity';
      String tag = 'Recommended for You';

      final jobText = '${job.title} ${job.specialization} ${job.qualification}'.toLowerCase();

      if (spec.isNotEmpty && jobText.contains(spec)) {
        score += 95;
        reason = 'Based on your specialty in ${profile.specialization}';
        tag = 'Based on your specialty';
      }

      if (qual.isNotEmpty && jobText.contains(qual)) {
        score += 40;
      }

      if (expYears > 0) {
        score += 20;
        if (tag == 'Recommended for You') {
          reason = 'Matches your $expYears+ years experience';
        }
      }

      if (dist != null && dist <= radiusKm) {
        score += (50 - dist.clamp(0, 50));
        if (score < 90) {
          reason = 'Near your location (${formatDistanceKm(dist)})';
          tag = 'Near you';
        }
      } else if (city.isNotEmpty && job.location.toLowerCase().contains(city)) {
        score += 35;
      }

      if (job.verified) score += 15;
      score += (job.salaryMax / 20000);

      list.add(ExplainedRecommendation(
        item: JobWithDistance(job: job, distanceKm: dist),
        reason: reason,
        categoryTag: tag,
        score: score,
      ));
    }

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }

  // ─── 3. RECOMMENDED DOCTORS & COLLEAGUES ───────────────────────────────────

  static Future<List<ExplainedRecommendation<SuggestedDoctorModel>>> recommendDoctors({
    required ProfileProvider profile,
    int limit = 6,
  }) async {
    final spec = profile.specialization.trim().toLowerCase();
    final city = profile.currentCity.trim().toLowerCase();

    final doctors = await _doctorService.fetchSuggested();
    final list = <ExplainedRecommendation<SuggestedDoctorModel>>[];

    for (final doc in doctors) {
      var score = 0.0;
      String reason = 'Colleague in MedDuty network';
      String tag = 'Recommended for You';

      final docSpec = doc.specialization.toLowerCase();
      final docLoc = doc.location.toLowerCase();

      if (spec.isNotEmpty && docSpec.contains(spec)) {
        score += 80;
        reason = 'Practicing in ${doc.specialization}';
        tag = 'Based on your specialty';
      }

      if (city.isNotEmpty && docLoc.contains(city)) {
        score += 60;
        if (score < 80) {
          reason = 'Practicing near ${profile.currentCity}';
          tag = 'Near you';
        }
      }

      if (doc.mutualCount != null && doc.mutualCount! > 0) {
        score += doc.mutualCount! * 15;
        reason = 'Because you follow mutual colleagues (${doc.mutualCount} mutual)';
        tag = 'Because you follow...';
      }

      if (doc.isVerified) score += 10;

      list.add(ExplainedRecommendation(
        item: doc,
        reason: reason,
        categoryTag: tag,
        score: score,
      ));
    }

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }

  // ─── 4. RECOMMENDED HOSPITALS & CLINICS ───────────────────────────────────

  static List<RecommendedHospital> recommendHospitals({
    required ProfileProvider profile,
    required double centerLat,
    required double centerLng,
    int limit = 5,
  }) {
    final seedHospitals = <RecommendedHospital>[
      const RecommendedHospital(
        id: 'hosp_apollo_gr',
        name: 'Apollo Hospitals Greams Road',
        type: 'Multi-speciality Hospital',
        location: 'Greams Road, Thousand Lights, Chennai, Tamil Nadu',
        distanceKm: 8.5,
        reason: 'Leading tertiary medical center with active duties',
        categoryTag: 'Recommended for You',
        isVerified: true,
        rating: 4.9,
        openDutiesCount: 4,
      ),
      const RecommendedHospital(
        id: 'hosp_miot',
        name: 'MIOT International',
        type: 'Super Speciality Hospital',
        location: 'Manapakkam, Chennai, Tamil Nadu',
        distanceKm: 12.0,
        reason: 'Speciality center hiring clinical consultants',
        categoryTag: 'Based on your specialty',
        isVerified: true,
        rating: 4.8,
        openDutiesCount: 2,
      ),
      const RecommendedHospital(
        id: 'hosp_fortis_malr',
        name: 'Fortis Malar Hospital',
        type: 'Multi-speciality Hospital',
        location: 'Adyar, Chennai, Tamil Nadu',
        distanceKm: 14.2,
        reason: 'Recommended for emergency and ICU coverage',
        categoryTag: 'Recommended for You',
        isVerified: true,
        rating: 4.7,
        openDutiesCount: 3,
      ),
      const RecommendedHospital(
        id: 'hosp_kauvery',
        name: 'Kauvery Hospital',
        type: 'Multi-speciality Hospital',
        location: 'Alwarpet, Chennai, Tamil Nadu',
        distanceKm: 10.0,
        reason: 'Near your practice region with regular duty postings',
        categoryTag: 'Near you',
        isVerified: true,
        rating: 4.8,
        openDutiesCount: 5,
      ),
      const RecommendedHospital(
        id: 'hosp_sri_ramachandra',
        name: 'Sri Ramachandra Medical Centre',
        type: 'Teaching & Research Hospital',
        location: 'Porur, Chennai, Tamil Nadu',
        distanceKm: 9.8,
        reason: 'Academic healthcare institution with active peer network',
        categoryTag: 'Because you follow...',
        isVerified: true,
        rating: 4.9,
        openDutiesCount: 6,
      ),
    ];

    return seedHospitals.take(limit).toList();
  }

  // ─── 5. RECOMMENDED COMMUNITY POSTS ────────────────────────────────────────

  static List<ExplainedRecommendation<CommunityPostModel>> recommendCommunityPosts({
    required List<CommunityPostModel> allPosts,
    required ProfileProvider profile,
    int limit = 6,
  }) {
    final spec = profile.specialization.trim().toLowerCase();
    final list = <ExplainedRecommendation<CommunityPostModel>>[];

    for (final post in allPosts) {
      var score = 0.0;
      String reason = 'Clinical insight from medical community';
      String tag = 'Recommended for You';

      final content = post.content.toLowerCase();
      final cat = post.categoryLabel.toLowerCase();

      if (spec.isNotEmpty && (content.contains(spec) || cat.contains(spec))) {
        score += 85;
        reason = 'Relevant to your specialty in ${profile.specialization}';
        tag = 'Based on your specialty';
      }

      if (profile.isFollowingUser(post.authorId)) {
        score += 90;
        reason = 'Because you follow ${post.authorName}';
        tag = 'Because you follow...';
      }

      score += (post.likes * 3) + (post.commentsCount * 5);
      if (post.authorVerified) score += 15;

      list.add(ExplainedRecommendation(
        item: post,
        reason: reason,
        categoryTag: tag,
        score: score,
      ));
    }

    list.sort((a, b) => b.score.compareTo(a.score));
    return list.take(limit).toList();
  }
}
