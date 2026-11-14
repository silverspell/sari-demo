@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _session = Session(
  phone: '+905321234567',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
  location: DefaultLocations.modaKadikoy,
);

void main() {
  goldenTest(
    'Menü',
    fileName: '12-menu',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: menuGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: menuGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget menuGolden(Size size) {
  final controller = SessionController(FakeSessionStore(_session));

  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: HomeScreen(
            sessionController: controller,
            sessionOverride: _session,
            tileProvider: FakeTileProvider(),
            initiallyMenuOpen: true,
          ),
        ),
      ),
    ),
  );
}
