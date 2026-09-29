import 'package:flutter/material.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ActivityTile(
          title: "Duty Application Sent",
          subtitle: "Apollo Hospital",
          icon: Icons.send,
        ),
        SizedBox(height: 12),
        ActivityTile(
          title: "Application Accepted",
          subtitle: "Fortis Hospital",
          icon: Icons.check_circle,
        ),
        SizedBox(height: 12),
        ActivityTile(
          title: "New Duty Posted",
          subtitle: "MIOT Hospital",
          icon: Icons.notifications,
        ),
      ],
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const ActivityTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xffFFE6EE),
        child: Icon(
          icon,
          color: const Color(0xffFF5C8D),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
    );
  }
}