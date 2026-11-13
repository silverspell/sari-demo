import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../theme/sari_theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    this.phone,
    this.initialCode,
    this.initialError = false,
  });

  static const screenKey = Key('otp-screen');
  static const fallbackPhone = '+90 532 123 45 67';
  static const errorBannerKey = Key('otp-error-banner');
  static const clearButtonKey = Key('otp-clear-button');
  static const verifyButtonKey = Key('otp-verify-button');
  static const backButtonKey = Key('otp-back-button');

  static Key digitKey(int index) => Key('otp-digit-$index');

  final String? phone;
  final String? initialCode;
  final bool initialError;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  static const _correctCode = '1234';

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  late bool _showError;

  @override
  void initState() {
    super.initState();
    final code = widget.initialCode ?? '';
    _controllers = List.generate(
      4,
      (index) => TextEditingController(
        text: index < code.length ? code[index] : '',
      ),
    );
    _focusNodes = List.generate(4, (_) => FocusNode());
    _showError = widget.initialError;
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _enteredCode => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  void _verify() {
    if (_enteredCode == _correctCode) {
      setState(() => _showError = false);
      context.go(AppRoutes.name);
      return;
    }
    setState(() => _showError = true);
  }

  void _clear() {
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() => _showError = false);
    _focusNodes.first.requestFocus();
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  String get _subtitlePhone {
    final digits = (widget.phone ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('90')) {
      return '+${digits.substring(0, 2)} ${digits.substring(2, 5)} '
          '${digits.substring(5, 8)} ${digits.substring(8, 10)} '
          '${digits.substring(10, 12)}';
    }
    return OtpScreen.fallbackPhone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      key: OtpScreen.screenKey,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SariSpacing.md,
            SariSpacing.sm,
            SariSpacing.md,
            SariSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [_buildBackButton(), _buildSmsBadge(theme)],
              ),
              const SizedBox(height: SariSpacing.sm),
              Text('Kodu gir', style: theme.textTheme.headlineLarge),
              const SizedBox(height: SariSpacing.xs),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: _subtitlePhone,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: SariColors.ink,
                      ),
                    ),
                    TextSpan(
                      text: ' numarasına gönderildi',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SariSpacing.lg),
              _buildDigitBoxes(theme),
              if (_showError) ...[
                const SizedBox(height: SariSpacing.sm),
                _buildErrorBanner(theme, colors),
              ],
              const SizedBox(height: SariSpacing.md),
              _buildResendRow(theme),
              const SizedBox(height: SariSpacing.lg),
              FilledButton(
                key: OtpScreen.verifyButtonKey,
                onPressed: _verify,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Doğrula'),
                    const SizedBox(width: SariSpacing.sm),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: SariSpacing.md),
              _buildHelpRow(theme, colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      key: OtpScreen.backButtonKey,
      onPressed: _back,
      tooltip: 'Geri dön',
      iconSize: 22,
      style: IconButton.styleFrom(
        backgroundColor: SariColors.surfaceSecondary,
        foregroundColor: SariColors.ink,
        fixedSize: const Size(40, 40),
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
      ),
      icon: const Icon(Icons.chevron_left),
    );
  }

  Widget _buildSmsBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.sm,
        vertical: SariSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: SariColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(999),
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
            'SMS ile Doğrulama',
            style: theme.textTheme.labelSmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDigitBoxes(ThemeData theme) {
    return Row(
      children: [
        for (var index = 0; index < _controllers.length; index++) ...[
          if (index > 0) const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: SizedBox(
              height: 72,
              child: TextField(
                key: OtpScreen.digitKey(index),
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
                cursorColor: SariColors.ink,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: _showError ? SariColors.critical : SariColors.ink,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '•',
                  hintStyle: theme.textTheme.headlineMedium?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                  filled: true,
                  fillColor: _showError
                      ? theme.colorScheme.errorContainer.withValues(alpha: 0.4)
                      : SariColors.surface,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SariRadius.button),
                    borderSide: BorderSide(
                      color: _showError ? SariColors.critical : SariColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SariRadius.button),
                    borderSide: BorderSide(
                      color: _showError ? SariColors.critical : SariColors.ink,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) => _onDigitChanged(index, value),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildErrorBanner(ThemeData theme, ColorScheme colors) {
    return Container(
      key: OtpScreen.errorBannerKey,
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.sm,
        vertical: SariSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.errorContainer,
        borderRadius: BorderRadius.circular(SariRadius.badge),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, size: 20, color: SariColors.critical),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Text(
              'Kod hatalı, tekrar dene.',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.error,
              ),
            ),
          ),
          TextButton(
            key: OtpScreen.clearButtonKey,
            onPressed: _clear,
            style: TextButton.styleFrom(
              foregroundColor: colors.onErrorContainer,
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(
                horizontal: SariSpacing.xs,
                vertical: SariSpacing.xs,
              ),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              textStyle: theme.textTheme.labelSmall,
            ),
            child: Text(
              'Temizle',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onErrorContainer,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResendRow(ThemeData theme) {
    final style = theme.textTheme.labelMedium?.copyWith(
      color: SariColors.textSecondary,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.update, size: 18, color: SariColors.textSecondary),
        const SizedBox(width: SariSpacing.xs),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'Kodu tekrar gönder (', style: style),
              TextSpan(
                text: '0:28',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: SariColors.ink,
                ),
              ),
              TextSpan(text: ')', style: style),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpRow(ThemeData theme, ColorScheme colors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Mesaj ulaşmadı mı?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: SariColors.textSecondary,
          ),
        ),
        TextButton.icon(
          onPressed: () {},
          style: TextButton.styleFrom(
            foregroundColor: colors.primary,
            minimumSize: Size.zero,
            padding: EdgeInsets.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: theme.textTheme.labelMedium,
          ),
          icon: const Icon(Icons.call, size: 16),
          label: const Text('Beni ara'),
        ),
      ],
    );
  }
}
