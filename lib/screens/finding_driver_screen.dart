import 'dart:async';
import 'dart:math' as math;

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

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({
    super.key,
    this.flowController,
    this.tileProvider,
    this.mapController,
    this.waitDuration = defaultWaitDuration,
    this.animationsEnabled = true,
    this.animationFrame = 0.0,
    this.onSearchComplete,
  });

  static const defaultWaitDuration = Duration(seconds: 3);
  static const radarAnimationDuration = Duration(seconds: 4);
  static const screenKey = Key('finding-driver-screen');
  static const backButtonKey = Key('finding-driver-back-button');
  static const mapKey = Key('finding-driver-map');
  static const statusChipKey = Key('finding-driver-status-chip');
  static const radarKey = Key('finding-driver-radar');
  static const focusButtonKey = Key('finding-driver-focus-button');
  static const summaryCardKey = Key('finding-driver-summary-card');
  static const fareTextKey = Key('finding-driver-fare-text');
  static const cancelButtonKey = Key('finding-driver-cancel-button');
  static const cancelDialogKey = Key('finding-driver-cancel-dialog');
  static const confirmCancelKey = Key('finding-driver-confirm-cancel');
  static const resumeSearchKey = Key('finding-driver-resume-search');

  final RideFlowController? flowController;
  final TileProvider? tileProvider;
  final MapController? mapController;
  final Duration waitDuration;
  final bool animationsEnabled;
  final double animationFrame;
  final VoidCallback? onSearchComplete;

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen>
    with SingleTickerProviderStateMixin {
  late final RideFlowController _ownedFlowController;
  late final MapController _ownedMapController;
  late final AnimationController _animationController;

  Timer? _waitTimer;
  bool _waitCompleted = false;
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
    _animationController = AnimationController(
      vsync: this,
      duration: FindingDriverScreen.radarAnimationDuration,
    );
    if (widget.animationsEnabled) {
      _animationController.repeat();
    } else {
      _animationController.value = widget.animationFrame
          .clamp(0.0, 1.0)
          .toDouble();
    }
    _ensureDestination();
    _startWaitTimer();
  }

  @override
  void dispose() {
    _waitTimer?.cancel();
    _animationController.dispose();
    _ownedMapController.dispose();
    _ownedFlowController.dispose();
    super.dispose();
  }

  void _ensureDestination() {
    if (_flow.destination == null) {
      _flow.selectDestination(FakeRideData.kadikoyIskele);
    }
  }

  void _startWaitTimer() {
    _waitTimer?.cancel();
    _waitTimer = Timer(widget.waitDuration, _handleWaitElapsed);
  }

  void _cancelWaitTimer() {
    _waitTimer?.cancel();
    _waitTimer = null;
  }

  void _handleWaitElapsed() {
    _waitTimer = null;
    if (_waitCompleted) {
      return;
    }
    _waitCompleted = true;
    widget.onSearchComplete?.call();
  }

  void _handleMapReady() {
    _mapReady = true;
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

  void _leaveSearch() {
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

  Future<void> _showCancelDialog() async {
    _cancelWaitTimer();
    final theme = Theme.of(context);
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surfaceContainerLowest.withValues(
        alpha: 0,
      ),
      builder: (dialogContext) => _buildCancelDialog(dialogContext),
    );
    if (!mounted) {
      return;
    }
    if (result == true) {
      _leaveSearch();
      return;
    }
    if (!_waitCompleted) {
      _startWaitTimer();
    }
  }

  Widget _buildCancelDialog(BuildContext dialogContext) {
    final theme = Theme.of(dialogContext);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(SariSpacing.md),
        child: Container(
          key: FindingDriverScreen.cancelDialogKey,
          padding: const EdgeInsets.all(SariSpacing.lg),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SariRadius.sheet),
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.do_not_disturb_on,
                      size: 28,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Taksi aramasını iptal etmek istiyor musun?',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: SariSpacing.sm),
                Text(
                  'Çevrendeki 4 taksi sürücüsüne çağrın iletildi. Ayrılırsan sıra kaybedebilirsin.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
                const SizedBox(height: SariSpacing.lg),
                _buildDialogButton(
                  buttonKey: FindingDriverScreen.confirmCancelKey,
                  label: 'Evet, İptal Et',
                  background: theme.colorScheme.error,
                  foreground: theme.colorScheme.onError,
                  onTap: () => Navigator.of(dialogContext).pop(true),
                ),
                const SizedBox(height: SariSpacing.sm),
                _buildDialogButton(
                  buttonKey: FindingDriverScreen.resumeSearchKey,
                  label: 'Aramaya Devam Et',
                  background: theme.colorScheme.surfaceContainer,
                  foreground: SariColors.ink,
                  onTap: () => Navigator.of(dialogContext).pop(false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton({
    required Key buttonKey,
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: buttonKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: onTap,
        child: SizedBox(
          height: 48,
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = _quote;

    return Scaffold(
      key: FindingDriverScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                _buildHeader(theme),
                Expanded(child: _buildMap(theme)),
                _buildSheet(theme, quote, constraints.maxHeight * 0.58),
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
            key: FindingDriverScreen.backButtonKey,
            onPressed: _leaveSearch,
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
              'Taksi Aranıyor',
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

  Widget _buildMap(ThemeData theme) {
    return Stack(
      children: [
        Positioned.fill(
          child: KeyedSubtree(
            key: FindingDriverScreen.mapKey,
            child: SariMap(
              center: _flow.origin,
              zoom: 13.5,
              tileProvider: widget.tileProvider,
              mapController: _mapController,
              onMapReady: _handleMapReady,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: ColoredBox(
              color: theme.colorScheme.inverseSurface.withValues(alpha: 0.40),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  radius: 0.6,
                  colors: [
                    theme.colorScheme.primaryContainer.withValues(alpha: 0.24),
                    theme.colorScheme.primaryContainer.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
        ),
        Center(child: _buildRadar(theme)),
        Positioned(
          top: SariSpacing.md,
          left: SariSpacing.md,
          right: SariSpacing.md,
          child: Center(child: _buildStatusChip(theme)),
        ),
        Positioned(
          bottom: SariSpacing.md,
          right: SariSpacing.md,
          child: _MapIconButton(
            buttonKey: FindingDriverScreen.focusButtonKey,
            icon: Icons.my_location,
            tooltip: 'Haritayı Odakla',
            onTap: _fitRoute,
          ),
        ),
      ],
    );
  }

  Widget _buildRadar(ThemeData theme) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                key: FindingDriverScreen.radarKey,
                size: const Size.square(280),
                painter: _RadarPainter(
                  frame: _animationController.value,
                  color: theme.colorScheme.primaryContainer,
                ),
              );
            },
          ),
          _buildCenterBadge(theme),
        ],
      ),
    );
  }

  Widget _buildCenterBadge(ThemeData theme) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 56,
          height: 56,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.24),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_taxi,
              size: 24,
              color: SariColors.ink,
            ),
          ),
        ),
        Positioned(
          top: -1,
          right: -1,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: SariColors.userLocation,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surfaceContainerLowest,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(ThemeData theme) {
    return Container(
      key: FindingDriverScreen.statusChipKey,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final progress = _animationController.value % 1;
              return SizedBox(
                width: 12,
                height: 12,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 1 + progress * 1.6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer.withValues(
                            alpha: 0.5 * (1 - progress),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: SariSpacing.sm),
          Flexible(
            child: Text(
              'Yakındaki sürücülere bildiriliyor',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(ThemeData theme, RouteQuote quote, double maxHeight) {
    final rideClass = _flow.selectedRideClass;

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
            _buildRadarPuck(theme),
            const SizedBox(height: 12),
            Text(
              'Sana en yakın taksiyi arıyoruz…',
              maxLines: 2,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: SariSpacing.xs),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Ortalama bekleme süresi ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SariColors.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: '1-2 dakika',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SariColors.ink,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SariColors.textSecondary,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: SariSpacing.md),
            _buildSummaryPill(theme, quote, rideClass),
            const SizedBox(height: SariSpacing.md),
            _buildCancelButton(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarPuck(ThemeData theme) {
    return Center(
      child: Container(
        width: 64,
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLow,
          shape: BoxShape.circle,
        ),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _animationController.value * 2 * math.pi,
                child: child,
              );
            },
            child: const Icon(Icons.radar, size: 26, color: SariColors.ink),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryPill(
    ThemeData theme,
    RouteQuote quote,
    RideClass rideClass,
  ) {
    return Container(
      key: FindingDriverScreen.summaryCardKey,
      padding: const EdgeInsets.all(SariSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: const Icon(
              Icons.local_taxi,
              size: 22,
              color: SariColors.ink,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${rideClass.label} Taksi',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(SariRadius.badge),
                      ),
                      child: Text(
                        'Standart',
                        maxLines: 1,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${FakeRideData.homeAreaLabel} → ${_destination.name}',
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatFare(quote.fareFor(rideClass)),
                key: FindingDriverScreen.fareTextKey,
                maxLines: 1,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                'Nakit/Kart',
                maxLines: 1,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton(ThemeData theme) {
    return Material(
      key: FindingDriverScreen.cancelButtonKey,
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: _showCancelDialog,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.close,
                size: 20,
                color: SariColors.textSecondary,
              ),
              const SizedBox(width: SariSpacing.xs),
              Text(
                'Aramayı İptal Et',
                maxLines: 1,
                style: theme.textTheme.labelLarge,
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

class _RadarPainter extends CustomPainter {
  const _RadarPainter({required this.frame, required this.color});

  final double frame;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (final factor in const [0.55, 0.75, 0.95]) {
      ringPaint.color = color.withValues(alpha: 0.28);
      _drawDashedCircle(canvas, center, maxRadius * factor, ringPaint);
    }

    final sweepStart = -math.pi / 2 + frame * 2 * math.pi;
    final rect = Rect.fromCircle(center: center, radius: maxRadius * 0.95);
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi / 3,
        colors: [
          color.withValues(alpha: 0.4),
          color.withValues(alpha: 0),
        ],
        transform: GradientRotation(sweepStart),
      ).createShader(rect);
    canvas.drawArc(rect, sweepStart, math.pi / 3, true, sweepPaint);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const dashCount = 48;
    const gapFactor = 0.45;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final circumference = 2 * math.pi * radius;
    final dashLength = circumference / dashCount * (1 - gapFactor);
    final gapLength = circumference / dashCount * gapFactor;
    final sweep = dashLength / radius;
    final step = (dashLength + gapLength) / radius;

    for (var index = 0; index < dashCount; index++) {
      canvas.drawArc(rect, index * step, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.frame != frame || oldDelegate.color != color;
}

String _formatFare(int amount) =>
    '₺${amount.toStringAsFixed(2).replaceAll('.', ',')}';
