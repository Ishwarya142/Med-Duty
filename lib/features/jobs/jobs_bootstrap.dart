import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/location_provider.dart';
import '../duties/discovery_bootstrap.dart';

/// Initializes job discovery alongside existing duty discovery.
Future<void> bootstrapJobDiscovery(BuildContext context) async {
  await bootstrapDutyDiscovery(context);
  if (!context.mounted) return;

  final jobs = context.read<JobProvider>();
  final loc = context.read<LocationProvider>();
  final auth = context.read<AuthProvider>();

  if (jobs.openJobs.isEmpty && !jobs.loading) {
    await jobs.startDiscovery(location: loc);
  }
  jobs.computeNearbyJobs(loc);

  if (auth.user?.uid != null) {
    await jobs.loadJobData(auth.user!.uid);
  }
}
