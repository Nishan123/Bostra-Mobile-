import 'package:bostra/models/portfolio_models.dart';

enum PortfolioStatus { initial, loading, success, error }

/// Sub-status for the AI summary, independent of the main data load so the
/// list/chart render immediately while the summary streams in behind them.
enum SummaryStatus { idle, loading, success, error }

class PortfolioState {
  final PortfolioStatus status;
  final String? errorMessage;

  final List<PortfolioHolding> holdings;
  final List<SectorAllocation> sectors;
  final double totalInvested;
  final double totalImpliedValue;

  final SummaryStatus summaryStatus;
  final String? aiSummary;
  final String? summaryError;

  const PortfolioState({
    this.status = PortfolioStatus.initial,
    this.errorMessage,
    this.holdings = const [],
    this.sectors = const [],
    this.totalInvested = 0,
    this.totalImpliedValue = 0,
    this.summaryStatus = SummaryStatus.idle,
    this.aiSummary,
    this.summaryError,
  });

  double get totalReturnPct => totalInvested > 0
      ? ((totalImpliedValue - totalInvested) / totalInvested) * 100
      : 0;

  int get sectorCount => sectors.length;

  bool get isEmpty => holdings.isEmpty;

  PortfolioState copyWith({
    PortfolioStatus? status,
    String? errorMessage,
    List<PortfolioHolding>? holdings,
    List<SectorAllocation>? sectors,
    double? totalInvested,
    double? totalImpliedValue,
    SummaryStatus? summaryStatus,
    String? aiSummary,
    String? summaryError,
  }) {
    return PortfolioState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      holdings: holdings ?? this.holdings,
      sectors: sectors ?? this.sectors,
      totalInvested: totalInvested ?? this.totalInvested,
      totalImpliedValue: totalImpliedValue ?? this.totalImpliedValue,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      aiSummary: aiSummary ?? this.aiSummary,
      summaryError: summaryError ?? this.summaryError,
    );
  }
}
