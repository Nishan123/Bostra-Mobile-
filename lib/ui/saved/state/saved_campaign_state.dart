import 'package:bostra/models/campaign_model.dart';

class SavedCampaignState {
  final List<CampaignModel> savedCampaigns;

  const SavedCampaignState({this.savedCampaigns = const []});

  /// Set of non-null campaign IDs currently saved — used for O(1) lookup.
  Set<String> get savedIds =>
      savedCampaigns.map((c) => c.id).whereType<String>().toSet();

  SavedCampaignState copyWith({List<CampaignModel>? savedCampaigns}) {
    return SavedCampaignState(
      savedCampaigns: savedCampaigns ?? this.savedCampaigns,
    );
  }
}
