class PaymentCard {
  final String id;
  final String holder;
  final String last4;
  final String expiry; // MM/YY
  final String brand;  // Visa, Mastercard, Amex, Card

  const PaymentCard({
    required this.id,
    required this.holder,
    required this.last4,
    required this.expiry,
    required this.brand,
  });

  static String detectBrand(String number) {
    if (number.startsWith('4')) return 'Visa';
    if (number.length >= 2) {
      final two = int.tryParse(number.substring(0, 2)) ?? 0;
      if (two >= 51 && two <= 55) return 'Mastercard';
      if (two == 34 || two == 37) return 'Amex';
    }
    return 'Card';
  }
}
