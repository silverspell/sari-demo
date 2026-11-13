@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/ride_screen.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

void main() {
  goldenTest(
    'Yolculukta ekranı',
    fileName: '10-ride',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: rideGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: rideGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget rideGolden(Size size) {
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
          child: RideScreen(
            flowController: flowController,
            tileProvider: FakeTileProvider(),
            animationsEnabled: false,
            animationFrame: 1 / 3,
            rideDuration: RideScreen.defaultRideDuration,
          ),
        ),
      ),
    ),
  );
}
