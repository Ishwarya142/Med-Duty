import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/community_provider.dart';
import '../../profile/widgets/professional_post_card.dart';

const _cTeal = Color(0xFF0F766E);

/// Dedicated section for professional posts from followed healthcare professionals.
class ProfessionalUpdatesSection extends StatelessWidget {
  const ProfessionalUpdatesSection({
    super.key,
    required this.tx,
    required this.sub,
    required this.card,
    required this.border,
  });

  final Color tx;
  final Color sub;
  final Color card;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityProvider>();
    final posts = community.networkProfessionalPosts;

    if (community.networkLoading && posts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: _cTeal.withValues(alpha: 0.8)),
        ),
      );
    }

    if (posts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.work_history_rounded, color: _cTeal, size: 20),
              const SizedBox(width: 8),
              Text(
                'Professional Updates',
                style: TextStyle(
                  color: tx,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                'From your network',
                style: TextStyle(color: sub, fontSize: 12),
              ),
            ],
          ),
        ),
        ...posts.take(5).map(
              (post) => ProfessionalPostCard(
                post: post,
                showAuthorHeader: true,
                isOwner: false,
              ),
            ),
        if (posts.length > 5)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '${posts.length - 5} more updates from your network',
              style: TextStyle(color: sub, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
