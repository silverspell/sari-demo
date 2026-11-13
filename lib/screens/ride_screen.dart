import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../data/fake_place.dart';
import '../data/fake_ride_data.dart';
import '../data/fake_route_path.dart';
import '../data/route_fare_calculator.dart';
import '../data/route_quote.dart';
import '../map/sari_map.dart';
import '../rides/ride_flow_controller.dart';
import '../rides/ride_simulation.dart';
import '../router/app_routes.dart';
import '../session/location_point.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';

class RideScreen extends StatefulWidget {
  const RideScreen({
    super.key,
    this.flowController,
    this.tileProvider,
    this.mapController,
    this.rideDuration = defaultRideDuration,
    this.seed = FakeRideData.rideSeed,
    this.animationsEnabled = true,
    this.animationFrame = 0.0,
  });

  static const defaultRideDuration = Duration(seconds: 12);
  static const screenKey = Key('ride-screen');
  static const backButtonKey = Key('ride-back-button');
  static const mapKey = Key('ride-map');
  static const routePolylineLayerKey = Key('ride-route-polyline-layer');
  static const taxiMarkerLayerKey = Key('ride-taxi-marker-layer');
  static const destinationMarkerLayerKey = Key('ride-destination-marker-layer');
  static const bannerKey = Key('ride-banner');
  static const bannerTitleKey = Key('ride-banner-title');
  static const bannerSubtitleKey = Key('ride-banner-subtitle');
  static const speedPillKey = Key('ride-speed-pill');
  static const focusButtonKey = Key('ride-focus-button');
  static const summaryKey = Key('ride-summary');
  static const etaHeadingKey = Key('ride-eta-heading');
  static const etaSubtitleKey = Key('ride-eta-subtitle');
  static const progressBarKey = Key('ride-progress-bar');
  static const driverCardKey = Key('ride-driver-card');
  static const callButtonKey = Key('ride-call-button');
  static const shareButtonKey = Key('ride-share-button');
  static const safetyCardKey = Key('ride-safety-card');
  static const detailsButtonKey = Key('ride-details-button');
  static const shareJourneyButtonKey = Key('ride-share-journey-button');
  static const sosButtonKey = Key('ride-sos-button');

  final RideFlowController? flowController;
  final TileProvider? tileProvider;
  final MapController? mapController;
  final Duration rideDuration;
  final int seed;
  final bool animationsEnabled;
  final double animationFrame;

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen>
    with SingleTickerProviderStateMixin {
  late final RideFlowController _ownedFlowController;
  late final MapController _ownedMapController;
  late final AnimationController _rideController;
  late final RideSimulation _simulation;

  bool _mapReady = false;

  RideFlowController get _flow => widget.flowController ?? _ownedFlowController;

  MapController get _mapController =>
      widget.mapController ?? _ownedMapController;

  FakePlace get _destination => _flow.destination ?? FakeRideData.kadikoyIskele;

  RouteQuote get _quote {
    final quote = _flow.quote;
    if (quote != null) {
      return quote;
    }
    return const RouteFareCalculator().quote(
      origin: _flow.origin,
      destination: _destination,
    );
  }

  List<LocationPoint> get _routePoints => FakeRoutePath.between(
    origin: _flow.origin,
    destination: _destination.location,
  );

  @override
  void initState() {
    super.initState();
    _ownedFlowController = RideFlowController();
    _ownedMapController = MapController();
    _ensureDestination();
    _rideController = AnimationController(
      vsync: this,
      duration: widget.rideDuration,
    );
    if (widget.animationsEnabled) {
      _rideController.forward();
    } else {
      _rideController.value = widget.animationFrame.clamp(0.0, 1.0).toDouble();
    }
    _simulation = RideSimulation(
      routePoints: _routePoints,
      quote: _quote,
      seed: widget.seed,
    );
  }

  @override
  void dispose() {
    _rideController.dispose();
    _ownedMapController.dispose();
    _ownedFlowController.dispose();
    super.dispose();
  }

  void _ensureDestination() {
    if (_flow.destination == null) {
      _flow.selectDestination(FakeRideData.kadikoyIskele);
    }
  }

  void _handleMapReady() {
    _mapReady = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _fitRoute();
    });
  }

  void _fitRoute() {
    if (!_mapReady) {
      return;
    }
    final points = _simulation.routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(
          SariSpacing.lg,
          96,
          SariSpacing.lg,
          SariSpacing.lg,
        ),
        maxZoom: 16,
      ),
    );
  }

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.maybeOf(context)?.maybePop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: RideScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(theme),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _rideController,
                    builder: (context, child) {
                      final sample = _simulation.sampleAt(
                        _rideController.value,
                      );
                      return _buildMap(theme, sample);
                    },
                  ),
                ),
                AnimatedBuilder(
                  animation: _rideController,
                  builder: (context, child) {
                    final sample = _simulation.sampleAt(_rideController.value);
                    return _buildSheet(
                      theme,
                      sample,
                      constraints.maxHeight * 0.62,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: SariSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: const Border(bottom: BorderSide(color: SariColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            key: RideScreen.backButtonKey,
            onPressed: _handleBack,
            tooltip: 'Geri',
            icon: const Icon(Icons.arrow_back),
            color: SariColors.ink,
          ),
          const SizedBox(width: SariSpacing.xs),
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
          Text('Sarı', maxLines: 1, style: theme.textTheme.labelLarge),
          const SizedBox(width: SariSpacing.xs),
          Text(
            '•',
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
          const SizedBox(width: SariSpacing.xs),
          Expanded(
            child: Text(
              'Yolculuk Başladı',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          const Icon(Icons.emergency, size: 20, color: SariColors.critical),
          const SizedBox(width: SariSpacing.sm),
          Container(
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
        ],
      ),
    );
  }

  Widget _buildMap(ThemeData theme, RideSample sample) {
    final routePoints = _simulation.routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: RideScreen.mapKey,
            child: SariMap(
              center: _flow.origin,
              zoom: 14.0,
              tileProvider: widget.tileProvider,
              mapController: _mapController,
              onMapReady: _handleMapReady,
              layers: [
                PolylineLayer(
                  key: RideScreen.routePolylineLayerKey,
                  polylines: [
                    Polyline(
                      points: routePoints,
                      strokeWidth: 4.5,
                      color: theme.colorScheme.primaryContainer,
                      borderStrokeWidth: 3,
                      borderColor: SariColors.ink,
                    ),
                  ],
                ),
                MarkerLayer(
                  key: RideScreen.destinationMarkerLayerKey,
                  markers: [
                    Marker(
                      point: LatLng(
                        _destination.location.latitude,
                        _destination.location.longitude,
                      ),
                      width: 48,
                      height: 48,
                      child: _DestinationMarker(theme: theme),
                    ),
                  ],
                ),
                MarkerLayer(
                  key: RideScreen.taxiMarkerLayerKey,
                  markers: [
                    Marker(
                      point: LatLng(
                        sample.position.latitude,
                        sample.position.longitude,
                      ),
                      width: 130,
                      height: 90,
                      child: _TaxiMarker(
                        theme: theme,
                        plate: FakeRideData.driver.plate,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: SariSpacing.md,
          left: SariSpacing.md,
          right: SariSpacing.md,
          child: _buildBanner(theme, sample),
        ),
        Positioned(
          bottom: SariSpacing.md,
          left: SariSpacing.md,
          child: _buildSpeedPill(theme),
        ),
        Positioned(
          bottom: SariSpacing.md,
          right: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: RideScreen.focusButtonKey,
            icon: Icons.my_location,
            tooltip: 'Haritayı Ortala',
            onTap: _fitRoute,
          ),
        ),
      ],
    );
  }

  Widget _buildBanner(ThemeData theme, RideSample sample) {
    return Container(
      key: RideScreen.bannerKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(SariRadius.button),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              Icons.turn_right,
              size: 20,
              color: SariColors.ink,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${FakeRideData.dativeName(_destination)} gidiyorsun',
                  key: RideScreen.bannerTitleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onInverseSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sample.maneuverLabel,
                  key: RideScreen.bannerSubtitleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onInverseSurface.withValues(
                      alpha: 0.72,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SariSpacing.xs),
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiaryContainer,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedPill(ThemeData theme) {
    return Container(
      key: RideScreen.speedPillKey,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(SariRadius.badge),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
          Text(
            FakeRideData.rideSpeedLabel,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(ThemeData theme, RideSample sample, double maxHeight) {
    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(SariRadius.sheet),
        ),
        border: const Border(top: BorderSide(color: SariColors.border)),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
            _buildSummary(theme, sample),
            const SizedBox(height: 12),
            _buildProgress(theme, sample),
            const SizedBox(height: SariSpacing.md),
            _buildDriverCard(theme),
            const SizedBox(height: SariSpacing.md),
            _buildSafetyCard(theme),
            const SizedBox(height: SariSpacing.md),
            _buildShareJourney(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme, RideSample sample) {
    return Row(
      key: RideScreen.summaryKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: SariSpacing.sm,
                runSpacing: SariSpacing.xs,
                children: [
                  Text(
                    'Varışa ${sample.remainingMinutes} dk',
                    key: RideScreen.etaHeadingKey,
                    maxLines: 1,
                    style: theme.textTheme.headlineLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Canlı',
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Tahmini varış: ${sample.etaLabel} · '
                'Kalan ${sample.remainingDistanceLabel}',
                key: RideScreen.etaSubtitleKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SariSpacing.sm),
        _SosButton(onTap: _showComingSoon),
      ],
    );
  }

  Widget _buildProgress(ThemeData theme, RideSample sample) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        key: RideScreen.progressBarKey,
        value: sample.progress,
        minHeight: 8,
        backgroundColor: theme.colorScheme.surfaceContainer,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
    final driver = FakeRideData.driver;
    final rating = driver.rating.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      key: RideScreen.driverCardKey,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
      ),
      child: Row(
        children: [
          _DriverAvatar(theme: theme),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      rating,
                      maxLines: 1,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(SariRadius.badge),
                      ),
                      child: Text(
                        driver.plate,
                        maxLines: 1,
                        style: sariPlateStyle.copyWith(color: SariColors.ink),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Sarı ${driver.vehicle}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SariColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RoundIconButton(
                buttonKey: RideScreen.callButtonKey,
                icon: Icons.call,
                tooltip: 'Sürücüyü Ara',
                onTap: _showComingSoon,
              ),
              const SizedBox(width: 6),
              _RoundIconButton(
                buttonKey: RideScreen.shareButtonKey,
                icon: Icons.ios_share,
                tooltip: 'Yolculuğu Paylaş',
                onTap: _showComingSoon,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyCard(ThemeData theme) {
    return Container(
      key: RideScreen.safetyCardKey,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
        border: Border.all(color: SariColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              size: 16,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Sürüş Koruması Aktif',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Canlı GPS takibi 7/24 merkezde izleniyor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: RideScreen.detailsButtonKey,
              borderRadius: BorderRadius.circular(SariRadius.badge),
              onTap: _showComingSoon,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                child: Text(
                  'Detay',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareJourney(ThemeData theme) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: RideScreen.shareJourneyButtonKey,
          borderRadius: BorderRadius.circular(SariRadius.badge),
          onTap: _showComingSoon,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.share_location,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Yolculuğu sevdiklerinle paylaş',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SosButton extends StatelessWidget {
  const _SosButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: 'Acil Yardım',
      child: Material(
        color: theme.colorScheme.errorContainer,
        shape: const CircleBorder(),
        child: InkWell(
          key: RideScreen.sosButtonKey,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              Icons.shield,
              size: 20,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
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
        child: InkWell(
          key: buttonKey,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: SariColors.ink),
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
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
        shape: const CircleBorder(),
        elevation: 3,
        child: InkWell(
          key: buttonKey,
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: 22, color: SariColors.ink),
          ),
        ),
      ),
    );
  }
}

class _DriverAvatar extends StatelessWidget {
  const _DriverAvatar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.inverseSurface,
              shape: BoxShape.circle,
            ),
            child: Text(
              'MY',
              maxLines: 1,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 18,
              height: 18,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.surfaceContainerLow,
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.star, size: 11, color: SariColors.ink),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaxiMarker extends StatelessWidget {
  const _TaxiMarker({required this.theme, required this.plate});

  final ThemeData theme;
  final String plate;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.local_taxi, size: 24, color: SariColors.ink),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(SariRadius.badge),
          ),
          child: Text(
            plate,
            maxLines: 1,
            style: sariPlateStyle.copyWith(
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 34,
        height: 34,
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
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.flag,
            size: 14,
            color: theme.colorScheme.onInverseSurface,
          ),
        ),
      ),
    );
  }
}
