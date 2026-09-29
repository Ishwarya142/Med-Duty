import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

// ---------------------------------------------------------------------------
// Country data
// ---------------------------------------------------------------------------
const List<Map<String, String>> _kCountries = [
  {'name': 'India', 'flag': '🇮🇳', 'dialCode': '+91'},
  {'name': 'United States', 'flag': '🇺🇸', 'dialCode': '+1'},
  {'name': 'United Kingdom', 'flag': '🇬🇧', 'dialCode': '+44'},
  {'name': 'Canada', 'flag': '🇨🇦', 'dialCode': '+1'},
  {'name': 'Australia', 'flag': '🇦🇺', 'dialCode': '+61'},
  {'name': 'Germany', 'flag': '🇩🇪', 'dialCode': '+49'},
  {'name': 'France', 'flag': '🇫🇷', 'dialCode': '+33'},
  {'name': 'United Arab Emirates', 'flag': '🇦🇪', 'dialCode': '+971'},
  {'name': 'Saudi Arabia', 'flag': '🇸🇦', 'dialCode': '+966'},
  {'name': 'Singapore', 'flag': '🇸🇬', 'dialCode': '+65'},
  {'name': 'New Zealand', 'flag': '🇳🇿', 'dialCode': '+64'},
  {'name': 'South Africa', 'flag': '🇿🇦', 'dialCode': '+27'},
  {'name': 'Japan', 'flag': '🇯🇵', 'dialCode': '+81'},
  {'name': 'China', 'flag': '🇨🇳', 'dialCode': '+86'},
  {'name': 'Brazil', 'flag': '🇧🇷', 'dialCode': '+55'},
];

// ---------------------------------------------------------------------------
// Indian states/UTs
// ---------------------------------------------------------------------------
const List<String> _kIndianStates = [
  'Andhra Pradesh', 'Arunachal Pradesh', 'Assam', 'Bihar', 'Chhattisgarh',
  'Goa', 'Gujarat', 'Haryana', 'Himachal Pradesh', 'Jharkhand', 'Karnataka',
  'Kerala', 'Madhya Pradesh', 'Maharashtra', 'Manipur', 'Meghalaya', 'Mizoram',
  'Nagaland', 'Odisha', 'Punjab', 'Rajasthan', 'Sikkim', 'Tamil Nadu',
  'Telangana', 'Tripura', 'Uttar Pradesh', 'Uttarakhand', 'West Bengal',
  // Union Territories
  'Andaman and Nicobar Islands', 'Chandigarh',
  'Dadra and Nagar Haveli and Daman and Diu', 'Delhi', 'Jammu and Kashmir',
  'Ladakh', 'Lakshadweep', 'Puducherry',
];

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _isGpsLoading = false;
  String? _uploadingDocType; // tracks which specific document type is being uploaded

  // 7 expansion tiles: Personal, Professional, Availability, Location,
  //                    Documents, Achievements, Social
  final List<bool> _expansionStates = [true, false, false, false, false, false, false];

  // ---- Text controllers ----
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _qualificationController;
  late TextEditingController _degreeController;
  late TextEditingController _medRegController;
  late TextEditingController _medCouncilController;
  late TextEditingController _specializationController;
  late TextEditingController _superSpecController;
  late TextEditingController _departmentController;
  late TextEditingController _experienceController;
  late TextEditingController _currentHospitalController;
  late TextEditingController _workingHoursController;
  late TextEditingController _dutyDistanceController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _linkedinController;
  late TextEditingController _websiteController;
  late TextEditingController _researchgateController;
  late TextEditingController _orcidController;
  late TextEditingController _addLanguageController;
  late TextEditingController _addSkillController;
  late TextEditingController _addAwardController;
  late TextEditingController _addPublicationController;
  late TextEditingController _addConferenceController;
  late TextEditingController _addMembershipController;

  // ---- Non-controller state ----
  String? _selectedGender;
  DateTime? _selectedDob;
  String _selectedDialCode = '+91';
  String _selectedCountryFlag = '🇮🇳';
  String? _selectedShift;
  String? _selectedHospitalType;
  String? _selectedRegState;
  List<String> _workingDays = [];
  bool _availableForDuties = true;
  bool _emergencyAvailable = false;
  double? _pinnedLatitude;
  double? _pinnedLongitude;

  // Chip lists
  List<String> _languages = [];
  List<String> _skills = [];
  List<String> _awards = [];
  final List<String> _publications = [];
  final List<String> _conferences = [];
  final List<String> _memberships = [];

  // Unsaved-changes detection snapshot
  late Map<String, String> _initialValues;

  // Map pin sheet camera position
  LatLng _mapCenter = const LatLng(20.5937, 78.9629); // India center default

  @override
  void initState() {
    super.initState();
    final p = Provider.of<ProfileProvider>(context, listen: false);

    _nameController = TextEditingController(text: p.name);
    _emailController = TextEditingController(text: p.email);
    _phoneController = TextEditingController(text: p.phone);
    _bioController = TextEditingController(text: p.bio);
    _qualificationController = TextEditingController(text: p.qualification);
    _degreeController = TextEditingController(text: p.degree);
    _medRegController = TextEditingController(text: p.medicalRegistrationNumber);
    _medCouncilController = TextEditingController(text: p.medicalCouncil);
    _specializationController = TextEditingController(text: p.specialization);
    _superSpecController = TextEditingController(text: p.superSpecialization ?? '');
    _departmentController = TextEditingController(text: p.department);
    _experienceController = TextEditingController(text: p.experience > 0 ? '${p.experience}' : '');
    _currentHospitalController = TextEditingController(text: p.currentHospital);
    _workingHoursController = TextEditingController(text: p.workingHours);
    _dutyDistanceController = TextEditingController(
        text: p.preferredDutyDistance > 0 ? '${p.preferredDutyDistance}' : '');
    _addressController = TextEditingController(text: p.address);
    _cityController = TextEditingController(text: p.currentCity);
    _stateController = TextEditingController(text: p.state);
    _countryController = TextEditingController(text: p.country);
    _linkedinController = TextEditingController(text: p.linkedinUrl);
    _websiteController = TextEditingController(text: p.websiteUrl);
    _researchgateController = TextEditingController(text: p.researchgateUrl);
    _orcidController = TextEditingController(text: p.orcidUrl);
    _addLanguageController = TextEditingController();
    _addSkillController = TextEditingController();
    _addAwardController = TextEditingController();
    _addPublicationController = TextEditingController();
    _addConferenceController = TextEditingController();
    _addMembershipController = TextEditingController();

    _selectedGender = (p.gender != null && p.gender!.isNotEmpty) ? p.gender : null;
    _selectedDob = p.dateOfBirth;
    _availableForDuties = p.availableForDuties;
    _emergencyAvailable = p.emergencyAvailable;
    _workingDays = List<String>.from(p.workingDays);
    _selectedShift = p.preferredShift.isNotEmpty ? p.preferredShift : null;
    _selectedHospitalType = p.preferredHospitalType.isNotEmpty ? p.preferredHospitalType : null;
    _selectedRegState = p.medicalRegistration.state.isNotEmpty ? p.medicalRegistration.state : null;
    _languages = List<String>.from(p.languages);
    _skills = List<String>.from(p.skills);
    _awards = List<String>.from(p.achievements);

    if (p.currentLatitude != null && p.currentLongitude != null) {
      _mapCenter = LatLng(p.currentLatitude!, p.currentLongitude!);
      _pinnedLatitude = p.currentLatitude;
      _pinnedLongitude = p.currentLongitude;
    }

    _initialValues = _snapshot();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _qualificationController.dispose();
    _degreeController.dispose();
    _medRegController.dispose();
    _medCouncilController.dispose();
    _specializationController.dispose();
    _superSpecController.dispose();
    _departmentController.dispose();
    _experienceController.dispose();
    _currentHospitalController.dispose();
    _workingHoursController.dispose();
    _dutyDistanceController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _linkedinController.dispose();
    _websiteController.dispose();
    _researchgateController.dispose();
    _orcidController.dispose();
    _addLanguageController.dispose();
    _addSkillController.dispose();
    _addAwardController.dispose();
    _addPublicationController.dispose();
    _addConferenceController.dispose();
    _addMembershipController.dispose();
    super.dispose();
  }

  // ---- Snapshot for unsaved-changes detection ----
  Map<String, String> _snapshot() {
    return {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
      'bio': _bioController.text,
      'qualification': _qualificationController.text,
      'degree': _degreeController.text,
      'medReg': _medRegController.text,
      'medCouncil': _medCouncilController.text,
      'specialization': _specializationController.text,
      'superSpec': _superSpecController.text,
      'department': _departmentController.text,
      'experience': _experienceController.text,
      'hospital': _currentHospitalController.text,
      'workingHours': _workingHoursController.text,
      'dutyDistance': _dutyDistanceController.text,
      'address': _addressController.text,
      'city': _cityController.text,
      'state': _stateController.text,
      'country': _countryController.text,
      'linkedin': _linkedinController.text,
      'website': _websiteController.text,
      'researchgate': _researchgateController.text,
      'orcid': _orcidController.text,
      'gender': _selectedGender ?? '',
      'dob': _selectedDob?.toIso8601String() ?? '',
      'shift': _selectedShift ?? '',
      'hospitalType': _selectedHospitalType ?? '',
      'regState': _selectedRegState ?? '',
      'dialCode': _selectedDialCode,
      'available': _availableForDuties.toString(),
      'emergency': _emergencyAvailable.toString(),
      'days': _workingDays.join(','),
      'languages': _languages.join(','),
      'skills': _skills.join(','),
      'awards': _awards.join(','),
      'publications': _publications.join(','),
      'conferences': _conferences.join(','),
      'memberships': _memberships.join(','),
    };
  }

  bool _hasUnsavedChanges() {
    final current = _snapshot();
    return current.entries.any((e) => _initialValues[e.key] != e.value);
  }

  // ---- Save profile ----
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final p = Provider.of<ProfileProvider>(context, listen: false);
      await p.updateProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: '$_selectedDialCode${_phoneController.text.trim()}',
        bio: _bioController.text.trim(),
        gender: _selectedGender,
        dateOfBirth: _selectedDob,
        qualification: _qualificationController.text.trim(),
        degree: _degreeController.text.trim(),
        medicalRegistrationNumber: _medRegController.text.trim(),
        medicalCouncil: _medCouncilController.text.trim(),
        specialization: _specializationController.text.trim(),
        superSpecialization: _superSpecController.text.trim(),
        department: _departmentController.text.trim(),
        experience: int.tryParse(_experienceController.text.trim()) ?? 0,
        currentHospital: _currentHospitalController.text.trim(),
        availableForDuties: _availableForDuties,
        emergencyAvailable: _emergencyAvailable,
        workingDays: _workingDays,
        workingHours: _workingHoursController.text.trim(),
        preferredShift: _selectedShift ?? '',
        preferredDutyDistance: int.tryParse(_dutyDistanceController.text.trim()) ?? 50,
        preferredHospitalType: _selectedHospitalType ?? '',
        address: _addressController.text.trim(),
        currentCity: _cityController.text.trim(),
        state: _stateController.text.trim(),
        country: _countryController.text.trim(),
        currentLatitude: _pinnedLatitude,
        currentLongitude: _pinnedLongitude,
        languages: _languages,
        skills: _skills,
        linkedinUrl: _linkedinController.text.trim(),
        websiteUrl: _websiteController.text.trim(),
        researchgateUrl: _researchgateController.text.trim(),
        orcidUrl: _orcidController.text.trim(),
      );
      await p.updateAchievements(_awards);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ---- GPS auto-detect ----
  Future<void> _autoDetectLocation() async {
    setState(() => _isGpsLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      setState(() {
        _pinnedLatitude = pos.latitude;
        _pinnedLongitude = pos.longitude;
        _mapCenter = LatLng(pos.latitude, pos.longitude);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location detected successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not detect location: $e')),
      );
    } finally {
      if (mounted) setState(() => _isGpsLoading = false);
    }
  }

  // ---- Country code bottom sheet ----
  void _showCountryCodeSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final searchController = TextEditingController();
    List<Map<String, String>> filtered = List.from(_kCountries);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setSheet) {
          return Container(
            height: MediaQuery.of(ctx2).size.height * 0.70,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Select Country Code',
                      style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: surfaceVariant,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    ),
                    onChanged: (v) {
                      setSheet(() {
                        filtered = _kCountries.where((c) =>
                          c['name']!.toLowerCase().contains(v.toLowerCase()) ||
                          c['dialCode']!.contains(v)).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (_, i) {
                      final c = filtered[i];
                      return ListTile(
                        leading: Text(c['flag']!, style: const TextStyle(fontSize: 24)),
                        title: Text(c['name']!, style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
                        trailing: Text(c['dialCode']!, style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                        onTap: () {
                          setState(() {
                            _selectedDialCode = c['dialCode']!;
                            _selectedCountryFlag = c['flag']!;
                          });
                          Navigator.pop(ctx2);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ---- Map pin bottom sheet ----
  void _showMapPinSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    LatLng tempCenter = _mapCenter;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setSheet) {
          return Container(
            height: MediaQuery.of(ctx2).size.height * 0.70,
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Row(
                    children: [
                      Expanded(child: Text('Pin Your Location',
                          style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800))),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx2)),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(target: tempCenter, zoom: 14),
                    onCameraMove: (pos) {
                      setSheet(() => tempCenter = pos.target);
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('pin'),
                        position: tempCenter,
                        draggable: true,
                        onDragEnd: (pos) => setSheet(() => tempCenter = pos),
                      ),
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pinnedLatitude = tempCenter.latitude;
                          _pinnedLongitude = tempCenter.longitude;
                          _mapCenter = tempCenter;
                        });
                        Navigator.pop(ctx2);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Location pinned successfully')),
                        );
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Confirm Location'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  // ---- Image picker dialog (reused from original) ----
  Future<void> _showImagePickerDialog({
    required bool isProfilePic,
    required ProfileProvider profileProvider,
    required bool isDark,
    required Color textColor,
    required Color surfaceColor,
    required Color surfaceVariant,
    required List<BoxShadow> cardShadow,
    required Color iconSecondaryBg,
  }) async {
    profileProvider.resetUploadState();
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  isProfilePic ? 'Update Profile Photo' : 'Update Cover Photo',
                  style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 22),
                _buildSheetOptionTile(
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (isProfilePic) {
                      await profileProvider.uploadProfilePicture(source: ImageSource.camera);
                    } else {
                      await profileProvider.uploadCoverPicture(source: ImageSource.camera);
                    }
                  },
                  iconBg: iconSecondaryBg,
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  surfaceVariant: surfaceVariant,
                  cardShadow: cardShadow,
                  textColor: textColor,
                ),
                const SizedBox(height: 12),
                _buildSheetOptionTile(
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (isProfilePic) {
                      await profileProvider.uploadProfilePicture(source: ImageSource.gallery);
                    } else {
                      await profileProvider.uploadCoverPicture(source: ImageSource.gallery);
                    }
                  },
                  iconBg: iconSecondaryBg,
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  surfaceVariant: surfaceVariant,
                  cardShadow: cardShadow,
                  textColor: textColor,
                ),
                if ((isProfilePic && profileProvider.profilePic.isNotEmpty) ||
                    (!isProfilePic && profileProvider.coverPic.isNotEmpty)) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () async {
                      Navigator.pop(ctx);
                      if (isProfilePic) {
                        await profileProvider.removeProfilePicture();
                      } else {
                        await profileProvider.removeCoverPicture();
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: isDark ? 0.12 : 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.delete_outline, color: AppColors.error, size: 24),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: Text('Remove Photo',
                              style: TextStyle(color: AppColors.error, fontSize: 16, fontWeight: FontWeight.w700))),
                          const Icon(Icons.arrow_forward_ios, color: AppColors.error, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetOptionTile({
    required VoidCallback onTap,
    required Color iconBg,
    required IconData icon,
    required String title,
    required Color surfaceVariant,
    required List<BoxShadow> cardShadow,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(color: surfaceVariant, borderRadius: BorderRadius.circular(16), boxShadow: cardShadow),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700))),
            const Icon(Icons.arrow_forward_ios, color: AppColors.accent, size: 18),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // BUILD
  // =========================================================================
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final iconSecondaryBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSecondary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardShadow = isDark ? <BoxShadow>[] : AppColors.softShadow;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (!_hasUnsavedChanges()) {
          Navigator.pop(context);
          return;
        }
        final discard = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('You have unsaved changes. Are you sure you want to leave?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep Editing'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Discard', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        );
        if ((discard ?? false) && context.mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: bgColor,
        appBar: AppBar(
          title: Text('Edit Profile',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 20)),
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: textColor, size: 24),
            onPressed: () async {
              if (!_hasUnsavedChanges()) { Navigator.pop(context); return; }
              final discard = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Discard changes?'),
                  content: const Text('You have unsaved changes. Are you sure you want to leave?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep Editing')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Discard', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              );
              if ((discard ?? false) && context.mounted) Navigator.pop(context);
            },
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          ),
        ),
        bottomNavigationBar: _buildSaveBottomBar(surfaceColor),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // Photo header
              _buildPhotoSection(
                profileProvider, isDark, textColor, surfaceColor,
                surfaceVariant, borderColor, cardShadow, iconSecondaryBg,
              ),
              const SizedBox(height: 8),
              // 1. Personal Information
              _buildExpansionSection(0, 'Personal Information', Icons.person_outline, [
                _buildPersonalInfoSection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 2. Professional Summary
              _buildExpansionSection(1, 'Professional Summary', Icons.workspace_premium_outlined, [
                _buildProfessionalSection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 3. Availability
              _buildExpansionSection(2, 'Availability', Icons.access_time_outlined, [
                _buildAvailabilitySection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 4. Location
              _buildExpansionSection(3, 'Location', Icons.location_on_outlined, [
                _buildLocationSection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 5. Documents
              _buildExpansionSection(4, 'Documents', Icons.description_outlined, [
                _buildDocumentsSection(profileProvider, isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 6. Achievements
              _buildExpansionSection(5, 'Achievements', Icons.emoji_events_outlined, [
                _buildAchievementsSection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 12),
              // 7. Social Links
              _buildExpansionSection(6, 'Social Links', Icons.link_outlined, [
                _buildSocialLinksSection(isDark, textColor, subTextColor, borderColor),
              ], isDark, textColor, borderColor, cardShadow),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // SAVE BOTTOM BAR
  // =========================================================================
  Widget _buildSaveBottomBar(Color surfaceColor) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
            child: _isSaving
                ? const SizedBox(width: 24, height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                : const Text('Save Changes',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // EXPANSION SECTION BUILDER
  // =========================================================================
  Widget _buildExpansionSection(
    int index,
    String title,
    IconData icon,
    List<Widget> children,
    bool isDark,
    Color textColor,
    Color borderColor,
    List<BoxShadow> cardShadow,
  ) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: cardShadow,
        border: Border.all(color: borderColor.withValues(alpha: 0.6), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          initiallyExpanded: _expansionStates[index],
          onExpansionChanged: (v) => setState(() => _expansionStates[index] = v),
          leading: Icon(icon, color: AppColors.accent, size: 24),
          title: Text(title,
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w700)),
          trailing: Icon(
            _expansionStates[index] ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: AppColors.accent,
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }

  // =========================================================================
  // PHOTO SECTION (identical behavior to original)
  // =========================================================================
  Widget _buildPhotoSection(
    ProfileProvider profileProvider,
    bool isDark,
    Color textColor,
    Color surfaceColor,
    Color surfaceVariant,
    Color borderColor,
    List<BoxShadow> cardShadow,
    Color iconSecondaryBg,
  ) {
    return Column(
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: cardShadow,
          ),
          child: Stack(
            children: [
              if (profileProvider.localCoverPicPath != null && !kIsWeb)
                ClipRRect(borderRadius: BorderRadius.circular(24),
                    child: Image.file(File(profileProvider.localCoverPicPath!),
                        fit: BoxFit.cover, width: double.infinity, height: double.infinity))
              else if (profileProvider.coverPic.isNotEmpty)
                ClipRRect(borderRadius: BorderRadius.circular(24),
                    child: Image.network(profileProvider.coverPic,
                        fit: BoxFit.cover, width: double.infinity, height: double.infinity)),
              Positioned(
                bottom: 12, right: 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showImagePickerDialog(
                      isProfilePic: false, profileProvider: profileProvider,
                      isDark: isDark, textColor: textColor, surfaceColor: surfaceColor,
                      surfaceVariant: surfaceVariant, cardShadow: cardShadow, iconSecondaryBg: iconSecondaryBg,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accent, shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: profileProvider.isUploading
                          ? const SizedBox(width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -60),
          child: Center(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 130, height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle, color: iconSecondaryBg,
                    border: Border.all(color: surfaceColor, width: 6),
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: (profileProvider.localProfilePicPath != null && !kIsWeb)
                      ? ClipOval(child: Image.file(File(profileProvider.localProfilePicPath!), fit: BoxFit.cover, width: 130, height: 130))
                      : profileProvider.profilePic.isNotEmpty
                          ? ClipOval(child: Image.network(profileProvider.profilePic, fit: BoxFit.cover, width: 130, height: 130))
                          : const Icon(Icons.person, size: 70, color: AppColors.accent),
                ),
                Positioned(
                  bottom: -4, right: -4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showImagePickerDialog(
                        isProfilePic: true, profileProvider: profileProvider,
                        isDark: isDark, textColor: textColor, surfaceColor: surfaceColor,
                        surfaceVariant: surfaceVariant, cardShadow: cardShadow, iconSecondaryBg: iconSecondaryBg,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.accent, shape: BoxShape.circle,
                          border: Border.all(color: surfaceColor, width: 4),
                          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 6))],
                        ),
                        child: profileProvider.isUploading
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                            : const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (profileProvider.isUploading || profileProvider.uploadError != null || profileProvider.uploadSuccess)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12, right: 12),
            child: Column(
              children: [
                if (profileProvider.isUploading)
                  Column(children: [
                    Text('Uploading: ${(profileProvider.uploadProgress * 100).toStringAsFixed(0)}%'),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(value: profileProvider.uploadProgress,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent)),
                  ]),
                if (profileProvider.uploadError != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error, width: 1),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(profileProvider.uploadError!, style: const TextStyle(color: AppColors.error, fontSize: 14))),
                    ]),
                  ),
                if (profileProvider.uploadSuccess)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent, width: 1),
                    ),
                    child: Row(children: [
                      const Icon(Icons.check_circle_outline, color: AppColors.accent, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Uploaded successfully!',
                          style: TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w600))),
                    ]),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  // =========================================================================
  // RESPONSIVE TWO-COLUMN HELPER
  // =========================================================================
  Widget _buildFieldRow(List<Widget> fields) {
    return LayoutBuilder(builder: (ctx, constraints) {
      if (constraints.maxWidth > 600) {
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: fields.map((f) => SizedBox(
              width: (constraints.maxWidth - 12) / 2, child: f)).toList(),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: f)).toList(),
      );
    });
  }

  // =========================================================================
  // CHIP INPUT BUILDER
  // =========================================================================
  Widget _buildChipInput({
    required List<String> items,
    required TextEditingController controller,
    required String label,
    required void Function(String) onAdd,
    required void Function(String) onDelete,
    required bool isDark,
    required Color textColor,
    required Color borderColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (items.isNotEmpty)
          Wrap(
            spacing: 8, runSpacing: 4,
            children: items.map((item) => InputChip(
              label: Text(item),
              onDeleted: () => onDelete(item),
              backgroundColor: AppColors.accent.withValues(alpha: isDark ? 0.18 : 0.10),
              labelStyle: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13),
              deleteIconColor: AppColors.accent,
              side: BorderSide(color: AppColors.accent.withValues(alpha: 0.3)),
            )).toList(),
          ),
        if (items.isNotEmpty) const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: 'Add $label',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onFieldSubmitted: (v) {
                  if (v.trim().isNotEmpty) {
                    if (items.contains(v.trim())) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('$v already added')),
                      );
                    } else {
                      onAdd(v.trim());
                      controller.clear();
                    }
                  }
                },
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppColors.accent, size: 28),
              onPressed: () {
                final v = controller.text.trim();
                if (v.isEmpty) return;
                if (items.contains(v)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$v already added')),
                  );
                } else {
                  onAdd(v);
                  controller.clear();
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Personal Information
  // =========================================================================
  Widget _buildPersonalInfoSection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Full Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
          textCapitalization: TextCapitalization.words,
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
        ),
        const SizedBox(height: 12),
        // Gender
        Text('Gender', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          emptySelectionAllowed: true,
          segments: const [
            ButtonSegment(value: 'Male', label: Text('Male'), icon: Icon(Icons.male)),
            ButtonSegment(value: 'Female', label: Text('Female'), icon: Icon(Icons.female)),
            ButtonSegment(value: 'Other', label: Text('Other'), icon: Icon(Icons.transgender)),
          ],
          selected: _selectedGender != null && const {'Male', 'Female', 'Other'}.contains(_selectedGender)
              ? {_selectedGender!}
              : const <String>{},
          onSelectionChanged: (s) => setState(() => _selectedGender = s.isNotEmpty ? s.first : null),
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.accent;
              return isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) return AppColors.white;
              return textColor;
            }),
          ),
        ),
        const SizedBox(height: 12),
        // Date of Birth
        TextFormField(
          readOnly: true,
          controller: TextEditingController(
            text: _selectedDob != null ? DateFormat('dd/MM/yyyy').format(_selectedDob!) : '',
          ),
          decoration: const InputDecoration(
            labelText: 'Date of Birth',
            prefixIcon: Icon(Icons.cake_outlined),
            hintText: 'dd/MM/yyyy',
          ),
          onTap: () async {
            final today = DateTime.now();
            final maxDate = DateTime(today.year - 18, today.month, today.day);
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDob ?? maxDate,
              firstDate: DateTime(1900),
              lastDate: maxDate,
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: Theme.of(ctx).colorScheme.copyWith(primary: AppColors.accent),
                ),
                child: child!,
              ),
            );
            if (picked != null) setState(() => _selectedDob = picked);
          },
        ),
        const SizedBox(height: 12),
        // Email
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          keyboardType: TextInputType.emailAddress,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            final regex = RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$');
            return regex.hasMatch(v.trim()) ? null : 'Enter a valid email';
          },
        ),
        const SizedBox(height: 12),
        // Phone with country code
        Row(
          children: [
            GestureDetector(
              onTap: _showCountryCodeSheet,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_selectedCountryFlag, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(_selectedDialCode,
                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.accent, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Languages
        Text('Languages', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildChipInput(
          items: _languages,
          controller: _addLanguageController,
          label: 'Language',
          onAdd: (v) => setState(() => _languages.add(v)),
          onDelete: (v) => setState(() => _languages.remove(v)),
          isDark: isDark,
          textColor: textColor,
          borderColor: borderColor,
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Professional Summary
  // =========================================================================
  Widget _buildProfessionalSection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldRow([
          TextFormField(
            controller: _qualificationController,
            decoration: const InputDecoration(labelText: 'Qualification', prefixIcon: Icon(Icons.school_outlined)),
          ),
          TextFormField(
            controller: _degreeController,
            decoration: const InputDecoration(labelText: 'Degree', prefixIcon: Icon(Icons.menu_book_outlined)),
          ),
        ]),
        const SizedBox(height: 12),
        _buildFieldRow([
          TextFormField(
            controller: _medRegController,
            decoration: const InputDecoration(labelText: 'Medical Registration No.', prefixIcon: Icon(Icons.badge_outlined)),
          ),
          TextFormField(
            controller: _medCouncilController,
            decoration: const InputDecoration(
              labelText: 'Medical Council',
              prefixIcon: Icon(Icons.account_balance_outlined),
              hintText: 'e.g. Maharashtra Medical Council',
            ),
          ),
        ]),
        const SizedBox(height: 12),
        // State of Registration dropdown
        DropdownButtonFormField<String>(
          initialValue: _selectedRegState,
          decoration: const InputDecoration(labelText: 'State of Registration', prefixIcon: Icon(Icons.map_outlined)),
          items: _kIndianStates.map((s) => DropdownMenuItem<String>(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _selectedRegState = v),
          isExpanded: true,
        ),
        const SizedBox(height: 12),
        _buildFieldRow([
          TextFormField(
            controller: _specializationController,
            decoration: const InputDecoration(labelText: 'Specialization', prefixIcon: Icon(Icons.biotech_outlined)),
          ),
          TextFormField(
            controller: _superSpecController,
            decoration: const InputDecoration(labelText: 'Super Specialization', prefixIcon: Icon(Icons.star_outline)),
          ),
        ]),
        const SizedBox(height: 12),
        _buildFieldRow([
          TextFormField(
            controller: _departmentController,
            decoration: const InputDecoration(labelText: 'Department', prefixIcon: Icon(Icons.local_hospital_outlined)),
          ),
          TextFormField(
            controller: _experienceController,
            decoration: const InputDecoration(labelText: 'Experience (years)', prefixIcon: Icon(Icons.work_history_outlined)),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _currentHospitalController,
          decoration: const InputDecoration(labelText: 'Current Hospital', prefixIcon: Icon(Icons.business_outlined)),
        ),
        const SizedBox(height: 12),
        // Skills
        Text('Skills', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _buildChipInput(
          items: _skills,
          controller: _addSkillController,
          label: 'Skill',
          onAdd: (v) => setState(() => _skills.add(v)),
          onDelete: (v) => setState(() => _skills.remove(v)),
          isDark: isDark,
          textColor: textColor,
          borderColor: borderColor,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _bioController,
          decoration: const InputDecoration(
            labelText: 'About Me / Bio',
            prefixIcon: Icon(Icons.info_outline),
            alignLabelWithHint: true,
          ),
          minLines: 3,
          maxLines: 6,
          keyboardType: TextInputType.multiline,
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Availability
  // =========================================================================
  Widget _buildAvailabilitySection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text('Available for Duties', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          value: _availableForDuties,
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _availableForDuties = v),
        ),
        SwitchListTile(
          title: Text('Emergency Available', style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
          value: _emergencyAvailable,
          activeThumbColor: AppColors.accent,
          activeTrackColor: AppColors.accent.withValues(alpha: 0.4),
          contentPadding: EdgeInsets.zero,
          onChanged: (v) => setState(() => _emergencyAvailable = v),
        ),
        const SizedBox(height: 4),
        Text('Working Days', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: days.map((day) {
            final selected = _workingDays.contains(day);
            return FilterChip(
              label: Text(day),
              selected: selected,
              onSelected: (v) {
                setState(() {
                  if (v) { _workingDays.add(day); } else { _workingDays.remove(day); }
                });
              },
              selectedColor: AppColors.accent.withValues(alpha: 0.18),
              checkmarkColor: AppColors.accent,
              labelStyle: TextStyle(
                color: selected ? AppColors.accent : textColor,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
              side: BorderSide(color: selected ? AppColors.accent : borderColor),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _workingHoursController,
          decoration: const InputDecoration(
            labelText: 'Working Hours',
            prefixIcon: Icon(Icons.schedule_outlined),
            hintText: 'e.g. 9 AM - 5 PM',
          ),
        ),
        const SizedBox(height: 12),
        _buildFieldRow([
          DropdownButtonFormField<String>(
            initialValue: _selectedShift,
            decoration: const InputDecoration(labelText: 'Preferred Shift', prefixIcon: Icon(Icons.wb_twilight_outlined)),
            items: const [
              DropdownMenuItem(value: 'Morning', child: Text('Morning')),
              DropdownMenuItem(value: 'Afternoon', child: Text('Afternoon')),
              DropdownMenuItem(value: 'Evening', child: Text('Evening')),
              DropdownMenuItem(value: 'Night', child: Text('Night')),
              DropdownMenuItem(value: 'Any', child: Text('Any')),
            ],
            onChanged: (v) => setState(() => _selectedShift = v),
            isExpanded: true,
          ),
          DropdownButtonFormField<String>(
            initialValue: _selectedHospitalType,
            decoration: const InputDecoration(labelText: 'Preferred Hospital Type', prefixIcon: Icon(Icons.local_hospital_outlined)),
            items: const [
              DropdownMenuItem(value: 'Government', child: Text('Government')),
              DropdownMenuItem(value: 'Private', child: Text('Private')),
              DropdownMenuItem(value: 'Both', child: Text('Both')),
            ],
            onChanged: (v) => setState(() => _selectedHospitalType = v),
            isExpanded: true,
          ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _dutyDistanceController,
          decoration: const InputDecoration(
            labelText: 'Preferred Duty Distance (km)',
            prefixIcon: Icon(Icons.social_distance_outlined),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Location
  // =========================================================================
  Widget _buildLocationSection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.home_outlined)),
        ),
        const SizedBox(height: 12),
        _buildFieldRow([
          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(labelText: 'City', prefixIcon: Icon(Icons.location_city_outlined)),
          ),
          TextFormField(
            controller: _stateController,
            decoration: const InputDecoration(labelText: 'State', prefixIcon: Icon(Icons.map_outlined)),
          ),
        ]),
        const SizedBox(height: 12),
        TextFormField(
          controller: _countryController,
          decoration: const InputDecoration(labelText: 'Country', prefixIcon: Icon(Icons.public_outlined)),
        ),
        const SizedBox(height: 16),
        if (_pinnedLatitude != null && _pinnedLongitude != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: AppColors.accent, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Pinned: ${_pinnedLatitude!.toStringAsFixed(4)}, ${_pinnedLongitude!.toStringAsFixed(4)}',
                    style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isGpsLoading ? null : _autoDetectLocation,
                icon: _isGpsLoading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    : const Icon(Icons.my_location),
                label: Text(_isGpsLoading ? 'Detecting...' : 'Auto-detect Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _showMapPinSheet,
                icon: const Icon(Icons.map_outlined),
                label: const Text('Pin on Map'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accent,
                  side: const BorderSide(color: AppColors.accent, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Documents
  // =========================================================================
  Widget _buildDocumentsSection(
    ProfileProvider profileProvider,
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    const docSlots = [
      {'type': 'medical_license', 'label': 'Medical License'},
      {'type': 'degree_certificate', 'label': 'Degree Certificate'},
      {'type': 'government_id', 'label': 'Government ID'},
      {'type': 'resume', 'label': 'Resume'},
      {'type': 'research_paper', 'label': 'Research Papers'},
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: docSlots.map((slot) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildDocumentSlot(
            slot['type']!, slot['label']!, profileProvider, isDark, textColor, subTextColor, borderColor,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDocumentSlot(
    String type, String label,
    ProfileProvider profileProvider,
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    final surfaceVariant = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
    final docs = profileProvider.documents.where((d) => d.type == type).toList();
    final uploaded = docs.isNotEmpty;
    final doc = uploaded ? docs.first : null;
    final isThisUploading = _uploadingDocType == type;

    Color statusColor;
    String statusLabel;
    if (!uploaded) {
      statusColor = subTextColor;
      statusLabel = '';
    } else {
      switch (doc!.verificationStatus) {
        case DocumentVerificationStatus.verified:
          statusColor = AppColors.success;
          statusLabel = 'Verified';
          break;
        case DocumentVerificationStatus.rejected:
          statusColor = AppColors.error;
          statusLabel = 'Rejected';
          break;
        case DocumentVerificationStatus.pending:
          statusColor = AppColors.warning;
          statusLabel = 'Pending';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.description_outlined, color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w700, fontSize: 14))),
              if (uploaded)
                Chip(
                  label: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w700)),
                  backgroundColor: statusColor.withValues(alpha: 0.12),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (isThisUploading)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinearProgressIndicator(
                  value: profileProvider.uploadProgress > 0 ? profileProvider.uploadProgress : null,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  backgroundColor: AppColors.accent.withValues(alpha: 0.12),
                ),
                const SizedBox(height: 4),
                Text(
                  profileProvider.uploadProgress > 0
                      ? 'Uploading ${(profileProvider.uploadProgress * 100).toStringAsFixed(0)}%...'
                      : 'Uploading...',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            )
          else if (!uploaded)
            OutlinedButton.icon(
              onPressed: () async {
                setState(() => _uploadingDocType = type);
                await profileProvider.uploadDocument(type);
                if (mounted) setState(() => _uploadingDocType = null);
              },
              icon: const Icon(Icons.upload_file_outlined, size: 18),
              label: const Text('Upload'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.accent,
                side: const BorderSide(color: AppColors.accent),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    doc!.name,
                    style: TextStyle(color: subTextColor, fontSize: 12, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    setState(() => _uploadingDocType = type);
                    await profileProvider.replaceDocument(doc.id, type);
                    if (mounted) setState(() => _uploadingDocType = null);
                  },
                  child: const Text('Replace', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // =========================================================================
  // SECTION: Achievements
  // =========================================================================
  Widget _buildAchievementsSection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Awards', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._awards.map((a) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(a, style: TextStyle(color: textColor, fontSize: 14)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error.withValues(alpha: 0.8), size: 20),
            onPressed: () => setState(() => _awards.remove(a)),
          ),
        )),
        _buildChipInput(
          items: const [],
          controller: _addAwardController,
          label: 'Award',
          onAdd: (v) => setState(() => _awards.add(v)),
          onDelete: (_) {},
          isDark: isDark, textColor: textColor, borderColor: borderColor,
        ),
        const SizedBox(height: 16),
        Text('Publications', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._publications.map((p) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(p, style: TextStyle(color: textColor, fontSize: 14)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error.withValues(alpha: 0.8), size: 20),
            onPressed: () => setState(() => _publications.remove(p)),
          ),
        )),
        _buildChipInput(
          items: const [],
          controller: _addPublicationController,
          label: 'Publication',
          onAdd: (v) => setState(() => _publications.add(v)),
          onDelete: (_) {},
          isDark: isDark, textColor: textColor, borderColor: borderColor,
        ),
        const SizedBox(height: 16),
        Text('Conferences', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._conferences.map((c) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(c, style: TextStyle(color: textColor, fontSize: 14)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error.withValues(alpha: 0.8), size: 20),
            onPressed: () => setState(() => _conferences.remove(c)),
          ),
        )),
        _buildChipInput(
          items: const [],
          controller: _addConferenceController,
          label: 'Conference',
          onAdd: (v) => setState(() => _conferences.add(v)),
          onDelete: (_) {},
          isDark: isDark, textColor: textColor, borderColor: borderColor,
        ),
        const SizedBox(height: 16),
        Text('Memberships', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        ..._memberships.map((m) => ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(m, style: TextStyle(color: textColor, fontSize: 14)),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: AppColors.error.withValues(alpha: 0.8), size: 20),
            onPressed: () => setState(() => _memberships.remove(m)),
          ),
        )),
        _buildChipInput(
          items: const [],
          controller: _addMembershipController,
          label: 'Membership',
          onAdd: (v) => setState(() => _memberships.add(v)),
          onDelete: (_) {},
          isDark: isDark, textColor: textColor, borderColor: borderColor,
        ),
      ],
    );
  }

  // =========================================================================
  // SECTION: Social Links
  // =========================================================================
  Widget _buildSocialLinksSection(
    bool isDark, Color textColor, Color subTextColor, Color borderColor,
  ) {
    String? urlValidator(String? v) {
      if (v == null || v.trim().isEmpty) return null;
      if (!v.trim().startsWith('http://') && !v.trim().startsWith('https://')) {
        return 'Must start with http:// or https://';
      }
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _linkedinController,
          decoration: const InputDecoration(
            labelText: 'LinkedIn URL',
            prefixIcon: Icon(Icons.link),
            hintText: 'https://linkedin.com/in/...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          validator: urlValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _websiteController,
          decoration: const InputDecoration(
            labelText: 'Website URL',
            prefixIcon: Icon(Icons.language_outlined),
            hintText: 'https://...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          validator: urlValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _researchgateController,
          decoration: const InputDecoration(
            labelText: 'ResearchGate URL',
            prefixIcon: Icon(Icons.science_outlined),
            hintText: 'https://researchgate.net/profile/...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.next,
          validator: urlValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _orcidController,
          decoration: const InputDecoration(
            labelText: 'ORCID URL',
            prefixIcon: Icon(Icons.fingerprint_outlined),
            hintText: 'https://orcid.org/...',
          ),
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          validator: urlValidator,
        ),
      ],
    );
  }
}
