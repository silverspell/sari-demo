import 'package:flutter/material.dart';

import '../data/fake_ride_data.dart';
import '../data/payment_method.dart';
import '../payments/payment_method_controller.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key, this.paymentMethodController});

  static const screenKey = Key('payment-methods-screen');
  static const scrollViewKey = Key('payment-methods-scroll');
  static const notificationButtonKey = Key(
    'payment-methods-notification-button',
  );
  static const avatarButtonKey = Key('payment-methods-avatar-button');
  static const walletCardKey = Key('payment-methods-wallet-card');
  static const walletLabelKey = Key('payment-methods-wallet-label');
  static const walletBalanceKey = Key('payment-methods-wallet-balance');
  static const walletAutoLoadKey = Key('payment-methods-wallet-auto-load');
  static const topUpButtonKey = Key('payment-methods-top-up-button');
  static const methodListKey = Key('payment-methods-list');
  static const securityCardKey = Key('payment-methods-security-card');
  static const securityTitleKey = Key('payment-methods-security-title');
  static const securityBodyKey = Key('payment-methods-security-body');
  static const corporateCardKey = Key('payment-methods-corporate-card');
  static const corporateSubtitleKey = Key('payment-methods-corporate-subtitle');
  static const updateButtonKey = Key('payment-methods-update-button');

  static Key methodRowKey(String id) => Key('payment-methods-row-$id');

  static Key methodLabelKey(String id) => Key('payment-methods-label-$id');

  static Key methodSubtitleKey(String id) =>
      Key('payment-methods-subtitle-$id');

  static Key methodDefaultBadgeKey(String id) =>
      Key('payment-methods-default-badge-$id');

  static Key methodRadioKey(String id) => Key('payment-methods-radio-$id');

  static Key methodRadioDotKey(String id) =>
      Key('payment-methods-radio-dot-$id');

  static Key methodBrandKey(String id) => Key('payment-methods-brand-$id');

  final PaymentMethodController? paymentMethodController;

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  PaymentMethodController? _ownedPaymentMethodController;

  PaymentMethodController get _payments =>
      widget.paymentMethodController ?? _ownedPaymentMethodController!;

  @override
  void initState() {
    super.initState();
    if (widget.paymentMethodController == null) {
      _ownedPaymentMethodController = PaymentMethodController();
    }
  }

  @override
  void dispose() {
    _ownedPaymentMethodController?.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: PaymentMethodsScreen.screenKey,
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Expanded(
              child: ListenableBuilder(
                listenable: _payments,
                builder: (context, _) => _buildContent(context, theme),
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
              'Ödeme Yöntemleri',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ),
          IconButton(
            key: PaymentMethodsScreen.notificationButtonKey,
            onPressed: _showComingSoon,
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none),
            color: SariColors.ink,
          ),
          const SizedBox(width: SariSpacing.xs),
          InkWell(
            key: PaymentMethodsScreen.avatarButtonKey,
            customBorder: const CircleBorder(),
            onTap: _showComingSoon,
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

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      key: PaymentMethodsScreen.scrollViewKey,
      padding: const EdgeInsets.fromLTRB(
        SariSpacing.md,
        SariSpacing.md,
        SariSpacing.md,
        SariSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTitleRow(theme),
          const SizedBox(height: SariSpacing.md),
          _buildWalletCard(theme),
          const SizedBox(height: SariSpacing.lg),
          _buildMethodList(theme),
          const SizedBox(height: SariSpacing.lg),
          _buildSecurityCard(theme),
          const SizedBox(height: SariSpacing.md),
          _buildCorporateCard(theme),
          const SizedBox(height: SariSpacing.lg),
          _buildUpdateButton(theme),
        ],
      ),
    );
  }

  Widget _buildTitleRow(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ödeme Yöntemleri',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: SariSpacing.xs),
              Text(
                'Yolculuklarınız için tercih edilen tahsilat yöntemi',
                maxLines: 2,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SariSpacing.sm),
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.security,
            size: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard(ThemeData theme) {
    return Container(
      key: PaymentMethodsScreen.walletCardKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SariRadius.button),
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerHigh,
            theme.colorScheme.surfaceContainer,
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SariRadius.button),
        child: Stack(
          children: [
            Positioned(
              right: -24,
              bottom: -32,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(SariSpacing.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SARI CÜZDAN BAKİYESİ',
                          key: PaymentMethodsScreen.walletLabelKey,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: SariColors.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: SariSpacing.xs),
                        Text(
                          FakeRideData.walletBalanceLabel,
                          key: PaymentMethodsScreen.walletBalanceKey,
                          maxLines: 1,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: SariSpacing.xs),
                        Row(
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
                            Flexible(
                              child: Text(
                                FakeRideData.walletAutoTopUpLabel,
                                key: PaymentMethodsScreen.walletAutoLoadKey,
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
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      key: PaymentMethodsScreen.topUpButtonKey,
                      onPressed: _showComingSoon,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        foregroundColor: theme.colorScheme.onPrimaryContainer,
                        minimumSize: const Size(0, 40),
                        padding: const EdgeInsets.symmetric(
                          horizontal: SariSpacing.md,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            SariRadius.button,
                          ),
                        ),
                        textStyle: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: SariSpacing.xs),
                          Text(
                            'Yükle',
                            maxLines: 1,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildMethodList(ThemeData theme) {
    final methods = _payments.methods;

    return Column(
      key: PaymentMethodsScreen.methodListKey,
      children: [
        for (var index = 0; index < methods.length; index++) ...[
          if (index > 0) const SizedBox(height: SariSpacing.sm),
          _buildMethodRow(theme, methods[index]),
        ],
      ],
    );
  }

  Widget _buildMethodRow(ThemeData theme, PaymentMethod method) {
    final selected = _payments.selected == method;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: PaymentMethodsScreen.methodRowKey(method.id),
        onTap: () => _payments.select(method),
        borderRadius: BorderRadius.circular(SariRadius.button),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.all(SariSpacing.md),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(SariRadius.button),
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildBrandBadge(theme, method),
              const SizedBox(width: SariSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _methodTitle(method),
                            key: PaymentMethodsScreen.methodLabelKey(method.id),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium,
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: SariSpacing.sm),
                          Container(
                            key: PaymentMethodsScreen.methodDefaultBadgeKey(
                              method.id,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: SariSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                SariRadius.badge,
                              ),
                            ),
                            child: Text(
                              'Varsayılan',
                              maxLines: 1,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _methodSubtitle(method),
                      key: PaymentMethodsScreen.methodSubtitleKey(method.id),
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
                key: PaymentMethodsScreen.methodRadioKey(method.id),
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? theme.colorScheme.inverseSurface
                      : theme.colorScheme.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                child: Container(
                  key: PaymentMethodsScreen.methodRadioDotKey(method.id),
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: selected
                        ? theme.colorScheme.primaryContainer
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandBadge(ThemeData theme, PaymentMethod method) {
    final isVisa = method.id == FakeRideData.visa4242.id;
    final isMastercard = method.id == FakeRideData.mastercard5310.id;

    return Container(
      key: PaymentMethodsScreen.methodBrandKey(method.id),
      width: 48,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isVisa
            ? theme.colorScheme.surfaceContainerLowest
            : theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SariRadius.badge),
        boxShadow: isVisa
            ? [
                BoxShadow(
                  color: SariColors.ink.withValues(alpha: 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ]
            : null,
      ),
      child: isVisa
          ? Text(
              'VISA',
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: SariColors.visaBlue,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                letterSpacing: 0.2,
              ),
            )
          : isMastercard
          ? SizedBox(
              width: 26,
              height: 16,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: SariColors.mastercardRed.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: SariColors.mastercardOrange.withValues(
                          alpha: 0.9,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Icon(
              Icons.payments,
              size: 22,
              color: theme.colorScheme.onSurfaceVariant,
            ),
    );
  }

  Widget _buildSecurityCard(ThemeData theme) {
    return Container(
      key: PaymentMethodsScreen.securityCardKey,
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
              Icon(
                Icons.verified_user,
                size: 20,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(width: SariSpacing.sm),
              Expanded(
                child: Text(
                  'Güvenli İşlem Garantisi',
                  key: PaymentMethodsScreen.securityTitleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: SariSpacing.sm),
          Text(
            'Kart bilgileriniz BDDK ve PCI-DSS standartlarına uygun şifreli '
            'altyapıda saklanmaktadır. Sarı hiçbir zaman tam kart numaranıza '
            'erişmez.',
            key: PaymentMethodsScreen.securityBodyKey,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorporateCard(ThemeData theme) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: PaymentMethodsScreen.corporateCardKey,
        onTap: _showComingSoon,
        borderRadius: BorderRadius.circular(SariRadius.button),
        child: Container(
          padding: const EdgeInsets.all(SariSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SariRadius.button),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(SariRadius.badge),
                ),
                child: Icon(
                  Icons.receipt,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: SariSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kurumsal Fatura',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'E-arşiv bilgileriniz kayıtlı',
                      key: PaymentMethodsScreen.corporateSubtitleKey,
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
                Icons.chevron_right,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpdateButton(ThemeData theme) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        key: PaymentMethodsScreen.updateButtonKey,
        onPressed: _showComingSoon,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SariRadius.button),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 22,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: SariSpacing.sm),
            Text(
              'Yöntemi Güncelle',
              maxLines: 1,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _methodTitle(PaymentMethod method) =>
    method.isCash ? method.label : '${method.label} ${method.brand}';

String _methodSubtitle(PaymentMethod method) => method.isCash
    ? 'Sürücüye elden ödeme'
    : 'Son Kullanma: ${method.expiryLabel}';
