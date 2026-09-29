import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/suggested_doctor_model.dart';
import '../constants/supabase_constants.dart';
import '../utils/account_status_utils.dart';

class SuggestedDoctorsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  static const _fallbackDoctors = [
    SuggestedDoctorModel(
      id: 'suggested_neha_verma',
      name: 'Dr. Neha Verma',
      qualification: 'MD (Paediatrics)',
      specialization: 'Paediatrician',
      hospital: 'Fortis Hospital',
      location: 'Delhi, India',
    ),
    SuggestedDoctorModel(
      id: 'suggested_rohan_mehta',
      name: 'Dr. Rohan Mehta',
      qualification: 'MD (Dermatology)',
      specialization: 'Dermatologist',
      hospital: 'Apollo Hospital',
      location: 'Delhi, India',
    ),
    SuggestedDoctorModel(
      id: 'suggested_priya_nair',
      name: 'Dr. Priya Nair',
      qualification: 'MS (Ortho)',
      specialization: 'Orthopaedic Surgeon',
      hospital: 'AIIMS Delhi',
      location: 'Delhi, India',
    ),
    SuggestedDoctorModel(
      id: 'suggested_amit_patel',
      name: 'Dr. Amit Patel',
      qualification: 'MS, General Surgery',
      specialization: 'General Surgeon',
      hospital: 'Max Healthcare',
      location: 'Delhi, India',
    ),
    SuggestedDoctorModel(
      id: 'suggested_ayesha_khan',
      name: 'Dr. Ayesha Khan',
      qualification: 'MD (Anaesthesia)',
      specialization: 'Anesthesiologist',
      hospital: 'AIIMS',
      location: 'Delhi, India',
    ),
    SuggestedDoctorModel(
      id: 'suggested_karan_patel',
      name: 'Dr. Karan Patel',
      qualification: 'MS (Ortho)',
      specialization: 'Orthopaedic Surgeon',
      hospital: 'Fortis Mumbai',
      location: 'Mumbai, India',
    ),
  ];

  Future<List<SuggestedDoctorModel>> fetchSuggested({
    String? specialization,
    String? hospital,
    String? city,
    String? searchQuery,
    SuggestedDoctorCategory category = SuggestedDoctorCategory.recommended,
  }) async {
    final currentId = _supabase.auth.currentUser?.id;
    try {
      var query = _supabase.from(SupabaseConstants.users).select();
      if (specialization != null && specialization.isNotEmpty) {
        query = query.eq('specialization', specialization);
      }
      final data = await query.limit(40);
      final list = List<Map<String, dynamic>>.from(data);

      var doctors = list
          .where((d) => (d['uid'] ?? d['id']) != currentId && AccountStatusUtils.isDiscoverable(d))
          .map((d) => SuggestedDoctorModel.fromMap((d['uid'] ?? d['id']).toString(), d))
          .toList();

      if (doctors.isEmpty) doctors = List.from(_fallbackDoctors);

      if (hospital != null && hospital.isNotEmpty) {
        doctors = doctors
            .where((d) => d.hospital.toLowerCase().contains(hospital.toLowerCase()))
            .toList();
      }
      if (city != null && city.isNotEmpty) {
        doctors = doctors
            .where((d) => d.location.toLowerCase().contains(city.toLowerCase()))
            .toList();
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        doctors = doctors.where((d) {
          return d.name.toLowerCase().contains(q) ||
              d.specialization.toLowerCase().contains(q) ||
              d.hospital.toLowerCase().contains(q) ||
              d.location.toLowerCase().contains(q);
        }).toList();
      }

      return doctors.isEmpty ? List.from(_fallbackDoctors) : doctors;
    } catch (_) {
      var doctors = List<SuggestedDoctorModel>.from(_fallbackDoctors);
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        doctors = doctors
            .where(
              (d) =>
                  d.name.toLowerCase().contains(q) ||
                  d.specialization.toLowerCase().contains(q),
            )
            .toList();
      }
      return doctors;
    }
  }
}
