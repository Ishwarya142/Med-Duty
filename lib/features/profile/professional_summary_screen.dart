import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfessionalSummaryScreen extends StatelessWidget {
  const ProfessionalSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final labelColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardShadow = isDark ? <BoxShadow>[] : AppColors.cardShadow;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Professional Summary',
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
          IconButton(
            icon: Icon(Icons.edit, color: AppColors.accent, size: 24),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: profileProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildProfileHeader(
                  profileProvider: profileProvider,
                  authProvider: authProvider,
                  isDark: isDark,
                  textColor: textColor,
                  subTextColor: subTextColor,
                  iconBgColor: iconBgColor,
                  borderColor: borderColor,
                  cardShadow: cardShadow,
                ),
                const SizedBox(height: 28),
                _buildSection(
                  title: 'Personal Information',
                  children: [
                    _buildInfoRow(
                      'Name',
                      profileProvider.name.isNotEmpty
                          ? profileProvider.name
                          : authProvider.userData?['name'] ?? 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    if (profileProvider.gender != null)
                      _buildInfoRow(
                        'Gender',
                        profileProvider.gender!,
                        labelColor,
                        textColor,
                        borderColor,
                      ),
                    if (profileProvider.dateOfBirth != null)
                      _buildInfoRow(
                        'Date of Birth',
                        _formatDate(profileProvider.dateOfBirth!),
                        labelColor,
                        textColor,
                        borderColor,
                      ),
                    _buildInfoRow(
                      'Email',
                      profileProvider.email.isNotEmpty
                          ? profileProvider.email
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Phone',
                      profileProvider.phone.isNotEmpty
                          ? profileProvider.phone
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Address',
                      profileProvider.address.isNotEmpty
                          ? profileProvider.address
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                      isLast: true,
                    ),
                  ],
                  textColor: textColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  cardShadow: cardShadow,
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Professional Information',
                  children: [
                    _buildInfoRow(
                      'Medical Reg #',
                      profileProvider.medicalRegistrationNumber.isNotEmpty
                          ? profileProvider.medicalRegistrationNumber
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Medical Council',
                      profileProvider.medicalCouncil.isNotEmpty
                          ? profileProvider.medicalCouncil
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Qualification',
                      profileProvider.qualification.isNotEmpty
                          ? profileProvider.qualification
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Specialization',
                      profileProvider.specialization.isNotEmpty
                          ? profileProvider.specialization
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Experience',
                      '${profileProvider.experience} years',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Languages',
                      profileProvider.languages.isNotEmpty
                          ? profileProvider.languages.join(', ')
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Skills',
                      profileProvider.skills.isNotEmpty
                          ? profileProvider.skills.join(', ')
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                      isLast: true,
                    ),
                  ],
                  textColor: textColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  cardShadow: cardShadow,
                ),
                const SizedBox(height: 20),
                _buildSection(
                  title: 'Location & Availability',
                  children: [
                    _buildInfoRow(
                      'Current City',
                      profileProvider.currentCity.isNotEmpty
                          ? profileProvider.currentCity
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'State',
                      profileProvider.state.isNotEmpty
                          ? profileProvider.state
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Country',
                      profileProvider.country.isNotEmpty
                          ? profileProvider.country
                          : 'Not set',
                      labelColor,
                      textColor,
                      borderColor,
                    ),
                    _buildInfoRow(
                      'Available for Duties',
                      profileProvider.availableForDuties ? 'Yes' : 'No',
                      labelColor,
                      textColor,
                      borderColor,
                      isLast: true,
                    ),
                  ],
                  textColor: textColor,
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  cardShadow: cardShadow,
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildProfileHeader({
    required ProfileProvider profileProvider,
    required AuthProvider authProvider,
    required bool isDark,
    required Color textColor,
    required Color subTextColor,
    required Color iconBgColor,
    required Color borderColor,
    required List<BoxShadow> cardShadow,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent.withValues(alpha: isDark ? 0.22 : 0.10),
            (isDark ? AppColors.darkSurface : Colors.white).withValues(
              alpha: 1,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: cardShadow,
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.22),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 58,
              backgroundColor: iconBgColor,
              backgroundImage:
                  (profileProvider.localProfilePicPath != null && !kIsWeb)
                  ? FileImage(File(profileProvider.localProfilePicPath!))
                  : (profileProvider.profilePic.isNotEmpty
                        ? NetworkImage(profileProvider.profilePic)
                        : null),
              child:
                  (profileProvider.localProfilePicPath == null || kIsWeb) &&
                      profileProvider.profilePic.isEmpty
                  ? const Icon(Icons.person, size: 58, color: AppColors.accent)
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            profileProvider.name.isNotEmpty
                ? profileProvider.name
                : authProvider.userData?['name'] ?? 'User',
            style: TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          if (profileProvider.specialization.isNotEmpty ||
              profileProvider.qualification.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.22),
                ),
              ),
              child: Text(
                [
                  profileProvider.qualification,
                  profileProvider.specialization,
                ].where((s) => s.isNotEmpty).join(' • '),
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.accent,
                ),
              ),
            ),
          const SizedBox(height: 12),
          Text(
            [
                  profileProvider.currentCity,
                  profileProvider.state,
                  profileProvider.country,
                ].where((s) => s.isNotEmpty).join(', ').isNotEmpty
                ? [
                    profileProvider.currentCity,
                    profileProvider.state,
                    profileProvider.country,
                  ].where((s) => s.isNotEmpty).join(', ')
                : 'Location not set',
            style: TextStyle(
              color: subTextColor,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required Color textColor,
    required Color surfaceColor,
    required Color borderColor,
    required List<BoxShadow> cardShadow,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: cardShadow,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    Color labelColor,
    Color textColor,
    Color borderColor, {
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 12 : 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: isLast
                ? BorderSide.none
                : BorderSide(color: borderColor, width: 0.7),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 130,
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
