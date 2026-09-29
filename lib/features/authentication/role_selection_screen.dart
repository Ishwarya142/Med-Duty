import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  Widget roleCard(
      IconData icon,
      String title,
      String subtitle,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: const Color(0xffFFE6EE),
          child: Icon(
            icon,
            color: const Color(0xffFF5C8D),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),
      appBar: AppBar(
        title: const Text("Choose Your Role"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            const SizedBox(height: 20),

            roleCard(
              Icons.medical_services,
              "Doctor",
              "Find and apply for duties",
            ),

            const SizedBox(height: 20),

            roleCard(
              Icons.local_hospital,
              "Nurse",
              "Find nursing duties",
            ),

            const SizedBox(height: 20),

            roleCard(
              Icons.business,
              "Hospital",
              "Post and manage duties",
            ),
          ],
        ),
      ),
    );
  }
}