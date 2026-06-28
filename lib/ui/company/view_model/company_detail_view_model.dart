import 'package:bostra/controllers/campaign_controller.dart';
import 'package:bostra/controllers/company_controller.dart';
import 'package:bostra/models/company_model.dart';
import 'package:bostra/ui/company/state/company_detail_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final companyDetailViewModelProvider =
    NotifierProvider<CompanyDetailViewModel, CompanyDetailState>(
  CompanyDetailViewModel.new,
);

class CompanyDetailViewModel extends Notifier<CompanyDetailState> {
  late CompanyController _companyController;
  late CampaignController _campaignController;

  @override
  CompanyDetailState build() {
    _companyController = ref.read(companyControllerProvider);
    _campaignController = ref.read(campaignControllerProvider);
    return const CompanyDetailState();
  }

  /// Loads founders + campaigns for [company]. Resets any prior state so the
  /// screen always reflects the company being viewed.
  Future<void> load(CompanyModel company) async {
    state = CompanyDetailState(
      status: CompanyDetailStatus.loading,
      company: company,
    );

    if (company.id == null) {
      state = state.copyWith(
        status: CompanyDetailStatus.error,
        errorMessage: 'Company id missing.',
      );
      return;
    }

    // Re-fetch the company row so verification status (and other fields) stay
    // current — e.g. after an admin verifies the company and the user refreshes.
    final companyRes = await _companyController.getCompanyById(company.id!);
    final foundersRes =
        await _companyController.getCompanyFounders(company.id!);
    final campaignsRes =
        await _campaignController.getCampaignsByCompany(company.id!);

    String? error;
    var resolvedCompany = company;
    var founders = state.founders;
    var campaigns = state.campaigns;

    companyRes.fold((_) {}, (c) {
      resolvedCompany = c;
    });
    foundersRes.fold((f) {
      error = f.errorMessage;
    }, (v) {
      founders = v;
    });
    campaignsRes.fold((f) {
      error ??= f.errorMessage;
    }, (v) {
      campaigns = v;
    });

    if (error != null && founders.isEmpty && campaigns.isEmpty) {
      state = state.copyWith(
        status: CompanyDetailStatus.error,
        errorMessage: error,
      );
      return;
    }

    state = state.copyWith(
      status: CompanyDetailStatus.success,
      company: resolvedCompany,
      founders: founders,
      campaigns: campaigns,
    );
  }

  Future<void> refresh() async {
    final company = state.company;
    if (company != null) await load(company);
  }

  Future<bool> inviteFounder({
    required String phone,
    required String designation,
  }) async {
    final companyId = state.company?.id;
    if (companyId == null) return false;

    state = state.copyWith(actionStatus: CompanyActionStatus.loading);
    final result = await _companyController.inviteFounder(
      companyId: companyId,
      phone: phone,
      designation: designation,
    );

    return await result.fold(
      (failure) async {
        state = state.copyWith(
          actionStatus: CompanyActionStatus.error,
          actionMessage: failure.errorMessage,
        );
        return false;
      },
      (_) async {
        await _reloadFounders();
        state = state.copyWith(
          actionStatus: CompanyActionStatus.success,
          actionMessage: 'Invitation sent.',
        );
        return true;
      },
    );
  }

  Future<bool> removeFounder(String founderId) async {
    state = state.copyWith(actionStatus: CompanyActionStatus.loading);
    final result = await _companyController.removeFounder(founderId);

    return await result.fold(
      (failure) async {
        state = state.copyWith(
          actionStatus: CompanyActionStatus.error,
          actionMessage: failure.errorMessage,
        );
        return false;
      },
      (_) async {
        await _reloadFounders();
        state = state.copyWith(
          actionStatus: CompanyActionStatus.success,
          actionMessage: 'Founder removed.',
        );
        return true;
      },
    );
  }

  Future<void> _reloadFounders() async {
    final companyId = state.company?.id;
    if (companyId == null) return;
    final res = await _companyController.getCompanyFounders(companyId);
    res.fold((_) {}, (founders) {
      state = state.copyWith(founders: founders);
    });
  }

  void resetActionStatus() =>
      state = state.copyWith(actionStatus: CompanyActionStatus.idle);
}
