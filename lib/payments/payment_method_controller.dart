import 'package:flutter/foundation.dart';

import '../data/fake_ride_data.dart';
import '../data/payment_method.dart';

class PaymentMethodController extends ChangeNotifier {
  PaymentMethodController({
    List<PaymentMethod>? methods,
    PaymentMethod? initialMethod,
  }) : _methods = List<PaymentMethod>.unmodifiable(
         methods ?? FakeRideData.paymentMethods,
       ) {
    if (_methods.isEmpty) {
      throw ArgumentError.value(
        methods,
        'methods',
        'En az bir ödeme yöntemi gerekli',
      );
    }
    _selected = initialMethod ?? _resolveDefault(_methods);
  }

  final List<PaymentMethod> _methods;
  late PaymentMethod _selected;

  List<PaymentMethod> get methods => _methods;

  PaymentMethod get selected => _selected;

  void select(PaymentMethod method) {
    if (_selected == method) {
      return;
    }
    _selected = method;
    notifyListeners();
  }

  static PaymentMethod _resolveDefault(List<PaymentMethod> methods) {
    for (final method in methods) {
      if (method.isDefault) {
        return method;
      }
    }
    return methods.first;
  }
}
