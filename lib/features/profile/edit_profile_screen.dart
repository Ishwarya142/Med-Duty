import 'package:flutter/material.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),
      appBar: AppBar(
        title: const Text("Edit Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xffFFE6EE),
            child: Icon(
              Icons.person,
              size: 55,
              color: Color(0xffFF5C8D),
            ),
          ),

          const SizedBox(height: 25),

          TextField(
            decoration: InputDecoration(
              labelText: "Full Name",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            decoration: InputDecoration(
              labelText: "Email",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            decoration: InputDecoration(
              labelText: "Phone",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            decoration: InputDecoration(
              labelText: "Hospital",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 30),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5C8D),
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text("Save Changes"),
            ),
          ),
        ],
      ),
    );
  }
}