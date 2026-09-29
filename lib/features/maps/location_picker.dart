import 'package:flutter/material.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: "Search Location",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 25),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.my_location),
              label: const Text("Use Current Location"),
            ),
          ],
        ),
      ),
    );
  }
}
