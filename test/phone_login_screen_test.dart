import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _title = 'Telefon numaranı gir';
const _subtitle = 'Hızlı ve güvenli yolculuklar için tek tıkla hesabına eriş.';
const _promoTitle = 'Tek dokunuşla Sarı Taksi';
const _promoSubtitle = 'Şehrin dört bir yanında anında sarı taksi kapında.';

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<SessionController> pumpLogin(
  WidgetTester tester, {
  FakeSessionStore? store,
}) async {
  final controller = SessionController(store ?? FakeSessionStore());
  await controller.load();

  await tester.pumpWidget(SariApp(sessionController: controller));
  await tester.pumpAndSettle();

  expect(find.byType(PhoneLoginScreen), findsOneWidget);
  return controller;
}

TextField phoneField(WidgetTester tester) =>
    tester.widget<TextField>(find.byKey(PhoneLoginScreen.phoneFieldKey));

FilledButton continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(PhoneLoginScreen.continueButtonKey));

bool isContinueEnabled(WidgetTester tester) =>
    continueButton(tester).onPressed != null;

Future<void> enterPhone(WidgetTester tester, String number) async {
  await tester.enterText(
    find.byKey(PhoneLoginScreen.phoneFieldKey),
    number,
  );
  await tester.pump();
}

void main() {
  testWidgets('kelime markası, başlık, alt başlık ve sabit ülke kodu görünür', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(find.text('Sarı'), findsOneWidget);
    expect(find.text(_title), findsOneWidget);
    expect(find.text(_subtitle), findsOneWidget);
    expect(find.text('+90'), findsOneWidget);
    expect(find.text('5xx xxx xx xx'), findsOneWidget);
    expect(find.text(_promoTitle), findsOneWidget);
    expect(find.text(_promoSubtitle), findsOneWidget);
    expect(find.byIcon(Icons.local_taxi), findsOneWidget);
    expect(find.text('Devam et'), findsOneWidget);
    expect(find.byIcon(Icons.expand_more), findsNothing);
  });

  testWidgets('numara yazıldıkça 3-3-2-2 gruplanır', (tester) async {
    await pumpLogin(tester);

    await enterPhone(tester, '5551234567');

    expect(phoneField(tester).controller?.text, '555 123 45 67');
  });

  testWidgets('geçerli 10 haneli 5 ile başlayan numara Devam et etkinleştirir', (
    tester,
  ) async {
    await pumpLogin(tester);

    expect(isContinueEnabled(tester), isFalse);

    await enterPhone(tester, '5551234567');

    expect(isContinueEnabled(tester), isTrue);
  });

  testWidgets('5 ile başlamayan veya 10 haneli olmayan numara Devam et kapalı', (
    tester,
  ) async {
    await pumpLogin(tester);

    for (final number in const [
      '4551234567',
      '555123456',
      '55512345678',
    ]) {
      await enterPhone(tester, number);

      expect(
        isContinueEnabled(tester),
        isFalse,
        reason: 'numara: $number',
      );
    }
  });

  testWidgets('etkin Devam et telefonu oturuma kaydedip OTP rotasına gider', (
    tester,
  ) async {
    final store = FakeSessionStore();
    await pumpLogin(tester, store: store);

    await enterPhone(tester, '5551234567');
    await tester.tap(find.byKey(PhoneLoginScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(store.session?.phone, '+905551234567');
    expect(store.session?.name, '');
    expect(store.session?.surname, '');
    expect(find.byType(OtpScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.otp);
  });

  testWidgets('yasal metinler tıklanabilir değil ve görünür kalır', (tester) async {
    await pumpLogin(tester);

    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(find.text('Gizlilik Politikası'), findsOneWidget);

    await tester.tap(
      find.byKey(PhoneLoginScreen.termsLinkKey),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(locationOf(tester), AppRoutes.login);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(find.text('Gizlilik Politikası'), findsOneWidget);

    await tester.tap(
      find.byKey(PhoneLoginScreen.privacyLinkKey),
      warnIfMissed: false,
    );
    await tester.pumpAndSettle();

    expect(locationOf(tester), AppRoutes.login);
    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(find.text('Kullanım Koşulları'), findsOneWidget);
    expect(find.text('Gizlilik Politikası'), findsOneWidget);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets(
      'taşma yok ${size.width.toInt()}x${size.height.toInt()}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await pumpLogin(tester);

        expect(tester.takeException(), isNull);
        expect(tester.getSize(find.byKey(PhoneLoginScreen.screenKey)), size);
      },
    );
  }

  goldenTest(
    'Telefon girişi boş ekran',
    fileName: '01-phone-login',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: phoneLoginGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: phoneLoginGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget phoneLoginGolden(Size size) {
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: PhoneLoginScreen(
            sessionController: SessionController(FakeSessionStore()),
          ),
        ),
      ),
    ),
  );
}
