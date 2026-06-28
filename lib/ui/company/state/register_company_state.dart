import 'package:bostra/models/company_model.dart';
import 'package:equatable/equatable.dart';

enum RegisterCompanyStatus { initial, loading, success, error }

/// A founder the registrant wants to invite, captured before the company is
/// submitted. [phone] is normalised to digits (to match how Supabase stores
/// phone numbers); [displayPhone] is the pretty version shown in the UI.
class FounderDraft extends Equatable {
  final String phone;
  final String displayPhone;
  final String designation;

  const FounderDraft({
    required this.phone,
    required this.displayPhone,
    required this.designation,
  });

  @override
  List<Object?> get props => [phone, displayPhone, designation];
}

class RegisterCompanyState {
  final RegisterCompanyStatus status;
  final String? errorMessage;

  /// 0 = company details, 1 = founders.
  final int currentStep;

  final CompanyModel company;
  final String? logoPath; // local file path before upload
  final String? ownerDesignation;
  final List<FounderDraft> founderDrafts;

  /// Populated after a successful submit so the UI can navigate to it.
  final CompanyModel? createdCompany;

  /// Non-fatal warning (e.g. the company was created but some invites failed).
  final String? warningMessage;

  const RegisterCompanyState({
    this.status = RegisterCompanyStatus.initial,
    this.errorMessage,
    this.currentStep = 0,
    this.company = const CompanyModel(),
    this.logoPath,
    this.ownerDesignation,
    this.founderDrafts = const [],
    this.createdCompany,
    this.warningMessage,
  });

  RegisterCompanyState copyWith({
    RegisterCompanyStatus? status,
    String? errorMessage,
    int? currentStep,
    CompanyModel? company,
    String? logoPath,
    String? ownerDesignation,
    List<FounderDraft>? founderDrafts,
    CompanyModel? createdCompany,
    String? warningMessage,
  }) {
    return RegisterCompanyState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      currentStep: currentStep ?? this.currentStep,
      company: company ?? this.company,
      logoPath: logoPath ?? this.logoPath,
      ownerDesignation: ownerDesignation ?? this.ownerDesignation,
      founderDrafts: founderDrafts ?? this.founderDrafts,
      createdCompany: createdCompany ?? this.createdCompany,
      warningMessage: warningMessage ?? this.warningMessage,
    );
  }
}
