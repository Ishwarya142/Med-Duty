import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget tile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xffFF5C8D)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            const CircleAvatar(
              radius: 55,
              backgroundColor: Color(0xffFFE6EE),
              child: Icon(
                Icons.person,
                size: 60,
                color: Color(0xffFF5C8D),
              ),
            ),

            const SizedBox(height: 15),

            const Text(
              "Dr. Priya",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Text(
              "Cardiologist",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 25),

            tile(Icons.edit, "Edit Profile", () {}),
            tile(Icons.workspace_premium, "Certificates", () {}),
            tile(Icons.star, "Ratings & Reviews", () {}),
            tile(Icons.settings, "Settings", () {}),
            tile(Icons.logout, "Logout", () {}),
          ],
        ),
      ),
    );
  }
}