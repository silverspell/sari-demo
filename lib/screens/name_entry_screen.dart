import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_routes.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';

class NameEntryScreen extends StatefulWidget {
  const NameEntryScreen({
    super.key,
    required this.sessionController,
    this.phone,
    this.initialName = '',
    this.initialSurname = '',
  });

  static const screenKey = Key('name-entry-screen');
  static const backButtonKey = Key('name-entry-back-button');
  static const helpButtonKey = Key('name-entry-help-button');
  static const previewTextKey = Key('name-entry-preview-text');
  static const firstNameFieldKey = Key('name-entry-first-name-field');
  static const lastNameFieldKey = Key('name-entry-last-name-field');
  static const clearFirstNameKey = Key('name-entry-clear-first-name');
  static const clearLastNameKey = Key('name-entry-clear-last-name');
  static const continueButtonKey = Key('name-entry-continue-button');
  static const stepIndicatorKey = Key('name-entry-step-indicator');

  static const chips = ['Kaptan Cem', 'Yolcu Cem', 'Av. Cem Güler'];

  static Key stepDotKey(int index) => Key('name-entry-step-dot-$index');

  static Key chipKey(String label) => Key('name-entry-chip-$label');

  final SessionController sessionController;
  final String? phone;
  final String initialName;
  final String initialSurname;

  @override
  State<NameEntryScreen> createState() => _NameEntryScreenState();
}

class _NameEntryScreenState extends State<NameEntryScreen> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _firstNameFocus = FocusNode();
  final _lastNameFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.initialName);
    _lastNameController = TextEditingController(text: widget.initialSurname);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    super.dispose();
  }

  String get _trimmedName => _firstNameController.text.trim();

  String get _preview {
    final name = _trimmedName;
    if (name.isEmpty) {
      return '"Sürücü sizi bekliyor!"';
    }
    return '"Merhaba $name Bey!"';
  }

  bool get _canContinue => _trimmedName.isNotEmpty;

  void _selectChip(String label) {
    _firstNameController.text = label;
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_canContinue) {
      return;
    }

    final name = _trimmedName;
    final surname = _lastNameController.text.trim();
    final current = widget.sessionController.session;
    final session = current != null
        ? current.copyWith(name: name, surname: surname)
        : Session(phone: widget.phone ?? '', name: name, surname: surname);

    await widget.sessionController.save(session);
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.locationPermission);
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.otp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: NameEntryScreen.screenKey,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 720;
            final fieldHeight = compact ? 48.0 : 52.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                SariSpacing.md,
                compact ? SariSpacing.xs : SariSpacing.sm,
                SariSpacing.md,
                compact ? SariSpacing.sm : SariSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildTopBar(theme),
                  SizedBox(height: compact ? SariSpacing.xs : SariSpacing.sm),
                  _buildHeader(theme),
                  SizedBox(height: compact ? 12 : SariSpacing.md),
                  _buildPreviewBubble(theme),
                  SizedBox(height: compact ? 12 : SariSpacing.md),
                  _buildNameField(
                    theme: theme,
                    label: 'Ad',
                    sideLabel: 'Zorunlu',
                    hint: 'Örn: Cem',
                    fieldKey: NameEntryScreen.firstNameFieldKey,
                    clearKey: NameEntryScreen.clearFirstNameKey,
                    clearTooltip: 'Adı temizle',
                    controller: _firstNameController,
                    focusNode: _firstNameFocus,
                    textInputAction: TextInputAction.next,
                    height: fieldHeight,
                  ),
                  SizedBox(height: compact ? SariSpacing.sm : 12),
                  _buildNameField(
                    theme: theme,
                    label: 'Soyad',
                    sideLabel: 'İsteğe bağlı',
                    hint: 'Örn: Güler',
                    fieldKey: NameEntryScreen.lastNameFieldKey,
                    clearKey: NameEntryScreen.clearLastNameKey,
                    clearTooltip: 'Soyadı temizle',
                    controller: _lastNameController,
                    focusNode: _lastNameFocus,
                    textInputAction: TextInputAction.done,
                    height: fieldHeight,
                  ),
                  SizedBox(height: compact ? SariSpacing.sm : 12),
                  _buildKvkkNote(theme),
                  SizedBox(height: compact ? 12 : SariSpacing.md),
                  _buildChips(theme),
                  SizedBox(height: compact ? 12 : SariSpacing.md),
                  _buildContinueButton(),
                  SizedBox(height: compact ? SariSpacing.sm : 12),
                  _buildFooter(theme),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          key: NameEntryScreen.backButtonKey,
          onPressed: _back,
          tooltip: 'Geri dön',
          iconSize: 22,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            foregroundColor: SariColors.ink,
            fixedSize: const Size(40, 40),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.chevron_left),
        ),
        _buildStepIndicator(theme),
        IconButton(
          key: NameEntryScreen.helpButtonKey,
          onPressed: () {},
          tooltip: 'Yardım',
          iconSize: 20,
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surfaceContainer,
            foregroundColor: SariColors.textSecondary,
            fixedSize: const Size(40, 40),
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
          ),
          icon: const Icon(Icons.help_outline),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(ThemeData theme) {
    return Container(
      key: NameEntryScreen.stepIndicatorKey,
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.sm,
        vertical: SariSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < 4; index++) ...[
            if (index > 0) const SizedBox(width: SariSpacing.xs),
            Container(
              key: NameEntryScreen.stepDotKey(index),
              width: index == 2 ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _stepDotColor(theme, index),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _stepDotColor(ThemeData theme, int index) {
    if (index < 2) {
      return theme.colorScheme.primaryContainer;
    }
    if (index == 2) {
      return SariColors.ink;
    }
    return theme.colorScheme.secondaryContainer;
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SariSpacing.sm,
                  vertical: SariSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: SariSpacing.xs),
                    Text(
                      'Profil Oluşturma',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SariSpacing.xs),
              Text(
                'Seni nasıl çağıralım?',
                style: theme.textTheme.headlineLarge,
              ),
              const SizedBox(height: SariSpacing.xs),
              Text(
                'Sürücünün seni tanıması için adını ve soyadını bilmesi '
                'gerekiyor.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: SariColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SariSpacing.sm),
        _buildAvatar(theme),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(SariRadius.sheet),
            ),
            child: const Icon(
              Icons.account_circle_outlined,
              size: 30,
              color: SariColors.ink,
            ),
          ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: SariColors.ink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewBubble(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_taxi,
              size: 20,
              color: SariColors.ink,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kaptan sürücünün ekranında:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
                Text(
                  _preview,
                  key: NameEntryScreen.previewTextKey,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: SariColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          const Icon(
            Icons.visibility_outlined,
            size: 18,
            color: SariColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildNameField({
    required ThemeData theme,
    required String label,
    required String sideLabel,
    required String hint,
    required Key fieldKey,
    required Key clearKey,
    required String clearTooltip,
    required TextEditingController controller,
    required FocusNode focusNode,
    required TextInputAction textInputAction,
    required double height,
  }) {
    final hasText = controller.text.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelMedium),
            Text(
              sideLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: SariColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: height,
          child: TextField(
            key: fieldKey,
            controller: controller,
            focusNode: focusNode,
            textInputAction: textInputAction,
            style: theme.textTheme.labelLarge,
            cursorColor: SariColors.ink,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: SariColors.textSecondary,
              ),
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHigh,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: SariSpacing.md,
                vertical: SariSpacing.sm,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SariRadius.button),
                borderSide: const BorderSide(color: SariColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SariRadius.button),
                borderSide: const BorderSide(color: SariColors.ink, width: 1.5),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 40,
              ),
              suffixIcon: hasText
                  ? IconButton(
                      key: clearKey,
                      onPressed: () {
                        controller.clear();
                        setState(() {});
                        focusNode.requestFocus();
                      },
                      tooltip: clearTooltip,
                      iconSize: 20,
                      visualDensity: VisualDensity.compact,
                      color: SariColors.textSecondary,
                      icon: const Icon(Icons.cancel),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKvkkNote(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SariSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SariRadius.button),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 18,
            color: theme.colorScheme.tertiary,
          ),
          const SizedBox(width: SariSpacing.sm),
          Expanded(
            child: Text(
              'Bilgilerin KVKK kapsamında güvendedir. Yalnızca yolculuk '
              'anında eşleşen sürücüyle paylaşılır.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: SariColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChips(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sık kullanılan hitaplar',
          style: theme.textTheme.labelSmall?.copyWith(
            color: SariColors.textSecondary,
          ),
        ),
        const SizedBox(height: SariSpacing.sm),
        Wrap(
          spacing: SariSpacing.sm,
          runSpacing: SariSpacing.sm,
          children: [
            for (final label in NameEntryScreen.chips)
              InkWell(
                key: NameEntryScreen.chipKey(label),
                onTap: () => _selectChip(label),
                borderRadius: BorderRadius.circular(SariRadius.badge),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SariSpacing.sm,
                    vertical: SariSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(SariRadius.badge),
                  ),
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: SariColors.ink,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return FilledButton(
      key: NameEntryScreen.continueButtonKey,
      onPressed: _canContinue ? _submit : null,
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

  Widget _buildFooter(ThemeData theme) {
    return Center(
      child: Text(
        'Adım 3 / 4 • Profil Doğrulama',
        style: theme.textTheme.bodySmall?.copyWith(
          color: SariColors.textSecondary,
        ),
      ),
    );
  }
}
