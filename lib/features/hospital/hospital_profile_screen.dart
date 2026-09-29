import 'package:flutter/material.dart';

class HospitalProfileScreen extends StatelessWidget {
  const HospitalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFFF5F8),
      appBar: AppBar(
        title: const Text("Hospital Profile"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          const CircleAvatar(
            radius: 55,
            backgroundColor: Color(0xffFFE6EE),
            child: Icon(
              Icons.local_hospital,
              size: 60,
              color: Color(0xffFF5C8D),
            ),
          ),

          const SizedBox(height: 20),

          const Center(
            child: Text(
              "Apollo Hospital",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const ListTile(
            leading: Icon(Icons.location_on),
            title: Text("Location"),
            subtitle: Text("Chennai, Tamil Nadu"),
          ),

          const ListTile(
            leading: Icon(Icons.phone),
            title: Text("Phone"),
            subtitle: Text("+91 9876543210"),
          ),

          const ListTile(
            leading: Icon(Icons.email),
            title: Text("Email"),
            subtitle: Text("apollo@hospital.com"),
          ),

          const ListTile(
            leading: Icon(Icons.language),
            title: Text("Website"),
            subtitle: Text("www.apollohospital.com"),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5C8D),
                foregroundColor: Colors.white,
              ),
              onPressed: () {},
              child: const Text("Edit Hospital Profile"),
            ),
          ),
        ],
      ),
    );
  }
}