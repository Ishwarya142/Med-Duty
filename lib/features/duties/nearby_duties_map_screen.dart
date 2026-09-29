import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../models/duty_with_distance.dart';
import '../../providers/duty_provider.dart';
import '../../providers/location_provider.dart';
import 'discovery_helpers.dart';
import 'widgets/discovery_map_widget.dart';
import 'widgets/duty_discovery_card.dart';
import 'widgets/duty_discovery_filters_sheet.dart';
import 'widgets/location_selector_sheet.dart';

const _cTeal = Color(0xFF0F766E);

class NearbyDutiesMapScreen extends StatefulWidget {
  const NearbyDutiesMapScreen({super.key});

  @override
  State<NearbyDutiesMapScreen> createState() => _NearbyDutiesMapScreenState();
}

class _NearbyDutiesMapScreenState extends State<NearbyDutiesMapScreen> {
  bool _mapMode = true;
  bool _showSearchArea = false;
  LatLng? _pendingMapCenter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final loc = context.read<LocationProvider>();
    if (!loc.isInitialized) await loc.initialize();
    if (!mounted) return;
    await context.read<DutyProvider>().startDiscovery(location: loc);
    if (mounted) _refreshResults();
  }

  void _refreshResults() {
    context.read<DutyProvider>().computeNearbyDuties(
          context.read<LocationProvider>(),
        );
    setState(() {});
  }

  Future<void> _onLocationOrRadiusChanged() async {
    final loc = context.read<LocationProvider>();
    await context.read<DutyProvider>().refreshDiscoveryForLocation(loc);
    if (mounted) _refreshResults();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final loc = context.watch<LocationProvider>();
    final dutyProvider = context.watch<DutyProvider>();
    final duties = dutyProvider.nearbyDuties.isEmpty
        ? dutyProvider.computeNearbyDuties(loc)
        : dutyProvider.nearbyDuties;

    DutyWithDistance? selected;
    for (final d in duties) {
      if (d.duty.id == dutyProvider.selectedDutyId) {
        selected = d;
        break;
      }
    }

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Nearby Duties',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: () async {
              await showDutyDiscoveryFiltersSheet(context);
              _refreshResults();
            },
            icon: Badge(
              isLabelVisible: dutyProvider.discoveryFilters.activeCount > 0,
              label: Text('${dutyProvider.discoveryFilters.activeCount}'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _locationHeader(loc, tx, sub, card, duties.length),
          _mapListToggle(card),
          if (dutyProvider.newDutiesCount > 0) _newDutiesBanner(dutyProvider, tx),
          Expanded(
            child: dutyProvider.discoveryLoading
                ? _loadingState(sub)
                : _mapMode
                    ? _buildMapView(loc, duties, dutyProvider, selected, sub)
                    : _buildListView(duties, dutyProvider, sub, loc),
          ),
          if (selected != null && _mapMode) _previewCard(selected, dutyProvider, card, tx),
        ],
      ),
    );
  }

  Widget _locationHeader(
    LocationProvider loc,
    Color tx,
    Color sub,
    Color card,
    int count,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: sub.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () async {
              await showLocationSelectorSheet(context);
              await _onLocationOrRadiusChanged();
            },
            child: Row(
              children: [
                const Icon(Icons.location_on_rounded, color: _cTeal, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loc.locationLabel,
                    style: TextStyle(color: tx, fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                ),
                const Text('Change', style: TextStyle(color: _cTeal, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () async {
                  final locProvider = context.read<LocationProvider>();
                  final r = await showRadiusSelectorSheet(context, loc.radiusKm);
                  if (r != null) {
                    locProvider.setRadiusKm(r);
                    await _onLocationOrRadiusChanged();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _cTeal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    loc.radiusLabel,
                    style: const TextStyle(
                      color: _cTeal,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('$count duties found', style: TextStyle(color: sub, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapListToggle(Color card) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mapMode = true),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _mapMode ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Map',
                      style: TextStyle(
                        color: _mapMode ? Colors.white : _cTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _mapMode = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_mapMode ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'List',
                      style: TextStyle(
                        color: !_mapMode ? Colors.white : _cTeal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _newDutiesBanner(DutyProvider dutyProvider, Color tx) {
    return Material(
      color: _cTeal.withValues(alpha: 0.12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '${dutyProvider.newDutiesCount} new duty available nearby',
                style: TextStyle(color: tx, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(
              onPressed: () {
                dutyProvider.clearNewDutiesBanner();
                _refreshResults();
              },
              child: const Text('View'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loadingState(Color sub) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: _cTeal),
          const SizedBox(height: 12),
          Text('Finding duties near you...', style: TextStyle(color: sub)),
        ],
      ),
    );
  }

  Widget _buildMapView(
    LocationProvider loc,
    List<DutyWithDistance> duties,
    DutyProvider dutyProvider,
    DutyWithDistance? selected,
    Color sub,
  ) {
    final center = loc.searchLocation;
    if (center == null) return _emptyState(sub, loc);

    return Stack(
      children: [
        DiscoveryMapWidget(
          searchCenter: center,
          radiusKm: loc.radiusKm,
          duties: duties,
          selectedDutyId: dutyProvider.selectedDutyId,
          onDutySelected: (id) {
            dutyProvider.selectDuty(id);
            setState(() {});
          },
          onMapPanned: (target) {
            setState(() {
              _showSearchArea = true;
              _pendingMapCenter = target;
            });
          },
        ),
        if (_showSearchArea && _pendingMapCenter != null) _searchAreaButton(),
      ],
    );
  }

  Widget _searchAreaButton() {
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: Center(
        child: FilledButton.icon(
          onPressed: () {
            final p = _pendingMapCenter;
            if (p == null) return;
            context.read<LocationProvider>().setSearchLocation(
                  SearchLocation(
                    label: 'Map area',
                    latitude: p.latitude,
                    longitude: p.longitude,
                  ),
                );
            setState(() {
              _showSearchArea = false;
              _pendingMapCenter = null;
            });
            _onLocationOrRadiusChanged();
          },
          icon: const Icon(Icons.travel_explore_rounded, size: 18),
          label: const Text('Search this area'),
          style: FilledButton.styleFrom(backgroundColor: _cTeal),
        ),
      ),
    );
  }

  Widget _buildListView(
    List<DutyWithDistance> duties,
    DutyProvider dutyProvider,
    Color sub,
    LocationProvider loc,
  ) {
    if (duties.isEmpty) return _emptyState(sub, loc);

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: duties.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (_, i) {
        final item = duties[i];
        return DutyDiscoveryCard(
          item: item,
          isSelected: dutyProvider.selectedDutyId == item.duty.id,
          isApplied: dutyProvider.isDutyApplied(item.duty.id),
          isSaved: dutyProvider.isDutySaved(item.duty.id),
          onTap: () {
            dutyProvider.selectDuty(item.duty.id);
            _openDetails(item);
          },
          onApply: () => applyDiscoveryDuty(context, item),
          onSave: () => toggleDiscoverySave(context, item),
        );
      },
    );
  }

  Widget _emptyState(Color sub, LocationProvider loc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: sub),
            const SizedBox(height: 12),
            Text(
              'No duties found within ${loc.radiusKm.toStringAsFixed(0)} km',
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () async {
                    context.read<LocationProvider>().setRadiusKm(25);
                    await _onLocationOrRadiusChanged();
                  },
                  child: const Text('Expand to 25 km'),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await showLocationSelectorSheet(context);
                    await _onLocationOrRadiusChanged();
                  },
                  child: const Text('Change location'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _previewCard(
    DutyWithDistance item,
    DutyProvider dutyProvider,
    Color card,
    Color tx,
  ) {
    return Container(
      color: card,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.duty.role, style: TextStyle(color: tx, fontWeight: FontWeight.w800, fontSize: 15)),
          Text(
            '${item.duty.hospitalName} • ${item.formattedDistance}',
            style: TextStyle(color: tx.withValues(alpha: 0.7), fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openDetails(item),
                  child: const Text('View Details'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: dutyProvider.isDutyApplied(item.duty.id)
                      ? null
                      : () => applyDiscoveryDuty(context, item),
                  style: FilledButton.styleFrom(backgroundColor: _cTeal),
                  child: Text(dutyProvider.isDutyApplied(item.duty.id) ? 'Applied' : 'Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openDetails(DutyWithDistance item) {
    openDiscoveryDutyDetails(context, item);
  }
}
