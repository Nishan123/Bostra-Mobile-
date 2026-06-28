import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/ui/manage_campaign/state/manage_campaign_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final manageCampaignViewModelProvider =
    NotifierProvider<ManageCampaignViewModel, ManageCampaignState>(
  ManageCampaignViewModel.new,
);

class ManageCampaignViewModel extends Notifier<ManageCampaignState> {
  late CampaignController _campaignController;

  @override
  ManageCampaignState build() {
    _campaignController = ref.read(campaignControllerProvider);
    return const ManageCampaignState();
  }

  /// Seed the screen with the campaign being managed.
  void init(CampaignModel campaign) {
    state = ManageCampaignState(campaign: campaign);
  }

  /// Founder management action — update target amount and/or funding end date.
  Future<bool> save({
    required double targetAmount,
    required DateTime endDate,
  }) async {
    final campaignId = state.campaign.id;
    if (campaignId == null) {
      state = state.copyWith(
        status: ManageCampaignStatus.error,
        errorMessage: 'Campaign id missing.',
      );
      return false;
    }
    if (targetAmount <= 0) {
      state = state.copyWith(
        status: ManageCampaignStatus.error,
        errorMessage: 'Please enter a valid target amount.',
      );
      return false;
    }
    if (targetAmount < state.campaign.currentFunding) {
      state = state.copyWith(
        status: ManageCampaignStatus.error,
        errorMessage:
            'Target cannot be below the amount already raised (NPR ${state.campaign.currentFunding.toStringAsFixed(0)}).',
      );
      return false;
    }

    state = state.copyWith(
      status: ManageCampaignStatus.loading,
      errorMessage: null,
    );

    final result = await _campaignController.updateCampaignFunding(
      campaignId: campaignId,
      targetAmount: targetAmount,
      endDate: endDate,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: ManageCampaignStatus.error,
          errorMessage: failure.errorMessage,
        );
        return false;
      },
      (updated) {
        state = state.copyWith(
          status: ManageCampaignStatus.success,
          campaign: updated,
        );
        return true;
      },
    );
  }

  void resetStatus() => state = state.copyWith(
        status: ManageCampaignStatus.initial,
        errorMessage: null,
      );
}
