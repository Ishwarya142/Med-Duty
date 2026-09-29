import 'package:flutter/material.dart';

class HospitalProfileScreen extends StatelessWidget {
  const HospitalProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Hospital Profile")),
      body: const Center(
        child: Text(
          "Hospital Profile",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
