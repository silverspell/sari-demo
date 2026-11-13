import 'package:flutter/material.dart';

import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';

class SessionPlaceholderScreen extends StatelessWidget {
  const SessionPlaceholderScreen({
    super.key,
    required this.sessionController,
    this.sessionOverride,
  });

  static const screenKey = Key('session-placeholder-screen');
  static const greetingTextKey = Key('session-placeholder-greeting');
  static const logoutButtonKey = Key('session-placeholder-logout-button');

  final SessionController sessionController;
  final Session? sessionOverride;

  Session? get _session => sessionOverride ?? sessionController.session;

  String get _displayName {
    final session = _session;
    if (session == null) {
      return 'Yolcu';
    }
    final parts = [session.name.trim(), session.surname.trim()]
        .where((part) => part.isNotEmpty)
        .toList();
    return parts.isEmpty ? 'Yolcu' : parts.join(' ');
  }

  String get _phone {
    final phone = _session?.phone.trim() ?? '';
    return phone.isEmpty ? '—' : phone;
  }

  Future<void> _handleLogout() async {
    await sessionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: screenKey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      SariSpacing.md,
                      compact ? SariSpacing.md : SariSpacing.lg,
                      SariSpacing.md,
                      compact ? SariSpacing.md : SariSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: _buildStatusPill(theme)),
                        SizedBox(
                          height: compact ? SariSpacing.md : SariSpacing.lg,
                        ),
                        Center(child: _buildAvatar(theme, compact: compact)),
                        SizedBox(
                          height: compact ? SariSpacing.md : SariSpacing.lg,
                        ),
                        Text(
                          'Merhaba, $_displayName',
                          key: greetingTextKey,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: SariSpacing.xs),
                        Text(
                          'Oturumun açık. Yolculuğa çıkmaya hazır olduğunda '
                          'devam edebilirsin.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: SariColors.textSecondary,
                          ),
                        ),
                        SizedBox(
                          height: compact ? SariSpacing.sm : SariSpacing.lg,
                        ),
                        _buildPhoneCard(theme),
                        const Spacer(),
                        SizedBox(
                          height: compact ? SariSpacing.md : SariSpacing.lg,
                        ),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusPill(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.md,
        vertical: SariSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: SariColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: SariColors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: SariSpacing.xs),
          Text(
            'Oturum açık',
            style: theme.textTheme.labelSmall?.copyWith(color: SariColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, {required bool compact}) {
    final size = compact ? 88.0 : 108.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: SariColors.ink.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.person,
            size: size * 0.5,
            color: SariColors.ink,
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.surfaceContainerLowest,
                width: 3,
              ),
            ),
            child: const Icon(
              Icons.check,
              size: 16,
              color: SariColors.surface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        border: Border.all(color: SariColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Icon(
              Icons.phone_outlined,
              size: 22,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telefon numarası',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _phone,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: SariColors.ink,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return FilledButton(
      key: logoutButtonKey,
      onPressed: _handleLogout,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SariRadius.button),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.logout, size: 20),
          SizedBox(width: SariSpacing.sm),
          Text('Çıkış yap'),
        ],
      ),
    );
  }
}
