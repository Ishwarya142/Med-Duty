import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../core/services/connectivity_service.dart';
import '../../core/services/duty_geo_index_service.dart';
import '../../core/services/emergency_duty_notification_service.dart';
import '../../providers/duty_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/profile_provider.dart';

/// Initializes location + duty discovery once per session.
Future<void> bootstrapDutyDiscovery(BuildContext context) async {
  final loc = context.read<LocationProvider>();
  if (!loc.isInitialized) {
    final profile = context.read<ProfileProvider>();
    await loc.initialize(
      profileFallback: ProfileLocationFallback(
        latitude: profile.currentLatitude,
        longitude: profile.currentLongitude,
        city: profile.currentCity,
        label: profile.currentCity.isNotEmpty
            ? '${profile.currentCity}, Chennai'
            : null,
      ),
    );
  }
  if (!context.mounted) return;

  final online = await ConnectivityService().hasInternet();
  if (!context.mounted) return;

  final duty = context.read<DutyProvider>();
  duty.setOfflineMode(!online);

  if (!online) {
    await duty.restoreCachedDutiesFromDisk();
    if (!context.mounted) return;
  }

  if (online) {
    await DutyGeoIndexService().ensureGeoIndexReady();
    if (!context.mounted) return;
    if (duty.openDuties.isEmpty && !duty.discoveryLoading) {
      await duty.startDiscovery(location: loc);
    } else if (online) {
      await duty.refreshDiscoveryForLocation(loc);
    }
  } else if (duty.cachedNearbyDuties.isNotEmpty || duty.openDuties.isNotEmpty) {
    duty.computeNearbyDuties(loc);
  }

  if (!context.mounted) return;
  duty.computeNearbyDuties(loc);

  if (!context.mounted) return;
  EmergencyDutyNotificationService.instance.checkNewEmergencies(
    duties: duty,
    location: loc,
    profile: context.read<ProfileProvider>(),
  );
}

void refreshNearbyDuties(BuildContext context) {
  bootstrapDutyDiscovery(context);
}

Future<void> onDiscoveryLocationChanged(BuildContext context) async {
  final loc = context.read<LocationProvider>();
  await context.read<DutyProvider>().refreshDiscoveryForLocation(loc);
}
