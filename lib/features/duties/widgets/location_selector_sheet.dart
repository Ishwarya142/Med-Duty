import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/geocoding_service.dart';
import '../../../core/services/location_service.dart';
import '../../../models/duty_discovery_models.dart';
import '../../../providers/location_provider.dart';

const _cTeal = Color(0xFF0F766E);

Future<void> showLocationSelectorSheet(BuildContext context) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _LocationSelectorSheet(),
  );
}

class _LocationSelectorSheet extends StatefulWidget {
  const _LocationSelectorSheet();

  @override
  State<_LocationSelectorSheet> createState() => _LocationSelectorSheetState();
}

class _LocationSelectorSheetState extends State<_LocationSelectorSheet> {
  final _searchCtrl = TextEditingController();
  final _geocoding = GeocodingService();
  String _query = '';
  List<SearchLocationSuggestion> _remoteResults = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<SearchLocationSuggestion> get _localSuggestions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return kPopularSearchLocations;
    return kPopularSearchLocations
        .where(
          (s) =>
              s.label.toLowerCase().contains(q) ||
              s.subtitle.toLowerCase().contains(q),
        )
        .toList();
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().length < 2) {
      setState(() {
        _remoteResults = [];
        _searching = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 450), () async {
      setState(() => _searching = true);
      final results = await _geocoding.searchPlaces(value);
      if (mounted) {
        setState(() {
          _remoteResults = results;
          _searching = false;
        });
      }
    });
  }

  List<SearchLocationSuggestion> get _displayList {
    if (_query.trim().length >= 2 && _remoteResults.isNotEmpty) {
      return _remoteResults;
    }
    return _localSuggestions;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final loc = context.watch<LocationProvider>();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: _cTeal),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Choose search location',
                    style: TextStyle(
                      color: tx,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close_rounded, color: sub),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onQueryChanged,
              style: TextStyle(color: tx),
              decoration: InputDecoration(
                hintText: 'Search any city, area, hospital or landmark',
                hintStyle: TextStyle(color: sub, fontSize: 13),
                prefixIcon: Icon(Icons.search_rounded, color: sub),
                suffixIcon: _searching
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
                filled: true,
                fillColor: sub.withValues(alpha: 0.08),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _query.trim().length >= 2
                    ? 'Results anywhere in the world'
                    : 'Popular locations',
                style: TextStyle(color: sub, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 4),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _cTeal.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: loc.loadingGps
                  ? const Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, color: _cTeal),
            ),
            title: Text(
              'Use current location',
              style: TextStyle(color: tx, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              loc.accessState == LocationAccessState.denied ||
                      loc.accessState == LocationAccessState.deniedForever
                  ? 'Permission unavailable — choose manually'
                  : 'GPS location',
              style: TextStyle(color: sub, fontSize: 12),
            ),
            onTap: loc.loadingGps
                ? null
                : () async {
                    final ok = await context
                        .read<LocationProvider>()
                        .tryUseCurrentLocation();
                    if (context.mounted && ok) Navigator.pop(context);
                  },
          ),
          const Divider(height: 1),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              itemCount: _displayList.length,
              itemBuilder: (_, i) {
                final s = _displayList[i];
                return ListTile(
                  leading: Icon(Icons.place_rounded,
                      color: _cTeal.withValues(alpha: 0.8)),
                  title: Text(
                    s.label,
                    style: TextStyle(color: tx, fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      Text(s.subtitle, style: TextStyle(color: sub, fontSize: 12)),
                  onTap: () {
                    context.read<LocationProvider>().setSearchLocation(
                          SearchLocation(
                            label: s.subtitle.contains(',')
                                ? s.subtitle.split(',').take(2).join(',')
                                : s.label,
                            latitude: s.latitude,
                            longitude: s.longitude,
                          ),
                        );
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<double?> showRadiusSelectorSheet(
  BuildContext context,
  double current,
) async {
  return showModalBottomSheet<double>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final card = isDark ? const Color(0xFF1E293B) : Colors.white;
      final tx = isDark ? Colors.white : const Color(0xFF0F172A);
      final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      var selected = current;

      return StatefulBuilder(
        builder: (ctx, setSt) => Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Search within',
                style: TextStyle(
                  color: tx,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kRadiusOptionsKm.map((km) {
                  final active = selected == km;
                  return ChoiceChip(
                    label: Text('${km.toStringAsFixed(0)} km'),
                    selected: active,
                    onSelected: (_) => setSt(() => selected = km),
                    selectedColor: _cTeal.withValues(alpha: 0.15),
                    labelStyle: TextStyle(
                      color: active ? _cTeal : sub,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: active ? _cTeal : sub.withValues(alpha: 0.25),
                    ),
                  );
                }).toList(),
              ),
              Slider(
                value: selected,
                min: 2,
                max: 50,
                divisions: 48,
                label: '${selected.round()} km',
                activeColor: _cTeal,
                onChanged: (v) => setSt(() => selected = v),
              ),
              Center(
                child: Text(
                  '${selected.toStringAsFixed(0)} km radius',
                  style: const TextStyle(
                    color: _cTeal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx, selected),
                  style: FilledButton.styleFrom(
                    backgroundColor: _cTeal,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Apply radius'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
