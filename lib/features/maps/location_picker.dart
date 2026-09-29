import 'package:flutter/material.dart';

class LocationPicker extends StatelessWidget {
  const LocationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Location"),
      ),
      body: Column(
        children: [

          Expanded(
            child: Container(
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(
                  Icons.location_pin,
                  size: 100,
                  color: Colors.red,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xffFF5C8D),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {},
                child: const Text("Confirm Location"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}