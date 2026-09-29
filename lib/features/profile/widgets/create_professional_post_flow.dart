// ignore_for_file: deprecated_member_use
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/services/cloudinary_service.dart';
import '../../../core/utils/professional_post_utils.dart';
import '../../../models/post_visibility.dart';
import '../../../models/professional_post_category.dart';
import '../../../providers/community_provider.dart';
import '../../../providers/profile_provider.dart';

const _cTeal = Color(0xFF0F766E);

/// Opens the category picker, then the creation form.
void showCreateProfessionalPostFlow(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => const _CreateCategorySheet(),
  );
}

class _CreateCategorySheet extends StatelessWidget {
  const _CreateCategorySheet();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: sub.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Create Professional Post',
            style: TextStyle(
              color: tx,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Share your healthcare experience, achievements, and insights.',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...ProfessionalPostCategory.values.map((cat) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _cTeal.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(cat.icon, color: _cTeal, size: 20),
              ),
              title: Text(cat.label, style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
              trailing: Icon(Icons.chevron_right_rounded, color: sub),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateProfessionalPostScreen(category: cat),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class CreateProfessionalPostScreen extends StatefulWidget {
  const CreateProfessionalPostScreen({super.key, required this.category});

  final ProfessionalPostCategory category;

  @override
  State<CreateProfessionalPostScreen> createState() =>
      _CreateProfessionalPostScreenState();
}

class _CreateProfessionalPostScreenState
    extends State<CreateProfessionalPostScreen> {
  final _hospitalCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  final _specialtyCtrl = TextEditingController();
  final _institutionCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _startDateCtrl = TextEditingController();
  final _endDateCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _hashtagsCtrl = TextEditingController();
  final _picker = ImagePicker();

  PostVisibility _visibility = PostVisibility.followers;
  bool _currentlyWorking = false;
  bool _publishing = false;
  final List<String> _imageUrls = [];
  final List<String> _documentUrls = [];
  final List<File> _pendingImages = [];
  final List<String> _tags = [];
  final List<String> _hashtags = [];

  @override
  void dispose() {
    _hospitalCtrl.dispose();
    _roleCtrl.dispose();
    _specialtyCtrl.dispose();
    _institutionCtrl.dispose();
    _titleCtrl.dispose();
    _startDateCtrl.dispose();
    _endDateCtrl.dispose();
    _contentCtrl.dispose();
    _locationCtrl.dispose();
    _tagsCtrl.dispose();
    _hashtagsCtrl.dispose();
    super.dispose();
  }

  bool get _needsExperienceFields {
    switch (widget.category) {
      case ProfessionalPostCategory.clinicalExperience:
      case ProfessionalPostCategory.dutyExperience:
      case ProfessionalPostCategory.hospitalClinicExperience:
        return true;
      case ProfessionalPostCategory.certification:
      case ProfessionalPostCategory.medicalEducation:
      case ProfessionalPostCategory.research:
      case ProfessionalPostCategory.publication:
      case ProfessionalPostCategory.workshopConference:
      case ProfessionalPostCategory.careerAchievement:
        return true;
      case ProfessionalPostCategory.professionalUpdate:
      case ProfessionalPostCategory.poll:
      case ProfessionalPostCategory.article:
      case ProfessionalPostCategory.photoDocument:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Create ${widget.category.label}',
          style: TextStyle(color: tx, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        iconTheme: IconThemeData(color: tx),
        actions: [
          TextButton(
            onPressed: _publishing ? null : _publish,
            child: _publishing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Publish',
                    style: TextStyle(
                      color: _cTeal,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.privacy_tip_outlined, color: Color(0xFF0F766E), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ProfessionalPostUtils.patientInfoReminder,
                        style: TextStyle(
                          color: tx,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Clearly discouraged: patient names, phone numbers, MRNs, addresses, identifiable photos, hospital records, or private medical documents.',
                  style: TextStyle(color: sub, fontSize: 11.5, height: 1.35),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_needsExperienceFields) ...[
            _field('Hospital / Clinic / Institution', _hospitalCtrl, card, border, tx, sub,
                hint: 'Search or enter name'),
            if (widget.category == ProfessionalPostCategory.clinicalExperience ||
                widget.category == ProfessionalPostCategory.dutyExperience) ...[
              _field('Role', _roleCtrl, card, border, tx, sub,
                  hint: 'Doctor, Resident, Medical Officer...'),
              _field('Specialty', _specialtyCtrl, card, border, tx, sub,
                  hint: 'Cardiology, Dermatology...'),
              _field('Start Date', _startDateCtrl, card, border, tx, sub, hint: 'Jan 2025'),
              if (!_currentlyWorking)
                _field('End Date', _endDateCtrl, card, border, tx, sub, hint: 'Jun 2026'),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Currently working here', style: TextStyle(color: tx)),
                value: _currentlyWorking,
                activeThumbColor: _cTeal,
                onChanged: (v) => setState(() => _currentlyWorking = v),
              ),
            ],
            if (widget.category == ProfessionalPostCategory.medicalEducation)
              _field('Qualification', _titleCtrl, card, border, tx, sub,
                  hint: 'MD, DM, Fellowship...'),
            if (widget.category == ProfessionalPostCategory.research)
              _field('Research Title', _titleCtrl, card, border, tx, sub),
            if (widget.category == ProfessionalPostCategory.workshopConference)
              _field('Event Name', _titleCtrl, card, border, tx, sub),
            if (widget.category == ProfessionalPostCategory.careerAchievement)
              _field('Achievement Title', _titleCtrl, card, border, tx, sub),
          ],
          _field(
            'Experience / Description',
            _contentCtrl,
            card,
            border,
            tx,
            sub,
            hint: 'Share your professional experience, responsibilities, learning, or achievements...',
            maxLines: 6,
          ),
          const SizedBox(height: 12),
          _field('Location', _locationCtrl, card, border, tx, sub,
              hint: 'City, Hospital, or Clinic name'),
          const SizedBox(height: 12),
          Text('Tags', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _tagsCtrl,
            style: TextStyle(color: tx),
            decoration: InputDecoration(
              hintText: 'Add tags (e.g., Cardiology, Emergency)',
              hintStyle: TextStyle(color: sub),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: _cTeal),
                onPressed: () {
                  if (_tagsCtrl.text.trim().isNotEmpty) {
                    setState(() => _tags.add(_tagsCtrl.text.trim()));
                    _tagsCtrl.clear();
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                setState(() => _tags.add(value.trim()));
                _tagsCtrl.clear();
              }
            },
          ),
          if (_tags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _tags.map((tag) {
                return Chip(
                  label: Text(tag, style: TextStyle(color: tx, fontSize: 12)),
                  deleteIconColor: sub,
                  onDeleted: () => setState(() => _tags.remove(tag)),
                  backgroundColor: _cTeal.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text('Hashtags', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          TextField(
            controller: _hashtagsCtrl,
            style: TextStyle(color: tx),
            decoration: InputDecoration(
              hintText: 'Add hashtags (e.g., #Healthcare #Medicine)',
              hintStyle: TextStyle(color: sub),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.add, color: _cTeal),
                onPressed: () {
                  if (_hashtagsCtrl.text.trim().isNotEmpty) {
                    final tag = _hashtagsCtrl.text.trim().startsWith('#')
                        ? _hashtagsCtrl.text.trim()
                        : '#${_hashtagsCtrl.text.trim()}';
                    setState(() => _hashtags.add(tag));
                    _hashtagsCtrl.clear();
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                final tag = value.trim().startsWith('#')
                    ? value.trim()
                    : '#${value.trim()}';
                setState(() => _hashtags.add(tag));
                _hashtagsCtrl.clear();
              }
            },
          ),
          if (_hashtags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _hashtags.map((tag) {
                return Chip(
                  label: Text(tag, style: TextStyle(color: _cTeal, fontSize: 12)),
                  deleteIconColor: sub,
                  onDeleted: () => setState(() => _hashtags.remove(tag)),
                  backgroundColor: _cTeal.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          Text('Add media', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_outlined, size: 18),
                label: const Text('Photo'),
              ),
              OutlinedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.attach_file, size: 18),
                label: const Text('Document'),
              ),
            ],
          ),
          if (_pendingImages.isNotEmpty || _imageUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingImages.length + _imageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i < _pendingImages.length) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_pendingImages[i], width: 72, height: 72, fit: BoxFit.cover),
                    );
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(_imageUrls[i - _pendingImages.length],
                        width: 72, height: 72, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 20),
          Text('Who can see this post?', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...PostVisibility.values.map((v) {
            return RadioListTile<PostVisibility>(
              value: v,
              groupValue: _visibility,
              activeColor: _cTeal,
              title: Text(v.label, style: TextStyle(color: tx)),
              subtitle: Text(
                v == PostVisibility.public
                    ? 'Anyone can view on your profile'
                    : v == PostVisibility.followers
                        ? 'Only your followers'
                        : 'Only you',
                style: TextStyle(color: sub, fontSize: 12),
              ),
              onChanged: (val) => setState(() => _visibility = val!),
            );
          }),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl,
    Color card,
    Color border,
    Color tx,
    Color sub, {
    String? hint,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: tx, fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            maxLines: maxLines,
            style: TextStyle(color: tx),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: sub),
              filled: true,
              fillColor: card,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (file == null) return;
    setState(() => _pendingImages.add(File(file.path)));
  }

  Future<void> _pickDocument() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) return;
    setState(() => _pendingImages.add(File(file.path)));
  }

  Future<void> _publish() async {
    if (_contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add a description for your post.')),
      );
      return;
    }

    // Check for sensitive patient information
    final warning = ProfessionalPostUtils.getSensitiveInfoWarning(_contentCtrl.text.trim());
    final profile = context.read<ProfileProvider>();
    final community = context.read<CommunityProvider>();

    if (warning != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 8),
              Text('Content Warning'),
            ],
          ),
          content: Text(warning),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Edit Content'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Publish Anyway'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    if (!mounted) return;
    setState(() => _publishing = true);

    final uploadedUrls = <String>[..._imageUrls];
    for (final file in _pendingImages) {
      try {
        if (CloudinaryService.instance.isAllowedImageExtension(file.path)) {
          final result = await CloudinaryService.instance.uploadImage(file: file);
          uploadedUrls.add(result.secureUrl);
        }
      } catch (e) {
        debugPrint('upload error: $e');
      }
    }

    final meta = <String, dynamic>{
      if (_hospitalCtrl.text.trim().isNotEmpty)
        'hospital': _hospitalCtrl.text.trim(),
      if (_institutionCtrl.text.trim().isNotEmpty)
        'institution': _institutionCtrl.text.trim(),
      if (_roleCtrl.text.trim().isNotEmpty) 'role': _roleCtrl.text.trim(),
      if (_specialtyCtrl.text.trim().isNotEmpty)
        'specialty': _specialtyCtrl.text.trim(),
      if (_titleCtrl.text.trim().isNotEmpty) 'title': _titleCtrl.text.trim(),
      if (_startDateCtrl.text.trim().isNotEmpty)
        'startDate': _startDateCtrl.text.trim(),
      if (_endDateCtrl.text.trim().isNotEmpty && !_currentlyWorking)
        'endDate': _endDateCtrl.text.trim(),
      'currentlyWorking': _currentlyWorking,
      if (_locationCtrl.text.trim().isNotEmpty)
        'location': _locationCtrl.text.trim(),
      if (_tags.isNotEmpty) 'tags': _tags,
      if (_hashtags.isNotEmpty) 'hashtags': _hashtags,
    };

    final postId = await community.createProfessionalPost(
      category: widget.category,
      content: _contentCtrl.text.trim(),
      visibility: _visibility,
      experienceMeta: meta,
      imageUrls: uploadedUrls,
      documentUrls: _documentUrls,
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
    setState(() => _publishing = false);

    if (postId != null) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Professional post published successfully.'),
          backgroundColor: _cTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to publish post. Please try again.')),
      );
    }
  }
}
