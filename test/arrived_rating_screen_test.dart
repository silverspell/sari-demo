import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/ride_class.dart';
import 'package:sari/rides/ride_feedback_tag.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/router/app_router.dart';
import 'package:sari/router/app_routes.dart';
import 'package:sari/screens/arrived_rating_screen.dart';
import 'package:sari/screens/home_screen.dart';
import 'package:sari/session/location_point.dart';
import 'package:sari/session/session.dart';
import 'package:sari/session/session_controller.dart';
import 'package:sari/theme/sari_theme.dart';
import 'package:sari/trips/completed_trip.dart';
import 'package:sari/trips/in_memory_trip_history_store.dart';
import 'package:sari/trips/trip_history_controller.dart';

import 'support/fake_session_store.dart';
import 'support/fake_tile_provider.dart';

const _completedSession = Session(
  phone: '+905551112233',
  name: 'Cem',
  surname: 'Güler',
  locationPermission: LocationPermissionStatus.granted,
  location: DefaultLocations.modaKadikoy,
);

Future<void> pumpArrived(
  WidgetTester tester, {
  RideFlowController? flowController,
  TripHistoryController? tripHistoryController,
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
      home: ArrivedRatingScreen(
        flowController: flowController,
        tripHistoryController: tripHistoryController,
        now: now,
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

String fareText(WidgetTester tester) {
  final text = tester.widget<Text>(
    find.byKey(ArrivedRatingScreen.fareTextKey),
  );
  return text.data ?? '';
}

void main() {
  testWidgets('tamamlanan yolculuğun tutar, ödeme ve sürücü bilgisini gösterir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpArrived(tester, flowController: flow);

    expect(find.byKey(ArrivedRatingScreen.screenKey), findsOneWidget);
    expect(find.text('Yolculuk Tamamlandı'), findsOneWidget);
    expect(find.byKey(ArrivedRatingScreen.completionBadgeKey), findsOneWidget);
    expect(find.text('Vardın!'), findsOneWidget);
    expect(
      find.text('Kadıköy İskele varış noktasına ulaştın'),
      findsOneWidget,
    );
    expect(find.text('TOPLAM TUTAR'), findsOneWidget);
    expect(find.text('4,8 km • 12 dk'), findsOneWidget);
    expect(fareText(tester), '₺185,00');
    expect(find.byKey(ArrivedRatingScreen.paymentRowKey), findsOneWidget);
    expect(find.text('•••• 4242'), findsOneWidget);
    expect(find.text('Mastercard'), findsOneWidget);
    expect(find.text('Ödendi'), findsOneWidget);
    expect(find.byKey(ArrivedRatingScreen.driverCardKey), findsOneWidget);
    expect(find.text('MY'), findsOneWidget);
    expect(find.text('Mehmet Y.'), findsOneWidget);
    expect(find.text('4,9'), findsOneWidget);
    expect(find.text('34 TK 1923 • Sarı Taksi'), findsOneWidget);
    expect(find.byKey(ArrivedRatingScreen.ratingCardKey), findsOneWidget);
    expect(find.text('Yolculuğunu puanla'), findsOneWidget);
    expect(
      find.text('Sürücüyü değerlendirerek Sarı kalitesini destekle'),
      findsOneWidget,
    );
    for (var star = 1; star <= 5; star++) {
      expect(find.byKey(ArrivedRatingScreen.starButtonKey(star)), findsOneWidget);
    }
    expect(find.byIcon(Icons.star_border_rounded), findsNWidgets(5));
    expect(find.byIcon(Icons.star_rounded), findsNothing);
    for (final tag in RideFeedbackTag.values) {
      expect(find.byKey(ArrivedRatingScreen.tagKey(tag)), findsOneWidget);
      expect(find.text(tag.label), findsOneWidget);
    }
    expect(find.byKey(ArrivedRatingScreen.finishButtonKey), findsOneWidget);
    expect(find.text('Bitir'), findsOneWidget);
    expect(find.byKey(ArrivedRatingScreen.emailButtonKey), findsOneWidget);
    expect(find.text('Faturayı E-Posta ile Gönder'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Turkuaz sınıfında toplam tutar Turkuaz ücretidir', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele)
      ..selectRideClass(RideClass.turkuaz);

    await pumpArrived(tester, flowController: flow);

    expect(fareText(tester), '₺215,00');

    flow.selectRideClass(RideClass.sari);
    await tester.pump();

    expect(fareText(tester), '₺185,00');
    expect(tester.takeException(), isNull);
  });

  testWidgets('4 yıldız ve Temiz araç seçimi görünür ve duruma yazılır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpArrived(tester, flowController: flow);

    await tester.tap(find.byKey(ArrivedRatingScreen.starButtonKey(4)));
    await tester.pump();
    await tester.tap(
      find.byKey(ArrivedRatingScreen.tagKey(RideFeedbackTag.temizArac)),
    );
    await tester.pump();

    expect(flow.rating, 4);
    expect(flow.tags, contains(RideFeedbackTag.temizArac));
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
    expect(find.byIcon(Icons.star_border_rounded), findsOneWidget);
    final chip = tester.widget<FilterChip>(
      find.byKey(ArrivedRatingScreen.tagKey(RideFeedbackTag.temizArac)),
    );
    expect(chip.selected, isTrue);

    await tester.tap(
      find.byKey(ArrivedRatingScreen.tagKey(RideFeedbackTag.temizArac)),
    );
    await tester.pump();

    expect(flow.tags, isNot(contains(RideFeedbackTag.temizArac)));
    final unselectedChip = tester.widget<FilterChip>(
      find.byKey(ArrivedRatingScreen.tagKey(RideFeedbackTag.temizArac)),
    );
    expect(unselectedChip.selected, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bitir tamamlanan yolculuğu kaydeder ve ana ekrana döner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final sessionController = SessionController(
      FakeSessionStore(_completedSession),
    );
    await sessionController.load();
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);
    final tripHistory = TripHistoryController(InMemoryTripHistoryStore());
    final completedAt = DateTime(2026, 11, 13, 9, 30);
    final router = createAppRouter(
      sessionController: sessionController,
      rideFlowController: flow,
      tripHistoryController: tripHistory,
      tileProvider: FakeTileProvider(),
      now: () => completedAt,
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(theme: buildSariTheme(), routerConfig: router),
    );
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);

    final context = tester.element(find.byType(HomeScreen));
    GoRouter.of(context).go(AppRoutes.arrived);
    await tester.pumpAndSettle();
    expect(find.byKey(ArrivedRatingScreen.screenKey), findsOneWidget);

    await tester.tap(find.byKey(ArrivedRatingScreen.starButtonKey(4)));
    await tester.pump();
    await tester.tap(find.byKey(ArrivedRatingScreen.finishButtonKey));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(ArrivedRatingScreen), findsNothing);
    final location = GoRouter.of(
      tester.element(find.byType(HomeScreen)),
    ).routerDelegate.currentConfiguration.uri.toString();
    expect(location, AppRoutes.home);
    expect(tripHistory.trips, hasLength(1));
    final recordedTrip = tripHistory.trips.single;
    expect(recordedTrip.departureLabel, 'Moda');
    expect(recordedTrip.distanceMeters, flow.quote!.distanceMeters);
    expect(recordedTrip.distanceMeters, 4800);
    expect(recordedTrip.duration, flow.quote!.duration);
    expect(recordedTrip.duration, const Duration(minutes: 12));
    expect(
      recordedTrip,
      CompletedTrip(
        destination: FakeRideData.kadikoyIskele,
        departureLabel: FakeRideData.homeAreaLabel,
        distanceMeters: flow.quote!.distanceMeters,
        duration: flow.quote!.duration,
        completedAt: completedAt,
        amountLira: 185,
        driver: FakeRideData.driver,
        rating: 4,
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Faturayı E-Posta ile Gönder Yakında gösterir ve ekranda kalır', (
    tester,
  ) async {
    final flow = RideFlowController()
      ..selectDestination(FakeRideData.kadikoyIskele);

    await pumpArrived(tester, flowController: flow);

    await tester.tap(find.byKey(ArrivedRatingScreen.emailButtonKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Yakında'), findsOneWidget);
    expect(find.byKey(ArrivedRatingScreen.screenKey), findsOneWidget);
    expect(find.text('Vardın!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(375, 667), Size(430, 932)]) {
    testWidgets('taşma yok ${size.width.toInt()}x${size.height.toInt()}', (
      tester,
    ) async {
      final flow = RideFlowController()
        ..selectDestination(FakeRideData.kadikoyIskele);

      await pumpArrived(tester, flowController: flow, size: size);

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byKey(ArrivedRatingScreen.screenKey)), size);

      await tester.ensureVisible(
        find.byKey(ArrivedRatingScreen.finishButtonKey),
      );
      await tester.pumpAndSettle();

      expect(
        tester.getBottomLeft(find.byKey(ArrivedRatingScreen.finishButtonKey)).dy,
        lessThanOrEqualTo(size.height),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
