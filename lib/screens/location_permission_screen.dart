import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../location/location_service.dart';
import '../permissions/location_permission_service.dart';
import '../router/app_routes.dart';
import '../session/location_point.dart';
import '../session/session.dart';
import '../session/session_controller.dart';
import '../theme/sari_theme.dart';

class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({
    super.key,
    required this.sessionController,
    this.permissionService = const PermissionHandlerLocationPermissionService(),
    this.locationService = const GeolocatorLocationService(),
  });

  static const screenKey = Key('location-permission-screen');
  static const allowButtonKey = Key('location-permission-allow-button');
  static const notNowButtonKey = Key('location-permission-not-now-button');

  final SessionController sessionController;
  final LocationPermissionService permissionService;
  final LocationService locationService;

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {
  bool _submitting = false;

  Future<void> _persist(
    LocationPermissionStatus status,
    LocationPoint location,
  ) async {
    final current = widget.sessionController.session;
    final session = current != null
        ? current.copyWith(locationPermission: status, location: location)
        : Session(
            phone: '',
            name: '',
            surname: '',
            locationPermission: status,
            location: location,
          );

    await widget.sessionController.save(session);
  }

  Future<void> _handleAllow() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);

    final decision = await widget.permissionService.requestPermission();

    var status = LocationPermissionStatus.denied;
    var location = DefaultLocations.modaKadikoy;
    if (decision == LocationPermissionDecision.granted) {
      status = LocationPermissionStatus.granted;
      try {
        final currentLocation = await widget.locationService.currentLocation();
        if (currentLocation != null) {
          location = currentLocation;
        }
      } catch (_) {
        location = DefaultLocations.modaKadikoy;
      }
    }
    if (!mounted) {
      return;
    }

    await _persist(status, location);
    if (!mounted) {
      return;
    }

    context.go(AppRoutes.session);
  }

  Future<void> _handleNotNow() async {
    if (_submitting) {
      return;
    }
    setState(() => _submitting = true);

    await _persist(
      LocationPermissionStatus.denied,
      DefaultLocations.modaKadikoy,
    );
    if (!mounted) {
      return;
    }

    context.go(AppRoutes.session);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      key: LocationPermissionScreen.screenKey,
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
                      compact ? SariSpacing.sm : SariSpacing.md,
                      SariSpacing.md,
                      compact ? SariSpacing.md : SariSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildRadar(theme, compact: compact),
                        SizedBox(
                          height: compact ? SariSpacing.xs : SariSpacing.sm,
                        ),
                        Text(
                          'Konumunu kullanalım',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: SariSpacing.xs),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: SariSpacing.sm,
                          ),
                          child: Text(
                            'Taksini kapına getirebilmemiz ve en hızlı rotayı '
                            'çizebilmemiz için konumuna ihtiyacımız var.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: SariColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: compact ? SariSpacing.sm : SariSpacing.lg,
                        ),
                        _buildBenefitCard(
                          theme: theme,
                          icon: Icons.near_me,
                          iconBackground: theme.colorScheme.primaryContainer
                              .withValues(alpha: 0.3),
                          iconColor: theme.colorScheme.onPrimaryContainer,
                          title: 'En yakın taksiyi anında bul',
                          subtitle: 'Semtindeki aktif sarı taksileri canlı gör',
                        ),
                        const SizedBox(height: SariSpacing.sm),
                        _buildBenefitCard(
                          theme: theme,
                          icon: Icons.touch_app,
                          iconBackground: theme.colorScheme.secondaryContainer,
                          iconColor: theme.colorScheme.onSecondaryContainer,
                          title: 'Adres yazmadan tek tıkla çağır',
                          subtitle:
                              'Olduğun noktaya saniyeler içinde araç '
                              'yönlendir',
                        ),
                        SizedBox(
                          height: compact ? SariSpacing.sm : SariSpacing.lg,
                        ),
                        _buildTrustNote(theme),
                        const Spacer(),
                        SizedBox(
                          height: compact ? SariSpacing.sm : SariSpacing.lg,
                        ),
                        _buildAllowButton(),
                        SizedBox(
                          height: compact ? SariSpacing.xs : SariSpacing.sm,
                        ),
                        _buildNotNowButton(theme),
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

  Widget _buildRadar(ThemeData theme, {required bool compact}) {
    final height = compact ? 156.0 : 236.0;
    final outerSize = compact ? 144.0 : 220.0;
    final middleSize = compact ? 108.0 : 176.0;
    final haloSize = compact ? 84.0 : 128.0;
    final targetSize = compact ? 60.0 : 80.0;

    return SizedBox(
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildRing(
            size: outerSize,
            color: theme.colorScheme.surfaceContainerHigh.withValues(
              alpha: 0.6,
            ),
          ),
          _buildRing(
            size: middleSize,
            color: theme.colorScheme.surfaceContainer,
          ),
          _buildRing(
            size: haloSize,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          ),
          _buildRing(
            size: targetSize,
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
          ),
          _buildPin(theme),
          Positioned(
            bottom: compact ? SariSpacing.xs : SariSpacing.sm,
            right: SariSpacing.xs,
            child: _buildGpsBadge(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildRing({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildPin(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SariColors.ink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: SariColors.ink.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi,
                  size: 28,
                  color: SariColors.ink,
                ),
              ),
            ),
            Positioned(
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SariSpacing.xs,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: SariColors.ink.withValues(alpha: 0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  'TAKSİ',
                  style: sariPlateStyle.copyWith(color: SariColors.ink),
                ),
              ),
            ),
          ],
        ),
        Transform.translate(
          offset: const Offset(0, -1),
          child: SizedBox(
            width: 18,
            height: 14,
            child: CustomPaint(painter: _PinTrianglePainter(SariColors.ink)),
          ),
        ),
        Container(
          width: 32,
          height: 8,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: SariColors.ink.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ],
    );
  }

  Widget _buildGpsBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SariSpacing.md,
        vertical: SariSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
            'GPS Hazır',
            style: theme.textTheme.labelSmall?.copyWith(color: SariColors.ink),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard({
    required ThemeData theme,
    required IconData icon,
    required Color iconBackground,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(SariSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(SariRadius.sheet),
        boxShadow: [
          BoxShadow(
            color: SariColors.ink.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(SariRadius.badge),
            ),
            child: Icon(icon, size: 22, color: iconColor),
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
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: SariColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: SariColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: SariSpacing.sm),
          Icon(Icons.check_circle, size: 20, color: theme.colorScheme.tertiary),
        ],
      ),
    );
  }

  Widget _buildTrustNote(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.verified_user_outlined,
          size: 16,
          color: SariColors.textSecondary,
        ),
        const SizedBox(width: SariSpacing.xs),
        Flexible(
          child: Text(
            'Konumun yalnızca yolculuk süresince paylaşılır',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: SariColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllowButton() {
    return FilledButton(
      key: LocationPermissionScreen.allowButtonKey,
      onPressed: _submitting ? null : _handleAllow,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.my_location, size: 20),
          SizedBox(width: SariSpacing.sm),
          Text('Konumu aç'),
        ],
      ),
    );
  }

  Widget _buildNotNowButton(ThemeData theme) {
    return TextButton(
      key: LocationPermissionScreen.notNowButtonKey,
      onPressed: _submitting ? null : _handleNotNow,
      style: TextButton.styleFrom(
        foregroundColor: SariColors.textSecondary,
        minimumSize: const Size.fromHeight(44),
        textStyle: theme.textTheme.labelMedium,
      ),
      child: const Text('Şimdi değil'),
    );
  }
}

class _PinTrianglePainter extends CustomPainter {
  const _PinTrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _PinTrianglePainter oldDelegate) =>
      oldDelegate.color != color;
}
