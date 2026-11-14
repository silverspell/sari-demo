import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/fake_menu_data.dart';
import '../session/session.dart';
import '../session/session_display.dart';
import '../theme/sari_theme.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({
    super.key,
    required this.animation,
    required this.session,
    required this.onClose,
    required this.onTripHistory,
    required this.onAccount,
    required this.onPaymentMethods,
    required this.onLogout,
    required this.onPoints,
  });

  static const panelKey = Key('menu-panel');
  static const scrimKey = Key('menu-scrim');
  static const closeButtonKey = Key('menu-close-button');
  static const profileBadgeKey = Key('menu-profile-badge');
  static const avatarKey = Key('menu-avatar');
  static const avatarInitialsKey = Key('menu-avatar-initials');
  static const verifiedBadgeKey = Key('menu-verified-badge');
  static const nameKey = Key('menu-name');
  static const phoneKey = Key('menu-phone');
  static const ratingKey = Key('menu-rating');
  static const tripHistoryRowKey = Key('menu-trip-history-row');
  static const accountRowKey = Key('menu-account-row');
  static const paymentMethodsRowKey = Key('menu-payment-methods-row');
  static const pointsCardKey = Key('menu-points-card');
  static const logoutButtonKey = Key('menu-logout-button');
  static const versionKey = Key('menu-version');

  static const _panelMaxWidth = 310.0;
  static const _panelWidthFactor = 0.8;

  final Animation<double> animation;
  final Session? session;
  final VoidCallback onClose;
  final VoidCallback onTripHistory;
  final VoidCallback onAccount;
  final VoidCallback onPaymentMethods;
  final VoidCallback onLogout;
  final VoidCallback onPoints;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 700;
        final panelWidth = math.min(
          _panelMaxWidth,
          constraints.maxWidth * _panelWidthFactor,
        );
        final dismissWidth = math.max(0.0, constraints.maxWidth - panelWidth);

        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final progress = animation.value;
            return Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: theme.colorScheme.inverseSurface.withValues(
                        alpha: 0.6 * progress,
                      ),
                    ),
                  ),
                ),
                if (dismissWidth > 0)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: dismissWidth,
                    child: GestureDetector(
                      key: scrimKey,
                      behavior: HitTestBehavior.opaque,
                      onTap: onClose,
                    ),
                  ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  width: panelWidth,
                  child: Transform.translate(
                    offset: Offset(-panelWidth * (1 - progress), 0),
                    child: _buildPanel(context, theme, compact),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPanel(BuildContext context, ThemeData theme, bool compact) {
    final padding = compact ? 20.0 : SariSpacing.lg;

    return Material(
      key: panelKey,
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: 12,
      clipBehavior: Clip.antiAlias,
      borderRadius: const BorderRadius.horizontal(
        right: Radius.circular(SariRadius.drawer),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTopRow(theme),
            SizedBox(height: compact ? 12 : SariSpacing.md),
            _buildIdentity(context, theme),
            SizedBox(height: compact ? 16 : SariSpacing.lg),
            _buildTripHistoryRow(compact),
            SizedBox(height: compact ? 4 : 6),
            _buildAccountRow(compact),
            SizedBox(height: compact ? 4 : 6),
            _buildPaymentMethodsRow(compact),
            SizedBox(height: compact ? 12 : SariSpacing.md),
            _buildPointsCard(theme),
            const Spacer(),
            Container(
              height: 1,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            SizedBox(height: compact ? 8 : 12),
            _buildLogoutRow(theme, compact),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow(ThemeData theme) {
    return Row(
      children: [
        Container(
          key: profileBadgeKey,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: SariColors.primaryFixed,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            FakeMenuData.profileBadgeLabel,
            maxLines: 1,
            style: theme.textTheme.labelSmall?.copyWith(
              color: SariColors.onPrimaryFixed,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: theme.colorScheme.surfaceContainer,
          shape: const CircleBorder(),
          child: InkWell(
            key: closeButtonKey,
            customBorder: const CircleBorder(),
            onTap: onClose,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Icon(
                Icons.close,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdentity(BuildContext context, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 64,
          height: 64,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: avatarKey,
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  SessionDisplay.initials(session),
                  key: avatarInitialsKey,
                  maxLines: 1,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: SariColors.onPrimaryFixed,
                  ),
                ),
              ),
              if (FakeMenuData.isVerified)
                Positioned(
                  right: -1,
                  bottom: -1,
                  child: Container(
                    key: verifiedBadgeKey,
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surfaceContainerLowest,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 12,
                      color: theme.colorScheme.onTertiary,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: SariSpacing.sm),
        Text(
          SessionDisplay.fullName(session),
          key: nameKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Flexible(
              child: Text(
                SessionDisplay.phone(session),
                key: phoneKey,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SariColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              width: 3,
              height: 3,
              decoration: const BoxDecoration(
                color: SariColors.textSecondary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.star,
              size: 14,
              color: theme.colorScheme.primaryContainer,
            ),
            const SizedBox(width: 2),
            Text(
              FakeMenuData.passengerRatingLabel,
              key: ratingKey,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SariColors.ink,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripHistoryRow(bool compact) {
    return _MenuNavRow(
      rowKey: tripHistoryRowKey,
      icon: Icons.receipt_long,
      title: FakeMenuData.tripHistoryTitle,
      subtitle: FakeMenuData.tripHistorySubtitle,
      onTap: onTripHistory,
      compact: compact,
    );
  }

  Widget _buildAccountRow(bool compact) {
    return _MenuNavRow(
      rowKey: accountRowKey,
      icon: Icons.account_circle_outlined,
      title: FakeMenuData.accountTitle,
      subtitle: FakeMenuData.accountSubtitle,
      onTap: onAccount,
      compact: compact,
    );
  }

  Widget _buildPaymentMethodsRow(bool compact) {
    return _MenuNavRow(
      rowKey: paymentMethodsRowKey,
      icon: Icons.credit_card,
      title: FakeMenuData.paymentMethodsTitle,
      subtitle: FakeMenuData.paymentMethodsSubtitle,
      onTap: onPaymentMethods,
      compact: compact,
    );
  }

  Widget _buildPointsCard(ThemeData theme) {
    return Material(
      color: SariColors.primaryFixed.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: pointsCardKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: onPoints,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(SariRadius.badge),
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 20,
                  color: SariColors.onPrimaryFixed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      FakeMenuData.pointsTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      FakeMenuData.pointsDiscount,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
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

  Widget _buildLogoutRow(ThemeData theme, bool compact) {
    final errorColor = theme.colorScheme.error;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: logoutButtonKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: onLogout,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 8 : 10,
          ),
          child: Row(
            children: [
              Icon(Icons.logout, size: 22, color: errorColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  FakeMenuData.logoutLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: errorColor,
                  ),
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Text(
                FakeMenuData.versionLabel,
                key: versionKey,
                maxLines: 1,
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

class _MenuNavRow extends StatelessWidget {
  const _MenuNavRow({
    required this.rowKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.compact,
  });

  final Key rowKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        key: rowKey,
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: compact ? 10 : 14,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(SariRadius.button),
                ),
                child: Icon(icon, size: 22, color: SariColors.ink),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
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
                color: SariColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
