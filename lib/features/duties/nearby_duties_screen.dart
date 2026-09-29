import 'package:flutter/material.dart';

class NearbyDutiesScreen extends StatelessWidget {
  const NearbyDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duties = [
      {
        "hospital": "Apollo Hospital",
        "role": "Cardiologist",
        "distance": "2.3 km",
        "salary": "₹15,000"
      },
      {
        "hospital": "Fortis Hospital",
        "role": "Emergency Doctor",
        "distance": "4.1 km",
        "salary": "₹18,000"
      },
      {
        "hospital": "MIOT Hospital",
        "role": "General Physician",
        "distance": "5.8 km",
        "salary": "₹12,000"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Duties"),
      ),
      body: ListView.builder(
        itemCount: duties.length,
        itemBuilder: (context, index) {
          final duty = duties[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(
                Icons.local_hospital,
                color: Color(0xffFF5C8D),
              ),
              title: Text(duty["hospital"]!),
              subtitle: Text(
                  "${duty["role"]}\n${duty["distance"]}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    duty["salary"]!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16)
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}