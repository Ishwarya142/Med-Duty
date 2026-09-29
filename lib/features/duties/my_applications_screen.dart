import 'package:flutter/material.dart';

class MyApplicationsScreen extends StatelessWidget {
  const MyApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applications = [
      {
        "hospital": "Apollo Hospital",
        "status": "Pending",
        "date": "20 July"
      },
      {
        "hospital": "Fortis Hospital",
        "status": "Accepted",
        "date": "18 July"
      },
      {
        "hospital": "MIOT Hospital",
        "status": "Rejected",
        "date": "16 July"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Applications"),
      ),
      body: ListView.builder(
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final app = applications[index];

          Color color = Colors.orange;

          if (app["status"] == "Accepted") {
            color = Colors.green;
          }

          if (app["status"] == "Rejected") {
            color = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(Icons.assignment),
              title: Text(app["hospital"]!),
              subtitle: Text(app["date"]!),
              trailing: Chip(
                label: Text(app["status"]!),
                backgroundColor: color.withValues(alpha: 0.15),
                labelStyle: TextStyle(color: color),
              ),
            ),
          );
        },
      ),
    );
  }
}