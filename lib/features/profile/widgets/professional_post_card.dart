import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/professional_post_utils.dart';
import '../../../models/community_post_model.dart';
import '../../../models/professional_post_category.dart';
import '../../../models/post_visibility.dart';
import '../../../providers/community_provider.dart';
import '../../../shared/widgets/report_bottom_sheet.dart';
import '../../community/post_comments_screen.dart';

const _cTeal = Color(0xFF0F766E);
const _cBlue = Color(0xFF2563EB);

class ProfessionalPostCard extends StatelessWidget {
  const ProfessionalPostCard({
    super.key,
    required this.post,
    this.compact = false,
    this.showAuthorHeader = true,
    this.isOwner = false,
    this.onDeleted,
  });

  final CommunityPostModel post;
  final bool compact;
  final bool showAuthorHeader;
  final bool isOwner;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final community = context.watch<CommunityProvider>();
    final isLiked = community.isPostLiked(post.id);
    final isSaved = community.isPostSaved(post.id);

    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 0 : 16, compact ? 0 : 12, compact ? 0 : 16, 0),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAuthorHeader) _header(context, tx, sub),
            if (showAuthorHeader) const SizedBox(height: 12),
            _categoryBadge(tx, sub),
            if (_hasExperienceCard) ...[
              const SizedBox(height: 10),
              _experienceCard(tx, sub, border),
            ],
            if (post.content.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                post.content,
                style: TextStyle(color: tx, fontSize: 14, height: 1.5),
              ),
            ],
            if (post.imageUrls.isNotEmpty) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: post.imageUrls.length == 1
                    ? Image.network(
                        post.imageUrls.first,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _mediaPlaceholder(sub),
                      )
                    : SizedBox(
                        height: 120,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: post.imageUrls.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (_, i) => ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              post.imageUrls[i],
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
            if (post.documentUrls.isNotEmpty) ...[
              const SizedBox(height: 10),
              ...post.documentUrls.map(
                (url) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Icon(Icons.description_outlined, size: 18, color: _cTeal),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Professional document',
                          style: TextStyle(color: _cBlue, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (post.experienceMeta['location'] != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.location_on_outlined, size: 14, color: sub),
                  const SizedBox(width: 4),
                  Text(
                    post.experienceMeta['location'].toString(),
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                ],
              ),
            ],
            if (post.experienceMeta['tags'] != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (post.experienceMeta['tags'] as List).map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _cTeal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      tag.toString(),
                      style: TextStyle(color: _cTeal, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  );
                }).toList(),
              ),
            ],
            if (post.experienceMeta['hashtags'] != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (post.experienceMeta['hashtags'] as List).map((tag) {
                  return Text(
                    tag.toString(),
                    style: TextStyle(color: _cBlue, fontSize: 12),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 14),
            _actions(context, community, isLiked, isSaved, tx, sub),
          ],
        ),
      ),
    );
  }

  bool get _hasExperienceCard {
    final m = post.experienceMeta;
    return m['hospital'] != null ||
        m['institution'] != null ||
        m['role'] != null ||
        m['title'] != null;
  }

  Widget _header(BuildContext context, Color tx, Color sub) {
    final subtitle = [
      if (post.authorRole != null && post.authorRole!.isNotEmpty) post.authorRole,
      if (post.authorSpecialty != null && post.authorSpecialty!.isNotEmpty)
        post.authorSpecialty,
      if (post.authorHospital != null && post.authorHospital!.isNotEmpty)
        post.authorHospital,
    ].whereType<String>().join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: _cTeal.withValues(alpha: 0.15),
          backgroundImage: post.authorAvatar != null && post.authorAvatar!.isNotEmpty
              ? NetworkImage(post.authorAvatar!)
              : null,
          child: post.authorAvatar == null || post.authorAvatar!.isEmpty
              ? Text(
                  post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: _cTeal,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      post.authorName,
                      style: TextStyle(
                        color: tx,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (post.authorVerified) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.verified_rounded, color: _cBlue, size: 15),
                  ],
                ],
              ),
              if (subtitle.isNotEmpty)
                Text(
                  subtitle,
                  style: TextStyle(color: sub, fontSize: 11.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 2),
              Text(
                '${ProfessionalPostUtils.timeAgo(post.createdAt)} · ${post.visibilityLabel}',
                style: TextStyle(color: sub, fontSize: 10.5),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.more_horiz_rounded, color: sub),
          onPressed: () => _showMoreMenu(context),
        ),
      ],
    );
  }

  Widget _categoryBadge(Color tx, Color sub) {
    final cat = post.category;
    if (cat == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _cTeal.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _cTeal.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cat.icon, size: 14, color: _cTeal),
          const SizedBox(width: 6),
          Text(
            cat.label,
            style: TextStyle(
              color: tx,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _experienceCard(Color tx, Color sub, Color border) {
    final m = post.experienceMeta;
    final hospital = m['hospital'] ?? m['institution'] ?? m['organization'];
    final role = m['role'] ?? m['title'];
    final specialty = m['specialty'];
    final duration = ProfessionalPostUtils.formatDuration(m);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
        color: _cTeal.withValues(alpha: 0.03),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hospital != null)
            Row(
              children: [
                Icon(Icons.local_hospital_outlined, size: 16, color: _cTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hospital.toString(),
                    style: TextStyle(
                      color: tx,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          if (role != null) ...[
            const SizedBox(height: 4),
            Text(
              role.toString(),
              style: TextStyle(
                color: tx,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (specialty != null)
            Text(specialty.toString(), style: TextStyle(color: sub, fontSize: 12)),
          if (duration.isNotEmpty)
            Text(duration, style: TextStyle(color: sub, fontSize: 11.5)),
        ],
      ),
    );
  }

  Widget _mediaPlaceholder(Color sub) => Container(
        height: 140,
        color: sub.withValues(alpha: 0.1),
        alignment: Alignment.center,
        child: Icon(Icons.image_not_supported_outlined, color: sub),
      );

  Widget _actions(
    BuildContext context,
    CommunityProvider community,
    bool isLiked,
    bool isSaved,
    Color tx,
    Color sub,
  ) {
    return Row(
      children: [
        _actionBtn(
          icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          label: '${post.likes}',
          color: isLiked ? const Color(0xFFEF4444) : sub,
          onTap: () => community.toggleLikePost(post.id),
        ),
        const SizedBox(width: 16),
        _actionBtn(
          icon: Icons.chat_bubble_outline_rounded,
          label: '${post.commentsCount}',
          color: _cBlue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostCommentsScreen(post: post),
            ),
          ),
        ),
        const SizedBox(width: 16),
        _actionBtn(
          icon: Icons.repeat_rounded,
          label: '${post.repostCount}',
          color: sub,
          onTap: () async {
            await community.incrementRepostCount(post.id);
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Reposted to your network'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        const Spacer(),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            color: isSaved ? _cTeal : sub,
            size: 22,
          ),
          onPressed: () async {
            final wasSaved = isSaved;
            await community.toggleSavePost(
              post.id,
              post.categoryLabel,
              post.content,
            );
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(wasSaved ? 'Removed from saved' : 'Post saved'),
                backgroundColor: _cTeal,
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(Icons.share_outlined, color: sub, size: 22),
          onPressed: () => Share.share(
            '${post.authorName}: ${post.content}\n\nShared via MedDuty',
          ),
        ),
      ],
    );
  }

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    final community = context.read<CommunityProvider>();
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner) ...[
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit'),
                onTap: () {
                  Navigator.pop(ctx);
                  _editPost(context, community);
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Change visibility'),
                onTap: () {
                  Navigator.pop(ctx);
                  _changeVisibility(context, community);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('Delete', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final ok = await community.deletePost(post.id);
                  if (ok) onDeleted?.call();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('Save'),
                onTap: () {
                  Navigator.pop(ctx);
                  community.toggleSavePost(post.id, post.categoryLabel, post.content);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Copy link'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'medduty://post/${post.id}'));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.flag_outlined),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(ctx);
                  showContentReportSheet(
                    context,
                    subjectLabel: 'this post',
                    targetId: post.id,
                    targetName: post.authorName,
                    reportType: 'professional_post_report',
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editPost(BuildContext context, CommunityProvider community) {
    final ctrl = TextEditingController(text: post.content);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit post'),
        content: TextField(
          controller: ctrl,
          maxLines: 5,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await community.updatePostContent(post.id, ctrl.text);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _changeVisibility(BuildContext context, CommunityProvider community) {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: PostVisibility.values.map((v) {
            return ListTile(
              title: Text(v.label),
              trailing: post.visibility == v ? const Icon(Icons.check, color: _cTeal) : null,
              onTap: () async {
                await community.updatePostVisibility(post.id, v);
                if (ctx.mounted) Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
