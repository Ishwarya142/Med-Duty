import 'package:flutter/material.dart';

class AppliedDutiesScreen extends StatelessWidget {
  const AppliedDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Applied Duties"),
      ),
      body: const Center(
        child: Text(
          "No Active Duties",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
