final class PaymentMethod {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.brand,
    this.expiryLabel,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String brand;
  final String? expiryLabel;
  final bool isDefault;

  bool get isCash => expiryLabel == null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentMethod &&
          other.id == id &&
          other.label == label &&
          other.brand == brand &&
          other.expiryLabel == expiryLabel &&
          other.isDefault == isDefault;

  @override
  int get hashCode => Object.hash(id, label, brand, expiryLabel, isDefault);
}
