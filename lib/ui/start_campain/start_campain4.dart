import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/start_campain/widgets/campain_app_bar.dart';
import 'package:bostra/ui/start_campain/widgets/start_campain_progress.dart';
import 'package:bostra/ui/start_campain/view_model/start_campaign_view_model.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
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
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    final campaign = ref.read(campaignViewModelProvider).campaign;
    _amountController = TextEditingController(
      text: campaign.targetAmount > 0 ? campaign.targetAmount.toStringAsFixed(0) : '',
    );
    _agreedToTerms = campaign.agreedToTerms;
    _dueDate = campaign.endDate;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Earliest selectable due date: 5 days from today (≈2 days for verification
  /// plus a funding buffer).
  DateTime get _minDueDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 5));
  }

  Future<void> _pickDueDate() async {
    final first = _minDueDate;
    final initial =
        (_dueDate != null && !_dueDate!.isBefore(first)) ? _dueDate! : first;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: first.add(const Duration(days: 730)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primaryColor,
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
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
                    const StartCampainProgress(currentStep: 4, totalSteps: 5),

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
                    const SizedBox(height: 20),

                    // Funding due date
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Funding due date', style: AppTextStyle.h4),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: _pickDueDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primaryColor,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.calendar,
                                size: 18,
                                color: AppColors.primaryColor,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _dueDate != null
                                    ? _formatDate(_dueDate!)
                                    : 'Select due date',
                                style: AppTextStyle.normalText.copyWith(
                                  color: _dueDate != null
                                      ? AppColors.blackColor
                                      : AppColors.blackColor.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Pick a date at least 5 days away — campaigns take ~2 days to verify. Funding closes automatically once this date passes.',
                        style: AppTextStyle.bodyText3,
                      ),
                    ),
                    const SizedBox(height: 16),

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

            // Next button → Investor Rewards step
            PrimaryButton(
              margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              text: 'Next',
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

                if (_dueDate == null) {
                  CustomSnackBar.showErrorSnackBar(
                    context,
                    "Please select a funding due date.",
                  );
                  return;
                }

                final notifier = ref.read(campaignViewModelProvider.notifier);
                notifier.updateTargetAmount(amount);
                notifier.updateEndDate(_dueDate!);
                notifier.updateAgreedToTerms(_agreedToTerms);

                // Rewards are configured on the next (final) step before publish.
                context.pushNamed('startCampaign5');
              },
            ),
          ],
        ),
      ),
    );
  }
}
