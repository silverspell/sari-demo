import 'dart:async';

import 'package:alchemist/alchemist.dart';

/// Golden'lar gerçek fontla ve yalnız Linux'ta üretilir. QA ajanı golden'ları
/// tasarım PNG'leriyle karşılaştırırken metni okuyabilmelidir; CI modu metni
/// bloğa çevirdiği için kapalıdır. Validation sabit sürümlü Linux
/// devcontainer'ında koştuğu için çıktı kararlıdır.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  return AlchemistConfig.runWithConfig(
    config: AlchemistConfig(
      ciGoldensConfig: const CiGoldensConfig(enabled: false),
      platformGoldensConfig: PlatformGoldensConfig(
        platforms: {HostPlatform.linux},
      ),
    ),
    run: testMain,
  );
}
