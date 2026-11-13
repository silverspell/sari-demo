import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/destination_screen.dart';
import 'package:sari/theme/sari_theme.dart';

Future<void> pumpDestination(
  WidgetTester tester, {
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(theme: buildSariTheme(), home: const DestinationScreen()),
  );
  await tester.pumpAndSettle();
}

Future<void> expectSnackBarToClear(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(seconds: 3));
  await tester.pumpAndSettle();
  expect(find.text('Yakında'), findsNothing);
}

void main() {
  testWidgets('statik bölümleri, başlıkları ve satırları gösterir', (
    tester,
  ) async {
    await pumpDestination(tester);

    expect(find.byKey(DestinationScreen.screenKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.backButtonKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.originRowKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.originPickerKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.searchFieldKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.mapPickButtonKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.clearHistoryButtonKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.promoBannerKey), findsOneWidget);
    expect(find.byKey(DestinationScreen.savedPlacePromptKey), findsOneWidget);

    expect(find.text('Nereden'), findsOneWidget);
    expect(find.text('Mevcut Konum · Moda, Kadıköy'), findsOneWidget);
    expect(find.text('Haritadan Seç'), findsOneWidget);
    expect(find.text('SON GİDİLENLER'), findsOneWidget);
    expect(find.text('Geçmişi Temizle'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.historyRowKey('kadikoy-iskele')),
      findsOneWidget,
    );
    expect(find.text('Kadıköy İskele'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.historyRowKey('taksim-meydani')),
      findsOneWidget,
    );
    expect(find.text('Taksim Meydanı'), findsOneWidget);
    expect(find.text('ÖZEL FIRSAT'), findsOneWidget);
    expect(find.text('Havalimanı Sabit Fiyat'), findsOneWidget);
    expect(find.text('ÖNERİLER'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.suggestionRowKey('istanbul-havalimani')),
      findsOneWidget,
    );
    expect(find.text('İstanbul Havalimanı (IST)'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.suggestionRowKey('sabiha-gokcen')),
      findsOneWidget,
    );
    expect(find.text('Sabiha Gökçen Havalimanı (SAW)'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.suggestionRowKey('kanyon-avm')),
      findsOneWidget,
    );
    expect(find.text('Kanyon AVM'), findsOneWidget);
    expect(find.text('Ev veya İş Yeri adresinizi ekleyin'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Kadıköy araması sahte yer listesinden sonuçları filtreler', (
    tester,
  ) async {
    await pumpDestination(tester);

    await tester.enterText(
      find.byKey(DestinationScreen.searchFieldKey),
      'Kadıköy',
    );
    await tester.pump();

    expect(find.text('SONUÇLAR'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.resultRowKey('kadikoy-iskele')),
      findsOneWidget,
    );
    expect(find.text('Kadıköy İskele'), findsOneWidget);
    expect(find.text('SON GİDİLENLER'), findsNothing);
    expect(find.text('ÖNERİLER'), findsNothing);
    expect(
      find.byKey(DestinationScreen.resultRowKey('taksim-meydani')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('arama büyük harf ve Türkçesiz yazımla da eşleşir', (
    tester,
  ) async {
    await pumpDestination(tester);

    for (final query in ['KADIKÖY', 'kadikoy']) {
      await tester.enterText(
        find.byKey(DestinationScreen.searchFieldKey),
        query,
      );
      await tester.pump();

      expect(
        find.byKey(DestinationScreen.resultRowKey('kadikoy-iskele')),
        findsOneWidget,
        reason: query,
      );
      expect(find.text('Kadıköy İskele'), findsOneWidget, reason: query);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('eşleşme yoksa boş sonuç kartı gösterir', (tester) async {
    await pumpDestination(tester);

    await tester.enterText(
      find.byKey(DestinationScreen.searchFieldKey),
      'zzzz',
    );
    await tester.pump();

    expect(find.byKey(DestinationScreen.emptyResultsKey), findsOneWidget);
    expect(find.text('Sonuç bulunamadı'), findsOneWidget);
    expect(
      find.byKey(DestinationScreen.resultRowKey('kadikoy-iskele')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Haritadan Seç Yakında bildirimi gösterir', (tester) async {
    await pumpDestination(tester);

    await tester.tap(find.byKey(DestinationScreen.mapPickButtonKey));
    await tester.pump();

    expect(find.text('Yakında'), findsOneWidget);
    await expectSnackBarToClear(tester);
    expect(find.byKey(DestinationScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Geçmişi Temizle Yakında bildirimi gösterir', (tester) async {
    await pumpDestination(tester);

    await tester.tap(find.byKey(DestinationScreen.clearHistoryButtonKey));
    await tester.pump();

    expect(find.text('Yakında'), findsOneWidget);
    await expectSnackBarToClear(tester);
    expect(find.byKey(DestinationScreen.screenKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('yer satırına dokunmak şimdilik Yakında gösterir', (
    tester,
  ) async {
    await pumpDestination(tester);

    await tester.tap(
      find.byKey(DestinationScreen.historyRowKey('kadikoy-iskele')),
    );
    await tester.pump();

    expect(find.text('Yakında'), findsOneWidget);
    await expectSnackBarToClear(tester);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      await pumpDestination(tester, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(DestinationScreen.screenKey)), size);

      await tester.scrollUntilVisible(
        find.byKey(DestinationScreen.savedPlacePromptKey),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        tester
            .getBottomLeft(find.byKey(DestinationScreen.savedPlacePromptKey))
            .dy,
        lessThanOrEqualTo(size.height),
      );
    });
  }
}
