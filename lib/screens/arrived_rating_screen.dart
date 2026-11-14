import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/fake_place.dart';
import '../data/fake_ride_data.dart';
import '../data/ride_class.dart';
import '../data/route_fare_calculator.dart';
import '../data/route_quote.dart';
import '../rides/ride_feedback_tag.dart';
import '../rides/ride_flow_controller.dart';
import '../router/app_routes.dart';
import '../theme/sari_theme.dart';
import '../trips/completed_trip.dart';
import '../trips/in_memory_trip_history_store.dart';
import '../trips/trip_history_controller.dart';
import '../widgets/coming_soon_snack_bar.dart';

class ArrivedRatingScreen extends StatefulWidget {
  const ArrivedRatingScreen({
    super.key,
    this.flowController,
    this.tripHistoryController,
    this.now,
  });

  static const screenKey = Key('arrived-rating-screen');
  static const backButtonKey = Key('arrived-rating-back-button');
  static const completionBadgeKey = Key('arrived-rating-completion-badge');
  static const fareCardKey = Key('arrived-rating-fare-card');
  static const fareTextKey = Key('arrived-rating-fare-text');
  static const paymentRowKey = Key('arrived-rating-payment-row');
  static const driverCardKey = Key('arrived-rating-driver-card');
  static const ratingCardKey = Key('arrived-rating-rating-card');
  static const finishButtonKey = Key('arrived-rating-finish-button');
  static const emailButtonKey = Key('arrived-rating-email-button');

  static Key starButtonKey(int rating) => Key('arrived-rating-star-$rating');

  static Key tagKey(RideFeedbackTag tag) =>
      Key('arrived-rating-tag-${tag.name}');

  final RideFlowController? flowController;
  final TripHistoryController? tripHistoryController;
  final DateTime Function()? now;

  @override
  State<ArrivedRatingScreen> createState() => _ArrivedRatingScreenState();
}

class _ArrivedRatingScreenState extends State<ArrivedRatingScreen> {
  late final RideFlowController _ownedFlowController;
  late final TripHistoryController _ownedTripHistoryController;

  bool _saving = false;

  RideFlowController get _flow =>
      widget.flowController ?? _ownedFlowController;

  TripHistoryController get _tripHistory =>
      widget.tripHistoryController ?? _ownedTripHistoryController;

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

  @override
  void initState() {
    super.initState();
    _ownedFlowController = RideFlowController();
    _ownedTripHistoryController = TripHistoryController(
      InMemoryTripHistoryStore(),
    );
    _ensureDestination();
    _flow.addListener(_handleFlowChanged);
  }

  @override
  void didUpdateWidget(covariant ArrivedRatingScreen oldWidget) {
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
    _ownedFlowController.dispose();
    _ownedTripHistoryController.dispose();
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

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.go(AppRoutes.home);
      return;
    }
    Navigator.maybeOf(context)?.maybePop();
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  Future<void> _handleFinish() async {
    if (_saving) {
      return;
    }
    setState(() {
      _saving = true;
    });

    final quote = _quote;
    final trip = CompletedTrip(
      destination: _flow.destination ?? FakeRideData.kadikoyIskele,
      departureLabel: FakeRideData.homeAreaLabel,
      distanceMeters: quote.distanceMeters,
      duration: quote.duration,
      completedAt: widget.now?.call() ?? DateTime.now(),
      amountLira: quote.fareFor(_flow.selectedRideClass),
      driver: FakeRideData.driver,
      rating: (_flow.rating ?? 0).toDouble(),
    );

    await _tripHistory.save(trip);
    if (!mounted) {
      return;
    }

    final router = GoRouter.maybeOf(context);
    if (router != null) {
      context.go(AppRoutes.home);
      return;
    }
    Navigator.maybeOf(context)?.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quote = _quote;

    return Scaffold(
      key: ArrivedRatingScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  SariSpacing.md,
                  SariSpacing.md,
                  SariSpacing.md,
                  SariSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHero(theme),
                    const SizedBox(height: 12),
                    _buildFareCard(theme, quote),
                    const SizedBox(height: 12),
                    _buildDriverCard(theme),
                    const SizedBox(height: 12),
                    _buildRatingCard(theme),
                    const SizedBox(height: 12),
                    _buildActions(theme),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: SariSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: const Border(bottom: BorderSide(color: SariColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            key: ArrivedRatingScreen.backButtonKey,
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
              'Yolculuk Tamamlandı',
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

  Widget _buildHero(ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withValues(
                    alpha: 0.35,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                key: ArrivedRatingScreen.completionBadgeKey,
                width: 80,
                height: 80,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check,
                  size: 44,
                  color: theme.colorScheme.onTertiary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Vardın!',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: SariSpacing.xs),
        Text(
          '${_destination.name} varış noktasına ulaştın',
          maxLines: 2,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: SariColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFareCard(ThemeData theme, RouteQuote quote) {
    return Container(
      key: ArrivedRatingScreen.fareCardKey,
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'TOPLAM TUTAR',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: SariColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SariSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SariRadius.badge),
                ),
                child: Text(
                  '${_distanceLabel(quote)} • ${_durationLabel(quote)}',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SariSpacing.xs),
          Text(
            _fareLabel(quote, _flow.selectedRideClass),
            key: ArrivedRatingScreen.fareTextKey,
            maxLines: 1,
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: SariSpacing.sm),
          Container(
            key: ArrivedRatingScreen.paymentRowKey,
            padding: const EdgeInsets.all(SariSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(SariRadius.badge),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    size: 18,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: SariSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '•••• 4242',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                      Text(
                        'Mastercard',
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
                Icon(
                  Icons.check_circle,
                  size: 18,
                  color: theme.colorScheme.tertiary,
                ),
                const SizedBox(width: SariSpacing.xs),
                Text(
                  'Ödendi',
                  maxLines: 1,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.tertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(ThemeData theme) {
    final driver = FakeRideData.driver;
    final rating = driver.rating.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      key: ArrivedRatingScreen.driverCardKey,
      padding: const EdgeInsets.all(SariSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
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
          const SizedBox(width: SariSpacing.sm),
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
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Icon(
                      Icons.star,
                      size: 15,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      maxLines: 1,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${driver.plate} • Sarı Taksi',
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
          Icon(
            Icons.local_taxi,
            size: 20,
            color: SariColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCard(ThemeData theme) {
    final rating = _flow.rating ?? 0;

    return Container(
      key: ArrivedRatingScreen.ratingCardKey,
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Column(
        children: [
          Text(
            'Yolculuğunu puanla',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 2),
          Text(
            'Sürücüyü değerlendirerek Sarı kalitesini destekle',
            maxLines: 2,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
          const SizedBox(height: SariSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var value = 1; value <= 5; value++)
                IconButton(
                  key: ArrivedRatingScreen.starButtonKey(value),
                  onPressed: () => _flow.selectRating(value),
                  tooltip: '$value Yıldız',
                  padding: const EdgeInsets.all(SariSpacing.xs),
                  constraints: const BoxConstraints.tightFor(
                    width: 48,
                    height: 48,
                  ),
                  icon: Icon(
                    value <= rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 36,
                    color: value <= rating
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.secondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: SariSpacing.sm),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: SariSpacing.sm,
            runSpacing: SariSpacing.sm,
            children: [
              for (final tag in RideFeedbackTag.values)
                _buildTagChip(theme, tag),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(ThemeData theme, RideFeedbackTag tag) {
    final selected = _flow.tags.contains(tag);

    return FilterChip(
      key: ArrivedRatingScreen.tagKey(tag),
      label: Text(tag.label, maxLines: 1),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => _flow.toggleTag(tag),
      selectedColor: theme.colorScheme.inverseSurface,
      backgroundColor: theme.colorScheme.surfaceContainer,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        color: selected
            ? theme.colorScheme.onInverseSurface
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildActions(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 56,
          child: FilledButton(
            key: ArrivedRatingScreen.finishButtonKey,
            onPressed: _saving ? null : _handleFinish,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Bitir',
                  maxLines: 1,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: SariColors.surface,
                  ),
                ),
                const SizedBox(width: SariSpacing.xs),
                const Icon(
                  Icons.done_all,
                  size: 20,
                  color: SariColors.surface,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: SariSpacing.xs),
        TextButton(
          key: ArrivedRatingScreen.emailButtonKey,
          onPressed: _showComingSoon,
          child: Text(
            'Faturayı E-Posta ile Gönder',
            maxLines: 1,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: SariColors.textSecondary,
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
    '₺${quote.fareFor(rideClass)},00';
