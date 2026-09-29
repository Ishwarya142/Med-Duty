import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../duties/post_duty_screen.dart';
import 'post_job_screen.dart';

/// Hospital/clinic owner chooses between posting a duty or a job.
class PostOpportunityScreen extends StatelessWidget {
  const PostOpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What would you like to post?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Duties are for immediate or temporary staffing. Jobs are for employment opportunities.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            _OptionCard(
              icon: Icons.schedule_rounded,
              color: const Color(0xFF0F766E),
              title: 'Duty',
              subtitle:
                  'Emergency, shift, locum, or short-term coverage. Uses existing duty posting flow.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostDutyScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _OptionCard(
              icon: Icons.work_outline_rounded,
              color: const Color(0xFF2563EB),
              title: 'Job',
              subtitle:
                  'Full-time, part-time, contract, or permanent employment opportunity.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostJobScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
