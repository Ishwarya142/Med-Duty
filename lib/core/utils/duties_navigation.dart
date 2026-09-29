import 'package:flutter/foundation.dart';

/// Cross-tab navigation requests for the Duties screen (Duties vs Jobs toggle).
class DutiesNavigation {
  DutiesNavigation._();

  static final DutiesNavigation instance = DutiesNavigation._();

  /// 0 = Duties, 1 = Jobs. Set before switching to the Duties tab.
  final ValueNotifier<int?> pendingOpportunityMode = ValueNotifier(null);

  void openJobsTab() => pendingOpportunityMode.value = 1;

  void openDutiesTab() => pendingOpportunityMode.value = 0;

  void consumePendingMode() {
    pendingOpportunityMode.value = null;
  }
}
