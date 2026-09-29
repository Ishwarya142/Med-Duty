import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';

class ResearchScreen extends StatelessWidget {
  const ResearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subText = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final papers = profile.documents
        .where((d) => d.type.toLowerCase().contains('research'))
        .toList();
    final hasResearchGate = profile.researchgateUrl.isNotEmpty;

    if (papers.isEmpty && !hasResearchGate) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          title: Text('Research & Publications', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
          backgroundColor: bg,
          foregroundColor: textColor,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.science_outlined, size: 56, color: AppColors.accent),
                const SizedBox(height: 16),
                Text('No research publications added yet.', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Research & Publications', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (hasResearchGate)
            ListTile(
              leading: const Icon(Icons.link_rounded, color: AppColors.accent),
              title: Text('ResearchGate Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.w700)),
              subtitle: Text(profile.researchgateUrl, style: TextStyle(color: subText, fontSize: 12)),
              onTap: () async {
                final uri = Uri.tryParse(profile.researchgateUrl);
                if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
            ),
          ...papers.map(
            (paper) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border.withValues(alpha: 0.5)),
              ),
              child: InkWell(
                onTap: () async {
                  if (paper.url.isEmpty) return;
                  final uri = Uri.tryParse(paper.url);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(paper.name, style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 15)),
                    const SizedBox(height: 6),
                    Text('Uploaded ${paper.uploadedAt.year}', style: TextStyle(color: subText, fontSize: 12)),
                    if (paper.url.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Tap to open publication', style: TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
