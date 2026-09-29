import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/community_provider.dart';
import '../../providers/profile_provider.dart';
import '../../models/community_post_model.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityProvider>().loadPosts();
      context.read<CommunityProvider>().loadSavedPosts();
      context.read<CommunityProvider>().loadLikedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final communityProvider = context.watch<CommunityProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    final tabs = ['Your Posts', 'Liked', 'Saved', 'Followers', 'Following'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Community'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Stats Cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Posts',
                    communityProvider.posts.length,
                    Icons.description,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Followers',
                    profileProvider.followersCount,
                    Icons.people,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Following',
                    profileProvider.followingCount,
                    Icons.person_add,
                  ),
                ),
              ],
            ),
          ),
          // Tabs
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(tabs[index]),
                    selected: _selectedIndex == index,
                    onSelected: (selected) {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      color: _selectedIndex == index
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Content
          Expanded(child: _buildContent(communityProvider, _selectedIndex)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CommunityProvider communityProvider, int index) {
    switch (index) {
      case 0:
        return _buildPostsList(communityProvider.posts, communityProvider);
      case 1:
        return _buildPostsList(communityProvider.likedPosts, communityProvider);
      case 2:
        return _buildPostsList(communityProvider.savedPosts, communityProvider);
      case 3:
        return _buildUsersList('Followers');
      case 4:
        return _buildUsersList('Following');
      default:
        return const SizedBox();
    }
  }

  Widget _buildPostsList(
    List<CommunityPostModel> posts,
    CommunityProvider provider,
  ) {
    if (posts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.article_outlined,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'No posts found',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: posts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _buildPostCard(post, provider);
      },
    );
  }

  Widget _buildPostCard(CommunityPostModel post, CommunityProvider provider) {
    final isLiked = provider.isPostLiked(post.id);
    final isSaved = provider.isPostSaved(post.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.secondary,
                child: Text(
                  post.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${post.createdAt.day}/${post.createdAt.month}/${post.createdAt.year}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            post.content,
            style: const TextStyle(color: AppColors.white, fontSize: 14),
          ),
          const SizedBox(height: 12),
          if (post.imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                post.imageUrls.first,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  color: isLiked ? AppColors.error : AppColors.textSecondary,
                ),
                onPressed: () async {
                  await provider.toggleLikePost(post.id);
                },
              ),
              Text(
                '${post.likes}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: isSaved ? AppColors.accent : AppColors.textSecondary,
                ),
                onPressed: () async {
                  await provider.toggleSavePost(
                    post.id,
                    post.authorName,
                    post.content,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(String title) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              '$title list',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
