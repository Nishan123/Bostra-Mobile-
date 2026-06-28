import 'package:bostra/controllers/company_controller.dart';
import 'package:bostra/ui/company/state/my_companies_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final myCompaniesViewModelProvider =
    NotifierProvider<MyCompaniesViewModel, MyCompaniesState>(
  MyCompaniesViewModel.new,
);

class MyCompaniesViewModel extends Notifier<MyCompaniesState> {
  late CompanyController _companyController;

  @override
  MyCompaniesState build() {
    _companyController = ref.read(companyControllerProvider);
    Future.microtask(fetchMyCompanies);
    return const MyCompaniesState();
  }

  Future<void> fetchMyCompanies() async {
    state = state.copyWith(
      status: MyCompaniesStatus.loading,
      errorMessage: null,
    );
    final result = await _companyController.getMyCompanies();
    result.fold(
      (failure) => state = state.copyWith(
        status: MyCompaniesStatus.error,
        errorMessage: failure.errorMessage,
      ),
      (companies) => state = state.copyWith(
        status: MyCompaniesStatus.success,
        companies: companies,
      ),
    );
  }
}
