import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/profile_provider.dart';
import 'profile_media_viewer.dart';

class ProfileGalleryScreen extends StatelessWidget {
  const ProfileGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = context.watch<ProfileProvider>();
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final items = <ProfileMediaItem>[];
    if (profile.profilePic.isNotEmpty) {
      items.add(ProfileMediaItem(title: 'Profile Photo', url: profile.profilePic));
    }
    if (profile.coverPic.isNotEmpty) {
      items.add(ProfileMediaItem(title: 'Cover Photo', url: profile.coverPic));
    }
    for (final doc in profile.documents) {
      if (doc.url.isEmpty) continue;
      final lower = doc.url.toLowerCase();
      if (lower.contains('.png') ||
          lower.contains('.jpg') ||
          lower.contains('.jpeg') ||
          lower.contains('.webp') ||
          lower.contains('image')) {
        items.add(ProfileMediaItem(title: doc.name, subtitle: doc.type, url: doc.url));
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Gallery', style: TextStyle(color: textColor, fontWeight: FontWeight.w800)),
        backgroundColor: bg,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: items.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.photo_library_outlined, size: 56, color: AppColors.accent),
                    const SizedBox(height: 16),
                    Text('No professional media added yet.', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final crossCount = constraints.maxWidth > 520 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProfileMediaViewer(items: items, initialIndex: index),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border.withValues(alpha: 0.5)),
                          color: AppColors.accent.withValues(alpha: 0.06),
                        ),
                        child: item.url != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.url!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => Center(
                                    child: Icon(item.icon, color: AppColors.accent, size: 32),
                                  ),
                                ),
                              )
                            : Center(child: Icon(item.icon, color: AppColors.accent, size: 32)),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
