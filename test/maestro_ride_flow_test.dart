import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  test('ride_flow.yaml girişten puanlamaya kadar adımları sırayla içerir', () {
    final source = File('.maestro/ride_flow.yaml').readAsStringSync();
    final documents = loadYamlDocuments(source);

    expect(documents, isNotEmpty);

    final header = documents.first.contents;
    expect(header, isA<YamlMap>());
    expect((header as YamlMap)['appId'], 'tr.byteflow.sari');

    expect(documents.length, greaterThanOrEqualTo(2));
    final commands = documents[1].contents;
    expect(commands, isA<YamlList>());

    final values = <String>[];
    void collect(Object? node) {
      if (node is String) {
        values.add(node);
      } else if (node is YamlList) {
        for (final item in node) {
          collect(item);
        }
      } else if (node is YamlMap) {
        for (final value in node.values) {
          collect(value);
        }
      }
    }

    collect(commands);

    const expectedSteps = <String>[
      'Telefon numaranı gir',
      'Kodu gir',
      'Seni nasıl çağıralım?',
      'Konumunu kullanalım',
      'Merhaba Ayşe',
      'Nereye?',
      'Taksi çağır',
      'Nereye?',
      'Nereye gitmek istersiniz?',
      'Kadıköy İskele',
      'Rota Ve Ücret Tahmini',
      'Sarı Taksi',
      'Taksi Çağır',
      'Taksi Aranıyor',
      'Sürücü Yolda',
      'Yolculuk Başladı',
      'Yolculuk Tamamlandı',
      'Yolculuğunu puanla',
      '5 Yıldız',
      'Bitir',
      'Merhaba Ayşe',
      'Nereye?',
    ];

    var cursor = 0;
    for (final step in expectedSteps) {
      final index = values.indexOf(step, cursor);
      expect(
        index,
        isNot(-1),
        reason: '"$step" adımı beklenen sırada bulunamadı.',
      );
      cursor = index + 1;
    }
  });
}
