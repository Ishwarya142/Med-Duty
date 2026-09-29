import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import 'profile_media_viewer.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final certificates = profile.documents
        .where((d) => d.type.toLowerCase().contains('certificate'))
        .toList();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Certificates', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: profile.isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accent))
          : certificates.isEmpty
          ? _emptyState(textColor, subText)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final cert = certificates[index];
                final verified = cert.verificationStatus == DocumentVerificationStatus.verified;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProfileMediaViewer(
                          initialIndex: index,
                          items: certificates
                              .map(
                                (c) => ProfileMediaItem(
                                  title: c.name,
                                  subtitle: c.type,
                                  url: c.url,
                                  icon: Icons.workspace_premium_rounded,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border.withValues(alpha: 0.5)),
                      boxShadow: isDark ? null : AppColors.softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                          ),
                          child: cert.url.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    cert.url,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.workspace_premium_rounded,
                                      size: 48,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                )
                              : const Icon(Icons.workspace_premium_rounded, size: 48, color: AppColors.accent),
                        ),
                        const SizedBox(height: 12),
                        Text(cert.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('Issued by: ${cert.type.replaceAll('_', ' ')}', style: TextStyle(color: subText, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('${cert.uploadedAt.year}', style: TextStyle(color: subText, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              verified ? Icons.verified_rounded : Icons.pending_outlined,
                              size: 16,
                              color: verified ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              verified ? 'Verified' : 'Pending verification',
                              style: TextStyle(
                                color: verified ? AppColors.success : AppColors.warning,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _emptyState(Color textColor, Color subText) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.workspace_premium_outlined, size: 56, color: AppColors.accent),
            const SizedBox(height: 16),
            Text('No certificates added yet.', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Upload certificates from Professional Documents.', style: TextStyle(color: subText), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
