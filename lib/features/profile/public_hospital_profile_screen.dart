import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../duties/duty_details_screen.dart';
import 'public_doctor_profile_screen.dart';
import 'profile_share_helper.dart';
import 'widgets/contact_options_sheet.dart';
import '../../core/services/profile_share_service.dart';
import '../../models/profile_share_data.dart';
import '../../shared/widgets/report_bottom_sheet.dart';
import '../../shared/widgets/healthcare_verification_badge.dart';
import '../../providers/settings_preferences_provider.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cPurple = Color(0xFF7C3AED);
const _cAmber  = Color(0xFFF59E0B);
const _cRed    = Color(0xFFEF4444);

class PublicHospitalProfileScreen extends StatefulWidget {
  final String? hospitalId;
  final String hospitalName;
  final String hospitalType;
  final String location;
  final String? speciality;

  const PublicHospitalProfileScreen({
    super.key,
    this.hospitalId,
    required this.hospitalName,
    required this.hospitalType,
    required this.location,
    this.speciality,
  });

  @override
  State<PublicHospitalProfileScreen> createState() =>
      _PublicHospitalProfileScreenState();
}

class _PublicHospitalProfileScreenState
    extends State<PublicHospitalProfileScreen> {
  bool _isFollowing = false;
  int _tabIndex = 0;

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }

  ProfileShareData get _shareData => ProfileShareHelper.hospital(
        hospitalId: widget.hospitalId,
        hospitalName: widget.hospitalName,
        hospitalType: widget.hospitalType,
        location: widget.location,
        speciality: widget.speciality,
      );

  Future<void> _copyProfileLink() async {
    try {
      await ProfileShareService.copyProfileLink(_shareData);
      if (!mounted) return;
      _showSnackBar('Profile link copied');
    } catch (_) {
      if (mounted) _showSnackBar('Unable to copy link. Please try again.');
    }
  }

  void _openReport() {
    showContentReportSheet(
      context,
      subjectLabel: 'Hospital (${widget.hospitalName})',
      targetId: widget.hospitalId ?? widget.hospitalName,
      targetName: widget.hospitalName,
      reportType: 'profile',
    );
  }

  Future<void> _handleMenuAction(String action) async {
    final settings = context.read<SettingsPreferencesProvider>();
    final hospitalBlockId = widget.hospitalId ?? widget.hospitalName;
    final isBlocked = settings.isUserBlocked(hospitalBlockId);

    switch (action) {
      case 'report':
        _openReport();
        break;
      case 'block':
        if (isBlocked) {
          await settings.unblockUser(hospitalBlockId);
          if (mounted) _showSnackBar('${widget.hospitalName} unblocked');
        } else {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text('Block ${widget.hospitalName}?'),
              content: const Text(
                'You will no longer receive duty offers or messages from this hospital/clinic.',
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Block'),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await settings.blockUser(
              id: hospitalBlockId,
              name: widget.hospitalName,
              role: widget.hospitalType,
            );
            if (mounted) _showSnackBar('${widget.hospitalName} blocked');
          }
        }
        break;
      case 'copy_link':
        _copyProfileLink();
        break;
    }
  }

  void _openContact() {
    if (widget.hospitalId != null) {
      ContactOptionsSheet.showForHospital(
        context,
        hospitalId: widget.hospitalId!,
        hospitalName: widget.hospitalName,
        role: widget.hospitalType,
      );
    } else {
      ContactOptionsSheet.show(
        context,
        displayName: widget.hospitalName,
        role: widget.hospitalType,
      );
    }
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  Widget _vertDivider(Color borderColor) =>
      Container(width: 1, height: 32, color: borderColor);

  Widget _sectionLabel(String label) => Text(
        label,
        style: const TextStyle(
          color: _cTeal,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      );

  Widget _infoChip(String label, Color tx, Color borderColor) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: _cTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _cTeal.withValues(alpha: 0.2)),
        ),
        child: Text(label,
            style: TextStyle(
                color: tx, fontSize: 12, fontWeight: FontWeight.w500)),
      );

  // ── build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg     = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card   = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx     = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub    = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final shadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.07),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ];

    return Scaffold(
      backgroundColor: bg,
      appBar: _buildAppBar(bg, tx),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHospitalHeader(card, border, shadow, tx, sub),
            _buildActionButtons(card, border),
            _buildAboutCard(card, border, shadow, tx, sub),
            _buildStatsRow(card, border, shadow, tx, sub),
            _buildTabBar(card, border, shadow, sub),
            _buildTabContent(card, border, shadow, tx, sub, bg),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  AppBar _buildAppBar(Color bg, Color tx) {
    return AppBar(
      backgroundColor: bg,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: tx),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.hospitalName,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: tx, fontSize: 17, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: tx),
          onPressed: () {
            ProfileShareHelper.showShareSheet(
              context,
              ProfileShareHelper.hospital(
                hospitalId: widget.hospitalId,
                hospitalName: widget.hospitalName,
                hospitalType: widget.hospitalType,
                location: widget.location,
                speciality: widget.speciality,
              ),
            );
          },
        ),
        Consumer<SettingsPreferencesProvider>(
          builder: (context, settings, child) {
            final isBlocked = settings.isUserBlocked(widget.hospitalId ?? widget.hospitalName);
            return PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded, color: tx),
              onSelected: _handleMenuAction,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'report', child: Text('Report')),
                PopupMenuItem(
                  value: 'block',
                  child: Text(isBlocked ? 'Unblock Hospital' : 'Block Hospital', style: TextStyle(color: isBlocked ? Colors.green : Colors.red)),
                ),
                const PopupMenuItem(value: 'copy_link', child: Text('Copy Link')),
              ],
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ── Hospital Header Card ───────────────────────────────────────────────────

  Widget _buildHospitalHeader(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: _cTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.local_hospital_rounded,
                color: _cTeal, size: 48),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.hospitalName,
                  style: TextStyle(
                      color: tx, fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const HealthcareVerificationBadge(
                isVerified: true,
                type: HealthcareVerificationType.hospital,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(widget.hospitalType,
              style: TextStyle(color: sub, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined, color: sub, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(widget.location,
                    style: TextStyle(color: sub, fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(
                  5,
                  (_) => const Icon(Icons.star_rounded,
                      color: _cAmber, size: 14)),
              const SizedBox(width: 4),
              const Text('4.7',
                  style: TextStyle(
                      color: _cAmber,
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              Text(' (328 reviews)',
                  style: TextStyle(color: sub, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _cTeal.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '12.4K Followers',
              style: TextStyle(
                  color: _cTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons(Color card, Color border) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFollowing ? card : _cTeal,
                  foregroundColor: _isFollowing ? _cTeal : Colors.white,
                  side: _isFollowing ? const BorderSide(color: _cTeal) : null,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  setState(() => _isFollowing = !_isFollowing);
                  _showSnackBar(_isFollowing
                      ? 'You\'re now following ${widget.hospitalName}'
                      : 'Unfollowed ${widget.hospitalName}');
                },
                child: Text(
                  _isFollowing ? 'Following ✓' : 'Follow',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _cTeal,
                  side: const BorderSide(color: _cTeal),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _openContact,
                child: const Text('Contact',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _cTeal,
                  side: const BorderSide(color: _cTeal),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => setState(() => _tabIndex = 1),
                child: const Text('Duties',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── About Card ─────────────────────────────────────────────────────────────

  Widget _buildAboutCard(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    Widget chips(List<String> labels) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: labels.map((l) => _infoChip(l, tx, border)).toList(),
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('ABOUT'),
          const SizedBox(height: 8),
          Text(
            '${widget.hospitalName} is a multi-speciality healthcare institution providing comprehensive clinical services. '
            'With state-of-the-art infrastructure and a team of leading specialists, it is committed to delivering exceptional patient care across a wide range of medical disciplines.',
            style: TextStyle(color: sub, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          _sectionLabel('SPECIALITIES'),
          const SizedBox(height: 6),
          chips([
            'Cardiology',
            'Neurology',
            'Pediatrics',
            'Emergency',
            'ICU',
            'Surgery',
            'Orthopedics'
          ]),
          const SizedBox(height: 16),
          _sectionLabel('FACILITIES'),
          const SizedBox(height: 6),
          chips([
            '500+ Beds',
            'ICU',
            'NICU',
            'Emergency 24/7',
            'OT',
            'Lab',
            'Radiology',
            'Pharmacy'
          ]),
          const SizedBox(height: 16),
          _sectionLabel('ESTABLISHED'),
          const SizedBox(height: 4),
          Text('1983',
              style: TextStyle(
                  color: tx, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ── Stats Row ──────────────────────────────────────────────────────────────

  Widget _buildStatsRow(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    Widget stat(String value, String label) => Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(value,
                  style: TextStyle(
                      color: tx,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(color: sub, fontSize: 11)),
            ],
          ),
        );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: Row(
        children: [
          stat('12.4K', 'Followers'),
          _vertDivider(border),
          stat('50+', 'Doctors'),
          _vertDivider(border),
          stat('4.7', 'Rating'),
          _vertDivider(border),
          stat('328', 'Reviews'),
        ],
      ),
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────────────

  Widget _buildTabBar(Color card, Color border, List<BoxShadow> shadow, Color sub) {
    final tabs = ['Overview', 'Duties', 'Doctors', 'Reviews'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final selected = _tabIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tabIndex = i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? _cTeal.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tabs[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selected ? _cTeal : sub,
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab Content ────────────────────────────────────────────────────────────

  Widget _buildTabContent(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub, Color bg) {
    switch (_tabIndex) {
      case 0:
        return _buildOverviewTab(card, border, shadow, tx, sub);
      case 1:
        return _buildDutiesTab(card, border, shadow, tx, sub, bg);
      case 2:
        return _buildDoctorsTab(card, border, shadow, tx, sub);
      case 3:
        return _buildReviewsTab(card, border, shadow, tx, sub);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Overview Tab ───────────────────────────────────────────────────────────

  Widget _buildOverviewTab(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    final departments = [
      {'name': 'Cardiology', 'icon': Icons.favorite_rounded, 'color': _cRed},
      {'name': 'Neurology', 'icon': Icons.psychology_rounded, 'color': _cPurple},
      {'name': 'Pediatrics', 'icon': Icons.child_care_rounded, 'color': _cGreen},
      {'name': 'Emergency', 'icon': Icons.emergency_rounded, 'color': _cRed},
      {'name': 'ICU', 'icon': Icons.monitor_heart_rounded, 'color': _cBlue},
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('DEPARTMENTS'),
          const SizedBox(height: 10),
          ...departments.map((d) {
            final color = d['color'] as Color;
            final icon = d['icon'] as IconData;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 10),
                  Text(d['name'] as String,
                      style: TextStyle(
                          color: tx,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          _sectionLabel('LOCATION'),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () =>
                _showSnackBar('Opening hospital location in maps...'),
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: border.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.map_rounded, color: _cTeal, size: 40),
                    const SizedBox(height: 6),
                    const Text('Open in Maps',
                        style: TextStyle(
                            color: _cTeal,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Duties Tab ─────────────────────────────────────────────────────────────

  Widget _dutyMiniCard({
    required String role,
    required String hosp,
    required String time,
    required String salary,
    required Color bg,
    required Color border,
    required Color tx,
    required Color sub,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DutyDetailsScreen(
            hospital: hosp,
            role: role,
            salary: salary,
            time: time,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _cTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded,
                  color: _cTeal, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(role,
                      style: TextStyle(
                          color: tx,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(hosp,
                      style: TextStyle(color: sub, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                  Text(time, style: TextStyle(color: sub, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(salary,
                    style: const TextStyle(
                        color: _cGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                SizedBox(
                  height: 28,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _cTeal,
                      side: const BorderSide(color: _cTeal),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DutyDetailsScreen(
                            hospital: hosp, role: role, salary: salary),
                      ),
                    ),
                    child: const Text('Apply',
                        style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDutiesTab(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub, Color bg) {
    final duties = [
      {'role': 'General Physician', 'time': '9AM–5PM', 'salary': '₹2500'},
      {'role': 'ICU Duty', 'time': '7PM–7AM', 'salary': '₹3500'},
      {'role': 'Emergency Duty', 'time': '8AM–8PM', 'salary': '₹3000'},
    ];
    return Column(
      children: duties.map((d) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _dutyMiniCard(
            role: d['role']!,
            hosp: widget.location,
            time: d['time']!,
            salary: d['salary']!,
            bg: bg,
            border: border,
            tx: tx,
            sub: sub,
          ),
        );
      }).toList(),
    );
  }

  // ── Doctors Tab ────────────────────────────────────────────────────────────

  Widget _buildDoctorsTab(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    final doctors = [
      {
        'name': 'Dr. Arjun Sharma',
        'spec': 'Diabetologist',
        'initials': 'AS',
        'color': _cTeal,
        'qual': 'MBBS, MD',
        'hosp': widget.hospitalName,
        'loc': widget.location,
      },
      {
        'name': 'Dr. Priya Nair',
        'spec': 'Pediatrician',
        'initials': 'PN',
        'color': _cGreen,
        'qual': 'MBBS, MD',
        'hosp': widget.hospitalName,
        'loc': widget.location,
      },
      {
        'name': 'Dr. Rohan Mehta',
        'spec': 'Cardiologist',
        'initials': 'RM',
        'color': _cRed,
        'qual': 'MBBS, DM',
        'hosp': widget.hospitalName,
        'loc': widget.location,
      },
      {
        'name': 'Dr. Ayesha Khan',
        'spec': 'Anesthesiologist',
        'initials': 'AK',
        'color': _cPurple,
        'qual': 'MBBS, MD',
        'hosp': widget.hospitalName,
        'loc': widget.location,
      },
    ];

    return Column(
      children: doctors.map((d) {
        final color = d['color'] as Color;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: color,
                child: Text(
                  d['initials'] as String,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            d['name'] as String,
                            style: TextStyle(
                                color: tx,
                                fontSize: 13,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.verified_rounded,
                            color: _cBlue, size: 13),
                      ],
                    ),
                    Text(d['spec'] as String,
                        style: TextStyle(color: sub, fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cTeal,
                    side: const BorderSide(color: _cTeal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PublicDoctorProfileScreen(
                        doctorName: d['name'] as String,
                        qualification: d['qual'] as String,
                        specialization: d['spec'] as String,
                        hospital: d['hosp'] as String,
                        location: d['loc'] as String,
                        avatarInitials: d['initials'] as String,
                        avatarColor: color,
                      ),
                    ),
                  ),
                  child: const Text('View',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ── Reviews Tab ────────────────────────────────────────────────────────────

  Widget _buildReviewsTab(Color card, Color border, List<BoxShadow> shadow,
      Color tx, Color sub) {
    final reviews = [
      {
        'name': 'Dr. Rohan Mehta',
        'initials': 'RM',
        'date': '2 days ago',
        'review':
            'World-class facilities and a very professional medical team. The ICU setup is exceptional and the staff is incredibly supportive.',
      },
      {
        'name': 'Dr. Priya Nair',
        'initials': 'PN',
        'date': '5 days ago',
        'review':
            'Great working environment. The management is very approachable and duty schedules are well-organized. Highly recommended for medical professionals.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
            boxShadow: shadow,
          ),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, color: _cAmber, size: 28),
              const SizedBox(width: 8),
              Text('4.7',
                  style: TextStyle(
                      color: tx,
                      fontSize: 28,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('328 Reviews',
                      style: TextStyle(
                          color: tx,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Row(
                    children: List.generate(
                        5,
                        (_) => const Icon(Icons.star_rounded,
                            color: _cAmber, size: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
        ...reviews.map((r) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: _cTeal,
                      child: Text(r['initials']!,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['name']!,
                              style: TextStyle(
                                  color: tx,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                          Text(r['date']!,
                              style: TextStyle(color: sub, fontSize: 11)),
                        ],
                      ),
                    ),
                    Row(
                      children: List.generate(
                          5,
                          (_) => const Icon(Icons.star_rounded,
                              color: _cAmber, size: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(r['review']!,
                    style: TextStyle(color: sub, fontSize: 13, height: 1.4)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
