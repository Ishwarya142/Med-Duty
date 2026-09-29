import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/cloudinary_service.dart';
import '../../providers/profile_provider.dart';

class _DraftState {
  String profilePic = '';
  String name = '';
  String? gender;
  DateTime? dob;
  String email = '';
  String phone = '';
  String address = '';
  String city = '';
  String state = '';
  String country = '';
  String registrationNumber = '';
  String medicalCouncil = '';
  String qualification = '';
  String degree = '';
  String specialization = '';
  String superSpecialization = '';
  String department = '';
  int experience = 0;
  String currentHospital = '';
  String previousHospitals = '';
  double consultationFee = 0.0;
  String biography = '';
  List<String> workingDays = [];
  String workingHours = '';
  String preferredShift = '';
  int preferredDutyDistance = 50;
  String preferredHospitalType = '';
  bool autoGps = true;
  double? currentLat;
  double? currentLng;
  String currentLocationText = '';
  double? homeLat;
  double? homeLng;
  String homeLocationText = '';
  int radius = 50;
  Map<String, List<_DocDraft>> documents = {
    'medical_license': [],
    'certificates': [],
    'government_id': [],
    'research_papers': [],
    'resume': [],
  };

  Map<String, dynamic> toJson() => {
    'profilePic': profilePic,
    'name': name,
    'gender': gender,
    'dob': dob?.toIso8601String(),
    'email': email,
    'phone': phone,
    'address': address,
    'city': city,
    'state': state,
    'country': country,
    'registrationNumber': registrationNumber,
    'medicalCouncil': medicalCouncil,
    'qualification': qualification,
    'degree': degree,
    'specialization': specialization,
    'superSpecialization': superSpecialization,
    'department': department,
    'experience': experience,
    'currentHospital': currentHospital,
    'previousHospitals': previousHospitals,
    'consultationFee': consultationFee,
    'biography': biography,
    'workingDays': workingDays,
    'workingHours': workingHours,
    'preferredShift': preferredShift,
    'preferredDutyDistance': preferredDutyDistance,
    'preferredHospitalType': preferredHospitalType,
    'autoGps': autoGps,
    'currentLat': currentLat,
    'currentLng': currentLng,
    'currentLocationText': currentLocationText,
    'homeLat': homeLat,
    'homeLng': homeLng,
    'homeLocationText': homeLocationText,
    'radius': radius,
    'documents': documents.map(
      (k, v) => MapEntry(k, v.map((d) => d.toJson()).toList()),
    ),
  };

  static _DraftState fromJson(Map<String, dynamic> m) {
    final d = _DraftState();
    d.profilePic = m['profilePic'] ?? '';
    d.name = m['name'] ?? '';
    d.gender = m['gender'];
    final dobStr = m['dob'];
    if (dobStr != null && dobStr.toString().isNotEmpty) {
      d.dob = DateTime.tryParse(dobStr.toString());
    }
    d.email = m['email'] ?? '';
    d.phone = m['phone'] ?? '';
    d.address = m['address'] ?? '';
    d.city = m['city'] ?? '';
    d.state = m['state'] ?? '';
    d.country = m['country'] ?? '';
    d.registrationNumber = m['registrationNumber'] ?? '';
    d.medicalCouncil = m['medicalCouncil'] ?? '';
    d.qualification = m['qualification'] ?? '';
    d.degree = m['degree'] ?? '';
    d.specialization = m['specialization'] ?? '';
    d.superSpecialization = m['superSpecialization'] ?? '';
    d.department = m['department'] ?? '';
    d.experience = (m['experience'] ?? 0) as int;
    d.currentHospital = m['currentHospital'] ?? '';
    d.previousHospitals = m['previousHospitals'] ?? '';
    final cf = m['consultationFee'];
    d.consultationFee = (cf is int) ? cf.toDouble() : (cf as double? ?? 0.0);
    d.biography = m['biography'] ?? '';
    d.workingDays = List<String>.from(m['workingDays'] ?? []);
    d.workingHours = m['workingHours'] ?? '';
    d.preferredShift = m['preferredShift'] ?? '';
    d.preferredDutyDistance = (m['preferredDutyDistance'] ?? 50) as int;
    d.preferredHospitalType = m['preferredHospitalType'] ?? '';
    d.autoGps = m['autoGps'] ?? true;
    d.currentLat = (m['currentLat'] as num?)?.toDouble();
    d.currentLng = (m['currentLng'] as num?)?.toDouble();
    d.currentLocationText = m['currentLocationText'] ?? '';
    d.homeLat = (m['homeLat'] as num?)?.toDouble();
    d.homeLng = (m['homeLng'] as num?)?.toDouble();
    d.homeLocationText = m['homeLocationText'] ?? '';
    d.radius = (m['radius'] ?? 50) as int;
    final docsRaw = m['documents'] as Map<String, dynamic>? ?? {};
    d.documents = {
      'medical_license': [],
      'certificates': [],
      'government_id': [],
      'research_papers': [],
      'resume': [],
    };
    for (final k in d.documents.keys) {
      final list = docsRaw[k] as List<dynamic>? ?? [];
      d.documents[k] = list
          .map((e) => _DocDraft.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return d;
  }
}

class _DocDraft {
  String id;
  String name;
  String? cloudinaryUrl;
  String? localPath;
  bool uploading;
  String? uploadError;
  DateTime uploadedAt;

  _DocDraft({
    required this.id,
    required this.name,
    this.cloudinaryUrl,
    this.localPath,
    this.uploading = false,
    this.uploadError,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'cloudinaryUrl': cloudinaryUrl,
    'localPath': localPath,
    'uploading': uploading,
    'uploadError': uploadError,
    'uploadedAt': uploadedAt.toIso8601String(),
  };

  factory _DocDraft.fromJson(Map<String, dynamic> m) => _DocDraft(
    id: m['id'] ?? const Uuid().v4(),
    name: m['name'] ?? '',
    cloudinaryUrl: m['cloudinaryUrl'],
    localPath: m['localPath'],
    uploading: m['uploading'] ?? false,
    uploadError: m['uploadError'],
    uploadedAt: DateTime.tryParse(m['uploadedAt'] ?? '') ?? DateTime.now(),
  );
}

class EditProfileCompleteScreen extends StatefulWidget {
  const EditProfileCompleteScreen({super.key});

  @override
  State<EditProfileCompleteScreen> createState() =>
      _EditProfileCompleteScreenState();
}

class _EditProfileCompleteScreenState extends State<EditProfileCompleteScreen> {
  static const _draftKey = 'edit_profile_draft_v1';

  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final Uuid _uuid = const Uuid();

  late _DraftState _draft;
  late _DraftState _original;
  bool _isSaving = false;
  bool _isUploadingProfile = false;
  bool _isDrafterLoaded = false;

  final List<String> _genderOptions = const ['Male', 'Female', 'Other'];
  final List<String> _daysOptions = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  final List<String> _shiftOptions = const [
    'Morning',
    'Afternoon',
    'Evening',
    'Night',
    'Any',
  ];
  final List<String> _hospitalTypes = const [
    'Government',
    'Private',
    'Corporate',
    'Clinic',
    'Nursing Home',
    'Multi-Speciality',
    'Any',
  ];
  final List<String> _hourOptions = [
    for (int h = 0; h < 24; h++)
      '${(h % 12 == 0 ? 12 : h % 12).toString().padLeft(2, '0')}:00 ${h < 12 ? 'AM' : 'PM'}',
  ];

  final Map<String, TextEditingController> _ctrl = {};
  final Map<String, FocusNode> _fn = {};

  TextEditingController _c(String key) =>
      _ctrl.putIfAbsent(key, () => TextEditingController());
  FocusNode _f(String key) => _fn.putIfAbsent(key, () => FocusNode());

  @override
  void initState() {
    super.initState();
    _draft = _DraftState();
    _original = _DraftState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initFromProvider();
      await _loadDraft();
    });
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    for (final f in _fn.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _initFromProvider() async {
    final p = Provider.of<ProfileProvider>(context, listen: false);
    setState(() {
      _draft.profilePic = p.profilePic;
      _draft.name = p.name;
      _draft.gender = p.gender;
      _draft.dob = p.dateOfBirth;
      _draft.email = p.email;
      _draft.phone = p.phone;
      _draft.address = p.address;
      _draft.city = p.currentCity;
      _draft.state = p.state;
      _draft.country = p.country;
      _draft.registrationNumber = p.medicalRegistrationNumber;
      _draft.medicalCouncil = p.medicalCouncil;
      _draft.qualification = p.qualification;
      _draft.degree = p.degree;
      _draft.specialization = p.specialization;
      _draft.superSpecialization = p.superSpecialization ?? '';
      _draft.department = p.department;
      _draft.experience = p.experience;
      _draft.currentHospital = p.currentHospital;
      _draft.previousHospitals = p.previousHospitals;
      _draft.consultationFee = p.consultationFee;
      _draft.biography = p.bio;
      _draft.workingDays = List.from(p.workingDays);
      _draft.workingHours = p.workingHours;
      _draft.preferredShift = p.preferredShift;
      _draft.preferredDutyDistance = p.preferredDutyDistance;
      _draft.preferredHospitalType = p.preferredHospitalType;
      _draft.currentLat = p.currentLatitude;
      _draft.currentLng = p.currentLongitude;
      _draft.homeLat = p.homeLatitude;
      _draft.homeLng = p.homeLongitude;
      _draft.radius = p.preferredWorkingRadius;
      _original = _DraftState.fromJson(jsonDecode(jsonEncode(_draft.toJson())));
      _syncControllersFromDraft();
    });
  }

  void _syncControllersFromDraft() {
    _c('name').text = _draft.name;
    _c('email').text = _draft.email;
    _c('phone').text = _draft.phone;
    _c('address').text = _draft.address;
    _c('city').text = _draft.city;
    _c('state').text = _draft.state;
    _c('country').text = _draft.country;
    _c('registrationNumber').text = _draft.registrationNumber;
    _c('medicalCouncil').text = _draft.medicalCouncil;
    _c('qualification').text = _draft.qualification;
    _c('degree').text = _draft.degree;
    _c('specialization').text = _draft.specialization;
    _c('superSpecialization').text = _draft.superSpecialization;
    _c('department').text = _draft.department;
    _c('experience').text = _draft.experience > 0
        ? _draft.experience.toString()
        : '';
    _c('currentHospital').text = _draft.currentHospital;
    _c('previousHospitals').text = _draft.previousHospitals;
    _c('consultationFee').text = _draft.consultationFee > 0
        ? _draft.consultationFee.toString()
        : '';
    _c('biography').text = _draft.biography;
    _c('workingHours').text = _draft.workingHours;
    _c('preferredDutyDistance').text = _draft.preferredDutyDistance.toString();
    _c('preferredHospitalType').text = _draft.preferredHospitalType;
    _c('preferredShift').text = _draft.preferredShift;
    _c('currentLocation').text = _draft.currentLocationText;
    _c('homeLocation').text = _draft.homeLocationText;
    _c('radius').text = _draft.radius.toString();
  }

  Future<void> _loadDraft() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_draftKey);
      if (raw != null && raw.isNotEmpty) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        final loaded = _DraftState.fromJson(m);
        final isPopulated =
            loaded.name.isNotEmpty ||
            loaded.email.isNotEmpty ||
            loaded.phone.isNotEmpty ||
            loaded.biography.isNotEmpty;
        if (isPopulated && mounted) {
          final useDraft =
              await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Restore Draft?'),
                  content: const Text(
                    'We found an unsaved draft. Would you like to restore your edits or discard them?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Discard'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                      ),
                      child: const Text('Restore'),
                    ),
                  ],
                ),
              ) ??
              false;
          if (useDraft) {
            setState(() {
              _draft = loaded;
              _syncControllersFromDraft();
            });
          }
        }
      }
    } catch (_) {}
    setState(() => _isDrafterLoaded = true);
    _scheduleAutosave();
  }

  Future<void> _persistDraft() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.setString(_draftKey, jsonEncode(_draft.toJson()));
    } catch (_) {}
  }

  Future<void> _clearDraft() async {
    try {
      final sp = await SharedPreferences.getInstance();
      await sp.remove(_draftKey);
    } catch (_) {}
  }

  bool _autosaveScheduled = false;
  void _scheduleAutosave() {
    if (_autosaveScheduled) return;
    _autosaveScheduled = true;
    Future.delayed(const Duration(seconds: 2), () async {
      _autosaveScheduled = false;
      await _persistDraft();
    });
  }

  void _markChanged() {
    if (!mounted) return;
    setState(() {});
    _scheduleAutosave();
  }

  bool get _hasUnsavedChanges {
    final o = jsonEncode(_original.toJson());
    final n = jsonEncode(_draft.toJson());
    return o != n;
  }

  Future<bool> _onWillPop() async {
    if (_isSaving) return false;
    if (!_hasUnsavedChanges) {
      await _clearDraft();
      return true;
    }
    if (!mounted) return true;
    final result =
        await showDialog<int>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Unsaved Changes'),
            content: const Text(
              'You have unsaved changes. Would you like to save them before leaving, discard them, or continue editing?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, 0),
                child: const Text('Continue Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, 2),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Discard'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Save & Exit'),
              ),
            ],
          ),
        ) ??
        0;
    if (result == 1) {
      final saved = await _saveAll(silent: true);
      if (saved) {
        await _clearDraft();
        return true;
      }
      return false;
    }
    if (result == 2) {
      await _clearDraft();
      return true;
    }
    return false;
  }

  String? _required(String? v, String label) {
    if (v == null || v.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _emailValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final e = v.trim();
    final r = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!r.hasMatch(e)) return 'Enter a valid email address';
    return null;
  }

  String? _phoneValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'Phone is required';
    final e = v.replaceAll(RegExp(r'[^\d+]'), '');
    if (e.length < 7) return 'Enter a valid phone number';
    if (e.length > 15) return 'Phone number is too long';
    return null;
  }

  String? _positiveNum(String? v, String label) {
    if (v == null || v.trim().isEmpty) return null;
    final n = num.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n.isNegative) return '$label cannot be negative';
    return null;
  }

  String? _zip(String? v) => _positiveNum(v, 'Experience');

  Future<XFile?> _pickImage({required bool camera}) async {
    try {
      final src = camera ? ImageSource.camera : ImageSource.gallery;
      final picked = await _picker.pickImage(
        source: src,
        imageQuality: 85,
        maxHeight: 1600,
        maxWidth: 1600,
      );
      if (picked == null) return null;
      final bytes = await picked.readAsBytes();
      final validation = CloudinaryService.instance.validateFile(
        picked.path,
        bytes,
      );
      if (!validation.valid && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validation.error),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
        return null;
      }
      return picked;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }
  }

  Future<void> _pickProfilePic(bool camera) async {
    final picked = await _pickImage(camera: camera);
    if (picked == null) return;
    setState(() => _isUploadingProfile = true);
    try {
      final result = await CloudinaryService.instance.uploadImage(
        file: File(picked.path),
        folder: 'medduty/profile_images',
      );
      setState(() {
        _draft.profilePic = result.secureUrl;
      });
      _markChanged();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      setState(() => _isUploadingProfile = false);
    }
  }

  Future<void> _pickDocument({
    required String documentType,
    required bool camera,
  }) async {
    final picked = await _pickImage(camera: camera);
    if (picked == null) return;

    final doc = _DocDraft(
      id: _uuid.v4(),
      name: picked.name,
      localPath: picked.path,
      uploading: true,
      uploadedAt: DateTime.now(),
    );
    setState(() {
      _draft.documents[documentType] = [
        ...?_draft.documents[documentType],
        doc,
      ];
    });
    try {
      final result = await CloudinaryService.instance.uploadImage(
        file: File(picked.path),
        folder: 'medduty/$documentType',
      );
      setState(() {
        final list = _draft.documents[documentType] ?? [];
        final idx = list.indexWhere((d) => d.id == doc.id);
        if (idx >= 0) {
          list[idx].uploading = false;
          list[idx].cloudinaryUrl = result.secureUrl;
          list[idx].uploadError = null;
        }
      });
      _markChanged();
    } catch (e) {
      setState(() {
        final list = _draft.documents[documentType] ?? [];
        final idx = list.indexWhere((d) => d.id == doc.id);
        if (idx >= 0) {
          list[idx].uploading = false;
          list[idx].uploadError = e.toString();
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeDoc(String documentType, String id) {
    setState(() {
      _draft.documents[documentType]?.removeWhere((d) => d.id == id);
    });
    _markChanged();
  }

  Future<void> _pickDob() async {
    final now = DateTime.now();
    final initial = _draft.dob ?? DateTime(now.year - 25);
    final first = DateTime(now.year - 120);
    final last = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (ctx, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(ctx).copyWith(
            colorScheme: Theme.of(ctx).colorScheme.copyWith(
              primary: AppColors.accent,
              onPrimary: AppColors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _draft.dob = picked);
      _markChanged();
    }
  }

  Future<void> _getGps() async {
    bool service;
    LocationPermission perm;
    service = await Geolocator.isLocationServiceEnabled();
    if (!service && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services are disabled'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permissions denied'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }
    }
    if (perm == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enable location permissions in settings'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    setState(() {
      _draft.currentLat = pos.latitude;
      _draft.currentLng = pos.longitude;
      _draft.currentLocationText =
          '${pos.latitude.toStringAsFixed(4)}, ${pos.longitude.toStringAsFixed(4)}';
      _c('currentLocation').text = _draft.currentLocationText;
    });
    _markChanged();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location captured via GPS'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<bool> _saveAll({bool silent = false}) async {
    final valid = _formKey.currentState?.validate() ?? true;
    if (!valid) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fix the highlighted errors first'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    }
    final docs = _draft.documents.values.expand((e) => e);
    final anyUploading = docs.any((d) => d.uploading);
    final anyFailed = docs.any((d) => (d.uploadError?.isNotEmpty ?? false));
    if (anyUploading && mounted && !silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for uploads to finish'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.warning,
        ),
      );
      return false;
    }
    if (anyFailed && mounted && !silent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Some documents failed to upload. Re-upload or remove them.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
        ),
      );
      return false;
    }
    setState(() => _isSaving = true);
    try {
      final p = Provider.of<ProfileProvider>(context, listen: false);
      await p.updateProfile(
        name: _draft.name.trim(),
        gender: _draft.gender,
        dateOfBirth: _draft.dob,
        email: _draft.email.trim(),
        phone: _draft.phone.trim(),
        address: _draft.address.trim(),
        currentCity: _draft.city.trim(),
        state: _draft.state.trim(),
        country: _draft.country.trim(),
        medicalRegistrationNumber: _draft.registrationNumber.trim(),
        medicalCouncil: _draft.medicalCouncil.trim(),
        qualification: _draft.qualification.trim(),
        degree: _draft.degree.trim(),
        specialization: _draft.specialization.trim(),
        superSpecialization: _draft.superSpecialization.trim().isEmpty
            ? null
            : _draft.superSpecialization.trim(),
        department: _draft.department.trim(),
        experience: _draft.experience,
        currentHospital: _draft.currentHospital.trim(),
        previousHospitals: _draft.previousHospitals.trim(),
        consultationFee: _draft.consultationFee,
        bio: _draft.biography.trim(),
        workingDays: _draft.workingDays,
        workingHours: _draft.workingHours,
        preferredShift: _draft.preferredShift,
        preferredDutyDistance: _draft.preferredDutyDistance,
        preferredHospitalType: _draft.preferredHospitalType,
        currentLatitude: _draft.currentLat,
        currentLongitude: _draft.currentLng,
        homeLatitude: _draft.homeLat,
        homeLongitude: _draft.homeLng,
        preferredWorkingRadius: _draft.radius,
        profilePic: _draft.profilePic.isEmpty ? null : _draft.profilePic,
      );
      _original = _DraftState.fromJson(jsonDecode(jsonEncode(_draft.toJson())));
      await _clearDraft();
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile saved successfully'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return true;
    } catch (e) {
      if (!silent && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.error,
          ),
        );
      }
      return false;
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final surfaceVariant = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final iconSecondaryBg = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final mutedColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardShadow = isDark ? <BoxShadow>[] : AppColors.softShadow;

    if (!_isDrafterLoaded) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accent),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: Icon(Icons.close, color: textColor),
            onPressed: () async {
              final nav = Navigator.of(context);
              final shouldPop = await _onWillPop();
              if (!mounted) return;
              if (shouldPop) nav.pop();
            },
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          actions: [
            TextButton(
              onPressed: () async {
                if (_isSaving) return;
                final nav = Navigator.of(context);
                final ok = await _saveAll();
                if (!mounted) return;
                if (ok) nav.pop();
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.accent),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          bottom: false,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                children: [
                  _buildProfilePicture(
                    isDark,
                    textColor,
                    subTextColor,
                    surfaceColor,
                    cardShadow,
                    borderColor,
                  ),
                  const SizedBox(height: 22),
                  _buildSection(
                    title: 'Personal Information',
                    icon: Icons.person_outline,
                    iconBg: iconSecondaryBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    children: [
                      _buildField(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        icon: Icons.badge_outlined,
                        keyName: 'name',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: (v) => _required(v, 'Full Name'),
                        onChanged: (v) {
                          _draft.name = v;
                          _markChanged();
                        },
                      ),
                      _buildGender(
                        isDark,
                        textColor,
                        subTextColor,
                        surfaceColor,
                        cardShadow,
                        borderColor,
                      ),
                      _buildDob(
                        isDark,
                        textColor,
                        subTextColor,
                        surfaceColor,
                        cardShadow,
                        borderColor,
                      ),
                      _buildField(
                        label: 'Email',
                        hint: 'you@example.com',
                        icon: Icons.email_outlined,
                        keyName: 'email',
                        keyboard: TextInputType.emailAddress,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: _emailValidator,
                        onChanged: (v) {
                          _draft.email = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Phone Number',
                        hint: '+1 555 000 0000',
                        icon: Icons.phone_outlined,
                        keyName: 'phone',
                        keyboard: TextInputType.phone,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: _phoneValidator,
                        onChanged: (v) {
                          _draft.phone = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Address',
                        hint: 'Street, building, landmark',
                        icon: Icons.location_on_outlined,
                        keyName: 'address',
                        maxLines: 2,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.address = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'City',
                        hint: 'Current city',
                        icon: Icons.location_city_outlined,
                        keyName: 'city',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.city = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'State / Province',
                        hint: 'State or region',
                        icon: Icons.map_outlined,
                        keyName: 'state',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.state = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Country',
                        hint: 'Your country',
                        icon: Icons.public,
                        keyName: 'country',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.country = v;
                          _markChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Professional Information',
                    icon: Icons.workspace_premium_outlined,
                    iconBg: iconSecondaryBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    children: [
                      _buildField(
                        label: 'Registration Number',
                        hint: 'Medical council registration number',
                        icon: Icons.verified_outlined,
                        keyName: 'registrationNumber',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.registrationNumber = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Medical Council',
                        hint: 'e.g., MCI, GMC, NMC',
                        icon: Icons.medical_information_outlined,
                        keyName: 'medicalCouncil',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.medicalCouncil = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Qualification',
                        hint: 'e.g., MBBS, MD, BSc Nursing',
                        icon: Icons.school_outlined,
                        keyName: 'qualification',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.qualification = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Degree',
                        hint: 'e.g., Doctor of Medicine',
                        icon: Icons.menu_book_outlined,
                        keyName: 'degree',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.degree = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Specialization',
                        hint: 'e.g., Cardiology',
                        icon: Icons.favorite_border,
                        keyName: 'specialization',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.specialization = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Super Specialization',
                        hint: 'Optional',
                        icon: Icons.star_border,
                        keyName: 'superSpecialization',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.superSpecialization = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Department',
                        hint: 'Department in hospital / clinic',
                        icon: Icons.account_tree_outlined,
                        keyName: 'department',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.department = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Experience (Years)',
                        hint: '0',
                        icon: Icons.timelapse_outlined,
                        keyName: 'experience',
                        keyboard: TextInputType.number,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: _zip,
                        onChanged: (v) {
                          _draft.experience = int.tryParse(v.trim()) ?? 0;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Current Hospital',
                        hint: 'Where you currently work',
                        icon: Icons.local_hospital_outlined,
                        keyName: 'currentHospital',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.currentHospital = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Previous Hospitals',
                        hint: 'Comma-separated list',
                        icon: Icons.history,
                        keyName: 'previousHospitals',
                        maxLines: 2,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.previousHospitals = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Consultation Fee (₹ / \$)',
                        hint: 'e.g., 500',
                        icon: Icons.currency_rupee,
                        keyName: 'consultationFee',
                        keyboard: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: (v) => _positiveNum(v, 'Consultation Fee'),
                        onChanged: (v) {
                          _draft.consultationFee =
                              double.tryParse(v.trim()) ?? 0.0;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Biography',
                        hint: 'A short introduction about yourself',
                        icon: Icons.edit_note,
                        keyName: 'biography',
                        maxLines: 5,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.biography = v;
                          _markChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Availability',
                    icon: Icons.event_available_outlined,
                    iconBg: iconSecondaryBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    children: [
                      _buildWorkingDays(
                        isDark,
                        textColor,
                        subTextColor,
                        surfaceVariant,
                      ),
                      _buildDropdown(
                        label: 'Working Hours',
                        hint: 'Select hours',
                        icon: Icons.schedule_outlined,
                        options: [
                          for (int i = 0; i < _hourOptions.length; i++)
                            for (int j = i + 1; j < _hourOptions.length; j++)
                              '${_hourOptions[i]}  -  ${_hourOptions[j]}',
                        ].take(40).toList(),
                        keyName: 'workingHours',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.workingHours = v ?? '';
                          _markChanged();
                        },
                      ),
                      _buildDropdown(
                        label: 'Preferred Shift',
                        hint: 'Choose shift',
                        icon: Icons.bedtime_outlined,
                        options: _shiftOptions,
                        keyName: 'preferredShift',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.preferredShift = v ?? '';
                          _c('preferredShift').text = v ?? '';
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Preferred Duty Distance (km)',
                        hint: '50',
                        icon: Icons.social_distance_outlined,
                        keyName: 'preferredDutyDistance',
                        keyboard: TextInputType.number,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: (v) => _positiveNum(v, 'Distance'),
                        onChanged: (v) {
                          _draft.preferredDutyDistance =
                              int.tryParse(v.trim()) ?? 0;
                          _markChanged();
                        },
                      ),
                      _buildDropdown(
                        label: 'Preferred Hospital Type',
                        hint: 'Choose type',
                        icon: Icons.apartment_outlined,
                        options: _hospitalTypes,
                        keyName: 'preferredHospitalType',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.preferredHospitalType = v ?? '';
                          _c('preferredHospitalType').text = v ?? '';
                          _markChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Location',
                    icon: Icons.explore_outlined,
                    iconBg: iconSecondaryBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    children: [
                      _buildAutoGps(
                        isDark,
                        textColor,
                        subTextColor,
                        surfaceColor,
                        cardShadow,
                        borderColor,
                      ),
                      _buildField(
                        label: 'Current Location',
                        hint: 'Auto-captured or manual',
                        icon: Icons.my_location_outlined,
                        keyName: 'currentLocation',
                        readOnly: true,
                        suffix: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              tooltip: 'Use GPS',
                              onPressed: _getGps,
                              icon: const Icon(
                                Icons.gps_fixed,
                                color: AppColors.accent,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.currentLocationText = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Home Location',
                        hint: 'Home address coordinates (optional)',
                        icon: Icons.home_outlined,
                        keyName: 'homeLocation',
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        onChanged: (v) {
                          _draft.homeLocationText = v;
                          _markChanged();
                        },
                      ),
                      _buildField(
                        label: 'Preferred Working Radius (km)',
                        hint: '50',
                        icon: Icons.radio_button_checked_outlined,
                        keyName: 'radius',
                        keyboard: TextInputType.number,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        cardShadow: cardShadow,
                        validator: (v) => _positiveNum(v, 'Radius'),
                        onChanged: (v) {
                          _draft.radius = int.tryParse(v.trim()) ?? 0;
                          _markChanged();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _buildSection(
                    title: 'Documents',
                    icon: Icons.folder_copy_outlined,
                    iconBg: iconSecondaryBg,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    children: [
                      _buildDocumentGroup(
                        docType: 'medical_license',
                        label: 'Medical License',
                        icon: Icons.medical_services_outlined,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        cardShadow: cardShadow,
                        borderColor: borderColor,
                        iconBg: iconSecondaryBg,
                      ),
                      _buildDocumentGroup(
                        docType: 'certificates',
                        label: 'Certificates',
                        icon: Icons.card_membership_outlined,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        cardShadow: cardShadow,
                        borderColor: borderColor,
                        iconBg: iconSecondaryBg,
                      ),
                      _buildDocumentGroup(
                        docType: 'government_id',
                        label: 'Government ID',
                        icon: Icons.badge_outlined,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        cardShadow: cardShadow,
                        borderColor: borderColor,
                        iconBg: iconSecondaryBg,
                      ),
                      _buildDocumentGroup(
                        docType: 'research_papers',
                        label: 'Research Papers',
                        icon: Icons.description_outlined,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        cardShadow: cardShadow,
                        borderColor: borderColor,
                        iconBg: iconSecondaryBg,
                      ),
                      _buildDocumentGroup(
                        docType: 'resume',
                        label: 'Resume / CV',
                        icon: Icons.article_outlined,
                        isDark: isDark,
                        textColor: textColor,
                        subTextColor: subTextColor,
                        surfaceColor: surfaceColor,
                        cardShadow: cardShadow,
                        borderColor: borderColor,
                        iconBg: iconSecondaryBg,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 6, 4, 2),
                        child: Text(
                          'Accepted formats: JPG, JPEG, PNG • Max 10MB',
                          style: TextStyle(
                            color: mutedColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(
          isDark,
          bgColor,
          textColor,
          surfaceColor,
          borderColor,
        ),
      ),
    );
  }

  Widget _buildProfilePicture(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    List<BoxShadow> cardShadow,
    Color borderColor,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: cardShadow,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSecondary,
                  border: Border.all(color: borderColor, width: 1.5),
                ),
                child: ClipOval(
                  child: _isUploadingProfile
                      ? const Center(
                          child: SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      : _draft.profilePic.isEmpty
                      ? Icon(
                          Icons.person_outline,
                          size: 42,
                          color: AppColors.accent,
                        )
                      : Image.network(
                          _draft.profilePic,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.person_outline,
                            size: 42,
                            color: AppColors.accent,
                          ),
                        ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: () => _showImagePicker(
                    (camera) => _pickProfilePic(camera),
                    isDark,
                    textColor,
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accent,
                      border: Border.all(color: surfaceColor, width: 2.5),
                      boxShadow: AppColors.accentShadow,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 15,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _draft.name.isEmpty ? 'Profile Picture' : _draft.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'JPG, JPEG, PNG up to 10MB',
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickProfilePic(false),
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: const Text('Gallery'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pickProfilePic(true),
                        icon: const Icon(Icons.camera_alt_outlined, size: 18),
                        label: const Text('Camera'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color textColor,
    required Color subTextColor,
    required List<Widget> children,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(
        dividerColor: Colors.transparent,
        expansionTileTheme: ExpansionTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(4, 4, 4, 10),
          iconColor: AppColors.accent,
          collapsedIconColor: AppColors.accent,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkBorder
                : AppColors.lightBorder,
          ),
          boxShadow: Theme.of(context).brightness == Brightness.dark
              ? <BoxShadow>[]
              : AppColors.softShadow,
        ),
        child: ExpansionTile(
          initiallyExpanded: true,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          title: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          children: [const SizedBox(height: 6), ...children],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required IconData icon,
    required String keyName,
    bool isDark = false,
    int maxLines = 1,
    TextInputType? keyboard,
    bool readOnly = false,
    Widget? suffix,
    required Color textColor,
    required Color subTextColor,
    required Color surfaceColor,
    required Color borderColor,
    required List<BoxShadow> cardShadow,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
          border: Border.all(color: borderColor),
        ),
        child: TextFormField(
          controller: _c(keyName),
          focusNode: _f(keyName),
          readOnly: readOnly,
          keyboardType: keyboard,
          maxLines: maxLines,
          validator: validator,
          onChanged: onChanged,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: TextStyle(
              color: subTextColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: AppColors.accent, size: 22),
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGender(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    List<BoxShadow> cardShadow,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
          border: Border.all(color: borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.accent, size: 22),
                const SizedBox(width: 10),
                Text(
                  'Gender',
                  style: TextStyle(
                    color: subTextColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _genderOptions
                  .map(
                    (g) => GestureDetector(
                      onTap: () {
                        setState(() => _draft.gender = g);
                        _markChanged();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _draft.gender == g
                              ? AppColors.accent
                              : (isDark
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.lightSurfaceVariant),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _draft.gender == g
                                ? AppColors.accent
                                : borderColor,
                          ),
                        ),
                        child: Text(
                          g,
                          style: TextStyle(
                            color: _draft.gender == g
                                ? AppColors.white
                                : textColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDob(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    List<BoxShadow> cardShadow,
    Color borderColor,
  ) {
    final dob = _draft.dob;
    final formatted = dob == null
        ? ''
        : DateFormat('EEE, MMM d, yyyy').format(dob);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
          border: Border.all(color: borderColor),
        ),
        child: InkWell(
          onTap: _pickDob,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.accent, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date of Birth',
                        style: TextStyle(
                          color: subTextColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatted.isEmpty
                            ? 'Select your date of birth'
                            : formatted,
                        style: TextStyle(
                          color: formatted.isEmpty ? subTextColor : textColor,
                          fontWeight: formatted.isEmpty
                              ? FontWeight.w500
                              : FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: subTextColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> options,
    required String keyName,
    bool isDark = false,
    required Color textColor,
    required Color subTextColor,
    required Color surfaceColor,
    required Color borderColor,
    required List<BoxShadow> cardShadow,
    void Function(String?)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
          border: Border.all(color: borderColor),
        ),
        child: DropdownButtonFormField<String>(
          key: ValueKey('dd_$keyName'),
          initialValue: options.contains(_c(keyName).text)
              ? _c(keyName).text
              : null,
          onChanged: onChanged,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          icon: Icon(Icons.expand_more, color: AppColors.accent),
          dropdownColor: surfaceColor,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle: TextStyle(
              color: subTextColor,
              fontWeight: FontWeight.w500,
            ),
            floatingLabelStyle: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w600,
            ),
            prefixIcon: Icon(icon, color: AppColors.accent, size: 22),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
            ),
            filled: true,
            fillColor: Colors.transparent,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
          items: options
              .map(
                (o) => DropdownMenuItem(
                  value: o,
                  child: Text(
                    o,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildWorkingDays(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceVariant,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month_outlined,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                'Working Days',
                style: TextStyle(
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _daysOptions.map((d) {
              final selected = _draft.workingDays.contains(d);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (selected) {
                      _draft.workingDays.remove(d);
                    } else {
                      _draft.workingDays.add(d);
                    }
                  });
                  _markChanged();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 48,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.accent : surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? AppColors.accent
                          : (isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    d.substring(0, 3),
                    style: TextStyle(
                      color: selected ? AppColors.white : textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoGps(
    bool isDark,
    Color textColor,
    Color subTextColor,
    Color surfaceColor,
    List<BoxShadow> cardShadow,
    Color borderColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow,
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.gps_fixed,
                color: AppColors.accent,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Auto GPS Capture',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Automatically capture current location via GPS when saving',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _draft.autoGps,
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
              onChanged: (v) {
                setState(() => _draft.autoGps = v);
                _markChanged();
                if (v) _getGps();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentGroup({
    required String docType,
    required String label,
    required IconData icon,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color surfaceColor,
    required List<BoxShadow> cardShadow,
    required Color borderColor,
    required Color iconBg,
  }) {
    final docs = _draft.documents[docType] ?? [];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${docs.length} uploaded',
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () =>
                          _pickDocument(documentType: docType, camera: false),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.photo_library_outlined,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () =>
                          _pickDocument(documentType: docType, camera: true),
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.camera_alt_outlined,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (docs.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: docs
                    .map(
                      (d) => _buildDocChip(
                        d,
                        docType,
                        isDark,
                        textColor,
                        surfaceColor,
                        borderColor,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDocChip(
    _DocDraft doc,
    String docType,
    bool isDark,
    Color textColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    final ok = doc.cloudinaryUrl != null && doc.cloudinaryUrl!.isNotEmpty;
    final err = doc.uploadError != null && doc.uploadError!.isNotEmpty;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: err
              ? AppColors.error
              : doc.uploading
              ? AppColors.warning
              : ok
              ? AppColors.success
              : borderColor,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AspectRatio(
              aspectRatio: 1.4,
              child: Container(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                child: doc.uploading
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: AppColors.accent,
                            strokeWidth: 2,
                          ),
                        ),
                      )
                    : err
                    ? const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 26,
                        ),
                      )
                    : (doc.localPath != null &&
                          File(doc.localPath!).existsSync())
                    ? Image.file(File(doc.localPath!), fit: BoxFit.cover)
                    : ok
                    ? Image.network(
                        doc.cloudinaryUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.picture_as_pdf,
                            color: AppColors.accent,
                            size: 26,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.folder_open,
                          color: AppColors.accent,
                          size: 26,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            doc.name.length > 16 ? '${doc.name.substring(0, 15)}…' : doc.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            err
                ? 'Error'
                : doc.uploading
                ? 'Uploading…'
                : ok
                ? 'Uploaded'
                : 'Pending',
            style: TextStyle(
              color: err
                  ? AppColors.error
                  : doc.uploading
                  ? AppColors.warning
                  : AppColors.success,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 30,
            child: OutlinedButton.icon(
              onPressed: () => _removeDoc(docType, doc.id),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(horizontal: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.close, size: 14),
              label: const Text(
                'Remove',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(
    bool isDark,
    Color bgColor,
    Color textColor,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: isDark
            ? <BoxShadow>[]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  if (_isSaving) return;
                  if (!_hasUnsavedChanges) {
                    await _clearDraft();
                    if (mounted) Navigator.pop(context);
                    return;
                  }
                  final discard =
                      await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Discard Changes?'),
                          content: const Text(
                            'Are you sure you want to discard all unsaved edits?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.error,
                              ),
                              child: const Text('Discard'),
                            ),
                          ],
                        ),
                      ) ??
                      false;
                  if (discard) {
                    await _clearDraft();
                    if (mounted) Navigator.pop(context);
                  }
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  side: BorderSide(color: borderColor),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (_isSaving) return;
                  final ok = await _saveAll();
                  if (ok && mounted) Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  shadowColor: AppColors.accent.withValues(alpha: 0.35),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check, size: 18),
                label: Text(
                  _isSaving ? 'Saving…' : 'Save Changes',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImagePicker(
    Future<void> Function(bool camera) onPick,
    bool isDark,
    Color textColor,
  ) async {
    final opt = await showModalBottomSheet<int>(
      context: context,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Take Photo',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Open camera to capture photo',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 6),
              ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.photo_library_outlined,
                    color: AppColors.accent,
                    size: 24,
                  ),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  'Select from photos gallery',
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
    if (opt != null) {
      await onPick(opt == 1);
    }
  }
}
