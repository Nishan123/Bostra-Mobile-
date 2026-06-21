import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/investment_model.dart';

enum InvestmentTabStatus { initial, loading, success, error }

class InvestmentTabState {
  final InvestmentTabStatus status;
  final List<InvestmentModel> investments;
  final List<CampaignModel> myCampaigns;
  final String? errorMessage;

  const InvestmentTabState({
    this.status = InvestmentTabStatus.initial,
    this.investments = const [],
    this.myCampaigns = const [],
    this.errorMessage,
  });

  InvestmentTabState copyWith({
    InvestmentTabStatus? status,
    List<InvestmentModel>? investments,
    List<CampaignModel>? myCampaigns,
    String? errorMessage,
  }) {
    return InvestmentTabState(
      status: status ?? this.status,
      investments: investments ?? this.investments,
      myCampaigns: myCampaigns ?? this.myCampaigns,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
