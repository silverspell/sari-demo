import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../data/fake_place.dart';
import '../data/fake_ride_data.dart';
import '../data/fake_route_path.dart';
import '../data/ride_class.dart';
import '../data/route_fare_calculator.dart';
import '../data/route_quote.dart';
import '../map/sari_map.dart';
import '../rides/ride_flow_controller.dart';
import '../router/app_routes.dart';
import '../session/location_point.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';
import 'finding_driver_screen.dart';

class RouteFareScreen extends StatefulWidget {
  const RouteFareScreen({
    super.key,
    this.flowController,
    this.tileProvider,
    this.mapController,
  });

  static const screenKey = Key('route-fare-screen');
  static const backButtonKey = Key('route-fare-back-button');
  static const headerBackButtonKey = Key('route-fare-header-back-button');
  static const polylineLayerKey = Key('route-fare-polyline-layer');
  static const originMarkerLayerKey = Key('route-fare-origin-marker-layer');
  static const destinationMarkerLayerKey = Key(
    'route-fare-destination-marker-layer',
  );
  static const statsPillKey = Key('route-fare-stats-pill');
  static const focusButtonKey = Key('route-fare-focus-button');
  static const sariCardKey = Key('route-fare-sari-card');
  static const turkuazCardKey = Key('route-fare-turkuaz-card');
  static const selectedFareKey = Key('route-fare-selected-fare');
  static const paymentRowKey = Key('route-fare-payment-row');
  static const changePaymentButtonKey = Key(
    'route-fare-change-payment-button',
  );
  static const callButtonKey = Key('route-fare-call-button');
  static const meterNoticeKey = Key('route-fare-meter-notice');

  final RideFlowController? flowController;
  final TileProvider? tileProvider;
  final MapController? mapController;

  @override
  State<RouteFareScreen> createState() => _RouteFareScreenState();
}

class _RouteFareScreenState extends State<RouteFareScreen> {
  late final RideFlowController _ownedFlowController;
  late final MapController _ownedMapController;
  bool _mapReady = false;

  RideFlowController get _flow =>
      widget.flowController ?? _ownedFlowController;

  MapController get _mapController =>
      widget.mapController ?? _ownedMapController;

  FakePlace get _destination =>
      _flow.destination ?? FakeRideData.kadikoyIskele;

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
    _flow.addListener(_handleFlowChanged);
  }

  @override
  void didUpdateWidget(covariant RouteFareScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.flowController != widget.flowController) {
      (oldWidget.flowController ?? _ownedFlowController).removeListener(
        _handleFlowChanged,
      );
      _ensureDestination();
      _flow.addListener(_handleFlowChanged);
    }
  }

  @override
  void dispose() {
    _flow.removeListener(_handleFlowChanged);
    _ownedMapController.dispose();
    _ownedFlowController.dispose();
    super.dispose();
  }

  void _ensureDestination() {
    if (_flow.destination == null) {
      _flow.selectDestination(FakeRideData.kadikoyIskele);
    }
  }

  void _handleFlowChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
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
    final points = _routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: const EdgeInsets.all(SariSpacing.lg),
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
      context.go(AppRoutes.destination);
    }
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  void _handleCallTaxi() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.push(AppRoutes.findingDriver);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FindingDriverScreen(
          flowController: _flow,
          tileProvider: widget.tileProvider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = _quote;

    return Scaffold(
      key: RouteFareScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(child: _buildMap(theme, quote)),
            _buildSheet(theme, quote),
          ],
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
            key: RouteFareScreen.headerBackButtonKey,
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
              'Rota Ve Ücret Tahmini',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          const Icon(
            Icons.emergency,
            size: 20,
            color: SariColors.critical,
          ),
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

  Widget _buildMap(ThemeData theme, RouteQuote quote) {
    final routePoints = _routePoints
        .map((point) => LatLng(point.latitude, point.longitude))
        .toList();

    return Stack(
      children: [
        Positioned.fill(
          child: SariMap(
            center: _flow.origin,
            tileProvider: widget.tileProvider,
            mapController: _mapController,
            onMapReady: _handleMapReady,
            layers: [
              PolylineLayer(
                key: RouteFareScreen.polylineLayerKey,
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.5,
                    color: SariColors.ink,
                    borderStrokeWidth: 3,
                    borderColor: SariColors.surface,
                  ),
                ],
              ),
              MarkerLayer(
                key: RouteFareScreen.originMarkerLayerKey,
                markers: [
                  Marker(
                    point: LatLng(
                      _flow.origin.latitude,
                      _flow.origin.longitude,
                    ),
                    width: 130,
                    height: 78,
                    child: _OriginMarker(theme: theme),
                  ),
                ],
              ),
              MarkerLayer(
                key: RouteFareScreen.destinationMarkerLayerKey,
                markers: [
                  Marker(
                    point: LatLng(
                      _destination.location.latitude,
                      _destination.location.longitude,
                    ),
                    width: 130,
                    height: 82,
                    child: _DestinationMarker(theme: theme),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: SariSpacing.md,
          left: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: RouteFareScreen.backButtonKey,
            icon: Icons.arrow_back,
            tooltip: 'Geri',
            onTap: _handleBack,
          ),
        ),
        Positioned(
          top: SariSpacing.md,
          right: SariSpacing.md,
          child: _buildStatsPill(theme, quote),
        ),
        Positioned(
          bottom: SariSpacing.md,
          right: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: RouteFareScreen.focusButtonKey,
            icon: Icons.near_me,
            tooltip: 'Haritayı Hizala',
            onTap: _fitRoute,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsPill(ThemeData theme, RouteQuote quote) {
    return Container(
      key: RouteFareScreen.statsPillKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
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
          const SizedBox(width: SariSpacing.sm),
          Text(_durationLabel(quote), style: theme.textTheme.labelMedium),
          const SizedBox(width: SariSpacing.xs),
          Text(
            '·',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
          const SizedBox(width: SariSpacing.xs),
          Text(
            _distanceLabel(quote),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(ThemeData theme, RouteQuote quote) {
    return Container(
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
          _buildDestinationHeader(theme, quote),
          const SizedBox(height: 12),
          _buildSariCard(theme, quote),
          const SizedBox(height: SariSpacing.sm),
          _buildTurkuazCard(theme, quote),
          const SizedBox(height: 12),
          _buildPaymentRow(theme),
          const SizedBox(height: SariSpacing.md),
          _buildCallButton(theme),
          const SizedBox(height: 12),
          _buildMeterNotice(theme),
        ],
      ),
    );
  }

  Widget _buildDestinationHeader(ThemeData theme, RouteQuote quote) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _destination.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _destination.address,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${_durationLabel(quote)} · ${_distanceLabel(quote)}',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSariCard(ThemeData theme, RouteQuote quote) {
    final selected = _flow.selectedRideClass == RideClass.sari;

    return Material(
      key: RouteFareScreen.sariCardKey,
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: () => _flow.selectRideClass(RideClass.sari),
        child: Padding(
          padding: const EdgeInsets.all(SariSpacing.md),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 26,
                  color: SariColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            'Sarı Taksi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge,
                          ),
                        ),
                        const SizedBox(width: SariSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              SariRadius.badge,
                            ),
                          ),
                          child: Text(
                            '${RideClass.sari.capacity} Kişi',
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
                    Row(
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 14,
                          color: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '3 dk uzakta · Hızlı eşleşme',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fareLabel(quote, RideClass.sari),
                    key: selected ? RouteFareScreen.selectedFareKey : null,
                    maxLines: 1,
                    style: theme.textTheme.headlineMedium,
                  ),
                  Text(
                    'tahmini',
                    maxLines: 1,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SariColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurkuazCard(ThemeData theme, RouteQuote quote) {
    final selected = _flow.selectedRideClass == RideClass.turkuaz;

    return Material(
      key: RouteFareScreen.turkuazCardKey,
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.2)
          : theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: () => _flow.selectRideClass(RideClass.turkuaz),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.electric_car,
                  size: 20,
                  color: SariColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turkuaz Taksi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    Text(
                      'Konforlu & Sessiz',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _fareLabel(quote, RideClass.turkuaz),
                key: selected ? RouteFareScreen.selectedFareKey : null,
                maxLines: 1,
                style: theme.textTheme.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentRow(ThemeData theme) {
    return Material(
      key: RouteFareScreen.paymentRowKey,
      color: theme.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: _showComingSoon,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(SariRadius.badge),
                ),
                child: Icon(
                  Icons.credit_card,
                  size: 18,
                  color: theme.colorScheme.onInverseSurface,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mastercard •••• 4242',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: SariSpacing.xs),
                        Flexible(
                          child: Text(
                            'Hızlı Dijital Ödeme',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.tertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              InkWell(
                key: RouteFareScreen.changePaymentButtonKey,
                borderRadius: BorderRadius.circular(SariRadius.badge),
                onTap: _showComingSoon,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SariSpacing.xs,
                    vertical: SariSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Değiştir',
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: SariColors.textSecondary,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: SariColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallButton(ThemeData theme) {
    return Material(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: RouteFareScreen.callButtonKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: _handleCallTaxi,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_taxi, size: 22, color: SariColors.ink),
              const SizedBox(width: SariSpacing.sm),
              Text(
                'Taksi Çağır',
                maxLines: 1,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: SariColors.ink,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMeterNotice(ThemeData theme) {
    return Row(
      key: RouteFareScreen.meterNoticeKey,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.verified_user,
          size: 15,
          color: theme.colorScheme.tertiary,
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            'Taksimetre ücreti güzergah yoğunluğuna göre değişebilir.',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ),
      ],
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

class _OriginMarker extends StatelessWidget {
  const _OriginMarker({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(SariRadius.badge),
          ),
          child: Text(
            'Moda Sahil',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onInverseSurface,
              fontSize: 10,
            ),
          ),
        ),
        const SizedBox(height: SariSpacing.xs),
        Container(
          width: 24,
          height: 24,
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
              color: theme.colorScheme.tertiary,
              shape: BoxShape.circle,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
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
          child: const Icon(
            Icons.local_taxi,
            size: 20,
            color: SariColors.ink,
          ),
        ),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: theme.colorScheme.inverseSurface,
            borderRadius: BorderRadius.circular(SariRadius.badge),
          ),
          child: Text(
            'İSKELE',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onInverseSurface,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

String _durationLabel(RouteQuote quote) => '${quote.duration.inMinutes} dk';

String _distanceLabel(RouteQuote quote) {
  final kilometers = quote.distanceMeters / 1000;
  return '${kilometers.toStringAsFixed(1).replaceAll('.', ',')} km';
}

String _fareLabel(RouteQuote quote, RideClass rideClass) =>
    '₺${quote.fareFor(rideClass)}';
