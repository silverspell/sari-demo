@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/arrived_rating_screen.dart';
import 'package:sari/theme/sari_theme.dart';
import 'package:sari/trips/in_memory_trip_history_store.dart';
import 'package:sari/trips/trip_history_controller.dart';

void main() {
  goldenTest(
    'Vardın ekranı',
    fileName: '11-arrived-rating',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: arrivedRatingGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: arrivedRatingGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget arrivedRatingGolden(Size size) {
  final flowController = RideFlowController()
    ..selectDestination(FakeRideData.kadikoyIskele);

  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: ArrivedRatingScreen(
            flowController: flowController,
            tripHistoryController: TripHistoryController(
              InMemoryTripHistoryStore(),
            ),
          ),
        ),
      ),
    ),
  );
}
