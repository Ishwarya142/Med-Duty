import 'package:flutter/material.dart';

class FeaturedDutyCard extends StatelessWidget {
  const FeaturedDutyCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xffFF5C8D),
            Color(0xffFF8FAF),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            "FEATURED DUTY",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            "Apollo Hospital",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          const Text(
            "Emergency Physician",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 15),

          const Row(
            children: [

              Icon(
                Icons.location_on,
                color: Colors.white,
                size: 18,
              ),

              SizedBox(width: 5),

              Text(
                "Chennai",
                style: TextStyle(color: Colors.white),
              ),

              Spacer(),

              Text(
                "₹15,000",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xffFF5C8D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
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