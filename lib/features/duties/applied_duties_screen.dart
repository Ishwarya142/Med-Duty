import 'package:flutter/material.dart';

class AppliedDutiesScreen extends StatelessWidget {
  const AppliedDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duties = [
      {
        "title": "Emergency Shift",
        "hospital": "Apollo Hospital",
        "status": "Upcoming"
      },
      {
        "title": "Night Duty",
        "hospital": "Fortis Hospital",
        "status": "Completed"
      },
      {
        "title": "ICU Coverage",
        "hospital": "MIOT Hospital",
        "status": "Cancelled"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Applied Duties"),
      ),
      body: ListView.builder(
        itemCount: duties.length,
        itemBuilder: (context, index) {
          final duty = duties[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(
                Icons.work_history,
                color: Color(0xffFF5C8D),
              ),
              title: Text(duty["title"]!),
              subtitle: Text(duty["hospital"]!),
              trailing: Text(
                duty["status"]!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}