import 'package:bostra/models/company_model.dart';

enum MyCompaniesStatus { initial, loading, success, error }

class MyCompaniesState {
  final MyCompaniesStatus status;
  final String? errorMessage;
  final List<CompanyModel> companies;

  const MyCompaniesState({
    this.status = MyCompaniesStatus.initial,
    this.errorMessage,
    this.companies = const [],
  });

  bool get isEmpty =>
      status == MyCompaniesStatus.success && companies.isEmpty;

  /// One company per account: true once the user owns a company.
  bool get ownsCompany => companies.any((c) => c.isOwner);

  MyCompaniesState copyWith({
    MyCompaniesStatus? status,
    String? errorMessage,
    List<CompanyModel>? companies,
  }) {
    return MyCompaniesState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      companies: companies ?? this.companies,
    );
  }
}
