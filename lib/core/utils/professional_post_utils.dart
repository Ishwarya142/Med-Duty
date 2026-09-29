import '../../models/community_post_model.dart';
import '../../models/post_visibility.dart';

class ProfessionalPostUtils {
  ProfessionalPostUtils._();

  static const String patientInfoReminder =
      'Do not share personally identifiable patient information.';

  static const List<String> discouragedSharingItems = [
    'Patient names',
    'Patient phone numbers',
    'Medical record numbers',
    'Addresses',
    'Identifiable photographs',
    'Hospital records',
    'Private medical documents',
  ];

  static bool canViewPost({
    required CommunityPostModel post,
    required String? viewerId,
    required bool isFollowingAuthor,
    required bool isOwner,
    bool isAuthorBlocked = false,
  }) {
    if (isOwner) return true;
    if (isAuthorBlocked) return false;
    if (post.hidden) return false;

    switch (post.visibility) {
      case PostVisibility.public:
        return true;
      case PostVisibility.followers:
        return viewerId != null && isFollowingAuthor;
      case PostVisibility.private:
        return false;
    }
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    return '${dateTime.day} ${_month(dateTime.month)} ${dateTime.year}';
  }

  static String _month(int m) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[(m - 1).clamp(0, 11)];
  }

  static String formatDuration(Map<String, dynamic>? meta) {
    if (meta == null) return '';
    final start = meta['startDate']?.toString();
    final end = meta['endDate']?.toString();
    final current = meta['currentlyWorking'] == true;
    if (start == null || start.isEmpty) return '';
    if (current) return '$start – Present';
    if (end != null && end.isNotEmpty) return '$start – $end';
    return start;
  }

  /// Detects potentially sensitive healthcare / patient information in content
  static bool containsSensitivePatientInfo(String content) {
    final lowerContent = content.toLowerCase();

    final sensitivePatterns = [
      // Phone numbers (Indian format +91 XXXXX XXXXX or standard 10-digit mobile)
      RegExp(r'(\+91[\-\s]?)?[6-9]\d{4}[\-\s]?\d{5}'),
      // General phone numbers
      RegExp(r'\+?\d{2,3}[-\s]?\d{5}[-\s]?\d{5}'),
      // Medical record numbers (MRN, UHID, IPD, OPD, Patient ID)
      RegExp(
        r'(mrn|uhid|ipd|opd|patient\s*id|medical\s*record|case\s*sheet|reg\s*no)[\s:#\-_.]*\d+',
        caseSensitive: false,
      ),
      // Date of birth patterns (DOB, DOB:, etc.)
      RegExp(
        r'(dob|date\s*of\s*birth|born\s*on)[\s:#\-_.]*\d{1,2}[/\-.]\d{1,2}[/\-.]\d{2,4}',
        caseSensitive: false,
      ),
      // Address / Bed / Room / Ward patterns
      RegExp(
        r'(bed|ward|room|flat|apartment|door|street|nagar|colony)[\s:#\-_.]*\d+',
        caseSensitive: false,
      ),
      // Explicit Patient Name identifiers
      RegExp(
        r'(patient\s*name|patient:|pt:|patient\s+is\s+called|named\s+mr|named\s+mrs|named\s+ms|patient\s+named)[\s:]+[A-Za-z]+',
        caseSensitive: false,
      ),
      // Aadhaar or Social Security / National ID numbers (12-digit format: XXXX-XXXX-XXXX)
      RegExp(r'\b\d{4}[-\s]\d{4}[-\s]\d{4}\b'),
      // Hospital private records reference
      RegExp(
        r'(discharge\s*summary\s*of|lab\s*report\s*for|biopsy\s*report\s*of|prescription\s*for)\s+[A-Za-z]+',
        caseSensitive: false,
      ),
    ];

    for (final pattern in sensitivePatterns) {
      if (pattern.hasMatch(lowerContent)) {
        return true;
      }
    }

    return false;
  }

  /// Returns a detailed warning message if sensitive patient info is detected
  static String? getSensitiveInfoWarning(String content) {
    if (containsSensitivePatientInfo(content)) {
      return 'Your content appears to contain potentially sensitive healthcare or patient information '
          '(e.g., patient names, phone numbers, MRN/UHID, addresses, or private medical documents).\n\n'
          'To protect patient privacy, please de-identify or remove any personally identifiable details before publishing.';
    }
    return null;
  }
}
