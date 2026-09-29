import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/professional_post_utils.dart';
import '../../models/community_post_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/community_provider.dart';
import '../../shared/widgets/report_bottom_sheet.dart';

const _cTeal = Color(0xFF0F766E);

class PostCommentsScreen extends StatefulWidget {
  const PostCommentsScreen({super.key, required this.post});

  final CommunityPostModel post;

  @override
  State<PostCommentsScreen> createState() => _PostCommentsScreenState();
}

class _PostCommentsScreenState extends State<PostCommentsScreen> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submitComment(String authorName) async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final warning = ProfessionalPostUtils.getSensitiveInfoWarning(text);
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
              child: const Text('Edit'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Post Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (!mounted) return;
    setState(() => _sending = true);

    final community = context.read<CommunityProvider>();
    final ok = await community.addComment(
      widget.post.id,
      text,
      authorName,
    );

    if (ok) {
      _ctrl.clear();
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final community = context.watch<CommunityProvider>();
    final auth = context.watch<AuthProvider>();
    final authorName = auth.userData?['name']?.toString() ?? 'Doctor';

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text('Comments', style: TextStyle(color: tx, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: tx),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<PostCommentModel>>(
              stream: community.watchComments(widget.post.id),
              builder: (context, snap) {
                final comments = snap.data ?? [];
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, size: 48, color: sub.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet. Start the conversation.',
                          style: TextStyle(color: sub, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: comments.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = comments[i];
                    final isMine = c.authorId == auth.user?.uid;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: _cTeal.withValues(alpha: 0.15),
                            child: Text(
                              c.authorName.isNotEmpty
                                  ? c.authorName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: _cTeal,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      c.authorName,
                                      style: TextStyle(
                                        color: tx,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      icon: Icon(Icons.more_horiz_rounded, size: 18, color: sub),
                                      onSelected: (val) {
                                        if (val == 'delete') {
                                          community.deleteComment(widget.post.id, c.id);
                                        } else if (val == 'report') {
                                          showContentReportSheet(
                                            context,
                                            subjectLabel: 'Comment',
                                            targetId: c.id,
                                            targetName: c.authorName,
                                            reportType: 'comment',
                                          );
                                        }
                                      },
                                      itemBuilder: (ctx) => [
                                        if (isMine)
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                                SizedBox(width: 8),
                                                Text('Delete comment', style: TextStyle(color: Colors.red)),
                                              ],
                                            ),
                                          )
                                        else
                                          const PopupMenuItem(
                                            value: 'report',
                                            child: Row(
                                              children: [
                                                Icon(Icons.flag_outlined, size: 18),
                                                SizedBox(width: 8),
                                                Text('Report comment'),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  c.content,
                                  style: TextStyle(color: tx, fontSize: 13, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: card,
                border: Border(top: BorderSide(color: border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      style: TextStyle(color: tx),
                      decoration: InputDecoration(
                        hintText: 'Write a professional comment...',
                        hintStyle: TextStyle(color: sub),
                        filled: true,
                        fillColor: bg,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: _cTeal,
                    child: IconButton(
                      onPressed: _sending ? null : () => _submitComment(authorName),
                      icon: _sending
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
