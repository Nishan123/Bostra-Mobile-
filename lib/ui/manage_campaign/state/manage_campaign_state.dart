import 'package:bostra/models/campaign_model.dart';

enum ManageCampaignStatus { initial, loading, success, error }

class ManageCampaignState {
  final ManageCampaignStatus status;
  final String? errorMessage;
  final CampaignModel campaign;

  const ManageCampaignState({
    this.status = ManageCampaignStatus.initial,
    this.errorMessage,
    this.campaign = const CampaignModel(),
  });

  ManageCampaignState copyWith({
    ManageCampaignStatus? status,
    String? errorMessage,
    CampaignModel? campaign,
  }) {
    return ManageCampaignState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      campaign: campaign ?? this.campaign,
    );
  }
}
