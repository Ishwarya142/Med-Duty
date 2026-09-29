import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

const _cTeal = Color(0xFF0B7A75);
const _cBlue = Color(0xFF2563EB);
const _cGreen = Color(0xFF16A34A);
const _cPurple = Color(0xFF7C3AED);
const _cAmber = Color(0xFFF59E0B);
const _cRed = Color(0xFFEF4444);

class TrendingTopic {
  final String hashtag;
  final String description;
  final int postCount;
  final IconData icon;
  final Color color;

  TrendingTopic({
    required this.hashtag,
    required this.description,
    required this.postCount,
    required this.icon,
    required this.color,
  });
}

class TrendingTopicsScreen extends StatelessWidget {
  const TrendingTopicsScreen({super.key});

  List<TrendingTopic> get _topics => [
    TrendingTopic(
      hashtag: '#PostCOVIDComplications',
      description: 'Discussing long-term effects and recovery strategies for COVID-19 patients',
      postCount: 2400,
      icon: Icons.coronavirus_rounded,
      color: _cRed,
    ),
    TrendingTopic(
      hashtag: '#HealthcareBurnout',
      description: 'Support and resources for healthcare professionals dealing with burnout',
      postCount: 1800,
      icon: Icons.psychology_rounded,
      color: _cAmber,
    ),
    TrendingTopic(
      hashtag: '#AIinDiagnostics',
      description: 'Exploring artificial intelligence applications in medical diagnostics',
      postCount: 3100,
      icon: Icons.smart_toy_rounded,
      color: _cPurple,
    ),
    TrendingTopic(
      hashtag: '#Telemedicine',
      description: 'Best practices and experiences with remote healthcare delivery',
      postCount: 1500,
      icon: Icons.video_call_rounded,
      color: _cBlue,
    ),
    TrendingTopic(
      hashtag: '#MedicalEthics',
      description: 'Ethical dilemmas and discussions in modern healthcare practice',
      postCount: 980,
      icon: Icons.balance_rounded,
      color: _cTeal,
    ),
    TrendingTopic(
      hashtag: '#SurgicalInnovation',
      description: 'Latest techniques and technologies in surgical procedures',
      postCount: 1200,
      icon: Icons.content_cut_rounded,
      color: _cGreen,
    ),
  ];

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final tx = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Trending Topics',
          style: TextStyle(color: tx, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _topics.length,
        itemBuilder: (context, index) {
          final topic = _topics[index];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TopicDetailScreen(topic: topic),
              ),
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: topic.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(topic.icon, color: topic.color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.hashtag,
                          style: TextStyle(
                            color: topic.color,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topic.description,
                          style: TextStyle(
                            color: sub,
                            fontSize: 12,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${_formatCount(topic.postCount)} posts',
                          style: TextStyle(
                            color: sub,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: sub, size: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TopicDetailScreen extends StatelessWidget {
  final TrendingTopic topic;

  const TopicDetailScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final card = isDark ? AppColors.darkCardBg : AppColors.lightCardBg;
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final tx = isDark ? AppColors.darkText : AppColors.lightText;
    final sub = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          topic.hashtag,
          style: TextStyle(color: topic.color, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: topic.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(topic.icon, color: topic.color, size: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.hashtag,
                            style: TextStyle(
                              color: topic.color,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${(topic.postCount / 1000).toStringAsFixed(1)}K posts',
                            style: TextStyle(
                              color: sub,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  topic.description,
                  style: TextStyle(
                    color: tx,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Related Posts', tx),
          const SizedBox(height: 12),
          _buildPostPlaceholder(card, border, tx, sub),
          _buildPostPlaceholder(card, border, tx, sub),
          const SizedBox(height: 20),
          _buildSectionHeader('Recent Posts', tx),
          const SizedBox(height: 12),
          _buildPostPlaceholder(card, border, tx, sub),
          _buildPostPlaceholder(card, border, tx, sub),
          _buildPostPlaceholder(card, border, tx, sub),
          const SizedBox(height: 20),
          _buildSectionHeader('Popular Posts', tx),
          const SizedBox(height: 12),
          _buildPostPlaceholder(card, border, tx, sub),
          _buildPostPlaceholder(card, border, tx, sub),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color tx) {
    return Text(
      title,
      style: TextStyle(
        color: tx,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPostPlaceholder(Color card, Color border, Color tx, Color sub) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20, backgroundColor: _cTeal.withValues(alpha: 0.15)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. Name', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.w600)),
                    Text('Specialty • Hospital', style: TextStyle(color: sub, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sample post content related to ${topic.hashtag}...',
            style: TextStyle(color: tx, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.favorite_border_rounded, color: sub, size: 18),
              const SizedBox(width: 4),
              Text('24', style: TextStyle(color: sub, fontSize: 12)),
              const SizedBox(width: 16),
              Icon(Icons.chat_bubble_outline_rounded, color: sub, size: 18),
              const SizedBox(width: 4),
              Text('8', style: TextStyle(color: sub, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
