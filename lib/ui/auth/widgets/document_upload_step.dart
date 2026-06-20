import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/state/user_details_state.dart';
import 'package:bostra/ui/auth/view_models/user_details_view_model.dart';
import 'package:bostra/ui/auth/widgets/document_picker_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DocumentUploadStep extends ConsumerWidget {
  const DocumentUploadStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailsViewModelProvider);
    final notifier = ref.read(userDetailsViewModelProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Upload your\ndocuments.', style: AppTextStyle.h1),
        const SizedBox(height: 6),
        Text(
          'Your government issued documents\nfor verifications',
          style: AppTextStyle.bodyText1.copyWith(
            color: AppColors.blackColor.withAlpha(160),
          ),
        ),
        const SizedBox(height: 20),

        // Toggle — Citizenship / National ID
        _DocumentTypeToggle(
          selected: state.documentType,
          onSelected: notifier.setDocumentType,
        ),
        const SizedBox(height: 16),

        // Document upload area
        if (state.documentType == DocumentType.citizenship) ...[
          DocumentPickerCard(
            label: 'Full Document',
            pickedFile: state.citizenshipFile,
            onTap: () => notifier.pickDocument('citizenship'),
          ),
        ] else ...[
          DocumentPickerCard(
            label: 'Front side',
            pickedFile: state.nationalIdFrontFile,
            onTap: () => notifier.pickDocument('nationalIdFront'),
          ),
          const SizedBox(height: 12),
          DocumentPickerCard(
            label: 'Back side',
            pickedFile: state.nationalIdBackFile,
            onTap: () => notifier.pickDocument('nationalIdBack'),
          ),
        ],
      ],
    );
  }
}

class _DocumentTypeToggle extends StatelessWidget {
  final DocumentType selected;
  final ValueChanged<DocumentType> onSelected;

  const _DocumentTypeToggle({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Citizenship',
            isSelected: selected == DocumentType.citizenship,
            onTap: () => onSelected(DocumentType.citizenship),
          ),
          _Tab(
            label: 'National ID',
            isSelected: selected == DocumentType.nationalId,
            onTap: () => onSelected(DocumentType.nationalId),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? AppColors.blackColor
                  : AppColors.blackColor.withAlpha(140),
            ),
          ),
        ),
      ),
    );
  }
}
