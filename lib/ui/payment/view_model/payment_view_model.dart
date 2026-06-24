import 'package:bostra/controllers/payment_controller.dart';
import 'package:bostra/enums/card_brand.dart';
import 'package:bostra/models/payment_model.dart';
import 'package:bostra/ui/payment/state/payment_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentViewModelProvider =
    NotifierProvider<PaymentViewModel, PaymentState>(PaymentViewModel.new);

class PaymentViewModel extends Notifier<PaymentState> {
  late final PaymentController _paymentController;

  @override
  PaymentState build() {
    _paymentController = ref.read(paymentControllerProvider);
    return const PaymentState();
  }

  /// Clears any state from a previous session. Called when the sheet opens
  /// since the provider is a long-lived singleton.
  void reset() => state = const PaymentState();

  /// Updates the highlighted brand badge as the card number changes.
  void detectBrand(String rawNumber) {
    final detected = CardBrand.fromNumber(rawNumber);
    if (detected != state.brand) {
      state = state.copyWith(brand: detected);
    }
  }

  /// Runs the mock charge. Returns true on success (state holds the receipt),
  /// false on failure (state holds the error message).
  Future<bool> pay({
    required PaymentCard card,
    required double amount,
  }) async {
    state = state.copyWith(status: PaymentStatus.processing);

    final result = await _paymentController.processPayment(
      card: card,
      amount: amount,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: PaymentStatus.error,
          errorMessage: failure.errorMessage,
        );
        return false;
      },
      (paymentResult) {
        state = state.copyWith(
          status: PaymentStatus.success,
          result: paymentResult,
        );
        return true;
      },
    );
  }
}
