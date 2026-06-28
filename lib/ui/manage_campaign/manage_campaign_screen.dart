import 'package:bostra/models/campaign_model.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/manage_campaign/state/manage_campaign_state.dart';
import 'package:bostra/ui/manage_campaign/view_model/manage_campaign_view_model.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ManageCampaignScreen extends ConsumerStatefulWidget {
  final CampaignModel campaign;
  const ManageCampaignScreen({super.key, required this.campaign});

  @override
  ConsumerState<ManageCampaignScreen> createState() =>
      _ManageCampaignScreenState();
}

class _ManageCampaignScreenState extends ConsumerState<ManageCampaignScreen> {
  late final TextEditingController _amountController;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.campaign.targetAmount > 0
          ? widget.campaign.targetAmount.toStringAsFixed(0)
          : '',
    );
    _endDate = widget.campaign.endDate;
    Future.microtask(
      () => ref
          .read(manageCampaignViewModelProvider.notifier)
          .init(widget.campaign),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final initial = _endDate != null && _endDate!.isAfter(now)
        ? _endDate!
        : now.add(const Duration(days: 30));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
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
    if (picked != null) setState(() => _endDate = picked);
  }

  void _save() {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null) {
      CustomSnackBar.showErrorSnackBar(context, 'Enter a valid target amount.');
      return;
    }
    if (_endDate == null) {
      CustomSnackBar.showErrorSnackBar(context, 'Select a funding end date.');
      return;
    }
    ref.read(manageCampaignViewModelProvider.notifier).save(
          targetAmount: amount,
          endDate: _endDate!,
        );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return 'Select date';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ManageCampaignState>(manageCampaignViewModelProvider,
        (previous, next) {
      if (next.status == ManageCampaignStatus.success) {
        CustomSnackBar.showSuccessSnackBar(context, 'Campaign updated.');
        ref.read(manageCampaignViewModelProvider.notifier).resetStatus();
        context.pop(true);
      } else if (next.status == ManageCampaignStatus.error) {
        CustomSnackBar.showErrorSnackBar(
          context,
          next.errorMessage ?? 'Failed to update campaign.',
        );
        ref.read(manageCampaignViewModelProvider.notifier).resetStatus();
      }
    });

    final state = ref.watch(manageCampaignViewModelProvider);
    final isLoading = state.status == ManageCampaignStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Campaign')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        widget.campaign.startupName.isNotEmpty
                            ? widget.campaign.startupName
                            : 'Campaign',
                        style: AppTextStyle.h2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Any founder can adjust the funding target and the funding end date.',
                        style: AppTextStyle.bodyText2,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Raised so far (read-only context)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withAlpha(14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(LucideIcons.trending_up,
                                color: AppColors.primaryColor, size: 18),
                            const SizedBox(width: 10),
                            Text(
                              'Raised so far: NPR ${widget.campaign.currentFunding.toStringAsFixed(0)}',
                              style: AppTextStyle.bodyText1,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Target amount
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Target amount',
                        style: AppTextStyle.bodyText2.copyWith(
                          color: AppColors.blackColor.withAlpha(180),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyle.normalText
                            .copyWith(color: AppColors.blackColor),
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
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 0, minHeight: 0),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.blackColor.withAlpha(60)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: AppColors.primaryColor, width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // End date
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Funding end date',
                        style: AppTextStyle.bodyText2.copyWith(
                          color: AppColors.blackColor.withAlpha(180),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: InkWell(
                        onTap: _pickEndDate,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.blackColor.withAlpha(60)),
                          ),
                          child: Row(
                            children: [
                              Icon(LucideIcons.calendar,
                                  size: 18, color: AppColors.primaryColor),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(_endDate),
                                style: AppTextStyle.normalText
                                    .copyWith(color: AppColors.blackColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            PrimaryButton(
              margin: const EdgeInsets.all(16),
              text: 'Save changes',
              isLoading: isLoading,
              onTap: _save,
            ),
          ],
        ),
      ),
    );
  }
}
