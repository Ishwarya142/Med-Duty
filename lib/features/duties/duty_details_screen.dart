import 'package:flutter/material.dart';

class DutyDetailsScreen extends StatelessWidget {
  const DutyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Duty Details"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Emergency Night Duty",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            const Text("Hospital : Apollo Hospital"),
            const Text("Department : Emergency"),
            const Text("Salary : ₹15,000"),
            const Text("Duration : 12 Hours"),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text("Apply"),
              ),
            )
          ],
        ),
      ),
    );
  }
}