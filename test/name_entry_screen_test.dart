@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/main.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/location_permission_screen.dart';
import 'package:sari/screens/name_entry_screen.dart';
import 'package:sari/screens/otp_screen.dart';
import 'package:sari/screens/phone_login_screen.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_session_store.dart';

const _title = 'Seni nasıl çağıralım?';
const _description =
    'Sürücünün seni tanıması için adını ve soyadını bilmesi gerekiyor.';
const _kvkk =
    'Bilgilerin KVKK kapsamında güvendedir. Yalnızca yolculuk anında eşleşen '
    'sürücüyle paylaşılır.';
const _emptyPreview = '"Sürücü sizi bekliyor!"';
const _footer = 'Adım 3 / 4 • Profil Doğrulama';

String locationOf(WidgetTester tester) {
  final context = tester.element(find.byType(Scaffold).first);
  return GoRouter.of(
    context,
  ).routerDelegate.currentConfiguration.uri.toString();
}

Future<SessionController> pumpApp(
  WidgetTester tester, {
  FakeSessionStore? store,
}) async {
  final controller = SessionController(store ?? FakeSessionStore());
  await controller.load();

  await tester.pumpWidget(SariApp(sessionController: controller));
  await tester.pumpAndSettle();

  return controller;
}

Future<void> goToName(WidgetTester tester) async {
  final context = tester.element(find.byType(PhoneLoginScreen));
  GoRouter.of(context).go(AppRoutes.name);
  await tester.pumpAndSettle();

  expect(find.byType(NameEntryScreen), findsOneWidget);
}

TextField nameField(WidgetTester tester, Key key) =>
    tester.widget<TextField>(find.byKey(key));

FilledButton continueButton(WidgetTester tester) =>
    tester.widget<FilledButton>(find.byKey(NameEntryScreen.continueButtonKey));

bool isContinueEnabled(WidgetTester tester) =>
    continueButton(tester).onPressed != null;

Future<void> enterName(
  WidgetTester tester, {
  String? firstName,
  String? lastName,
}) async {
  if (firstName != null) {
    await tester.enterText(
      find.byKey(NameEntryScreen.firstNameFieldKey),
      firstName,
    );
  }
  if (lastName != null) {
    await tester.enterText(
      find.byKey(NameEntryScreen.lastNameFieldKey),
      lastName,
    );
  }
  await tester.pump();
}

void main() {
  testWidgets('tasarım içeriği görünür', (tester) async {
    await pumpApp(tester);
    await goToName(tester);

    expect(find.text(_title), findsOneWidget);
    expect(find.text(_description), findsOneWidget);
    expect(find.text('Profil Oluşturma'), findsOneWidget);

    expect(find.byKey(NameEntryScreen.stepIndicatorKey), findsOneWidget);
    for (var index = 0; index < 4; index++) {
      expect(find.byKey(NameEntryScreen.stepDotKey(index)), findsOneWidget);
    }
    expect(
      tester.getSize(find.byKey(NameEntryScreen.stepDotKey(2))).width,
      greaterThan(
        tester.getSize(find.byKey(NameEntryScreen.stepDotKey(0))).width,
      ),
    );

    expect(find.byKey(NameEntryScreen.backButtonKey), findsOneWidget);
    expect(find.byTooltip('Geri dön'), findsOneWidget);
    expect(find.byKey(NameEntryScreen.helpButtonKey), findsOneWidget);
    expect(find.byTooltip('Yardım'), findsOneWidget);

    expect(find.byIcon(Icons.account_circle_outlined), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.local_taxi), findsOneWidget);
    expect(find.text('Kaptan sürücünün ekranında:'), findsOneWidget);
    expect(find.byKey(NameEntryScreen.previewTextKey), findsOneWidget);

    expect(find.text('Ad'), findsOneWidget);
    expect(find.text('Zorunlu'), findsOneWidget);
    expect(find.text('Soyad'), findsOneWidget);
    expect(find.text('İsteğe bağlı'), findsOneWidget);
    expect(find.text('Örn: Cem'), findsOneWidget);
    expect(find.text('Örn: Güler'), findsOneWidget);
    expect(find.text(_kvkk), findsOneWidget);

    expect(find.text('Sık kullanılan hitaplar'), findsOneWidget);
    expect(find.text('Kaptan Cem'), findsOneWidget);
    expect(find.text('Yolcu Cem'), findsOneWidget);
    expect(find.text('Av. Cem Güler'), findsOneWidget);

    expect(find.text('Devam et'), findsOneWidget);
    expect(find.text(_footer), findsOneWidget);
  });

  testWidgets('boş form önizleme ve Devam et durumu', (tester) async {
    await pumpApp(tester);
    await goToName(tester);

    expect(find.text(_emptyPreview), findsOneWidget);
    expect(isContinueEnabled(tester), isFalse);

    await enterName(tester, firstName: '   ');
    expect(find.text(_emptyPreview), findsOneWidget);
    expect(isContinueEnabled(tester), isFalse);

    await enterName(tester, firstName: 'Cem');
    expect(isContinueEnabled(tester), isTrue);
  });

  testWidgets('önizleme adla canlı güncellenir, soyadla değişmez', (
    tester,
  ) async {
    await pumpApp(tester);
    await goToName(tester);

    await enterName(tester, firstName: 'Cem');
    expect(find.text('"Merhaba Cem Bey!"'), findsOneWidget);

    await enterName(tester, firstName: 'Kaptan Cem');
    expect(find.text('"Merhaba Kaptan Cem Bey!"'), findsOneWidget);

    await enterName(tester, lastName: 'Güler');
    expect(find.text('"Merhaba Kaptan Cem Bey!"'), findsOneWidget);
  });

  testWidgets('temizle düğmeleri yalnızca dolu alanda görünür ve alanı korur', (
    tester,
  ) async {
    await pumpApp(tester);
    await goToName(tester);

    expect(find.byKey(NameEntryScreen.clearFirstNameKey), findsNothing);
    expect(find.byKey(NameEntryScreen.clearLastNameKey), findsNothing);

    await enterName(tester, firstName: 'Cem', lastName: 'Güler');
    expect(find.byKey(NameEntryScreen.clearFirstNameKey), findsOneWidget);
    expect(find.byKey(NameEntryScreen.clearLastNameKey), findsOneWidget);

    await tester.tap(find.byKey(NameEntryScreen.clearFirstNameKey));
    await tester.pump();

    expect(
      nameField(tester, NameEntryScreen.firstNameFieldKey).controller?.text,
      isEmpty,
    );
    expect(
      nameField(tester, NameEntryScreen.lastNameFieldKey).controller?.text,
      'Güler',
    );
    expect(
      nameField(tester, NameEntryScreen.firstNameFieldKey).focusNode?.hasFocus,
      isTrue,
    );

    await enterName(tester, firstName: 'Cem');
    await tester.tap(find.byKey(NameEntryScreen.clearLastNameKey));
    await tester.pump();

    expect(
      nameField(tester, NameEntryScreen.firstNameFieldKey).controller?.text,
      'Cem',
    );
    expect(
      nameField(tester, NameEntryScreen.lastNameFieldKey).controller?.text,
      isEmpty,
    );
    expect(
      nameField(tester, NameEntryScreen.lastNameFieldKey).focusNode?.hasFocus,
      isTrue,
    );
  });

  testWidgets('hızlı hitaplar tam metni yalnızca ada yazar', (tester) async {
    await pumpApp(tester);
    await goToName(tester);
    await enterName(tester, lastName: 'Güler');

    for (final label in const ['Kaptan Cem', 'Yolcu Cem', 'Av. Cem Güler']) {
      await tester.tap(find.byKey(NameEntryScreen.chipKey(label)));
      await tester.pump();

      expect(
        nameField(tester, NameEntryScreen.firstNameFieldKey).controller?.text,
        label,
        reason: 'etiket: $label',
      );
      expect(
        nameField(tester, NameEntryScreen.lastNameFieldKey).controller?.text,
        'Güler',
        reason: 'etiket: $label',
      );
      expect(find.text('"Merhaba $label Bey!"'), findsOneWidget);
    }
  });

  testWidgets('Devam et kırpılmış adı saklar ve konum iznine gider', (
    tester,
  ) async {
    final store = FakeSessionStore(
      const Session(phone: '+905551112233', name: '', surname: ''),
    );
    await pumpApp(tester, store: store);
    await goToName(tester);

    await enterName(tester, firstName: '  Cem  ', lastName: '  Güler  ');
    await tester.tap(find.byKey(NameEntryScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(store.session?.phone, '+905551112233');
    expect(store.session?.name, 'Cem');
    expect(store.session?.surname, 'Güler');
    expect(
      store.session?.locationPermission,
      LocationPermissionStatus.notRequested,
    );
    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.locationPermission);
  });

  testWidgets('soyad boşken Devam et boş soyadla kaydeder ve ilerler', (
    tester,
  ) async {
    final store = FakeSessionStore(
      const Session(phone: '+905551112233', name: '', surname: ''),
    );
    await pumpApp(tester, store: store);
    await goToName(tester);

    await enterName(tester, firstName: 'Cem');
    await tester.tap(find.byKey(NameEntryScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(store.session?.name, 'Cem');
    expect(store.session?.surname, '');
    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.locationPermission);
  });

  testWidgets('oturum yokken Devam et çökmeden ilerler', (tester) async {
    await pumpApp(tester);
    await goToName(tester);

    await enterName(tester, firstName: 'Cem');
    await tester.tap(find.byKey(NameEntryScreen.continueButtonKey));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.locationPermission);
  });

  testWidgets('geri dönüş OTP ekranına gider', (tester) async {
    await pumpApp(
      tester,
      store: FakeSessionStore(
        const Session(phone: '+905551112233', name: '', surname: ''),
      ),
    );

    final loginContext = tester.element(find.byType(PhoneLoginScreen));
    GoRouter.of(loginContext).go(AppRoutes.otp);
    await tester.pumpAndSettle();

    final otpContext = tester.element(find.byType(OtpScreen));
    GoRouter.of(otpContext).push(AppRoutes.name);
    await tester.pumpAndSettle();

    expect(find.byType(NameEntryScreen), findsOneWidget);

    await tester.tap(find.byKey(NameEntryScreen.backButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(OtpScreen), findsOneWidget);
    expect(locationOf(tester), AppRoutes.otp);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await pumpApp(tester);
      await goToName(tester);
      await enterName(tester, firstName: 'Cem', lastName: 'Güler');

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(NameEntryScreen.screenKey)), size);
      expect(
        tester.getBottomLeft(find.text(_footer)).dy,
        lessThanOrEqualTo(size.height),
      );
    });
  }

  goldenTest(
    'Ad girişi dolu ekran',
    fileName: '03-name',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: nameEntryGolden(
            const Size(375, 667),
            initialName: 'Cem',
            initialSurname: 'Güler',
          ),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: nameEntryGolden(
            const Size(430, 932),
            initialName: 'Cem',
            initialSurname: 'Güler',
          ),
        ),
      ],
    ),
  );

  goldenTest(
    'Ad girişi boş ekran',
    fileName: '03-name-empty',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: nameEntryGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: nameEntryGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget nameEntryGolden(
  Size size, {
  String initialName = '',
  String initialSurname = '',
}) {
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: NameEntryScreen(
            sessionController: SessionController(FakeSessionStore()),
            initialName: initialName,
            initialSurname: initialSurname,
          ),
        ),
      ),
    ),
  );
}
