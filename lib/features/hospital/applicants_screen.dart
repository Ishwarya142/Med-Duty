import 'package:flutter/material.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final applicants = [
      {
        "name": "Dr. Priya",
        "speciality": "Cardiologist",
        "experience": "6 Years"
      },
      {
        "name": "Dr. Rahul",
        "speciality": "Neurologist",
        "experience": "8 Years"
      },
      {
        "name": "Nurse Kavya",
        "speciality": "ICU Nurse",
        "experience": "5 Years"
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Applicants")),
      body: ListView.builder(
        itemCount: applicants.length,
        itemBuilder: (context, index) {
          final user = applicants[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffFFE6EE),
                child: Icon(Icons.person, color: Color(0xffFF5C8D)),
              ),
              title: Text(user["name"]!),
              subtitle: Text(
                  "${user["speciality"]}\n${user["experience"]} Experience"),
              isThreeLine: true,
              trailing: PopupMenuButton(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 1, child: Text("Accept")),
                  PopupMenuItem(value: 2, child: Text("Reject")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}