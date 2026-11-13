@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/rides/ride_flow_controller.dart';
import 'package:sari/screens/driver_found_screen.dart';
import 'package:sari/theme/sari_theme.dart';

import 'support/fake_tile_provider.dart';

void main() {
  goldenTest(
    'Sürücü bulundu ekranı',
    fileName: '09-driver-found',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: driverFoundGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: driverFoundGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget driverFoundGolden(Size size) {
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
          child: DriverFoundScreen(
            flowController: flowController,
            tileProvider: FakeTileProvider(),
            animationsEnabled: false,
            animationFrame: 0.68,
            arrivalDuration: DriverFoundScreen.defaultArrivalDuration,
          ),
        ),
      ),
    ),
  );
}
