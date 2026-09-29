import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/geo_utils.dart';
import '../../providers/duty_provider.dart';
import '../../providers/location_provider.dart';
import '../../core/services/med_duty_share_service.dart';
import '../../models/share_payload.dart';
import '../profile/public_hospital_profile_screen.dart';
import 'discovery_helpers.dart';
import '../../shared/widgets/report_bottom_sheet.dart';

class DutyDetailsScreen extends StatefulWidget {
  final String hospital;
  final String role;
  final String salary;
  final String? location;
  final String? date;
  final String? shift;
  final String? time;
  final String? spec;
  final String? dutyId;
  final double? distanceKm;
  final double? dutyLatitude;
  final double? dutyLongitude;
  final bool isEmergency;
  final String? emergencyReason;
  final String? description;

  const DutyDetailsScreen({
    super.key,
    required this.hospital,
    required this.role,
    required this.salary,
    this.location,
    this.date,
    this.shift,
    this.time,
    this.spec,
    this.dutyId,
    this.distanceKm,
    this.dutyLatitude,
    this.dutyLongitude,
    this.isEmergency = false,
    this.emergencyReason,
    this.description,
  });

  @override
  State<DutyDetailsScreen> createState() => _DutyDetailsScreenState();
}

class _DutyDetailsScreenState extends State<DutyDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  bool get _isApplied {
    if (widget.dutyId == null) return false;
    return context.read<DutyProvider>().isDutyApplied(widget.dutyId!);
  }

  bool get _isSaved {
    if (widget.dutyId == null) return false;
    return context.read<DutyProvider>().isDutySaved(widget.dutyId!);
  }

  bool get _isEmergencyFilled {
    if (!widget.isEmergency || widget.dutyId == null) return false;
    final duties = context.read<DutyProvider>();
    if (duties.discoveryLoading || duties.openDuties.isEmpty) return false;
    return duties.findDutyById(widget.dutyId!) == null;
  }

  Future<void> _applyForDuty() async {
    if (_isEmergencyFilled) return;
    const cTeal = Color(0xFF0F766E);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    if (widget.isEmergency) {
      final loc = context.read<LocationProvider>();
      final duties = context.read<DutyProvider>();
      final item = widget.dutyId != null
          ? duties.dutyWithDistanceForId(widget.dutyId!, loc)
          : null;
      if (item != null) {
        await applyDiscoveryDuty(context, item, isEmergency: true);
        if (mounted) setState(() {});
      }
      return;
    }

    showModalBottomSheet(
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
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: sub.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Confirm Application', style: TextStyle(color: tx, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('You are about to apply for this duty. Please review the details below.', style: TextStyle(color: sub, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            _sheetDetailRow(Icons.medical_services_rounded, 'Duty', widget.role, tx, sub),
            _sheetDetailRow(Icons.local_hospital_outlined, 'Hospital', widget.hospital, tx, sub),
            if (widget.date != null) _sheetDetailRow(Icons.calendar_today_outlined, 'Date', widget.date!, tx, sub),
            if (widget.shift != null) _sheetDetailRow(Icons.wb_sunny_outlined, 'Shift', widget.shift!, tx, sub),
            if (widget.location != null) _sheetDetailRow(Icons.location_on_outlined, 'Location', widget.location!, tx, sub),
            _sheetDetailRow(Icons.currency_rupee, 'Payout', widget.salary, tx, sub),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: cTeal),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Cancel', style: TextStyle(color: cTeal, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final loc = context.read<LocationProvider>();
                  final duties = context.read<DutyProvider>();
                  final item = widget.dutyId != null
                      ? duties.dutyWithDistanceForId(widget.dutyId!, loc)
                      : null;
                  if (item != null) {
                    await applyDiscoveryDuty(context, item);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Application submitted successfully!'),
                        backgroundColor: cTeal,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                  if (mounted) setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: cTeal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Apply Now', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _sheetDetailRow(IconData icon, String label, String value, Color tx, Color sub) {
    const cTeal = Color(0xFF0F766E);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Icon(icon, color: cTeal, size: 16),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: sub, fontSize: 13)),
        Flexible(child: Text(value, style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final lat = widget.dutyLatitude;
    final lng = widget.dutyLongitude;
    Uri uri;
    if (lat != null && lng != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    } else if (widget.location != null && widget.location!.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(widget.location!)}',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not available for directions.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DutyProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg    = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card  = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border= isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx    = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub   = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow= isDark ? <BoxShadow>[] : [BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))];
    const cTeal  = Color(0xFF0F766E);
    const cGreen = Color(0xFF16A34A);
    const cBlue  = Color(0xFF2563EB);
    const cRed   = Color(0xFFEF4444);
    const cAmber = Color(0xFFF59E0B);

    final shiftColor = widget.shift == 'Night Shift' ? const Color(0xFF7C3AED) : widget.shift == 'Emergency' ? cRed : cBlue;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: tx, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.role, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: tx), overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: Icon(_isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: cTeal),
            onPressed: () async {
              final loc = context.read<LocationProvider>();
              final duties = context.read<DutyProvider>();
              final item = widget.dutyId != null
                  ? duties.dutyWithDistanceForId(widget.dutyId!, loc)
                  : null;
              if (item != null) {
                await toggleDiscoverySave(context, item);
              }
              if (mounted) setState(() {});
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            color: tx,
            onPressed: () => MedDutyShareService.show(
              context,
              SharePayload.duty(
                title: widget.role,
                hospital: widget.hospital,
                location: widget.location ?? 'Location not specified',
                dutyId: widget.dutyId,
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert_rounded, color: tx),
            onSelected: (val) {
              if (val == 'report') {
                showContentReportSheet(
                  context,
                  subjectLabel: 'Duty (${widget.role} at ${widget.hospital})',
                  targetId: widget.dutyId,
                  targetName: '${widget.role} - ${widget.hospital}',
                  reportType: 'duty',
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.flag_outlined, size: 18),
                    SizedBox(width: 8),
                    Text('Report Duty'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: card,
          border: Border(top: BorderSide(color: border)),
          boxShadow: shadow,
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Payout', style: TextStyle(color: sub, fontSize: 12)),
                Text(widget.salary, style: const TextStyle(color: cGreen, fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: (_isApplied || _isEmergencyFilled) ? null : _applyForDuty,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isApplied
                      ? cGreen.withValues(alpha: 0.1)
                      : (_isEmergencyFilled ? Colors.grey : cTeal),
                  foregroundColor: _isApplied ? cGreen : Colors.white,
                  disabledBackgroundColor: cGreen.withValues(alpha: 0.1),
                  disabledForegroundColor: cGreen,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  minimumSize: const Size(double.infinity, 48),
                  elevation: 0,
                ),
                child: _isEmergencyFilled
                  ? const Text('No Longer Available', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                  : _isApplied
                  ? const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.check_circle_rounded, size: 18, color: cGreen),
                      SizedBox(width: 6),
                      Text('Applied ✓', style: TextStyle(fontWeight: FontWeight.bold, color: cGreen, fontSize: 16)),
                    ])
                  : const Text('Apply Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isEmergency) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isEmergencyFilled
                      ? Colors.grey.withValues(alpha: 0.15)
                      : cRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: cRed.withValues(alpha: 0.35)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text('🚨', style: TextStyle(fontSize: 18)),
                        SizedBox(width: 8),
                        Text(
                          'EMERGENCY DUTY',
                          style: TextStyle(
                            color: cRed,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    if (_isEmergencyFilled) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Emergency Duty Filled',
                        style: TextStyle(color: tx, fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This duty is no longer accepting applications.',
                        style: TextStyle(color: sub, fontSize: 13),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      Text(widget.role, style: TextStyle(color: tx, fontSize: 18, fontWeight: FontWeight.w800)),
                      if (widget.spec != null) ...[
                        const SizedBox(height: 6),
                        Text('Specialist Required: ${widget.spec}', style: TextStyle(color: sub, fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                      if (widget.distanceKm != null) ...[
                        const SizedBox(height: 6),
                        Text('Distance: ${formatDistanceKm(widget.distanceKm)}', style: const TextStyle(color: cRed, fontWeight: FontWeight.w700, fontSize: 13)),
                      ],
                      if (widget.emergencyReason != null) ...[
                        const SizedBox(height: 10),
                        Text('Reason for Emergency:', style: TextStyle(color: sub, fontSize: 12, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(widget.emergencyReason!, style: TextStyle(color: tx, fontSize: 13, height: 1.4)),
                      ],
                    ],
                  ],
                ),
              ),
            ],
            // ── Hospital Header Card ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(
                      color: cTeal.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Center(child: Icon(Icons.local_hospital_rounded, color: cTeal, size: 38)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PublicHospitalProfileScreen(
                                    hospitalName: widget.hospital,
                                    hospitalType: 'Multi-Speciality Hospital',
                                    location: widget.location ?? 'India',
                                  ),
                                ),
                              ),
                              child: Text(widget.hospital, style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified_rounded, color: cBlue, size: 16),
                        ]),
                        const SizedBox(height: 4),
                        if (widget.location != null)
                          Row(children: [
                            Icon(Icons.location_on_rounded, color: sub, size: 13),
                            const SizedBox(width: 4),
                            Flexible(child: Text(widget.location!, style: TextStyle(color: sub, fontSize: 12), overflow: TextOverflow.ellipsis)),
                            if (widget.distanceKm != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cTeal.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${widget.distanceKm!.toStringAsFixed(1)} km away',
                                  style: const TextStyle(color: cTeal, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ]),
                        const SizedBox(height: 8),
                        Row(children: [
                          ...List.generate(5, (i) => Icon(i < 4 ? Icons.star_rounded : Icons.star_half_rounded, color: cAmber, size: 14)),
                          const SizedBox(width: 4),
                          Text('4.5 (128 reviews)', style: TextStyle(color: sub, fontSize: 11)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Duty Info Grid ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Duty Details', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.0,
                    children: [
                      _infoCell(Icons.calendar_today_rounded, 'Date', widget.date ?? 'TBD', cBlue, card, tx, sub, border),
                      _infoCell(Icons.access_time_rounded, 'Time', widget.time ?? 'TBD', cTeal, card, tx, sub, border),
                      _infoCell(Icons.wb_sunny_rounded, 'Shift', widget.shift ?? 'TBD', shiftColor, card, tx, sub, border),
                      _infoCell(Icons.currency_rupee, 'Salary', widget.salary, cGreen, card, tx, sub, border),
                      _infoCell(Icons.timer_outlined, 'Duration', '12 Hours', cAmber, card, tx, sub, border),
                      _infoCell(Icons.medical_services_rounded, 'Spec', widget.spec ?? 'General', cRed, card, tx, sub, border),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Description Card ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About this Duty', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    'This position requires a qualified medical professional to provide exceptional patient care in a fast-paced hospital environment. The role offers flexible timing and competitive compensation.',
                    style: TextStyle(color: sub, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Text('Responsibilities', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...[
                    'Attend to patients and provide emergency care',
                    'Collaborate with the nursing and support staff',
                    'Maintain accurate patient records and documentation',
                    'Follow hospital protocols and safety standards',
                  ].map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: cTeal, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Flexible(child: Text(r, style: TextStyle(color: sub, fontSize: 13, height: 1.4))),
                    ]),
                  )),
                  const SizedBox(height: 16),
                  Text('Requirements', style: TextStyle(color: tx, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...[
                    'MBBS or equivalent medical degree',
                    'Valid medical registration certificate',
                    'Minimum 1 year of clinical experience',
                    'Ability to work under pressure',
                  ].map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(margin: const EdgeInsets.only(top: 6), width: 6, height: 6, decoration: const BoxDecoration(color: cBlue, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Flexible(child: Text(r, style: TextStyle(color: sub, fontSize: 13, height: 1.4))),
                    ]),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Benefits ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Benefits Included', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ('🍽️', 'Meals'),
                      ('🏨', 'Accommodation'),
                      ('🅿️', 'Parking'),
                      ('📜', 'Certificate'),
                    ].map((b) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: cTeal.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cTeal.withValues(alpha: 0.2)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(b.$1, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(b.$2, style: const TextStyle(color: cTeal, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                    )).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Hospital Info Card ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('About the Hospital', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Contacting hospital...'),
                          backgroundColor: cTeal,
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        )),
                        icon: const Icon(Icons.phone_rounded, size: 15, color: cTeal),
                        label: const Text('Contact', style: TextStyle(color: cTeal, fontSize: 13, fontWeight: FontWeight.w600)),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          backgroundColor: cTeal.withValues(alpha: 0.08),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.hospital} is a leading multi-speciality hospital known for providing world-class medical care with state-of-the-art facilities and experienced medical professionals.',
                    style: TextStyle(color: sub, fontSize: 13, height: 1.5),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    _statChip('500+ Beds', Icons.bed_rounded, cTeal),
                    const SizedBox(width: 10),
                    _statChip('NABH Accredited', Icons.verified_outlined, cBlue),
                    const SizedBox(width: 10),
                    _statChip('24/7 Emergency', Icons.local_hospital_rounded, cRed),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Location Card ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Location', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 160,
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.map_rounded, size: 56, color: cTeal.withValues(alpha: 0.4)),
                                const SizedBox(height: 8),
                                Text('Map Preview', style: TextStyle(color: sub, fontSize: 12)),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 12, right: 12,
                            child: GestureDetector(
                              onTap: () => _openDirections(context),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: cTeal,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                                  Icon(Icons.open_in_new_rounded, color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('Open in Maps', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    const Icon(Icons.location_on_rounded, color: cRed, size: 16),
                    const SizedBox(width: 6),
                    Flexible(child: Text('📍 ${widget.location ?? 'Location not specified'}', style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                    if (widget.distanceKm != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${widget.distanceKm!.toStringAsFixed(1)} km',
                        style: const TextStyle(color: cTeal, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // ── Reviews Section ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: border),
                boxShadow: shadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Doctor Reviews', style: TextStyle(color: tx, fontSize: 15, fontWeight: FontWeight.bold)),
                      GestureDetector(
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Loading all reviews...'),
                          backgroundColor: cTeal,
                          behavior: SnackBarBehavior.floating,
                        )),
                        child: const Text('See All', style: TextStyle(color: cTeal, fontSize: 13, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _reviewCard('Dr. Priya Sharma', 'Great hospital, supportive staff and clean facilities.', 5, sub, tx, cAmber, card, border),
                  const SizedBox(height: 10),
                  _reviewCard('Dr. Rohit Kapoor', 'Smooth duty experience. Payment was on time.', 4, sub, tx, cAmber, card, border),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCell(IconData icon, String label, String value, Color iconColor, Color card, Color tx, Color sub, Color border) {
    return Container(
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withValues(alpha: 0.15)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(color: sub, fontSize: 10, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(color: tx, fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _statChip(String label, IconData icon, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Flexible(child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
        ]),
      ),
    );
  }

  Widget _reviewCard(String name, String review, int stars, Color sub, Color tx, Color starColor, Color card, Color border) {
    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF0F766E).withValues(alpha: 0.15),
                child: Text(name[3].toUpperCase(), style: const TextStyle(color: Color(0xFF0F766E), fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.bold)),
                    Row(children: List.generate(5, (i) => Icon(i < stars ? Icons.star_rounded : Icons.star_border_rounded, color: starColor, size: 12))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(review, style: TextStyle(color: sub, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
