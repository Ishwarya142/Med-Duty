import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class CommentModel {
  final String id;
  final String username;
  final String? avatarUrl;
  final DateTime timestamp;
  final String text;
  final int likes;
  final bool likedByAuthor;
  final bool isVerified;
  final List<CommentModel>? replies;
  final bool hasLiked;
  final bool likedByMe;
  final Color avatarColor;

  CommentModel({
    required this.id,
    required this.username,
    this.avatarUrl,
    required this.timestamp,
    required this.text,
    this.likes = 0,
    this.likedByAuthor = false,
    this.isVerified = false,
    this.replies,
    this.hasLiked = false,
    this.likedByMe = false,
    this.avatarColor = const Color(0xFF0F766E),
  });
}

class CommentsScreen extends StatefulWidget {
  final String postAuthorUsername;
  final String? postAuthorAvatar;
  final Color postAuthorColor;
  final List<CommentModel>? initialComments;

  const CommentsScreen({
    super.key,
    this.postAuthorUsername = 'medduty.official',
    this.postAuthorAvatar,
    this.postAuthorColor = const Color(0xFF0F766E),
    this.initialComments,
  });

  static Future<void> show(
    BuildContext context, {
    String postAuthorUsername = 'medduty.official',
    String? postAuthorAvatar,
    Color postAuthorColor = const Color(0xFF0F766E),
    List<CommentModel>? initialComments,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (c) => CommentsScreen(
        postAuthorUsername: postAuthorUsername,
        postAuthorAvatar: postAuthorAvatar,
        postAuthorColor: postAuthorColor,
        initialComments: initialComments,
      ),
    );
  }

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late List<CommentModel> _comments;
  final TextEditingController _commentCtrl = TextEditingController();
  final Set<String> _expandedThreads = {};

  static const List<String> _quickEmojis = [
    '❤️',
    '🙌',
    '🔥',
    '👏',
    '😢',
    '😍',
    '😮',
    '😂',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialComments != null && widget.initialComments!.isNotEmpty) {
      _comments = List<CommentModel>.from(widget.initialComments!);
    } else {
      final now = DateTime.now();
      _comments = [
        CommentModel(
          id: '1',
          username: 'dr.ashhaffwags',
          timestamp: now.subtract(const Duration(days: 6)),
          text:
              'Where is this? Can the public view it? It\'s unbelievably beautiful ✨',
          likes: 80,
          replies: [
            CommentModel(
              id: '1-1',
              username: 'nurse.priya',
              timestamp: now.subtract(const Duration(days: 5, hours: 8)),
              text: 'It\'s the new super speciality block at Apollo Chennai!',
              likes: 12,
              isVerified: true,
              avatarColor: const Color(0xFF7C3AED),
            ),
            CommentModel(
              id: '1-2',
              username: 'dr.rahul.cardiology',
              timestamp: now.subtract(const Duration(days: 5, hours: 3)),
              text:
                  'Incredible architecture 🔥 Visiting next month for a conference!',
              likes: 7,
              avatarColor: const Color(0xFFF59E0B),
            ),
            CommentModel(
              id: '1-3',
              username: 'sister.anjali',
              timestamp: now.subtract(const Duration(days: 4, hours: 19)),
              text:
                  'Visited last week! The healing gardens are even more stunning 💚',
              likes: 19,
              avatarColor: const Color(0xFF2563EB),
            ),
          ],
          avatarColor: const Color(0xFFEF4444),
        ),
        CommentModel(
          id: '2',
          username: 'tow.studios.clinic',
          timestamp: now.subtract(const Duration(days: 6, hours: 12)),
          text: 'Where is this? Its amazing! 👏',
          likes: 10,
          avatarColor: const Color(0xFF6366F1),
        ),
        CommentModel(
          id: '3',
          username: 'dr.challah.cat',
          timestamp: now.subtract(const Duration(days: 3)),
          text: 'This reminds me of the airport in Madrid... ❤️',
          likes: 4,
          likedByAuthor: true,
          isVerified: true,
          avatarColor: const Color(0xFF10B981),
        ),
        CommentModel(
          id: '4',
          username: 'amber.arbucci.health',
          timestamp: now.subtract(const Duration(days: 5)),
          text: 'Wow stunning 🤍',
          likes: 2,
          likedByAuthor: true,
          isVerified: true,
          avatarColor: const Color(0xFFEC4899),
          replies: [
            CommentModel(
              id: '4-1',
              username: 'dr.neha.pediatrics',
              timestamp: now.subtract(const Duration(days: 4, hours: 10)),
              text: 'Right?! 10/10 aesthetic + patient-friendly design 💯',
              likes: 5,
              avatarColor: const Color(0xFF14B8A6),
            ),
          ],
        ),
      ];
    }
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inSeconds < 60) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
    return '${(diff.inDays / 365).floor()}y';
  }

  Widget _avatar({
    required String username,
    String? url,
    required Color color,
    double size = 36,
  }) {
    final initials = username
        .replaceAll('.', ' ')
        .trim()
        .split(' ')
        .where((s) => s.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _commentRow({
    required CommentModel c,
    required bool isDark,
    required Color textColor,
    required Color subColor,
    bool isReply = false,
  }) {
    final hasReplies = c.replies != null && c.replies!.isNotEmpty;
    final expanded = _expandedThreads.contains(c.id);
    final visibleReplies = hasReplies && expanded
        ? c.replies!
        : <CommentModel>[];
    final hiddenCount = hasReplies
        ? c.replies!.length - visibleReplies.length
        : 0;

    return Padding(
      padding: EdgeInsets.only(left: isReply ? 52 : 16, right: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _avatar(
                username: c.username,
                url: c.avatarUrl,
                color: c.avatarColor,
                size: isReply ? 30 : 36,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          c.username,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (c.isVerified) ...[
                          const SizedBox(width: 3),
                          const Icon(
                            Icons.verified,
                            color: Color(0xFF0EA5E9),
                            size: 14,
                          ),
                        ],
                        const SizedBox(width: 6),
                        Text(
                          _formatTime(c.timestamp),
                          style: TextStyle(
                            color: subColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (c.likedByAuthor) ...[
                          const SizedBox(width: 6),
                          Text(
                            '·',
                            style: TextStyle(color: subColor, fontSize: 12),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.favorite,
                            color: Color(0xFFEF4444),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'by author',
                            style: TextStyle(
                              color: subColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      c.text,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          'Reply',
                          style: TextStyle(
                            color: subColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                children: [
                  Icon(
                    c.likedByMe ? Icons.favorite : Icons.favorite_border,
                    color: c.likedByMe ? const Color(0xFFEF4444) : subColor,
                    size: 15,
                  ),
                  if (c.likes > 0) ...[
                    const SizedBox(height: 3),
                    Text(
                      '${c.likes}',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          if (hasReplies && !expanded && hiddenCount > 0) ...[
            Padding(
              padding: const EdgeInsets.only(left: 48, top: 4),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 1,
                    decoration: BoxDecoration(
                      color: subColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() => _expandedThreads.add(c.id));
                    },
                    child: Text(
                      'View $hiddenCount more ${hiddenCount == 1 ? 'reply' : 'replies'}',
                      style: TextStyle(
                        color: subColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (hasReplies && expanded) ...[
            const SizedBox(height: 4),
            ...visibleReplies.map(
              (r) => _commentRow(
                c: r,
                isDark: isDark,
                textColor: textColor,
                subColor: subColor,
                isReply: true,
              ),
            ),
            if (hiddenCount > 0)
              Padding(
                padding: const EdgeInsets.only(left: 48, top: 2),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _expandedThreads.remove(c.id));
                  },
                  child: Text(
                    'Hide replies',
                    style: TextStyle(
                      color: subColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final subColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final bgColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final inputBg = isDark
        ? AppColors.darkSurfaceVariant
        : const Color(0xFFF1F5F9);

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.55,
      maxChildSize: 0.96,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 6),
                child: Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: subColor.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      'Comments',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.1,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.send_outlined,
                        color: textColor,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Divider(color: borderColor, height: 0.5, thickness: 0.5),
              ),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.only(top: 6, bottom: 12),
                  children: _comments
                      .map(
                        (c) => _commentRow(
                          c: c,
                          isDark: isDark,
                          textColor: textColor,
                          subColor: subColor,
                        ),
                      )
                      .toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: SizedBox(
                  height: 30,
                  child: Row(
                    children: List.generate(_quickEmojis.length, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _commentCtrl.text += _quickEmojis[i];
                            });
                          },
                          child: Text(
                            _quickEmojis[i],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 14, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _avatar(
                        username: 'dr.you',
                        color: widget.postAuthorColor,
                        size: 34,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _commentCtrl,
                          style: TextStyle(color: textColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText:
                                'Add a comment for ${widget.postAuthorUsername}...',
                            hintStyle: TextStyle(
                              color: subColor,
                              fontSize: 13.5,
                            ),
                            filled: true,
                            fillColor: inputBg,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 11,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(color: borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: AppColors.accent.withValues(alpha: 0.4),
                              ),
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Icon(
                                Icons.insert_emoticon_outlined,
                                color: subColor,
                                size: 22,
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(
                              minWidth: 36,
                              minHeight: 36,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
