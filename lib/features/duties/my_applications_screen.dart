import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/geo_utils.dart';
import '../../models/application_model.dart';
import '../../models/duty_model.dart';
import '../../providers/duty_provider.dart';
import '../../providers/location_provider.dart';
import '../../models/duty_with_distance.dart';
import 'duty_details_screen.dart';

const _cTeal = Color(0xFF0F766E);
const _cGreen = Color(0xFF16A34A);
const _cBlue = Color(0xFF2563EB);
const _cAmber = Color(0xFFF59E0B);
const _cRed = Color(0xFFEF4444);

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final duties = context.watch<DutyProvider>();
    final location = context.watch<LocationProvider>();

    final tabApplications = _filterApplicationsByTab(duties.applications, _selectedTab);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'My Applications',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: tx,
          ),
        ),
      ),
      body: Column(
        children: [
          _tabBar(card, border, tx, sub, duties),
          Expanded(
            child: tabApplications.isEmpty
                ? _emptyState(tx, sub, _selectedTab)
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tabApplications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final app = tabApplications[index];
                      final duty = duties.findDutyById(app.dutyId);
                      return _applicationCard(
                        app,
                        duty,
                        location,
                        card,
                        border,
                        tx,
                        sub,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  List<ApplicationModel> _filterApplicationsByTab(
    List<ApplicationModel> applications,
    int tab,
  ) {
    switch (tab) {
      case 0:
        return applications
            .where((a) => a.status == ApplicationStatus.pending)
            .toList();
      case 1:
        return applications
            .where((a) => a.status == ApplicationStatus.accepted)
            .toList();
      case 2:
        return applications
            .where((a) => a.status == ApplicationStatus.shortlisted)
            .toList();
      case 3:
        return applications
            .where((a) => a.status == ApplicationStatus.rejected)
            .toList();
      case 4:
        return applications
            .where((a) => a.status == ApplicationStatus.withdrawn)
            .toList();
      case 5:
        return applications
            .where((a) => a.status == ApplicationStatus.completed)
            .toList();
      default:
        return applications;
    }
  }

  Widget _tabBar(Color card, Color border, Color tx, Color sub, DutyProvider duties) {
    final tabs = [
      ('Pending', duties.pendingApplicationsCount, _cAmber),
      ('Accepted', duties.acceptedApplicationsCount, _cGreen),
      ('Shortlisted', duties.shortlistedApplicationsCount, _cBlue),
      ('Rejected', duties.rejectedApplicationsCount, _cRed),
      ('Withdrawn', duties.withdrawnApplicationsCount, sub),
      ('Completed', duties.completedApplicationsCount, _cTeal),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = _selectedTab == index;
            final tab = tabs[index];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => setState(() => _selectedTab = index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? tab.$3 : card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? tab.$3 : border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        tab.$1,
                        style: TextStyle(
                          color: selected ? Colors.white : sub,
                          fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      if (tab.$2 > 0) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: selected
                                ? Colors.white.withValues(alpha: 0.2)
                                : tab.$3.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${tab.$2}',
                            style: TextStyle(
                              color: selected ? Colors.white : tab.$3,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _applicationCard(
    ApplicationModel app,
    DutyModel? duty,
    LocationProvider location,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    final statusColor = _getStatusColor(app.status);
    final statusLabel = _getStatusLabel(app.status);
    
    double? distKm;
    if (duty != null && duty.hasCoordinates && location.searchLocation != null) {
      distKm = distanceKm(
        location.searchLocation!.latitude,
        location.searchLocation!.longitude,
        duty.latitude!,
        duty.longitude!,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: InkWell(
        onTap: duty != null
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DutyDetailsScreen(
                      hospital: duty.hospitalName,
                      role: duty.role,
                      salary: '₹${duty.salary.toStringAsFixed(0)}',
                      location: duty.location,
                      date: duty.dutyDate.toString().split(' ').first,
                      shift: duty.displayShift,
                      time:
                          '${duty.startTime.hour}:${duty.startTime.minute.toString().padLeft(2, '0')} – ${duty.endTime.hour}:${duty.endTime.minute.toString().padLeft(2, '0')}',
                      spec: duty.displaySpecialization,
                      dutyId: duty.id,
                      distanceKm: distKm,
                      dutyLatitude: duty.latitude,
                      dutyLongitude: duty.longitude,
                    ),
                  ),
                );
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (app.status == ApplicationStatus.pending)
                    TextButton(
                      onPressed: () => _withdrawApplication(app.id),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Withdraw',
                        style: TextStyle(
                          color: _cRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                app.role,
                style: TextStyle(
                  color: tx,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                app.hospitalName,
                style: TextStyle(
                  color: sub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 14, color: _cTeal),
                  const SizedBox(width: 4),
                  Text(
                    '${app.dutyDate.day}/${app.dutyDate.month}/${app.dutyDate.year}',
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.location_on_rounded, size: 14, color: _cTeal),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      app.location,
                      style: TextStyle(color: sub, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (distKm != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _cTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        formatDistanceKm(distKm),
                        style: const TextStyle(
                          color: _cTeal,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (app.salary != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.currency_rupee, size: 14, color: _cGreen),
                    const SizedBox(width: 4),
                    Text(
                      '₹${app.salary!.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: _cGreen,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              Text(
                'Applied on ${app.appliedAt.day}/${app.appliedAt.month}/${app.appliedAt.year}',
                style: TextStyle(
                  color: sub.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return _cAmber;
      case ApplicationStatus.accepted:
        return _cGreen;
      case ApplicationStatus.shortlisted:
        return _cBlue;
      case ApplicationStatus.rejected:
        return _cRed;
      case ApplicationStatus.withdrawn:
        return const Color(0xFF94A3B8);
      case ApplicationStatus.completed:
        return _cTeal;
    }
  }

  String _getStatusLabel(ApplicationStatus status) {
    switch (status) {
      case ApplicationStatus.pending:
        return 'Pending';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.withdrawn:
        return 'Withdrawn';
      case ApplicationStatus.completed:
        return 'Completed';
    }
  }

  Widget _emptyState(Color tx, Color sub, int tab) {
    final messages = [
      ('No pending applications', 'Your pending applications will appear here.'),
      ('No accepted applications', 'Accepted duties will appear here.'),
      ('No shortlisted applications', 'Shortlisted applications will appear here.'),
      ('No rejected applications', 'Rejected applications will appear here.'),
      ('No withdrawn applications', 'Withdrawn applications will appear here.'),
      ('No completed applications', 'Completed duties will appear here.'),
    ];
    final m = messages[tab.clamp(0, messages.length - 1)];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_rounded, size: 48, color: sub),
            const SizedBox(height: 12),
            Text(
              m.$1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tx,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              m.$2,
              textAlign: TextAlign.center,
              style: TextStyle(color: sub),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _withdrawApplication(String applicationId) async {
    final duties = context.read<DutyProvider>();
    await duties.withdrawApplication(applicationId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application withdrawn successfully'),
          backgroundColor: _cTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
