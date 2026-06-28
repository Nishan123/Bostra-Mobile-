import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/models/company_model.dart';
import 'package:bostra/models/founder_model.dart';

enum CompanyDetailStatus { initial, loading, success, error }

/// Status for one-off actions (invite, remove founder) layered on top of the
/// page load so they can drive snackbars without clobbering the loaded data.
enum CompanyActionStatus { idle, loading, success, error }

class CompanyDetailState {
  final CompanyDetailStatus status;
  final String? errorMessage;
  final CompanyModel? company;
  final List<FounderModel> founders;
  final List<CampaignModel> campaigns;

  final CompanyActionStatus actionStatus;
  final String? actionMessage;

  const CompanyDetailState({
    this.status = CompanyDetailStatus.initial,
    this.errorMessage,
    this.company,
    this.founders = const [],
    this.campaigns = const [],
    this.actionStatus = CompanyActionStatus.idle,
    this.actionMessage,
  });

  bool get isOwner => company?.isOwner ?? false;

  List<FounderModel> get activeFounders =>
      founders.where((f) => f.isActive).toList();

  List<FounderModel> get pendingFounders =>
      founders.where((f) => f.isPending).toList();

  CompanyDetailState copyWith({
    CompanyDetailStatus? status,
    String? errorMessage,
    CompanyModel? company,
    List<FounderModel>? founders,
    List<CampaignModel>? campaigns,
    CompanyActionStatus? actionStatus,
    String? actionMessage,
  }) {
    return CompanyDetailState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      company: company ?? this.company,
      founders: founders ?? this.founders,
      campaigns: campaigns ?? this.campaigns,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }
}
