import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/trip_history_screen.dart';
import 'package:sari/theme/sari_theme.dart';
import 'package:sari/trips/completed_trip.dart';
import 'package:sari/trips/trip_history_controller.dart';

import 'support/fake_trip_history_data.dart';

Future<void> pumpTripHistory(
  WidgetTester tester, {
  required TripHistoryController tripHistoryController,
  DateTime Function()? now,
  Size size = const Size(430, 932),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      theme: buildSariTheme(),
      home: TripHistoryScreen(
        tripHistoryController: tripHistoryController,
        now: now ?? () => fakeTripHistoryNow,
      ),
    ),
  );
  await tester.pump();
}

String textAt(WidgetTester tester, Key key) {
  final text = tester.widget<Text>(find.byKey(key));
  return text.data ?? '';
}

CompletedTrip tripAt(CompletedTrip template, DateTime completedAt) {
  return CompletedTrip(
    destination: template.destination,
    departureLabel: template.departureLabel,
    distanceMeters: template.distanceMeters,
    duration: template.duration,
    completedAt: completedAt,
    amountLira: template.amountLira,
    driver: template.driver,
    rating: template.rating,
  );
}

Future<void> tapAndExpectComingSoon(
  WidgetTester tester,
  Finder finder,
) async {
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  expect(find.text('Yakında'), findsOneWidget);

  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('AC1: kayıtlar en yeni tamamlanan önce listelenir', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController(
      trips: [fakeTrips[2], fakeTrips[0], fakeTrips[1]],
    );

    await pumpTripHistory(tester, tripHistoryController: controller);

    expect(find.byKey(TripHistoryScreen.screenKey), findsOneWidget);
    expect(find.text('Yolculuklarım'), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.tripCardKey(0)), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.tripCardKey(1)), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.tripCardKey(2)), findsOneWidget);
    expect(textAt(tester, TripHistoryScreen.cardDateKey(0)), '12 Kas, 09:14');
    expect(textAt(tester, TripHistoryScreen.cardDateKey(1)), '10 Kas, 18:40');
    expect(textAt(tester, TripHistoryScreen.cardDateKey(2)), '7 Kas, 06:05');
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC2: kart tarih-saat, tutar, rota, plaka, sınıf, km, puan ve sürücü gösterir', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController();

    await pumpTripHistory(tester, tripHistoryController: controller);

    expect(textAt(tester, TripHistoryScreen.cardDateKey(0)), '12 Kas, 09:14');
    expect(textAt(tester, TripHistoryScreen.cardAmountKey(0)), '₺92,00');
    expect(
      textAt(tester, TripHistoryScreen.cardRouteKey(0)),
      'Moda → Kadıköy İskele',
    );
    expect(textAt(tester, TripHistoryScreen.cardPlateKey(0)), '34 TB 4201');
    expect(textAt(tester, TripHistoryScreen.cardClassKey(0)), 'Sarı Taksi');
    expect(textAt(tester, TripHistoryScreen.cardDistanceKey(0)), '2.8 km');
    expect(textAt(tester, TripHistoryScreen.cardRatingKey(0)), '5.0');
    expect(textAt(tester, TripHistoryScreen.cardDriverKey(0)), '(Murat K.)');
    expect(find.text('Tamamlandı'), findsNWidgets(3));
    expect(find.text('Fiş'), findsNWidgets(3));
    expect(find.text('Tekrarla'), findsNWidgets(3));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC3: aylık özet kayıtlı yolculuklardan hesaplanır', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController();

    await pumpTripHistory(tester, tripHistoryController: controller);

    expect(find.byKey(TripHistoryScreen.summaryCardKey), findsOneWidget);
    expect(find.text('Bu Ayki Yolculuklar'), findsOneWidget);
    expect(
      textAt(tester, TripHistoryScreen.summaryTripCountKey),
      '3 Yolculuk',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryDistanceKey),
      '• 42.6 km',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryDurationKey),
      '68 dk yolda',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryCo2Key),
      '5.4 kg CO₂ tasarrufu',
    );
    expect(find.text('Kasım 2023'), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.monthChipKey), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.allFilterKey), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.sariFilterKey), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.corporateFilterKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC4: seçili ayda kayıt yoksa özet sıfır, kartlar görünür', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController(
      trips: [tripAt(fakeTrips[0], DateTime(2023, 10, 5, 10, 30))],
    );

    await pumpTripHistory(tester, tripHistoryController: controller);

    expect(
      textAt(tester, TripHistoryScreen.summaryTripCountKey),
      '0 Yolculuk',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryDistanceKey),
      '• 0.0 km',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryDurationKey),
      '0 dk yolda',
    );
    expect(
      textAt(tester, TripHistoryScreen.summaryCo2Key),
      '0.0 kg CO₂ tasarrufu',
    );
    expect(find.byKey(TripHistoryScreen.tripCardKey(0)), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.emptyStateKey), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC4: hiç kayıt yoksa Henüz yolculuk yok görünür', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController(
      trips: const [],
    );

    await pumpTripHistory(tester, tripHistoryController: controller);

    expect(
      textAt(tester, TripHistoryScreen.summaryTripCountKey),
      '0 Yolculuk',
    );
    expect(find.byKey(TripHistoryScreen.emptyStateKey), findsOneWidget);
    expect(find.text('Henüz yolculuk yok'), findsOneWidget);
    expect(find.byKey(TripHistoryScreen.tripCardKey(0)), findsNothing);
    expect(find.byKey(TripHistoryScreen.supportCardKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC5: filtre çipleri ve kart dokunuşları Yakında gösterir', (
    tester,
  ) async {
    final controller = await createSeededTripHistoryController();
    await pumpTripHistory(tester, tripHistoryController: controller);

    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.monthChipKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.allFilterKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.sariFilterKey),
    );
    await tester.ensureVisible(
      find.byKey(TripHistoryScreen.corporateFilterKey),
    );
    await tester.pumpAndSettle();
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.corporateFilterKey),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.receiptButtonKey(0)),
    );
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.repeatButtonKey(0)),
    );

    await tester.drag(
      find.byKey(TripHistoryScreen.tripListKey),
      const Offset(0, -1200),
    );
    await tester.pumpAndSettle();
    await tapAndExpectComingSoon(
      tester,
      find.byKey(TripHistoryScreen.supportCardKey),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('küçük ve büyük ekranda taşma veya kırpılma olmaz', (
    tester,
  ) async {
    for (final size in const [Size(375, 667), Size(430, 932)]) {
      final controller = await createSeededTripHistoryController();
      await pumpTripHistory(
        tester,
        tripHistoryController: controller,
        size: size,
      );

      expect(tester.takeException(), isNull);
      await tester.drag(
        find.byKey(TripHistoryScreen.tripListKey),
        const Offset(0, -1200),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
