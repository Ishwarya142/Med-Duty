/// Keyword expansion for medical job search (e.g. cardio → cardiology).
class JobSearchUtils {
  JobSearchUtils._();

  static const _synonyms = <String, List<String>>{
    'cardio': ['cardiology', 'cardiologist', 'cardiac', 'heart'],
    'cardiac': ['cardiology', 'cardiologist', 'cardiac', 'icu'],
    'heart': ['cardiology', 'cardiologist', 'cardiac'],
    'ped': ['pediatric', 'paediatric', 'pediatrics', 'paediatrics', 'child'],
    'derma': ['dermatology', 'dermatologist', 'skin'],
    'neuro': ['neurology', 'neurologist', 'neurosurgery'],
    'ortho': ['orthopedic', 'orthopaedic', 'orthopedics'],
    'emerg': ['emergency', 'er', 'trauma'],
    'icu': ['intensive', 'critical care', 'icu'],
    'nurse': ['nursing', 'staff nurse', 'rn'],
    'doctor': ['physician', 'medical officer', 'resident', 'consultant'],
    'gp': ['general physician', 'general medicine', 'family medicine'],
    'research': ['clinical research', 'associate', 'cra'],
  };

  static List<String> expandQuery(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];

    final terms = <String>{q};
    for (final entry in _synonyms.entries) {
      if (q.contains(entry.key) || entry.key.contains(q)) {
        terms.addAll(entry.value);
      }
      for (final syn in entry.value) {
        if (syn.contains(q) || q.contains(syn)) {
          terms.add(entry.key);
          terms.addAll(entry.value);
        }
      }
    }
    return terms.toList();
  }

  static bool matchesJobSearch({
    required String query,
    required String title,
    required String hospitalName,
    required String location,
    required String specialization,
    List<String> skills = const [],
  }) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;

    final haystack =
        '$title $hospitalName $location $specialization ${skills.join(' ')}'
            .toLowerCase();

    if (haystack.contains(q)) return true;

    for (final term in expandQuery(q)) {
      if (haystack.contains(term)) return true;
    }
    return false;
  }
}
