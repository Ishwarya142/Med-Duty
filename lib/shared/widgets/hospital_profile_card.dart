import 'package:flutter/material.dart';

class HospitalProfileCard extends StatelessWidget {
  final String hospital;
  final String location;
  final String rating;

  const HospitalProfileCard({
    super.key,
    required this.hospital,
    required this.location,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 35,
              backgroundColor: Color(0xffFFE6EE),
              child: Icon(
                Icons.local_hospital,
                size: 35,
                color: Color(0xffFF5C8D),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hospital,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  Text(location),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 5),
                      Text(rating),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
