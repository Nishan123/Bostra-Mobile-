import 'package:bostra/models/campaign_model.dart';

enum CampaignStatus { initial, loading, success, error }

class CampaignState {
  final CampaignStatus status;
  final String? errorMessage;
  final CampaignModel campaign;

  const CampaignState({
    this.status = CampaignStatus.initial,
    this.errorMessage,
    this.campaign = const CampaignModel(),
  });

  CampaignState copyWith({
    CampaignStatus? status,
    String? errorMessage,
    CampaignModel? campaign,
  }) {
    return CampaignState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      campaign: campaign ?? this.campaign,
    );
  }
}
