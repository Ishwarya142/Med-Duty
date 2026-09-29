import 'package:flutter/material.dart';

class ManageDutiesScreen extends StatelessWidget {
  const ManageDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duties = [
      {
        "title": "Night Shift",
        "department": "Emergency",
        "date": "20 July"
      },
      {
        "title": "Morning OP",
        "department": "Cardiology",
        "date": "22 July"
      },
      {
        "title": "ICU Duty",
        "department": "ICU",
        "date": "25 July"
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Duties"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffFF5C8D),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {},
      ),
      body: ListView.builder(
        itemCount: duties.length,
        itemBuilder: (context, index) {
          final duty = duties[index];

          return Card(
            margin: const EdgeInsets.all(12),
            child: ListTile(
              leading: const Icon(
                Icons.medical_services,
                color: Color(0xffFF5C8D),
              ),
              title: Text(duty["title"]!),
              subtitle:
                  Text("${duty["department"]}\n${duty["date"]}"),
              isThreeLine: true,
              trailing: PopupMenuButton(
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 1,
                    child: Text("Edit"),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Text("Delete"),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}