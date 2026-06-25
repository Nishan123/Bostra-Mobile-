import 'package:bostra/controllers/investment_controller.dart';
import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/fund_startup/state/fund_startup_state.dart';
import 'package:bostra/ui/fund_startup/view_model/fund_startup_view_model.dart';
import 'package:bostra/ui/investment/view_model/investment_tab_view_model.dart';
import 'package:bostra/ui/payment/widgets/payment_bottom_sheet.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FundStartupScreen extends ConsumerStatefulWidget {
  final CampaignModel campaign;
  const FundStartupScreen({super.key, required this.campaign});

  @override
  ConsumerState<FundStartupScreen> createState() => _FundStartupScreenState();
}

class _FundStartupScreenState extends ConsumerState<FundStartupScreen> {
  final _amountController = TextEditingController();

  CampaignModel get c => widget.campaign;

  String get _campaignId => c.id ?? '';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vmProvider = fundStartupViewModelProvider(_campaignId);
    final state = ref.watch(vmProvider);
    final vm = ref.read(vmProvider.notifier);

    // Listen for success / error
    ref.listen<FundStartupState>(vmProvider, (_, next) {
      if (next.status == FundStatus.success) {
        _showSuccess(context);
        vm.resetStatus();
      } else if (next.status == FundStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Something went wrong'),
            backgroundColor: AppColors.redColor,
          ),
        );
        vm.resetStatus();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: _BackButton(),
        title: Text(
          'Fund Now',
          style: TextStyle(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 0.6,
            color: AppColors.blackColor.withAlpha(30),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 28),

            // ── "You're funding," ──────────────────────────────────────────
            Text(
              "You're funding,",
              style: AppTextStyle.h2.copyWith(
                color: AppColors.redColor,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),

            // ── "StartupName by CompanyName" ───────────────────────────────
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${c.startupName} ',
                    style: AppTextStyle.bodyText1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.blackColor,
                    ),
                  ),
                  TextSpan(
                    text: 'by ',
                    style: AppTextStyle.bodyText1.copyWith(
                      color: AppColors.blackColor,
                    ),
                  ),
                  TextSpan(
                    text: c.founderName ?? c.startupName,
                    style: AppTextStyle.bodyText1.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Agree checkbox ─────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 22,
                  height: 22,
                  child: Checkbox(
                    value: state.agreedToTerms,
                    onChanged: (_) => vm.toggleAgreement(),
                    activeColor: AppColors.primaryColor,
                    side: BorderSide(
                      color: AppColors.blackColor.withAlpha(120),
                      width: 1.4,
                    ),
                    materialTapTargetSize:
                        MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 3,
                    children: [
                      Text('Agree to all',
                          style: AppTextStyle.bodyText2.copyWith(
                              color: AppColors.blackColor)),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'privacy policy',
                          style: AppTextStyle.bodyText2.copyWith(
                            color: AppColors.textButtonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text('&',
                          style: AppTextStyle.bodyText2
                              .copyWith(color: AppColors.blackColor)),
                      GestureDetector(
                        onTap: () {},
                        child: Text(
                          'legal information',
                          style: AppTextStyle.bodyText2.copyWith(
                            color: AppColors.textButtonColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // ── Amount label ───────────────────────────────────────────────
            Text(
              'Enter the amount you want to fund',
              style: AppTextStyle.bodyText1.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),

            // ── Amount input ───────────────────────────────────────────────
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (val) {
                final parsed = double.tryParse(val);
                if (parsed != null) vm.setAmount(parsed);
              },
              style: AppTextStyle.bodyText1,
              decoration: InputDecoration(
                hintText: 'Amount',
                hintStyle: AppTextStyle.bodyText1.copyWith(
                  color: AppColors.blackColor.withAlpha(80),
                ),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Text(
                    '₹',
                    style: TextStyle(
                      fontSize: 20,
                      color: AppColors.blackColor.withAlpha(160),
                    ),
                  ),
                ),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 0,
                  minHeight: 0,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor.withAlpha(180),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 1.6,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),

            // ── Minimum amount hint ────────────────────────────────────────
            if (c.minimumInvestment > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Minimum investment: Rs ${c.minimumInvestment.toStringAsFixed(0)}',
                style: AppTextStyle.bodyText3.copyWith(
                  color: AppColors.blackColor.withAlpha(120),
                ),
              ),
            ],

            const Spacer(),
          ],
        ),
      ),

      // ── Sticky Next / Submit button ──────────────────────────────────────
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
          top: 12,
        ),
        child: PrimaryButton(
          text: 'Next',
          isLoading: state.status == FundStatus.loading,
          onTap: () => _startPayment(context, vm),
        ),
      ),
    );
  }

  /// Validates input, then shows the mock payment sheet. Only after the card
  /// is "charged" do we run the real funding via [submitInvestment].
  Future<void> _startPayment(
    BuildContext context,
    FundStartupViewModel vm,
  ) async {
    if (!vm.validateForPayment()) return;

    final double amount =
        ref.read(fundStartupViewModelProvider(_campaignId)).amount ?? 0;

    final result = await PaymentBottomSheet.show(
      context,
      amount: amount,
      campaign: c,
    );

    // Sheet dismissed without completing payment.
    if (result == null || !mounted) return;

    // Card accepted — fund the campaign for real.
    await vm.submitInvestment();
  }

  void _showSuccess(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                color: AppColors.primaryColor,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text('Investment Successful!',
                style: AppTextStyle.h3,
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              'You have successfully funded ${c.startupName}.',
              style: AppTextStyle.bodyText2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              text: 'Done',
              onTap: () {
                ref.read(investmentTabViewModelProvider.notifier).fetchData();
                // Refresh one-time-fund state + backers so the details screen
                // flips to "Add More Funding" immediately.
                ref.invalidate(hasInvestedProvider(_campaignId));
                ref.invalidate(campaignBackersProvider(_campaignId));
                Navigator.of(context).pop(); // close dialog
                Navigator.of(context).pop(); // pop fund screen
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.turnaryColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_back,
          color: AppColors.blackColor,
          size: 20,
        ),
      ),
    );
  }
}
