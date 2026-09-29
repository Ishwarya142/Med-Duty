import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

class ProfessionalDocumentsScreen extends StatefulWidget {
  const ProfessionalDocumentsScreen({super.key});

  @override
  State<ProfessionalDocumentsScreen> createState() =>
      _ProfessionalDocumentsScreenState();
}

class _ProfessionalDocumentsScreenState
    extends State<ProfessionalDocumentsScreen> {
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
    final iconBgColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSecondary;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final cardShadow = isDark ? <BoxShadow>[] : AppColors.softShadow;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Professional Documents',
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
      ),
      body: profileProvider.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : profileProvider.documents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.description_outlined,
                        size: 56,
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No documents uploaded yet',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button below to upload your documents.',
                      style: TextStyle(
                        color: subTextColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
              itemCount: profileProvider.documents.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final doc = profileProvider.documents[index];
                Color statusColor;
                String statusText;
                switch (doc.verificationStatus) {
                  case DocumentVerificationStatus.verified:
                    statusColor = AppColors.success;
                    statusText = 'Verified';
                    break;
                  case DocumentVerificationStatus.rejected:
                    statusColor = AppColors.error;
                    statusText = 'Rejected';
                    break;
                  default:
                    statusColor = AppColors.warning;
                    statusText = 'Pending';
                }
                return Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: cardShadow,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: AppColors.accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.name,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(
                        height: 1,
                        thickness: 0.8,
                        color: Color(0x1A000000),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _iconBtn(
                            label: 'Preview',
                            icon: Icons.visibility_outlined,
                            textColor: subTextColor,
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await launchUrl(
                                  Uri.parse(doc.url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to open document: $e',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          _iconBtn(
                            label: 'Download',
                            icon: Icons.download_outlined,
                            textColor: subTextColor,
                            onPressed: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                await launchUrl(
                                  Uri.parse(doc.url),
                                  mode: LaunchMode.externalApplication,
                                );
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to download document: $e',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                          _iconBtn(
                            label: 'Replace',
                            icon: Icons.refresh_outlined,
                            textColor: AppColors.accent,
                            onPressed: () async {
                              await profileProvider.replaceDocument(
                                doc.id,
                                doc.type,
                              );
                            },
                          ),
                          _iconBtn(
                            label: 'Delete',
                            icon: Icons.delete_outline_rounded,
                            textColor: AppColors.error,
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: surfaceColor,
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  title: Text(
                                    'Delete Document',
                                    style: TextStyle(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  content: Text(
                                    'Are you sure you want to delete this document? This cannot be undone.',
                                    style: TextStyle(
                                      color: subTextColor,
                                      fontSize: 14.5,
                                      height: 1.35,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: subTextColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm == true) {
                                await profileProvider.deleteDocument(doc.id);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => profileProvider.uploadDocument('other'),
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.add_rounded, size: 24),
        label: const Text(
          'Upload',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  Widget _iconBtn({
    required String label,
    required IconData icon,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, color: textColor, size: 22),
            onPressed: onPressed,
            constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
            padding: EdgeInsets.zero,
            splashRadius: 18,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
