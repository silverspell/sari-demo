@Tags(['golden'])
library;

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sari/screens/destination_screen.dart';
import 'package:sari/theme/sari_theme.dart';

void main() {
  goldenTest(
    'Nereye ekranı',
    fileName: '06-destination',
    builder: () => GoldenTestGroup(
      columns: 1,
      children: [
        GoldenTestScenario(
          name: 'iPhone SE (375x667)',
          child: destinationGolden(const Size(375, 667)),
        ),
        GoldenTestScenario(
          name: 'iPhone 15 Pro Max (430x932)',
          child: destinationGolden(const Size(430, 932)),
        ),
      ],
    ),
  );
}

Widget destinationGolden(Size size) {
  return SizedBox(
    width: size.width,
    height: size.height,
    child: MediaQuery(
      data: MediaQueryData(size: size),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Theme(data: buildSariTheme(), child: const DestinationScreen()),
      ),
    ),
  );
}
