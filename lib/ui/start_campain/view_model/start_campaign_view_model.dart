import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final campaignViewModelProvider = NotifierProvider<StartCampaignViewModel, CampaignState>(StartCampaignViewModel.new);

class StartCampaignViewModel extends Notifier<CampaignState> {
  late final CampaignController _campaignController;

  @override
  CampaignState build() {
    _campaignController = ref.read(campaignControllerProvider);
    return const CampaignState();
  }

  void updateStartupName(String name) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(startupName: name),
    );
  }

  void updateShortTagline(String tagline) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(shortTagline: tagline),
    );
  }

  void updateIndustry(String industry) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(industry: industry),
    );
  }

  void updateMonthProjection(
    int monthNumber,
    String monthLabel, {
    String? objectives,
    String? goals,
    String? initiative,
  }) {
    final list = List<MonthProjection>.from(state.campaign.monthProjections);
    final index = list.indexWhere((element) => element.monthNumber == monthNumber);

    final currentProj = index != -1
        ? list[index]
        : MonthProjection(monthNumber: monthNumber, monthLabel: monthLabel);

    final updatedProj = currentProj.copyWith(
      objectives: objectives,
      goals: goals,
      initiative: initiative,
    );

    if (index != -1) {
      list[index] = updatedProj;
    } else {
      list.add(updatedProj);
    }

    state = state.copyWith(
      campaign: state.campaign.copyWith(monthProjections: list),
    );
  }

  void updateDescription(String description) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(description: description),
    );
  }

  void updateProblemStatement(String problem) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(problemStatement: problem),
    );
  }

  void updateSolution(String solution) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(solution: solution),
    );
  }

  void updateTargetAudience(String targetAudience) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(targetAudience: targetAudience),
    );
  }

  void updateUniqueSellingPoint(String usp) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(uniqueSellingPoint: usp),
    );
  }

  void updateDocumentUrl(String docType, String? url) {
    if (docType == 'Company Registration') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(companyRegistrationUrl: url),
      );
    } else if (docType == 'PAN') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(panUrl: url),
      );
    } else if (docType == 'MOA / AOA') {
      state = state.copyWith(
        campaign: state.campaign.copyWith(moaAoaUrl: url),
      );
    }
  }

  void updateTargetAmount(double amount) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(targetAmount: amount),
    );
  }

  void updateAgreedToTerms(bool agreed) {
    state = state.copyWith(
      campaign: state.campaign.copyWith(agreedToTerms: agreed),
    );
  }

  Future<bool> submitCampaign() async {
    state = state.copyWith(status: CampaignStatus.loading, errorMessage: null);

    final result = await _campaignController.createCampaign(state.campaign);

    return result.fold(
      (failure) {
        state = state.copyWith(
          status: CampaignStatus.error,
          errorMessage: failure.errorMessage,
        );
        return false;
      },
      (campaign) {
        state = state.copyWith(
          status: CampaignStatus.success,
          campaign: campaign,
        );
        return true;
      },
    );
  }

  void resetStatus() {
    state = state.copyWith(status: CampaignStatus.initial, errorMessage: null);
  }
}
