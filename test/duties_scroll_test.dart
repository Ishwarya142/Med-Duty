import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medduty/models/duty_model.dart';
import 'package:medduty/models/duty_with_distance.dart';
import 'package:medduty/features/duties/widgets/duty_discovery_card.dart';

void main() {
  const widths = [320.0, 360.0, 375.0, 390.0, 412.0, 430.0];

  final mockDuty = DutyModel(
    id: 'duty_scroll_1',
    hospitalId: 'hosp_1',
    hospitalName: 'Apollo Speciality Hospital',
    role: 'Emergency Medical Officer (ICU)',
    salary: 3500,
    location: 'Greams Road, Chennai',
    dutyDate: DateTime.now().add(const Duration(days: 1)),
    startTime: DateTime(2026, 8, 16, 8, 0),
    endTime: DateTime(2026, 8, 16, 16, 0),
    status: DutyStatus.upcoming,
    shiftType: 'Day Shift',
    specialization: 'Cardiology',
    verified: true,
    createdAt: DateTime.now(),
  );

  final mockItem = DutyWithDistance(
    duty: mockDuty,
    distanceKm: 3.2,
  );

  testWidgets('Duties single CustomScrollView layout scrolls smoothly across mobile widths',
      (WidgetTester tester) async {
    for (final width in widths) {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              key: ValueKey(width),
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Top location section
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Avadi, Chennai'),
                        const Text('Within 10 km'),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                child: const Text('Radius'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                onPressed: () {},
                                child: const Text('View Map'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Pinned Tab Bar
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TestTabDelegate(
                    child: Container(
                      height: 48,
                      color: Colors.white,
                      child: const Text('Nearby • Completed • Upcoming'),
                    ),
                  ),
                ),
                // Duty cards list
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: DutyDiscoveryCard(
                            item: mockItem,
                            isApplied: false,
                            isSaved: false,
                            onTap: () {},
                            onApply: () {},
                            onSave: () {},
                          ),
                        );
                      },
                      childCount: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify full height and elements exist before scroll
      expect(find.byType(CustomScrollView), findsOneWidget);
      expect(find.text('Radius'), findsOneWidget);
      expect(find.text('View Map'), findsOneWidget);
      expect(find.text('Nearby • Completed • Upcoming'), findsOneWidget);

      // Perform scroll drag: location section scrolls away, pinned tab remains
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Pinned header remains visible
      expect(find.text('Nearby • Completed • Upcoming'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}

class _TestTabDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TestTabDelegate({required this.child});

  @override
  double get minExtent => 48.0;

  @override
  double get maxExtent => 48.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _TestTabDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
