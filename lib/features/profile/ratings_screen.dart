import 'package:flutter/material.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        "name": "Apollo Hospital",
        "rating": "★★★★★",
        "review": "Excellent professionalism."
      },
      {
        "name": "Fortis Hospital",
        "rating": "★★★★☆",
        "review": "Very punctual."
      },
      {
        "name": "MIOT Hospital",
        "rating": "★★★★★",
        "review": "Highly recommended."
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ratings"),
      ),
      body: ListView.builder(
        itemCount: reviews.length,
        itemBuilder: (context, index) {
          final item = reviews[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.star),
              ),
              title: Text(item["name"]!),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["rating"]!),
                  Text(item["review"]!),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}