import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import 'package:provider/provider.dart';



import '../../core/utils/emergency_duty_utils.dart';
import '../../core/utils/geo_utils.dart';
import '../../models/duty_with_distance.dart';

import '../../providers/duty_provider.dart';

import '../../providers/location_provider.dart';

import 'duty_details_screen.dart';



const discoveryTeal = Color(0xFF0F766E);



void openDiscoveryDutyDetails(BuildContext context, DutyWithDistance item) {

  final d = item.duty;

  final dateFmt = DateFormat('d MMM yyyy');

  final timeFmt = DateFormat('h:mm a');

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => DutyDetailsScreen(

        hospital: d.hospitalName,

        role: d.role,

        salary: '₹${d.salary.toStringAsFixed(0)}',

        location: d.location,

        date: dateFmt.format(d.dutyDate),

        shift: d.displayShift,

        time: '${timeFmt.format(d.startTime)} – ${timeFmt.format(d.endTime)}',

        spec: d.displaySpecialization,

        dutyId: d.id,

        distanceKm: item.distanceKm,

        dutyLatitude: d.latitude,

        dutyLongitude: d.longitude,

        isEmergency: EmergencyDutyUtils.isActiveEmergency(d),

        emergencyReason: d.emergencyReason,

        description: d.description,

      ),

    ),

  );

}



void openDutyDetailsById(BuildContext context, String dutyId) {

  final loc = context.read<LocationProvider>();

  final duties = context.read<DutyProvider>();

  final item = duties.dutyWithDistanceForId(dutyId, loc);

  if (item != null) {

    openDiscoveryDutyDetails(context, item);

    return;

  }

  final duty = duties.findDutyById(dutyId);

  if (duty == null) return;

  final dateFmt = DateFormat('d MMM yyyy');

  final timeFmt = DateFormat('h:mm a');

  double? dist;

  final center = loc.searchLocation;

  if (center != null && duty.hasCoordinates) {

    dist = distanceKm(

      center.latitude,

      center.longitude,

      duty.latitude!,

      duty.longitude!,

    );

  }

  Navigator.push(

    context,

    MaterialPageRoute(

      builder: (_) => DutyDetailsScreen(

        hospital: duty.hospitalName,

        role: duty.role,

        salary: '₹${duty.salary.toStringAsFixed(0)}',

        location: duty.location,

        date: dateFmt.format(duty.dutyDate),

        shift: duty.displayShift,

        time: '${timeFmt.format(duty.startTime)} – ${timeFmt.format(duty.endTime)}',

        spec: duty.displaySpecialization,

        dutyId: duty.id,

        distanceKm: dist,

        dutyLatitude: duty.latitude,

        dutyLongitude: duty.longitude,

        isEmergency: EmergencyDutyUtils.isActiveEmergency(duty),

        emergencyReason: duty.emergencyReason,

        description: duty.description,

      ),

    ),

  );

}



Future<void> applyDiscoveryDuty(

  BuildContext context,

  DutyWithDistance item, {

  bool isEmergency = false,

}) async {

  final duties = context.read<DutyProvider>();

  if (duties.isDutyApplied(item.duty.id)) {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Application already submitted.'),

        behavior: SnackBarBehavior.floating,

      ),

    );

    return;

  }



  if (isEmergency || EmergencyDutyUtils.isActiveEmergency(item.duty)) {

    final confirmed = await _showEmergencyApplySheet(context, item);

    if (confirmed != true || !context.mounted) return;

  }



  final ok = await duties.applyForDuty(item);

  if (!context.mounted) return;



  if (ok) {

    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(

          EmergencyDutyUtils.isActiveEmergency(item.duty)

              ? 'Your application for this emergency duty has been submitted.'

              : 'Duty application submitted successfully.',

        ),

        backgroundColor: discoveryTeal,

        behavior: SnackBarBehavior.floating,

        duration: const Duration(seconds: 3),

      ),

    );

  } else {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(

        content: Text('Unable to submit application. Please try again.'),

        behavior: SnackBarBehavior.floating,

      ),

    );

  }

}



Future<bool?> _showEmergencyApplySheet(

  BuildContext context,

  DutyWithDistance item,

) {

  final isDark = Theme.of(context).brightness == Brightness.dark;

  final card = isDark ? const Color(0xFF1E293B) : Colors.white;

  final tx = isDark ? Colors.white : const Color(0xFF0F172A);

  final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  final d = item.duty;



  return showModalBottomSheet<bool>(

    context: context,

    backgroundColor: Colors.transparent,

    isScrollControlled: true,

    builder: (_) => Container(

      decoration: BoxDecoration(

        color: card,

        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),

      ),

      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),

      child: Column(

        mainAxisSize: MainAxisSize.min,

        children: [

          Center(

            child: Container(

              width: 40,

              height: 4,

              decoration: BoxDecoration(

                color: sub.withValues(alpha: 0.4),

                borderRadius: BorderRadius.circular(2),

              ),

            ),

          ),

          const SizedBox(height: 16),

          const Text('🚨', style: TextStyle(fontSize: 28)),

          const SizedBox(height: 8),

          Text(

            'Emergency Duty Application',

            style: TextStyle(color: tx, fontSize: 18, fontWeight: FontWeight.bold),

          ),

          const SizedBox(height: 8),

          Text(

            'You are applying for an emergency duty at ${d.hospitalName}.',

            style: TextStyle(color: sub, fontSize: 13),

            textAlign: TextAlign.center,

          ),

          const SizedBox(height: 20),

          _sheetRow(Icons.local_hospital_outlined, 'Hospital', d.hospitalName, tx, sub),

          _sheetRow(Icons.medical_services_rounded, 'Duty', d.role, tx, sub),

          _sheetRow(Icons.schedule_rounded, 'Time', '${DateFormat('d MMM').format(d.dutyDate)} • ${DateFormat('h:mm a').format(d.startTime)}', tx, sub),

          _sheetRow(Icons.location_on_outlined, 'Location', d.location, tx, sub),

          _sheetRow(Icons.currency_rupee, 'Payout', '₹${d.salary.toStringAsFixed(0)}', tx, sub),

          const SizedBox(height: 24),

          Row(

            children: [

              Expanded(

                child: OutlinedButton(

                  onPressed: () => Navigator.pop(context, false),

                  style: OutlinedButton.styleFrom(

                    side: const BorderSide(color: discoveryTeal),

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                    padding: const EdgeInsets.symmetric(vertical: 14),

                  ),

                  child: const Text('Cancel', style: TextStyle(color: discoveryTeal, fontWeight: FontWeight.bold)),

                ),

              ),

              const SizedBox(width: 12),

              Expanded(

                flex: 2,

                child: ElevatedButton(

                  onPressed: () => Navigator.pop(context, true),

                  style: ElevatedButton.styleFrom(

                    backgroundColor: discoveryTeal,

                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),

                    padding: const EdgeInsets.symmetric(vertical: 14),

                  ),

                  child: const Text('Confirm Application', style: TextStyle(fontWeight: FontWeight.bold)),

                ),

              ),

            ],

          ),

        ],

      ),

    ),

  );

}



Widget _sheetRow(IconData icon, String label, String value, Color tx, Color sub) {

  return Padding(

    padding: const EdgeInsets.only(bottom: 10),

    child: Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Icon(icon, color: discoveryTeal, size: 18),

        const SizedBox(width: 10),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(label, style: TextStyle(color: sub, fontSize: 11)),

              Text(value, style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.w600)),

            ],

          ),

        ),

      ],

    ),

  );

}



Future<void> toggleDiscoverySave(

  BuildContext context,

  DutyWithDistance item,

) async {

  final duties = context.read<DutyProvider>();

  final wasSaved = duties.isDutySaved(item.duty.id);

  await duties.toggleSaveDuty(

    item.duty.id,

    item.duty.role,

    item.duty.location,

    item.duty.salary,

  );

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(

      content: Text(

        wasSaved ? 'Removed from saved duties' : 'Duty saved',

      ),

      backgroundColor: discoveryTeal,

      behavior: SnackBarBehavior.floating,

      duration: const Duration(seconds: 2),

    ),

  );

}



List<DutyWithDistance> filterDiscoveryList(

  List<DutyWithDistance> list,

  String query,

) {

  final q = query.trim().toLowerCase();

  if (q.isEmpty) return list;

  return list.where((item) {

    final d = item.duty;

    final haystack =

        '${d.role} ${d.hospitalName} ${d.location} ${d.specialization ?? ''}'

            .toLowerCase();

    return haystack.contains(q);

  }).toList();

}



List<DutyWithDistance> withDistancesFromLocation(

  List<DutyWithDistance> items,

  LocationProvider location,

) {

  final center = location.searchLocation;

  if (center == null) return items;

  return items.map((item) {

    if (!item.hasLocation) return item;

    final dist = distanceKm(

      center.latitude,

      center.longitude,

      item.duty.latitude!,

      item.duty.longitude!,

    );

    return item.copyWith(distanceKm: dist);

  }).toList();

}


