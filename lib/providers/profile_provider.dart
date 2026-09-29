import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/services/supabase_adapters.dart';
import '../core/constants/supabase_constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../models/post_visibility.dart';

class Resume {
  final String id;
  final String name;
  final String url;
  final DateTime uploadedAt;

  Resume({
    required this.id,
    required this.name,
    required this.url,
    required this.uploadedAt,
  });

  factory Resume.fromMap(Map<String, dynamic> map, String id) {
    return Resume(
      id: id,
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'url': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
    };
  }
}

enum DocumentVerificationStatus { pending, verified, rejected }

class Document {
  final String id;
  final String
  type; // e.g., 'medical_license', 'certificate', 'government_id', 'research_paper', 'resume', 'other'
  final String name;
  final String url;
  final DateTime uploadedAt;
  final DocumentVerificationStatus verificationStatus;
  final DateTime? verifiedAt;
  final String? verifiedBy;
  final String? rejectionReason;

  Document({
    required this.id,
    required this.type,
    required this.name,
    required this.url,
    required this.uploadedAt,
    this.verificationStatus = DocumentVerificationStatus.pending,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectionReason,
  });

  factory Document.fromMap(Map<String, dynamic> map, String id) {
    return Document(
      id: id,
      type: map['type'] ?? '',
      name: map['name'] ?? '',
      url: map['url'] ?? '',
      uploadedAt: (map['uploadedAt'] as Timestamp).toDate(),
      verificationStatus: DocumentVerificationStatus.values.firstWhere(
        (e) => e.name == (map['verificationStatus'] ?? 'pending'),
        orElse: () => DocumentVerificationStatus.pending,
      ),
      verifiedAt: map['verifiedAt'] != null
          ? (map['verifiedAt'] as Timestamp).toDate()
          : null,
      verifiedBy: map['verifiedBy'],
      rejectionReason: map['rejectionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'name': name,
      'url': url,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'verificationStatus': verificationStatus.name,
      'verifiedAt': verifiedAt != null ? Timestamp.fromDate(verifiedAt!) : null,
      'verifiedBy': verifiedBy,
      'rejectionReason': rejectionReason,
    };
  }
}

class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory Review.fromMap(Map<String, dynamic> map, String id) {
    return Review(
      id: id,
      reviewerId: map['reviewerId'] ?? '',
      reviewerName: map['reviewerName'] ?? '',
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

enum Proficiency { basic, intermediate, fluent, native }

class LanguageWithProficiency {
  final String name;
  final Proficiency proficiency;

  LanguageWithProficiency({
    required this.name,
    this.proficiency = Proficiency.fluent,
  });

  factory LanguageWithProficiency.fromMap(Map<String, dynamic> map) {
    return LanguageWithProficiency(
      name: map['name'] ?? '',
      proficiency: Proficiency.values.firstWhere(
        (e) => e.name == (map['proficiency'] ?? 'fluent'),
        orElse: () => Proficiency.fluent,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'proficiency': proficiency.name};
  }
}

class SkillWithProficiency {
  final String name;
  final Proficiency proficiency;
  final int endorsements;

  SkillWithProficiency({
    required this.name,
    this.proficiency = Proficiency.fluent,
    this.endorsements = 0,
  });

  factory SkillWithProficiency.fromMap(Map<String, dynamic> map) {
    return SkillWithProficiency(
      name: map['name'] ?? '',
      proficiency: Proficiency.values.firstWhere(
        (e) => e.name == (map['proficiency'] ?? 'fluent'),
        orElse: () => Proficiency.fluent,
      ),
      endorsements: map['endorsements'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'proficiency': proficiency.name,
      'endorsements': endorsements,
    };
  }
}

class Qualification {
  final String id;
  final String degree;
  final String university;
  final int year;
  final String? supportingDocUrl;
  final String? supportingDocName;

  Qualification({
    required this.id,
    required this.degree,
    required this.university,
    required this.year,
    this.supportingDocUrl,
    this.supportingDocName,
  });

  factory Qualification.fromMap(Map<String, dynamic> map, String id) {
    return Qualification(
      id: id,
      degree: map['degree'] ?? '',
      university: map['university'] ?? '',
      year: map['year'] ?? DateTime.now().year,
      supportingDocUrl: map['supportingDocUrl'],
      supportingDocName: map['supportingDocName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'university': university,
      'year': year,
      'supportingDocUrl': supportingDocUrl,
      'supportingDocName': supportingDocName,
    };
  }
}

class ExperienceEntry {
  final String id;
  final String hospital;
  final String department;
  final String designation;
  final int startYear;
  final int? endYear; // null if current
  final String? description;

  ExperienceEntry({
    required this.id,
    required this.hospital,
    required this.department,
    required this.designation,
    required this.startYear,
    this.endYear,
    this.description,
  });

  bool get isCurrent => endYear == null;

  factory ExperienceEntry.fromMap(Map<String, dynamic> map, String id) {
    return ExperienceEntry(
      id: id,
      hospital: map['hospital'] ?? '',
      department: map['department'] ?? '',
      designation: map['designation'] ?? '',
      startYear: map['startYear'] ?? DateTime.now().year,
      endYear: map['endYear'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hospital': hospital,
      'department': department,
      'designation': designation,
      'startYear': startYear,
      'endYear': endYear,
      'description': description,
    };
  }
}

class MedicalRegistration {
  final String number;
  final String council;
  final String state;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final bool isVerified;
  final bool renewalReminder;

  MedicalRegistration({
    this.number = '',
    this.council = '',
    this.state = '',
    this.issueDate,
    this.expiryDate,
    this.isVerified = false,
    this.renewalReminder = false,
  });

  factory MedicalRegistration.fromMap(Map<String, dynamic>? map) {
    if (map == null) return MedicalRegistration();
    return MedicalRegistration(
      number: map['number'] ?? '',
      council: map['council'] ?? '',
      state: map['state'] ?? '',
      issueDate: map['issueDate'] != null
          ? (map['issueDate'] as Timestamp).toDate()
          : null,
      expiryDate: map['expiryDate'] != null
          ? (map['expiryDate'] as Timestamp).toDate()
          : null,
      isVerified: map['isVerified'] ?? false,
      renewalReminder: map['renewalReminder'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'council': council,
      'state': state,
      'issueDate': issueDate != null ? Timestamp.fromDate(issueDate!) : null,
      'expiryDate': expiryDate != null ? Timestamp.fromDate(expiryDate!) : null,
      'isVerified': isVerified,
      'renewalReminder': renewalReminder,
    };
  }
}

class ProfileProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  StreamSubscription? _profileSubscription;
  StreamSubscription? _documentsSubscription;
  StreamSubscription? _reviewsSubscription;
  StreamSubscription? _followersSubscription;
  StreamSubscription? _followingSubscription;

  Set<String> _followingUserIds = {};
  String? _localProfilePicPath;
  String? _localCoverPicPath;

  // Upload progress
  double _uploadProgress = 0.0;
  String? _uploadError;
  bool _uploadSuccess = false;

  // Personal Information
  String _name = '';
  String _bio = '';
  String _phone = '';
  String _profilePic = '';
  String _coverPic = '';
  String? _gender;
  DateTime? _dateOfBirth;
  String _email = '';
  String _recoveryEmail = '';
  bool _recoveryEmailVerified = false;
  bool _phoneVerified = false;
  String _address = '';
  String _currentCity = '';
  String _state = '';
  String _country = '';

  // Professional Information
  String _medicalRegistrationNumber = '';
  String _medicalCouncil = '';
  String _qualification = '';
  String _degree = '';
  String _specialization = '';
  String _department = '';
  int _experience = 0;
  String _currentHospital = '';
  String _previousHospitals = '';
  double _consultationFee = 0.0;

  // Availability
  bool _availableForDuties = true;
  bool _emergencyAvailable = false;
  List<String> _workingDays = [];
  String _workingHours = '';
  String _preferredShift = '';
  int _preferredDutyDistance = 50; // km
  String _preferredHospitalType = '';

  // Location
  double? _currentLatitude;
  double? _currentLongitude;
  double? _homeLatitude;
  double? _homeLongitude;
  int _preferredWorkingRadius = 50; // km

  // Languages
  List<String> _languages = ['English'];
  List<LanguageWithProficiency> _languagesWithProficiency = [];

  // Skills
  List<String> _skills = [];
  List<SkillWithProficiency> _skillsWithProficiency = [];

  // Qualifications
  List<Qualification> _qualifications = [];

  // Experience
  List<ExperienceEntry> _experienceEntries = [];

  // Medical Registration
  MedicalRegistration _medicalRegistration = MedicalRegistration();

  // About Me extras
  List<String> _achievements = [];
  List<String> _interests = [];

  // Specialization
  List<String> _secondarySpecializations = [];
  String? _superSpecialization;

  // Certificates/Documents
  List<Document> _documents = [];
  int _documentsCount = 0;

  // Social Links
  String _linkedinUrl = '';
  String _researchgateUrl = '';
  String _orcidUrl = '';
  String _websiteUrl = '';

  // Resume
  Resume? _resume;

  // Reviews
  List<Review> _reviews = [];
  double _averageRating = 0.0;
  int _reviewsCount = 0;

  // Community Stats
  int _followersCount = 0;
  int _followingCount = 0;

  // Privacy Settings
  ProfilePrivacy _profilePrivacy = ProfilePrivacy.public;
  bool _profileVisibility = true;
  bool _phoneVisibility = false;
  bool _allowMessages = true;
  bool _allowReviews = true;
  bool _followRequestRequired = false;

  bool _isLoading = false;
  bool _isUploading = false;

  // Getters - Personal
  String get name => _name;
  String get bio => _bio;
  String get phone => _phone;
  String get profilePic => _profilePic;
  String get coverPic => _coverPic;
  String? get gender => _gender;
  DateTime? get dateOfBirth => _dateOfBirth;
  String get email => _email;
  String get recoveryEmail => _recoveryEmail;
  bool get recoveryEmailVerified => _recoveryEmailVerified;
  bool get phoneVerified => _phoneVerified;
  String get address => _address;
  String get currentCity => _currentCity;
  String get state => _state;
  String get country => _country;

  // Getters - Professional
  String get medicalRegistrationNumber => _medicalRegistrationNumber;
  String get medicalCouncil => _medicalCouncil;
  String get qualification => _qualification;
  String get degree => _degree;
  String get specialization => _specialization;
  String get department => _department;
  int get experience => _experience;
  String get currentHospital => _currentHospital;
  String get previousHospitals => _previousHospitals;
  double get consultationFee => _consultationFee;

  // Getters - Availability
  bool get availableForDuties => _availableForDuties;
  bool get emergencyAvailable => _emergencyAvailable;
  List<String> get workingDays => _workingDays;
  String get workingHours => _workingHours;
  String get preferredShift => _preferredShift;
  int get preferredDutyDistance => _preferredDutyDistance;
  String get preferredHospitalType => _preferredHospitalType;

  // Getters - Location
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;
  double? get homeLatitude => _homeLatitude;
  double? get homeLongitude => _homeLongitude;
  int get preferredWorkingRadius => _preferredWorkingRadius;

  // Getters - Languages, Skills, Documents
  List<String> get languages => _languages;
  List<LanguageWithProficiency> get languagesWithProficiency =>
      _languagesWithProficiency;
  List<String> get skills => _skills;
  List<SkillWithProficiency> get skillsWithProficiency =>
      _skillsWithProficiency;
  List<Document> get documents => _documents;

  // Getters - Qualifications, Experience
  List<Qualification> get qualifications => _qualifications;
  List<ExperienceEntry> get experienceEntries => _experienceEntries;

  // Getters - Medical Registration
  MedicalRegistration get medicalRegistration => _medicalRegistration;

  // Getters - About Me extras
  List<String> get achievements => _achievements;
  List<String> get interests => _interests;

  // Getters - Specialization
  List<String> get secondarySpecializations => _secondarySpecializations;
  String? get superSpecialization => _superSpecialization;

  // Getters - Social
  String get linkedinUrl => _linkedinUrl;
  String get researchgateUrl => _researchgateUrl;
  String get orcidUrl => _orcidUrl;
  String get websiteUrl => _websiteUrl;

  // Getters - Others
  Resume? get resume => _resume;
  List<Review> get reviews => _reviews;
  double get averageRating => _averageRating;
  int get reviewsCount => _reviewsCount;
  int get documentsCount => _documentsCount;
  Set<String> get followingUserIds => _followingUserIds;
  bool isFollowingUser(String userId) => _followingUserIds.contains(userId);
  int get followersCount => _followersCount;
  int get followingCount => _followingCount;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get uploadError => _uploadError;
  bool get uploadSuccess => _uploadSuccess;
  String? get localProfilePicPath => _localProfilePicPath;
  String? get localCoverPicPath => _localCoverPicPath;

  // Privacy Getters
  ProfilePrivacy get profilePrivacy => _profilePrivacy;
  bool get profileVisibility => _profileVisibility;
  bool get phoneVisibility => _phoneVisibility;
  bool get allowMessages => _allowMessages;
  bool get allowReviews => _allowReviews;
  bool get followRequestRequired => _followRequestRequired;

  /// Returns true only if medical registration is verified or verified document exists
  bool get isVerifiedProfessional =>
      _medicalRegistration.isVerified ||
      _documents.any((d) => d.verificationStatus == DocumentVerificationStatus.verified);

  Future<void> loadReviews() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      // Reviews are already loaded in loadProfile
    }
  }

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();

    // Load locally saved images first for instant preview
    await loadLocalImages();
    try {
      // Profile listener
      _profileSubscription = _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .listen((doc) {
            if (doc.exists) {
              final data = doc.data()!;
              // Personal
              _name = data['name'] ?? '';
              _bio = data['bio'] ?? '';
              _phone = data['phone'] ?? '';
              _profilePic = data['profilePhoto'] ?? '';
              _coverPic = data['coverPhoto'] ?? '';
              final genderData = data['gender'] as String?;
              _gender = genderData?.isEmpty == true ? null : genderData;
              _dateOfBirth = data['dateOfBirth'] != null
                  ? (data['dateOfBirth'] as Timestamp).toDate()
                  : null;
              _email = data['email'] ?? '';
              _recoveryEmail = data['recoveryEmail'] ?? '';
              _recoveryEmailVerified = data['recoveryEmailVerified'] == true;
              _phoneVerified = data['phoneVerified'] == true;
              _address = data['address'] ?? '';
              _currentCity = data['currentCity'] ?? '';
              _state = data['state'] ?? '';
              _country = data['country'] ?? '';

              // Professional
              _medicalRegistrationNumber =
                  data['medicalRegistrationNumber'] ?? '';
              _medicalCouncil = data['medicalCouncil'] ?? '';
              _qualification = data['qualification'] ?? '';
              _degree = data['degree'] ?? '';
              _specialization = data['specialization'] ?? '';
              _superSpecialization = data['superSpecialization'] ?? '';
              _department = data['department'] ?? '';
              _experience = data['experience'] ?? 0;
              _currentHospital = data['currentHospital'] ?? '';
              _previousHospitals = data['previousHospitals'] ?? '';
              _consultationFee =
                  (data['consultationFee'] as num?)?.toDouble() ?? 0.0;

              // Availability
              _availableForDuties = data['availableForDuties'] ?? true;
              _emergencyAvailable = data['emergencyAvailable'] ?? false;
              _workingDays = List<String>.from(data['workingDays'] ?? []);
              _workingHours = data['workingHours'] ?? '';
              _preferredShift = data['preferredShift'] ?? '';
              _preferredDutyDistance = data['preferredDutyDistance'] ?? 50;
              _preferredHospitalType = data['preferredHospitalType'] ?? '';

              // Location
              _currentLatitude = (data['currentLatitude'] as num?)?.toDouble();
              _currentLongitude = (data['currentLongitude'] as num?)
                  ?.toDouble();
              _homeLatitude = (data['homeLatitude'] as num?)?.toDouble();
              _homeLongitude = (data['homeLongitude'] as num?)?.toDouble();
              _preferredWorkingRadius = data['preferredWorkingRadius'] ?? 50;

              // Languages, Skills
              _languages = List<String>.from(data['languages'] ?? ['English']);
              _skills = List<String>.from(data['skills'] ?? []);

              // Social
              _linkedinUrl = data['linkedinUrl'] ?? '';
              _researchgateUrl = data['researchgateUrl'] ?? '';
              _orcidUrl = data['orcidUrl'] ?? '';
              _websiteUrl = data['websiteUrl'] ?? '';

              // Rating
              _averageRating = (data['rating'] as num?)?.toDouble() ?? 0.0;

              // Privacy Settings
              _profileVisibility = data['profileVisibility'] ?? true;
              _phoneVisibility = data['phoneVisibility'] ?? false;
              _allowMessages = data['allowMessages'] ?? true;
              _allowReviews = data['allowReviews'] ?? true;
              _followRequestRequired = data['followRequestRequired'] ?? false;
              if (data['profilePrivacy'] != null) {
                _profilePrivacy = ProfilePrivacyX.fromString(data['profilePrivacy'].toString());
              } else {
                _profilePrivacy = _profileVisibility ? ProfilePrivacy.public : ProfilePrivacy.private;
              }
              notifyListeners();
            }
          });

      // Resume listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('resume')
          .limit(1)
          .snapshots()
          .listen((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              _resume = Resume.fromMap(
                snapshot.docs.first.data(),
                snapshot.docs.first.id,
              );
            } else {
              _resume = null;
            }
            notifyListeners();
          });

      // Documents listener
      _documentsSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .snapshots()
          .listen((snapshot) {
            _documents = snapshot.docs
                .map((doc) => Document.fromMap(doc.data(), doc.id))
                .toList();
            _documentsCount = _documents.length;
            notifyListeners();
          });

      // Reviews listener
      _reviewsSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('reviews')
          .orderBy('createdAt', descending: true)
          .snapshots()
          .listen((snapshot) {
            _reviews = snapshot.docs
                .map((doc) => Review.fromMap(doc.data(), doc.id))
                .toList();
            _reviewsCount = _reviews.length;
            notifyListeners();
          });

      // Followers listener (count)
      _followersSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('followers')
          .snapshots()
          .listen((snapshot) {
            _followersCount = snapshot.size;
            notifyListeners();
          });

      // Following listener (count + ids)
      _followingSubscription = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .snapshots()
          .listen((snapshot) {
            _followingCount = snapshot.size;
            _followingUserIds = snapshot.docs.map((d) => d.id).toSet();
            notifyListeners();
          });

      // Qualifications listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('qualifications')
          .orderBy('year', descending: true)
          .snapshots()
          .listen((snapshot) {
            _qualifications = snapshot.docs
                .map((doc) => Qualification.fromMap(doc.data(), doc.id))
                .toList();
            notifyListeners();
          });

      // Experience listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('experience')
          .orderBy('startYear', descending: true)
          .snapshots()
          .listen((snapshot) {
            _experienceEntries = snapshot.docs
                .map((doc) => ExperienceEntry.fromMap(doc.data(), doc.id))
                .toList();
            notifyListeners();
          });

      // Languages with proficiency listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .snapshots()
          .listen((snapshot) {
            _languagesWithProficiency = snapshot.docs
                .map((doc) => LanguageWithProficiency.fromMap(doc.data()))
                .toList();
            _languages = _languagesWithProficiency.map((l) => l.name).toList();
            notifyListeners();
          });

      // Skills with proficiency listener
      _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .snapshots()
          .listen((snapshot) {
            _skillsWithProficiency = snapshot.docs
                .map((doc) => SkillWithProficiency.fromMap(doc.data()))
                .toList();
            _skills = _skillsWithProficiency.map((s) => s.name).toList();
            notifyListeners();
          });

      // Medical registration listener
      _firestore.collection('users').doc(userId).snapshots().listen((doc) {
        if (doc.exists) {
          _medicalRegistration = MedicalRegistration.fromMap(
            doc.data()?['medicalRegistration'],
          );
          _achievements = List<String>.from(doc.data()?['achievements'] ?? []);
          _interests = List<String>.from(doc.data()?['interests'] ?? []);
          _secondarySpecializations = List<String>.from(
            doc.data()?['secondarySpecializations'] ?? [],
          );
          _superSpecialization = doc.data()?['superSpecialization'];

          // Privacy settings
          _profileVisibility = doc.data()?['profileVisibility'] ?? true;
          _phoneVisibility = doc.data()?['phoneVisibility'] ?? false;
          _allowMessages = doc.data()?['allowMessages'] ?? true;
          _allowReviews = doc.data()?['allowReviews'] ?? true;
          _followRequestRequired = doc.data()?['followRequestRequired'] ?? false;
        }
        notifyListeners();
      });
    } catch (e) {
      debugPrint('Error loading profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    _documentsSubscription?.cancel();
    _reviewsSubscription?.cancel();
    _followersSubscription?.cancel();
    _followingSubscription?.cancel();
    super.dispose();
  }

  // Load locally saved images
  Future<void> loadLocalImages() async {
    final prefs = await SharedPreferences.getInstance();
    _localProfilePicPath = prefs.getString('local_profile_pic');
    _localCoverPicPath = prefs.getString('local_cover_pic');
    notifyListeners();
  }

  // Save image locally
  Future<void> _saveImageLocally(String key, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, path);
    if (key == 'local_profile_pic') {
      _localProfilePicPath = path;
    } else if (key == 'local_cover_pic') {
      _localCoverPicPath = path;
    }
    notifyListeners();
  }

  // Reset upload state
  void resetUploadState() {
    _uploadProgress = 0.0;
    _uploadError = null;
    _uploadSuccess = false;
    notifyListeners();
  }

  // Validate image format
  bool _isValidImageFormat(String fileName, String? mimeType) {
    final lowerFileName = fileName.toLowerCase();
    final lowerMimeType = mimeType?.toLowerCase() ?? '';
    return lowerFileName.endsWith('.jpg') ||
        lowerFileName.endsWith('.jpeg') ||
        lowerFileName.endsWith('.png') ||
        lowerMimeType.contains('jpeg') ||
        lowerMimeType.contains('jpg') ||
        lowerMimeType.contains('png');
  }

  // Crop image helper
  Future<CroppedFile?> _cropImage(
    String imagePath, {
    bool isProfile = true,
  }) async {
    if (kIsWeb) return null; // Skip cropping on web for now

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.accent,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: true,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );
      return croppedFile;
    } catch (e) {
      debugPrint('Error cropping image: $e');
      return null;
    }
  }

  Future<String?> uploadProfilePicture({required ImageSource source}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadError = null;
    _uploadSuccess = false;
    notifyListeners();

    try {
      // Pick image - ensure camera opens camera, not file picker
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image == null) {
        _isUploading = false;
        notifyListeners();
        return null;
      }

      // Validate format
      if (!_isValidImageFormat(image.name, image.mimeType)) {
        _uploadError = 'Only JPG, JPEG, and PNG files are allowed';
        _isUploading = false;
        notifyListeners();
        return null;
      }

      // Crop image (only on mobile, skip on web for now)
      XFile? croppedImageFile = image;
      if (!kIsWeb) {
        final croppedFile = await _cropImage(image.path, isProfile: true);
        if (croppedFile != null) {
          croppedImageFile = XFile(croppedFile.path);
        }
      }

      // Save locally for instant preview
      if (!kIsWeb) {
        await _saveImageLocally('local_profile_pic', croppedImageFile.path);
      }

      // Upload to Firebase with progress
      final ref = _storage.ref().child('profile_pictures').child('$userId.jpg');
      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await croppedImageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        final file = File(croppedImageFile.path);
        uploadTask = ref.putFile(file);
      }

      // Listen for progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      // Complete the upload
      await uploadTask;
      final url = await ref.getDownloadURL();

      // Update profile
      await updateProfile(profilePic: url);
      _uploadSuccess = true;
      return url;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      _uploadError = 'Failed to upload image: ${e.toString()}';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> removeProfilePicture() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      await _storage
          .ref()
          .child('profile_pictures')
          .child('$userId.jpg')
          .delete();
    } catch (e) {
      debugPrint('Error deleting profile picture from storage: $e');
    }

    await updateProfile(profilePic: '');
  }

  Future<String?> uploadCoverPicture({required ImageSource source}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    _isUploading = true;
    _uploadProgress = 0.0;
    _uploadError = null;
    _uploadSuccess = false;
    notifyListeners();

    try {
      // Pick image
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (image == null) {
        _isUploading = false;
        notifyListeners();
        return null;
      }

      // Validate format
      if (!_isValidImageFormat(image.name, image.mimeType)) {
        _uploadError = 'Only JPG, JPEG, and PNG files are allowed';
        _isUploading = false;
        notifyListeners();
        return null;
      }

      // Crop image
      XFile? croppedImageFile = image;
      if (!kIsWeb) {
        final croppedFile = await _cropImage(image.path, isProfile: false);
        if (croppedFile != null) {
          croppedImageFile = XFile(croppedFile.path);
        }
      }

      // Save locally for instant preview
      if (!kIsWeb) {
        await _saveImageLocally('local_cover_pic', croppedImageFile.path);
      }

      // Upload to Firebase with progress
      final ref = _storage.ref().child('cover_pictures').child('$userId.jpg');
      UploadTask uploadTask;

      if (kIsWeb) {
        final bytes = await croppedImageFile.readAsBytes();
        uploadTask = ref.putData(bytes);
      } else {
        final file = File(croppedImageFile.path);
        uploadTask = ref.putFile(file);
      }

      // Listen for progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        notifyListeners();
      });

      // Complete the upload
      await uploadTask;
      final url = await ref.getDownloadURL();

      // Update profile
      await updateProfile(coverPic: url);
      _uploadSuccess = true;
      return url;
    } catch (e) {
      debugPrint('Error uploading cover picture: $e');
      _uploadError = 'Failed to upload image: ${e.toString()}';
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> removeCoverPicture() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      await _storage
          .ref()
          .child('cover_pictures')
          .child('$userId.jpg')
          .delete();
    } catch (e) {
      debugPrint('Error deleting cover picture from storage: $e');
    }

    await updateProfile(coverPic: '');
  }

  Future<void> uploadResume() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      if (result == null) return;

      final PlatformFile file = result.files.single;
      String fileName = file.name;
      final ref = _storage.ref().child('resumes').child('$userId-$fileName');

      if (kIsWeb) {
        final bytes = file.bytes!;
        await ref.putData(bytes);
      } else {
        final File localFile = File(file.path!);
        await ref.putFile(localFile);
      }

      final url = await ref.getDownloadURL();

      final resume = Resume(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: fileName,
        url: url,
        uploadedAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('resume')
          .doc(resume.id)
          .set(resume.toMap());

      _resume = resume;
      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading resume: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> uploadDocument(String type) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result == null) return;

      final PlatformFile file = result.files.single;
      String fileName = file.name;
      final ref = _storage.ref().child('documents').child('$userId-$fileName');

      if (kIsWeb) {
        final bytes = file.bytes!;
        await ref.putData(bytes);
      } else {
        final File localFile = File(file.path!);
        await ref.putFile(localFile);
      }

      final url = await ref.getDownloadURL();

      final document = Document(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        type: type,
        name: fileName,
        url: url,
        uploadedAt: DateTime.now(),
        verificationStatus: DocumentVerificationStatus.pending,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(document.id)
          .set(document.toMap());

      _documents.add(document);
      notifyListeners();
    } catch (e) {
      debugPrint('Error uploading document: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> replaceDocument(String documentId, String type) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isUploading = true;
    notifyListeners();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result == null) return;

      final PlatformFile file = result.files.single;
      String fileName = file.name;
      final ref = _storage.ref().child('documents').child('$userId-$fileName');

      if (kIsWeb) {
        final bytes = file.bytes!;
        await ref.putData(bytes);
      } else {
        final File localFile = File(file.path!);
        await ref.putFile(localFile);
      }

      final url = await ref.getDownloadURL();

      final updatedDocument = Document(
        id: documentId,
        type: type,
        name: fileName,
        url: url,
        uploadedAt: DateTime.now(),
        verificationStatus: DocumentVerificationStatus.pending,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .set(updatedDocument.toMap());

      // Find and replace in local list
      final index = _documents.indexWhere((d) => d.id == documentId);
      if (index != -1) {
        _documents[index] = updatedDocument;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error replacing document: $e');
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDocument(String documentId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('documents')
          .doc(documentId)
          .delete();
      _documents.removeWhere((d) => d.id == documentId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting document: $e');
    }
  }

  Future<void> deleteResume() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || _resume == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('resume')
          .doc(_resume!.id)
          .delete();
      _resume = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting resume: $e');
    }
  }

  void toggleLanguage(String language) {
    if (_languages.contains(language)) {
      _languages.remove(language);
    } else {
      _languages.add(language);
    }
    notifyListeners();
  }

  void toggleSkill(String skill) {
    if (_skills.contains(skill)) {
      _skills.remove(skill);
    } else {
      _skills.add(skill);
    }
    notifyListeners();
  }

  void toggleWorkingDay(String day) {
    if (_workingDays.contains(day)) {
      _workingDays.remove(day);
    } else {
      _workingDays.add(day);
    }
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? bio,
    String? phone,
    String? profilePic,
    String? coverPic,
    String? gender,
    DateTime? dateOfBirth,
    String? email,
    String? address,
    String? currentCity,
    String? state,
    String? country,
    String? medicalRegistrationNumber,
    String? medicalCouncil,
    String? qualification,
    String? degree,
    String? specialization,
    String? superSpecialization,
    String? department,
    int? experience,
    String? currentHospital,
    String? previousHospitals,
    double? consultationFee,
    bool? availableForDuties,
    bool? emergencyAvailable,
    List<String>? workingDays,
    String? workingHours,
    String? preferredShift,
    int? preferredDutyDistance,
    String? preferredHospitalType,
    double? currentLatitude,
    double? currentLongitude,
    double? homeLatitude,
    double? homeLongitude,
    int? preferredWorkingRadius,
    List<String>? languages,
    List<String>? skills,
    String? linkedinUrl,
    String? researchgateUrl,
    String? orcidUrl,
    String? websiteUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _isLoading = true;
    notifyListeners();
    try {
      final updateData = <String, dynamic>{};
      // Personal
      if (name != null) {
        _name = name;
        updateData['name'] = name;
      }
      if (bio != null) {
        _bio = bio;
        updateData['bio'] = bio;
      }
      if (phone != null) {
        _phone = phone;
        updateData['phone'] = phone;
      }
      if (profilePic != null) {
        _profilePic = profilePic;
        updateData['profilePhoto'] = profilePic;
      }
      if (coverPic != null) {
        _coverPic = coverPic;
        updateData['coverPhoto'] = coverPic;
      }
      if (gender != null) {
        _gender = gender;
        updateData['gender'] = gender;
      }
      if (dateOfBirth != null) {
        _dateOfBirth = dateOfBirth;
        updateData['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      }
      if (email != null) {
        _email = email;
        updateData['email'] = email;
      }
      if (address != null) {
        _address = address;
        updateData['address'] = address;
      }
      if (currentCity != null) {
        _currentCity = currentCity;
        updateData['currentCity'] = currentCity;
      }
      if (state != null) {
        _state = state;
        updateData['state'] = state;
      }
      if (country != null) {
        _country = country;
        updateData['country'] = country;
      }
      // Professional
      if (medicalRegistrationNumber != null) {
        _medicalRegistrationNumber = medicalRegistrationNumber;
        updateData['medicalRegistrationNumber'] = medicalRegistrationNumber;
      }
      if (medicalCouncil != null) {
        _medicalCouncil = medicalCouncil;
        updateData['medicalCouncil'] = medicalCouncil;
      }
      if (qualification != null) {
        _qualification = qualification;
        updateData['qualification'] = qualification;
      }
      if (degree != null) {
        _degree = degree;
        updateData['degree'] = degree;
      }
      if (specialization != null) {
        _specialization = specialization;
        updateData['specialization'] = specialization;
      }
      if (superSpecialization != null) {
        _superSpecialization = superSpecialization;
        updateData['superSpecialization'] = superSpecialization;
      }
      if (department != null) {
        _department = department;
        updateData['department'] = department;
      }
      if (experience != null) {
        _experience = experience;
        updateData['experience'] = experience;
      }
      if (currentHospital != null) {
        _currentHospital = currentHospital;
        updateData['currentHospital'] = currentHospital;
      }
      if (previousHospitals != null) {
        _previousHospitals = previousHospitals;
        updateData['previousHospitals'] = previousHospitals;
      }
      if (consultationFee != null) {
        _consultationFee = consultationFee;
        updateData['consultationFee'] = consultationFee;
      }
      // Availability
      if (availableForDuties != null) {
        _availableForDuties = availableForDuties;
        updateData['availableForDuties'] = availableForDuties;
      }
      if (emergencyAvailable != null) {
        _emergencyAvailable = emergencyAvailable;
        updateData['emergencyAvailable'] = emergencyAvailable;
      }
      if (workingDays != null) {
        _workingDays = workingDays;
        updateData['workingDays'] = workingDays;
      }
      if (workingHours != null) {
        _workingHours = workingHours;
        updateData['workingHours'] = workingHours;
      }
      if (preferredShift != null) {
        _preferredShift = preferredShift;
        updateData['preferredShift'] = preferredShift;
      }
      if (preferredDutyDistance != null) {
        _preferredDutyDistance = preferredDutyDistance;
        updateData['preferredDutyDistance'] = preferredDutyDistance;
      }
      if (preferredHospitalType != null) {
        _preferredHospitalType = preferredHospitalType;
        updateData['preferredHospitalType'] = preferredHospitalType;
      }
      // Location
      if (currentLatitude != null) {
        _currentLatitude = currentLatitude;
        updateData['currentLatitude'] = currentLatitude;
      }
      if (currentLongitude != null) {
        _currentLongitude = currentLongitude;
        updateData['currentLongitude'] = currentLongitude;
      }
      if (homeLatitude != null) {
        _homeLatitude = homeLatitude;
        updateData['homeLatitude'] = homeLatitude;
      }
      if (homeLongitude != null) {
        _homeLongitude = homeLongitude;
        updateData['homeLongitude'] = homeLongitude;
      }
      if (preferredWorkingRadius != null) {
        _preferredWorkingRadius = preferredWorkingRadius;
        updateData['preferredWorkingRadius'] = preferredWorkingRadius;
      }
      // Languages, Skills
      if (languages != null) {
        _languages = languages;
        updateData['languages'] = languages;
      }
      if (skills != null) {
        _skills = skills;
        updateData['skills'] = skills;
      }
      // Social
      if (linkedinUrl != null) {
        _linkedinUrl = linkedinUrl;
        updateData['linkedinUrl'] = linkedinUrl;
      }
      if (researchgateUrl != null) {
        _researchgateUrl = researchgateUrl;
        updateData['researchgateUrl'] = researchgateUrl;
      }
      if (orcidUrl != null) {
        _orcidUrl = orcidUrl;
        updateData['orcidUrl'] = orcidUrl;
      }
      if (websiteUrl != null) {
        _websiteUrl = websiteUrl;
        updateData['websiteUrl'] = websiteUrl;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .set(updateData, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Qualifications methods
  Future<void> addQualification(Qualification qualification) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('qualifications')
          .doc(qualification.id)
          .set(qualification.toMap());
    } catch (e) {
      debugPrint('Error adding qualification: $e');
    }
  }

  Future<void> updateQualification(Qualification qualification) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('qualifications')
          .doc(qualification.id)
          .set(qualification.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating qualification: $e');
    }
  }

  Future<void> deleteQualification(String qualificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('qualifications')
          .doc(qualificationId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting qualification: $e');
    }
  }

  // Experience methods
  Future<void> addExperienceEntry(ExperienceEntry entry) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('experience')
          .doc(entry.id)
          .set(entry.toMap());
    } catch (e) {
      debugPrint('Error adding experience: $e');
    }
  }

  Future<void> updateExperienceEntry(ExperienceEntry entry) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('experience')
          .doc(entry.id)
          .set(entry.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating experience: $e');
    }
  }

  Future<void> deleteExperienceEntry(String entryId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('experience')
          .doc(entryId)
          .delete();
    } catch (e) {
      debugPrint('Error deleting experience: $e');
    }
  }

  // Language methods
  Future<void> addLanguage(LanguageWithProficiency language) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      // Use language name as document id for easy management
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(language.name)
          .set(language.toMap());
    } catch (e) {
      debugPrint('Error adding language: $e');
    }
  }

  Future<void> updateLanguage(LanguageWithProficiency language) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(language.name)
          .set(language.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating language: $e');
    }
  }

  Future<void> deleteLanguage(String languageName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('languages')
          .doc(languageName)
          .delete();
    } catch (e) {
      debugPrint('Error deleting language: $e');
    }
  }

  // Skill methods
  Future<void> addSkill(SkillWithProficiency skill) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      // Use skill name as document id
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skill.name)
          .set(skill.toMap());
    } catch (e) {
      debugPrint('Error adding skill: $e');
    }
  }

  Future<void> updateSkill(SkillWithProficiency skill) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skill.name)
          .set(skill.toMap(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating skill: $e');
    }
  }

  Future<void> deleteSkill(String skillName) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('skills')
          .doc(skillName)
          .delete();
    } catch (e) {
      debugPrint('Error deleting skill: $e');
    }
  }

  // Update medical registration
  Future<void> updateMedicalRegistration(
    MedicalRegistration registration,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).set({
        'medicalRegistration': registration.toMap(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating medical registration: $e');
    }
  }

  // Update achievements
  Future<void> updateAchievements(List<String> achievements) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).set({
        'achievements': achievements,
      }, SetOptions(merge: true));
      _achievements = achievements;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating achievements: $e');
    }
  }

  // Update interests
  Future<void> updateInterests(List<String> interests) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      await _firestore.collection('users').doc(userId).set({
        'interests': interests,
      }, SetOptions(merge: true));
      _interests = interests;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating interests: $e');
    }
  }

  // Update specialization details
  Future<void> updateSpecializationDetails({
    List<String>? secondarySpecializations,
    String? superSpecialization,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      final updateData = <String, dynamic>{};
      if (secondarySpecializations != null) {
        updateData['secondarySpecializations'] = secondarySpecializations;
        _secondarySpecializations = secondarySpecializations;
      }
      if (superSpecialization != null) {
        updateData['superSpecialization'] = superSpecialization;
        _superSpecialization = superSpecialization;
      }
      await _firestore
          .collection('users')
          .doc(userId)
          .set(updateData, SetOptions(merge: true));
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating specialization details: $e');
    }
  }

  Future<void> updateSpecialization({required String specialization}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      _specialization = specialization;
      await _firestore.collection('users').doc(userId).set(
        {'specialization': specialization},
        SetOptions(merge: true),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating specialization: $e');
    }
  }

  Future<void> updateLanguages({required List<String> languages}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      _languages = languages;
      await _firestore.collection('users').doc(userId).set(
        {'languages': languages},
        SetOptions(merge: true),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating languages: $e');
    }
  }

  Future<void> updateSkills({required List<String> skills}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      _skills = skills;
      await _firestore.collection('users').doc(userId).set(
        {'skills': skills},
        SetOptions(merge: true),
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating skills: $e');
    }
  }

  // Calculate profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 15;

    if (_name.isNotEmpty) completedFields++;
    if (_email.isNotEmpty) completedFields++;
    if (_phone.isNotEmpty) completedFields++;
    if (_qualifications.isNotEmpty) completedFields++;
    if (_experienceEntries.isNotEmpty) completedFields++;
    if (_languagesWithProficiency.isNotEmpty) completedFields++;
    if (_skillsWithProficiency.isNotEmpty) completedFields++;
    if (_medicalRegistration.number.isNotEmpty) completedFields++;
    if (_specialization.isNotEmpty) completedFields++;
    if (_bio.isNotEmpty) completedFields++;
    if (_profilePic.isNotEmpty) completedFields++;
    if (_documents.isNotEmpty) completedFields++;
    if (_currentCity.isNotEmpty) completedFields++;
    if (_address.isNotEmpty) completedFields++;
    if (_gender != null) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  Future<bool> followUser({
    required String targetUserId,
    String? targetName,
    String? targetSpecialization,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId == targetUserId) return false;
    if (_followingUserIds.contains(targetUserId)) return true;
    try {
      final now = FieldValue.serverTimestamp();
      final batch = _firestore.batch();
      final followingRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('following')
          .doc(targetUserId);
      final followerRef = _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('followers')
          .doc(userId);
      final followingData = <String, dynamic>{'followedAt': now};
      if (targetName != null) followingData['name'] = targetName;
      if (targetSpecialization != null) {
        followingData['specialization'] = targetSpecialization;
      }
      batch.set(followingRef, followingData);
      batch.set(followerRef, {'followedAt': now});
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error following user: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId == targetUserId) return false;
    try {
      final batch = _firestore.batch();
      batch.delete(
        _firestore
            .collection('users')
            .doc(userId)
            .collection('following')
            .doc(targetUserId),
      );
      batch.delete(
        _firestore
            .collection('users')
            .doc(targetUserId)
            .collection('followers')
            .doc(userId),
      );
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error unfollowing user: $e');
      return false;
    }
  }

  Future<int> mutualConnectionsCount(String targetUserId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId == targetUserId) return 0;
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('following')
          .get();
      final theirFollowing = snapshot.docs.map((d) => d.id).toSet();
      return _followingUserIds.intersection(theirFollowing).length;
    } catch (e) {
      debugPrint('Error loading mutual count: $e');
      return 0;
    }
  }

  Future<List<Map<String, String>>> mutualConnections(
    String targetUserId,
  ) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null || userId == targetUserId) return [];
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(targetUserId)
          .collection('following')
          .get();
      final mutualIds = _followingUserIds.intersection(
        snapshot.docs.map((d) => d.id).toSet(),
      );
      if (mutualIds.isEmpty) return [];
      final results = <Map<String, String>>[];
      for (final id in mutualIds.take(30)) {
        final doc = await _firestore.collection('users').doc(id).get();
        if (!doc.exists) continue;
        final data = doc.data() ?? {};
        results.add({
          'id': id,
          'name': (data['name'] ?? data['displayName'] ?? 'Doctor').toString(),
          'specialization': (data['specialization'] ?? 'Healthcare Professional')
              .toString(),
          'hospital': (data['currentHospital'] ?? '').toString(),
        });
      }
      return results;
    } catch (e) {
      debugPrint('Error loading mutual connections: $e');
      return [];
    }
  }

  List<Document> documentsByType(String typeKeyword) {
    final key = typeKeyword.toLowerCase();
    return _documents
        .where((d) => d.type.toLowerCase().contains(key))
        .toList();
  }

  Future<void> syncContactFromAuth() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final authPhone = user.phoneNumber;
    final authEmail = user.email;

    final updates = <String, dynamic>{};
    if (authEmail != null &&
        authEmail.isNotEmpty &&
        authEmail != _email) {
      _email = authEmail;
      updates['email'] = authEmail;
    }
    if (authPhone != null &&
        authPhone.isNotEmpty &&
        authPhone != _phone) {
      _phone = authPhone;
      _phoneVerified = true;
      updates['phone'] = authPhone;
      updates['phoneVerified'] = true;
    }
    if (updates.isNotEmpty) {
      final userId = user.uid;
      await _firestore.collection('users').doc(userId).set(
            updates,
            SetOptions(merge: true),
          );
      notifyListeners();
    }
  }

  Future<void> saveVerifiedPhone(String phoneE164) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _phone = phoneE164;
    _phoneVerified = true;
    await _firestore.collection('users').doc(userId).set(
      {
        'phone': phoneE164,
        'phoneVerified': true,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> removeVerifiedPhone() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _phone = '';
    _phoneVerified = false;
    await _firestore.collection('users').doc(userId).set(
      {
        'phone': '',
        'phoneVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> saveRecoveryEmail({
    required String email,
    required bool verified,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _recoveryEmail = email;
    _recoveryEmailVerified = verified;
    await _firestore.collection('users').doc(userId).set(
      {
        'recoveryEmail': email,
        'recoveryEmailVerified': verified,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> clearRecoveryEmail() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _recoveryEmail = '';
    _recoveryEmailVerified = false;
    await _firestore.collection('users').doc(userId).set(
      {
        'recoveryEmail': '',
        'recoveryEmailVerified': false,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> updatePrimaryEmailInProfile(String email) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    _email = email;
    await _firestore.collection('users').doc(userId).set(
      {
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  // Privacy settings methods
  Future<void> updatePrivacySettings({
    ProfilePrivacy? profilePrivacy,
    bool? profileVisibility,
    bool? phoneVisibility,
    bool? allowMessages,
    bool? allowReviews,
    bool? followRequestRequired,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final updateData = <String, dynamic>{};
    if (profilePrivacy != null) {
      _profilePrivacy = profilePrivacy;
      _profileVisibility = profilePrivacy != ProfilePrivacy.private;
      updateData['profilePrivacy'] = profilePrivacy.firestoreValue;
      updateData['profileVisibility'] = _profileVisibility;
    } else if (profileVisibility != null) {
      _profileVisibility = profileVisibility;
      _profilePrivacy = profileVisibility ? ProfilePrivacy.public : ProfilePrivacy.private;
      updateData['profileVisibility'] = profileVisibility;
      updateData['profilePrivacy'] = _profilePrivacy.firestoreValue;
    }
    if (phoneVisibility != null) {
      _phoneVisibility = phoneVisibility;
      updateData['phoneVisibility'] = phoneVisibility;
    }
    if (allowMessages != null) {
      _allowMessages = allowMessages;
      updateData['allowMessages'] = allowMessages;
    }
    if (allowReviews != null) {
      _allowReviews = allowReviews;
      updateData['allowReviews'] = allowReviews;
    }
    if (followRequestRequired != null) {
      _followRequestRequired = followRequestRequired;
      updateData['followRequestRequired'] = followRequestRequired;
    }

    updateData['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).set(
      updateData,
      SetOptions(merge: true),
    );
    notifyListeners();
  }

  Future<void> updateProfilePrivacy(ProfilePrivacy privacy) async {
    await updatePrivacySettings(profilePrivacy: privacy);
  }
}
