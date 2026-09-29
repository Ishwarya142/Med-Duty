import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';

class ProfileMediaViewer extends StatelessWidget {
  final List<ProfileMediaItem> items;
  final int initialIndex;

  const ProfileMediaViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (items.isNotEmpty)
            IconButton(
              tooltip: 'Open',
              onPressed: () async {
                final url = items[initialIndex.clamp(0, items.length - 1)].url;
                if (url == null) return;
                final uri = Uri.tryParse(url);
                if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              icon: const Icon(Icons.open_in_new_rounded),
            ),
        ],
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Center(
            child: InteractiveViewer(
              minScale: 0.8,
              maxScale: 4,
              child: item.url != null && _isImageUrl(item.url!)
                  ? Image.network(
                      item.url!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => _placeholder(item),
                    )
                  : _placeholder(item),
            ),
          );
        },
      ),
    );
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.contains('cloudinary') ||
        lower.contains('image');
  }

  Widget _placeholder(ProfileMediaItem item) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 72, color: AppColors.accent),
          const SizedBox(height: 16),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              item.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ],
      ),
    );
  }
}

class ProfileMediaItem {
  final String title;
  final String? subtitle;
  final String? url;
  final IconData icon;

  const ProfileMediaItem({
    required this.title,
    this.subtitle,
    this.url,
    this.icon = Icons.image_rounded,
  });
}
