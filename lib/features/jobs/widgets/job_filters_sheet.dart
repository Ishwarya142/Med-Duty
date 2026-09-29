import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/job_discovery_models.dart';
import '../../../models/job_model.dart';
import '../../../providers/job_provider.dart';

const _cBlue = Color(0xFF2563EB);

Future<void> showJobFiltersSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _JobFiltersSheet(),
  );
}

class _JobFiltersSheet extends StatefulWidget {
  const _JobFiltersSheet();

  @override
  State<_JobFiltersSheet> createState() => _JobFiltersSheetState();
}

class _JobFiltersSheetState extends State<_JobFiltersSheet> {
  late Set<String> _specializations;
  late Set<EmploymentType> _employmentTypes;
  int? _postedWithinDays;
  bool _verifiedOnly = false;

  static const _specialties = [
    'General Medicine',
    'General Physician',
    'Cardiology',
    'Pediatrics',
    'Dermatology',
    'Orthopedic Surgery',
    'Anesthesiology',
    'Emergency Medicine',
    'Radiology',
  ];

  @override
  void initState() {
    super.initState();
    final f = context.read<JobProvider>().filters;
    _specializations = Set.from(f.specializations);
    _employmentTypes = Set.from(f.employmentTypes);
    _postedWithinDays = f.postedWithinDays;
    _verifiedOnly = f.verifiedHospitalsOnly;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);

    return Container(
      decoration: BoxDecoration(
        color: card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Job Filters',
                style: TextStyle(
                    color: tx, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Specialty', style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specialties.map((s) {
                final selected = _specializations.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _specializations.add(s);
                    } else {
                      _specializations.remove(s);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Employment Type',
                style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: EmploymentType.values.map((t) {
                final selected = _employmentTypes.contains(t);
                return FilterChip(
                  label: Text(_employmentLabel(t)),
                  selected: selected,
                  onSelected: (v) => setState(() {
                    if (v) {
                      _employmentTypes.add(t);
                    } else {
                      _employmentTypes.remove(t);
                    }
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Date Posted',
                style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _postedChip('Today', 1),
                _postedChip('Last 3 days', 3),
                _postedChip('Last 7 days', 7),
                _postedChip('Last 30 days', 30),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Verified hospitals only', style: TextStyle(color: tx)),
              value: _verifiedOnly,
              activeThumbColor: _cBlue,
              onChanged: (v) => setState(() => _verifiedOnly = v),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      context.read<JobProvider>().setFilters(
                            const JobDiscoveryFilters(),
                          );
                      Navigator.pop(context);
                    },
                    child: const Text('Clear'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      context.read<JobProvider>().setFilters(
                            JobDiscoveryFilters(
                              specializations: _specializations,
                              employmentTypes: _employmentTypes,
                              postedWithinDays: _postedWithinDays,
                              verifiedHospitalsOnly: _verifiedOnly,
                            ),
                          );
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(backgroundColor: _cBlue),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _postedChip(String label, int days) {
    final selected = _postedWithinDays == days;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (v) => setState(() {
        _postedWithinDays = v ? days : null;
      }),
    );
  }

  String _employmentLabel(EmploymentType t) {
    switch (t) {
      case EmploymentType.fullTime:
        return 'Full-time';
      case EmploymentType.partTime:
        return 'Part-time';
      case EmploymentType.contract:
        return 'Contract';
      case EmploymentType.permanent:
        return 'Permanent';
      case EmploymentType.locum:
        return 'Locum';
      case EmploymentType.remote:
        return 'Remote';
      case EmploymentType.hybrid:
        return 'Hybrid';
      case EmploymentType.internship:
        return 'Internship';
      case EmploymentType.fellowship:
        return 'Fellowship';
      case EmploymentType.residency:
        return 'Residency';
      case EmploymentType.temporary:
        return 'Temporary';
    }
  }
}
