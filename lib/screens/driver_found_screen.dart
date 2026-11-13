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
import '../router/app_routes.dart';
import '../session/location_point.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';

class DriverFoundScreen extends StatefulWidget {
  const DriverFoundScreen({
    super.key,
    this.flowController,
    this.tileProvider,
    this.mapController,
    this.arrivalDuration = defaultArrivalDuration,
    this.animationsEnabled = true,
    this.animationFrame = 0.0,
    this.onArrivalComplete,
  });

  static const defaultArrivalDuration = Duration(seconds: 5);
  static const screenKey = Key('driver-found-screen');
  static const backButtonKey = Key('driver-found-back-button');
  static const mapKey = Key('driver-found-map');
  static const statusPillKey = Key('driver-found-status-pill');
  static const headingKey = Key('driver-found-heading');
  static const headingTextKey = headingKey;
  static const subtitleKey = Key('driver-found-subtitle');
  static const progressKey = Key('driver-found-progress');
  static const arrivalProgressKey = progressKey;
  static const driverCardKey = Key('driver-found-driver-card');
  static const fareTextKey = Key('driver-found-fare-text');
  static const callButtonKey = Key('driver-found-call-button');
  static const messageButtonKey = Key('driver-found-message-button');
  static const shareButtonKey = Key('driver-found-share-button');
  static const cancelButtonKey = Key('driver-found-cancel-button');
  static const focusButtonKey = Key('driver-found-focus-button');
  static const polylineLayerKey = Key('driver-found-polyline-layer');
  static const driverMarkerLayerKey = Key('driver-found-driver-marker-layer');
  static const pickupMarkerLayerKey = Key('driver-found-pickup-marker-layer');
  static const statusChipKey = statusPillKey;
  static const arrivalHeadingKey = headingKey;
  static const progressBarKey = progressKey;
  static const cancelRideButtonKey = cancelButtonKey;
  static const messageSendButtonKey = messageButtonKey;
  static const shareRideButtonKey = shareButtonKey;
  static const approachPolylineLayerKey = polylineLayerKey;
  static const driverLayerKey = driverMarkerLayerKey;
  static const pickupLayerKey = pickupMarkerLayerKey;

  final RideFlowController? flowController;
  final TileProvider? tileProvider;
  final MapController? mapController;
  final Duration arrivalDuration;
  final bool animationsEnabled;
  final double animationFrame;
  final VoidCallback? onArrivalComplete;

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen>
    with SingleTickerProviderStateMixin {
  late final RideFlowController _ownedFlowController;
  late final MapController _ownedMapController;
  late final AnimationController _arrivalController;

  bool _mapReady = false;
  bool _arrivalNotified = false;

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

  List<LocationPoint> get _approachPoints => FakeRoutePath.between(
    origin: FakeRideData.driverApproachOrigin,
    destination: _flow.origin,
  );

  int get _arrivalMinutes {
    final minutes = (FakeRideData.driverApproachDistanceMeters / 1000 / 18 * 60)
        .round();
    return minutes < 1 ? 1 : minutes;
  }

  @override
  void initState() {
    super.initState();
    _ownedFlowController = RideFlowController();
    _ownedMapController = MapController();
    _arrivalController = AnimationController(
      vsync: this,
      duration: widget.arrivalDuration,
    );
    if (widget.animationsEnabled) {
      _arrivalController.forward();
    } else {
      _arrivalController.value = widget.animationFrame
          .clamp(0.0, 1.0)
          .toDouble();
    }
    _arrivalController.addStatusListener(_handleArrivalStatus);
    _ensureDestination();
  }

  @override
  void dispose() {
    _arrivalController.removeStatusListener(_handleArrivalStatus);
    _arrivalController.dispose();
    _ownedMapController.dispose();
    _ownedFlowController.dispose();
    super.dispose();
  }

  void _handleArrivalStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _arrivalNotified) {
      return;
    }
    _arrivalNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onArrivalComplete?.call();
    });
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
    final points = _approachPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.fromLTRB(
          SariSpacing.lg,
          104,
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
      context.go(AppRoutes.routeFare);
    }
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = _quote;

    return Scaffold(
      key: DriverFoundScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(theme),
                Expanded(child: _buildMap(theme)),
                _buildSheet(theme, quote, constraints.maxHeight * 0.66),
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
            key: DriverFoundScreen.backButtonKey,
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
              'Sürücü Yolda',
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

  Widget _buildMap(ThemeData theme) {
    final approachPoints = _approachPoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: DriverFoundScreen.mapKey,
            child: SariMap(
              center: _flow.origin,
              zoom: 14.0,
              tileProvider: widget.tileProvider,
              mapController: _mapController,
              onMapReady: _handleMapReady,
              layers: [
                PolylineLayer(
                  key: DriverFoundScreen.polylineLayerKey,
                  polylines: [
                    Polyline(
                      points: approachPoints,
                      strokeWidth: 4.5,
                      color: theme.colorScheme.primaryContainer,
                      borderStrokeWidth: 3,
                      borderColor: SariColors.ink,
                    ),
                  ],
                ),
                MarkerLayer(
                  key: DriverFoundScreen.driverMarkerLayerKey,
                  markers: [
                    Marker(
                      point: LatLng(
                        FakeRideData.driverApproachOrigin.latitude,
                        FakeRideData.driverApproachOrigin.longitude,
                      ),
                      width: 130,
                      height: 90,
                      child: _DriverMarker(
                        theme: theme,
                        plate: FakeRideData.driver.plate,
                      ),
                    ),
                  ],
                ),
                MarkerLayer(
                  key: DriverFoundScreen.pickupMarkerLayerKey,
                  markers: [
                    Marker(
                      point: LatLng(
                        _flow.origin.latitude,
                        _flow.origin.longitude,
                      ),
                      width: 48,
                      height: 48,
                      child: _PickupMarker(theme: theme),
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
          child: Center(child: _buildStatusPill(theme)),
        ),
        Positioned(
          bottom: SariSpacing.md,
          right: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: DriverFoundScreen.focusButtonKey,
            icon: Icons.near_me,
            tooltip: 'Haritayı Odakla',
            onTap: _fitRoute,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusPill(ThemeData theme) {
    return Container(
      key: DriverFoundScreen.statusPillKey,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Flexible(
            child: Text(
              'Sürücü yolda · ${FakeRideData.driverApproachDistanceMeters} m',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onInverseSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(ThemeData theme, RouteQuote quote, double maxHeight) {
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
            _buildArrivalHeader(theme),
            const SizedBox(height: 12),
            _buildProgress(theme),
            const SizedBox(height: 20),
            _buildDriverCard(theme),
            const SizedBox(height: SariSpacing.md),
            _buildActionRow(theme),
            const SizedBox(height: 20),
            _buildSafetyCard(theme, quote),
            const SizedBox(height: 12),
            _buildCancelButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildArrivalHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Taksin $_arrivalMinutes dk içinde geliyor',
                key: DriverFoundScreen.headingKey,
                maxLines: 2,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 2),
              Text(
                'Sürücün seni ${_destination.name} noktasından alacak',
                key: DriverFoundScreen.subtitleKey,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SariSpacing.sm),
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.timer_outlined,
            size: 20,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(ThemeData theme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: AnimatedBuilder(
        animation: _arrivalController,
        builder: (context, child) {
          return LinearProgressIndicator(
            key: DriverFoundScreen.progressKey,
            value: _arrivalController.value,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainer,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.primaryContainer,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
    final driver = FakeRideData.driver;
    final rating = driver.rating.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      key: DriverFoundScreen.driverCardKey,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
      ),
      child: Row(
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
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        driver.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rating,
                            maxLines: 1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.star,
                            size: 13,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.vehicle} · Sarı Taksi',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 104),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: _buildPlateBadge(theme, driver.plate),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlateBadge(ThemeData theme, String plate) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.badge),
        border: Border.all(color: SariColors.border),
      ),
      child: Text(
        'TR $plate',
        maxLines: 1,
        style: sariPlateStyle.copyWith(color: SariColors.ink),
      ),
    );
  }

  Widget _buildActionRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(SariRadius.button),
            child: InkWell(
              key: DriverFoundScreen.callButtonKey,
              borderRadius: BorderRadius.circular(SariRadius.button),
              onTap: _showComingSoon,
              child: SizedBox(
                height: 48,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.call,
                      size: 20,
                      color: theme.colorScheme.onInverseSurface,
                    ),
                    const SizedBox(width: SariSpacing.sm),
                    Flexible(
                      child: Text(
                        'Sürücüyü Ara',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _ActionIconButton(
          buttonKey: DriverFoundScreen.messageButtonKey,
          icon: Icons.chat_bubble_outline,
          tooltip: 'Mesaj Gönder',
          onTap: _showComingSoon,
        ),
        const SizedBox(width: 12),
        _ActionIconButton(
          buttonKey: DriverFoundScreen.shareButtonKey,
          icon: Icons.ios_share,
          tooltip: 'Yolculuğu Paylaş',
          onTap: _showComingSoon,
        ),
      ],
    );
  }

  Widget _buildSafetyCard(ThemeData theme, RouteQuote quote) {
    final rideClass = _flow.selectedRideClass;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user,
              size: 16,
              color: theme.colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taksi Güvenlik Koruması',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Taksimetre kilitli güvencesi aktif',
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formatFare(quote.fareFor(rideClass)),
                key: DriverFoundScreen.fareTextKey,
                maxLines: 1,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(width: SariSpacing.xs),
              Icon(
                Icons.credit_card,
                size: 16,
                color: SariColors.textSecondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(ThemeData theme) {
    return Material(
      color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0),
      child: InkWell(
        key: DriverFoundScreen.cancelButtonKey,
        borderRadius: BorderRadius.circular(SariRadius.badge),
        onTap: _showComingSoon,
        child: SizedBox(
          height: 32,
          child: Center(
            child: Text(
              'Yolculuğu iptal et',
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
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
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SariRadius.button),
        child: InkWell(
          key: buttonKey,
          borderRadius: BorderRadius.circular(SariRadius.button),
          onTap: onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, size: 20, color: SariColors.ink),
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

class _DriverMarker extends StatelessWidget {
  const _DriverMarker({required this.theme, required this.plate});

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

class _PickupMarker extends StatelessWidget {
  const _PickupMarker({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
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
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}

String _formatFare(int amount) =>
    '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
