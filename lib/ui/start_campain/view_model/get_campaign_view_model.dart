import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getCampaignViewModelProvider =
    NotifierProvider<GetCampaignViewModel, GetCampaignState>(
  GetCampaignViewModel.new,
);

class GetCampaignViewModel extends Notifier<GetCampaignState> {
  late final CampaignController _campaignController;

  @override
  GetCampaignState build() {
    _campaignController = ref.read(campaignControllerProvider);
    Future.microtask(fetchVerifiedCampaigns);
    return const GetCampaignState();
  }

  Future<void> fetchVerifiedCampaigns() async {
    state = state.copyWith(status: CampaignStatus.loading, errorMessage: null);
    final result = await _campaignController.getVerifiedCampaigns();
    result.fold(
      (failure) => state = state.copyWith(
        status: CampaignStatus.error,
        errorMessage: failure.errorMessage,
      ),
      (campaigns) => state = state.copyWith(
        status: CampaignStatus.success,
        campaigns: campaigns,
      ),
    );
  }
}
