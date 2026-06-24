import 'package:bostra/enums/card_brand.dart';

/// User-entered card details collected by the payment sheet.
/// [number] holds raw digits only (formatting spaces stripped).
class PaymentCard {
  final String number;
  final String expiryMonth; // MM
  final String expiryYear; // YY
  final String cvc;
  final String holderName;
  final String country;
  final String zip;

  const PaymentCard({
    required this.number,
    required this.expiryMonth,
    required this.expiryYear,
    required this.cvc,
    required this.holderName,
    required this.country,
    required this.zip,
  });

  CardBrand get brand => CardBrand.fromNumber(number);

  String get last4 =>
      number.length >= 4 ? number.substring(number.length - 4) : number;
}

/// Result of a successful (mock) charge. Mirrors the shape a real gateway
/// would return so the rest of the app can treat it as a normal receipt.
class PaymentResult {
  final String transactionId;
  final String last4;
  final CardBrand brand;
  final double amount;
  final DateTime processedAt;

  const PaymentResult({
    required this.transactionId,
    required this.last4,
    required this.brand,
    required this.amount,
    required this.processedAt,
  });

  Map<String, dynamic> toJson() => {
        'transaction_id': transactionId,
        'last4': last4,
        'brand': brand.name,
        'amount': amount,
        'processed_at': processedAt.toIso8601String(),
      };

  @override
  String toString() =>
      'PaymentResult($transactionId, ${brand.label} ****$last4, $amount)';
}
