import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/widgets/auth_input_field.dart';
import 'package:flutter/material.dart';

class PersonalInfoStep extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController dobController;
  final TextEditingController addressController;
  final VoidCallback onDobTap;

  const PersonalInfoStep({
    super.key,
    required this.nameController,
    required this.dobController,
    required this.addressController,
    required this.onDobTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome!', style: AppTextStyle.h1),
        const SizedBox(height: 4),
        Text(
          'New User',
          style: AppTextStyle.bodyText1.copyWith(
            color: AppColors.blackColor.withAlpha(160),
          ),
        ),
        const SizedBox(height: 24),

        // Full Name field
        AuthInputField(
          controller: nameController,
          hintText: 'Full Name',
          trailingIcon: Icon(
            Icons.person_outline_rounded,
            color: AppColors.blackColor.withAlpha(160),
            size: 20,
          ),
        ),
        const SizedBox(height: 14),

        // DOB field
        AuthInputField(
          controller: dobController,
          hintText: 'DOB',
          readOnly: true,
          onTap: onDobTap,
          trailingIcon: Icon(
            Icons.calendar_today_outlined,
            color: AppColors.blackColor.withAlpha(160),
            size: 20,
          ),
        ),
        const SizedBox(height: 14),

        // Address field
        AuthInputField(
          controller: addressController,
          hintText: 'Address (Permanent)',
          trailingIcon: Icon(
            Icons.location_on_outlined,
            color: AppColors.blackColor.withAlpha(160),
            size: 20,
          ),
        ),
      ],
    );
  }
}
