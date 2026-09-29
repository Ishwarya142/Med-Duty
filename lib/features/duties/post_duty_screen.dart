import 'package:flutter/material.dart';

class PostDutyScreen extends StatelessWidget {
  const PostDutyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Post Duty")),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          TextField(
            decoration: InputDecoration(
              labelText: "Duty Title",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            decoration: InputDecoration(
              labelText: "Department",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            decoration: InputDecoration(
              labelText: "Salary",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text("Post Duty"),
            ),
          ),
        ],
      ),
    );
  }
}