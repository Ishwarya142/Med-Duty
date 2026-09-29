import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  Widget statTile(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.softShadow,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.04), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hospital Dashboard"),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Analytics Overview",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black, letterSpacing: -0.5),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: statTile("Total Duties", "25 Active", Icons.assignment_outlined, AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: statTile("Applicants", "180 Total", Icons.people_outline_rounded, Colors.blue)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: statTile("Hired Staff", "72 Shift", Icons.check_circle_outline_rounded, AppColors.success)),
                const SizedBox(width: 12),
                Expanded(child: statTile("Budget Spent", "₹4.8 Lakh", Icons.currency_rupee_rounded, Colors.orange)),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Application Traffic (Weekly)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
            ),
            const SizedBox(height: 14),
            // Custom Painter Chart Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.04), width: 1.5),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Applications Received",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.black),
                      ),
                      Text(
                        "+12% vs last week",
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: AnalyticsChartPainter(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Labels Row
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Mon", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Tue", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Wed", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Thu", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Fri", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Sat", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                      Text("Sun", style: TextStyle(color: AppColors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Beautiful Custom Painter to draw bar charts with pink-red neon look
class AnalyticsChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.primaryGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final backgroundPaint = Paint()
      ..color = AppColors.blueTint.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final double barWidth = size.width / 15;
    final double space = size.width / 10;
    
    final heights = [0.4, 0.6, 0.35, 0.8, 0.55, 0.72, 0.9]; // Bar ratio heights

    for (int i = 0; i < heights.length; i++) {
      final double x = (i * (barWidth + space)) + space / 2;
      final double y = size.height * (1 - heights[i]);

      // Background tracking line
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 0, barWidth, size.height),
          const Radius.circular(8),
        ),
        backgroundPaint,
      );

      // Active value bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, size.height * heights[i]),
          const Radius.circular(8),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
