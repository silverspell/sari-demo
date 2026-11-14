import 'package:flutter_test/flutter_test.dart';
import 'package:sari/data/fake_ride_data.dart';
import 'package:sari/data/payment_method.dart';
import 'package:sari/payments/payment_method_controller.dart';

void main() {
  group('PaymentMethodController', () {
    test('varsayılan seçim sahte veride işaretli yöntemdir', () {
      final controller = PaymentMethodController();
      addTearDown(controller.dispose);

      expect(controller.methods, FakeRideData.paymentMethods);
      expect(controller.selected, FakeRideData.visa4242);
      expect(controller.selected.brand, 'Visa');
      expect(controller.selected.isDefault, isTrue);
    });

    test('initialMethod verilirse seçili yöntem odur', () {
      final controller = PaymentMethodController(
        initialMethod: FakeRideData.mastercard5310,
      );
      addTearDown(controller.dispose);

      expect(controller.selected, FakeRideData.mastercard5310);
      expect(controller.selected.brand, 'Mastercard');
    });

    test('işaretli yöntem yoksa ilk yöntem varsayılan olur', () {
      const first = PaymentMethod(id: 'ilk', label: 'İlk', brand: 'İlk');
      const second = PaymentMethod(
        id: 'ikinci',
        label: 'İkinci',
        brand: 'İkinci',
      );
      final controller = PaymentMethodController(
        methods: const <PaymentMethod>[first, second],
      );
      addTearDown(controller.dispose);

      expect(controller.selected, first);
    });

    test('select farklı yöntemde seçimi değiştirir ve yalnız değişimde '
        'dinleyicileri bildirir', () {
      final controller = PaymentMethodController();
      addTearDown(controller.dispose);
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.select(FakeRideData.nakit);

      expect(controller.selected, FakeRideData.nakit);
      expect(controller.selected.isCash, isTrue);
      expect(notifications, 1);

      controller.select(FakeRideData.nakit);

      expect(notifications, 1);
    });

    test('methods listesi dışarıdan değiştirilemez', () {
      final controller = PaymentMethodController();
      addTearDown(controller.dispose);

      expect(
        () => controller.methods.add(FakeRideData.nakit),
        throwsUnsupportedError,
      );
    });
  });
}
