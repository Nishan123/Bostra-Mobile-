import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/ui/start_campain/state/campaign_state.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class StartCampain4 extends ConsumerStatefulWidget {
  const StartCampain4({super.key});

  @override
  ConsumerState<StartCampain4> createState() => _StartCampain4State();
}

class _StartCampain4State extends ConsumerState<StartCampain4> {
  late final TextEditingController _amountController;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    final campaign = ref.read(campaignViewModelProvider).campaign;
    _amountController = TextEditingController(
      text: campaign.targetAmount > 0 ? campaign.targetAmount.toStringAsFixed(0) : '',
    );
    _agreedToTerms = campaign.agreedToTerms;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CampaignState>(campaignViewModelProvider, (previous, next) {
      if (next.status == CampaignStatus.success) {
        CustomSnackBar.showSuccessSnackBar(context, "Campaign created successfully!");
        ref.read(campaignViewModelProvider.notifier).resetStatus();
        context.go('/main');
      } else if (next.status == CampaignStatus.error) {
        final message = next.errorMessage ?? "Failed to start campaign";
        CustomSnackBar.showErrorSnackBar(context, message);
        ref.read(campaignViewModelProvider.notifier).resetStatus();
      }
    });

    final campaignState = ref.watch(campaignViewModelProvider);

    return Scaffold(
      appBar: CampainAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    const StartCampainProgress(currentStep: 4, totalSteps: 4),

                    const SizedBox(height: 16),

                    // Enter target amount
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Enter your target amount.',
                        style: AppTextStyle.h4,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Amount text field
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyle.normalText.copyWith(
                          color: AppColors.blackColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'NPR 0.00',
                          hintStyle: AppTextStyle.normalText.copyWith(
                            color: AppColors.blackColor.withAlpha(100),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              'NPR',
                              style: AppTextStyle.h3.copyWith(
                                color: AppColors.blackColor.withAlpha(150),
                              ),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(
                            minWidth: 0,
                            minHeight: 0,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Verification notice
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Your campaign needs to be verified before other users can start to fund.',
                        style: AppTextStyle.bodyText2.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Terms checkbox
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Agree to all ',
                    style: AppTextStyle.normalText.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  Text(
                    'terms and conditions',
                    style: AppTextStyle.normalText.copyWith(
                      color: AppColors.textButtonColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Next button
            PrimaryButton(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              text: 'Next',
              isLoading: campaignState.status == CampaignStatus.loading,
              onTap: () {
                if (!_agreedToTerms) {
                  CustomSnackBar.showErrorSnackBar(
                    context,
                    "You must agree to the terms and conditions.",
                  );
                  return;
                }

                final amountText = _amountController.text.trim();
                if (amountText.isEmpty) {
                  CustomSnackBar.showErrorSnackBar(
                    context,
                    "Please enter a target amount.",
                  );
                  return;
                }

                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  CustomSnackBar.showErrorSnackBar(
                    context,
                    "Please enter a valid target amount.",
                  );
                  return;
                }

                final notifier = ref.read(campaignViewModelProvider.notifier);
                notifier.updateTargetAmount(amount);
                notifier.updateAgreedToTerms(_agreedToTerms);
                notifier.submitCampaign();
              },
            ),
          ],
        ),
      ),
    );
  }
}
