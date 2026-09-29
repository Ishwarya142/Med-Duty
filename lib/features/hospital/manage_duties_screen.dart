import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../jobs/post_opportunity_screen.dart';

class ManageDutiesScreen extends StatefulWidget {
  const ManageDutiesScreen({super.key});

  @override
  State<ManageDutiesScreen> createState() => _ManageDutiesScreenState();
}

class _ManageDutiesScreenState extends State<ManageDutiesScreen> {
  final List<Map<String, String>> duties = [
    {
      "role": "ICU Specialist",
      "hospital": "Apollo Hospital",
      "payout": "₹7000/day",
      "status": "Active",
    },
    {
      "role": "Emergency Duty ER",
      "hospital": "Apollo Hospital",
      "payout": "₹6500/day",
      "status": "Active",
    },
    {
      "role": "General Physician",
      "hospital": "Apollo Hospital",
      "payout": "₹5500/day",
      "status": "Paused",
    },
  ];

  void _deleteDuty(int index) {
    setState(() {
      duties.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Duty posting deleted successfully"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Manage Duties"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PostOpportunityScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      body: duties.isEmpty
          ? const Center(
              child: Text(
                "No duties posted yet. Tap + to post a shift!",
                style: TextStyle(color: AppColors.grey),
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: duties.length,
              itemBuilder: (context, index) {
                final duty = duties[index];
                final isActive = duty["status"] == "Active";

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.softShadow,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.04), width: 1.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.medical_services_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          duty["role"]!,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.black, fontSize: 15),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.success.withValues(alpha: 0.1) : AppColors.greyLight.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            duty["status"]!,
                            style: TextStyle(
                              color: isActive ? AppColors.success : AppColors.grey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        "${duty["hospital"]} • ${duty["payout"]}",
                        style: const TextStyle(color: AppColors.grey, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Edit shift details feature"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                          onPressed: () => _deleteDuty(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
