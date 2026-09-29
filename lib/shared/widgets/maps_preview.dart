import 'package:flutter/material.dart';

class MapsPreview extends StatelessWidget {
  const MapsPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Icon(
          Icons.map,
          size: 70,
          color: Colors.grey,
        ),
      ),
    );
  }
}