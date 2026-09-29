import 'package:flutter/material.dart';

class DutyDetailsCard extends StatelessWidget {
  final String hospital;
  final String speciality;
  final String location;
  final String salary;
  final String shift;
  final String distance;

  const DutyDetailsCard({
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            Row(
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
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        hospital,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        speciality,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                const Icon(Icons.location_on,size:18),

                const SizedBox(width:5),

                Text(location),

                const Spacer(),

                Text(distance),
              ],
            ),

            const SizedBox(height:10),

            Row(
              children: [

                const Icon(Icons.schedule,size:18),

                const SizedBox(width:5),

                Text(shift),

                const Spacer(),

                Text(
                  salary,
                  style: const TextStyle(
                    color: Color(0xffFF5C8D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height:20),

            Row(
              children: [

                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text("View"),
                  ),
                ),

                const SizedBox(width:12),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xffFF5C8D),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {},
                    child: const Text("Apply"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}