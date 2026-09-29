import 'package:flutter/material.dart';

class MedDutyApp extends StatelessWidget {
  const MedDutyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("MedDuty")),
        body: const Center(
          child: Text(
            "App Working ✅",
            style: TextStyle(fontSize: 28),
          ),
        ),
      ),
    );
  }
}