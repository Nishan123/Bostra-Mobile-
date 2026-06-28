import 'package:bostra/controllers/company_controller.dart';
import 'package:bostra/controllers/user_controller.dart';
import 'package:bostra/models/company_model.dart';
import 'package:bostra/ui/company/state/register_company_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final registerCompanyViewModelProvider =
    NotifierProvider<RegisterCompanyViewModel, RegisterCompanyState>(
  RegisterCompanyViewModel.new,
);

class RegisterCompanyViewModel extends Notifier<RegisterCompanyState> {
  late CompanyController _companyController;
  late UserController _userController;

  @override
  RegisterCompanyState build() {
    _companyController = ref.read(companyControllerProvider);
    _userController = ref.read(userControllerProvider);
    return const RegisterCompanyState();
  }

  /// Clears the whole draft — call when the registration screen opens.
  void reset() => state = const RegisterCompanyState();

  void goToStep(int step) => state = state.copyWith(currentStep: step);

  // ── Company field setters ────────────────────────────────────────────────
  void updateName(String v) =>
      state = state.copyWith(company: state.company.copyWith(name: v));
  void updateTagline(String v) =>
      state = state.copyWith(company: state.company.copyWith(tagline: v));
  void updateDescription(String v) =>
      state = state.copyWith(company: state.company.copyWith(description: v));
  void updateIndustry(String v) =>
      state = state.copyWith(company: state.company.copyWith(industry: v));
  void updateRegistrationNumber(String v) => state =
      state.copyWith(company: state.company.copyWith(registrationNumber: v));
  void updateWebsite(String v) =>
      state = state.copyWith(company: state.company.copyWith(website: v));
  void updateEmail(String v) =>
      state = state.copyWith(company: state.company.copyWith(email: v));
  void updateCity(String v) =>
      state = state.copyWith(company: state.company.copyWith(city: v));
  void updateCountry(String v) =>
      state = state.copyWith(company: state.company.copyWith(country: v));

  void setLogoPath(String? path) => state = state.copyWith(logoPath: path);
  void setOwnerDesignation(String d) =>
      state = state.copyWith(ownerDesignation: d);

  // ── Founder drafts ───────────────────────────────────────────────────────
  /// Returns false if a founder with the same phone is already in the draft.
  bool addFounderDraft(FounderDraft draft) {
    if (state.founderDrafts.any((d) => d.phone == draft.phone)) return false;
    state = state.copyWith(founderDrafts: [...state.founderDrafts, draft]);
    return true;
  }

  void removeFounderDraft(int index) {
    final list = [...state.founderDrafts]..removeAt(index);
    state = state.copyWith(founderDrafts: list);
  }

  // ── Submit ────────────────────────────────────────────────────────────────
  Future<bool> submit() async {
    if (state.company.name.trim().isEmpty) {
      state = state.copyWith(
        status: RegisterCompanyStatus.error,
        errorMessage: 'Company name is required.',
      );
      return false;
    }
    if (state.ownerDesignation == null || state.ownerDesignation!.isEmpty) {
      state = state.copyWith(
        status: RegisterCompanyStatus.error,
        errorMessage: 'Please select your role in the company.',
      );
      return false;
    }

    state = state.copyWith(
      status: RegisterCompanyStatus.loading,
      errorMessage: null,
      warningMessage: '',
    );

    final auth = Supabase.instance.client.auth.currentUser;
    final ownerId = auth?.id;
    if (ownerId == null) {
      state = state.copyWith(
        status: RegisterCompanyStatus.error,
        errorMessage: 'Session expired. Please log in again.',
      );
      return false;
    }

    // Resolve the owner's stored phone + name (source of truth for matching).
    String ownerPhone = auth?.phone ?? '';
    String? ownerName;
    final me = await _userController.getCurrentUser();
    me.fold((_) {}, (u) {
      if (u != null) {
        if (u.phone.isNotEmpty) ownerPhone = u.phone;
        ownerName = u.fullName;
      }
    });

    var company = state.company;

    // 1. Upload logo (if picked).
    if (state.logoPath != null && state.logoPath!.isNotEmpty) {
      final upload =
          await _companyController.uploadCompanyLogo(filePath: state.logoPath!);
      final ok = upload.fold(
        (failure) {
          state = state.copyWith(
            status: RegisterCompanyStatus.error,
            errorMessage: failure.errorMessage,
          );
          return false;
        },
        (url) {
          company = company.copyWith(logoUrl: url);
          return true;
        },
      );
      if (!ok) return false;
    }

    // 2. Create the company.
    final created = await _companyController.createCompany(company);
    final CompanyModel? createdCompany = created.fold(
      (failure) {
        state = state.copyWith(
          status: RegisterCompanyStatus.error,
          errorMessage: failure.errorMessage,
        );
        return null;
      },
      (c) => c,
    );
    if (createdCompany == null || createdCompany.id == null) return false;

    final warnings = <String>[];

    // 3. Register the owner as an active founder.
    final ownerResult = await _companyController.addOwnerFounder(
      companyId: createdCompany.id!,
      ownerUserId: ownerId,
      phone: ownerPhone,
      fullName: ownerName,
      designation: state.ownerDesignation!,
    );
    ownerResult.fold(
      (failure) => warnings.add('Owner record: ${failure.errorMessage}'),
      (_) {},
    );

    // 4. Send out founder invitations.
    for (final draft in state.founderDrafts) {
      final invite = await _companyController.inviteFounder(
        companyId: createdCompany.id!,
        phone: draft.phone,
        designation: draft.designation,
      );
      invite.fold(
        (failure) => warnings.add('${draft.displayPhone}: ${failure.errorMessage}'),
        (_) {},
      );
    }

    state = state.copyWith(
      status: RegisterCompanyStatus.success,
      createdCompany: createdCompany,
      warningMessage: warnings.isEmpty
          ? ''
          : 'Company created, but some steps need attention:\n${warnings.join('\n')}',
    );
    return true;
  }

  void resetStatus() => state = state.copyWith(
        status: RegisterCompanyStatus.initial,
        errorMessage: null,
      );
}
