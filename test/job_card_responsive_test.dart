import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medduty/features/jobs/widgets/job_card.dart';
import 'package:medduty/models/job_model.dart';
import 'package:medduty/models/job_with_distance.dart';

void main() {
  testWidgets('JobCard renders with zero overflow on small mobile widths (320px to 430px)',
      (WidgetTester tester) async {
    final widths = [320.0, 360.0, 375.0, 390.0, 412.0, 430.0];

    final job = JobModel(
      id: 'job_test_1',
      hospitalId: 'hosp_1',
      hospitalName: 'Apollo Multispeciality Hospitals & Research Center',
      title: 'Senior Clinical Research Associate & Emergency Physician',
      specialization: 'Emergency Medicine',
      employmentType: EmploymentType.fullTime,
      workMode: WorkMode.onSite,
      salaryMin: 80000,
      salaryMax: 120000,
      salaryPeriod: 'month',
      experienceRequired: '3-5 years',
      qualification: 'MBBS, MD',
      location: 'Avadi, Chennai, Tamil Nadu, India',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      applicationDeadline: DateTime.now().add(const Duration(days: 14)),
      positions: 2,
      status: JobStatus.open,
      verified: true,
      workingHours: '9 AM - 5 PM',
    );

    final item = JobWithDistance(job: job, distanceKm: 4.8);

    for (final width in widths) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: JobCard(
                item: item,
                compact: true,
                actionLabel: 'View Job',
                onTap: () {},
                onApply: () {},
                onSave: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Senior Clinical Research Associate & Emergency Physician'), findsOneWidget);
      expect(find.text('View Job'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
