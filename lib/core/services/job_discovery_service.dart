import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../constants/supabase_constants.dart';
import '../utils/geo_utils.dart';
import '../utils/geohash_utils.dart';
import '../../models/job_model.dart';

/// Loads open jobs from Supabase with client-side geo filtering fallback.
class JobDiscoveryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<JobModel>> fetchOpenJobs() async {
    try {
      final data = await _supabase
          .from(SupabaseConstants.jobs)
          .select()
          .eq('status', JobStatus.open.name)
          .limit(150);

      final list = List<Map<String, dynamic>>.from(data);
      if (list.isNotEmpty) {
        return list
            .map((doc) => JobModel.fromMap(doc, (doc['id'] ?? '').toString()))
            .toList();
      }
    } catch (e) {
      debugPrint('JobDiscoveryService Supabase read: $e');
    }
    return _seedJobs();
  }

  Stream<List<JobModel>> watchOpenJobs() {
    try {
      return _supabase
          .from(SupabaseConstants.jobs)
          .stream(primaryKey: ['id'])
          .eq('status', JobStatus.open.name)
          .limit(150)
          .map((rows) {
        if (rows.isEmpty) return _seedJobs();
        return rows
            .map((doc) => JobModel.fromMap(doc, (doc['id'] ?? '').toString()))
            .toList();
      });
    } catch (e) {
      debugPrint('JobDiscoveryService stream: $e');
      return Stream.value(_seedJobs());
    }
  }

  List<JobModel> fetchOpenJobsSync() => _seedJobs();

  Future<List<JobModel>> fetchNearbyJobs({
    required double centerLat,
    required double centerLng,
    required double radiusKm,
  }) async {
    final all = await fetchOpenJobs();
    return all.where((job) {
      if (!job.hasCoordinates) return false;
      return isWithinRadiusKm(
        centerLat,
        centerLng,
        job.latitude!,
        job.longitude!,
        radiusKm,
      );
    }).toList();
  }

  List<JobModel> _seedJobs() {
    final now = DateTime.now();

    JobModel j({
      required String id,
      required String hospitalId,
      required String hospitalName,
      required String title,
      required String specialization,
      required EmploymentType employmentType,
      required double salaryMin,
      required double salaryMax,
      required String experienceRequired,
      required String qualification,
      required String location,
      required double lat,
      required double lng,
      int postedDaysAgo = 2,
      List<String>? skills,
      List<String>? responsibilities,
      List<String>? requirements,
      String? description,
      WorkMode workMode = WorkMode.onSite,
      bool verified = true,
    }) {
      return JobModel(
        id: id,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        title: title,
        specialization: specialization,
        employmentType: employmentType,
        workMode: workMode,
        salaryMin: salaryMin,
        salaryMax: salaryMax,
        experienceRequired: experienceRequired,
        qualification: qualification,
        location: location,
        description: description ??
            'Join $hospitalName as $title. Build your medical career with a leading healthcare institution.',
        responsibilities: responsibilities ??
            [
              'Patient care and clinical assessment',
              'Documentation and coordination',
              'Team collaboration',
            ],
        requirements: requirements ??
            [
              qualification,
              'Valid medical registration',
              experienceRequired,
            ],
        skills: skills ??
            [specialization, 'Patient Care', 'Clinical Assessment'],
        postedAt: now.subtract(Duration(days: postedDaysAgo)),
        applicationDeadline: now.add(const Duration(days: 30)),
        latitude: lat,
        longitude: lng,
        geohash: encodeGeohash(lat, lng),
        city: 'Chennai',
        state: 'Tamil Nadu',
        verified: verified,
      );
    }

    return [
      j(
        id: 'job_1',
        hospitalId: 'h_apollo',
        hospitalName: 'Apollo Hospitals',
        title: 'Junior Resident — General Medicine',
        specialization: 'General Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 80000,
        salaryMax: 100000,
        experienceRequired: '0–2 years',
        qualification: 'MBBS',
        location: 'Chennai',
        lat: 13.0604,
        lng: 80.2496,
        postedDaysAgo: 1,
      ),
      j(
        id: 'job_2',
        hospitalId: 'h_miot',
        hospitalName: 'MIOT International',
        title: 'Consultant Cardiologist',
        specialization: 'Cardiology',
        employmentType: EmploymentType.fullTime,
        salaryMin: 150000,
        salaryMax: 180000,
        experienceRequired: '8+ years',
        qualification: 'MD/DM Cardiology',
        location: 'Chennai',
        lat: 13.0358,
        lng: 80.1568,
        postedDaysAgo: 3,
        skills: ['Cardiology', 'Interventional Cardiology', 'Patient Care'],
      ),
      j(
        id: 'job_3',
        hospitalId: 'h_citycare',
        hospitalName: 'City Care Hospital',
        title: 'Medical Officer',
        specialization: 'General Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 70000,
        salaryMax: 70000,
        experienceRequired: '1–3 years',
        qualification: 'MBBS',
        location: 'Avadi, Chennai',
        lat: 13.1098,
        lng: 80.0945,
        postedDaysAgo: 4,
      ),
      j(
        id: 'job_4',
        hospitalId: 'h_apollo_avadi',
        hospitalName: 'Apollo Hospitals',
        title: 'Senior Resident — General Medicine',
        specialization: 'General Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 100000,
        salaryMax: 140000,
        experienceRequired: '2–5 years',
        qualification: 'MBBS, MD General Medicine',
        location: 'Chennai',
        lat: 13.1155,
        lng: 80.0980,
        postedDaysAgo: 2,
      ),
      j(
        id: 'job_5',
        hospitalId: 'h_kauvery',
        hospitalName: 'Kauvery Hospital',
        title: 'Pediatrician',
        specialization: 'Pediatrics',
        employmentType: EmploymentType.fullTime,
        salaryMin: 90000,
        salaryMax: 120000,
        experienceRequired: '3–5 years',
        qualification: 'MD Pediatrics',
        location: 'Alwarpet, Chennai',
        lat: 13.0339,
        lng: 80.2610,
        postedDaysAgo: 5,
      ),
      j(
        id: 'job_6',
        hospitalId: 'h_fortis',
        hospitalName: 'Fortis Malar Hospital',
        title: 'Anesthesiologist',
        specialization: 'Anesthesiology',
        employmentType: EmploymentType.fullTime,
        salaryMin: 120000,
        salaryMax: 150000,
        experienceRequired: '5+ years',
        qualification: 'MD Anesthesiology',
        location: 'Adyar, Chennai',
        lat: 13.0067,
        lng: 80.2206,
        postedDaysAgo: 6,
      ),
      j(
        id: 'job_7',
        hospitalId: 'h_sims',
        hospitalName: 'SIMS Hospital',
        title: 'Clinical Associate — Emergency Medicine',
        specialization: 'Emergency Medicine',
        employmentType: EmploymentType.partTime,
        salaryMin: 50000,
        salaryMax: 65000,
        experienceRequired: '1–3 years',
        qualification: 'MBBS',
        location: 'Vadapalani, Chennai',
        lat: 13.0501,
        lng: 80.2124,
        postedDaysAgo: 1,
      ),
      j(
        id: 'job_8',
        hospitalId: 'h_pims',
        hospitalName: 'PIMS Hospital',
        title: 'General Physician',
        specialization: 'General Physician',
        employmentType: EmploymentType.locum,
        salaryMin: 60000,
        salaryMax: 80000,
        experienceRequired: '2+ years',
        qualification: 'MBBS',
        location: 'Avadi, Chennai',
        lat: 13.1148,
        lng: 80.0982,
        postedDaysAgo: 3,
      ),
      j(
        id: 'job_9',
        hospitalId: 'h_global',
        hospitalName: 'Gleneagles Global Health City',
        title: 'Orthopedic Surgeon',
        specialization: 'Orthopedic Surgery',
        employmentType: EmploymentType.contract,
        salaryMin: 180000,
        salaryMax: 220000,
        experienceRequired: '7+ years',
        qualification: 'MS Orthopedics',
        location: 'Perumbakkam, Chennai',
        lat: 12.8972,
        lng: 80.2270,
        postedDaysAgo: 7,
      ),
      j(
        id: 'job_10',
        hospitalId: 'h_billroth',
        hospitalName: 'Billroth Hospital',
        title: 'Dermatologist',
        specialization: 'Dermatology',
        employmentType: EmploymentType.partTime,
        salaryMin: 80000,
        salaryMax: 100000,
        experienceRequired: '3+ years',
        qualification: 'MD Dermatology',
        location: 'Shenoy Nagar, Chennai',
        lat: 13.0456,
        lng: 80.2334,
        postedDaysAgo: 10,
      ),
      j(
        id: 'job_11',
        hospitalId: 'h_apollo_avadi',
        hospitalName: 'Apollo Clinic Avadi',
        title: 'Junior Resident',
        specialization: 'General Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 75000,
        salaryMax: 90000,
        experienceRequired: '0–2 years',
        qualification: 'MBBS',
        location: 'Avadi, Chennai',
        lat: 13.1142,
        lng: 80.0978,
        postedDaysAgo: 1,
      ),
      j(
        id: 'job_12',
        hospitalId: 'h_private',
        hospitalName: 'Private Hospital',
        title: 'Medical Officer',
        specialization: 'General Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 65000,
        salaryMax: 85000,
        experienceRequired: '1–3 years',
        qualification: 'MBBS',
        location: 'Avadi, Chennai',
        lat: 13.1125,
        lng: 80.1012,
        postedDaysAgo: 2,
      ),
      j(
        id: 'job_13',
        hospitalId: 'h_emergency',
        hospitalName: 'City Emergency Hospital',
        title: 'Emergency Medical Officer',
        specialization: 'Emergency Medicine',
        employmentType: EmploymentType.fullTime,
        salaryMin: 90000,
        salaryMax: 110000,
        experienceRequired: '2+ years',
        qualification: 'MBBS, ATLS',
        location: 'Ambattur, Chennai',
        lat: 13.0987,
        lng: 80.1612,
        postedDaysAgo: 1,
      ),
      j(
        id: 'job_14',
        hospitalId: 'h_icu',
        hospitalName: 'Care ICU Hospital',
        title: 'ICU Medical Officer',
        specialization: 'Critical Care',
        employmentType: EmploymentType.fullTime,
        salaryMin: 95000,
        salaryMax: 120000,
        experienceRequired: '3+ years',
        qualification: 'MBBS, ICU experience',
        location: 'Avadi, Chennai',
        lat: 13.1168,
        lng: 80.0955,
        postedDaysAgo: 2,
        skills: ['ICU', 'Critical Care', 'Ventilator Management'],
      ),
      j(
        id: 'job_15',
        hospitalId: 'h_nurse',
        hospitalName: 'PIMS Hospital',
        title: 'Staff Nurse',
        specialization: 'Nursing',
        employmentType: EmploymentType.fullTime,
        salaryMin: 25000,
        salaryMax: 35000,
        experienceRequired: '1+ years',
        qualification: 'BSc Nursing / GNM',
        location: 'Avadi, Chennai',
        lat: 13.1135,
        lng: 80.0991,
        postedDaysAgo: 3,
      ),
      j(
        id: 'job_16',
        hospitalId: 'h_research',
        hospitalName: 'MedResearch Chennai',
        title: 'Clinical Research Associate',
        specialization: 'Clinical Research',
        employmentType: EmploymentType.contract,
        salaryMin: 45000,
        salaryMax: 60000,
        experienceRequired: '1–2 years',
        qualification: 'Life Sciences / MBBS',
        location: 'Guindy, Chennai',
        lat: 13.0108,
        lng: 80.2124,
        postedDaysAgo: 4,
      ),
      j(
        id: 'job_17',
        hospitalId: 'h_duty',
        hospitalName: 'Metro Hospital',
        title: 'Hospital Duty Doctor',
        specialization: 'General Physician',
        employmentType: EmploymentType.locum,
        salaryMin: 50000,
        salaryMax: 70000,
        experienceRequired: '2+ years',
        qualification: 'MBBS',
        location: 'Avadi, Chennai',
        lat: 13.1102,
        lng: 80.1025,
        postedDaysAgo: 1,
      ),
      j(
        id: 'job_18',
        hospitalId: 'h_ped',
        hospitalName: 'Rainbow Children\'s Hospital',
        title: 'Paediatrician',
        specialization: 'Paediatrics',
        employmentType: EmploymentType.fullTime,
        salaryMin: 100000,
        salaryMax: 130000,
        experienceRequired: '4+ years',
        qualification: 'MD Paediatrics',
        location: 'Anna Nagar, Chennai',
        lat: 13.0850,
        lng: 80.2101,
        postedDaysAgo: 5,
      ),
    ];
  }
}
