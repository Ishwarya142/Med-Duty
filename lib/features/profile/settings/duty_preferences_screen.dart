// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';
import '../../../providers/settings_preferences_provider.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cPurple = Color(0xFF7C3AED);

class DutyPreferencesScreen extends StatefulWidget {
  const DutyPreferencesScreen({super.key});

  @override
  State<DutyPreferencesScreen> createState() => _DutyPreferencesScreenState();
}

class _DutyPreferencesScreenState extends State<DutyPreferencesScreen> {
  double _radius = 25.0; // 5, 10, 25, 50, 100
  late List<String> _locations;
  late List<String> _specialties;

  bool _dayDuty = true;
  bool _nightDuty = true;
  bool _fullDay = false;
  bool _halfDay = true;

  bool _weekendAvailability = true;
  bool _emergencyDuties = true;
  int _minExpectedPay = 2500;
  int _maxTravelTimeMins = 45;
  String _genderPreference = 'No Preference';
  int _advanceNoticeHours = 2;
  bool _smartRecommendations = true;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    _radius = profile.preferredWorkingRadius > 0
        ? profile.preferredWorkingRadius.toDouble()
        : 25.0;
    _locations = [
      'Avadi, Chennai',
      'Anna Nagar, Chennai',
      'Tambaram, Chennai',
    ];
    _specialties = [
      profile.specialization.isNotEmpty
          ? profile.specialization
          : 'General Medicine',
      'Paediatrics',
      'Emergency Medicine',
    ];
    _emergencyDuties = profile.emergencyAvailable;
  }

  void _showAddLocationDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Preferred Location'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. T. Nagar, Chennai',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final loc = ctrl.text.trim();
              if (loc.isNotEmpty && !_locations.contains(loc)) {
                setState(() => _locations.add(loc));
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: _cTeal),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddSpecialtyDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Specialty'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Cardiology, Anaesthesia',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final spec = ctrl.text.trim();
              if (spec.isNotEmpty && !_specialties.contains(spec)) {
                setState(() => _specialties.add(spec));
              }
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: _cTeal),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showPayDialog() {
    final options = [1500, 2000, 2500, 3500, 5000, 7500, 10000];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Minimum Expected Pay per Duty',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (p) => ListTile(
                title: Text('₹ ${p.toString()}'),
                trailing: _minExpectedPay == p
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _minExpectedPay = p);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTravelTimeDialog() {
    final options = [15, 30, 45, 60, 90, 120];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Maximum Travel Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (t) => ListTile(
                title: Text('$t mins'),
                trailing: _maxTravelTimeMins == t
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _maxTravelTimeMins = t);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGenderPreferenceDialog() {
    const options = ['No Preference', 'Female Only', 'Male Only'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Gender Preference',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (g) => ListTile(
                title: Text(g),
                trailing: _genderPreference == g
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _genderPreference = g);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAdvanceNoticeDialog() {
    final options = [1, 2, 4, 6, 12, 24];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Minimum Advance Notice',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (h) => ListTile(
                title: Text('$h Hour${h > 1 ? 's' : ''}'),
                trailing: _advanceNoticeHours == h
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _advanceNoticeHours = h);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePreferences() async {
    HapticFeedback.mediumImpact();
    final profile = context.read<ProfileProvider>();
    final prefs = context.read<SettingsPreferencesProvider>();

    await profile.updateProfile(
      preferredWorkingRadius: _radius.toInt(),
      emergencyAvailable: _emergencyDuties,
    );
    await prefs.setDutyNearby(true);
    await prefs.setDutyEmergency(_emergencyDuties);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Duty preferences saved successfully!'),
          backgroundColor: _cTeal,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: tx),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Duty Preferences',
              style: TextStyle(
                color: tx,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Customize your duty search preferences',
              style: TextStyle(color: sub, fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // ── Search Radius ───────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Search Radius',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tx,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _cTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_radius.toInt()} km',
                        style: const TextStyle(
                          color: _cTeal,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Set the maximum distance you are willing to travel for duties.',
                  style: TextStyle(fontSize: 12.5, color: sub),
                ),
                const SizedBox(height: 12),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _cTeal,
                    inactiveTrackColor: sub.withValues(alpha: 0.2),
                    thumbColor: _cTeal,
                    overlayColor: _cTeal.withValues(alpha: 0.15),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _radius,
                    min: 5,
                    max: 100,
                    divisions: 4, // 5, 25, 50, 75, 100
                    onChanged: (v) => setState(() => _radius = v),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('5 km', style: TextStyle(fontSize: 11, color: sub)),
                      Text('10 km', style: TextStyle(fontSize: 11, color: sub)),
                      Text('25 km', style: TextStyle(fontSize: 11, color: sub)),
                      Text('50 km', style: TextStyle(fontSize: 11, color: sub)),
                      Text('100 km', style: TextStyle(fontSize: 11, color: sub)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Preferred Locations ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preferred Locations',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tx,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: sub),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Add locations where you prefer to take duties',
                  style: TextStyle(fontSize: 12.5, color: sub),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._locations.map(
                      (loc) => Chip(
                        label: Text(loc, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () => setState(() => _locations.remove(loc)),
                        backgroundColor: _cTeal.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: _cTeal.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add_rounded, size: 16, color: _cTeal),
                      label: const Text(
                        'Add Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: _cTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: card,
                      side: const BorderSide(color: _cTeal, style: BorderStyle.solid),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: _showAddLocationDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Preferred Specialties ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Preferred Specialties',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tx,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: sub),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the specialties you are comfortable with',
                  style: TextStyle(fontSize: 12.5, color: sub),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._specialties.map(
                      (spec) => Chip(
                        label: Text(spec, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () =>
                            setState(() => _specialties.remove(spec)),
                        backgroundColor: _cTeal.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: _cTeal.withValues(alpha: 0.25),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.add_rounded, size: 16, color: _cTeal),
                      label: const Text(
                        'Add Specialty',
                        style: TextStyle(
                          fontSize: 12,
                          color: _cTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: card,
                      side: const BorderSide(color: _cTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: _showAddSpecialtyDialog,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Duty Types (2x2 Grid Cards) ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Duty Types',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: tx,
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: sub),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Select the type of duties you want to see',
                  style: TextStyle(fontSize: 12.5, color: sub),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _dutyTypeCard(
                        Icons.wb_sunny_outlined,
                        'Day Duty',
                        '6 AM - 6 PM',
                        _dayDuty,
                        (v) => setState(() => _dayDuty = v),
                        card,
                        border,
                        tx,
                        sub,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dutyTypeCard(
                        Icons.nightlight_outlined,
                        'Night Duty',
                        '6 PM - 6 AM',
                        _nightDuty,
                        (v) => setState(() => _nightDuty = v),
                        card,
                        border,
                        tx,
                        sub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _dutyTypeCard(
                        Icons.calendar_month_outlined,
                        'Full Day',
                        '24 Hours',
                        _fullDay,
                        (v) => setState(() => _fullDay = v),
                        card,
                        border,
                        tx,
                        sub,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dutyTypeCard(
                        Icons.schedule_rounded,
                        'Half Day',
                        'Up to 6 Hours',
                        _halfDay,
                        (v) => setState(() => _halfDay = v),
                        card,
                        border,
                        tx,
                        sub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Availability & Pay Settings ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Weekend Availability',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'I am available on weekends',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  activeColor: _cTeal,
                  value: _weekendAvailability,
                  onChanged: (v) => setState(() => _weekendAvailability = v),
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Emergency Duties',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'I am available for emergency duties',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  activeColor: _cTeal,
                  value: _emergencyDuties,
                  onChanged: (v) => setState(() => _emergencyDuties = v),
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Minimum Expected Pay',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'Set your minimum expected pay per duty',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${_minExpectedPay.toString()}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: _cTeal,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showPayDialog,
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Maximum Travel Time',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'Maximum travel time you are okay with',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_maxTravelTimeMins mins',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: tx,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showTravelTimeDialog,
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Gender Preference',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'If you have any preference',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _genderPreference,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: tx,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showGenderPreferenceDialog,
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Advance Notice',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'Minimum advance notice required',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$_advanceNoticeHours Hours',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: tx,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showAdvanceNoticeDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Smart Recommendations ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _cAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: _cAmber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Smart Recommendations',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: tx,
                        ),
                      ),
                      Text(
                        'We will use your preferences to show you the most relevant duties.',
                        style: TextStyle(fontSize: 12, color: sub),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _smartRecommendations,
                  activeColor: _cTeal,
                  onChanged: (v) =>
                      setState(() => _smartRecommendations = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Preferences Button ─────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _savePreferences,
              style: ElevatedButton.styleFrom(
                backgroundColor: _cTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Preferences',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dutyTypeCard(
    IconData icon,
    String title,
    String timing,
    bool isSelected,
    ValueChanged<bool> onChanged,
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return GestureDetector(
      onTap: () => onChanged(!isSelected),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? _cTeal.withValues(alpha: 0.06) : card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? _cTeal : border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? _cTeal : sub,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: tx,
                    ),
                  ),
                  Text(
                    timing,
                    style: TextStyle(fontSize: 10.5, color: sub),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: _cTeal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (v) => onChanged(v ?? false),
            ),
          ],
        ),
      ),
    );
  }
}
