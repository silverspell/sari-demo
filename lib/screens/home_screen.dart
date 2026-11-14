import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../data/fake_ride_data.dart';
import '../data/nearby_taxi.dart';
import '../data/nearby_taxi_generator.dart';
import '../location/location_service.dart';
import '../map/sari_map.dart';
import '../permissions/location_permission_service.dart';
import '../router/app_routes.dart';
import '../session/location_point.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';
import '../widgets/menu_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.sessionController,
    this.permissionService = const PermissionHandlerLocationPermissionService(),
    this.locationService = const GeolocatorLocationService(),
    this.nearbyTaxiGenerator = const NearbyTaxiGenerator(),
    this.tileProvider,
    this.mapController,
    this.sessionOverride,
    this.initiallyMenuOpen = false,
  });

  static const screenKey = Key('home-screen');
  static const greetingTextKey = Key('home-greeting');
  static const notificationButtonKey = Key('home-notification-button');
  static const avatarButtonKey = Key('home-avatar-button');
  static const menuButtonKey = Key('home-menu-button');
  static const cityBadgeKey = Key('home-city-badge');
  static const etaPillKey = Key('home-eta-pill');
  static const searchButtonKey = Key('home-search-button');
  static const karakoyChipKey = Key('home-karakoy-chip');
  static const homeChipKey = Key('home-home-chip');
  static const workChipKey = Key('home-work-chip');
  static const addChipKey = Key('home-add-chip');
  static const callTaxiButtonKey = Key('home-call-taxi-button');
  static const recenterButtonKey = Key('home-recenter-button');
  static const taxiMarkerLayerKey = Key('home-taxi-marker-layer');
  static const userMarkerLayerKey = Key('home-user-marker-layer');

  static const _maxEtaLabels = 5;

  final SessionController sessionController;
  final LocationPermissionService permissionService;
  final LocationService locationService;
  final NearbyTaxiGenerator nearbyTaxiGenerator;
  final TileProvider? tileProvider;
  final MapController? mapController;
  final Session? sessionOverride;

  /// Golden testlerinde menünün animasyonsuz açık başlaması için.
  final bool initiallyMenuOpen;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final MapController _ownedMapController;
  late final AnimationController _menuController;
  bool _menuOpen = false;
  NearbyTaxis? _cachedTaxis;
  LocationPoint? _cachedCenter;

  @override
  void initState() {
    super.initState();
    _ownedMapController = MapController();
    _menuController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    if (widget.initiallyMenuOpen) {
      _menuOpen = true;
      _menuController.value = 1;
    }
    widget.sessionController.addListener(_handleSessionChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sessionController != widget.sessionController) {
      oldWidget.sessionController.removeListener(_handleSessionChanged);
      widget.sessionController.addListener(_handleSessionChanged);
    }
    if (oldWidget.nearbyTaxiGenerator != widget.nearbyTaxiGenerator) {
      _cachedTaxis = null;
      _cachedCenter = null;
    }
  }

  @override
  void dispose() {
    widget.sessionController.removeListener(_handleSessionChanged);
    _menuController.dispose();
    _ownedMapController.dispose();
    super.dispose();
  }

  MapController get _mapController =>
      widget.mapController ?? _ownedMapController;

  Session? get _session =>
      widget.sessionOverride ?? widget.sessionController.session;

  void _handleSessionChanged() {
    if (!mounted || widget.sessionOverride != null) {
      return;
    }
    setState(() {});
  }

  String get _greetingName {
    final name = _session?.name.trim() ?? '';
    if (name.isEmpty) {
      return 'Yolcu';
    }
    return name.split(RegExp(r'\s+')).first;
  }

  NearbyTaxis _taxisFor(LocationPoint center) {
    final cached = _cachedTaxis;
    if (cached != null && _cachedCenter == center) {
      return cached;
    }
    final generated = widget.nearbyTaxiGenerator.generate(
      areaLabel: FakeRideData.homeAreaLabel,
      center: center,
    );
    _cachedCenter = center;
    _cachedTaxis = generated;
    return generated;
  }

  void _showComingSoon(BuildContext context) {
    showComingSoonSnackBar(context);
  }

  void _openMenu() {
    if (_menuOpen) {
      return;
    }
    setState(() => _menuOpen = true);
    _menuController.forward();
  }

  void _closeMenu() {
    if (!_menuOpen) {
      return;
    }
    _menuController.reverse().whenComplete(() {
      if (mounted) {
        setState(() => _menuOpen = false);
      }
    });
  }

  void _handleMenuNavigation(String route) {
    _closeMenu();
    context.push(route);
  }

  Future<void> _handleMenuLogout() async {
    _closeMenu();
    await widget.sessionController.clear();
  }

  Future<void> _handleRecenter() async {
    try {
      if (_session?.locationPermission != LocationPermissionStatus.granted) {
        final decision = await widget.permissionService.requestPermission();
        if (decision != LocationPermissionDecision.granted) {
          return;
        }
      }

      final location = await widget.locationService.currentLocation();
      if (location == null) {
        return;
      }

      final current = widget.sessionController.session;
      if (current != null) {
        await widget.sessionController.save(
          current.copyWith(
            locationPermission: LocationPermissionStatus.granted,
            location: location,
          ),
        );
      }

      if (!mounted) {
        return;
      }
      _mapController.move(
        LatLng(location.latitude, location.longitude),
        SariMap.defaultZoom,
      );
    } catch (_) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final session = _session;
    final center = session?.location ?? DefaultLocations.modaKadikoy;
    final taxis = _taxisFor(center);

    return Scaffold(
      key: HomeScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(child: _buildMap(theme, center, taxis)),
                      _buildSheet(theme, taxis),
                    ],
                  ),
                  if (_menuOpen)
                    Positioned.fill(
                      child: MenuDrawer(
                        animation: _menuController,
                        session: session,
                        onClose: _closeMenu,
                        onTripHistory: () =>
                            _handleMenuNavigation(AppRoutes.tripHistory),
                        onAccount: () =>
                            _handleMenuNavigation(AppRoutes.account),
                        onPaymentMethods: () =>
                            _handleMenuNavigation(AppRoutes.paymentMethods),
                        onLogout: _handleMenuLogout,
                        onPoints: () => _showComingSoon(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: const Border(bottom: BorderSide(color: SariColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.local_taxi,
                    size: 18,
                    color: SariColors.ink,
                  ),
                ),
                const SizedBox(width: SariSpacing.sm),
                Text('Sarı', maxLines: 1, style: theme.textTheme.headlineSmall),
                const SizedBox(width: SariSpacing.xs),
                Text(
                  '•',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
                const SizedBox(width: SariSpacing.xs),
                Flexible(
                  child: Text(
                    'Taksi Çağır',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            key: HomeScreen.notificationButtonKey,
            onPressed: () => _showComingSoon(context),
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none),
            color: SariColors.ink,
          ),
          const SizedBox(width: SariSpacing.xs),
          InkWell(
            key: HomeScreen.avatarButtonKey,
            customBorder: const CircleBorder(),
            onTap: () => _showComingSoon(context),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 20,
                color: theme.colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(ThemeData theme, LocationPoint center, NearbyTaxis taxis) {
    return Stack(
      children: [
        Positioned.fill(
          child: SariMap(
            center: center,
            tileProvider: widget.tileProvider,
            mapController: _mapController,
            layers: [
              _buildTaxiLayer(theme, taxis),
              _buildUserMarkerLayer(theme, center),
            ],
          ),
        ),
        Positioned(
          top: SariSpacing.md,
          left: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: HomeScreen.menuButtonKey,
            icon: Icons.menu,
            tooltip: 'Menüyü Aç',
            onTap: _openMenu,
          ),
        ),
        Positioned(
          top: SariSpacing.md,
          right: SariSpacing.md,
          child: _CityBadge(
            key: HomeScreen.cityBadgeKey,
            label: taxis.countLabel,
            onTap: () => _showComingSoon(context),
          ),
        ),
        Positioned(
          bottom: SariSpacing.md,
          right: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: HomeScreen.recenterButtonKey,
            icon: Icons.my_location,
            tooltip: 'Konumumu Bul',
            onTap: _handleRecenter,
          ),
        ),
      ],
    );
  }

  Widget _buildTaxiLayer(ThemeData theme, NearbyTaxis taxis) {
    return MarkerLayer(
      key: HomeScreen.taxiMarkerLayerKey,
      markers: [
        for (var index = 0; index < taxis.taxis.length; index++)
          Marker(
            point: LatLng(
              taxis.taxis[index].location.latitude,
              taxis.taxis[index].location.longitude,
            ),
            width: 46,
            height: 60,
            child: _TaxiMarker(
              index: index,
              etaMinutes: index < HomeScreen._maxEtaLabels
                  ? taxis.taxis[index].etaMinutes
                  : null,
              theme: theme,
            ),
          ),
      ],
    );
  }

  Widget _buildUserMarkerLayer(ThemeData theme, LocationPoint center) {
    return MarkerLayer(
      key: HomeScreen.userMarkerLayerKey,
      alignment: Alignment.center,
      markers: [
        Marker(
          point: LatLng(center.latitude, center.longitude),
          width: 150,
          height: 100,
          child: _UserLocationMarker(theme: theme),
        ),
      ],
    );
  }

  Widget _buildSheet(ThemeData theme, NearbyTaxis taxis) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SariRadius.sheet),
        ),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: SariSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Merhaba $_greetingName',
                      key: HomeScreen.greetingTextKey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Günün nasıldı? Nereye gidiyoruz?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              _EtaPill(
                label: taxis.nearestEtaLabel,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSearchBar(theme),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _QuickChip(
                  chipKey: HomeScreen.homeChipKey,
                  theme: theme,
                  icon: Icons.home,
                  label: 'Ev',
                  trailing: '18 dk',
                  onTap: () => _showComingSoon(context),
                ),
                const SizedBox(width: SariSpacing.sm),
                _QuickChip(
                  chipKey: HomeScreen.workChipKey,
                  theme: theme,
                  icon: Icons.work,
                  label: 'İş',
                  trailing: 'Levent',
                  onTap: () => _showComingSoon(context),
                ),
                const SizedBox(width: SariSpacing.sm),
                _AddChip(theme: theme, onTap: () => _showComingSoon(context)),
              ],
            ),
          ),
          const SizedBox(height: SariSpacing.md),
          _buildCallTaxiButton(theme),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: HomeScreen.searchButtonKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: () => context.push(AppRoutes.destination),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              const Icon(Icons.search, size: 22, color: SariColors.ink),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nereye?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Material(
                color: theme.colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(SariRadius.badge),
                child: InkWell(
                  key: HomeScreen.karakoyChipKey,
                  borderRadius: BorderRadius.circular(SariRadius.badge),
                  onTap: () => _showComingSoon(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SariSpacing.sm,
                      vertical: SariSpacing.xs,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 14,
                          color: SariColors.ink,
                        ),
                        const SizedBox(width: SariSpacing.xs),
                        Text('Karaköy', style: theme.textTheme.labelSmall),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallTaxiButton(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: HomeScreen.callTaxiButtonKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: () => context.push(AppRoutes.destination),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: SariColors.ink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 20,
                  color: SariColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Taksi çağır',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: SariColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: SariSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: SariColors.ink.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SARI',
                      style: sariPlateStyle.copyWith(
                        color: SariColors.ink,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    const Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: SariColors.ink,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapIconButton extends StatelessWidget {
  const _MapIconButton({
    required this.buttonKey,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final Key buttonKey;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          key: buttonKey,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 24, color: SariColors.ink),
          ),
        ),
      ),
    );
  }
}

class _CityBadge extends StatelessWidget {
  const _CityBadge({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.94),
      borderRadius: BorderRadius.circular(999),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtaPill extends StatelessWidget {
  const _EtaPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: HomeScreen.etaPillKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 16, color: theme.colorScheme.primary),
              const SizedBox(width: SariSpacing.xs),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.chipKey,
    required this.theme,
    required this.icon,
    required this.label,
    required this.trailing,
    required this.onTap,
  });

  final Key chipKey;
  final ThemeData theme;
  final IconData icon;
  final String label;
  final String trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.secondaryContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: chipKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: SariSpacing.md),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: SariColors.ink),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.labelMedium),
              const SizedBox(width: 6),
              Text(
                trailing,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  const _AddChip({required this.theme, required this.onTap});

  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        key: HomeScreen.addChipKey,
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add, size: 18, color: SariColors.textSecondary),
              const SizedBox(width: SariSpacing.xs),
              Text(
                'Ekle',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaxiMarker extends StatelessWidget {
  const _TaxiMarker({
    required this.index,
    required this.etaMinutes,
    required this.theme,
  });

  final int index;
  final int? etaMinutes;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final angle = ((index * 43) % 360 - 180) * math.pi / 180;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Transform.rotate(
          angle: angle,
          child: Container(
            width: 20,
            height: 32,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: SariColors.yellow,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: SariColors.ink.withValues(alpha: 0.3)),
              boxShadow: [
                BoxShadow(
                  color: SariColors.ink.withValues(alpha: 0.18),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: SariColors.ink,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(height: 2),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: SariColors.ink.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(1),
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 3,
                        color: SariColors.yellow,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: SariColors.ink,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (etaMinutes != null) ...[
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: theme.colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$etaMinutes dk',
              style: sariPlateStyle.copyWith(
                color: theme.colorScheme.onInverseSurface,
                fontSize: 9,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _UserLocationMarker extends StatelessWidget {
  const _UserLocationMarker({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'Buradasınız',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onInverseSurface,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: SariSpacing.xs),
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: SariColors.userLocation.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: SariColors.userLocation.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SariColors.ink.withValues(alpha: 0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: SariColors.userLocation,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
