import 'package:flutter/material.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  Widget action(IconData icon, String title) {
    return Column(
      children: [
        Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            color: const Color(0xffFFE6EE),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            icon,
            color: Color(0xffFF5C8D),
          ),
        ),
        const SizedBox(height: 8),
        Text(title),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Quick(Icons.add_box_outlined, "Post"),
        _Quick(Icons.location_on_outlined, "Nearby"),
        _Quick(Icons.chat_outlined, "Chat"),
        _Quick(Icons.bookmark_outline, "Saved"),
      ],
    );
  }
}

class _Quick extends StatelessWidget {
  final IconData icon;
  final String title;

  const _Quick(this.icon, this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Color(0xffFFE6EE),
          child: Icon(
            icon,
            color: Color(0xffFF5C8D),
          ),
        ),
        SizedBox(height: 8),
        Text(title),
      ],
    );
  }
}