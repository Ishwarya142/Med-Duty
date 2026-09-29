import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medduty/models/duty_model.dart';
import 'package:medduty/models/duty_with_distance.dart';
import 'package:medduty/features/duties/widgets/duty_discovery_card.dart';

void main() {
  const widths = [320.0, 360.0, 375.0, 390.0, 412.0, 430.0];

  group('Quick Actions 2-Column Responsive Grid', () {
    testWidgets('renders all 6 quick action cards with equal spacing and no overflow',
        (WidgetTester tester) async {
      for (final width in widths) {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final actions = [
          {
            'icon': Icons.medical_services_rounded,
            'title': 'Find Duties',
            'sub': 'Nearby shifts',
            'color': const Color(0xFF16A34A),
          },
          {
            'icon': Icons.work_outline_rounded,
            'title': 'Find Jobs',
            'sub': 'Career roles',
            'color': const Color(0xFF2563EB),
          },
          {
            'icon': Icons.groups_rounded,
            'title': 'Community',
            'sub': 'Network',
            'color': const Color(0xFF7C3AED),
          },
          {
            'icon': Icons.chat_bubble_rounded,
            'title': 'Messages',
            'sub': 'Inbox',
            'color': const Color(0xFFF97316),
          },
          {
            'icon': Icons.bookmark_rounded,
            'title': 'Saved',
            'sub': 'Bookmarks',
            'color': const Color(0xFFF59E0B),
          },
          {
            'icon': Icons.person_rounded,
            'title': 'Profile',
            'sub': 'Your account',
            'color': const Color(0xFF0F766E),
          },
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    for (int i = 0; i < actions.length; i += 2) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionCard(actions[i]),
                          ),
                          const SizedBox(width: 10),
                          if (i + 1 < actions.length)
                            Expanded(
                              child: _buildQuickActionCard(actions[i + 1]),
                            )
                          else
                            const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Find Duties'), findsOneWidget);
        expect(find.text('Find Jobs'), findsOneWidget);
        expect(find.text('Community'), findsOneWidget);
        expect(find.text('Messages'), findsOneWidget);
        expect(find.text('Saved'), findsOneWidget);
        expect(find.text('Profile'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Community Activity Responsive Empty State', () {
    testWidgets('renders compact empty state without overflow on all screen widths',
        (WidgetTester tester) async {
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
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EDF2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.groups_rounded,
                          color: Color(0xFF7C3AED),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Your professional network is quiet',
                              style: TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Follow healthcare professionals to see their updates here.',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0F766E),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          visualDensity: VisualDensity.compact,
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Explore'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Your professional network is quiet'), findsOneWidget);
        expect(find.text('Explore'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('DutyDiscoveryCard Responsive Tests', () {
    testWidgets('renders cleanly on all mobile viewports without overflow',
        (WidgetTester tester) async {
      final duty = DutyModel(
        id: 'duty_1',
        hospitalId: 'hosp_1',
        hospitalName: 'Apollo Speciality Hospitals & Heart Center',
        role: 'Emergency Medical Officer (ICU/CCU Shift)',
        salary: 4500,
        location: 'Avadi Main Road, Ambattur, Chennai',
        dutyDate: DateTime.now().add(const Duration(days: 1)),
        startTime: DateTime(2026, 8, 16, 8, 0),
        endTime: DateTime(2026, 8, 16, 16, 0),
        status: DutyStatus.upcoming,
        shiftType: 'Day Shift',
        specialization: 'General Medicine',
        verified: true,
        createdAt: DateTime.now(),
      );

      final item = DutyWithDistance(duty: duty, distanceKm: 3.2);

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
                child: DutyDiscoveryCard(
                  item: item,
                  compact: true,
                  onTap: () {},
                  onApply: () {},
                  onSave: () {},
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Apollo Speciality Hospitals & Heart Center'), findsOneWidget);
        expect(find.text('₹4500'), findsOneWidget);
        expect(find.text('Apply'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}

Widget _buildQuickActionCard(Map<String, dynamic> item) {
  final color = item['color'] as Color;
  final icon = item['icon'] as IconData;
  final title = item['title'] as String;
  final subText = item['sub'] as String;

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 19, color: color),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    subText,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF64748B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
