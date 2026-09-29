import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/geo_utils.dart';
import '../../../core/utils/marker_cluster_utils.dart';
import '../../../models/duty_with_distance.dart';
import '../../../providers/location_provider.dart';

const _cTeal = Color(0xFF0F766E);

/// Cross-platform duty discovery map using OpenStreetMap via flutter_map.
/// **No Google Maps API key required** — works on Android, iOS, and Web.
class DiscoveryMapWidget extends StatefulWidget {
  final SearchLocation? searchCenter;
  final double radiusKm;
  final List<DutyWithDistance> duties;
  final String? selectedDutyId;
  final ValueChanged<String?> onDutySelected;
  final ValueChanged<LatLng>? onMapPanned;

  const DiscoveryMapWidget({
    super.key,
    required this.searchCenter,
    required this.radiusKm,
    required this.duties,
    this.selectedDutyId,
    required this.onDutySelected,
    this.onMapPanned,
  });

  @override
  State<DiscoveryMapWidget> createState() => _DiscoveryMapWidgetState();
}

class _DiscoveryMapWidgetState extends State<DiscoveryMapWidget> {
  final MapController _mapController = MapController();
  double _zoom = 12;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _recenter() {
    final center = widget.searchCenter;
    if (center == null) return;
    final point = LatLng(center.latitude, center.longitude);
    final zoom = zoomForRadiusKm(widget.radiusKm);
    _mapController.move(point, zoom);
    setState(() => _zoom = zoom);
  }

  List<Marker> _buildMarkers() {
    final center = widget.searchCenter;
    if (center == null) return [];

    final clusters = clusterDuties(widget.duties, _zoom);
    final markers = <Marker>[];

    for (var i = 0; i < clusters.length; i++) {
      final cluster = clusters[i];
      if (cluster.isCluster) {
        markers.add(
          Marker(
            point: cluster.center,
            width: 48,
            height: 48,
            child: GestureDetector(
              onTap: () {
                _mapController.move(
                  cluster.center,
                  zoomInFromCluster(_zoom),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _cTeal,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${cluster.count}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      } else {
        final item = cluster.items.first;
        final duty = item.duty;
        final selected = duty.id == widget.selectedDutyId;
        markers.add(
          Marker(
            point: LatLng(duty.latitude!, duty.longitude!),
            width: 42,
            height: 42,
            child: GestureDetector(
              onTap: () => widget.onDutySelected(duty.id),
              child: Icon(
                Icons.local_hospital_rounded,
                color: selected ? Colors.green : Colors.blue,
                size: 36,
              ),
            ),
          ),
        );
      }
    }

    markers.add(
      Marker(
        point: LatLng(center.latitude, center.longitude),
        width: 42,
        height: 42,
        child: const Icon(
          Icons.person_pin_circle_rounded,
          color: Colors.red,
          size: 40,
        ),
      ),
    );

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final center = widget.searchCenter;
    if (center == null) {
      return const Center(child: Text('Choose a search location'));
    }

    final initialZoom = zoomForRadiusKm(widget.radiusKm);
    final mapCenter = LatLng(center.latitude, center.longitude);

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: initialZoom,
            onTap: (_, _) => widget.onDutySelected(null),
            onPositionChanged: (position, hasGesture) {
              _zoom = position.zoom;
              if (hasGesture) {
                final target = position.center;
                final dist = distanceKm(
                  target.latitude,
                  target.longitude,
                  center.latitude,
                  center.longitude,
                );
                if (dist > 0.8) {
                  widget.onMapPanned?.call(target);
                }
              }
              setState(() {});
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.medduty',
            ),
            CircleLayer(
              circles: [
                CircleMarker(
                  point: mapCenter,
                  radius: widget.radiusKm * 1000,
                  useRadiusInMeter: true,
                  color: _cTeal.withValues(alpha: 0.10),
                  borderColor: _cTeal.withValues(alpha: 0.55),
                  borderStrokeWidth: 2,
                ),
              ],
            ),
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.small(
            backgroundColor: Colors.white,
            onPressed: _recenter,
            tooltip: 'Recenter',
            child: const Icon(Icons.my_location_rounded, color: _cTeal),
          ),
        ),
        Positioned(
          left: 8,
          bottom: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                '© OpenStreetMap',
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
