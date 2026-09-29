import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../models/share_payload.dart';
import '../../features/profile/profile_share_helper.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/settings/account_control_screens.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final Map<String, bool> _expandedSections = {
    'professionalSummary': false,
    'professionalDocuments': false,
    'dutyInformation': false,
    'applications': false,
    'ratingsReviews': false,
    'community': false,
    'saved': false,
    'activity': false,
    'wallet': false,
    'settings': false,
  };

  void _toggleSection(String key) {
    setState(() {
      _expandedSections[key] = !_expandedSections[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = Provider.of<ProfileProvider>(context);
    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final mutedColor = isDark
        ? AppColors.darkTextMuted
        : AppColors.lightTextMuted;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;
    final dividerColor = isDark
        ? AppColors.darkDivider
        : AppColors.lightDivider;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Profile Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: isDark ? null : AppColors.softShadow,
                  border: Border.all(
                    color: borderColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Profile Picture
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: iconBgColor,
                            border: Border.all(
                              color: AppColors.accent,
                              width: 2.2,
                            ),
                          ),
                          child: profileProvider.profilePic.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileProvider.profilePic,
                                    fit: BoxFit.cover,
                                    width: 60,
                                    height: 60,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: AppColors.accent,
                                  size: 30,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Name and Title
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      profileProvider.name.isNotEmpty
                                          ? profileProvider.name
                                          : 'Dr. User',
                                      style: TextStyle(
                                        color: textColor,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 18,
                                        letterSpacing: -0.2,
                                        height: 1.2,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.all(2.5),
                                    decoration: const BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: AppColors.white,
                                      size: 9,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                profileProvider.specialization.isNotEmpty
                                    ? profileProvider.specialization
                                    : 'MBBS | General Physician',
                                style: TextStyle(
                                  color: subTextColor,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.warning,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    profileProvider.averageRating
                                        .toStringAsFixed(1),
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: mutedColor,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      profileProvider.currentCity.isNotEmpty
                                          ? profileProvider.currentCity
                                          : 'City',
                                      style: TextStyle(
                                        color: subTextColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.5,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 15),
                            label: const Text(
                              'Edit',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: AppColors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              MedDutyShareService.show(
                                context,
                                SharePayload.profile(ProfileShareHelper.ownProfile(context)),
                              );
                            },
                            icon: const Icon(Icons.share, size: 15),
                            label: const Text(
                              'Share',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textColor,
                              side: BorderSide(color: borderColor, width: 1.3),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
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
              const SizedBox(height: 18),
              // Expandable Menu Sections
              _buildExpandableSection(
                title: 'Professional Summary',
                key: 'professionalSummary',
                icon: Icons.work,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.person_outline,
                    title: 'About Me',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.school,
                    title: 'Qualification',
                    subtitle: profileProvider.qualification.isNotEmpty
                        ? profileProvider.qualification
                        : null,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.badge,
                    title: 'Registration Number',
                    subtitle:
                        profileProvider.medicalRegistrationNumber.isNotEmpty
                        ? profileProvider.medicalRegistrationNumber
                        : null,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.local_hospital,
                    title: 'Medical Council',
                    subtitle: profileProvider.medicalCouncil.isNotEmpty
                        ? profileProvider.medicalCouncil
                        : null,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.medical_services,
                    title: 'Specialization',
                    subtitle: profileProvider.specialization.isNotEmpty
                        ? profileProvider.specialization
                        : null,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.timelapse,
                    title: 'Experience',
                    subtitle: '${profileProvider.experience} years',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.language,
                    title: 'Languages',
                    subtitle: profileProvider.languages.join(', '),
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.star_border,
                    title: 'Skills',
                    subtitle: profileProvider.skills.isNotEmpty
                        ? profileProvider.skills.join(', ')
                        : null,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Professional Documents',
                key: 'professionalDocuments',
                icon: Icons.file_present,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.description,
                    title: 'Medical License',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.book,
                    title: 'Certificates',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.perm_identity,
                    title: 'Government ID',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.article,
                    title: 'Research Papers',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.file_upload,
                    title: 'Resume / CV',
                    subtitle: profileProvider.resume != null
                        ? profileProvider.resume!.name
                        : 'Upload',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () async {
                      await profileProvider.uploadResume();
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.add_circle_outline,
                    title: 'Upload New Document',
                    iconColor: AppColors.accent,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () async {
                      await profileProvider.uploadDocument('other');
                    },
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Duty Information',
                key: 'dutyInformation',
                icon: Icons.event_note,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.check_circle_outline,
                    title: 'Completed Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.event_available,
                    title: 'Upcoming Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.send,
                    title: 'Applied Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.bookmark_border,
                    title: 'Saved Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.cancel_outlined,
                    title: 'Cancelled Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.history,
                    title: 'Duty History',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.today,
                    title: 'Attendance',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.calendar_today,
                    title: 'Duty Calendar',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Applications',
                key: 'applications',
                icon: Icons.description_outlined,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.pending_actions,
                    title: 'Pending',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.check_circle,
                    title: 'Accepted',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.cancel,
                    title: 'Rejected',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.list_alt,
                    title: 'Shortlisted',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.done_all,
                    title: 'Completed',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.arrow_back,
                    title: 'Withdrawn',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Ratings & Reviews',
                key: 'ratingsReviews',
                icon: Icons.star_rate,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.star_half,
                    title: 'Average Rating',
                    subtitle: profileProvider.averageRating.toStringAsFixed(1),
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.rate_review,
                    title: 'Total Reviews',
                    subtitle: profileProvider.reviews.length.toString(),
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.person,
                    title: 'Patient Reviews',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.local_hospital,
                    title: 'Hospital Reviews',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.edit_note,
                    title: 'Write Review',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.visibility,
                    title: 'View All Reviews',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Community',
                key: 'community',
                icon: Icons.people,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.post_add,
                    title: 'Posts',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.bookmark_added,
                    title: 'Saved Posts',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.thumb_up,
                    title: 'Liked Posts',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.person_add,
                    title: 'Followers',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.person_add_alt_1,
                    title: 'Following',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Saved',
                key: 'saved',
                icon: Icons.bookmark_border,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.event_note,
                    title: 'Saved Duties',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.local_hospital,
                    title: 'Saved Hospitals',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.person,
                    title: 'Saved Doctors',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.post_add,
                    title: 'Saved Posts',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.search,
                    title: 'Saved Searches',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Activity',
                key: 'activity',
                icon: Icons.history,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.notifications,
                    title: 'Notification History',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.search,
                    title: 'Search History',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.visibility,
                    title: 'Profile Visits',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.history_toggle_off,
                    title: 'Recently Viewed',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.login,
                    title: 'Login History',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Wallet',
                key: 'wallet',
                icon: Icons.account_balance_wallet,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.attach_money,
                    title: 'Wallet Balance',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.receipt_long,
                    title: 'Transactions',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.payment,
                    title: 'Payment History',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.money_off,
                    title: 'Withdraw',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.account_balance,
                    title: 'Bank Details',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.currency_exchange,
                    title: 'UPI',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                ],
              ),
              _buildCompactDivider(dividerColor),
              _buildExpandableSection(
                title: 'Settings',
                key: 'settings',
                icon: Icons.settings,
                iconBgColor: iconBgColor,
                textColor: textColor,
                subTextColor: subTextColor,
                children: [
                  _buildCompactMenuItem(
                    icon: Icons.notifications_active,
                    title: 'Notification Settings',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.privacy_tip,
                    title: 'Privacy',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.location_on,
                    title: 'Location Permissions',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.fingerprint,
                    title: 'Biometric Login',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.face,
                    title: 'Face ID',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.dark_mode,
                    title: 'Theme (System / Light / Dark)',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.translate,
                    title: 'Language',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.security,
                    title: 'Security',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.block,
                    title: 'Blocked Users',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.pause_circle_outline,
                    title: 'Deactivate Account',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const DeactivateAccountScreen(),
                        ),
                      );
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.report,
                    title: 'Report Issue',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.help,
                    title: 'Help Center',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.description,
                    title: 'Terms',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () async {
                      await launchUrl(Uri.parse('https://medduty.com/terms'));
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () async {
                      await launchUrl(Uri.parse('https://medduty.com/privacy'));
                    },
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.info_outline,
                    title: 'About',
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                    onTap: () {},
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: () {},
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                  _buildCompactMenuItem(
                    icon: Icons.delete_forever,
                    title: 'Delete Account',
                    onTap: () {},
                    titleColor: AppColors.error,
                    iconColor: AppColors.error,
                    iconBgColor: iconBgColor,
                    textColor: textColor,
                    subTextColor: subTextColor,
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required String key,
    required IconData icon,
    required Color iconBgColor,
    required Color textColor,
    required Color subTextColor,
    required List<Widget> children,
  }) {
    final isExpanded = _expandedSections[key] ?? false;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (_) => _toggleSection(key),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        childrenPadding: const EdgeInsets.only(left: 4, right: 8, bottom: 6),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            height: 1.2,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          color: subTextColor,
          size: 22,
        ),
        children: children,
      ),
    );
  }

  Widget _buildCompactMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Color? titleColor,
    Color? iconColor,
    Widget? trailing,
    required Color iconBgColor,
    required Color textColor,
    required Color subTextColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.accent, size: 17),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          height: 1.2,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: subTextColor,
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                height: 1.2,
              ),
            )
          : null,
      trailing:
          trailing ?? Icon(Icons.chevron_right, color: subTextColor, size: 17),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      minLeadingWidth: 0,
      dense: true,
    );
  }

  Widget _buildCompactDivider(Color dividerColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Divider(
        color: dividerColor.withValues(alpha: 0.3),
        thickness: 0.8,
        height: 1,
      ),
    );
  }
}
