import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String buttonText;
  final VoidCallback? onTap;

  const SectionTitle({
    super.key,
    required this.title,
    this.buttonText = "See All",
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onTap ?? () {},
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Color(0xffFF5C8D),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}