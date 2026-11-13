import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key, required this.sessionController});

  static const screenKey = Key('phone-login-screen');
  static const phoneFieldKey = Key('phone-login-phone-field');
  static const continueButtonKey = Key('phone-login-continue-button');
  static const clearButtonKey = Key('phone-login-clear-button');
  static const termsLinkKey = Key('phone-login-terms-link');
  static const privacyLinkKey = Key('phone-login-privacy-link');

  final SessionController sessionController;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneController = TextEditingController();

  String get _digits => _phoneController.text.replaceAll(RegExp(r'\D'), '');

  bool get _isValid => _digits.length == 10 && _digits.startsWith('5');

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _clear() {
    _phoneController.clear();
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_isValid) {
      return;
    }
    await widget.sessionController.save(
      Session(phone: '+90$_digits', name: '', surname: ''),
    );
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.otp);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: PhoneLoginScreen.screenKey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      SariSpacing.md,
                      SariSpacing.sm,
                      SariSpacing.md,
                      SariSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Text(
                            'Sarı',
                            style: theme.textTheme.displaySmall,
                          ),
                        ),
                        const SizedBox(height: SariSpacing.lg),
                        Text(
                          'Telefon numaranı gir',
                          style: theme.textTheme.headlineLarge,
                        ),
                        const SizedBox(height: SariSpacing.sm),
                        Text(
                          'Hızlı ve güvenli yolculuklar için tek tıkla '
                          'hesabına eriş.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: SariColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: SariSpacing.xl),
                        _buildPhoneInput(theme),
                        const SizedBox(height: SariSpacing.sm),
                        _buildHelperText(theme),
                        const SizedBox(height: SariSpacing.xl),
                        _buildPromoCard(theme),
                        const Spacer(),
                        const SizedBox(height: SariSpacing.lg),
                        _buildContinueButton(),
                        const SizedBox(height: SariSpacing.md),
                        _buildLegalText(theme),
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

  Widget _buildPhoneInput(ThemeData theme) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: SariSpacing.md),
      decoration: BoxDecoration(
        color: SariColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SariSpacing.sm,
              vertical: SariSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Text(
              '+90',
              style: theme.textTheme.labelMedium?.copyWith(
                color: SariColors.ink,
              ),
            ),
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: SariSpacing.sm),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          Expanded(
            child: TextField(
              key: PhoneLoginScreen.phoneFieldKey,
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              inputFormatters: const [_PhoneNumberFormatter()],
              style: theme.textTheme.labelLarge,
              cursorColor: SariColors.ink,
              decoration: InputDecoration(
                hintText: '5xx xxx xx xx',
                hintStyle: theme.textTheme.labelLarge?.copyWith(
                  color: SariColors.textSecondary,
                ),
                filled: false,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_digits.isNotEmpty)
            IconButton(
              key: PhoneLoginScreen.clearButtonKey,
              onPressed: _clear,
              tooltip: 'Temizle',
              iconSize: 20,
              visualDensity: VisualDensity.compact,
              color: SariColors.textSecondary,
              icon: const Icon(Icons.cancel),
            ),
        ],
      ),
    );
  }

  Widget _buildHelperText(ThemeData theme) {
    return Row(
      children: [
        const Icon(
          Icons.sms_outlined,
          size: 16,
          color: SariColors.textSecondary,
        ),
        const SizedBox(width: SariSpacing.sm),
        Expanded(
          child: Text(
            'Sana bir doğrulama kodu göndereceğiz.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPromoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: SariColors.yellow,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: const Icon(
              Icons.local_taxi,
              size: 18,
              color: SariColors.ink,
            ),
          ),
          const SizedBox(width: SariSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tek dokunuşla Sarı Taksi',
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: SariSpacing.xs),
                Text(
                  'Şehrin dört bir yanında anında sarı taksi kapında.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return FilledButton(
      key: PhoneLoginScreen.continueButtonKey,
      onPressed: _isValid ? _submit : null,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Devam et'),
          SizedBox(width: SariSpacing.sm),
          Icon(Icons.arrow_forward, size: 20),
        ],
      ),
    );
  }

  Widget _buildLegalText(ThemeData theme) {
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      color: SariColors.textSecondary,
    );
    final linkStyle = theme.textTheme.labelSmall?.copyWith(
      color: SariColors.ink,
      decoration: TextDecoration.underline,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Devam ederek ', style: bodyStyle),
        Text(
          'Kullanım Koşulları',
          key: PhoneLoginScreen.termsLinkKey,
          style: linkStyle,
        ),
        Text(' ve ', style: bodyStyle),
        Text(
          'Gizlilik Politikası',
          key: PhoneLoginScreen.privacyLinkKey,
          style: linkStyle,
        ),
        Text("'nı kabul etmiş olursun.", style: bodyStyle),
      ],
    );
  }
}

class _PhoneNumberFormatter extends TextInputFormatter {
  const _PhoneNumberFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();

    for (var index = 0; index < digits.length; index++) {
      if (index == 3 || index == 6 || (index >= 8 && index.isEven)) {
        buffer.write(' ');
      }
      buffer.write(digits[index]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
