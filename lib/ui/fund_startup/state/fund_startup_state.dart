enum FundStatus { initial, loading, success, error }

class FundStartupState {
  final FundStatus status;
  final String? errorMessage;
  final bool agreedToTerms;
  final double? amount;

  const FundStartupState({
    this.status = FundStatus.initial,
    this.errorMessage,
    this.agreedToTerms = false,
    this.amount,
  });

  FundStartupState copyWith({
    FundStatus? status,
    String? errorMessage,
    bool? agreedToTerms,
    double? amount,
  }) {
    return FundStartupState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      agreedToTerms: agreedToTerms ?? this.agreedToTerms,
      amount: amount ?? this.amount,
    );
  }
}
