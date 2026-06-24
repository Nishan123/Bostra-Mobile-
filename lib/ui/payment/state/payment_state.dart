import 'package:bostra/enums/card_brand.dart';
import 'package:bostra/models/payment_model.dart';

enum PaymentStatus { initial, processing, success, error }

class PaymentState {
  final PaymentStatus status;
  final String? errorMessage;

  /// Network detected from the card number as the user types — drives the
  /// highlighted brand badge in the sheet.
  final CardBrand brand;

  /// Receipt returned by the gateway once the charge succeeds.
  final PaymentResult? result;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.errorMessage,
    this.brand = CardBrand.unknown,
    this.result,
  });

  PaymentState copyWith({
    PaymentStatus? status,
    String? errorMessage,
    CardBrand? brand,
    PaymentResult? result,
  }) {
    return PaymentState(
      status: status ?? this.status,
      // Passed directly (not coalesced) so it can be cleared on retry/typing.
      errorMessage: errorMessage,
      brand: brand ?? this.brand,
      result: result ?? this.result,
    );
  }
}
