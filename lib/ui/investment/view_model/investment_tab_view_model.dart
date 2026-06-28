import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/ui/investment/state/investment_tab_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final investmentTabViewModelProvider =
    NotifierProvider.autoDispose<InvestmentTabViewModel, InvestmentTabState>(
  InvestmentTabViewModel.new,
);

class InvestmentTabViewModel extends AutoDisposeNotifier<InvestmentTabState> {
  late InvestmentController _investmentController;
  late CampaignController _campaignController;

  @override
  InvestmentTabState build() {
    _investmentController = ref.watch(investmentControllerProvider);
    _campaignController = ref.watch(campaignControllerProvider);
    return const InvestmentTabState();
  }

  Future<void> fetchData() async {
    state = state.copyWith(status: InvestmentTabStatus.loading);

    final investmentsResult = await _investmentController.getMyInvestments();
    final campaignsResult = await _campaignController.getMyCampaigns();

    investmentsResult.fold(
      (failure) {
        state = state.copyWith(
          status: InvestmentTabStatus.error,
          errorMessage: failure.errorMessage,
        );
      },
      (investments) {
        campaignsResult.fold(
          (failure) {
            state = state.copyWith(
              status: InvestmentTabStatus.error,
              errorMessage: failure.errorMessage,
            );
          },
          (myCampaigns) {
            state = state.copyWith(
              status: InvestmentTabStatus.success,
              investments: investments,
              myCampaigns: myCampaigns,
            );
          },
        );
      },
    );
  }
}
