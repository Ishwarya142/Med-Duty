import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/services/cloudinary_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/professional_post_utils.dart';
import '../../models/post_visibility.dart';
import '../../models/professional_post_category.dart';
import '../../providers/community_provider.dart';
import '../../providers/profile_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _postController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  PostVisibility _visibility = PostVisibility.public;
  final List<File> _pendingImages = [];
  final List<String> _tags = [];
  bool _isPublishing = false;

  @override
  void dispose() {
    _postController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source, imageQuality: 85);
      if (file != null) {
        setState(() => _pendingImages.add(File(file.path)));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _publishPost() async {
    final content = _postController.text.trim();
    if (content.isEmpty && _pendingImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something or attach a photo before posting.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Check for sensitive patient health information
    final warning = ProfessionalPostUtils.getSensitiveInfoWarning(content);
    if (warning != null) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Healthcare Privacy Warning'),
            ],
          ),
          content: Text(warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Edit Post'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Publish Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (!mounted) return;
    setState(() => _isPublishing = true);

    final profile = context.read<ProfileProvider>();
    final community = context.read<CommunityProvider>();

    final uploadedUrls = <String>[];
    for (final file in _pendingImages) {
      try {
        if (CloudinaryService.instance.isAllowedImageExtension(file.path)) {
          final result = await CloudinaryService.instance.uploadImage(file: file);
          uploadedUrls.add(result.secureUrl);
        }
      } catch (e) {
        debugPrint('Image upload error: $e');
      }
    }

    final meta = <String, dynamic>{
      if (_locationController.text.trim().isNotEmpty)
        'location': _locationController.text.trim(),
      if (_tags.isNotEmpty) 'tags': _tags,
    };

    final postId = await community.createProfessionalPost(
      category: ProfessionalPostCategory.professionalUpdate,
      content: content,
      visibility: _visibility,
      experienceMeta: meta,
      imageUrls: uploadedUrls,
      authorName: profile.name.isNotEmpty ? profile.name : 'Healthcare Professional',
      authorAvatar: profile.profilePic.isNotEmpty ? profile.profilePic : null,
      authorSpecialty: profile.specialization.isNotEmpty
          ? profile.specialization
          : profile.qualification,
      authorHospital: profile.currentHospital,
      authorRole: profile.qualification,
      authorVerified: profile.phoneVerified,
    );

    if (!mounted) return;
    setState(() => _isPublishing = false);

    if (postId != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post published to MedDuty community.'),
          backgroundColor: Color(0xFF0F766E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to publish post. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC);
    final card = isDark ? AppColors.darkSurface : Colors.white;
    final text = isDark ? AppColors.darkText : const Color(0xFF0F172A);
    final sub = isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B);
    final border = isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0);
    final profile = context.watch<ProfileProvider>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, color: text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create Post',
          style: TextStyle(color: text, fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isPublishing ? null : _publishPost,
              child: _isPublishing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Healthcare Privacy Warning & Reminder
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.privacy_tip_outlined, color: Color(0xFF0F766E), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          ProfessionalPostUtils.patientInfoReminder,
                          style: TextStyle(
                            color: text,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Do not post patient names, MRN numbers, phone numbers, addresses, or private clinical records.',
                    style: TextStyle(color: sub, fontSize: 11.5, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Author Header & Visibility Picker
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF0F766E),
                  backgroundImage: profile.profilePic.isNotEmpty
                      ? NetworkImage(profile.profilePic)
                      : null,
                  child: profile.profilePic.isEmpty
                      ? Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'D',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isNotEmpty ? profile.name : 'Doctor',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      PopupMenuButton<PostVisibility>(
                        initialValue: _visibility,
                        onSelected: (v) => setState(() => _visibility = v),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: card,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _visibility == PostVisibility.public
                                    ? Icons.public_rounded
                                    : _visibility == PostVisibility.followers
                                        ? Icons.group_rounded
                                        : Icons.lock_outline_rounded,
                                size: 13,
                                color: sub,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _visibility.label,
                                style: TextStyle(
                                  color: sub,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down_rounded, size: 16, color: sub),
                            ],
                          ),
                        ),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(
                            value: PostVisibility.public,
                            child: Row(
                              children: [
                                Icon(Icons.public_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Public (Everyone)'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: PostVisibility.followers,
                            child: Row(
                              children: [
                                Icon(Icons.group_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Followers Only'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: PostVisibility.private,
                            child: Row(
                              children: [
                                Icon(Icons.lock_outline_rounded, size: 18),
                                SizedBox(width: 8),
                                Text('Only Me (Private)'),
                              ],
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

            // Content text area
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _postController,
                maxLines: 8,
                minLines: 4,
                style: TextStyle(color: text, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Share a case discussion, medical insight, or professional update...',
                  hintStyle: TextStyle(color: sub),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Attached Images preview
            if (_pendingImages.isNotEmpty) ...[
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pendingImages.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(_pendingImages[i], width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _pendingImages.removeAt(i)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            padding: const EdgeInsets.all(2),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Tags
            if (_tags.isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _tags.map((t) {
                  return Chip(
                    label: Text(t, style: TextStyle(color: text, fontSize: 11)),
                    deleteIcon: const Icon(Icons.close, size: 12),
                    onDeleted: () => setState(() => _tags.remove(t)),
                    backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.1),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Actions bar: Photo, Camera, Tag, Location
            Container(
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Text('Add to post', style: TextStyle(color: sub, fontSize: 13, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Add Photo',
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_outlined, color: Color(0xFF0F766E)),
                  ),
                  IconButton(
                    tooltip: 'Take Photo',
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF0F766E)),
                  ),
                  IconButton(
                    tooltip: 'Add Topic Tag',
                    onPressed: () => _showAddTagDialog(context),
                    icon: const Icon(Icons.tag_rounded, color: Color(0xFF0F766E)),
                  ),
                  IconButton(
                    tooltip: 'Add Location',
                    onPressed: () => _showAddLocationDialog(context),
                    icon: const Icon(Icons.location_on_outlined, color: Color(0xFF0F766E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    _tagController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: _tagController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Cardiology, Research, Clinical',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final tag = _tagController.text.trim();
              if (tag.isNotEmpty) {
                setState(() => _tags.add(tag.startsWith('#') ? tag : '#$tag'));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Location / Hospital'),
        content: TextField(
          controller: _locationController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Apollo Hospital, Chennai',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(ctx);
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }
}
