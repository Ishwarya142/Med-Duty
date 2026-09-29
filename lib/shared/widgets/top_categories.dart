import 'package:flutter/material.dart';

class TopCategories extends StatelessWidget {
  const TopCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {"icon": Icons.emergency, "title": "Emergency"},
      {"icon": Icons.favorite, "title": "Cardiology"},
      {"icon": Icons.child_care, "title": "Pediatrics"},
      {"icon": Icons.local_hospital, "title": "ICU"},
      {"icon": Icons.medication, "title": "Surgery"},
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final item = categories[index];

          return Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: const Color(0xffFFE6EE),
                  child: Icon(
                    item["icon"] as IconData,
                    color: const Color(0xffFF5C8D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item["title"] as String,
                  style: const TextStyle(fontSize: 13),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}