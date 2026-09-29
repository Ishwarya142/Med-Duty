import 'package:flutter/material.dart';

class SpecialistDutiesScreen extends StatelessWidget {
  const SpecialistDutiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final specialities = [
      "Cardiologist",
      "Neurologist",
      "Orthopedic",
      "Pediatrician",
      "General Surgeon",
      "Anesthesiologist",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Specialist Duties"),
      ),
      body: ListView.builder(
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xffFFE6EE),
                child: Icon(
                  Icons.medical_services,
                  color: Color(0xffFF5C8D),
                ),
              ),
              title: Text(specialities[index]),
              subtitle: const Text("15 Duties Available"),
              trailing: const Icon(Icons.arrow_forward_ios),
            ),
          );
        },
      ),
    );
  }
}
