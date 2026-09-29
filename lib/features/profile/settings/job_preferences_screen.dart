// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../providers/profile_provider.dart';

const _cTeal   = Color(0xFF0F766E);
const _cGreen  = Color(0xFF16A34A);
const _cBlue   = Color(0xFF2563EB);
const _cAmber  = Color(0xFFF59E0B);
const _cPurple = Color(0xFF7C3AED);

class JobPreferencesScreen extends StatefulWidget {
  const JobPreferencesScreen({super.key});

  @override
  State<JobPreferencesScreen> createState() => _JobPreferencesScreenState();
}

class _JobPreferencesScreenState extends State<JobPreferencesScreen> {
  String _jobTitle = 'Consultant Dermatologist';
  String _specialty = 'Dermatology';
  late List<String> _preferredLocations;
  final List<String> _workTypes = ['Full-Time', 'Part-Time', 'Locum / Visiting'];
  final Set<String> _selectedWorkTypes = {'Full-Time', 'Locum / Visiting'};
  int _minSalaryLakhs = 18; // in LPA
  int _maxCommuteMins = 45;
  String _experienceLevel = '5 - 10 Years';
  bool _openToRelocation = false;
  bool _jobAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>();
    if (profile.specialization.isNotEmpty) {
      _specialty = profile.specialization;
      _jobTitle = 'Consultant ${profile.specialization}';
    }
    _preferredLocations = ['Delhi NCR', 'Gurugram', 'Noida'];
  }

  void _showAddLocationDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Preferred City / Region'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. Bengaluru, Mumbai',
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
              if (loc.isNotEmpty && !_preferredLocations.contains(loc)) {
                setState(() => _preferredLocations.add(loc));
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

  void _showSalaryDialog() {
    final options = [8, 12, 15, 18, 24, 30, 40, 50];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Minimum Expected Annual Package (LPA)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (s) => ListTile(
                title: Text('₹ $s LPA'),
                trailing: _minSalaryLakhs == s
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _minSalaryLakhs = s);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExperienceDialog() {
    const options = ['0 - 2 Years', '2 - 5 Years', '5 - 10 Years', '10+ Years'];
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Experience Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            ...options.map(
              (e) => ListTile(
                title: Text(e),
                trailing: _experienceLevel == e
                    ? const Icon(Icons.check_circle_rounded, color: _cTeal)
                    : null,
                onTap: () {
                  setState(() => _experienceLevel = e);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveJobPreferences() {
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Job preferences saved successfully!'),
        backgroundColor: _cTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
    Navigator.pop(context);
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
              'Job Preferences',
              style: TextStyle(
                color: tx,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Set your job search and placement preferences',
              style: TextStyle(color: sub, fontSize: 12),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
        children: [
          // ── Preferred Job Title & Specialty ─────────────────────────────────
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
                Text(
                  'Desired Role & Specialty',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: tx,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _jobTitle),
                  onChanged: (v) => _jobTitle = v,
                  decoration: InputDecoration(
                    labelText: 'Preferred Job Title',
                    labelStyle: TextStyle(color: sub),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _cTeal, width: 1.5),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: _specialty),
                  onChanged: (v) => _specialty = v,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    labelStyle: TextStyle(color: sub),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _cTeal, width: 1.5),
                    ),
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
                  'Cities & regions you would like to work in',
                  style: TextStyle(fontSize: 12.5, color: sub),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._preferredLocations.map(
                      (loc) => Chip(
                        label: Text(loc, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close_rounded, size: 14),
                        onDeleted: () =>
                            setState(() => _preferredLocations.remove(loc)),
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
                      side: const BorderSide(color: _cTeal),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      onPressed: _showAddLocationDialog,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Open to Relocation',
                    style: TextStyle(fontSize: 14, color: tx),
                  ),
                  activeColor: _cTeal,
                  value: _openToRelocation,
                  onChanged: (v) => setState(() => _openToRelocation = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Work Type (Full-time, Part-time, Locum) ─────────────────────────
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
                Text(
                  'Employment Type',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: tx,
                  ),
                ),
                const SizedBox(height: 10),
                ..._workTypes.map(
                  (wt) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      wt,
                      style: TextStyle(fontSize: 14, color: tx),
                    ),
                    value: _selectedWorkTypes.contains(wt),
                    activeColor: _cTeal,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedWorkTypes.add(wt);
                        } else {
                          _selectedWorkTypes.remove(wt);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ── Salary, Experience & Alerts ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Minimum Expected Salary',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'Annual CTC expectation',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹ $_minSalaryLakhs LPA',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: _cTeal,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showSalaryDialog,
                ),
                const Divider(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Experience Level',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _experienceLevel,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: tx,
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: sub),
                    ],
                  ),
                  onTap: _showExperienceDialog,
                ),
                const Divider(height: 16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Job Alerts',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: tx,
                    ),
                  ),
                  subtitle: Text(
                    'Receive instant alerts when matching jobs are posted',
                    style: TextStyle(fontSize: 12, color: sub),
                  ),
                  activeColor: _cTeal,
                  value: _jobAlertsEnabled,
                  onChanged: (v) => setState(() => _jobAlertsEnabled = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Save Button ─────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _saveJobPreferences,
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
}
