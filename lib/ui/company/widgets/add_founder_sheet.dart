import 'package:bostra/constants/country_picker_constants.dart';
import 'package:bostra/models/country.dart';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/widgets/country_picker_sheet.dart';
import 'package:bostra/ui/auth/widgets/phone_field.dart';
import 'package:bostra/ui/company/state/register_company_state.dart';
import 'package:bostra/ui/company/widgets/designation_dropdown.dart';
import 'package:bostra/widgets/custom_snackbar.dart';
import 'package:bostra/widgets/primary_button.dart';
import 'package:flutter/material.dart';

/// Bottom sheet to capture one founder invite (phone + designation).
class AddFounderSheet {
  static Future<void> show(
    BuildContext context, {
    required void Function(FounderDraft draft) onAdd,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.whiteColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _AddFounderSheetContent(onAdd: onAdd),
    );
  }
}

class _AddFounderSheetContent extends StatefulWidget {
  final void Function(FounderDraft draft) onAdd;
  const _AddFounderSheetContent({required this.onAdd});

  @override
  State<_AddFounderSheetContent> createState() =>
      _AddFounderSheetContentState();
}

class _AddFounderSheetContentState extends State<_AddFounderSheetContent> {
  final TextEditingController _phoneController = TextEditingController();
  Country _country = CountryPickerConstants.availableCountries.first;
  String? _designation;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _pickCountry() {
    CountryPickerSheet.showAvailableCountry(
      context: context,
      pickedCountry: _country,
      onCountrySelected: (country) {
        setState(() => _country = country);
        Navigator.of(context).pop();
      },
    );
  }

  void _submit() {
    final number = _phoneController.text.trim();
    if (number.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, 'Enter the founder\'s phone number.');
      return;
    }
    if (_designation == null || _designation!.isEmpty) {
      CustomSnackBar.showErrorSnackBar(context, 'Select a designation.');
      return;
    }

    // Normalise to digits-only (matches how Supabase stores phone numbers),
    // so the invite auto-links to an existing account.
    final normalized =
        '${_country.phoneCode}$number'.replaceAll('+', '').replaceAll(' ', '');

    widget.onAdd(
      FounderDraft(
        phone: normalized,
        displayPhone: '${_country.phoneCode} $number',
        designation: _designation!,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 4,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Invite a founder', style: AppTextStyle.h3),
          const SizedBox(height: 4),
          Text(
            'They\'ll get an invitation in their notifications to accept or decline.',
            style: AppTextStyle.bodyText3,
          ),
          const SizedBox(height: 16),

          Text(
            'Phone number',
            style: AppTextStyle.bodyText2.copyWith(
              color: AppColors.blackColor.withAlpha(180),
            ),
          ),
          const SizedBox(height: 6),
          PhoneField(
            controller: _phoneController,
            pickerTab: _pickCountry,
            pickedCountry: _country,
          ),
          const SizedBox(height: 16),

          Text(
            'Designation',
            style: AppTextStyle.bodyText2.copyWith(
              color: AppColors.blackColor.withAlpha(180),
            ),
          ),
          const SizedBox(height: 6),
          DesignationDropdown(
            selected: _designation,
            onChanged: (v) => setState(() => _designation = v),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: 'Add founder',
            onTap: _submit,
          ),
        ],
      ),
    );
  }
}
