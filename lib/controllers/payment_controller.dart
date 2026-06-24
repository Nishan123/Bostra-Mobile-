import 'dart:math';

import 'package:bostra/failure/failure.dart';
import 'package:bostra/models/payment_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentControllerProvider = Provider((ref) {
  return PaymentController();
});

/// Simulated payment gateway used to make the funding flow feel real.
///
/// It validates the card the way a real acquirer surfaces errors (format,
/// expiry, CVC length), simulates the network round-trip, then returns a fake
/// transaction reference. No real charge is made and no card data leaves the
/// device — the PAN is never persisted, only the last four digits are kept.
class PaymentController {
  final Random _random = Random();

  Future<Either<Failure, PaymentResult>> processPayment({
    required PaymentCard card,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        return Left(GeneralFailure('Enter a valid amount to pay.'));
      }

      final validationError = _validateCard(card);
      if (validationError != null) {
        return Left(GeneralFailure(validationError));
      }

      // Simulate the round-trip to the acquiring bank.
      await Future.delayed(const Duration(milliseconds: 1900));

      return Right(
        PaymentResult(
          transactionId: _generateTransactionId(),
          last4: card.last4,
          brand: card.brand,
          amount: amount,
          processedAt: DateTime.now(),
        ),
      );
    } catch (e) {
      return Left(GeneralFailure('Payment could not be processed: $e'));
    }
  }

  /// Returns a user-facing error string, or null if the card passes checks.
  String? _validateCard(PaymentCard card) {
    final brand = card.brand;

    if (card.number.length < brand.numberLength) {
      return 'Your card number is incomplete.';
    }
    if (card.holderName.trim().isEmpty) {
      return "Enter the cardholder's name.";
    }

    final month = int.tryParse(card.expiryMonth);
    final year = int.tryParse(card.expiryYear);
    if (month == null ||
        year == null ||
        card.expiryMonth.length != 2 ||
        card.expiryYear.length != 2) {
      return "Your card's expiration date is incomplete.";
    }
    if (month < 1 || month > 12) {
      return "Your card's expiration date is invalid.";
    }

    // Valid through the last moment of the expiry month.
    final expiry = DateTime(2000 + year, month + 1, 0, 23, 59, 59);
    if (expiry.isBefore(DateTime.now())) {
      return 'Your card has expired.';
    }

    if (card.cvc.length != brand.cvcLength) {
      return "Your card's security code is incomplete.";
    }
    if (card.zip.trim().isEmpty) {
      return 'Enter your billing ZIP or postal code.';
    }
    return null;
  }

  String _generateTransactionId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final buffer = StringBuffer('txn_');
    for (var i = 0; i < 20; i++) {
      buffer.write(chars[_random.nextInt(chars.length)]);
    }
    return buffer.toString();
  }
}
