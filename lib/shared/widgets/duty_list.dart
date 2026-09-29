import 'package:flutter/material.dart';

class DutyList extends StatelessWidget {
  const DutyList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        DutyCard(
          hospital: "Apollo Hospital",
          speciality: "General Physician",
          location: "Chennai",
          salary: "₹8,000",
          shift: "Night Shift",
          distance: "2.5 km",
        ),

        SizedBox(height: 18),

        DutyCard(
          hospital: "Fortis Hospital",
          speciality: "Cardiologist",
          location: "Bangalore",
          salary: "₹12,500",
          shift: "Day Shift",
          distance: "5 km",
        ),

        SizedBox(height: 18),

        DutyCard(
          hospital: "SRM Medical College",
          speciality: "Emergency Medicine",
          location: "Kattankulathur",
          salary: "₹9,500",
          shift: "24 Hours",
          distance: "9 km",
        ),
      ],
    );
  }
}

class DutyCard extends StatelessWidget {
  final String hospital;
  final String speciality;
  final String location;
  final String salary;
  final String shift;
  final String distance;

  const DutyCard({
    super.key,
    required this.hospital,
    required this.speciality,
    required this.location,
    required this.salary,
    required this.shift,
    required this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [

          Row(
            children: [

              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xffFFE6EE),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.local_hospital,
                  color: Color(0xffFF5C8D),
                  size: 30,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      speciality,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.bookmark_border,
                color: Color(0xffFF5C8D),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [

              const Icon(Icons.location_on,
                  size: 18,
                  color: Colors.red),

              const SizedBox(width: 5),

              Text(location),

              const Spacer(),

              Text(distance),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [

              const Icon(Icons.access_time,
                  size: 18,
                  color: Colors.orange),

              const SizedBox(width: 5),

              Text(shift),

              const Spacer(),

              Text(
                salary,
                style: const TextStyle(
                  color: Color(0xffFF5C8D),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffFF5C8D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {},
              child: const Text("Apply Now"),
            ),
          ),
        ],
      ),
    );
  }
}