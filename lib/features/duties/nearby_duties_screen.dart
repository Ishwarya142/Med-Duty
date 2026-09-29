// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/l10n/app_localizations.dart';
import '../../models/application_model.dart';
import '../../models/duty_with_distance.dart';
import '../../providers/duty_provider.dart';
import '../../providers/job_provider.dart';
import '../../providers/location_provider.dart';
import '../notifications/notification_screen.dart';
import '../jobs/jobs_bootstrap.dart';
import '../jobs/jobs_screen.dart';
import '../../core/utils/duties_navigation.dart';
import 'discovery_helpers.dart';
import 'nearby_duties_map_screen.dart';
import 'widgets/duty_discovery_card.dart';
import 'widgets/duty_discovery_filters_sheet.dart';
import 'widgets/location_selector_sheet.dart';

const _cTeal   = Color(0xFF0F766E);
const _cRed    = Color(0xFFEF4444);
const _cGreen  = Color(0xFF16A34A);

enum DutySortOption {
  nearest,
  highestPay,
  earliest,
}

class NearbyDutiesScreen extends StatefulWidget {
  const NearbyDutiesScreen({super.key});

  @override
  State<NearbyDutiesScreen> createState() => _NearbyDutiesScreenState();
}

class _NearbyDutiesScreenState extends State<NearbyDutiesScreen> {
  int _selectedTab = 0;
  int _opportunityMode = 0; // 0 = Duties, 1 = Jobs
  bool _isSearching = false;
  String _searchQuery = '';
  DutySortOption _sortOption = DutySortOption.nearest;
  final TextEditingController _searchCtrl = TextEditingController();
  LocationProvider? _locationProvider;

  @override
  void initState() {
    super.initState();
    DutiesNavigation.instance.pendingOpportunityMode.addListener(_onNavRequest);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending = DutiesNavigation.instance.pendingOpportunityMode.value;
      if (pending != null && mounted) {
        setState(() => _opportunityMode = pending);
        DutiesNavigation.instance.consumePendingMode();
      }
      await bootstrapJobDiscovery(context);
      if (!mounted) return;
      _locationProvider = context.read<LocationProvider>();
      _locationProvider!.addListener(_onLocationChanged);
    });
  }

  void _onNavRequest() {
    final mode = DutiesNavigation.instance.pendingOpportunityMode.value;
    if (mode == null || !mounted) return;
    setState(() => _opportunityMode = mode);
    DutiesNavigation.instance.consumePendingMode();
  }

  void _onLocationChanged() {
    if (!mounted) return;
    final loc = context.read<LocationProvider>();
    context.read<DutyProvider>().refreshDiscoveryForLocation(loc);
    context.read<JobProvider>().refreshForLocation(loc);
    setState(() {});
  }

  @override
  void dispose() {
    DutiesNavigation.instance.pendingOpportunityMode.removeListener(_onNavRequest);
    _locationProvider?.removeListener(_onLocationChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  List<DutyWithDistance> _tabItems(
    DutyProvider duties,
    LocationProvider location,
  ) {
    List<DutyWithDistance> list;
    switch (_selectedTab) {
      case 0:
        list = filterDiscoveryList(duties.nearbyDuties, _searchQuery);
        break;
      case 1:
        list = withDistancesFromLocation(
          duties.completedDuties
              .map((d) => DutyWithDistance(duty: d))
              .toList(),
          location,
        );
        break;
      case 2:
        list = withDistancesFromLocation(
          duties.upcomingDuties
              .map((d) => DutyWithDistance(duty: d))
              .toList(),
          location,
        );
        break;
      case 3:
        list = filterDiscoveryList(
          duties.appliedDutiesNearby(location),
          _searchQuery,
        );
        break;
      case 4:
        list = filterDiscoveryList(
          duties.savedDutiesNearby(location),
          _searchQuery,
        );
        break;
      default:
        list = [];
    }

    // Apply Sorting
    switch (_sortOption) {
      case DutySortOption.highestPay:
        list.sort((a, b) => b.duty.salary.compareTo(a.duty.salary));
        break;
      case DutySortOption.earliest:
        list.sort((a, b) => a.duty.dutyDate.compareTo(b.duty.dutyDate));
        break;
      case DutySortOption.nearest:
        list.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
        break;
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final card = isDark ? const Color(0xFF1E293B) : Colors.white;
    final border = isDark ? const Color(0xFF334155) : const Color(0xFFE8EDF2);
    final tx = isDark ? Colors.white : const Color(0xFF0F172A);
    final sub = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final duties = context.watch<DutyProvider>();
    final location = context.watch<LocationProvider>();
    final l10n = context.l10n;
    final items = _tabItems(duties, location);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 64,
        title: _isSearching
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: TextStyle(color: tx),
                decoration: InputDecoration(
                  hintText: l10n.searchDuties,
                  hintStyle: TextStyle(color: sub),
                  border: InputBorder.none,
                ),
              )
            : Text(
                _opportunityMode == 0 ? l10n.duties : l10n.jobs,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: tx,
                  letterSpacing: -0.5,
                ),
              ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: Icon(Icons.close, color: tx),
              onPressed: () => setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchCtrl.clear();
              }),
            )
          else ...[
            IconButton(
              icon: Icon(Icons.search_rounded, color: tx, size: 24),
              onPressed: () => setState(() => _isSearching = true),
            ),
            IconButton(
              icon: Icon(Icons.tune_rounded, color: tx, size: 24),
              onPressed: () async {
                await showDutyDiscoveryFiltersSheet(context);
                if (!mounted) return;
                await duties.refreshDiscoveryForLocation(location);
                setState(() {});
              },
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(Icons.notifications_none_rounded, color: tx, size: 25),
                    Positioned(
                      right: -1,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: _cRed,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: const Center(
                          child: Text(
                            '3',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _opportunityModeToggle(card, border, tx, sub),
          Expanded(
            child: _opportunityMode == 1
                ? const JobsScreen(embedded: true)
                : _buildDutiesBody(bg, tx, sub, card, border, isDark, duties, location, items),
          ),
        ],
      ),
    );
  }

  Widget _buildDutiesBody(
    Color bg,
    Color tx,
    Color sub,
    Color card,
    Color border,
    bool isDark,
    DutyProvider duties,
    LocationProvider location,
    List<DutyWithDistance> items,
  ) {
    final l10n = context.l10n;
    final tabs = [
      (l10n.nearby, duties.nearbyDuties.length),
      (l10n.completed, duties.completedDutiesCount),
      (l10n.upcoming, duties.upcomingDutiesCount),
      (l10n.applied, duties.applications
          .where(
            (a) =>
                a.status != ApplicationStatus.withdrawn &&
                a.status != ApplicationStatus.rejected,
          )
          .length),
      (l10n.saved, duties.savedDutiesCount),
    ];

    return CustomScrollView(
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        // 1. Top Section (Offline Banner + Location & Map Card)
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Offline Banner with Retry
              if (duties.isOffline)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF2D1515) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cRed.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: _cRed, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "You're offline — showing cached results.",
                          style: TextStyle(color: tx, fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await duties.refreshDiscoveryForLocation(location);
                          setState(() {});
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 14, color: _cRed),
                        label: const Text('Retry', style: TextStyle(fontSize: 12, color: _cRed)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _cRed.withValues(alpha: 0.3)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ],
                  ),
                ),

              // Location + Map Preview Card
              _buildLocationMapCard(card, border, tx, sub, isDark, location, duties),
            ],
          ),
        ),

        // 2. Pinned Sticky Filter Tabs
        SliverPersistentHeader(
          pinned: true,
          delegate: _DutiesTabBarDelegate(
            bg: bg,
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                itemCount: tabs.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = _selectedTab == i;
                  final count = tabs[i].$2;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedTab = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? _cTeal : card,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: selected ? _cTeal : border,
                          width: 1,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: _cTeal.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tabs[i].$1,
                            style: TextStyle(
                              color: selected ? Colors.white : tx,
                              fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: selected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : _cTeal.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  color: selected ? Colors.white : _cTeal,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        // 3. Tab Content Slivers
        if (duties.discoveryLoading && _selectedTab == 0)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: _cTeal),
                  const SizedBox(height: 12),
                  Text('Finding duties near you...', style: TextStyle(color: sub)),
                ],
              ),
            ),
          )
        else if (_selectedTab == 0)
          ..._buildNearbySlivers(tx, sub, card, border, isDark, location, duties, items)
        else if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _emptyState(tx, sub, location, duties),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) {
                  final item = items[i];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DutyDiscoveryCard(
                      item: item,
                      isApplied: duties.isDutyApplied(item.duty.id),
                      isSaved: duties.isDutySaved(item.duty.id),
                      onTap: () => openDiscoveryDutyDetails(context, item),
                      onApply: () => applyDiscoveryDuty(context, item),
                      onSave: () => toggleDiscoverySave(context, item),
                    ),
                  );
                },
                childCount: items.length,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildNearbySlivers(
    Color tx,
    Color sub,
    Color card,
    Color border,
    bool isDark,
    LocationProvider location,
    DutyProvider duties,
    List<DutyWithDistance> items,
  ) {
    final regularItems = filterDiscoveryList(
      duties.regularNearby(location),
      _searchQuery,
    );
    final emergencyItems = duties.emergencyNearby(location);

    // Apply sorting to regular items
    switch (_sortOption) {
      case DutySortOption.highestPay:
        regularItems.sort((a, b) => b.duty.salary.compareTo(a.duty.salary));
        break;
      case DutySortOption.earliest:
        regularItems.sort((a, b) => a.duty.dutyDate.compareTo(b.duty.dutyDate));
        break;
      case DutySortOption.nearest:
        regularItems.sort((a, b) => (a.distanceKm ?? 999).compareTo(b.distanceKm ?? 999));
        break;
    }

    final displayItems = [
      ...emergencyItems,
      ...regularItems,
    ];

    return [
      // Section Subheader: "Nearby Duties" + "Sort by: Nearest ▾"
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nearby Duties',
                    style: TextStyle(
                      color: tx,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Duties available near your location',
                    style: TextStyle(color: sub, fontSize: 12),
                  ),
                ],
              ),
              // Sort dropdown button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<DutySortOption>(
                    value: _sortOption,
                    isDense: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: tx),
                    style: TextStyle(color: tx, fontSize: 12, fontWeight: FontWeight.bold),
                    items: const [
                      DropdownMenuItem(
                        value: DutySortOption.nearest,
                        child: Text('Sort by  Nearest'),
                      ),
                      DropdownMenuItem(
                        value: DutySortOption.highestPay,
                        child: Text('Sort by  Highest Pay'),
                      ),
                      DropdownMenuItem(
                        value: DutySortOption.earliest,
                        child: Text('Sort by  Earliest'),
                      ),
                    ],
                    onChanged: (opt) {
                      if (opt != null) setState(() => _sortOption = opt);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Empty State if no duties
      if (displayItems.isEmpty)
        SliverFillRemaining(
          hasScrollBody: false,
          child: _emptyState(tx, sub, location, duties),
        )
      else ...[
        // Duty Cards List
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (ctx, i) {
                final item = displayItems[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DutyDiscoveryCard(
                    item: item,
                    isApplied: duties.isDutyApplied(item.duty.id),
                    isSaved: duties.isDutySaved(item.duty.id),
                    onTap: () => openDiscoveryDutyDetails(context, item),
                    onApply: () => applyDiscoveryDuty(context, item),
                    onSave: () => toggleDiscoverySave(context, item),
                  ),
                );
              },
              childCount: displayItems.length,
            ),
          ),
        ),

        // Expand Your Search Banner at the bottom
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? _cTeal.withValues(alpha: 0.12) : const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _cGreen.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _cGreen.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lightbulb_outline_rounded, color: _cGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expand your search',
                          style: TextStyle(
                            color: tx,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'No more duties within ${location.radiusKm.toStringAsFixed(0)} km. Try expanding your radius.',
                          style: TextStyle(color: sub, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  OutlinedButton.icon(
                    onPressed: () async {
                      location.setRadiusKm(25);
                      await duties.refreshDiscoveryForLocation(location);
                      setState(() {});
                    },
                    icon: const Text('Expand to 25 km', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                    label: const Icon(Icons.chevron_right_rounded, size: 16),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _cTeal,
                      side: BorderSide(color: _cTeal.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ];
  }

  // ─── SEGMENTED SWITCHER: [Duties] [Jobs] ─────────────────────────────────
  Widget _opportunityModeToggle(
    Color card,
    Color border,
    Color tx,
    Color sub,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _opportunityMode = 0);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _opportunityMode == 0 ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: _opportunityMode == 0
                        ? [
                            BoxShadow(
                              color: _cTeal.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medical_services_rounded,
                        size: 17,
                        color: _opportunityMode == 0 ? Colors.white : sub,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.duties,
                        style: TextStyle(
                          color: _opportunityMode == 0 ? Colors.white : sub,
                          fontWeight: _opportunityMode == 0 ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _opportunityMode = 1);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: _opportunityMode == 1 ? _cTeal : Colors.transparent,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: _opportunityMode == 1
                        ? [
                            BoxShadow(
                              color: _cTeal.withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.work_rounded,
                        size: 17,
                        color: _opportunityMode == 1 ? Colors.white : sub,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        context.l10n.jobs,
                        style: TextStyle(
                          color: _opportunityMode == 1 ? Colors.white : sub,
                          fontWeight: _opportunityMode == 1 ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LOCATION / MAP PREVIEW CARD ──────────────────────────────────────────
  Widget _buildLocationMapCard(
    Color card,
    Color border,
    Color tx,
    Color sub,
    bool isDark,
    LocationProvider location,
    DutyProvider duties,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Location Info on Left + Mini Map Vector Preview on Right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Pin in circle container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _cTeal.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.location_on_rounded, color: _cTeal, size: 24),
                ),
              ),
              const SizedBox(width: 12),
              // Location Labels
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    await showLocationSelectorSheet(context);
                    if (!mounted) return;
                    await duties.refreshDiscoveryForLocation(
                      context.read<LocationProvider>(),
                    );
                    setState(() {});
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              location.locationLabel.isNotEmpty
                                  ? location.locationLabel
                                  : 'Avadi, Chennai',
                              style: TextStyle(
                                color: tx,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: _cTeal, size: 20),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded, size: 13, color: sub),
                          const SizedBox(width: 3),
                          Text(
                            'Within ${location.radiusKm.toStringAsFixed(0)} km',
                            style: TextStyle(color: sub, fontSize: 12.5),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Right: Mini Map Graphic Preview
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 90,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E3A37) : const Color(0xFFE2F4F2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: CustomPaint(
                    painter: _MiniMapPainter(isDark: isDark),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bottom Actions: [ Radius ] and [ View Map ]
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final r = await showRadiusSelectorSheet(
                      context,
                      location.radiusKm,
                    );
                    if (r != null && mounted) {
                      location.setRadiusKm(r);
                      await duties.refreshDiscoveryForLocation(location);
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.radar_rounded, size: 17, color: _cTeal),
                  label: const Text('Radius', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _cTeal,
                    side: BorderSide(color: border),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NearbyDutiesMapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_rounded, size: 17, color: Colors.white),
                  label: const Text('View Map', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                  style: FilledButton.styleFrom(
                    backgroundColor: _cTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyState(
    Color tx,
    Color sub,
    LocationProvider location,
    DutyProvider duties,
  ) {
    final messages = [
      (
        'No duties found within ${location.radiusKm.toStringAsFixed(0)} km',
        'Try expanding your radius or choosing a different location.',
        'Expand to 25 km',
        () async {
          location.setRadiusKm(25);
          await duties.refreshDiscoveryForLocation(location);
          setState(() {});
        },
      ),
      ('No completed duties', 'Your completed duties will appear here.', null, null),
      ('No upcoming duties', 'Accepted duties will appear here.', null, null),
      ('No applied duties', 'Apply for duties to see them here.', 'Browse nearby', () => setState(() => _selectedTab = 0)),
      ('No saved duties', 'Save duties to view them later.', 'Browse nearby', () => setState(() => _selectedTab = 0)),
    ];
    final m = messages[_selectedTab.clamp(0, messages.length - 1)];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: sub),
            const SizedBox(height: 12),
            Text(
              m.$1,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tx,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              m.$2,
              textAlign: TextAlign.center,
              style: TextStyle(color: sub, fontSize: 13),
            ),
            if (m.$3 != null && m.$4 != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: m.$4,
                style: FilledButton.styleFrom(
                  backgroundColor: _cTeal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
                child: Text(m.$3!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── SLIVER DELEGATE FOR STICKY TAB BAR ──────────────────────────────────────
class _DutiesTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final Color bg;

  const _DutiesTabBarDelegate({
    required this.child,
    required this.bg,
  });

  @override
  double get minExtent => 52.0;

  @override
  double get maxExtent => 52.0;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: bg,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _DutiesTabBarDelegate oldDelegate) {
    return oldDelegate.bg != bg || oldDelegate.child != child;
  }
}

// ─── MINI MAP VECTOR PAINTER ────────────────────────────────────────────────
class _MiniMapPainter extends CustomPainter {
  final bool isDark;
  _MiniMapPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = isDark ? const Color(0xFF2C4A47) : Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Roads
    final path = Path()
      ..moveTo(0, size.height * 0.4)
      ..lineTo(size.width, size.height * 0.4)
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.5, size.height)
      ..moveTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.8, 0);

    canvas.drawPath(path, roadPaint);

    // User Location Ripple Dot
    final userRipple = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    final userDot = Paint()
      ..color = const Color(0xFF2563EB)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.45), 10, userRipple);
    canvas.drawCircle(Offset(size.width * 0.52, size.height * 0.45), 4, userDot);

    // Hospital Green Map Pins
    final pinPaint = Paint()..color = const Color(0xFF0F766E);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.3), 3.5, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.3), 3.5, pinPaint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.7), 3.5, pinPaint);
  }

  @override
  bool shouldRepaint(covariant _MiniMapPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
