import 'package:flutter/material.dart';

class RecommendedHospitals extends StatelessWidget {
  const RecommendedHospitals({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        HospitalTile(
          hospital: "Apollo Hospital",
          city: "Chennai",
          rating: "4.9",
        ),
        SizedBox(height: 15),
        HospitalTile(
          hospital: "Fortis Hospital",
          city: "Bangalore",
          rating: "4.8",
        ),
        SizedBox(height: 15),
        HospitalTile(
          hospital: "MIOT Hospital",
          city: "Chennai",
          rating: "4.7",
        ),
      ],
    );
  }
}

class HospitalTile extends StatelessWidget {
  final String hospital;
  final String city;
  final String rating;

  const HospitalTile({
    super.key,
    required this.hospital,
    required this.city,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
          )
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xffFFE6EE),
            child: Icon(
              Icons.local_hospital,
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
                    fontSize: 17,
                  ),
                ),
                Text(
                  city,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const Icon(
                Icons.star,
                color: Colors.amber,
                size: 18,
              ),
              Text(rating),
            ],
          )
        ],
      ),
    );
  }
}