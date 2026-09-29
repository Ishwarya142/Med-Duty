import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/duty_discovery_models.dart';
import '../../../providers/duty_provider.dart';

const _cTeal = Color(0xFF0F766E);

Future<void> showDutyDiscoveryFiltersSheet(BuildContext context) async {
  final dutyProvider = context.read<DutyProvider>();
  var filters = dutyProvider.discoveryFilters;
  var sort = dutyProvider.sortOption;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => StatefulBuilder(
      builder: (ctx, setSt) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final card = isDark ? const Color(0xFF1E293B) : Colors.white;
        final tx = isDark ? Colors.white : const Color(0xFF0F172A);
        final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sub.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.tune_rounded, color: _cTeal),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Filters & Sort',
                        style: TextStyle(
                          color: tx,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setSt(() {
                          filters = const DutyDiscoveryFilters();
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  children: [
                    Text('Sort by', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: DutySortOption.values.map((opt) {
                        final sel = sort == opt;
                        return ChoiceChip(
                          label: Text(opt.label),
                          selected: sel,
                          onSelected: (_) => setSt(() => sort = opt),
                          selectedColor: _cTeal.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: sel ? _cTeal : sub,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text('Specialization', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _multiChips(
                      kSpecializationFilters,
                      filters.specializations,
                      (next) => setSt(() => filters = filters.copyWith(specializations: next)),
                      sub,
                    ),
                    const SizedBox(height: 16),
                    Text('Shift', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _multiChips(
                      kShiftFilters,
                      filters.shifts,
                      (next) => setSt(() => filters = filters.copyWith(shifts: next)),
                      sub,
                    ),
                    const SizedBox(height: 16),
                    Text('Duty type', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    _multiChips(
                      kDutyTypeFilters,
                      filters.dutyTypes,
                      (next) => setSt(() => filters = filters.copyWith(dutyTypes: next)),
                      sub,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      value: filters.verifiedHospitalsOnly,
                      onChanged: (v) => setSt(
                        () => filters = filters.copyWith(verifiedHospitalsOnly: v),
                      ),
                      title: Text('Verified hospitals only', style: TextStyle(color: tx)),
                      activeThumbColor: _cTeal,
                    ),
                    const SizedBox(height: 8),
                    Text('Date', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        _dateChip('Today', 'today', filters, (f) => setSt(() => filters = f), tx, sub),
                        _dateChip('Tomorrow', 'tomorrow', filters, (f) => setSt(() => filters = f), tx, sub),
                        _dateChip('This week', 'week', filters, (f) => setSt(() => filters = f), tx, sub),
                      ],
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Custom date', style: TextStyle(color: tx, fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        filters.dateFilter != null
                            ? '${filters.dateFilter!.day}/${filters.dateFilter!.month}/${filters.dateFilter!.year}'
                            : 'Pick a specific date',
                        style: TextStyle(color: sub, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.calendar_today_rounded, color: _cTeal),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: filters.dateFilter ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 1)),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setSt(() {
                            filters = filters.copyWith(
                              dateFilter: picked,
                              datePreset: null,
                            );
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Payout range (₹)', style: TextStyle(color: tx, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: filters.minPayout?.toStringAsFixed(0) ?? '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Min',
                              labelStyle: TextStyle(color: sub),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) {
                              final n = double.tryParse(v);
                              setSt(() => filters = filters.copyWith(minPayout: n));
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: filters.maxPayout?.toStringAsFixed(0) ?? '',
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Max',
                              labelStyle: TextStyle(color: sub),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (v) {
                              final n = double.tryParse(v);
                              setSt(() => filters = filters.copyWith(maxPayout: n));
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      dutyProvider.setDiscoveryFilters(filters);
                      dutyProvider.setSortOption(sort);
                      Navigator.pop(ctx);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _cTeal,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Apply filters'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _multiChips(
  List<String> options,
  Set<String> selected,
  ValueChanged<Set<String>> onChanged,
  Color sub,
) {
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: options.map((o) {
      final sel = selected.contains(o);
      return FilterChip(
        label: Text(o),
        selected: sel,
        onSelected: (v) {
          final next = Set<String>.from(selected);
          if (v) {
            next.add(o);
          } else {
            next.remove(o);
          }
          onChanged(next);
        },
        selectedColor: _cTeal.withValues(alpha: 0.15),
        checkmarkColor: _cTeal,
        labelStyle: TextStyle(
          color: sel ? _cTeal : sub,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    }).toList(),
  );
}

Widget _dateChip(
  String label,
  String preset,
  DutyDiscoveryFilters current,
  ValueChanged<DutyDiscoveryFilters> onChanged,
  Color tx,
  Color sub,
) {
  final sel = current.datePreset == preset;
  return ChoiceChip(
    label: Text(label),
    selected: sel,
    onSelected: (_) {
      onChanged(
        current.copyWith(
          datePreset: sel ? null : preset,
          clearDate: sel,
        ),
      );
    },
    selectedColor: _cTeal.withValues(alpha: 0.15),
    labelStyle: TextStyle(color: sel ? _cTeal : sub),
  );
}
