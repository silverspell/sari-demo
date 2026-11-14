import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_account_data.dart';
import 'package:sari/screens/account_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _completedSession = Session(
  phone: '+905321234567',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
);

Future<SessionController> _seededController() async {
  final controller = SessionController(FakeSessionStore(_completedSession));
  await controller.load();
  return controller;
}

Future<void> pumpAccount(
  WidgetTester tester, {
  SessionController? sessionController,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final controller = sessionController ?? await _seededController();

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: AccountScreen(sessionController: controller),
    ),
  );
  await tester.pump();
}

String textAt(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? '';
}

Future<void> tapAndExpectComingSoon(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('Yakında'), findsOneWidget);

  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('AC1: üyelik, avatar ve salt okunur hesap alanlarını gösterir', (
    tester,
  ) async {
    await pumpAccount(tester);

    expect(find.byKey(AccountScreen.screenKey), findsOneWidget);
    expect(find.text('Hesabım'), findsOneWidget);

    expect(find.byKey(AccountScreen.membershipBandKey), findsOneWidget);
    expect(
      textAt(tester, AccountScreen.membershipTitleKey),
      FakeAccountData.membershipTitle,
    );
    expect(
      textAt(tester, AccountScreen.membershipMetaKey),
      '32 yolculuk • 4,98 yolcu puanı',
    );
    expect(
      textAt(tester, AccountScreen.membershipVipKey),
      FakeAccountData.membershipBadge,
    );

    expect(find.byKey(AccountScreen.avatarKey), findsOneWidget);
    expect(textAt(tester, AccountScreen.avatarInitialsKey), 'CG');
    expect(find.byKey(AccountScreen.photoButtonKey), findsOneWidget);
    expect(find.byIcon(Icons.photo_camera), findsOneWidget);

    expect(textAt(tester, AccountScreen.nameValueKey), 'Cem Güler');
    expect(textAt(tester, AccountScreen.nameStatusKey), 'DOĞRULANDI');
    expect(textAt(tester, AccountScreen.phoneValueKey), '+90 532 123 45 67');
    expect(textAt(tester, AccountScreen.phoneStatusKey), 'DEĞİŞTİRİLEMEZ');
    expect(textAt(tester, AccountScreen.emailValueKey), FakeAccountData.email);
    expect(find.text('E-POSTA ADRESİ'), findsOneWidget);

    expect(find.byKey(AccountScreen.savedAddressesRowKey), findsOneWidget);
    expect(find.text('Kayıtlı Adresler'), findsOneWidget);
    expect(
      textAt(tester, AccountScreen.savedAddressesSubtitleKey),
      FakeAccountData.savedAddressesSubtitle,
    );
    expect(find.byKey(AccountScreen.tripPreferencesRowKey), findsOneWidget);
    expect(find.text('Yolculuk Tercihleri'), findsOneWidget);
    expect(
      textAt(tester, AccountScreen.tripPreferencesSubtitleKey),
      FakeAccountData.tripPreferencesSubtitle,
    );

    expect(find.byKey(AccountScreen.saveButtonKey), findsOneWidget);
    expect(find.text('Kaydet'), findsOneWidget);
    expect(find.byKey(AccountScreen.logoutButtonKey), findsOneWidget);
    expect(find.text('Çıkış Yap'), findsOneWidget);

    expect(find.byType(TextField), findsNothing);
    expect(find.byType(EditableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC2: fotoğraf, kaydet ve tercih satırları Yakında gösterir', (
    tester,
  ) async {
    await pumpAccount(tester);

    await tapAndExpectComingSoon(
      tester,
      find.byKey(AccountScreen.photoButtonKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(AccountScreen.saveButtonKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(AccountScreen.savedAddressesRowKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(AccountScreen.tripPreferencesRowKey),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('küçük ve büyük ekranda taşma veya kırpılma olmaz', (
    tester,
  ) async {
    for (final size in const [Size(375, 667), Size(430, 932)]) {
      await pumpAccount(tester, size: size);

      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(AccountScreen.contentScrollKey),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
