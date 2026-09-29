import 'package:flutter/material.dart';

class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Applicants")),
      body: ListView(
        children: const [
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Dr. Rahul"),
            subtitle: Text("Cardiologist"),
          ),
          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Dr. Priya"),
            subtitle: Text("Neurologist"),
          ),
        ],
      ),
    );
  }
}
