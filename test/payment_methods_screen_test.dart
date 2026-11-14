import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/payments/payment_method_controller.dart';
import 'package:sari/screens/payment_methods_screen.dart';
import 'package:sari/theme/sari_theme.dart';

Future<PaymentMethodController> _pumpPaymentMethods(
  WidgetTester tester, {
  PaymentMethodController? controller,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final payments = controller ?? PaymentMethodController();
  addTearDown(payments.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: PaymentMethodsScreen(paymentMethodController: payments),
    ),
  );
  await tester.pump();

  return payments;
}

String textAt(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? '';
}

Color? dotColor(WidgetTester tester, String id) {
  final dot = tester.widget<Container>(
    find.byKey(PaymentMethodsScreen.methodRadioDotKey(id)),
  );
  final decoration = dot.decoration as BoxDecoration?;
  return decoration?.color;
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
  testWidgets(
    'AC1: cüzdan, üç yöntem, güvenlik ve fatura kartlarını gösterir',
    (tester) async {
      await _pumpPaymentMethods(tester);

      expect(find.byKey(PaymentMethodsScreen.screenKey), findsOneWidget);
      expect(find.text('Ödeme Yöntemleri'), findsNWidgets(2));
      expect(
        find.text('Yolculuklarınız için tercih edilen tahsilat yöntemi'),
        findsOneWidget,
      );

      expect(find.byKey(PaymentMethodsScreen.walletCardKey), findsOneWidget);
      expect(
        textAt(tester, PaymentMethodsScreen.walletLabelKey),
        'SARI CÜZDAN BAKİYESİ',
      );
      expect(textAt(tester, PaymentMethodsScreen.walletBalanceKey), '₺340,50');
      expect(
        textAt(tester, PaymentMethodsScreen.walletAutoLoadKey),
        'Otomatik yükleme aktif',
      );
      expect(find.byKey(PaymentMethodsScreen.topUpButtonKey), findsOneWidget);
      expect(find.text('Yükle'), findsOneWidget);

      expect(find.byKey(PaymentMethodsScreen.methodListKey), findsOneWidget);

      final expected = <String, (String, String)>{
        FakeRideData.visa4242.id: ('•••• 4242 Visa', 'Son Kullanma: 08/28'),
        FakeRideData.mastercard5310.id: (
          '•••• 5310 Mastercard',
          'Son Kullanma: 11/26',
        ),
        FakeRideData.nakit.id: ('Nakit', 'Sürücüye elden ödeme'),
      };

      for (final method in FakeRideData.paymentMethods) {
        final (title, subtitle) = expected[method.id]!;
        expect(
          find.byKey(PaymentMethodsScreen.methodRowKey(method.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PaymentMethodsScreen.methodBrandKey(method.id)),
          findsOneWidget,
        );
        expect(
          textAt(tester, PaymentMethodsScreen.methodLabelKey(method.id)),
          title,
        );
        expect(
          textAt(tester, PaymentMethodsScreen.methodSubtitleKey(method.id)),
          subtitle,
        );
        expect(
          find.byKey(PaymentMethodsScreen.methodRadioKey(method.id)),
          findsOneWidget,
        );
        expect(
          find.byKey(PaymentMethodsScreen.methodRadioDotKey(method.id)),
          findsOneWidget,
        );
      }

      expect(
        find.byKey(
          PaymentMethodsScreen.methodDefaultBadgeKey(FakeRideData.visa4242.id),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(
          PaymentMethodsScreen.methodDefaultBadgeKey(
            FakeRideData.mastercard5310.id,
          ),
        ),
        findsNothing,
      );
      expect(
        find.byKey(
          PaymentMethodsScreen.methodDefaultBadgeKey(FakeRideData.nakit.id),
        ),
        findsNothing,
      );

      expect(find.byKey(PaymentMethodsScreen.securityCardKey), findsOneWidget);
      expect(
        textAt(tester, PaymentMethodsScreen.securityTitleKey),
        'Güvenli İşlem Garantisi',
      );
      expect(
        textAt(tester, PaymentMethodsScreen.securityBodyKey),
        'Kart bilgileriniz BDDK ve PCI-DSS standartlarına uygun şifreli '
        'altyapıda saklanmaktadır. Sarı hiçbir zaman tam kart numaranıza '
        'erişmez.',
      );

      expect(find.byKey(PaymentMethodsScreen.corporateCardKey), findsOneWidget);
      expect(find.text('Kurumsal Fatura'), findsOneWidget);
      expect(
        textAt(tester, PaymentMethodsScreen.corporateSubtitleKey),
        'E-arşiv bilgileriniz kayıtlı',
      );

      expect(find.byKey(PaymentMethodsScreen.updateButtonKey), findsOneWidget);
      expect(find.text('Yöntemi Güncelle'), findsOneWidget);

      expect(find.text('Kart Ekle'), findsNothing);
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(EditableText), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.byType(BottomNavigationBar), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AC2: başka bir yönteme dokununca seçim ve dolu nokta taşınır', (
    tester,
  ) async {
    final payments = await _pumpPaymentMethods(tester);
    final theme = buildSariTheme();

    expect(payments.selected, FakeRideData.visa4242);
    expect(
      dotColor(tester, FakeRideData.visa4242.id),
      theme.colorScheme.primaryContainer,
    );
    expect(
      dotColor(tester, FakeRideData.mastercard5310.id),
      Colors.transparent,
    );

    await tester.tap(
      find.byKey(
        PaymentMethodsScreen.methodRowKey(FakeRideData.mastercard5310.id),
      ),
    );
    await tester.pumpAndSettle();

    expect(payments.selected, FakeRideData.mastercard5310);
    expect(
      dotColor(tester, FakeRideData.mastercard5310.id),
      theme.colorScheme.primaryContainer,
    );
    expect(dotColor(tester, FakeRideData.visa4242.id), Colors.transparent);
    expect(
      find.byKey(
        PaymentMethodsScreen.methodDefaultBadgeKey(
          FakeRideData.mastercard5310.id,
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(
        PaymentMethodsScreen.methodDefaultBadgeKey(FakeRideData.visa4242.id),
      ),
      findsNothing,
    );

    await tester.tap(
      find.byKey(PaymentMethodsScreen.methodRowKey(FakeRideData.nakit.id)),
    );
    await tester.pumpAndSettle();

    expect(payments.selected, FakeRideData.nakit);
    expect(
      dotColor(tester, FakeRideData.nakit.id),
      theme.colorScheme.primaryContainer,
    );
    expect(
      dotColor(tester, FakeRideData.mastercard5310.id),
      Colors.transparent,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AC4: Yükle, Kurumsal Fatura ve Yöntemi Güncelle Yakında gösterir',
    (tester) async {
      await _pumpPaymentMethods(tester);

      await tapAndExpectComingSoon(
        tester,
        find.byKey(PaymentMethodsScreen.topUpButtonKey),
      );
      await tapAndExpectComingSoon(
        tester,
        find.byKey(PaymentMethodsScreen.corporateCardKey),
      );
      await tapAndExpectComingSoon(
        tester,
        find.byKey(PaymentMethodsScreen.updateButtonKey),
      );
      await tapAndExpectComingSoon(
        tester,
        find.byKey(PaymentMethodsScreen.notificationButtonKey),
      );
      await tapAndExpectComingSoon(
        tester,
        find.byKey(PaymentMethodsScreen.avatarButtonKey),
      );

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('AC5: küçük ve büyük ekranda taşma veya kırpılma olmaz', (
    tester,
  ) async {
    for (final size in const [Size(375, 667), Size(430, 932)]) {
      await _pumpPaymentMethods(tester, size: size);

      expect(tester.takeException(), isNull);

      await tester.ensureVisible(
        find.byKey(PaymentMethodsScreen.updateButtonKey),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await tester.drag(
        find.byKey(PaymentMethodsScreen.scrollViewKey),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
