import 'package:flutter/material.dart';

import '../data/ride_class.dart';
import '../theme/sari_theme.dart';
import '../trips/completed_trip.dart';
import '../trips/trip_history_controller.dart';
import '../trips/trip_summary.dart';
import '../widgets/coming_soon_snack_bar.dart';

const _shortMonths = <String>[
  'Oca',
  'Şub',
  'Mar',
  'Nis',
  'May',
  'Haz',
  'Tem',
  'Ağu',
  'Eyl',
  'Eki',
  'Kas',
  'Ara',
];

const _longMonths = <String>[
  'Ocak',
  'Şubat',
  'Mart',
  'Nisan',
  'Mayıs',
  'Haziran',
  'Temmuz',
  'Ağustos',
  'Eylül',
  'Ekim',
  'Kasım',
  'Aralık',
];

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({
    super.key,
    required this.tripHistoryController,
    this.now,
  });

  static const screenKey = Key('trip-history-screen');
  static const notificationButtonKey = Key(
    'trip-history-notification-button',
  );
  static const avatarButtonKey = Key('trip-history-avatar-button');
  static const summaryCardKey = Key('trip-history-summary-card');
  static const summaryTripCountKey = Key('trip-history-summary-trip-count');
  static const summaryDistanceKey = Key('trip-history-summary-distance');
  static const summaryDurationKey = Key('trip-history-summary-duration');
  static const summaryCo2Key = Key('trip-history-summary-co2');
  static const monthChipKey = Key('trip-history-month-chip');
  static const allFilterKey = Key('trip-history-filter-all');
  static const sariFilterKey = Key('trip-history-filter-sari');
  static const corporateFilterKey = Key('trip-history-filter-corporate');
  static const tripListKey = Key('trip-history-list');
  static const emptyStateKey = Key('trip-history-empty-state');
  static const supportCardKey = Key('trip-history-support-card');

  static Key tripCardKey(int index) => Key('trip-history-card-$index');
  static Key cardDateKey(int index) => Key('trip-history-card-date-$index');
  static Key cardAmountKey(int index) => Key('trip-history-card-amount-$index');
  static Key cardRouteKey(int index) => Key('trip-history-card-route-$index');
  static Key cardPlateKey(int index) => Key('trip-history-card-plate-$index');
  static Key cardClassKey(int index) => Key('trip-history-card-class-$index');
  static Key cardDistanceKey(int index) =>
      Key('trip-history-card-distance-$index');
  static Key cardRatingKey(int index) =>
      Key('trip-history-card-rating-$index');
  static Key cardDriverKey(int index) =>
      Key('trip-history-card-driver-$index');
  static Key receiptButtonKey(int index) =>
      Key('trip-history-card-receipt-$index');
  static Key repeatButtonKey(int index) =>
      Key('trip-history-card-repeat-$index');

  final TripHistoryController tripHistoryController;
  final DateTime Function()? now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, theme),
            Expanded(
              child: ListenableBuilder(
                listenable: tripHistoryController,
                builder: (context, _) {
                  final current = now?.call() ?? DateTime.now();
                  final trips = tripHistoryController.trips;
                  final summary = TripSummary.forMonth(
                    trips: trips,
                    month: current,
                  );
                  return _buildContent(context, theme, current, trips, summary);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        border: const Border(bottom: BorderSide(color: SariColors.border)),
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
          Expanded(
            child: Text(
              'Yolculuklarım',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          IconButton(
            key: notificationButtonKey,
            onPressed: () => _showComingSoon(context),
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none),
            color: SariColors.ink,
          ),
          const SizedBox(width: SariSpacing.xs),
          InkWell(
            key: avatarButtonKey,
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

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    DateTime current,
    List<CompletedTrip> trips,
    TripSummary summary,
  ) {
    return ListView(
      key: tripListKey,
      padding: const EdgeInsets.fromLTRB(
        SariSpacing.md,
        SariSpacing.md,
        SariSpacing.md,
        SariSpacing.lg,
      ),
      children: [
        _buildSummaryCard(theme, current, summary),
        const SizedBox(height: SariSpacing.md),
        _buildFilters(context, theme, current),
        const SizedBox(height: SariSpacing.md),
        if (trips.isEmpty)
          _buildEmptyState(theme)
        else
          for (var index = 0; index < trips.length; index++) ...[
            if (index > 0) const SizedBox(height: SariSpacing.sm),
            _buildTripCard(context, theme, trips[index], index),
          ],
        const SizedBox(height: SariSpacing.md),
        _buildSupportCard(context, theme),
      ],
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    DateTime current,
    TripSummary summary,
  ) {
    final kilometers = summary.totalKilometers.toStringAsFixed(1);
    final co2 = summary.co2SavedKg.toStringAsFixed(1);
    final durationMinutes = summary.totalDuration.inMinutes;

    return Container(
      key: summaryCardKey,
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bu Ayki Yolculuklar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: SariSpacing.xs,
                      children: [
                        Text(
                          '${summary.tripCount} Yolculuk',
                          key: summaryTripCountKey,
                          maxLines: 1,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          '• $kilometers km',
                          key: summaryDistanceKey,
                          maxLines: 1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: SariColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_taxi,
                  size: 26,
                  color: theme.colorScheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: SariSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SariSpacing.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.eco,
                        size: 18,
                        color: theme.colorScheme.tertiary,
                      ),
                      const SizedBox(width: SariSpacing.xs),
                      Flexible(
                        child: Text(
                          '$co2 kg CO₂ tasarrufu',
                          key: summaryCo2Key,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: SariSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Text(
                      '$durationMinutes dk yolda',
                      key: summaryDurationKey,
                      maxLines: 1,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(
    BuildContext context,
    ThemeData theme,
    DateTime current,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            key: monthChipKey,
            theme: theme,
            label: '${_longMonths[current.month - 1]} ${current.year}',
            selected: true,
            icon: Icons.expand_more,
            horizontalPadding: SariSpacing.md,
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(width: SariSpacing.xs),
          _buildChip(
            key: allFilterKey,
            theme: theme,
            label: 'Tümü',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(width: SariSpacing.xs),
          _buildChip(
            key: sariFilterKey,
            theme: theme,
            label: '${RideClass.sari.label} Taksi',
            onTap: () => _showComingSoon(context),
          ),
          const SizedBox(width: SariSpacing.xs),
          _buildChip(
            key: corporateFilterKey,
            theme: theme,
            label: 'Kurumsal',
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required Key key,
    required ThemeData theme,
    required String label,
    required VoidCallback onTap,
    bool selected = false,
    IconData? icon,
    double horizontalPadding = SariSpacing.sm,
  }) {
    final foreground = selected
        ? theme.colorScheme.onInverseSurface
        : theme.colorScheme.onSurface;

    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 36,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        decoration: BoxDecoration(
          color: selected
              ? theme.colorScheme.inverseSurface
              : theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(SariRadius.badge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(color: foreground),
            ),
            if (icon != null) ...[
              const SizedBox(width: SariSpacing.xs),
              Icon(icon, size: 16, color: foreground),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SariSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 40,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: SariSpacing.sm),
          Text(
            'Henüz yolculuk yok',
            key: emptyStateKey,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    ThemeData theme,
    CompletedTrip trip,
    int index,
  ) {
    final route =
        '${trip.departureLabel} → ${trip.destination.name}';
    final distance = (trip.distanceMeters / 1000).toStringAsFixed(1);
    final amount = '₺${trip.amountLira},00';
    final rating = trip.rating.toStringAsFixed(1);

    return Container(
      key: tripCardKey(index),
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _formatTripDate(trip.completedAt),
                        key: cardDateKey(index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: SariColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    _buildCompletedBadge(theme),
                  ],
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Text(
                amount,
                key: cardAmountKey(index),
                maxLines: 1,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: SariSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildRouteThumbnail(theme, index),
              const SizedBox(width: SariSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route,
                      key: cardRouteKey(index),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(
                              SariRadius.badge / 2,
                            ),
                          ),
                          child: Text(
                            trip.driver.plate,
                            key: cardPlateKey(index),
                            maxLines: 1,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
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
                            '${RideClass.sari.label} Taksi',
                            key: cardClassKey(index),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: SariColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: SariSpacing.xs),
                        Text(
                          '•',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: SariColors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: SariSpacing.xs),
                        Text(
                          '$distance km',
                          key: cardDistanceKey(index),
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
            ],
          ),
          const SizedBox(height: SariSpacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 16,
                      color: theme.colorScheme.primaryContainer,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rating,
                      key: cardRatingKey(index),
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Flexible(
                      child: Text(
                        '(${trip.driver.name})',
                        key: cardDriverKey(index),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: SariColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              _buildCardButton(
                key: receiptButtonKey(index),
                theme: theme,
                icon: Icons.receipt_long,
                label: 'Fiş',
                onTap: () => _showComingSoon(context),
              ),
              const SizedBox(width: SariSpacing.sm),
              _buildCardButton(
                key: repeatButtonKey(index),
                theme: theme,
                icon: Icons.restart_alt,
                label: 'Tekrarla',
                highlighted: true,
                onTap: () => _showComingSoon(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle,
            size: 13,
            color: theme.colorScheme.onTertiaryContainer,
          ),
          const SizedBox(width: 2),
          Text(
            'Tamamlandı',
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteThumbnail(ThemeData theme, int index) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.badge),
      ),
      child: CustomPaint(
        painter: _RouteThumbnailPainter(
          variant: index % 3,
          routeColor: theme.colorScheme.primaryContainer,
          startColor: theme.colorScheme.primary,
          endColor: theme.colorScheme.tertiary,
          dotBorderColor: theme.colorScheme.surfaceContainerLow,
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required Key key,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    final background = highlighted
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surfaceContainer;
    final foreground = highlighted
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;

    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: SariSpacing.sm),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(SariRadius.badge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 4),
            Text(
              label,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: highlighted ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportCard(BuildContext context, ThemeData theme) {
    return GestureDetector(
      key: supportCardKey,
      onTap: () => _showComingSoon(context),
      child: Container(
        padding: const EdgeInsets.all(SariSpacing.md),
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
                color: theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.support_agent,
                size: 20,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: SariSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Araçta eşyanızı mı unuttunuz?',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sürücü ile iletişime geçin veya destek talebi açın',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: SariColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SariSpacing.xs),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    showComingSoonSnackBar(context);
  }
}

String _formatTripDate(DateTime date) {
  final day = date.day;
  final month = _shortMonths[date.month - 1];
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$day $month, $hour:$minute';
}

class _RouteThumbnailPainter extends CustomPainter {
  const _RouteThumbnailPainter({
    required this.variant,
    required this.routeColor,
    required this.startColor,
    required this.endColor,
    required this.dotBorderColor,
  });

  final int variant;
  final Color routeColor;
  final Color startColor;
  final Color endColor;
  final Color dotBorderColor;

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 48;
    final scaleY = size.height / 48;
    Offset p(double x, double y) => Offset(x * scaleX, y * scaleY);

    final path = Path();
    late final Offset start;
    late final Offset end;

    switch (variant) {
      case 1:
        start = p(38, 38);
        end = p(10, 10);
        path.moveTo(start.dx, start.dy);
        path.cubicTo(
          p(30, 32).dx,
          p(30, 32).dy,
          p(24, 36).dx,
          p(24, 36).dy,
          p(18, 20).dx,
          p(18, 20).dy,
        );
        path.cubicTo(
          p(14, 12).dx,
          p(14, 12).dy,
          p(10, 14).dx,
          p(10, 14).dy,
          end.dx,
          end.dy,
        );
        break;
      case 2:
        start = p(8, 16);
        end = p(42, 38);
        path.moveTo(start.dx, start.dy);
        path.cubicTo(
          p(18, 14).dx,
          p(18, 14).dy,
          p(20, 34).dx,
          p(20, 34).dy,
          p(30, 28).dx,
          p(30, 28).dy,
        );
        path.cubicTo(
          p(38, 22).dx,
          p(38, 22).dy,
          p(38, 36).dx,
          p(38, 36).dy,
          end.dx,
          end.dy,
        );
        break;
      default:
        start = p(8, 36);
        end = p(40, 12);
        path.moveTo(start.dx, start.dy);
        path.cubicTo(
          p(14, 36).dx,
          p(14, 36).dy,
          p(16, 16).dx,
          p(16, 16).dy,
          p(26, 22).dx,
          p(26, 22).dy,
        );
        path.cubicTo(
          p(34, 26).dx,
          p(34, 26).dy,
          p(36, 10).dx,
          p(36, 10).dy,
          end.dx,
          end.dy,
        );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = routeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    final borderPaint = Paint()
      ..color = dotBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(start, 3.5 * scaleX, Paint()..color = startColor);
    canvas.drawCircle(start, 3.5 * scaleX, borderPaint);
    canvas.drawCircle(end, 3.5 * scaleX, Paint()..color = endColor);
    canvas.drawCircle(end, 3.5 * scaleX, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RouteThumbnailPainter oldDelegate) {
    return oldDelegate.variant != variant ||
        oldDelegate.routeColor != routeColor ||
        oldDelegate.startColor != startColor ||
        oldDelegate.endColor != endColor ||
        oldDelegate.dotBorderColor != dotBorderColor;
  }
}
