import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/reward_tier_model.dart';

enum CampaignStatus { initial, loading, success, error }

class GetCampaignState {
  final CampaignStatus status;
  final String? errorMessage;
  final List<CampaignModel> campaigns;

  const GetCampaignState({
    this.status = CampaignStatus.initial,
    this.errorMessage,
    this.campaigns = const [],
  });

  GetCampaignState copyWith({
    CampaignStatus? status,
    String? errorMessage,
    List<CampaignModel>? campaigns,
  }) {
    return GetCampaignState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      campaigns: campaigns ?? this.campaigns,
    );
  }
}

class CampaignState {
  final CampaignStatus status;
  final String? errorMessage;
  final CampaignModel campaign;

  /// Draft investor reward tiers being configured for this campaign. Persisted
  /// to the campaign_reward_tiers table (not the campaign row) on submit.
  final List<RewardTierModel> rewardTiers;

  const CampaignState({
    this.status = CampaignStatus.initial,
    this.errorMessage,
    this.campaign = const CampaignModel(),
    this.rewardTiers = const [],
  });

  CampaignState copyWith({
    CampaignStatus? status,
    String? errorMessage,
    CampaignModel? campaign,
    List<RewardTierModel>? rewardTiers,
  }) {
    return CampaignState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      campaign: campaign ?? this.campaign,
      rewardTiers: rewardTiers ?? this.rewardTiers,
    );
  }
}
