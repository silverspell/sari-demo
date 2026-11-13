import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/fake_place.dart';
import '../data/fake_ride_data.dart';
import '../rides/ride_flow_controller.dart';
import '../router/app_routes.dart';
import '../theme/sari_theme.dart';
import '../widgets/coming_soon_snack_bar.dart';

class DestinationScreen extends StatefulWidget {
  const DestinationScreen({super.key, this.flowController});

  static const screenKey = Key('destination-screen');
  static const backButtonKey = Key('destination-back-button');
  static const originRowKey = Key('destination-origin-row');
  static const originPickerKey = Key('destination-origin-picker');
  static const searchFieldKey = Key('destination-search-field');
  static const clearSearchButtonKey = Key('destination-clear-search-button');
  static const mapPickButtonKey = Key('destination-map-pick-button');
  static const clearHistoryButtonKey = Key('destination-clear-history-button');
  static const promoBannerKey = Key('destination-promo-banner');
  static const savedPlacePromptKey = Key('destination-saved-place-prompt');
  static const emptyResultsKey = Key('destination-empty-results');

  static Key historyRowKey(String id) => Key('destination-history-row-$id');
  static Key suggestionRowKey(String id) =>
      Key('destination-suggestion-row-$id');
  static Key resultRowKey(String id) => Key('destination-result-row-$id');

  final RideFlowController? flowController;

  @override
  State<DestinationScreen> createState() => _DestinationScreenState();
}

class _DestinationScreenState extends State<DestinationScreen> {
  final _searchController = TextEditingController();
  RideFlowController? _ownedFlowController;

  RideFlowController get _flowController =>
      widget.flowController ??
      (_ownedFlowController ??= RideFlowController());

  String get _query => _searchController.text.trim();

  bool get _hasQuery => _normalizeSearch(_query).isNotEmpty;

  List<FakePlace> get _results {
    final query = _normalizeSearch(_query);
    return FakeRideData.places.where((place) {
      final haystack = _normalizeSearch('${place.name} ${place.address}');
      return haystack.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ownedFlowController?.dispose();
    super.dispose();
  }

  void _showComingSoon() {
    showComingSoonSnackBar(context);
  }

  void _selectDestination(FakePlace place) {
    _flowController.selectDestination(place);
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      return;
    }
    router.push(AppRoutes.routeFare);
  }

  void _handleBack() {
    final router = GoRouter.maybeOf(context);
    if (router == null) {
      Navigator.maybeOf(context)?.maybePop();
      return;
    }
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _handleSearchChanged(String value) {
    setState(() {});
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: DestinationScreen.screenKey,
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
                    _buildOriginRow(theme),
                    const SizedBox(height: SariSpacing.sm),
                    _buildSearchField(theme),
                    const SizedBox(height: SariSpacing.sm),
                    _buildMapRow(theme),
                    const SizedBox(height: SariSpacing.sm),
                    const Divider(height: 1, color: SariColors.border),
                    const SizedBox(height: SariSpacing.md),
                    if (_hasQuery)
                      ..._buildResults(theme)
                    else
                      ..._buildStatic(theme),
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
            key: DestinationScreen.backButtonKey,
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
          Flexible(
            child: Text(
              'Nereye',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Text(
            '*',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: SariColors.critical,
            ),
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

  Widget _buildOriginRow(ThemeData theme) {
    return Material(
      key: DestinationScreen.originRowKey,
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: _showComingSoon,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 4, 10),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox(
                  width: 10,
                  height: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: SariColors.ink,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SariSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nereden',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Mevcut Konum · Moda, Kadıköy',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                key: DestinationScreen.originPickerKey,
                onPressed: _showComingSoon,
                tooltip: 'Konum seç',
                icon: const Icon(Icons.gps_fixed, size: 20),
                color: SariColors.ink,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.button),
        border: Border.all(color: SariColors.ink, width: 1.5),
      ),
      child: TextField(
        key: DestinationScreen.searchFieldKey,
        controller: _searchController,
        onChanged: _handleSearchChanged,
        textInputAction: TextInputAction.search,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 17),
          hintText: 'Nereye gitmek istersiniz?',
          hintStyle: theme.textTheme.bodyLarge?.copyWith(
            color: SariColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.location_on,
            size: 22,
            color: theme.colorScheme.primaryContainer,
          ),
          suffixIcon: IconButton(
            key: DestinationScreen.clearSearchButtonKey,
            onPressed: _clearSearch,
            tooltip: 'Aramayı temizle',
            icon: Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 15,
                color: SariColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapRow(ThemeData theme) {
    return Row(
      children: [
        Material(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            key: DestinationScreen.mapPickButtonKey,
            borderRadius: BorderRadius.circular(999),
            onTap: _showComingSoon,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: SariColors.ink,
                  ),
                  const SizedBox(width: SariSpacing.xs),
                  Text('Haritadan Seç', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.touch_app_outlined,
                size: 16,
                color: SariColors.textSecondary,
              ),
              const SizedBox(width: SariSpacing.xs),
              Flexible(
                child: Text(
                  'Hızlı Dokun',
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
      ],
    );
  }

  List<Widget> _buildStatic(ThemeData theme) {
    return [
      _buildSectionHeader(
        theme,
        'SON GİDİLENLER',
        action: TextButton(
          key: DestinationScreen.clearHistoryButtonKey,
          onPressed: _showComingSoon,
          style: TextButton.styleFrom(
            foregroundColor: SariColors.textSecondary,
            minimumSize: const Size(0, 36),
            padding: const EdgeInsets.symmetric(horizontal: SariSpacing.sm),
            textStyle: theme.textTheme.bodySmall,
          ),
          child: const Text('Geçmişi Temizle'),
        ),
      ),
      const SizedBox(height: SariSpacing.sm),
      _buildHistoryRow(
        theme,
        place: FakeRideData.kadikoyIskele,
        address: 'Caferağa Mah., Rıhtım Cd., Kadıköy',
        distance: '1.8 km',
        icon: Icons.directions_boat_outlined,
      ),
      const SizedBox(height: SariSpacing.sm),
      _buildHistoryRow(
        theme,
        place: FakeRideData.taksim,
        address: 'Gümüşsuyu, Beyoğlu',
        distance: '12 km',
        icon: Icons.place_outlined,
      ),
      const SizedBox(height: SariSpacing.md),
      _buildPromoBanner(theme),
      const SizedBox(height: SariSpacing.md),
      _buildSectionHeader(theme, 'ÖNERİLER'),
      const SizedBox(height: SariSpacing.sm),
      _buildSuggestionRow(
        theme,
        place: FakeRideData.istanbulHavalimani,
        address: 'Tayakadın, Arnavutköy',
        icon: Icons.flight_outlined,
        badge: 'Hızlı Hat',
      ),
      const SizedBox(height: SariSpacing.sm),
      _buildSuggestionRow(
        theme,
        place: FakeRideData.sabihaGokcen,
        address: 'Sanayi Mah., Pendik',
        icon: Icons.flight_outlined,
      ),
      const SizedBox(height: SariSpacing.sm),
      _buildSuggestionRow(
        theme,
        place: FakeRideData.kanyonAvm,
        address: 'Büyükdere Cd., Levent',
        icon: Icons.shopping_bag_outlined,
        trailing: 'Taksi Standı',
      ),
      const SizedBox(height: SariSpacing.lg),
      _buildSavedPlacePrompt(theme),
    ];
  }

  List<Widget> _buildResults(ThemeData theme) {
    final results = _results;

    return [
      _buildSectionHeader(theme, 'SONUÇLAR'),
      const SizedBox(height: SariSpacing.sm),
      if (results.isEmpty)
        _buildEmptyResults(theme)
      else
        for (var index = 0; index < results.length; index++) ...[
          if (index > 0) const SizedBox(height: SariSpacing.sm),
          _buildResultRow(theme, results[index]),
        ],
    ];
  }

  Widget _buildSectionHeader(ThemeData theme, String title, {Widget? action}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: SariColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ?action,
      ],
    );
  }

  Widget _buildHistoryRow(
    ThemeData theme, {
    required FakePlace place,
    required String address,
    required String distance,
    required IconData icon,
  }) {
    return Material(
      key: DestinationScreen.historyRowKey(place.id),
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: () => _selectDestination(place),
        child: Padding(
          padding: const EdgeInsets.all(SariSpacing.sm + SariSpacing.xs),
          child: Row(
            children: [
              _buildLeadingIcon(theme, icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: SariSpacing.sm),
                        _buildDistanceBadge(theme, distance),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
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
              const Icon(
                Icons.schedule,
                size: 18,
                color: SariColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestionRow(
    ThemeData theme, {
    required FakePlace place,
    required String address,
    required IconData icon,
    String? badge,
    String? trailing,
  }) {
    return Material(
      key: DestinationScreen.suggestionRowKey(place.id),
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: () => _selectDestination(place),
        child: Padding(
          padding: const EdgeInsets.all(SariSpacing.sm + SariSpacing.xs),
          child: Row(
            children: [
              _buildLeadingIcon(theme, icon),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        if (badge != null) ...[
                          const SizedBox(width: SariSpacing.xs),
                          _buildBadge(theme, badge),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: SariColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: SariSpacing.sm),
                Text(
                  trailing,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(width: SariSpacing.xs),
              const Icon(
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

  Widget _buildResultRow(ThemeData theme, FakePlace place) {
    return Material(
      key: DestinationScreen.resultRowKey(place.id),
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(SariRadius.sheet),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        onTap: () => _selectDestination(place),
        child: Padding(
          padding: const EdgeInsets.all(SariSpacing.sm + SariSpacing.xs),
          child: Row(
            children: [
              _buildLeadingIcon(theme, Icons.place_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      place.address,
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
              const Icon(
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

  Widget _buildLeadingIcon(ThemeData theme, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: SariColors.ink),
    );
  }

  Widget _buildDistanceBadge(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(SariRadius.badge),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: theme.textTheme.labelSmall?.copyWith(
          color: SariColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildBadge(ThemeData theme, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }

  Widget _buildPromoBanner(ThemeData theme) {
    return Container(
      key: DestinationScreen.promoBannerKey,
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.surfaceContainerLow,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.22),
          ],
        ),
        borderRadius: BorderRadius.circular(SariRadius.sheet),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ÖZEL FIRSAT',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Havalimanı Sabit Fiyat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  'Sarı taksi ile köprü ve otoyol ücretleri şeffaf dökümlü.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SariSpacing.md),
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_taxi,
              size: 28,
              color: SariColors.ink,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedPlacePrompt(ThemeData theme) {
    return Material(
      key: DestinationScreen.savedPlacePromptKey,
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(SariRadius.button),
      child: InkWell(
        borderRadius: BorderRadius.circular(SariRadius.button),
        onTap: _showComingSoon,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: SariSpacing.md,
            vertical: 14,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.bookmark_border,
                size: 20,
                color: SariColors.textSecondary,
              ),
              const SizedBox(width: SariSpacing.sm),
              Flexible(
                child: Text(
                  'Ev veya İş Yeri adresinizi ekleyin',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyResults(ThemeData theme) {
    return Container(
      key: DestinationScreen.emptyResultsKey,
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.md,
        vertical: SariSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        border: Border.all(color: SariColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              size: 24,
              color: SariColors.textSecondary,
            ),
          ),
          const SizedBox(height: SariSpacing.sm),
          Text('Sonuç bulunamadı', style: theme.textTheme.titleMedium),
          const SizedBox(height: SariSpacing.xs),
          Text(
            'Aramanla eşleşen bir yer bulamadık.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

String _normalizeSearch(String value) {
  final buffer = StringBuffer();
  for (final rune in value.toLowerCase().runes) {
    if (rune == 0x0307) {
      continue;
    }
    var char = String.fromCharCode(rune);
    switch (char) {
      case 'ç':
        char = 'c';
      case 'ğ':
        char = 'g';
      case 'ı':
        char = 'i';
      case 'ö':
        char = 'o';
      case 'ş':
        char = 's';
      case 'ü':
        char = 'u';
    }
    buffer.write(char);
  }
  return buffer.toString();
}
