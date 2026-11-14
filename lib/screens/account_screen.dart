import 'package:flutter/material.dart';

import '../data/fake_account_data.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.sessionController});

  static const screenKey = Key('account-screen');
  static const notificationButtonKey = Key('account-notification-button');
  static const headerAvatarButtonKey = Key('account-header-avatar-button');
  static const contentScrollKey = Key('account-content-scroll');
  static const membershipBandKey = Key('account-membership-band');
  static const membershipTitleKey = Key('account-membership-title');
  static const membershipMetaKey = Key('account-membership-meta');
  static const membershipVipKey = Key('account-membership-vip');
  static const avatarKey = Key('account-avatar');
  static const avatarInitialsKey = Key('account-avatar-initials');
  static const photoButtonKey = Key('account-photo-button');
  static const nameTextKey = Key('account-name-text');
  static const emailTextKey = Key('account-email-text');
  static const nameValueKey = Key('account-name-value');
  static const nameStatusKey = Key('account-name-status');
  static const phoneValueKey = Key('account-phone-value');
  static const phoneStatusKey = Key('account-phone-status');
  static const emailValueKey = Key('account-email-value');
  static const savedAddressesRowKey = Key('account-saved-addresses-row');
  static const savedAddressesSubtitleKey = Key(
    'account-saved-addresses-subtitle',
  );
  static const tripPreferencesRowKey = Key('account-trip-preferences-row');
  static const tripPreferencesSubtitleKey = Key(
    'account-trip-preferences-subtitle',
  );
  static const saveButtonKey = Key('account-save-button');
  static const logoutButtonKey = Key('account-logout-button');

  final SessionController sessionController;

  Session? get _session => sessionController.session;

  String get _fullName {
    final name = (_session?.name ?? '').trim();
    final surname = (_session?.surname ?? '').trim();
    final parts = [if (name.isNotEmpty) name, if (surname.isNotEmpty) surname];
    return parts.isEmpty ? 'Misafir' : parts.join(' ');
  }

  String get _initials {
    final name = (_session?.name ?? '').trim();
    final surname = (_session?.surname ?? '').trim();
    if (name.isEmpty && surname.isEmpty) {
      return '?';
    }
    final first = name.isEmpty ? '' : name.substring(0, 1);
    final last = surname.isEmpty ? '' : surname.substring(0, 1);
    return '$first$last'.toUpperCase();
  }

  String get _phone {
    final digits = (_session?.phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('90')) {
      return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} '
          '${digits.substring(5, 8)} ${digits.substring(8, 10)} '
          '${digits.substring(10, 12)}';
    }
    return _session?.phone ?? '';
  }

  Future<void> _handleLogout() async {
    await sessionController.clear();
  }

  void _showComingSoon(BuildContext context) {
    showComingSoonSnackBar(context);
  }

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
              child: SingleChildScrollView(
                key: contentScrollKey,
                padding: const EdgeInsets.fromLTRB(
                  SariSpacing.md,
                  SariSpacing.md,
                  SariSpacing.md,
                  SariSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildMembershipBand(theme),
                    const SizedBox(height: SariSpacing.md),
                    _buildAvatarBlock(context, theme),
                    const SizedBox(height: SariSpacing.md),
                    _buildFieldsCard(theme),
                    const SizedBox(height: SariSpacing.md),
                    _buildShortcuts(context, theme),
                    const SizedBox(height: SariSpacing.lg),
                    _buildSaveButton(context, theme),
                    const SizedBox(height: SariSpacing.xs),
                    _buildLogoutButton(theme),
                  ],
                ),
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
              'Hesabım',
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
            key: headerAvatarButtonKey,
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

  Widget _buildMembershipBand(ThemeData theme) {
    return Container(
      key: membershipBandKey,
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.stars,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  FakeAccountData.membershipTitle,
                  key: membershipTitleKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  FakeAccountData.membershipMeta,
                  key: membershipMetaKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SariSpacing.xs,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.inverseSurface,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Text(
              FakeAccountData.membershipBadge,
              key: membershipVipKey,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onInverseSurface,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarBlock(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                key: avatarKey,
                width: 96,
                height: 96,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SariColors.ink.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  _initials,
                  key: avatarInitialsKey,
                  maxLines: 1,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    key: photoButtonKey,
                    customBorder: const CircleBorder(),
                    onTap: () => _showComingSoon(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.inverseSurface,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.photo_camera,
                        size: 16,
                        color: theme.colorScheme.onInverseSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: SariSpacing.sm),
        Text(
          _fullName,
          key: nameTextKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 2),
        Text(
          FakeAccountData.email,
          key: emailTextKey,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: SariColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldsCard(ThemeData theme) {
    return Container(
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
          _buildField(
            theme,
            label: 'AD SOYAD',
            status: 'DOĞRULANDI',
            statusKey: nameStatusKey,
            value: _fullName,
            valueKey: nameValueKey,
            trailingIcon: Icons.edit,
          ),
          const SizedBox(height: SariSpacing.md),
          _buildField(
            theme,
            label: 'TELEFON',
            status: 'DEĞİŞTİRİLEMEZ',
            statusKey: phoneStatusKey,
            value: _phone,
            valueKey: phoneValueKey,
            trailingIcon: Icons.lock,
            locked: true,
          ),
          const SizedBox(height: SariSpacing.md),
          _buildField(
            theme,
            label: 'E-POSTA ADRESİ',
            value: FakeAccountData.email,
            valueKey: emailValueKey,
            trailingIcon: Icons.mail,
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    ThemeData theme, {
    required String label,
    required String value,
    required Key valueKey,
    required IconData trailingIcon,
    String? status,
    Key? statusKey,
    bool locked = false,
  }) {
    final statusColor = status == 'DOĞRULANDI'
        ? theme.colorScheme.tertiary
        : SariColors.textSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: SariColors.textSecondary,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            if (status != null) ...[
              const SizedBox(width: SariSpacing.sm),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (status == 'DOĞRULANDI') ...[
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: theme.colorScheme.tertiary,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    status,
                    key: statusKey,
                    maxLines: 1,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: SariSpacing.xs),
        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: SariSpacing.md),
          decoration: BoxDecoration(
            color: locked
                ? theme.colorScheme.surfaceContainerHigh
                : theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(SariRadius.button),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  key: valueKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: locked
                      ? theme.textTheme.bodyLarge?.copyWith(
                          color: SariColors.textSecondary,
                        )
                      : theme.textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: SariSpacing.xs),
              Icon(
                trailingIcon,
                size: 20,
                color: locked
                    ? SariColors.textSecondary
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShortcuts(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SariSpacing.sm),
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
        children: [
          _buildShortcutRow(
            context,
            theme,
            key: savedAddressesRowKey,
            icon: Icons.location_on_outlined,
            title: 'Kayıtlı Adresler',
            subtitle: FakeAccountData.savedAddressesSubtitle,
            subtitleKey: savedAddressesSubtitleKey,
          ),
          const SizedBox(height: SariSpacing.xs),
          _buildShortcutRow(
            context,
            theme,
            key: tripPreferencesRowKey,
            icon: Icons.tune,
            title: 'Yolculuk Tercihleri',
            subtitle: FakeAccountData.tripPreferencesSubtitle,
            subtitleKey: tripPreferencesSubtitleKey,
          ),
        ],
      ),
    );
  }

  Widget _buildShortcutRow(
    BuildContext context,
    ThemeData theme, {
    required Key key,
    required IconData icon,
    required String title,
    required String subtitle,
    required Key subtitleKey,
  }) {
    return GestureDetector(
      key: key,
      behavior: HitTestBehavior.opaque,
      onTap: () => _showComingSoon(context),
      child: Padding(
        padding: const EdgeInsets.all(SariSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(SariRadius.badge),
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
            ),
            const SizedBox(width: SariSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    key: subtitleKey,
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
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, ThemeData theme) {
    return SizedBox(
      height: 56,
      child: FilledButton(
        key: saveButtonKey,
        onPressed: () => _showComingSoon(context),
        child: Text(
          'Kaydet',
          maxLines: 1,
          style: theme.textTheme.labelLarge?.copyWith(
            color: SariColors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(ThemeData theme) {
    return TextButton(
      key: logoutButtonKey,
      onPressed: _handleLogout,
      style: TextButton.styleFrom(
        foregroundColor: theme.colorScheme.error,
        minimumSize: const Size.fromHeight(44),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout, size: 18, color: theme.colorScheme.error),
          const SizedBox(width: SariSpacing.xs),
          Text(
            'Çıkış Yap',
            maxLines: 1,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }
}
