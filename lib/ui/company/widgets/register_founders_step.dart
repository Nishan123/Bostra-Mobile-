import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/company/state/register_company_state.dart';
import 'package:bostra/ui/company/view_model/register_company_view_model.dart';
import 'package:bostra/ui/company/widgets/add_founder_sheet.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/widget_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 2 of company registration: invite founders. Reads the draft straight
/// from the register view model.
class FoundersStep extends ConsumerWidget {
  const FoundersStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(registerCompanyViewModelProvider);
    final notifier = ref.read(registerCompanyViewModelProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const WidgetTitle(text: 'Founders'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Invite co-founders by phone number. They\'ll receive an invitation '
              'in their notifications to accept or decline. You can also add them later.',
              style: AppTextStyle.bodyText2,
            ),
          ),
          const SizedBox(height: 16),

          // Owner (you) row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withAlpha(14),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primaryColor.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.crown, color: AppColors.primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You — ${state.ownerDesignation ?? 'Owner'}',
                    style: AppTextStyle.bodyText1
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  'Owner',
                  style: AppTextStyle.bodyText3.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          ...state.founderDrafts.asMap().entries.map((entry) {
            return _FounderDraftTile(
              draft: entry.value,
              onRemove: () => notifier.removeFounderDraft(entry.key),
            );
          }),

          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: () => AddFounderSheet.show(
                context,
                onAdd: (draft) {
                  final added = notifier.addFounderDraft(draft);
                  if (!added) {
                    CustomSnackBar.showErrorSnackBar(
                      context,
                      '${draft.displayPhone} is already added.',
                    );
                  }
                },
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                side: BorderSide(color: AppColors.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(LucideIcons.user_plus, color: AppColors.primaryColor),
              label: Text(
                'Add founder',
                style: TextStyle(color: AppColors.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _FounderDraftTile extends StatelessWidget {
  final FounderDraft draft;
  final VoidCallback onRemove;
  const _FounderDraftTile({required this.draft, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blackColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primaryColor.withAlpha(30),
            child: Icon(
              LucideIcons.user,
              size: 18,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.displayPhone,
                  style: AppTextStyle.bodyText1
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                Text(draft.designation, style: AppTextStyle.bodyText3),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
            icon: Icon(LucideIcons.x, size: 18, color: AppColors.redColor),
          ),
        ],
      ),
    );
  }
}
