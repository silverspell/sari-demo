@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/account_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _goldenSession = Session(
  phone: '+905321234567',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
);

void main() {
  goldenTest(
    'Hesabım ekranı',
    fileName: '14-account',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: accountGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: accountGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget accountGolden(Size size) {
  final controller = SessionController(FakeSessionStore(_goldenSession));

  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: FutureBuilder<void>(
            future: controller.load(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox.shrink();
              }
              return AccountScreen(sessionController: controller);
            },
          ),
        ),
      ),
    ),
  );
}
