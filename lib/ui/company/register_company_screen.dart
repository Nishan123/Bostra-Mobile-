import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/register_company_state.dart';
import 'package:bostra/ui/company/view_model/register_company_view_model.dart';
import 'package:bostra/ui/company/view_model/my_companies_view_model.dart';
import 'package:bostra/ui/company/widgets/company_details_step.dart';
import 'package:bostra/ui/company/widgets/register_founders_step.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegisterCompanyScreen extends ConsumerStatefulWidget {
  const RegisterCompanyScreen({super.key});

  @override
  ConsumerState<RegisterCompanyScreen> createState() =>
      _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends ConsumerState<RegisterCompanyScreen> {
  @override
  void initState() {
    super.initState();
    // Start from a clean draft every time the screen opens.
    Future.microtask(
      () => ref.read(registerCompanyViewModelProvider.notifier).reset(),
    );
  }

  /// Validates step 1 against the view-model draft (the steps write into it as
  /// the user types), then advances to the founders step.
  void _goToFounders() {
    final state = ref.read(registerCompanyViewModelProvider);
    if (state.company.name.trim().isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, 'Company name is required.');
      return;
    }
    if (state.ownerDesignation == null || state.ownerDesignation!.isEmpty) {
      CustomSnackBar.showErrorSnackBar(
        context,
        'Select your role in the company.',
      );
      return;
    }
    ref.read(registerCompanyViewModelProvider.notifier).goToStep(1);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RegisterCompanyState>(registerCompanyViewModelProvider, (
      previous,
      next,
    ) {
      if (next.status == RegisterCompanyStatus.success &&
          next.createdCompany != null) {
        final warning = next.warningMessage;
        if (warning != null && warning.isNotEmpty) {
          CustomSnackBar.showNormalSnackBar(context, warning);
        } else {
          CustomSnackBar.showSuccessSnackBar(
            context,
            '${next.createdCompany!.name} registered!',
          );
        }
        final company = next.createdCompany!;
        ref.read(registerCompanyViewModelProvider.notifier).resetStatus();
        // Keep the companies list fresh, then open the new company.
        ref.read(myCompaniesViewModelProvider.notifier).fetchMyCompanies();
        context.pushReplacement('/company-detail', extra: company);
      } else if (next.status == RegisterCompanyStatus.error) {
        CustomSnackBar.showErrorSnackBar(
          context,
          next.errorMessage ?? 'Failed to register company.',
        );
        ref.read(registerCompanyViewModelProvider.notifier).resetStatus();
      }
    });

    final state = ref.watch(registerCompanyViewModelProvider);
    final isFounderStep = state.currentStep == 1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            if (isFounderStep) {
              ref.read(registerCompanyViewModelProvider.notifier).goToStep(0);
            } else {
              context.pop();
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Register Company'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepHeader(currentStep: state.currentStep),
            Expanded(
              child: IndexedStack(
                index: state.currentStep,
                children: const [
                  CompanyDetailsStep(),
                  FoundersStep(),
                ],
              ),
            ),
            _buildBottomBar(state),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(RegisterCompanyState state) {
    final isLoading = state.status == RegisterCompanyStatus.loading;
    if (state.currentStep == 0) {
      return PrimaryButton(
        margin: const EdgeInsets.all(16),
        text: 'Next',
        onTap: _goToFounders,
      );
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => ref
                      .read(registerCompanyViewModelProvider.notifier)
                      .goToStep(0),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: BorderSide(color: AppColors.blackColor.withAlpha(60)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Back', style: TextStyle(color: AppColors.blackColor)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              text: 'Register company',
              isLoading: isLoading,
              onTap: () =>
                  ref.read(registerCompanyViewModelProvider.notifier).submit(),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final int currentStep;
  const _StepHeader({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentStep == 0 ? 'Company details' : 'Invite founders',
            style: AppTextStyle.bodyText2.copyWith(color: AppColors.blackColor),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / 2,
              minHeight: 6,
              backgroundColor: AppColors.blackColor.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
