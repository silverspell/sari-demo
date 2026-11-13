@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/name_entry_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _subtitle = '+90 532 123 45 67 numarasına gönderildi';

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<void> pumpOtpRoute(WidgetTester tester) async {
  final controller = SessionController(FakeSessionStore());
  await controller.load();

  await tester.pumpWidget(SariApp(sessionController: controller));
  await tester.pumpAndSettle();

  final context = tester.element(find.byType(PhoneLoginScreen));
  GoRouter.of(context).go(AppRoutes.otp);
  await tester.pumpAndSettle();

  expect(find.byType(OtpScreen), findsOneWidget);
}

TextField digitBox(WidgetTester tester, int index) =>
    tester.widget<TextField>(find.byKey(OtpScreen.digitKey(index)));

Future<void> enterCode(WidgetTester tester, String code) async {
  for (var i = 0; i < code.length; i++) {
    await tester.enterText(find.byKey(OtpScreen.digitKey(i)), code[i]);
    await tester.pump();
  }
}

Future<void> pumpOtpWithClock(
  WidgetTester tester,
  DateTime Function() now,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: OtpScreen(now: now),
    ),
  );
}

void main() {
  testWidgets('dört kutu, başlık, alt başlık ve sabit yeniden gönderme', (
    tester,
  ) async {
    await pumpOtpRoute(tester);

    expect(find.text('Kodu gir'), findsOneWidget);
    expect(find.text(_subtitle), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Kodu tekrar gönder (0:28)'), findsOneWidget);
    expect(find.text('Doğrula'), findsOneWidget);
    expect(find.text('Mesaj ulaşmadı mı?'), findsOneWidget);
    expect(find.text('Beni ara'), findsOneWidget);
    expect(find.text('SMS ile Doğrulama'), findsOneWidget);
  });

  testWidgets('oturum telefonu alt başlıkta biçimlendirilir', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildSariTheme(),
        home: const OtpScreen(phone: '+905551112233'),
      ),
    );

    expect(
      find.text('+90 555 111 22 33 numarasına gönderildi'),
      findsOneWidget,
    );
  });

  testWidgets('rakam girilince odak sıradaki kutuya geçer', (tester) async {
    await pumpOtpRoute(tester);

    for (var i = 0; i < 3; i++) {
      await tester.enterText(find.byKey(OtpScreen.digitKey(i)), '${i + 1}');
      await tester.pump();

      expect(
        digitBox(tester, i).focusNode?.hasFocus,
        isFalse,
        reason: '$i. kutu odakta kalmamalı',
      );
      expect(
        digitBox(tester, i + 1).focusNode?.hasFocus,
        isTrue,
        reason: '${i + 1}. kutu odakta olmalı',
      );
    }
  });

  testWidgets('1234 doğru kodla isim ekranına gider', (tester) async {
    await pumpOtpRoute(tester);

    await enterCode(tester, '1234');
    await tester.tap(find.byKey(OtpScreen.verifyButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(NameEntryScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.name);
  });

  testWidgets('yanlış kod kutu vurgusu, hata mesajı ve Temizle gösterir', (
    tester,
  ) async {
    await pumpOtpRoute(tester);

    await enterCode(tester, '3910');
    await tester.tap(find.byKey(OtpScreen.verifyButtonKey));
    await tester.pump();

    expect(find.byType(NameEntryScreen), findsNothing);
    expect(locationOf(tester), AppRoutes.otp);

    expect(find.byKey(OtpScreen.errorBannerKey), findsOneWidget);
    expect(find.text('Kod hatalı, tekrar dene.'), findsOneWidget);
    expect(find.text('Temizle'), findsOneWidget);

    for (var i = 0; i < 4; i++) {
      expect(digitBox(tester, i).style?.color, SariColors.critical);
    }

    final boxesBottom = tester
        .getBottomLeft(find.byKey(OtpScreen.digitKey(0)))
        .dy;
    final errorTop = tester.getTopLeft(find.byKey(OtpScreen.errorBannerKey)).dy;
    expect(errorTop, greaterThan(boxesBottom));
  });

  testWidgets('Temizle kutuları ve hatayı temizler, ilk kutuya odaklanır', (
    tester,
  ) async {
    await pumpOtpRoute(tester);

    await enterCode(tester, '3910');
    await tester.tap(find.byKey(OtpScreen.verifyButtonKey));
    await tester.pump();

    await tester.tap(find.byKey(OtpScreen.clearButtonKey));
    await tester.pump();

    for (var i = 0; i < 4; i++) {
      expect(digitBox(tester, i).controller?.text, isEmpty);
      expect(digitBox(tester, i).style?.color, isNot(SariColors.critical));
    }
    expect(find.byKey(OtpScreen.errorBannerKey), findsNothing);
    expect(find.text('Kod hatalı, tekrar dene.'), findsNothing);
    expect(digitBox(tester, 0).focusNode?.hasFocus, isTrue);
  });

  testWidgets('geri dönüş telefon giriş ekranına gider', (tester) async {
    await pumpOtpRoute(tester);

    await tester.tap(find.byKey(OtpScreen.backButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(PhoneLoginScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.login);
  });

  testWidgets('sahte saat 28 saniye ilerleyince tekrar gönderme aktifleşir', (
    tester,
  ) async {
    var current = DateTime(2026, 1, 1, 12);
    await pumpOtpWithClock(tester, () => current);

    expect(find.text('Kodu tekrar gönder (0:28)'), findsOneWidget);
    expect(find.byKey(OtpScreen.resendButtonKey), findsNothing);

    current = current.add(const Duration(seconds: 28));
    await tester.pump(const Duration(seconds: 28));

    expect(find.byKey(OtpScreen.resendLabelKey), findsNothing);
    expect(find.text('Kodu tekrar gönder'), findsOneWidget);
    final button = tester.widget<TextButton>(
      find.byKey(OtpScreen.resendButtonKey),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('aktif tekrar gönderme bildirir ve sayacı sıfırlar', (
    tester,
  ) async {
    var current = DateTime(2026, 1, 1, 12);
    await pumpOtpWithClock(tester, () => current);

    current = current.add(const Duration(seconds: 28));
    await tester.pump(const Duration(seconds: 28));

    await tester.tap(find.byKey(OtpScreen.resendButtonKey));
    await tester.pump();

    expect(find.byKey(OtpScreen.resendSnackBarKey), findsOneWidget);
    expect(find.text('Kod tekrar gönderildi'), findsOneWidget);
    expect(find.text('Kodu tekrar gönder (0:28)'), findsOneWidget);
    expect(find.byKey(OtpScreen.resendButtonKey), findsNothing);
  });

  testWidgets('Beni ara demo bildirimi gösterir', (tester) async {
    await pumpOtpWithClock(tester, () => DateTime(2026, 1, 1, 12));

    await tester.tap(find.byKey(OtpScreen.callButtonKey));
    await tester.pump();

    expect(find.byKey(OtpScreen.callSnackBarKey), findsOneWidget);
    expect(find.text('Demo: kod 1234'), findsOneWidget);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpOtpRoute(tester);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(OtpScreen.screenKey)), size);
    });
  }

  goldenTest(
    'OTP boş ekran',
    fileName: '02-otp-empty',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: otpGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: otpGolden(const Size(430, 932)),
        ),
      ],
    ),
  );

  goldenTest(
    'OTP hatalı kod',
    fileName: '02-otp-error',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: otpGolden(
            const Size(375, 667),
            initialCode: '3910',
            initialError: true,
          ),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: otpGolden(
            const Size(430, 932),
            initialCode: '3910',
            initialError: true,
          ),
        ),
      ],
    ),
  );
  goldenTest(
    'OTP demo dolu ekran',
    fileName: '02-otp',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: otpGolden(const Size(375, 667), initialCode: '84'),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: otpGolden(const Size(430, 932), initialCode: '84'),
        ),
      ],
    ),
  );
}

Widget otpGolden(Size size, {String? initialCode, bool initialError = false}) {
  final now = DateTime(2026, 1, 1, 12);
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: OtpScreen(
            phone: OtpScreen.fallbackPhone,
            initialCode: initialCode,
            initialError: initialError,
            now: () => now,
          ),
        ),
      ),
    ),
  );
}
