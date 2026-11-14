@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/trip_history_screen.dart';
import 'package:sari/theme/sari_theme.dart';
import 'package:sari/trips/trip_history_controller.dart';

import 'support/fake_trip_history_data.dart';

void main() {
  goldenTest(
    'Yolculuklarım ekranı',
    fileName: '13-trip-history',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: tripHistoryGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: tripHistoryGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget tripHistoryGolden(Size size) {
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(
          data: buildSariTheme(),
          child: FutureBuilder<TripHistoryController>(
            future: createSeededTripHistoryController(),
            builder: (context, snapshot) {
              final controller = snapshot.data;
              if (controller == null) {
                return const SizedBox.shrink();
              }
              return TripHistoryScreen(
                tripHistoryController: controller,
                now: () => fakeTripHistoryNow,
              );
            },
          ),
        ),
      ),
    ),
  );
}
