import 'dart:io';
import 'package:bostra/theme/app_colors.dart';
import 'package:bostra/theme/app_text_style.dart';
import 'package:bostra/ui/auth/widgets/auth_input_field.dart';
import 'package:bostra/ui/auth/view_models/user_details_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PersonalInfoStep extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(userDetailsViewModelProvider);
    final notifier = ref.read(userDetailsViewModelProvider.notifier);

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
        const SizedBox(height: 20),

        // Profile Picture Selector
        Center(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => notifier.pickDocument('profilePic'),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primaryColor.withAlpha(20),
                  backgroundImage: state.profilePicFile != null
                      ? FileImage(File(state.profilePicFile!.path))
                      : null,
                  child: state.profilePicFile == null
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: AppColors.primaryColor,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => notifier.pickDocument('profilePic'),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
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
