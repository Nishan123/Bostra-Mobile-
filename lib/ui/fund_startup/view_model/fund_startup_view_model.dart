import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/ui/fund_startup/state/fund_startup_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final fundStartupViewModelProvider =
    NotifierProvider.family<FundStartupViewModel, FundStartupState, String>(
  FundStartupViewModel.new,
);

/// ViewModel scoped to a single campaign ID.
/// The `arg` is the campaignId.
class FundStartupViewModel extends FamilyNotifier<FundStartupState, String> {
  late final InvestmentController _controller;

  @override
  FundStartupState build(String arg) {
    _controller = ref.read(investmentControllerProvider);
    return const FundStartupState();
  }

  void toggleAgreement() {
    state = state.copyWith(agreedToTerms: !state.agreedToTerms);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  Future<void> submitInvestment() async {
    final amount = state.amount;
    if (amount == null || amount <= 0) {
      state = state.copyWith(
        status: FundStatus.error,
        errorMessage: 'Please enter a valid amount.',
      );
      return;
    }

    if (!state.agreedToTerms) {
      state = state.copyWith(
        status: FundStatus.error,
        errorMessage: 'You must agree to the terms before investing.',
      );
      return;
    }

    state = state.copyWith(status: FundStatus.loading);

    final result = await _controller.invest(
      campaignId: arg,
      amount: amount,
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: FundStatus.error,
        errorMessage: failure.errorMessage,
      ),
      (_) => state = state.copyWith(status: FundStatus.success),
    );
  }

  void resetStatus() {
    state = state.copyWith(status: FundStatus.initial, errorMessage: null);
  }
}
